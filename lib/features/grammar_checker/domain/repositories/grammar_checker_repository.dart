import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../entities/grammar_mistake.dart';

/// Repository interface for grammar checking operations
abstract class GrammarCheckerRepository {
  /// Check text for grammar mistakes
  Future<Result<List<GrammarMistake>, Failure>> checkGrammar(String text);

  /// Get available grammar rules
  Future<Result<Map<String, dynamic>, Failure>> getGrammarRules();

  /// Calculate accuracy based on mistakes found
  Future<Result<double, Failure>> calculateAccuracy(
    String text,
    List<GrammarMistake> mistakes,
  );

  /// Save grammar errors to database for a session
  Future<Result<bool, Failure>> saveGrammarErrors(
    String sessionId,
    String transcriptionId,
    String userId,
    List<GrammarMistake> mistakes,
  );

  /// Get grammar errors for a specific session
  Future<Result<List<GrammarMistake>, Failure>> getErrorsForSession(
    String sessionId,
  );

  /// Get grammar errors by type for a user
  Future<Result<Map<String, List<GrammarMistake>>, Failure>>
      getErrorsByTypeForUser(String userId);

  /// Get error statistics for a user on a specific date
  Future<Result<Map<String, dynamic>, Failure>> getErrorStatsForDate(
    String userId,
    String date,
  );
}

