import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/injection_container.dart';
import '../datasources/grammar_checker_local_data_source.dart';
import '../models/grammar_mistake_model.dart';
import '../../domain/entities/grammar_mistake.dart';
import '../../domain/repositories/grammar_checker_repository.dart';
import 'package:uuid/uuid.dart';

/// Implementation of GrammarCheckerRepository
class GrammarCheckerRepositoryImpl implements GrammarCheckerRepository {

  GrammarCheckerRepositoryImpl({
    required GrammarCheckerDataSource dataSource,
  }) : _dataSource = dataSource;
  final GrammarCheckerDataSource _dataSource;

  @override
  Future<Result<List<GrammarMistake>, Failure>> checkGrammar(
    String text,
  ) async {
    try {
      if (text.isEmpty) {
        return Result.success(const []);
      }

      final mistakes = await _dataSource.checkGrammar(text);
      return Result.success(mistakes);
    } catch (e) {
      return Result.failure(
        GrammarCheckingFailure(
          message: 'Failed to check grammar: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>, Failure>> getGrammarRules() async {
    try {
      final rules = await _dataSource.getGrammarRules();
      return Result.success(rules);
    } catch (e) {
      return Result.failure(
        GrammarCheckingFailure(
          message: 'Failed to get grammar rules: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<double, Failure>> calculateAccuracy(
    String text,
    List<GrammarMistake> mistakes,
  ) async {
    try {
      if (text.isEmpty) {
        return Result.success(100);
      }

      final wordCount = text.split(' ').length;
      final accuracy =
          ((wordCount - mistakes.length) / wordCount) * 100;

      return Result.success(accuracy.clamp(0.0, 100.0));
    } catch (e) {
      return Result.failure(
        UnexpectedFailure(message: e.toString()),
      );
    }
  }

  @override
  Future<Result<bool, Failure>> saveGrammarErrors(
    String sessionId,
    String transcriptionId,
    String userId,
    List<GrammarMistake> mistakes,
  ) async {
    try {
      final db = getIt<DatabaseService>();
      final database = await db.database;

      for (final mistake in mistakes) {
        await database.insert(
          'grammar_errors',
          {
            'id': const Uuid().v4(),
            'session_id': sessionId,
            'transcription_id': transcriptionId,
            'user_id': userId,
            'error_type': mistake.errorType.toString(),
            'error_category': mistake.errorType.toString().split('.').last,
            'original_text': mistake.text,
            'corrected_text': mistake.suggestion,
            'severity': 'medium', // TODO: Use actual severity from rule
            'position_start': mistake.startPosition,
            'position_end': mistake.endPosition,
            'explanation': mistake.suggestion,
            'created_at': DateTime.now().millisecondsSinceEpoch,
          },
        );
      }

      return Result.success(true);
    } catch (e) {
      return Result.failure(
        DatabaseFailure(
          message: 'Failed to save grammar errors: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<List<GrammarMistake>, Failure>> getErrorsForSession(
    String sessionId,
  ) async {
    try {
      final db = getIt<DatabaseService>();
      final database = await db.database;

      final result = await database.query(
        'grammar_errors',
        where: 'session_id = ?',
        whereArgs: [sessionId],
      );

      final mistakes = result
          .map(
            (row) => GrammarMistake(
              id: row['id']! as String,
              text: row['original_text']! as String,
              suggestion: row['corrected_text']! as String,
              errorType: _parseErrorType(row['error_type']! as String),
              startPosition: (row['position_start'] as int?) ?? 0,
              endPosition: (row['position_end'] as int?) ?? 0,
              confidence: 0.85, // Default confidence for retrieved errors
            ),
          )
          .toList();

      return Result.success(mistakes);
    } catch (e) {
      return Result.failure(
        DatabaseFailure(
          message: 'Failed to retrieve grammar errors: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<Map<String, List<GrammarMistake>>, Failure>>
      getErrorsByTypeForUser(String userId) async {
    try {
      final db = getIt<DatabaseService>();
      final database = await db.database;

      final result = await database.query(
        'grammar_errors',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      final grouped = <String, List<GrammarMistake>>{};

      for (final row in result) {
        final errorType = row['error_category']! as String;
        final mistake = GrammarMistake(
          id: row['id']! as String,
          text: row['original_text']! as String,
          suggestion: row['corrected_text']! as String,
          errorType: _parseErrorType(row['error_type']! as String),
          startPosition: (row['position_start'] as int?) ?? 0,
          endPosition: (row['position_end'] as int?) ?? 0,
          confidence: 0.85,
        );

        grouped.putIfAbsent(errorType, () => []).add(mistake);
      }

      return Result.success(grouped);
    } catch (e) {
      return Result.failure(
        DatabaseFailure(
          message: 'Failed to get errors by type: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>, Failure>> getErrorStatsForDate(
    String userId,
    String date,
  ) async {
    try {
      final db = getIt<DatabaseService>();
      final database = await db.database;

      final result = await database.query(
        'daily_stats',
        where: 'user_id = ? AND stat_date = ?',
        whereArgs: [userId, date],
      );

      if (result.isEmpty) {
        return Result.success({});
      }

      final row = result.first;
      return Result.success({
        'total_sessions': row['total_sessions'],
        'total_words': row['total_words'],
        'total_errors': row['total_errors'],
        'daily_accuracy': row['daily_accuracy'],
        'most_common_error': row['most_common_error'],
      });
    } catch (e) {
      return Result.failure(
        DatabaseFailure(
          message: 'Failed to get error stats: ${e.toString()}',
        ),
      );
    }
  }

  /// Parse error type from string representation
  GrammarErrorType _parseErrorType(String errorTypeStr) => GrammarErrorType.values.firstWhere(
      (e) => e.toString().contains(errorTypeStr),
      orElse: () => GrammarErrorType.other,
    );
}

