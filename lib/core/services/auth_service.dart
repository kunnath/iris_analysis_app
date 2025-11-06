import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../errors/auth_exception.dart';
import 'demo_auth_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DemoAuthService _demoAuth = DemoAuthService();

  // Get current user (Firebase or Demo)
  User? get currentUser => _auth.currentUser;
  
  // Get current app user (includes demo user)
  AppUser? get currentAppUser {
    if (_demoAuth.isDemoSignedIn) {
      return _demoAuth.currentDemoUser;
    }
    return null; // In real app, this would fetch from Firestore
  }
  
  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Check if user is signed in (Firebase or Demo)
  bool get isSignedIn => _auth.currentUser != null || _demoAuth.isDemoSignedIn;

  // Sign up with email and password
  Future<AppUser?> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty || fullName.isEmpty) {
        throw AuthException('Please fill in all required fields');
      }
      
      if (!_isValidEmail(email)) {
        throw AuthException('Please enter a valid email address');
      }
      
      if (password.length < 8) {
        throw AuthException('Password must be at least 8 characters long');
      }

      // Check network connectivity
      await _checkNetworkConnectivity();

      // Check if Firebase is properly initialized
      if (!await _isFirebaseInitialized()) {
        throw AuthException('Firebase is not properly configured. Please contact support.');
      }

      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(fullName);
        
        // Create user document in Firestore
        final AppUser appUser = AppUser(
          id: user.uid,
          email: email,
          fullName: fullName,
          createdAt: DateTime.now(),
          subscriptionTier: SubscriptionTier.free,
          analysisCount: 0,
          isEmailVerified: false,
        );

        await _createUserDocument(appUser);
        
        // Send email verification
        await user.sendEmailVerification();
        
        return appUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      throw AuthException(_getAuthErrorMessage(e.code));
    } on SocketException catch (e) {
      print('Network Error: $e');
      throw AuthException('No internet connection. Please check your network and try again.');
    } catch (e) {
      print('Unexpected Error during sign up: $e');
      throw AuthException('Registration failed. Please check your internet connection and try again. Error: ${e.toString()}');
    }
  }

  // Sign in with email and password
  Future<AppUser?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Check if it's demo credentials first
      if (_demoAuth.isDemoCredentials(email, password)) {
        print('Demo login detected - bypassing Firebase');
        return _demoAuth.createDemoUser();
      }

      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user != null) {
        return await _getUserFromFirestore(user.uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      throw AuthException(_getAuthErrorMessage(e.code));
    } on SocketException catch (e) {
      print('Network Error: $e');
      throw AuthException('No internet connection. Please check your network and try again.');
    } catch (e) {
      print('Unexpected Error during sign in: $e');
      throw AuthException('Sign in failed. Please check your internet connection and try again. Error: ${e.toString()}');
    }
  }

  // Sign in with Google
  Future<AppUser?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await _auth.signInWithCredential(credential);
      final User? user = result.user;

      if (user != null) {
        // Check if user exists in Firestore
        AppUser? appUser = await _getUserFromFirestore(user.uid);
        
        if (appUser == null) {
          // Create new user document
          appUser = AppUser(
            id: user.uid,
            email: user.email ?? '',
            fullName: user.displayName ?? '',
            profileImageUrl: user.photoURL,
            createdAt: DateTime.now(),
            subscriptionTier: SubscriptionTier.free,
            analysisCount: 0,
            isEmailVerified: user.emailVerified,
          );
          await _createUserDocument(appUser);
        }
        
        return appUser;
      }
      return null;
    } catch (e) {
      throw AuthException('Google sign in failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Sign out demo user if applicable
      if (_demoAuth.isDemoSignedIn) {
        _demoAuth.signOutDemo();
        return;
      }

      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException('Sign out failed');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete user document from Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        
        // Delete user account
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateProfile(
          displayName: displayName,
          photoURL: photoURL,
        );
        await user.reload();
      }
    } catch (e) {
      throw AuthException('Profile update failed');
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw AuthException('Failed to send verification email');
    }
  }

  // Private helper methods
  Future<void> _createUserDocument(AppUser appUser) async {
    await _firestore.collection('users').doc(appUser.id).set(appUser.toMap());
  }

  Future<AppUser?> _getUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Invalid password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters with numbers and symbols';
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled. Please contact support';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection';
      case 'invalid-verification-code':
        return 'Invalid verification code';
      case 'invalid-verification-id':
        return 'Invalid verification ID';
      case 'missing-verification-code':
        return 'Please enter the verification code';
      case 'missing-verification-id':
        return 'Missing verification ID';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later';
      case 'captcha-check-failed':
        return 'reCAPTCHA verification failed. Please try again';
      case 'app-not-authorized':
        return 'App not authorized. Please contact support';
      case 'keychain-error':
        return 'Keychain error. Please try again';
      case 'internal-error':
        return 'Internal error. Please try again later';
      case 'invalid-credential':
        return 'Invalid credentials provided';
      case 'credential-already-in-use':
        return 'This credential is already associated with another account';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action';
      case 'provider-already-linked':
        return 'This account is already linked to another provider';
      case 'no-such-provider':
        return 'No such authentication provider found';
      case 'invalid-user-token':
        return 'Invalid user token. Please sign in again';
      case 'user-token-expired':
        return 'User token has expired. Please sign in again';
      case 'null-user':
        return 'No user is currently signed in';
      case 'invalid-api-key':
        return 'Invalid API key configuration. Please contact support';
      case 'app-deleted':
        return 'Firebase app configuration error. Please contact support';
      case 'expired-action-code':
        return 'This verification link has expired';
      case 'invalid-action-code':
        return 'This verification link is invalid';
      case 'unknown':
        return 'Firebase configuration error. Please ensure:\n1. SHA fingerprints are added to Firebase Console\n2. Internet connection is stable\n3. Firebase project is properly configured';
      case 'configuration-not-found':
        return 'Firebase configuration not found. Please contact support.';
      case 'project-not-found':
        return 'Firebase project not found. Please contact support.';
      case 'invalid-project-id':
        return 'Invalid Firebase project ID. Please contact support.';
      default:
        return 'Authentication failed with error: $code. Please ensure SHA fingerprints are added to Firebase Console and try again.';
    }
  }

  // Check if Firebase is properly initialized
  Future<bool> _isFirebaseInitialized() async {
    try {
      // Try to access Firebase Auth instance
      final user = _auth.currentUser;
      return true;
    } catch (e) {
      print('Firebase not properly initialized: $e');
      return false;
    }
  }

  // Helper method to validate email
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Check network connectivity
  Future<void> _checkNetworkConnectivity() async {
    try {
      // Test general internet connectivity
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        throw AuthException('No internet connection. Please check your network and try again.');
      }
      
      // Test Firebase connectivity
      try {
        final firebaseResult = await InternetAddress.lookup('firebase.googleapis.com');
        if (firebaseResult.isEmpty) {
          throw AuthException('Cannot connect to Firebase services. Please check your network and try again.');
        }
      } catch (e) {
        print('Firebase connectivity test failed: $e');
        throw AuthException('Cannot connect to Firebase services. Please check your network and try again.');
      }
    } on SocketException catch (_) {
      throw AuthException('No internet connection. Please check your network and try again.');
    }
  }
}
