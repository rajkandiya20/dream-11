/// Environment variable handling for runtime configuration.
///
/// These values should be provided at build time via --dart-define
/// or loaded from a .env file at runtime.
class Env {
  Env._();

  /// Supabase project URL
  static String get supabaseUrl =>
      const String.fromEnvironment('SUPABASE_URL', defaultValue: '');

  /// Supabase anonymous key for client-side operations
  static String get supabaseAnonKey =>
      const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  /// Firebase API key
  static String get firebaseApiKey =>
      const String.fromEnvironment('FIREBASE_API_KEY', defaultValue: '');

  /// Firebase Auth domain
  static String get firebaseAuthDomain =>
      const String.fromEnvironment('FIREBASE_AUTH_DOMAIN', defaultValue: '');

  /// Firebase project ID
  static String get firebaseProjectId =>
      const String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: '');

  /// Whether the app is in production mode
  static bool get isProduction =>
      const String.fromEnvironment('ENV', defaultValue: 'dev') == 'production';

  /// Whether the app is in development mode
  static bool get isDevelopment => !isProduction;

  /// Validates that all required environment variables are set
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      firebaseApiKey.isNotEmpty;
}
