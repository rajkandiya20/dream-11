/// Application-wide constants.
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Local 11';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Fantasy Team Rules
  static const int maxPlayersPerTeam = 11;
  static const int minBatsmen = 3;
  static const int maxBatsmen = 6;
  static const int minBowlers = 3;
  static const int maxBowlers = 6;
  static const int minAllRounders = 1;
  static const int maxAllRounders = 4;
  static const int minWicketKeepers = 1;
  static const int maxWicketKeepers = 4;
  static const double maxCredits = 100.0;
  static const int maxPlayersFromOneTeam = 7;

  // Captain/Vice-Captain Multipliers
  static const double captainMultiplier = 2.0;
  static const double viceCaptainMultiplier = 1.5;

  // Pagination
  static const int defaultPageSize = 20;
  static const int feedPageSize = 10;
  static const int notificationsPageSize = 20;

  // Cache Duration
  static const Duration cacheDuration = Duration(minutes: 5);
  static const Duration matchCacheDuration = Duration(seconds: 30);
  static const Duration tournamentCacheDuration = Duration(minutes: 15);

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Splash Screen
  static const Duration splashDuration = Duration(seconds: 2);

  // Match Status
  static const String matchStatusUpcoming = 'upcoming';
  static const String matchStatusLive = 'live';
  static const String matchStatusCompleted = 'completed';

  // Contest Types
  static const String contestTypePaid = 'paid';
  static const String contestTypeFree = 'free';

  // Transaction Types
  static const String transactionDeposit = 'deposit';
  static const String transactionWithdrawal = 'withdrawal';
  static const String transactionContestJoin = 'contest_join';
  static const String transactionWinning = 'winning';

  // Player Roles
  static const String roleBatsman = 'Batsman';
  static const String roleBowler = 'Bowler';
  static const String roleAllRounder = 'All-rounder';
  static const String roleWicketKeeper = 'WK';

  // User Roles
  static const String roleUser = 'user';
  static const String roleAdmin = 'admin';

  // Hive Box Names
  static const String userBox = 'user_box';
  static const String settingsBox = 'settings_box';
  static const String cacheBox = 'cache_box';
  static const String matchesBox = 'matches_box';
  static const String tournamentsBox = 'tournaments_box';

  // Notification Sound
  static const String notificationSoundPath = 'assets/sounds/notification.mp3';
}
