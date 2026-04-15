import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:word_pedometer/features/analytics/domain/entities/analytics_entities.dart';
import 'package:word_pedometer/features/analytics/domain/usecases/analytics_usecases.dart';

// ==================== EVENTS ====================

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class GetDailyReportEvent extends AnalyticsEvent {
  final String userId;
  final String date;

  const GetDailyReportEvent({
    required this.userId,
    required this.date,
  });

  @override
  List<Object?> get props => [userId, date];
}

class GetWeeklyReportEvent extends AnalyticsEvent {
  final String userId;
  final String weekStart;

  const GetWeeklyReportEvent({
    required this.userId,
    required this.weekStart,
  });

  @override
  List<Object?> get props => [userId, weekStart];
}

class GetMonthlyReportEvent extends AnalyticsEvent {
  final String userId;
  final String yearMonth;

  const GetMonthlyReportEvent({
    required this.userId,
    required this.yearMonth,
  });

  @override
  List<Object?> get props => [userId, yearMonth];
}

class GetAccuracyTrendEvent extends AnalyticsEvent {
  final String userId;
  final int daysBack;

  const GetAccuracyTrendEvent({
    required this.userId,
    this.daysBack = 30,
  });

  @override
  List<Object?> get props => [userId, daysBack];
}

class GetErrorPatternsEvent extends AnalyticsEvent {
  final String userId;
  final int daysBack;

  const GetErrorPatternsEvent({
    required this.userId,
    this.daysBack = 30,
  });

  @override
  List<Object?> get props => [userId, daysBack];
}

class GetProjectedImprovementEvent extends AnalyticsEvent {
  final String userId;

  const GetProjectedImprovementEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class GetPerformanceComparisonEvent extends AnalyticsEvent {
  final String userId;
  final String period1Start;
  final String period1End;
  final String period2Start;
  final String period2End;

  const GetPerformanceComparisonEvent({
    required this.userId,
    required this.period1Start,
    required this.period1End,
    required this.period2Start,
    required this.period2End,
  });

  @override
  List<Object?> get props => [
    userId,
    period1Start,
    period1End,
    period2Start,
    period2End,
  ];
}

class GetOverallStatisticsEvent extends AnalyticsEvent {
  final String userId;

  const GetOverallStatisticsEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class GetDailyReportsRangeEvent extends AnalyticsEvent {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  const GetDailyReportsRangeEvent({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate];
}

// ==================== STATES ====================

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

class AnalyticsLoading extends AnalyticsState {
  final String message;

  const AnalyticsLoading({this.message = 'Loading analytics...'});

  @override
  List<Object?> get props => [message];
}

class DailyReportLoaded extends AnalyticsState {
  final DailyReport report;

  const DailyReportLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

class WeeklyReportLoaded extends AnalyticsState {
  final WeeklyReport report;

  const WeeklyReportLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

class MonthlyReportLoaded extends AnalyticsState {
  final MonthlyReport report;

  const MonthlyReportLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

class AccuracyTrendLoaded extends AnalyticsState {
  final AccuracyTrend trend;

  const AccuracyTrendLoaded(this.trend);

  @override
  List<Object?> get props => [trend];
}

class ErrorPatternsLoaded extends AnalyticsState {
  final List<ErrorPattern> patterns;

  const ErrorPatternsLoaded(this.patterns);

  @override
  List<Object?> get props => [patterns];
}

class ProjectedImprovementLoaded extends AnalyticsState {
  final ProjectedImprovement improvement;

  const ProjectedImprovementLoaded(this.improvement);

  @override
  List<Object?> get props => [improvement];
}

class PerformanceComparisonLoaded extends AnalyticsState {
  final List<PerformanceMetric> metrics;

  const PerformanceComparisonLoaded(this.metrics);

  @override
  List<Object?> get props => [metrics];
}

class OverallStatisticsLoaded extends AnalyticsState {
  final Map<String, dynamic> statistics;

  const OverallStatisticsLoaded(this.statistics);

  @override
  List<Object?> get props => [statistics];
}

class DailyReportsRangeLoaded extends AnalyticsState {
  final List<DailyReport> dailyReports;

  const DailyReportsRangeLoaded(this.dailyReports);

  @override
  List<Object?> get props => [dailyReports];
}

class AnalyticsError extends AnalyticsState {
  final String message;

  const AnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== BLOC ====================

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final GetDailyReportUseCase _getDailyReportUseCase;
  final GetWeeklyReportUseCase _getWeeklyReportUseCase;
  final GetMonthlyReportUseCase _getMonthlyReportUseCase;
  final GetAccuracyTrendUseCase _getAccuracyTrendUseCase;
  final GetErrorPatternsUseCase _getErrorPatternsUseCase;
  final GetProjectedImprovementUseCase _getProjectedImprovementUseCase;
  final GetPerformanceComparisonUseCase _getPerformanceComparisonUseCase;
  final GetOverallStatisticsUseCase _getOverallStatisticsUseCase;

  final Logger _logger = Logger();

  AnalyticsBloc({
    required GetDailyReportUseCase getDailyReportUseCase,
    required GetWeeklyReportUseCase getWeeklyReportUseCase,
    required GetMonthlyReportUseCase getMonthlyReportUseCase,
    required GetAccuracyTrendUseCase getAccuracyTrendUseCase,
    required GetErrorPatternsUseCase getErrorPatternsUseCase,
    required GetProjectedImprovementUseCase getProjectedImprovementUseCase,
    required GetPerformanceComparisonUseCase getPerformanceComparisonUseCase,
    required GetOverallStatisticsUseCase getOverallStatisticsUseCase,
  })  : _getDailyReportUseCase = getDailyReportUseCase,
        _getWeeklyReportUseCase = getWeeklyReportUseCase,
        _getMonthlyReportUseCase = getMonthlyReportUseCase,
        _getAccuracyTrendUseCase = getAccuracyTrendUseCase,
        _getErrorPatternsUseCase = getErrorPatternsUseCase,
        _getProjectedImprovementUseCase = getProjectedImprovementUseCase,
        _getPerformanceComparisonUseCase = getPerformanceComparisonUseCase,
        _getOverallStatisticsUseCase = getOverallStatisticsUseCase,
         super(const AnalyticsInitial()) {
    on<GetDailyReportEvent>(_onGetDailyReport);
    on<GetWeeklyReportEvent>(_onGetWeeklyReport);
    on<GetMonthlyReportEvent>(_onGetMonthlyReport);
    on<GetAccuracyTrendEvent>(_onGetAccuracyTrend);
    on<GetErrorPatternsEvent>(_onGetErrorPatterns);
    on<GetProjectedImprovementEvent>(_onGetProjectedImprovement);
    on<GetPerformanceComparisonEvent>(_onGetPerformanceComparison);
    on<GetOverallStatisticsEvent>(_onGetOverallStatistics);
    on<GetDailyReportsRangeEvent>(_onGetDailyReportsRange);
  }

  Future<void> _onGetDailyReport(
    GetDailyReportEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading(message: 'Loading daily report...'));

    final result = await _getDailyReportUseCase(
      GetDailyReportParams(userId: event.userId, date: event.date),
    );

    result.fold(
      (failure) {
        _logger.e('Error loading daily report: ${failure.message}');
        emit(AnalyticsError(failure.message));
      },
      (report) => emit(DailyReportLoaded(report)),
    );
  }

  Future<void> _onGetWeeklyReport(
    GetWeeklyReportEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading(message: 'Loading weekly report...'));

    final result = await _getWeeklyReportUseCase(
      GetWeeklyReportParams(userId: event.userId, weekStart: event.weekStart),
    );

    result.fold(
      (failure) {
        _logger.e('Error loading weekly report: ${failure.message}');
        emit(AnalyticsError(failure.message));
      },
      (report) => emit(WeeklyReportLoaded(report)),
    );
  }

  Future<void> _onGetMonthlyReport(
    GetMonthlyReportEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading(message: 'Loading monthly report...'));

    final result = await _getMonthlyReportUseCase(
      GetMonthlyReportParams(userId: event.userId, yearMonth: event.yearMonth),
    );

    result.fold(
      (failure) {
        _logger.e('Error loading monthly report: ${failure.message}');
        emit(AnalyticsError(failure.message));
      },
      (report) => emit(MonthlyReportLoaded(report)),
    );
  }

  Future<void> _onGetAccuracyTrend(
    GetAccuracyTrendEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading(message: 'Loading accuracy trend...'));

    final result = await _getAccuracyTrendUseCase(
      GetAccuracyTrendParams(userId: event.userId, daysBack: event.daysBack),
    );

    result.fold(
      (failure) {
        _logger.e('Error loading accuracy trend: ${failure.message}');
        emit(AnalyticsError(failure.message));
      },
      (trend) => emit(AccuracyTrendLoaded(trend)),
    );
  }

  Future<void> _onGetErrorPatterns(
    GetErrorPatternsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading(message: 'Analyzing error patterns...'));

    final result = await _getErrorPatternsUseCase(
      GetErrorPatternsParams(userId: event.userId, daysBack: event.daysBack),
    );

    result.fold(
      (failure) {
        _logger.e('Error loading error patterns: ${failure.message}');
        emit(AnalyticsError(failure.message));
      },
      (patterns) => emit(ErrorPatternsLoaded(patterns)),
    );
  }

  Future<void> _onGetProjectedImprovement(
    GetProjectedImprovementEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading(message: 'Calculating improvements...'));

    final result = await _getProjectedImprovementUseCase(
      GetProjectedImprovementParams(userId: event.userId),
    );

    result.fold(
      (failure) {
        _logger.e('Error loading projected improvement: ${failure.message}');
        emit(AnalyticsError(failure.message));
      },
      (improvement) => emit(ProjectedImprovementLoaded(improvement)),
    );
  }

  Future<void> _onGetPerformanceComparison(
    GetPerformanceComparisonEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading(message: 'Comparing performance...'));

    final result = await _getPerformanceComparisonUseCase(
      GetPerformanceComparisonParams(
        userId: event.userId,
        period1Start: event.period1Start,
        period1End: event.period1End,
        period2Start: event.period2Start,
        period2End: event.period2End,
      ),
    );

    result.fold(
      (failure) {
        _logger.e('Error loading performance comparison: ${failure.message}');
        emit(AnalyticsError(failure.message));
      },
      (metrics) => emit(PerformanceComparisonLoaded(metrics)),
    );
  }

  Future<void> _onGetOverallStatistics(
    GetOverallStatisticsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading(message: 'Loading statistics...'));

    final result = await _getOverallStatisticsUseCase(
      GetOverallStatisticsParams(userId: event.userId),
    );

    result.fold(
      (failure) {
        _logger.e('Error loading overall statistics: ${failure.message}');
        emit(AnalyticsError(failure.message));
      },
      (statistics) => emit(OverallStatisticsLoaded(statistics)),
    );
  }

  Future<void> _onGetDailyReportsRange(
    GetDailyReportsRangeEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading(message: 'Loading daily reports...'));

    final result = await _getDailyReportUseCase(
      GetDailyReportParams(
        userId: event.userId,
        date: event.startDate.toIso8601String(),
      ),
    );

    // For now, load individual daily reports from start to end
    // In future, add GetDailyReportsRangeUseCase for bulk loading
    final dailyReports = <DailyReport>[];
    var currentDate = event.startDate;
    
    while (currentDate.isBefore(event.endDate) || currentDate.isAtSameMomentAs(event.endDate)) {
      final dayResult = await _getDailyReportUseCase(
        GetDailyReportParams(userId: event.userId, date: currentDate.toIso8601String()),
      );
      
      dayResult.fold(
        (failure) {
          // Silently skip days with no data
        },
        (report) {
          dailyReports.add(report);
        },
      );
      
      currentDate = currentDate.add(const Duration(days: 1));
    }

    if (dailyReports.isNotEmpty) {
      emit(DailyReportsRangeLoaded(dailyReports));
    } else {
      _logger.e('No daily reports found in range');
      emit(const AnalyticsError('No data available for selected period'));
    }
  }
}
