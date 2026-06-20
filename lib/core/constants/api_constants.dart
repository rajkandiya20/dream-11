/// API and service configuration constants.
class ApiConstants {
  ApiConstants._();

  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // Firebase Configuration
  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: '',
  );
  static const String firebaseAuthDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
    defaultValue: '',
  );
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: '',
  );

  // Supabase Table Names
  static const String usersTable = 'users';
  static const String adminsTable = 'admins';
  static const String tournamentsTable = 'tournaments';
  static const String teamsTable = 'teams';
  static const String playersTable = 'players';
  static const String matchesTable = 'matches';
  static const String matchPlayersTable = 'match_players';
  static const String contestsTable = 'contests';
  static const String fantasyTeamsTable = 'fantasy_teams';
  static const String fantasyTeamPlayersTable = 'fantasy_team_players';
  static const String feedPostsTable = 'feed_posts';
  static const String groupsTable = 'groups';
  static const String groupMembersTable = 'group_members';
  static const String walletsTable = 'wallets';
  static const String transactionsTable = 'transactions';
  static const String notificationsTable = 'notifications';
  static const String leaderboardTable = 'leaderboard';
  static const String scoreboardTable = 'scoreboard';
  static const String commentaryTable = 'commentary';
  static const String paymentMethodsTable = 'payment_methods';

  // Realtime Channels
  static const String matchesChannel = 'matches';
  static const String tournamentsChannel = 'tournaments';
  static const String contestsChannel = 'contests';
  static const String playersChannel = 'players';
  static const String scoreboardChannel = 'scoreboard';
  static const String notificationsChannel = 'notifications';
  static const String teamsChannel = 'teams';
  static const String commentaryChannel = 'commentary';

  // API Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
