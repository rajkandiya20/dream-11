import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({this.status = AuthStatus.initial, this.user, this.errorMessage});

  AuthState copyWith({AuthStatus? status, UserModel? user, String? errorMessage}) {
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

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    _init();
  }

  void _init() {
    final firebaseUser = _repository.currentFirebaseUser;
    if (firebaseUser != null) {
      debugPrint('✅ Existing session: ${firebaseUser.email}');
      // Set initial state with Firebase data, then fetch role from Supabase
      state = AuthState(
        status: AuthStatus.authenticated,
        user: UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          username: firebaseUser.displayName,
          avatarUrl: firebaseUser.photoURL,
        ),
      );
      // Fetch full user data (including role) from Supabase asynchronously
      _fetchSupabaseUser();
    } else {
      debugPrint('ℹ️ No session, unauthenticated');
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> _fetchSupabaseUser() async {
    final supabaseUser = await _repository.fetchCurrentUserFromSupabase();
    if (supabaseUser != null && mounted) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: supabaseUser,
      );
      debugPrint('✅ Updated user from Supabase with role: ${supabaseUser.role}');
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final result = await _repository.loginWithEmail(email: email, password: password);
    if (result.success && result.user != null) {
      state = AuthState(status: AuthStatus.authenticated, user: result.user);
      return true;
    } else {
      state = AuthState(status: AuthStatus.unauthenticated, errorMessage: result.errorMessage);
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    String? username,
    String? phoneNumber,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final result = await _repository.registerWithEmail(
      email: email, password: password, username: username, phoneNumber: phoneNumber,
    );
    if (result.success && result.user != null) {
      state = AuthState(status: AuthStatus.authenticated, user: result.user);
      return true;
    } else {
      state = AuthState(status: AuthStatus.unauthenticated, errorMessage: result.errorMessage);
      return false;
    }
  }

  Future<bool> forgotPassword({required String email}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final result = await _repository.forgotPassword(email: email);
    if (result.success) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return true;
    } else {
      state = AuthState(status: AuthStatus.unauthenticated, errorMessage: result.errorMessage);
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAdmin;
});

final authStateStreamProvider = StreamProvider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});
