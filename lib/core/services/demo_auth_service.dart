import '../models/app_user.dart';

class DemoAuthService {
  static final DemoAuthService _instance = DemoAuthService._internal();
  factory DemoAuthService() => _instance;
  DemoAuthService._internal();

  // Demo user credentials
  static const String demoEmail = 'demo@irisapp.com';
  static const String demoPassword = 'Demo123456';
  static const String demoFullName = 'Demo User';

  // Demo user object
  AppUser? _currentDemoUser;

  // Check if credentials match demo account
  bool isDemoCredentials(String email, String password) {
    return email.toLowerCase().trim() == demoEmail && password == demoPassword;
  }

  // Create demo user session
  AppUser createDemoUser() {
    _currentDemoUser = AppUser(
      id: 'demo_user_123',
      email: demoEmail,
      fullName: demoFullName,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastLoginAt: DateTime.now(),
      subscriptionTier: SubscriptionTier.premium, // Give demo user premium access
      analysisCount: 15, // Show some existing analyses
      isEmailVerified: true,
      preferences: {
        'notifications': true,
        'darkMode': false,
        'language': 'en',
      },
      deviceTokens: [],
    );
    return _currentDemoUser!;
  }

  // Get current demo user
  AppUser? get currentDemoUser => _currentDemoUser;

  // Sign out demo user
  void signOutDemo() {
    _currentDemoUser = null;
  }

  // Check if currently signed in as demo user
  bool get isDemoSignedIn => _currentDemoUser != null;
}