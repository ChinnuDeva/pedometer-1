import 'package:word_pedometer/core/errors/failures.dart';
import 'package:word_pedometer/core/errors/result.dart';
import 'package:word_pedometer/features/authentication/domain/entities/user.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Get the currently authenticated user (null if not signed in)
  User? get currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated;

  /// Sign in with Google
  Future<Result<User, Failure>> signInWithGoogle();

  /// Sign out
  Future<Result<void, Failure>> signOut();

  /// Check if user is signed in
  Future<Result<bool, Failure>> isSignedIn();
}
