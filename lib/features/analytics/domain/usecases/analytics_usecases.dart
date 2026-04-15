import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/analytics_entities.dart';
import '../repositories/analytics_repository.dart';

// ==================== GET DAILY REPORT ====================

class GetDailyReportParams {

  GetDailyReportParams({
    required this.userId,
    required this.date,
  });
  final String userId;
  final String date;
}

class GetDailyReportUseCase
    extends UseCase<DailyReport, GetDailyReportParams> {

  GetDailyReportUseCase({required AnalyticsRepository repository})
      : _repository = repository;
  final AnalyticsRepository _repository;

  @override
  Future<Result<DailyReport, Failure>> call(GetDailyReportParams params) =>
      _repository.getDailyReport(params.userId, params.date);
}

// ==================== GET WEEKLY REPORT ====================

class GetWeeklyReportParams {

  GetWeeklyReportParams({
    required this.userId,
    required this.weekStart,
  });
  final String userId;
  final String weekStart;
}

class GetWeeklyReportUseCase
    extends UseCase<WeeklyReport, GetWeeklyReportParams> {

  GetWeeklyReportUseCase({required AnalyticsRepository repository})
      : _repository = repository;
  final AnalyticsRepository _repository;

  @override
  Future<Result<WeeklyReport, Failure>> call(GetWeeklyReportParams params) =>
      _repository.getWeeklyReport(params.userId, params.weekStart);
}

// ==================== GET MONTHLY REPORT ====================

class GetMonthlyReportParams {

  GetMonthlyReportParams({
    required this.userId,
    required this.yearMonth,
  });
  final String userId;
  final String yearMonth;
}

class GetMonthlyReportUseCase
    extends UseCase<MonthlyReport, GetMonthlyReportParams> {

  GetMonthlyReportUseCase({required AnalyticsRepository repository})
      : _repository = repository;
  final AnalyticsRepository _repository;

  @override
  Future<Result<MonthlyReport, Failure>> call(GetMonthlyReportParams params) =>
      _repository.getMonthlyReport(params.userId, params.yearMonth);
}

// ==================== GET ACCURACY TREND ====================

class GetAccuracyTrendParams {

  GetAccuracyTrendParams({
    required this.userId,
    this.daysBack = 30,
  });
  final String userId;
  final int daysBack;
}

class GetAccuracyTrendUseCase
    extends UseCase<AccuracyTrend, GetAccuracyTrendParams> {

  GetAccuracyTrendUseCase({required AnalyticsRepository repository})
      : _repository = repository;
  final AnalyticsRepository _repository;

  @override
  Future<Result<AccuracyTrend, Failure>> call(GetAccuracyTrendParams params) =>
      _repository.getAccuracyTrend(params.userId, params.daysBack);
}

// ==================== GET ERROR PATTERNS ====================

class GetErrorPatternsParams {

  GetErrorPatternsParams({
    required this.userId,
    this.daysBack = 30,
  });
  final String userId;
  final int daysBack;
}

class GetErrorPatternsUseCase
    extends UseCase<List<ErrorPattern>, GetErrorPatternsParams> {

  GetErrorPatternsUseCase({required AnalyticsRepository repository})
      : _repository = repository;
  final AnalyticsRepository _repository;

  @override
  Future<Result<List<ErrorPattern>, Failure>> call(
    GetErrorPatternsParams params,
  ) =>
      _repository.getErrorPatterns(params.userId, params.daysBack);
}

// ==================== GET PROJECTED IMPROVEMENT ====================

class GetProjectedImprovementParams {

  GetProjectedImprovementParams({required this.userId});
  final String userId;
}

class GetProjectedImprovementUseCase
    extends UseCase<ProjectedImprovement, GetProjectedImprovementParams> {

  GetProjectedImprovementUseCase({required AnalyticsRepository repository})
      : _repository = repository;
  final AnalyticsRepository _repository;

  @override
  Future<Result<ProjectedImprovement, Failure>> call(
    GetProjectedImprovementParams params,
  ) =>
      _repository.getProjectedImprovement(params.userId);
}

// ==================== GET PERFORMANCE COMPARISON ====================

class GetPerformanceComparisonParams {

  GetPerformanceComparisonParams({
    required this.userId,
    required this.period1Start,
    required this.period1End,
    required this.period2Start,
    required this.period2End,
  });
  final String userId;
  final String period1Start;
  final String period1End;
  final String period2Start;
  final String period2End;
}

class GetPerformanceComparisonUseCase
    extends UseCase<List<PerformanceMetric>, GetPerformanceComparisonParams> {

  GetPerformanceComparisonUseCase({required AnalyticsRepository repository})
      : _repository = repository;
  final AnalyticsRepository _repository;

  @override
  Future<Result<List<PerformanceMetric>, Failure>> call(
    GetPerformanceComparisonParams params,
  ) =>
      _repository.getPerformanceComparison(
        params.userId,
        params.period1Start,
        params.period1End,
        params.period2Start,
        params.period2End,
      );
}

// ==================== GET DAILY REPORTS RANGE ====================

class GetDailyReportsRangeParams {

  GetDailyReportsRangeParams({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });
  final String userId;
  final String startDate;
  final String endDate;
}

class GetDailyReportsRangeUseCase
    extends UseCase<List<DailyReport>, GetDailyReportsRangeParams> {

  GetDailyReportsRangeUseCase({required AnalyticsRepository repository})
      : _repository = repository;
  final AnalyticsRepository _repository;

  @override
  Future<Result<List<DailyReport>, Failure>> call(
    GetDailyReportsRangeParams params,
  ) =>
      _repository.getDailyReportsRange(
        params.userId,
        params.startDate,
        params.endDate,
      );
}

// ==================== GET OVERALL STATISTICS ====================

class GetOverallStatisticsParams {

  GetOverallStatisticsParams({required this.userId});
  final String userId;
}

class GetOverallStatisticsUseCase
    extends UseCase<Map<String, dynamic>, GetOverallStatisticsParams> {

  GetOverallStatisticsUseCase({required AnalyticsRepository repository})
      : _repository = repository;
  final AnalyticsRepository _repository;

  @override
  Future<Result<Map<String, dynamic>, Failure>> call(
    GetOverallStatisticsParams params,
  ) =>
      _repository.getOverallStatistics(params.userId);
}
