import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../../../../core/network/supabase_client.dart';
import '../models/user_model.dart';

/// Auth result wrapping success/error outcomes.
class AuthResult {
  final bool success;
  final UserModel? user;
  final String? errorMessage;

  const AuthResult({
    required this.success,
    this.user,
    this.errorMessage,
  });

  factory AuthResult.success(UserModel user) =>
      AuthResult(success: true, user: user);

  factory AuthResult.failure(String message) =>
      AuthResult(success: false, errorMessage: message);
}

/// Repository handling Firebase Auth and Supabase user upsert.
class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final SupabaseClient? _supabaseClient;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    SupabaseClient? supabaseClient,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _supabaseClient = supabaseClient;

  /// Get the current Firebase user.
  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  /// Get auth state stream.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Check if user is authenticated.
  bool get isAuthenticated => currentFirebaseUser != null;

  /// Login with email and password.
  Future<AuthResult> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        return AuthResult.failure('Login failed. Please try again.');
      }

      // Fetch or create user in Supabase
      final user = await _upsertSupabaseUser(credential.user!);
      return AuthResult.success(user);
    } on FirebaseException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e.code));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred. Please try again.');
    }
  }

  /// Register with email, password, username, and phone.
  Future<AuthResult> registerWithEmail({
    required String email,
    required String password,
    String? username,
    String? phoneNumber,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        return AuthResult.failure('Registration failed. Please try again.');
      }

      // Update display name in Firebase
      if (username != null && username.isNotEmpty) {
        await credential.user!.updateDisplayName(username);
      }

      // Upsert user in Supabase with additional info
      final user = await _upsertSupabaseUser(
        credential.user!,
        username: username,
        phoneNumber: phoneNumber,
      );

      return AuthResult.success(user);
    } on FirebaseException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e.code));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred. Please try again.');
    }
  }

  /// Send password reset email.
  Future<AuthResult> forgotPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return const AuthResult(success: true);
    } on FirebaseException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e.code));
    } catch (e) {
      return AuthResult.failure('Failed to send reset email. Please try again.');
    }
  }

  /// Logout from Firebase.
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  /// Get current user data from Supabase.
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = currentFirebaseUser;
    if (firebaseUser == null) return null;

    if (_supabaseClient == null) return null;

    try {
      final response = await _supabaseClient
          .from('users')
          .select()
          .eq('uid', firebaseUser.uid)
          .maybeSingle();

      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Check if current user is admin.
  Future<bool> isAdmin() async {
    final user = await getCurrentUser();
    return user?.isAdmin ?? false;
  }

  /// Upsert user data in Supabase after Firebase Auth.
  Future<UserModel> _upsertSupabaseUser(
    User firebaseUser, {
    String? username,
    String? phoneNumber,
  }) async {
    final userData = UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      username: username ?? firebaseUser.displayName,
      phoneNumber: phoneNumber ?? firebaseUser.phoneNumber,
      avatarUrl: firebaseUser.photoURL,
    );

    if (_supabaseClient == null) {
      return userData;
    }

    try {
      final response = await _supabaseClient
          .from('users')
          .upsert(
            userData.toJson(),
            onConflict: 'uid',
          )
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      // If upsert fails, return the basic user model
      return userData;
    }
  }

  /// Map Firebase Auth error codes to user-friendly messages.
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'invalid-credential':
        return 'Invalid credentials. Please try again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

/// Provider for the auth repository.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return AuthRepository(supabaseClient: supabaseClient);
});
