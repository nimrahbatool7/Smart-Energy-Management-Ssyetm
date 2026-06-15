// File: lib/core/config/app_config.dart

class AppConfig {
  /// Toggle to bypass onboarding authentication in development/testing mode.
  static const bool skipAuthentication = true;

  // Temporary mock user information for development/testing
  static const String mockUserName = 'Viora User';
  static const String mockUserEmail = 'test@viora.com';
  static const String mockUserUid = 'mock-viora-user';
}
