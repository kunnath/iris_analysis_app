import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import '../errors/auth_exception.dart';
import 'iris_analysis_service.dart';

class CloudStorageService {
  static final CloudStorageService _instance = CloudStorageService._internal();
  factory CloudStorageService() => _instance;
  CloudStorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Encryption for sensitive data
  final _encrypter = Encrypter(AES(Key.fromSecureRandom(32)));

  // Upload iris image with encryption
  Future<String> uploadIrisImage(String imagePath, String analysisId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('User not authenticated');
    }

    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      
      // Encrypt image data for security
      final encryptedBytes = _encryptData(bytes);
      
      // Create unique path
      final fileName = 'iris_${analysisId}_${DateTime.now().millisecondsSinceEpoch}.enc';
      final path = 'users/${user.uid}/iris_images/$fileName';
      
      // Upload to Firebase Storage
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putData(
        encryptedBytes,
        SettableMetadata(
          contentType: 'application/octet-stream',
          customMetadata: {
            'original_type': 'image/jpeg',
            'analysis_id': analysisId,
            'encrypted': 'true',
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw StorageException('Failed to upload image: $e');
    }
  }

  // Download and decrypt iris image
  Future<Uint8List> downloadIrisImage(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      final data = await ref.getData();
      
      if (data == null) {
        throw const StorageException('Image data not found');
      }

      // Check if data is encrypted
      final metadata = await ref.getMetadata();
      final isEncrypted = metadata.customMetadata?['encrypted'] == 'true';
      
      if (isEncrypted) {
        return _decryptData(data);
      }
      
      return data;
    } catch (e) {
      throw StorageException('Failed to download image: $e');
    }
  }

  // Save analysis result to Firestore
  Future<void> saveAnalysisResult(IrisAnalysisResult result) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('User not authenticated');
    }

    try {
      // Upload image first
      final imageUrl = await uploadIrisImage(result.imagePath, result.id);
      
      // Create analysis document
      final analysisData = result.toMap();
      analysisData['imageUrl'] = imageUrl;
      analysisData['userId'] = user.uid;
      analysisData['createdAt'] = FieldValue.serverTimestamp();
      
      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('analyses')
          .doc(result.id)
          .set(analysisData);

      // Update user's analysis count
      await _updateUserAnalysisCount();
      
    } catch (e) {
      throw StorageException('Failed to save analysis: $e');
    }
  }

  // Get user's analysis history
  Future<List<IrisAnalysisResult>> getUserAnalysisHistory({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('User not authenticated');
    }

    try {
      Query query = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('analyses')
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return IrisAnalysisResult.fromMap(data);
      }).toList();
    } catch (e) {
      throw StorageException('Failed to fetch analysis history: $e');
    }
  }

  // Delete analysis
  Future<void> deleteAnalysis(String analysisId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('User not authenticated');
    }

    try {
      // Get analysis document first
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('analyses')
          .doc(analysisId)
          .get();

      if (!doc.exists) {
        throw const StorageException('Analysis not found');
      }

      final data = doc.data()!;
      final imageUrl = data['imageUrl'] as String?;

      // Delete image from storage if exists
      if (imageUrl != null) {
        try {
          final ref = _storage.refFromURL(imageUrl);
          await ref.delete();
        } catch (e) {
          // Log but don't fail if image deletion fails
          print('Failed to delete image: $e');
        }
      }

      // Delete document
      await doc.reference.delete();
      
    } catch (e) {
      throw StorageException('Failed to delete analysis: $e');
    }
  }

  // Sync user data across devices
  Future<void> syncUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('User not authenticated');
    }

    try {
      // Update last sync timestamp
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({
        'lastSyncAt': FieldValue.serverTimestamp(),
        'deviceInfo': {
          'platform': Platform.operatingSystem,
          'version': Platform.operatingSystemVersion,
          'syncedAt': DateTime.now().millisecondsSinceEpoch,
        },
      });
    } catch (e) {
      throw StorageException('Failed to sync user data: $e');
    }
  }

  // Export user data (GDPR compliance)
  Future<Map<String, dynamic>> exportUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('User not authenticated');
    }

    try {
      // Get user profile
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};

      // Get all analyses
      final analysesSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('analyses')
          .get();

      final analyses = analysesSnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();

      return {
        'exportedAt': DateTime.now().toIso8601String(),
        'userId': user.uid,
        'userProfile': userData,
        'analyses': analyses,
        'totalAnalyses': analyses.length,
      };
    } catch (e) {
      throw StorageException('Failed to export user data: $e');
    }
  }

  // Delete all user data (GDPR compliance)
  Future<void> deleteAllUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('User not authenticated');
    }

    try {
      // Delete all analyses
      final analysesSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('analyses')
          .get();

      final batch = _firestore.batch();
      
      for (final doc in analysesSnapshot.docs) {
        batch.delete(doc.reference);
        
        // Delete associated images
        final data = doc.data();
        final imageUrl = data['imageUrl'] as String?;
        if (imageUrl != null) {
          try {
            final ref = _storage.refFromURL(imageUrl);
            await ref.delete();
          } catch (e) {
            print('Failed to delete image: $e');
          }
        }
      }

      // Delete user profile
      batch.delete(_firestore.collection('users').doc(user.uid));

      await batch.commit();
      
    } catch (e) {
      throw StorageException('Failed to delete user data: $e');
    }
  }

  // Get storage usage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('User not authenticated');
    }

    try {
      final analyses = await getUserAnalysisHistory(limit: 1000);
      
      int totalImages = 0;
      int totalSize = 0;
      
      for (final analysis in analyses) {
        totalImages++;
        // Estimate size (actual size would require additional Storage API calls)
        totalSize += 500000; // ~500KB average per encrypted image
      }

      return {
        'totalAnalyses': analyses.length,
        'totalImages': totalImages,
        'estimatedSize': totalSize,
        'formattedSize': _formatBytes(totalSize),
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw StorageException('Failed to get storage stats: $e');
    }
  }

  // Search analyses
  Future<List<IrisAnalysisResult>> searchAnalyses({
    String? query,
    IrisHealthIndicator? healthFilter,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('User not authenticated');
    }

    try {
      Query firestoreQuery = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('analyses');

      // Apply filters
      if (healthFilter != null) {
        firestoreQuery = firestoreQuery.where('overallHealth', isEqualTo: healthFilter.name);
      }

      if (startDate != null) {
        firestoreQuery = firestoreQuery.where('timestamp', isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch);
      }

      if (endDate != null) {
        firestoreQuery = firestoreQuery.where('timestamp', isLessThanOrEqualTo: endDate.millisecondsSinceEpoch);
      }

      firestoreQuery = firestoreQuery
          .orderBy('timestamp', descending: true)
          .limit(limit);

      final snapshot = await firestoreQuery.get();
      
      List<IrisAnalysisResult> results = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return IrisAnalysisResult.fromMap(data);
      }).toList();

      // Apply text search if needed (client-side filtering)
      if (query != null && query.isNotEmpty) {
        results = results.where((result) {
          return result.insights.any((insight) =>
              insight.title.toLowerCase().contains(query.toLowerCase()) ||
              insight.description.toLowerCase().contains(query.toLowerCase()) ||
              insight.category.toLowerCase().contains(query.toLowerCase()));
        }).toList();
      }

      return results;
    } catch (e) {
      throw StorageException('Failed to search analyses: $e');
    }
  }

  // Private helper methods
  Uint8List _encryptData(Uint8List data) {
    final iv = IV.fromSecureRandom(16);
    final encrypted = _encrypter.encryptBytes(data, iv: iv);
    
    // Combine IV and encrypted data
    final result = Uint8List(iv.bytes.length + encrypted.bytes.length);
    result.setRange(0, iv.bytes.length, iv.bytes);
    result.setRange(iv.bytes.length, result.length, encrypted.bytes);
    
    return result;
  }

  Uint8List _decryptData(Uint8List encryptedData) {
    // Extract IV and encrypted data
    final iv = IV(encryptedData.sublist(0, 16));
    final encrypted = Encrypted(encryptedData.sublist(16));
    
    return Uint8List.fromList(_encrypter.decryptBytes(encrypted, iv: iv));
  }

  Future<void> _updateUserAnalysisCount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);
    await userRef.update({
      'analysisCount': FieldValue.increment(1),
      'lastAnalysisAt': FieldValue.serverTimestamp(),
    });
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}