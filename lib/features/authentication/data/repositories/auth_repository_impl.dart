import 'package:word_pedometer/core/errors/failures.dart';
import 'package:word_pedometer/core/errors/result.dart';
import 'package:word_pedometer/core/services/auth_service.dart';
import 'package:word_pedometer/features/authentication/domain/entities/user.dart';
import 'package:word_pedometer/features/authentication/domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl({required AuthService authService})
      : _authService = authService;

  @override
  User? get currentUser {
    final authUser = _authService.currentUser;
    if (authUser == null) return null;
    return User(
      id: authUser.id,
      email: authUser.email,
      displayName: authUser.displayName,
      photoUrl: authUser.photoUrl,
    );
  }

  @override
  bool get isAuthenticated => _authService.isAuthenticated;

  @override
  Future<Result<User, Failure>> signInWithGoogle() async {
    try {
      final authUser = await _authService.signIn();
      return Result.success(User(
        id: authUser.id,
        email: authUser.email,
        displayName: authUser.displayName,
        photoUrl: authUser.photoUrl,
      ));
    } catch (e) {
      return Result.failure(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> signOut() async {
    try {
      await _authService.signOut();
      return Result.success(null);
    } catch (e) {
      return Result.failure(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<bool, Failure>> isSignedIn() async {
    try {
      final result = await _authService.isSignedIn();
      return Result.success(result);
    } catch (e) {
      return Result.failure(AuthFailure(message: e.toString()));
    }
  }
}
