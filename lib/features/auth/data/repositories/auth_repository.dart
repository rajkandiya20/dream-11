import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState, User;

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

/// Repository handling Firebase Auth with Supabase user data.
class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final SupabaseClient _supabaseClient;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    required SupabaseClient supabaseClient,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _supabaseClient = supabaseClient;

  User? get currentFirebaseUser => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  bool get isAuthenticated => currentFirebaseUser != null;

  /// Fetch user data from Supabase 'users' table by Firebase UID.
  /// If user doesn't exist, upserts with default role 'user'.
  Future<UserModel> _fetchOrCreateSupabaseUser(User firebaseUser, {String? overrideUsername}) async {
    try {
      // Try to fetch user from Supabase by uid
      final response = await _supabaseClient
          .from('users')
          .select('*')
          .eq('uid', firebaseUser.uid)
          .maybeSingle();

      if (response != null) {
        debugPrint('✅ Found user in Supabase with role: ${response['role']}');
        return UserModel.fromJson(response);
      }

      // User not found in Supabase - create with default role
      debugPrint('ℹ️ User not in Supabase, upserting...');
      final upsertData = {
        'uid': firebaseUser.uid,
        'email': firebaseUser.email ?? '',
        'username': overrideUsername ?? firebaseUser.displayName,
        'avatar_url': firebaseUser.photoURL,
        'role': 'user',
      };

      final inserted = await _supabaseClient
          .from('users')
          .upsert(upsertData, onConflict: 'uid')
          .select()
          .single();

      return UserModel.fromJson(inserted);
    } catch (e) {
      debugPrint('⚠️ Supabase user fetch failed: $e');
      // Fallback to Firebase-only data if Supabase is unavailable
      return UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        username: overrideUsername ?? firebaseUser.displayName,
        avatarUrl: firebaseUser.photoURL,
      );
    }
  }

  Future<AuthResult> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 Attempting login for: $email');
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (credential.user == null) {
        return AuthResult.failure('Login failed. Please try again.');
      }
      debugPrint('✅ Login successful: ${credential.user!.uid}');
      // Fetch role from Supabase
      final userModel = await _fetchOrCreateSupabaseUser(credential.user!);
      return AuthResult.success(userModel);
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      return AuthResult.failure(_mapFirebaseError(e.code));
    } on FirebaseException catch (e) {
      debugPrint('❌ FirebaseException: ${e.code} - ${e.message}');
      return AuthResult.failure(_mapFirebaseError(e.code));
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return AuthResult.failure('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<AuthResult> registerWithEmail({
    required String email,
    required String password,
    String? username,
    String? phoneNumber,
  }) async {
    try {
      debugPrint('📝 Attempting registration for: $email');
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (credential.user == null) {
        return AuthResult.failure('Registration failed. Please try again.');
      }
      if (username != null && username.isNotEmpty) {
        await credential.user!.updateDisplayName(username);
        await credential.user!.reload();
      }
      debugPrint('✅ Registration successful: ${credential.user!.uid}');
      final firebaseUser = _firebaseAuth.currentUser ?? credential.user!;
      // Create user in Supabase with default role
      final userModel = await _fetchOrCreateSupabaseUser(
        firebaseUser,
        overrideUsername: username,
      );
      return AuthResult.success(userModel);
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      return AuthResult.failure(_mapFirebaseError(e.code));
    } on FirebaseException catch (e) {
      debugPrint('❌ FirebaseException: ${e.code} - ${e.message}');
      return AuthResult.failure(_mapFirebaseError(e.code));
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return AuthResult.failure('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<AuthResult> forgotPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return const AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e.code));
    } catch (e) {
      return AuthResult.failure('Failed to send reset email.');
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  /// Fetch user from Supabase for existing session (used during _init in AuthNotifier).
  Future<UserModel?> fetchCurrentUserFromSupabase() async {
    final firebaseUser = currentFirebaseUser;
    if (firebaseUser == null) return null;
    try {
      return await _fetchOrCreateSupabaseUser(firebaseUser);
    } catch (e) {
      debugPrint('⚠️ Could not fetch Supabase user during init: $e');
      return null;
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'Email already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'Account disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try later.';
      case 'network-request-failed':
        return 'Network error. Check connection.';
      case 'weak-password':
        return 'Password too weak (min 6 chars).';
      case 'operation-not-allowed':
        return 'Email/Password sign-in not enabled in Firebase.';
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Invalid email or password.';
      default:
        return 'Authentication failed ($code).';
    }
  }
}

/// Provider for the auth repository with Supabase dependency.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return AuthRepository(supabaseClient: supabaseClient);
});
