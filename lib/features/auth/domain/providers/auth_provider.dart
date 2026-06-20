import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

/// Auth state enum.
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Auth state class.
class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get isAdmin => user?.isAdmin ?? false;
}

/// Auth state notifier managing login, registration, and auth state.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    _init();
  }

  /// Initialize auth state by checking current session.
  Future<void> _init() async {
    state = state.copyWith(status: AuthStatus.loading);

    final firebaseUser = _repository.currentFirebaseUser;
    if (firebaseUser != null) {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Login with email and password.
  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _repository.loginWithEmail(
      email: email,
      password: password,
    );

    if (result.success && result.user != null) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: result.user,
      );
      return true;
    } else {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: result.errorMessage,
      );
      return false;
    }
  }

  /// Register with email, password, username, and phone.
  Future<bool> register({
    required String email,
    required String password,
    String? username,
    String? phoneNumber,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _repository.registerWithEmail(
      email: email,
      password: password,
      username: username,
      phoneNumber: phoneNumber,
    );

    if (result.success && result.user != null) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: result.user,
      );
      return true;
    } else {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: result.errorMessage,
      );
      return false;
    }
  }

  /// Sign in with Google.
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _repository.signInWithGoogle();

    if (result.success && result.user != null) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: result.user,
      );
      return true;
    } else {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: result.errorMessage,
      );
      return false;
    }
  }

  /// Sign in with GitHub.
  Future<bool> signInWithGitHub() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _repository.signInWithGitHub();

    if (result.success && result.user != null) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: result.user,
      );
      return true;
    } else {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: result.errorMessage,
      );
      return false;
    }
  }

  /// Send forgot password email.
  Future<bool> forgotPassword({required String email}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _repository.forgotPassword(email: email);

    if (result.success) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return true;
    } else {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: result.errorMessage,
      );
      return false;
    }
  }

  /// Logout.
  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Refresh current user data from Supabase.
  Future<void> refreshUser() async {
    final user = await _repository.getCurrentUser();
    if (user != null) {
      state = state.copyWith(user: user);
    }
  }

  /// Clear error state.
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider for auth state notifier.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

/// Provider for current user model.
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

/// Provider for whether user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Provider for whether user is an admin.
final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAdmin;
});

/// Provider for Firebase auth state stream.
final authStateStreamProvider = StreamProvider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});
