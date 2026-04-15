import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/grammar_mistake.dart';
import '../repositories/grammar_checker_repository.dart';

/// Parameters for check grammar use case
class CheckGrammarParams {

  CheckGrammarParams({required this.text});
  final String text;
}

/// Check grammar use case
class CheckGrammarUseCase extends UseCase<List<GrammarMistake>, CheckGrammarParams> {

  CheckGrammarUseCase({
    required GrammarCheckerRepository repository,
  }) : _repository = repository;
  final GrammarCheckerRepository _repository;

  @override
  Future<Result<List<GrammarMistake>, Failure>> call(
    CheckGrammarParams params,
  ) =>
      _repository.checkGrammar(params.text);
}

/// Get grammar rules use case
class GetGrammarRulesUseCase extends UseCase<Map<String, dynamic>, NoParams> {

  GetGrammarRulesUseCase({
    required GrammarCheckerRepository repository,
  }) : _repository = repository;
  final GrammarCheckerRepository _repository;

  @override
  Future<Result<Map<String, dynamic>, Failure>> call(NoParams params) =>
      _repository.getGrammarRules();
}

/// Parameters for calculate accuracy use case
class CalculateAccuracyParams {

  CalculateAccuracyParams({
    required this.text,
    required this.mistakes,
  });
  final String text;
  final List<GrammarMistake> mistakes;
}

/// Calculate accuracy use case
class CalculateAccuracyUseCase
    extends UseCase<double, CalculateAccuracyParams> {

  CalculateAccuracyUseCase({
    required GrammarCheckerRepository repository,
  }) : _repository = repository;
  final GrammarCheckerRepository _repository;

  @override
  Future<Result<double, Failure>> call(CalculateAccuracyParams params) =>
      _repository.calculateAccuracy(params.text, params.mistakes);
}

/// Parameters for save grammar errors use case
class SaveGrammarErrorsParams {

  SaveGrammarErrorsParams({
    required this.sessionId,
    required this.transcriptionId,
    required this.userId,
    required this.mistakes,
  });
  final String sessionId;
  final String transcriptionId;
  final String userId;
  final List<GrammarMistake> mistakes;
}

/// Save grammar errors use case
class SaveGrammarErrorsUseCase
    extends UseCase<bool, SaveGrammarErrorsParams> {

  SaveGrammarErrorsUseCase({
    required GrammarCheckerRepository repository,
  }) : _repository = repository;
  final GrammarCheckerRepository _repository;

  @override
  Future<Result<bool, Failure>> call(SaveGrammarErrorsParams params) =>
      _repository.saveGrammarErrors(
        params.sessionId,
        params.transcriptionId,
        params.userId,
        params.mistakes,
      );
}

/// Parameters for get errors for session use case
class GetSessionErrorsParams {

  GetSessionErrorsParams({required this.sessionId});
  final String sessionId;
}

/// Get errors for session use case
class GetSessionErrorsUseCase
    extends UseCase<List<GrammarMistake>, GetSessionErrorsParams> {

  GetSessionErrorsUseCase({
    required GrammarCheckerRepository repository,
  }) : _repository = repository;
  final GrammarCheckerRepository _repository;

  @override
  Future<Result<List<GrammarMistake>, Failure>> call(
    GetSessionErrorsParams params,
  ) =>
      _repository.getErrorsForSession(params.sessionId);
}

/// Parameters for get user error statistics use case
class GetUserErrorStatsParams {

  GetUserErrorStatsParams({
    required this.userId,
    required this.date,
  });
  final String userId;
  final String date;
}

/// Get user error statistics use case
class GetUserErrorStatsUseCase
    extends UseCase<Map<String, dynamic>, GetUserErrorStatsParams> {

  GetUserErrorStatsUseCase({
    required GrammarCheckerRepository repository,
  }) : _repository = repository;
  final GrammarCheckerRepository _repository;

  @override
  Future<Result<Map<String, dynamic>, Failure>> call(
    GetUserErrorStatsParams params,
  ) =>
      _repository.getErrorStatsForDate(params.userId, params.date);
}

/// Parameters for get errors by type use case
class GetErrorsByTypeParams {

  GetErrorsByTypeParams({required this.userId});
  final String userId;
}

/// Get errors by type use case
class GetErrorsByTypeUseCase
    extends UseCase<Map<String, List<GrammarMistake>>,
        GetErrorsByTypeParams> {

  GetErrorsByTypeUseCase({
    required GrammarCheckerRepository repository,
  }) : _repository = repository;
  final GrammarCheckerRepository _repository;

  @override
  Future<Result<Map<String, List<GrammarMistake>>, Failure>> call(
    GetErrorsByTypeParams params,
  ) =>
      _repository.getErrorsByTypeForUser(params.userId);
}

