/// Environment configuration with hardcoded credentials.
class Env {
  Env._();

  /// Supabase project URL
  static const String supabaseUrl = 'https://rpgchcgjcfpfjppqtsdk.supabase.co';

  /// Supabase anonymous key
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJwZ2NoY2dqY2ZwZmpwcHF0c2RrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE5MTY3NDYsImV4cCI6MjA5NzQ5Mjc0Nn0.2Y11nIB1yFArSCFchgi298UXtVbulXfr1iaGg7jinVc';

  /// Firebase API key
  static const String firebaseApiKey = 'AIzaSyBlQ7Xg4MZPFWKONrPJE_piXg2B6VHiWHk';

  /// Firebase project ID
  static const String firebaseProjectId = 'dream11local';

  /// Whether the app is in production mode
  static bool get isProduction =>
      const String.fromEnvironment('ENV', defaultValue: 'dev') == 'production';

  /// Whether the app is in development mode
  static bool get isDevelopment => !isProduction;

  /// Always configured since credentials are hardcoded
  static bool get isConfigured => true;
}
