import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:word_pedometer/core/constants/butter_theme.dart';
import 'package:word_pedometer/core/utils/injection_container.dart';
import 'package:word_pedometer/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:word_pedometer/features/analytics/presentation/widgets/accuracy_trend_chart.dart';
import 'package:word_pedometer/features/analytics/presentation/widgets/error_distribution_chart.dart';
import 'package:word_pedometer/features/analytics/presentation/widgets/error_frequency_chart.dart';
import 'package:word_pedometer/features/analytics/presentation/widgets/stat_card.dart';

/// Analytics dashboard showing statistics and trends with buttery smooth UI
class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late AnalyticsBloc _analyticsBloc;
  late AnimationController _animationController;
  static const String _userId = 'default_user';

  @override
  void initState() {
    super.initState();
    _analyticsBloc = getIt<AnalyticsBloc>();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    _analyticsBloc.add(GetDailyReportEvent(
      userId: _userId,
      date: _formatDateForEvent(DateTime.now()),
    ));

    _analyticsBloc.add(GetAccuracyTrendEvent(
      userId: _userId,
      daysBack: 30,
    ));

    _analyticsBloc.add(GetErrorPatternsEvent(
      userId: _userId,
      daysBack: 30,
    ));

    _analyticsBloc.add(GetProjectedImprovementEvent(
      userId: _userId,
    ));

    final today = DateTime.now();
    final thirtyDaysAgo = today.subtract(const Duration(days: 30));
    _analyticsBloc.add(GetDailyReportsRangeEvent(
      userId: _userId,
      startDate: thirtyDaysAgo,
      endDate: today,
    ));
  }

  String _formatDateForEvent(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AnalyticsBloc>.value(
      value: _analyticsBloc,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFFFF8),
                Color(0xFFFFFDF5),
              ],
            ),
          ),
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                _loadDashboardData();
                await Future.delayed(const Duration(milliseconds: 500));
              },
              color: ButterTheme.butterGold,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  // App Bar
                  SliverToBoxAdapter(
                    child: _buildAppBar(context),
                  ),

                  // Content
                  SliverToBoxAdapter(
                    child: BlocListener<AnalyticsBloc, AnalyticsState>(
                      listener: (context, state) {
                        if (state is AnalyticsError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: ButterTheme.butterError,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          _buildTodaySection(),
                          const SizedBox(height: 24),
                          _buildAccuracyTrendSection(),
                          const SizedBox(height: 12),
                          _buildAccuracyTrendChartSection(),
                          const SizedBox(height: 24),
                          _buildErrorAnalysisSection(),
                          const SizedBox(height: 24),
                          _buildProjectedImprovementSection(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analytics',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your progress at a glance',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ButterTheme.butterGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: ButterTheme.butterGold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySection() {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) {
        if (state is DailyReportLoaded) {
          final report = state.report;
          final dateObj = DateTime.parse(report.date);
          final dateStr = DateFormat('EEEE, MMM d').format(dateObj);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Today's Progress",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    final delays = [
                      const Duration(milliseconds: 0),
                      const Duration(milliseconds: 100),
                      const Duration(milliseconds: 200),
                      const Duration(milliseconds: 300),
                    ];
                    final items = [
                      _StatItem('Accuracy', report.accuracy.toStringAsFixed(1), '%',
                          Icons.trending_up_rounded, Colors.blue),
                      _StatItem('Sessions', report.totalSessions.toString(), '',
                          Icons.mic_rounded, ButterTheme.butterOrange),
                      _StatItem('Words', _formatNumber(report.totalWords), '',
                          Icons.text_fields_rounded, ButterTheme.butterSuccess),
                      _StatItem('Errors', report.totalErrors.toString(), '',
                          Icons.warning_rounded, ButterTheme.butterError),
                    ];
                    return StatCard(
                      title: items[index].title,
                      value: items[index].value,
                      unit: items[index].unit,
                      icon: items[index].icon,
                      color: items[index].color,
                      delay: delays[index],
                    );
                  },
                ),
              ),
            ],
          );
        }

        if (state is AnalyticsLoading) {
          return SizedBox(
            height: 280,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: ButterTheme.butterGold,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        }

        return _buildEmptyState('Unable to load today\'s data');
      },
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  Widget _buildAccuracyTrendSection() {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) {
        if (state is AccuracyTrendLoaded) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AnimatedContainer(
              duration: ButterTheme.butterSmoothDuration,
              curve: ButterTheme.butterSmoothCurve,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    ButterTheme.butterCream,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Accuracy Trend',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildTrendBadge(
                        state.trend.trendDirection,
                        '${state.trend.improvementPercentage.toStringAsFixed(1)}%',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildMetricChip(
                        'Average',
                        '${state.trend.averageAccuracy.toStringAsFixed(1)}%',
                        ButterTheme.butterGold,
                      ),
                      const SizedBox(width: 12),
                      _buildMetricChip(
                        'Days Tracked',
                        '${state.trend.daysTracked}',
                        Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        if (state is AnalyticsLoading) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMetricChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChartCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildAccuracyTrendChartSection() {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) {
        if (state is DailyReportsRangeLoaded) {
          return _buildTrendChartCard(
            child: AccuracyTrendChart(
              dailyReports: state.dailyReports,
              height: 250,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildErrorAnalysisSection() {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) {
        if (state is ErrorPatternsLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Error Analysis',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildTrendChartCard(
                child: ErrorFrequencyChart(
                  errorPatterns: state.patterns,
                  maxBars: 5,
                  height: 280,
                ),
              ),
              const SizedBox(height: 16),
              _buildTrendChartCard(
                child: ErrorDistributionChart(
                  errorPatterns: state.patterns,
                  height: 280,
                ),
              ),
            ],
          );
        }

        if (state is AnalyticsLoading) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return _buildEmptyState('Unable to load error analysis');
      },
    );
  }

  Widget _buildProjectedImprovementSection() {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) {
        if (state is ProjectedImprovementLoaded) {
          final projection = state.improvement;
          final daysToGoal = projection.daysToReachGoal;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: ButterTheme.butterGradientLight,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: ButterTheme.butterGold.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Projected Improvement',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.auto_graph_rounded,
                          color: ButterTheme.butterOrange,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildProjectionMetric(
                        'Current',
                        '${projection.currentAccuracy.toStringAsFixed(1)}%',
                        Colors.blue,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.withOpacity(0.3),
                      ),
                      _buildProjectionMetric(
                        'Projected',
                        '${projection.projectedAccuracy.toStringAsFixed(1)}%',
                        ButterTheme.butterSuccess,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.withOpacity(0.3),
                      ),
                      _buildProjectionMetric(
                        'Days to Goal',
                        daysToGoal >= 0 ? daysToGoal.toString() : 'Done!',
                        daysToGoal >= 0
                            ? ButterTheme.butterOrange
                            : ButterTheme.butterSuccess,
                      ),
                    ],
                  ),
                  if (projection.areasToImprove.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 16),
                    Text(
                      'Focus Areas',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...projection.areasToImprove.take(3).map(
                          (area) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    area,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ],
              ),
            ),
          );
        }

        if (state is AnalyticsLoading) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildProjectionMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendBadge(String trendDirection, String value) {
    final isImproving = trendDirection == 'improving';
    final color = isImproving
        ? ButterTheme.butterSuccess
        : trendDirection == 'declining'
            ? ButterTheme.butterError
            : Colors.grey;
    final icon = isImproving
        ? Icons.trending_up_rounded
        : trendDirection == 'declining'
            ? Icons.trending_down_rounded
            : Icons.trending_flat_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 48,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _analyticsBloc.close();
    super.dispose();
  }
}

class _StatItem {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  _StatItem(this.title, this.value, this.unit, this.icon, this.color);
}
