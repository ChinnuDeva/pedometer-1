import 'package:word_pedometer/core/errors/failures.dart';
import 'package:word_pedometer/core/errors/result.dart';
import 'package:word_pedometer/features/analytics/domain/entities/analytics_entities.dart';
import 'package:word_pedometer/features/grammar_checker/domain/entities/grammar_mistake.dart';

/// Repository interface for analytics operations
abstract class AnalyticsRepository {
  /// Get daily report for a specific date
  Future<Result<DailyReport, Failure>> getDailyReport(
    String userId,
    String date,
  );

  /// Get weekly reports for a date range
  Future<Result<WeeklyReport, Failure>> getWeeklyReport(
    String userId,
    String weekStart,
  );

  /// Get monthly report for a specific month
  Future<Result<MonthlyReport, Failure>> getMonthlyReport(
    String userId,
    String yearMonth,
  );

  /// Get accuracy trend for a date range
  Future<Result<AccuracyTrend, Failure>> getAccuracyTrend(
    String userId,
    int daysBack,
  );

  /// Get error patterns analysis
  Future<Result<List<ErrorPattern>, Failure>> getErrorPatterns(
    String userId,
    int daysBack,
  );

  /// Get most common error type
  Future<Result<GrammarErrorType?, Failure>> getMostCommonErrorType(
    String userId,
    int daysBack,
  );

  /// Calculate projected improvement based on current trend
  Future<Result<ProjectedImprovement, Failure>> getProjectedImprovement(
    String userId,
  );

  /// Get performance metrics comparing two periods
  Future<Result<List<PerformanceMetric>, Failure>> getPerformanceComparison(
    String userId,
    String period1Start,
    String period1End,
    String period2Start,
    String period2End,
  );

  /// Get all daily reports for a date range
  Future<Result<List<DailyReport>, Failure>> getDailyReportsRange(
    String userId,
    String startDate,
    String endDate,
  );

  /// Calculate user's overall statistics
  Future<Result<Map<String, dynamic>, Failure>> getOverallStatistics(
    String userId,
  );
}
