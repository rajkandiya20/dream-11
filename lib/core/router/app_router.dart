import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/matches/presentation/screens/match_detail_screen.dart';
import '../../features/matches/presentation/screens/matches_screen.dart';
import '../../features/contests/presentation/screens/contest_detail_screen.dart';
import '../../features/contests/presentation/screens/contest_list_screen.dart';
import '../../features/contests/presentation/screens/contests_screen.dart';
import '../../features/fantasy/presentation/screens/captain_selection_screen.dart';
import '../../features/fantasy/presentation/screens/create_team_screen.dart';
import '../../features/fantasy/presentation/screens/fantasy_team_screen.dart';
import '../../features/fantasy/presentation/screens/team_preview_screen.dart';
import '../../features/matches/data/models/player_model.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../features/wallet/presentation/screens/transaction_history_screen.dart';
import '../../features/groups/presentation/screens/groups_screen.dart';
import '../../features/groups/presentation/screens/group_detail_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_users_screen.dart';
import '../../features/admin/presentation/screens/admin_tournaments_screen.dart';
import '../../features/admin/presentation/screens/admin_teams_screen.dart';
import '../../features/admin/presentation/screens/admin_scoreboard_screen.dart';
import '../../features/admin/presentation/screens/admin_wallet_screen.dart';
import '../../features/admin/presentation/screens/admin_reports_screen.dart';
import '../../features/admin/presentation/screens/admin_settings_screen.dart';
import '../../features/admin/presentation/screens/admin_payment_methods_screen.dart';
import '../../features/admin/presentation/screens/admin_matches_screen.dart';
import '../../features/admin/presentation/screens/admin_contests_screen.dart';
import '../../features/admin/presentation/screens/admin_players_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

/// Route name constants for type-safe navigation.
class AppRoutes {
  AppRoutes._();

  // Auth
  static const String splash          = '/splash';
  static const String login           = '/login';
  static const String register        = '/register';
  static const String forgotPassword  = '/forgot-password';

  // Main tabs
  static const String home     = '/';
  static const String matches  = '/matches';
  static const String contests = '/contests';
  static const String wallet   = '/wallet';
  static const String profile  = '/profile';

  // Match & Contest
  static const String matchDetail   = '/matches/:matchId';
  static const String contestDetail = '/contests/:contestId';

  // Contest list for a specific match (routable)
  static const String contestList = '/contest-list/:matchId';

  // Fantasy Team
  static const String createTeam       = '/create-team/:matchId';
  static const String captainSelection = '/captain-selection/:matchId';
  static const String fantasyTeam      = '/fantasy-team/:teamId';
  // team-preview receives data via GoRouter `extra` (no path params needed)
  static const String teamPreview      = '/team-preview';

  // Wallet
  static const String transactionHistory = '/wallet/transactions';

  // Groups
  static const String groups      = '/groups';
  static const String groupDetail = '/groups/:groupId';

  // Profile
  static const String editProfile = '/profile/edit';

  // Notifications
  static const String notifications = '/notifications';

  // Admin
  static const String adminDashboard      = '/admin';
  static const String adminMatches        = '/admin/matches';
  static const String adminContests       = '/admin/contests';
  static const String adminPlayers        = '/admin/players';
  static const String adminUsers          = '/admin/users';
  static const String adminTournaments    = '/admin/tournaments';
  static const String adminTeams          = '/admin/teams';
  static const String adminScoreboard     = '/admin/scoreboard';
  static const String adminWallet         = '/admin/wallet';
  static const String adminReports        = '/admin/reports';
  static const String adminSettings       = '/admin/settings';
  static const String adminPaymentMethods = '/admin/payment-methods';
}

/// Routes that don't require authentication.
const _publicRoutes = [
  AppRoutes.splash,
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.forgotPassword,
];

/// Notifier that triggers GoRouter refresh when auth state changes.
class AuthChangeNotifier extends ChangeNotifier {
  AuthChangeNotifier(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}

/// GoRouter provider — created once, refreshes on auth changes.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authChangeNotifier = AuthChangeNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    refreshListenable: authChangeNotifier,
    redirect: (context, state) {
      final authState  = ref.read(authProvider);
      final status     = authState.status;
      final isAuth     = authState.isAuthenticated;
      final path       = state.uri.path;
      final isPublic   = _publicRoutes.contains(path);
      final isSplash   = path == AppRoutes.splash;

      if (status == AuthStatus.loading || status == AuthStatus.initial) {
        return null;
      }
      if (isSplash) return null;
      if (!isAuth && !isPublic) return AppRoutes.login;
      if (isAuth  &&  isPublic) return AppRoutes.home;
      return null;
    },
    routes: [
      // ── Splash ───────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),

      // ── Auth ─────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),

      // ── Main shell with bottom nav ────────────────────────────────────
      ShellRoute(
        builder: (_, __, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.matches,
            name: 'matches',
            builder: (_, __) => const MatchesScreen(),
          ),
          GoRoute(
            path: AppRoutes.contests,
            name: 'contests',
            builder: (_, __) => const ContestsScreen(),
          ),
          GoRoute(
            path: AppRoutes.wallet,
            name: 'wallet',
            builder: (_, __) => const WalletScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),

      // ── Match detail ─────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.matchDetail,
        name: 'matchDetail',
        builder: (_, state) => MatchDetailScreen(
          matchId: state.pathParameters['matchId']!,
        ),
      ),

      // ── Contest detail ───────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.contestDetail,
        name: 'contestDetail',
        builder: (_, state) => ContestDetailScreen(
          contestId: state.pathParameters['contestId']!,
        ),
      ),

      // ── Contest list for a match ─────────────────────────────────────
      GoRoute(
        path: AppRoutes.contestList,
        name: 'contestList',
        builder: (_, state) => ContestListScreen(
          matchId: state.pathParameters['matchId']!,
        ),
      ),

      // ── Create team
      //    extra (String?) = contestId — passed through to captain selection
      GoRoute(
        path: AppRoutes.createTeam,
        name: 'createTeam',
        builder: (_, state) => CreateTeamScreen(
          matchId:   state.pathParameters['matchId']!,
          contestId: state.extra as String?,
        ),
      ),

      // ── Captain selection
      //    extra (String?) = contestId
      GoRoute(
        path: AppRoutes.captainSelection,
        name: 'captainSelection',
        builder: (_, state) => CaptainSelectionScreen(
          matchId:   state.pathParameters['matchId']!,
          contestId: state.extra as String?,
        ),
      ),

      // ── Fantasy team detail ──────────────────────────────────────────
      GoRoute(
        path: AppRoutes.fantasyTeam,
        name: 'fantasyTeam',
        builder: (_, state) => FantasyTeamScreen(
          teamId: state.pathParameters['teamId']!,
        ),
      ),

      // ── Team preview (cricket-ground view)
      //    extra = _TeamPreviewArgs (passed as GoRouter extra)
      GoRoute(
        path: AppRoutes.teamPreview,
        name: 'teamPreview',
        builder: (_, state) {
          final args = state.extra as _TeamPreviewArgs?;
          return TeamPreviewScreen(
            players:      args?.players      ?? const [],
            captainId:    args?.captainId,
            viceCaptainId: args?.viceCaptainId,
            playerPoints: args?.playerPoints,
          );
        },
      ),

      // ── Wallet transaction history ───────────────────────────────────
      GoRoute(
        path: AppRoutes.transactionHistory,
        name: 'transactionHistory',
        builder: (_, __) => const TransactionHistoryScreen(),
      ),

      // ── Groups ───────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.groups,
        name: 'groups',
        builder: (_, __) => const GroupsScreen(),
      ),
      GoRoute(
        path: AppRoutes.groupDetail,
        name: 'groupDetail',
        builder: (_, state) => GroupDetailScreen(
          groupId: state.pathParameters['groupId']!,
        ),
      ),

      // ── Profile ──────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.editProfile,
        name: 'editProfile',
        builder: (_, __) => const EditProfileScreen(),
      ),

      // ── Notifications ────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),

      // ── Admin ─────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.adminDashboard,
        name: 'adminDashboard',
        builder: (_, __) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminMatches,
        name: 'adminMatches',
        builder: (_, __) => const AdminMatchesScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminContests,
        name: 'adminContests',
        builder: (_, __) => const AdminContestsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminPlayers,
        name: 'adminPlayers',
        builder: (_, __) => const AdminPlayersScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminUsers,
        name: 'adminUsers',
        builder: (_, __) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminTournaments,
        name: 'adminTournaments',
        builder: (_, __) => const AdminTournamentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminTeams,
        name: 'adminTeams',
        builder: (_, __) => const AdminTeamsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminScoreboard,
        name: 'adminScoreboard',
        builder: (_, __) => const AdminScoreboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminWallet,
        name: 'adminWallet',
        builder: (_, __) => const AdminWalletScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminReports,
        name: 'adminReports',
        builder: (_, __) => const AdminReportsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminSettings,
        name: 'adminSettings',
        builder: (_, __) => const AdminSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminPaymentMethods,
        name: 'adminPaymentMethods',
        builder: (_, __) => const AdminPaymentMethodsScreen(),
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(state.uri.toString(),
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    ),
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Args class for /team-preview (passed via GoRouter extra)
// ─────────────────────────────────────────────────────────────────────────────

class _TeamPreviewArgs {
  final List<PlayerModel> players;
  final String? captainId;
  final String? viceCaptainId;
  final Map<String, double>? playerPoints;

  const _TeamPreviewArgs({
    required this.players,
    this.captainId,
    this.viceCaptainId,
    this.playerPoints,
  });
}

/// Public helper to navigate to the team preview screen.
/// Usage: navigateToTeamPreview(context, players: [...], captainId: 'x');
void navigateToTeamPreview(
  BuildContext context, {
  required List<PlayerModel> players,
  String? captainId,
  String? viceCaptainId,
  Map<String, double>? playerPoints,
}) {
  context.push(
    AppRoutes.teamPreview,
    extra: _TeamPreviewArgs(
      players:       players,
      captainId:     captainId,
      viceCaptainId: viceCaptainId,
      playerPoints:  playerPoints,
    ),
  );
}
