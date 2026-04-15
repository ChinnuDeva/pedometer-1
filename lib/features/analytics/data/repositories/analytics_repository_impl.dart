import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:word_pedometer/core/errors/failures.dart';
import 'package:word_pedometer/core/errors/result.dart';
import 'package:word_pedometer/core/services/database_service.dart';
import 'package:word_pedometer/core/utils/injection_container.dart';
import 'package:word_pedometer/features/analytics/domain/entities/analytics_entities.dart';
import 'package:word_pedometer/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:word_pedometer/features/grammar_checker/domain/entities/grammar_mistake.dart';

/// Implementation of AnalyticsRepository
class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final Logger _logger = Logger();
  final DatabaseService? _databaseService;

  AnalyticsRepositoryImpl({DatabaseService? databaseService}) 
      : _databaseService = databaseService;

  DatabaseService get _db => _databaseService ?? getIt<DatabaseService>();

  @override
  Future<Result<DailyReport, Failure>> getDailyReport(
    String userId,
    String date,
  ) async {
    try {
      final db = _db;
      final database = await db.database;

      // Get daily stats from daily_stats table
      final statsResult = await database.query(
        'daily_stats',
        where: 'user_id = ? AND stat_date = ?',
        whereArgs: [userId, date],
      );

      if (statsResult.isEmpty) {
        return Result.success(
          DailyReport(
            date: date,
            totalSessions: 0,
            totalMinutes: 0,
            totalWords: 0,
            totalErrors: 0,
            accuracy: 100.0,
            errorBreakdown: {},
            topSuggestions: [],
          ),
        );
      }

      final statsRow = statsResult.first;

      // Parse error breakdown from JSON string
      final errorBreakdown = <GrammarErrorType, int>{};
      final errorBreakdownStr = statsRow['error_breakdown'] as String?;
      if (errorBreakdownStr != null && errorBreakdownStr.isNotEmpty) {
        // Parse error breakdown (format: "type:count,type:count")
        final pairs = errorBreakdownStr.split(',');
        for (final pair in pairs) {
          final parts = pair.split(':');
          if (parts.length == 2) {
            try {
              final type = GrammarErrorType.values.firstWhere(
                (e) => e.toString().contains(parts[0].trim()),
                orElse: () => GrammarErrorType.other,
              );
              final count = int.parse(parts[1].trim());
              errorBreakdown[type] = count;
            } catch (e) {
              _logger.w('Error parsing error breakdown: $e');
            }
          }
        }
      }

      final report = DailyReport(
        date: date,
        totalSessions: (statsRow['total_sessions'] as int?) ?? 0,
        totalMinutes: (statsRow['total_minutes'] as int?) ?? 0,
        totalWords: (statsRow['total_words'] as int?) ?? 0,
        totalErrors: (statsRow['total_errors'] as int?) ?? 0,
        accuracy: (statsRow['daily_accuracy'] as num?)?.toDouble() ?? 100.0,
        errorBreakdown: errorBreakdown,
        mostCommonError: statsRow['most_common_error'] != null
            ? GrammarErrorType.values.firstWhere(
                (e) => e.toString().contains(statsRow['most_common_error'] as String),
                orElse: () => GrammarErrorType.other,
              )
            : null,
        topSuggestions: [],
      );

      return Result.success(report);
    } catch (e) {
      _logger.e('Error getting daily report: $e');
      return Result.failure(
        DatabaseFailure(message: 'Failed to get daily report: $e'),
      );
    }
  }

  @override
  Future<Result<WeeklyReport, Failure>> getWeeklyReport(
    String userId,
    String weekStart,
  ) async {
    try {
      final db = getIt<DatabaseService>();
      final database = await db.database;

      // Get weekly stats
      final statsResult = await database.query(
        'weekly_stats',
        where: 'user_id = ? AND week_start_date = ?',
        whereArgs: [userId, weekStart],
      );

      if (statsResult.isEmpty) {
        return Result.success(
          WeeklyReport(
            weekStart: weekStart,
            weekEnd: weekStart,
            totalSessions: 0,
            totalMinutes: 0,
            totalWords: 0,
            totalErrors: 0,
            weeklyAccuracy: 100.0,
            improvementVsPreviousWeek: 0.0,
            errorBreakdown: {},
            dailyReports: [],
          ),
        );
      }

      final statsRow = statsResult.first;

      // Get daily reports for this week
      final dailyReports = await getDailyReportsRange(
        userId,
        weekStart,
        _addDays(weekStart, 6),
      );

      final report = WeeklyReport(
        weekStart: weekStart,
        weekEnd: _addDays(weekStart, 6),
        totalSessions: (statsRow['total_sessions'] as int?) ?? 0,
        totalMinutes: (statsRow['total_minutes'] as int?) ?? 0,
        totalWords: (statsRow['total_words'] as int?) ?? 0,
        totalErrors: (statsRow['total_errors'] as int?) ?? 0,
        weeklyAccuracy: (statsRow['weekly_accuracy'] as num?)?.toDouble() ?? 100.0,
        improvementVsPreviousWeek:
            (statsRow['improvement_vs_last_week'] as num?)?.toDouble() ?? 0.0,
        errorBreakdown: {},
        dailyReports: dailyReports.fold(
          (failure) => <DailyReport>[],
          (reports) => reports,
        ),
      );

      return Result.success(report);
    } catch (e) {
      _logger.e('Error getting weekly report: $e');
      return Result.failure(
        DatabaseFailure(message: 'Failed to get weekly report: $e'),
      );
    }
  }

  @override
  Future<Result<MonthlyReport, Failure>> getMonthlyReport(
    String userId,
    String yearMonth,
  ) async {
    try {
      final db = getIt<DatabaseService>();
      final database = await db.database;

      // Get monthly stats
      final statsResult = await database.query(
        'monthly_stats',
        where: 'user_id = ? AND year_month = ?',
        whereArgs: [userId, yearMonth],
      );

      if (statsResult.isEmpty) {
        return Result.success(
          MonthlyReport(
            yearMonth: yearMonth,
            totalSessions: 0,
            totalMinutes: 0,
            totalWords: 0,
            totalErrors: 0,
            monthlyAccuracy: 100.0,
            errorBreakdown: {},
            weeklyReports: [],
          ),
        );
      }

      final statsRow = statsResult.first;

      final report = MonthlyReport(
        yearMonth: yearMonth,
        totalSessions: (statsRow['total_sessions'] as int?) ?? 0,
        totalMinutes: (statsRow['total_minutes'] as int?) ?? 0,
        totalWords: (statsRow['total_words'] as int?) ?? 0,
        totalErrors: (statsRow['total_errors'] as int?) ?? 0,
        monthlyAccuracy: (statsRow['monthly_accuracy'] as num?)?.toDouble() ?? 100.0,
        errorBreakdown: {},
        weeklyReports: [],
      );

      return Result.success(report);
    } catch (e) {
      _logger.e('Error getting monthly report: $e');
      return Result.failure(
        DatabaseFailure(message: 'Failed to get monthly report: $e'),
      );
    }
  }

  @override
  Future<Result<AccuracyTrend, Failure>> getAccuracyTrend(
    String userId,
    int daysBack,
  ) async {
    try {
      final dailyReportsResult = await getDailyReportsRange(
        userId,
        _subtractDays(DateTime.now().toString().split(' ')[0], daysBack),
        DateTime.now().toString().split(' ')[0],
      );

      return dailyReportsResult.fold(
        (failure) => Result.failure(failure),
        (reports) {
          if (reports.isEmpty) {
            return Result.success(
              AccuracyTrend(
                reports: [],
                startAccuracy: 100.0,
                endAccuracy: 100.0,
                improvementPercentage: 0.0,
                trendDirection: 'stable',
                daysTracked: 0,
              ),
            );
          }

          final sortedReports = List<DailyReport>.from(reports)
            ..sort((a, b) => a.date.compareTo(b.date));

          final startAccuracy = sortedReports.first.accuracy;
          final endAccuracy = sortedReports.last.accuracy;
          final improvement = endAccuracy - startAccuracy;

          String direction = 'stable';
          if (improvement > 5.0) {
            direction = 'improving';
          } else if (improvement < -5.0) {
            direction = 'declining';
          }

          return Result.success(
            AccuracyTrend(
              reports: sortedReports,
              startAccuracy: startAccuracy,
              endAccuracy: endAccuracy,
              improvementPercentage: improvement,
              trendDirection: direction,
              daysTracked: sortedReports.length,
            ),
          );
        },
      );
    } catch (e) {
      _logger.e('Error getting accuracy trend: $e');
      return Result.failure(
        DatabaseFailure(message: 'Failed to get accuracy trend: $e'),
      );
    }
  }

  @override
  Future<Result<List<ErrorPattern>, Failure>> getErrorPatterns(
    String userId,
    int daysBack,
  ) async {
    try {
      final db = getIt<DatabaseService>();
      final database = await db.database;

      final startDate = _subtractDays(DateTime.now().toString().split(' ')[0], daysBack);

      // Get all errors for the user in the date range
      final errorsResult = await database.query(
        'grammar_errors',
        where: 'user_id = ? AND created_at >= ?',
        whereArgs: [userId, DateTime.parse(startDate).millisecondsSinceEpoch],
        orderBy: 'created_at DESC',
      );

      final errorCounts = <String, int>{};
      int totalErrors = 0;

      for (final error in errorsResult) {
        final errorType = error['error_type'] as String;
        errorCounts[errorType] = (errorCounts[errorType] ?? 0) + 1;
        totalErrors++;
      }

      final patterns = <ErrorPattern>[];
      for (final entry in errorCounts.entries) {
        final frequency = totalErrors > 0 ? (entry.value / totalErrors) * 100 : 0.0;

        patterns.add(
          ErrorPattern(
            errorType: GrammarErrorType.values.firstWhere(
              (e) => e.toString().contains(entry.key),
              orElse: () => GrammarErrorType.other,
            ),
            occurrences: entry.value,
            frequency: frequency,
            commonContexts: [],
            suggestedFocus: _getSuggestedFocus(entry.key),
          ),
        );
      }

      // Sort by frequency
      patterns.sort((a, b) => b.frequency.compareTo(a.frequency));

      return Result.success(patterns);
    } catch (e) {
      _logger.e('Error getting error patterns: $e');
      return Result.failure(
        DatabaseFailure(message: 'Failed to get error patterns: $e'),
      );
    }
  }

  @override
  Future<Result<GrammarErrorType?, Failure>> getMostCommonErrorType(
    String userId,
    int daysBack,
  ) async {
    try {
      final patternsResult = await getErrorPatterns(userId, daysBack);

      return patternsResult.fold(
        (failure) => Result.failure(failure),
        (patterns) {
          if (patterns.isEmpty) {
            return Result.success(null);
          }
          return Result.success(patterns.first.errorType);
        },
      );
    } catch (e) {
      return Result.failure(
        DatabaseFailure(message: 'Failed to get most common error type: $e'),
      );
    }
  }

  @override
  Future<Result<ProjectedImprovement, Failure>> getProjectedImprovement(
    String userId,
  ) async {
    try {
      final trendResult = await getAccuracyTrend(userId, 30);

      final ProjectedImprovement improvement;

      final trend = trendResult.fold(
        (failure) => null,
        (trend) => trend,
      );

      if (trend == null || trend.reports.isEmpty) {
        improvement = ProjectedImprovement(
          currentAccuracy: 100.0,
          projectedAccuracy: 100.0,
          daysToReachGoal: 0,
          recommendation: 'Start tracking your grammar to see projections',
          areasToImprove: [],
        );
      } else {
        final currentAccuracy = trend.endAccuracy;
        final improvementRate = trend.improvementPercentage / trend.daysTracked.clamp(1, double.infinity).toDouble();
        final projectedAccuracy = (currentAccuracy + (improvementRate * 30)).clamp(0.0, 100.0).toDouble();
        final daysToGoal = currentAccuracy < 90.0
            ? ((90.0 - currentAccuracy) / improvementRate).ceil()
            : 0;

        final areasToImprove = await _getAreasToImprove(userId, 30);

        improvement = ProjectedImprovement(
          currentAccuracy: currentAccuracy,
          projectedAccuracy: projectedAccuracy,
          daysToReachGoal: daysToGoal > 0 ? daysToGoal : 0,
          recommendation: _getRecommendation(currentAccuracy, projectedAccuracy),
          areasToImprove: areasToImprove,
        );
      }

      return Result.success(improvement);
    } catch (e) {
      _logger.e('Error getting projected improvement: $e');
      return Result.failure(
        DatabaseFailure(message: 'Failed to get projected improvement: $e'),
      );
    }
  }

  @override
  Future<Result<List<PerformanceMetric>, Failure>> getPerformanceComparison(
    String userId,
    String period1Start,
    String period1End,
    String period2Start,
    String period2End,
  ) async {
    try {
      final period1Result = await getDailyReportsRange(
        userId,
        period1Start,
        period1End,
      );

      final period2Result = await getDailyReportsRange(
        userId,
        period2Start,
        period2End,
      );

      final period1Reports = period1Result.fold(
        (failure) => <DailyReport>[],
        (reports) => reports,
      );

      final period2Reports = period2Result.fold(
        (failure) => <DailyReport>[],
        (reports) => reports,
      );

      final metrics = <PerformanceMetric>[];

      // Calculate average accuracy
      final period1AvgAccuracy = period1Reports.isEmpty
          ? 0.0
          : period1Reports.fold(0.0, (sum, r) => sum + r.accuracy) /
              period1Reports.length;
      final period2AvgAccuracy = period2Reports.isEmpty
          ? 0.0
          : period2Reports.fold(0.0, (sum, r) => sum + r.accuracy) /
              period2Reports.length;

      metrics.add(
        PerformanceMetric(
          metricName: 'Average Accuracy',
          currentValue: period2AvgAccuracy,
          previousValue: period1AvgAccuracy,
          changePercentage: period1AvgAccuracy > 0
              ? ((period2AvgAccuracy - period1AvgAccuracy) /
                  period1AvgAccuracy *
                    100)
                : 0,
            status: period2AvgAccuracy > period1AvgAccuracy
                ? 'improved'
                : period2AvgAccuracy < period1AvgAccuracy
                    ? 'declined'
                    : 'stable',
            timestamp: DateTime.now(),
          ),
        );

        // Calculate total words
        final period1Words = period1Reports.fold(0, (sum, r) => sum + r.totalWords);
        final period2Words = period2Reports.fold(0, (sum, r) => sum + r.totalWords);

        metrics.add(
          PerformanceMetric(
            metricName: 'Total Words',
            currentValue: period2Words.toDouble(),
            previousValue: period1Words.toDouble(),
            changePercentage: period1Words > 0
                ? ((period2Words - period1Words) / period1Words * 100)
                : 0,
            status: period2Words > period1Words ? 'improved' : 'declined',
            timestamp: DateTime.now(),
          ),
        );

        return Result.success(metrics);
    } catch (e) {
      _logger.e('Error getting performance comparison: $e');
      return Result.failure(
        DatabaseFailure(message: 'Failed to get performance comparison: $e'),
      );
    }
  }

  @override
  Future<Result<List<DailyReport>, Failure>> getDailyReportsRange(
    String userId,
    String startDate,
    String endDate,
  ) async {
    try {
      final db = getIt<DatabaseService>();
      final database = await db.database;

      final results = await database.query(
        'daily_stats',
        where: 'user_id = ? AND stat_date >= ? AND stat_date <= ?',
        whereArgs: [userId, startDate, endDate],
        orderBy: 'stat_date ASC',
      );

      final reports = <DailyReport>[];
      for (final row in results) {
        final report = DailyReport(
          date: row['stat_date'] as String,
          totalSessions: (row['total_sessions'] as int?) ?? 0,
          totalMinutes: (row['total_minutes'] as int?) ?? 0,
          totalWords: (row['total_words'] as int?) ?? 0,
          totalErrors: (row['total_errors'] as int?) ?? 0,
          accuracy: (row['daily_accuracy'] as num?)?.toDouble() ?? 100.0,
          errorBreakdown: {},
          topSuggestions: [],
        );
        reports.add(report);
      }

      return Result.success(reports);
    } catch (e) {
      _logger.e('Error getting daily reports range: $e');
      return Result.failure(
        DatabaseFailure(message: 'Failed to get daily reports: $e'),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>, Failure>> getOverallStatistics(
    String userId,
  ) async {
    try {
      final db = getIt<DatabaseService>();
      final database = await db.database;

      // Query all speech sessions
      final sessionsResult = await database.rawQuery(
        'SELECT COUNT(*) as session_count, '
            'SUM(duration_seconds) as total_duration, '
            'AVG(accuracy_score) as avg_accuracy '
            'FROM speech_sessions WHERE user_id = ?',
        [userId],
      );

      // Query all errors
      final errorsResult = await database.rawQuery(
        'SELECT COUNT(*) as error_count FROM grammar_errors WHERE user_id = ?',
        [userId],
      );

      // Query all transcriptions
      final transcriptionsResult = await database.rawQuery(
        'SELECT COUNT(*) as transcription_count FROM transcriptions WHERE user_id = ?',
        [userId],
      );

      final stats = {
        'total_sessions': sessionsResult.isNotEmpty
            ? (sessionsResult.first['session_count'] as int?) ?? 0
            : 0,
        'total_duration_seconds': sessionsResult.isNotEmpty
            ? (sessionsResult.first['total_duration'] as int?) ?? 0
            : 0,
        'average_accuracy': sessionsResult.isNotEmpty
            ? (sessionsResult.first['avg_accuracy'] as num?)?.toDouble() ?? 0.0
            : 0.0,
        'total_errors': errorsResult.isNotEmpty
            ? (errorsResult.first['error_count'] as int?) ?? 0
            : 0,
        'total_transcriptions': transcriptionsResult.isNotEmpty
            ? (transcriptionsResult.first['transcription_count'] as int?) ?? 0
            : 0,
      };

      return Result.success(stats);
    } catch (e) {
      _logger.e('Error getting overall statistics: $e');
      return Result.failure(
        DatabaseFailure(message: 'Failed to get overall statistics: $e'),
      );
    }
  }

  // ==================== HELPER METHODS ====================

  String _addDays(String date, int days) {
    return DateFormat('yyyy-MM-dd').format(
      DateTime.parse(date).add(Duration(days: days)),
    );
  }

  String _subtractDays(String date, int days) {
    return DateFormat('yyyy-MM-dd').format(
      DateTime.parse(date).subtract(Duration(days: days)),
    );
  }

  String _getSuggestedFocus(String errorType) {
    final suggestions = {
      'subjectVerbAgreement': 'Make sure subjects and verbs match in number',
      'tenseMismatch': 'Keep your verb tenses consistent throughout',
      'wordChoice': 'Review common word choice mistakes',
      'sentenceStructure': 'Check your sentence structure and organization',
      'punctuation': 'Pay attention to punctuation rules',
      'spelling': 'Focus on correct spelling and contractions',
      'other': 'Review this error type for improvement',
    };
    return suggestions[errorType] ?? 'Continue practicing this area';
  }

  String _getRecommendation(double current, double projected) {
    if (current < 70.0) {
      return 'Great potential! Focus on consistent practice to reach 90%.';
    } else if (current < 85.0) {
      return 'You\'re on the right track! A bit more focus needed.';
    } else if (current < 95.0) {
      return 'Excellent work! You\'re nearly perfect.';
    } else {
      return 'Outstanding! You have excellent grammar skills.';
    }
  }

  Future<List<String>> _getAreasToImprove(String userId, int daysBack) async {
    final patternsResult = await getErrorPatterns(userId, daysBack);

    return patternsResult.fold(
      (failure) => [],
      (patterns) {
        if (patterns.isEmpty) return [];
        return patterns
            .take(3)
            .map((p) => _getSuggestedFocus(p.errorType.toString()))
            .toList();
      },
    );
  }
}
