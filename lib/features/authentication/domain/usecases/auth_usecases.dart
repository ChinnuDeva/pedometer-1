import 'package:word_pedometer/core/errors/failures.dart';
import 'package:word_pedometer/core/errors/result.dart';
import 'package:word_pedometer/core/usecases/usecase.dart';
import 'package:word_pedometer/features/authentication/domain/entities/user.dart';
import 'package:word_pedometer/features/authentication/domain/repositories/auth_repository.dart';

/// Sign in with Google use case
class SignInWithGoogleUseCase extends UseCase<User, NoParams> {
  final AuthRepository _repository;

  SignInWithGoogleUseCase({required AuthRepository repository})
      : _repository = repository;

  @override
  Future<Result<User, Failure>> call(NoParams params) =>
      _repository.signInWithGoogle();
}

/// Sign out use case
class SignOutUseCase extends UseCase<void, NoParams> {
  final AuthRepository _repository;

  SignOutUseCase({required AuthRepository repository})
      : _repository = repository;

  @override
  Future<Result<void, Failure>> call(NoParams params) =>
      _repository.signOut();
}

/// Check if signed in use case
class IsSignedInUseCase extends UseCase<bool, NoParams> {
  final AuthRepository _repository;

  IsSignedInUseCase({required AuthRepository repository})
      : _repository = repository;

  @override
  Future<Result<bool, Failure>> call(NoParams params) =>
      _repository.isSignedIn();
}

/// Get current user use case
class GetCurrentUserUseCase extends UseCase<User?, NoParams> {
  final AuthRepository _repository;

  GetCurrentUserUseCase({required AuthRepository repository})
      : _repository = repository;

  @override
  Future<Result<User?, Failure>> call(NoParams params) async {
    final user = _repository.currentUser;
    return Result.success(user);
  }
}
