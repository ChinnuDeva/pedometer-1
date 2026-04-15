import 'package:word_pedometer/core/errors/failures.dart';
import 'package:word_pedometer/core/errors/result.dart';

/// Base use case abstraction
abstract class UseCase<Type, Params> {
  Future<Result<Type, Failure>> call(Params params);
}

/// Use case parameters when no parameters are needed
class NoParams {
  const NoParams();
}
