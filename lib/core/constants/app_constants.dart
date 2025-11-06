class AppConstants {
  static const String appName = 'Iris Analysis';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI-powered iris analysis for health insights';
  
  // API Constants
  static const String baseUrl = 'https://api.irisanalysis.com';
  static const int timeoutDuration = 30000; // 30 seconds
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  
  // Feature Flags
  static const bool enableBiometrics = true;
  static const bool enableCloudSync = true;
  static const bool enableAnalytics = false; // GDPR compliance
  
  // Subscription Plans
  static const String basicPlanId = 'iris_basic_monthly';
  static const String premiumPlanId = 'iris_premium_monthly';
  static const String proPlanId = 'iris_pro_yearly';
}