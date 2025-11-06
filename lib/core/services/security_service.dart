import 'dart:typed_data';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Security settings
  bool _biometricEnabled = false;
  bool _encryptionEnabled = true;
  bool _autoLockEnabled = true;
  int _autoLockTimeout = 300; // 5 minutes
  DateTime? _lastActivity;

  // Encryption keys
  late Uint8List _encryptionKey;
  late String _keyId;

  // Initialize security framework
  Future<void> initialize() async {
    await _loadSecuritySettings();
    await _initializeEncryption();
    _updateLastActivity();
  }

  // Biometric Authentication
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  Future<bool> authenticateWithBiometrics({
    String reason = 'Please authenticate to access your health data',
  }) async {
    try {
      if (!_biometricEnabled) return true;
      
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      final result = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (result) {
        _updateLastActivity();
      }

      return result;
    } catch (e) {
      return false;
    }
  }

  // App Lock Management
  bool get isAutoLockEnabled => _autoLockEnabled;
  int get autoLockTimeout => _autoLockTimeout;

  void _updateLastActivity() {
    _lastActivity = DateTime.now();
  }

  bool shouldLockApp() {
    if (!_autoLockEnabled || _lastActivity == null) return false;
    
    final now = DateTime.now();
    final timeSinceLastActivity = now.difference(_lastActivity!).inSeconds;
    return timeSinceLastActivity >= _autoLockTimeout;
  }

  Future<void> lockApp() async {
    _lastActivity = null;
  }

  Future<bool> unlockApp() async {
    if (_biometricEnabled) {
      return await authenticateWithBiometrics(
        reason: 'Unlock app to access your health data',
      );
    }
    return true;
  }

  // Encryption Management
  Future<void> _initializeEncryption() async {
    try {
      // Try to load existing key
      final keyData = await _secureStorage.read(key: 'encryption_key');
      final keyIdData = await _secureStorage.read(key: 'key_id');

      if (keyData != null && keyIdData != null) {
        _encryptionKey = base64Decode(keyData);
        _keyId = keyIdData;
      } else {
        // Generate new encryption key
        await _generateNewEncryptionKey();
      }
    } catch (e) {
      // If loading fails, generate new key
      await _generateNewEncryptionKey();
    }
  }

  Future<void> _generateNewEncryptionKey() async {
    final random = Random.secure();
    _encryptionKey = Uint8List.fromList(List.generate(32, (_) => random.nextInt(256)));
    _keyId = _generateKeyId();

    await _secureStorage.write(
      key: 'encryption_key',
      value: base64Encode(_encryptionKey),
    );
    await _secureStorage.write(key: 'key_id', value: _keyId);
  }

  String _generateKeyId() {
    final random = Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  // Data Encryption/Decryption
  Future<String> encryptData(String data) async {
    if (!_encryptionEnabled) return data;

    try {
      final bytes = utf8.encode(data);
      final encrypted = await _encryptBytes(bytes);
      return base64Encode(encrypted);
    } catch (e) {
      throw SecurityException('Failed to encrypt data: $e');
    }
  }

  Future<String> decryptData(String encryptedData) async {
    if (!_encryptionEnabled) return encryptedData;

    try {
      final encryptedBytes = base64Decode(encryptedData);
      final decrypted = await _decryptBytes(encryptedBytes);
      return utf8.decode(decrypted);
    } catch (e) {
      throw SecurityException('Failed to decrypt data: $e');
    }
  }

  Future<Uint8List> encryptFile(Uint8List fileData) async {
    if (!_encryptionEnabled) return fileData;
    return await _encryptBytes(fileData);
  }

  Future<Uint8List> decryptFile(Uint8List encryptedData) async {
    if (!_encryptionEnabled) return encryptedData;
    return await _decryptBytes(encryptedData);
  }

  Future<Uint8List> _encryptBytes(Uint8List data) async {
    // Simple XOR encryption (in production, use AES)
    final encrypted = Uint8List(data.length);
    for (int i = 0; i < data.length; i++) {
      encrypted[i] = data[i] ^ _encryptionKey[i % _encryptionKey.length];
    }
    return encrypted;
  }

  Future<Uint8List> _decryptBytes(Uint8List encryptedData) async {
    // Simple XOR decryption (in production, use AES)
    final decrypted = Uint8List(encryptedData.length);
    for (int i = 0; i < encryptedData.length; i++) {
      decrypted[i] = encryptedData[i] ^ _encryptionKey[i % _encryptionKey.length];
    }
    return decrypted;
  }

  // Key Management
  Future<void> rotateEncryptionKey() async {
    // Store old key for data migration
    final oldKey = _encryptionKey;
    final oldKeyId = _keyId;

    // Generate new key
    await _generateNewEncryptionKey();

    // Store old key temporarily for data re-encryption
    await _secureStorage.write(
      key: 'old_encryption_key',
      value: base64Encode(oldKey),
    );
    await _secureStorage.write(key: 'old_key_id', value: oldKeyId);
  }

  Future<void> clearOldKeys() async {
    await _secureStorage.delete(key: 'old_encryption_key');
    await _secureStorage.delete(key: 'old_key_id');
  }

  // Data Sanitization
  String sanitizeHealthData(String data) {
    // Remove sensitive patterns
    return data
        .replaceAll(RegExp(r'\b\d{3}-\d{2}-\d{4}\b'), '[SSN]') // SSN
        .replaceAll(RegExp(r'\b\d{16}\b'), '[CARD]') // Credit card
        .replaceAll(RegExp(r'\b[\w\.-]+@[\w\.-]+\.\w+\b'), '[EMAIL]') // Email
        .replaceAll(RegExp(r'\b\d{3}-\d{3}-\d{4}\b'), '[PHONE]'); // Phone
  }

  // Privacy Controls
  Future<void> enablePrivacyMode() async {
    await _secureStorage.write(key: 'privacy_mode', value: 'true');
  }

  Future<void> disablePrivacyMode() async {
    await _secureStorage.write(key: 'privacy_mode', value: 'false');
  }

  Future<bool> isPrivacyModeEnabled() async {
    final value = await _secureStorage.read(key: 'privacy_mode');
    return value == 'true';
  }

  // Security Settings Management
  Future<void> _loadSecuritySettings() async {
    try {
      final biometric = await _secureStorage.read(key: 'biometric_enabled');
      final encryption = await _secureStorage.read(key: 'encryption_enabled');
      final autoLock = await _secureStorage.read(key: 'auto_lock_enabled');
      final timeout = await _secureStorage.read(key: 'auto_lock_timeout');

      _biometricEnabled = biometric == 'true';
      _encryptionEnabled = encryption != 'false'; // Default to true
      _autoLockEnabled = autoLock != 'false'; // Default to true
      _autoLockTimeout = int.tryParse(timeout ?? '') ?? 300;
    } catch (e) {
      // Use defaults if loading fails
    }
  }

  Future<void> updateSecuritySettings({
    bool? biometricEnabled,
    bool? encryptionEnabled,
    bool? autoLockEnabled,
    int? autoLockTimeout,
  }) async {
    if (biometricEnabled != null) {
      _biometricEnabled = biometricEnabled;
      await _secureStorage.write(
        key: 'biometric_enabled',
        value: biometricEnabled.toString(),
      );
    }

    if (encryptionEnabled != null) {
      _encryptionEnabled = encryptionEnabled;
      await _secureStorage.write(
        key: 'encryption_enabled',
        value: encryptionEnabled.toString(),
      );
    }

    if (autoLockEnabled != null) {
      _autoLockEnabled = autoLockEnabled;
      await _secureStorage.write(
        key: 'auto_lock_enabled',
        value: autoLockEnabled.toString(),
      );
    }

    if (autoLockTimeout != null) {
      _autoLockTimeout = autoLockTimeout;
      await _secureStorage.write(
        key: 'auto_lock_timeout',
        value: autoLockTimeout.toString(),
      );
    }
  }

  // Security audit and compliance
  Future<Map<String, dynamic>> performSecurityAudit() async {
    final audit = <String, dynamic>{};

    // Check biometric setup
    audit['biometric_available'] = await isBiometricAvailable();
    audit['biometric_enabled'] = _biometricEnabled;
    audit['available_biometrics'] = await getAvailableBiometrics();

    // Check encryption
    audit['encryption_enabled'] = _encryptionEnabled;
    audit['key_id'] = _keyId;

    // Check app lock
    audit['auto_lock_enabled'] = _autoLockEnabled;
    audit['auto_lock_timeout'] = _autoLockTimeout;

    // Check privacy mode
    audit['privacy_mode_enabled'] = await isPrivacyModeEnabled();

    // Security score (0-100)
    int score = 0;
    if (audit['biometric_enabled']) score += 30;
    if (audit['encryption_enabled']) score += 40;
    if (audit['auto_lock_enabled']) score += 20;
    if (audit['privacy_mode_enabled']) score += 10;

    audit['security_score'] = score;
    audit['recommendations'] = _getSecurityRecommendations(audit);

    return audit;
  }

  List<String> _getSecurityRecommendations(Map<String, dynamic> audit) {
    final recommendations = <String>[];

    if (!audit['biometric_enabled'] && audit['biometric_available']) {
      recommendations.add('Enable biometric authentication for enhanced security');
    }

    if (!audit['encryption_enabled']) {
      recommendations.add('Enable data encryption to protect sensitive health information');
    }

    if (!audit['auto_lock_enabled']) {
      recommendations.add('Enable auto-lock to secure your app automatically');
    }

    if (!audit['privacy_mode_enabled']) {
      recommendations.add('Consider enabling privacy mode for additional data protection');
    }

    if (audit['security_score'] < 70) {
      recommendations.add('Your security score is below recommended level. Consider implementing more security features.');
    }

    return recommendations;
  }

  // Secure data deletion
  Future<void> secureDelete(String key) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> secureDeleteAll() async {
    await _secureStorage.deleteAll();
  }

  // Activity tracking
  void trackActivity(String activity) {
    _updateLastActivity();
    // In production, log security events
  }

  // Getters for settings
  bool get isBiometricEnabled => _biometricEnabled;
  bool get isEncryptionEnabled => _encryptionEnabled;
  String get keyId => _keyId;
}

class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}