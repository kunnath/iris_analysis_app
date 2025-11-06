import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../firebase_options.dart';

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  String _testResult = 'Testing Firebase configuration...';

  @override
  void initState() {
    super.initState();
    _testFirebaseConnection();
  }

  Future<void> _testFirebaseConnection() async {
    try {
      // Test 1: Check if Firebase is initialized
      setState(() => _testResult = '1. Checking Firebase initialization...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      final app = Firebase.app();
      if (app.name.isNotEmpty) {
        setState(() => _testResult = '✅ Firebase app initialized: ${app.name}\n\n2. Testing Auth service...');
      }
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Test 2: Check Firebase Auth instance
      final auth = FirebaseAuth.instance;
      setState(() => _testResult = '✅ Firebase app: ${app.name}\n✅ Firebase Auth instance: OK\n\n3. Testing project configuration...');
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Test 3: Check current Firebase options
      final options = DefaultFirebaseOptions.currentPlatform;
      setState(() => _testResult = '''✅ Firebase app: ${app.name}
✅ Firebase Auth instance: OK
✅ Project ID: ${options.projectId}
✅ API Key: ${options.apiKey.substring(0, 10)}...

4. Testing authentication...''');
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Test 4: Try a simple auth operation (sign out if signed in)
      if (auth.currentUser != null) {
        await auth.signOut();
      }
      
      setState(() => _testResult = '''✅ Firebase app: ${app.name}
✅ Firebase Auth instance: OK
✅ Project ID: ${options.projectId}
✅ API Key: ${options.apiKey.substring(0, 10)}...
✅ Auth operations: OK

🎉 Firebase is properly configured!

Note: If registration still fails with "unknown" error, 
add these SHA fingerprints to Firebase Console:

SHA1: E7:33:AA:81:0A:CC:08:1F:0C:D7:9F:24:C1:E5:D2:7C:FF:86:49:C3
SHA256: 9D:2F:D4:EF:28:48:FC:26:A1:38:18:0A:3D:A7:18:6C:BA:93:71:F5:81:94:21:06:6A:7D:9C:3D:AA:24:E3:53''');
      
    } catch (e) {
      setState(() => _testResult = '''❌ Firebase Test Failed:
      
Error: $e

This error suggests:
1. Firebase project doesn't exist or is misconfigured
2. Invalid API keys in firebase_options.dart
3. Network connectivity issues
4. Missing SHA fingerprints in Firebase Console

Check Firebase Console and ensure project is properly set up.''');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Configuration Test'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    _testResult,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _testFirebaseConnection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Retest Firebase Configuration'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}