import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'features/camera/presentation/camera_screen.dart';
import 'features/auth/presentation/sign_in_screen.dart';
import 'features/subscription/presentation/subscription_screen.dart';
import 'features/analysis/presentation/analysis_history_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/debug/firebase_test_screen.dart';
import 'core/services/security_service.dart';
import 'core/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase with error handling
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Verify Firebase is working by checking auth instance
    final auth = FirebaseAuth.instance;
    print('Firebase Auth instance: ${auth.toString()}');
    
    // Initialize Security Service
    await SecurityService().initialize();
    
    print('✅ Firebase initialized successfully');
  } catch (e, stackTrace) {
    print('❌ Firebase initialization failed: $e');
    print('Stack trace: $stackTrace');
    // Continue app launch even if Firebase fails to initialize
    // The app will show appropriate error messages for auth operations
  }
  
  runApp(const IrisAnalysisApp());
}

class IrisAnalysisApp extends StatelessWidget {
  const IrisAnalysisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iris Analysis App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          
          // Check Firebase auth or demo auth
          final authService = AuthService();
          if (snapshot.hasData || authService.isSignedIn) {
            return const HomePage();
          }
          
          return const SignInScreen();
        },
      ),
      routes: {
        '/home': (context) => const HomePage(),
        '/signin': (context) => const SignInScreen(),
        '/subscription': (context) => const SubscriptionScreen(),
        '/history': (context) => const AnalysisHistoryScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/firebase-test': (context) => const FirebaseTestScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.visibility,
                size: 60,
                color: Colors.blue.shade900,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Iris Analysis',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'AI-Powered Health Insights',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iris Analysis Dashboard'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to Iris Analysis',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Analyze your iris patterns for health insights using AI technology.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFeatureCard(
                    'Camera Capture',
                    Icons.camera_alt,
                    Colors.green,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CameraScreen(),
                      ),
                    ),
                  ),
                  _buildFeatureCard(
                    'AI Analysis',
                    Icons.psychology,
                    Colors.purple,
                    () => _showComingSoon(context, 'AI Analysis feature'),
                  ),
                  _buildFeatureCard(
                    'Health Reports',
                    Icons.description,
                    Colors.orange,
                    () => _showComingSoon(context, 'Reports feature'),
                  ),
                  _buildFeatureCard(
                    'History',
                    Icons.history,
                    Colors.blue,
                    () => Navigator.pushNamed(context, '/history'),
                  ),
                  _buildFeatureCard(
                    'Subscription',
                    Icons.card_membership,
                    Colors.amber,
                    () => Navigator.pushNamed(context, '/subscription'),
                  ),
                  _buildFeatureCard(
                    'Settings',
                    Icons.settings,
                    Colors.grey,
                    () => Navigator.pushNamed(context, '/settings'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: Colors.blue.shade900,
      ),
    );
  }
}
