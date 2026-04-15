import 'package:equatable/equatable.dart';
import '../../../grammar_checker/domain/entities/grammar_mistake.dart';

/// Daily report entity containing aggregated statistics for a single day
class DailyReport extends Equatable {
  const DailyReport({
    required this.date,
    required this.totalSessions,
    required this.totalMinutes,
    required this.totalWords,
    required this.totalErrors,
    required this.accuracy,
    required this.errorBreakdown,
    this.mostCommonError,
    this.topSuggestions = const [],
  });
  final String date;
  final int totalSessions;
  final int totalMinutes;
  final int totalWords;
  final int totalErrors;
  final double accuracy;
  final Map<GrammarErrorType, int> errorBreakdown;
  final GrammarErrorType? mostCommonError;
  final List<String> topSuggestions;

  @override
  List<Object?> get props => [
        date,
        totalSessions,
        totalMinutes,
        totalWords,
        totalErrors,
        accuracy,
        errorBreakdown,
        mostCommonError,
        topSuggestions,
      ];

  // Calculate error rate (errors per 100 words)
  double get errorRate => totalWords > 0 ? (totalErrors / totalWords) * 100 : 0;

  // Check if accuracy improved
  bool get hasGoodAccuracy => accuracy >= 90.0;

  @override
  String toString() => 'DailyReport('
      'date: $date, '
      'sessions: $totalSessions, '
      'accuracy: ${accuracy.toStringAsFixed(1)}%, '
      'errors: $totalErrors)';
}

/// Weekly report containing aggregated statistics for a week
class WeeklyReport extends Equatable {
  const WeeklyReport({
    required this.weekStart,
    required this.weekEnd,
    required this.totalSessions,
    required this.totalMinutes,
    required this.totalWords,
    required this.totalErrors,
    required this.weeklyAccuracy,
    required this.improvementVsPreviousWeek,
    required this.errorBreakdown,
    required this.dailyReports,
  });
  final String weekStart;
  final String weekEnd;
  final int totalSessions;
  final int totalMinutes;
  final int totalWords;
  final int totalErrors;
  final double weeklyAccuracy;
  final double improvementVsPreviousWeek;
  final Map<GrammarErrorType, int> errorBreakdown;
  final List<DailyReport> dailyReports;

  @override
  List<Object?> get props => [
        weekStart,
        weekEnd,
        totalSessions,
        totalMinutes,
        totalWords,
        totalErrors,
        weeklyAccuracy,
        improvementVsPreviousWeek,
        errorBreakdown,
        dailyReports,
      ];

  // Average daily accuracy
  double get averageDailyAccuracy => dailyReports.isEmpty
      ? 0.0
      : dailyReports.fold<double>(0.0, (sum, report) => sum + report.accuracy) /
          dailyReports.length;

  @override
  String toString() => 'WeeklyReport('
      'week: $weekStart - $weekEnd, '
      'accuracy: ${weeklyAccuracy.toStringAsFixed(1)}%, '
      'improvement: ${improvementVsPreviousWeek.toStringAsFixed(1)}%)';
}

/// Monthly report containing aggregated statistics for a month
class MonthlyReport extends Equatable {
  const MonthlyReport({
    required this.yearMonth,
    required this.totalSessions,
    required this.totalMinutes,
    required this.totalWords,
    required this.totalErrors,
    required this.monthlyAccuracy,
    required this.errorBreakdown,
    required this.weeklyReports,
  });
  final String yearMonth;
  final int totalSessions;
  final int totalMinutes;
  final int totalWords;
  final int totalErrors;
  final double monthlyAccuracy;
  final Map<GrammarErrorType, int> errorBreakdown;
  final List<WeeklyReport> weeklyReports;

  @override
  List<Object?> get props => [
        yearMonth,
        totalSessions,
        totalMinutes,
        totalWords,
        totalErrors,
        monthlyAccuracy,
        errorBreakdown,
        weeklyReports,
      ];

  @override
  String toString() => 'MonthlyReport('
      'month: $yearMonth, '
      'accuracy: ${monthlyAccuracy.toStringAsFixed(1)}%, '
      'errors: $totalErrors)';
}

/// Trend data for analyzing improvement over time
class AccuracyTrend extends Equatable {
  const AccuracyTrend({
    required this.reports,
    required this.startAccuracy,
    required this.endAccuracy,
    required this.improvementPercentage,
    required this.trendDirection,
    required this.daysTracked,
  });
  final List<DailyReport> reports;
  final double startAccuracy;
  final double endAccuracy;
  final double improvementPercentage;
  final String trendDirection; // 'improving', 'declining', 'stable'
  final int daysTracked;

  @override
  List<Object?> get props => [
        reports,
        startAccuracy,
        endAccuracy,
        improvementPercentage,
        trendDirection,
        daysTracked,
      ];

  // Average accuracy over the trend period
  double get averageAccuracy => reports.isEmpty
      ? 0.0
      : reports.fold<double>(0.0, (sum, report) => sum + report.accuracy) /
          reports.length;

  @override
  String toString() => 'AccuracyTrend('
      'days: $daysTracked, '
      'start: ${startAccuracy.toStringAsFixed(1)}%, '
      'end: ${endAccuracy.toStringAsFixed(1)}%, '
      'improvement: ${improvementPercentage.toStringAsFixed(1)}%, '
      'direction: $trendDirection)';
}

/// Error pattern analysis
class ErrorPattern extends Equatable {
  const ErrorPattern({
    required this.errorType,
    required this.occurrences,
    required this.frequency,
    required this.commonContexts,
    required this.suggestedFocus,
  });
  final GrammarErrorType errorType;
  final int occurrences;
  final double frequency; // percentage of total errors
  final List<String> commonContexts;
  final String suggestedFocus;

  @override
  List<Object?> get props => [
        errorType,
        occurrences,
        frequency,
        commonContexts,
        suggestedFocus,
      ];

  @override
  String toString() => 'ErrorPattern('
      'type: $errorType, '
      'count: $occurrences, '
      'frequency: ${frequency.toStringAsFixed(1)}%)';
}

/// Performance metric for tracking progress
class PerformanceMetric extends Equatable {
  const PerformanceMetric({
    required this.metricName,
    required this.currentValue,
    required this.previousValue,
    required this.changePercentage,
    required this.status,
    required this.timestamp,
  });
  final String metricName;
  final double currentValue;
  final double previousValue;
  final double changePercentage;
  final String status; // 'improved', 'declined', 'stable'
  final DateTime timestamp;

  @override
  List<Object?> get props => [
        metricName,
        currentValue,
        previousValue,
        changePercentage,
        status,
        timestamp,
      ];

  @override
  String toString() => 'PerformanceMetric('
      '$metricName: $currentValue '
      '(${changePercentage > 0 ? '+' : ''}${changePercentage.toStringAsFixed(1)}%))';
}

/// Goal and projection for user improvement
class ProjectedImprovement extends Equatable {
  const ProjectedImprovement({
    required this.currentAccuracy,
    required this.projectedAccuracy,
    required this.daysToReachGoal,
    required this.recommendation,
    required this.areasToImprove,
  });
  final double currentAccuracy;
  final double projectedAccuracy;
  final int daysToReachGoal;
  final String recommendation;
  final List<String> areasToImprove;

  @override
  List<Object?> get props => [
        currentAccuracy,
        projectedAccuracy,
        daysToReachGoal,
        recommendation,
        areasToImprove,
      ];

  @override
  String toString() => 'ProjectedImprovement('
      'current: ${currentAccuracy.toStringAsFixed(1)}%, '
      'projected: ${projectedAccuracy.toStringAsFixed(1)}%, '
      'days: $daysToReachGoal)';
}
