import 'package:flutter/foundation.dart';
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
import '../../features/contests/presentation/screens/contests_screen.dart';
import '../../features/fantasy/presentation/screens/captain_selection_screen.dart';
import '../../features/fantasy/presentation/screens/create_team_screen.dart';
import '../../features/fantasy/presentation/screens/fantasy_team_screen.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../features/wallet/presentation/screens/transaction_history_screen.dart';
import '../../features/groups/presentation/screens/groups_screen.dart';
import '../../features/groups/presentation/screens/group_detail_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/match_manager_screen.dart';
import '../../features/admin/presentation/screens/contest_manager_screen.dart';
import '../../features/admin/presentation/screens/player_manager_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

/// Route names for type-safe navigation.
class AppRoutes {
  AppRoutes._();

  // Auth
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main tabs
  static const String home = '/';
  static const String matches = '/matches';
  static const String contests = '/contests';
  static const String wallet = '/wallet';
  static const String profile = '/profile';

  // Match & Contest Details
  static const String matchDetail = '/matches/:matchId';
  static const String contestDetail = '/contests/:contestId';

  // Fantasy Team
  static const String createTeam = '/create-team/:matchId';
  static const String captainSelection = '/captain-selection';
  static const String fantasyTeam = '/fantasy-team/:teamId';

  // Wallet
  static const String transactionHistory = '/wallet/transactions';

  // Groups
  static const String groups = '/groups';
  static const String groupDetail = '/groups/:groupId';

  // Profile
  static const String editProfile = '/profile/edit';

  // Notifications
  static const String notifications = '/notifications';

  // Admin
  static const String adminDashboard = '/admin';
  static const String adminMatches = '/admin/matches';
  static const String adminContests = '/admin/contests';
  static const String adminPlayers = '/admin/players';
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
    ref.listen(authProvider, (_, __) {
      notifyListeners();
    });
  }
}

/// GoRouter provider — router is created ONCE, refreshes on auth changes.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authChangeNotifier = AuthChangeNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    refreshListenable: authChangeNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final status = authState.status;
      final isAuthenticated = authState.isAuthenticated;
      final currentPath = state.uri.path;
      final isPublicRoute = _publicRoutes.contains(currentPath);
      final isSplash = currentPath == AppRoutes.splash;

      // Don't redirect while auth state is loading or initial
      if (status == AuthStatus.loading || status == AuthStatus.initial) {
        return null;
      }

      // Don't redirect on splash (it handles its own navigation)
      if (isSplash) return null;

      // If not authenticated and trying to access protected route, redirect to login
      if (!isAuthenticated && !isPublicRoute) {
        return AppRoutes.login;
      }

      // If authenticated and trying to access auth routes, redirect to home
      if (isAuthenticated && isPublicRoute) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main Shell with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          // Home Tab
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),

          // Matches Tab
          GoRoute(
            path: AppRoutes.matches,
            name: 'matches',
            builder: (context, state) => const MatchesScreen(),
          ),

          // Contests Tab
          GoRoute(
            path: AppRoutes.contests,
            name: 'contests',
            builder: (context, state) => const ContestsScreen(),
          ),

          // Wallet Tab
          GoRoute(
            path: AppRoutes.wallet,
            name: 'wallet',
            builder: (context, state) => const WalletScreen(),
          ),

          // Profile Tab
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Match Detail
      GoRoute(
        path: AppRoutes.matchDetail,
        name: 'matchDetail',
        builder: (context, state) => MatchDetailScreen(
          matchId: state.pathParameters['matchId']!,
        ),
      ),

      // Contest Detail
      GoRoute(
        path: AppRoutes.contestDetail,
        name: 'contestDetail',
        builder: (context, state) => ContestDetailScreen(
          contestId: state.pathParameters['contestId']!,
        ),
      ),

      // Fantasy Team Routes
      GoRoute(
        path: AppRoutes.createTeam,
        name: 'createTeam',
        builder: (context, state) => CreateTeamScreen(
          matchId: state.pathParameters['matchId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.captainSelection,
        name: 'captainSelection',
        builder: (context, state) => const CaptainSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.fantasyTeam,
        name: 'fantasyTeam',
        builder: (context, state) => FantasyTeamScreen(
          teamId: state.pathParameters['teamId']!,
        ),
      ),

      // Wallet Transaction History
      GoRoute(
        path: AppRoutes.transactionHistory,
        name: 'transactionHistory',
        builder: (context, state) => const TransactionHistoryScreen(),
      ),

      // Groups
      GoRoute(
        path: AppRoutes.groups,
        name: 'groups',
        builder: (context, state) => const GroupsScreen(),
      ),
      GoRoute(
        path: AppRoutes.groupDetail,
        name: 'groupDetail',
        builder: (context, state) => GroupDetailScreen(
          groupId: state.pathParameters['groupId']!,
        ),
      ),

      // Profile
      GoRoute(
        path: AppRoutes.editProfile,
        name: 'editProfile',
        builder: (context, state) => const EditProfileScreen(),
      ),

      // Notifications
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),

      // Admin Routes
      GoRoute(
        path: AppRoutes.adminDashboard,
        name: 'adminDashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminMatches,
        name: 'adminMatches',
        builder: (context, state) => const MatchManagerScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminContests,
        name: 'adminContests',
        builder: (context, state) => const ContestManagerScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminPlayers,
        name: 'adminPlayers',
        builder: (context, state) => const PlayerManagerScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    ),
  );
});
