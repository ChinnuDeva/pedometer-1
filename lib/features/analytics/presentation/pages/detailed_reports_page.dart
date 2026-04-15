import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:word_pedometer/core/constants/butter_theme.dart';
import 'package:word_pedometer/core/utils/injection_container.dart';
import 'package:word_pedometer/features/analytics/domain/entities/analytics_entities.dart';
import 'package:word_pedometer/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:word_pedometer/features/analytics/presentation/widgets/stat_card.dart';
import 'package:word_pedometer/features/grammar_checker/domain/entities/grammar_mistake.dart';

/// Detailed reports page with buttery smooth UI
class DetailedReportsPage extends StatefulWidget {
  const DetailedReportsPage({Key? key}) : super(key: key);

  @override
  State<DetailedReportsPage> createState() => _DetailedReportsPageState();
}

class _DetailedReportsPageState extends State<DetailedReportsPage>
    with SingleTickerProviderStateMixin {
  late AnalyticsBloc _analyticsBloc;
  late AnimationController _animationController;
  static const String _userId = 'default_user';

  ReportPeriod _selectedPeriod = ReportPeriod.weekly;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _analyticsBloc = getIt<AnalyticsBloc>();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animationController.forward();
    _loadReport();
  }

  void _loadReport() {
    switch (_selectedPeriod) {
      case ReportPeriod.daily:
        _analyticsBloc.add(GetDailyReportEvent(
          userId: _userId,
          date: _formatDate(_selectedDate),
        ));
        break;
      case ReportPeriod.weekly:
        final weekStart = _getWeekStart(_selectedDate);
        _analyticsBloc.add(GetWeeklyReportEvent(
          userId: _userId,
          weekStart: _formatDate(weekStart),
        ));
        break;
      case ReportPeriod.monthly:
        final yearMonth =
            '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}';
        _analyticsBloc.add(GetMonthlyReportEvent(
          userId: _userId,
          yearMonth: yearMonth,
        ));
        break;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
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
            child: Column(
              children: [
                _buildAppBar(context),
                _buildPeriodSelector(),
                _buildDatePicker(),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildReportContent(),
                ),
              ],
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
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
              color: ButterTheme.butterDark,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Detailed Reports',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: ReportPeriod.values.map((period) {
            final isSelected = _selectedPeriod == period;
            return Expanded(
              child: AnimatedContainer(
                duration: ButterTheme.butterFastDuration,
                curve: ButterTheme.butterSmoothCurve,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedPeriod = period;
                        _selectedDate = DateTime.now();
                      });
                      _loadReport();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: ButterTheme.butterFastDuration,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? ButterTheme.butterGold
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        period.displayName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    String dateDisplay;
    switch (_selectedPeriod) {
      case ReportPeriod.daily:
        dateDisplay = DateFormat('MMMM d, yyyy').format(_selectedDate);
        break;
      case ReportPeriod.weekly:
        final weekStart = _getWeekStart(_selectedDate);
        final weekEnd = weekStart.add(const Duration(days: 6));
        dateDisplay =
            '${DateFormat('MMM d').format(weekStart)} - ${DateFormat('MMM d, yyyy').format(weekEnd)}';
        break;
      case ReportPeriod.monthly:
        dateDisplay = DateFormat('MMMM yyyy').format(_selectedDate);
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDateNavButton(
              icon: Icons.chevron_left_rounded,
              onTap: () {
                setState(() {
                  switch (_selectedPeriod) {
                    case ReportPeriod.daily:
                      _selectedDate =
                          _selectedDate.subtract(const Duration(days: 1));
                      break;
                    case ReportPeriod.weekly:
                      _selectedDate =
                          _selectedDate.subtract(const Duration(days: 7));
                      break;
                    case ReportPeriod.monthly:
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month - 1,
                      );
                      break;
                  }
                });
                _loadReport();
              },
            ),
            Expanded(
              child: Text(
                dateDisplay,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _buildDateNavButton(
              icon: Icons.chevron_right_rounded,
              onTap: () {
                setState(() {
                  switch (_selectedPeriod) {
                    case ReportPeriod.daily:
                      _selectedDate =
                          _selectedDate.add(const Duration(days: 1));
                      break;
                    case ReportPeriod.weekly:
                      _selectedDate =
                          _selectedDate.add(const Duration(days: 7));
                      break;
                    case ReportPeriod.monthly:
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month + 1,
                      );
                      break;
                  }
                });
                _loadReport();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ButterTheme.butterGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: ButterTheme.butterGold,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildReportContent() {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) {
        if (state is DailyReportLoaded) {
          return _buildDailyReportView(state.report);
        }

        if (state is WeeklyReportLoaded) {
          return _buildWeeklyReportView(state.report);
        }

        if (state is MonthlyReportLoaded) {
          return _buildMonthlyReportView(state.report);
        }

        if (state is AnalyticsLoading) {
          return Center(
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
          );
        }

        return _buildEmptyState('No data available for selected period');
      },
    );
  }

  Widget _buildDailyReportView(DailyReport report) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
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
              final items = [
                _StatItem('Accuracy', report.accuracy.toStringAsFixed(1), '%',
                    Icons.trending_up_rounded, Colors.blue),
                _StatItem('Sessions', report.totalSessions.toString(), '',
                    Icons.mic_rounded, ButterTheme.butterOrange),
                _StatItem('Total Words', _formatNumber(report.totalWords), '',
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
                delay: Duration(milliseconds: index * 100),
              );
            },
          ),
          if (report.errorBreakdown.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text(
              'Error Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...report.errorBreakdown.entries.map((entry) {
              final total = report.errorBreakdown.values
                  .fold(0, (sum, count) => sum + count);
              final percentage = total > 0 ? (entry.value / total) * 100 : 0.0;
              return _buildErrorBreakdownItem(
                entry.key.displayName,
                entry.value,
                percentage,
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildWeeklyReportView(WeeklyReport report) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
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
              final items = [
                _StatItem('Accuracy', report.weeklyAccuracy.toStringAsFixed(1),
                    '%', Icons.trending_up_rounded, Colors.blue),
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
                delay: Duration(milliseconds: index * 100),
              );
            },
          ),
          const SizedBox(height: 32),
          _buildImprovementCard(report),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMonthlyReportView(MonthlyReport report) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
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
              final items = [
                _StatItem('Accuracy', report.monthlyAccuracy.toStringAsFixed(1),
                    '%', Icons.trending_up_rounded, Colors.blue),
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
                delay: Duration(milliseconds: index * 100),
              );
            },
          ),
          const SizedBox(height: 32),
          if (report.weeklyReports.isNotEmpty) ...[
            Text(
              'Weekly Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...report.weeklyReports.asMap().entries.map((entry) {
              final weekNum = entry.key + 1;
              final report = entry.value;
              return _buildWeeklyBreakdownItem(weekNum, report);
            }).toList(),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildImprovementCard(WeeklyReport report) {
    final isImproving = report.improvementVsPreviousWeek >= 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isImproving
              ? [ButterTheme.butterSuccess.withOpacity(0.2), Colors.white]
              : [ButterTheme.butterError.withOpacity(0.2), Colors.white],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isImproving
              ? ButterTheme.butterSuccess.withOpacity(0.3)
              : ButterTheme.butterError.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isImproving
                  ? ButterTheme.butterSuccess.withOpacity(0.2)
                  : ButterTheme.butterError.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isImproving ? Icons.trending_up_rounded : Icons.trending_down_rounded,
              color: isImproving
                  ? ButterTheme.butterSuccess
                  : ButterTheme.butterError,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'vs Previous Week',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${report.improvementVsPreviousWeek > 0 ? '+' : ''}${report.improvementVsPreviousWeek.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: isImproving
                        ? ButterTheme.butterSuccess
                        : ButterTheme.butterError,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBreakdownItem(String name, int count, double percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$count (${percentage.toStringAsFixed(1)}%)',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyBreakdownItem(int weekNum, WeeklyReport report) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: ButterTheme.butterGold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'W$weekNum',
                  style: const TextStyle(
                    color: ButterTheme.butterGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${report.weeklyAccuracy.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${report.totalSessions} sessions · ${_formatNumber(report.totalWords)} words',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 15,
            ),
          ),
        ],
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

enum ReportPeriod {
  daily,
  weekly,
  monthly,
}

extension ReportPeriodX on ReportPeriod {
  String get displayName {
    switch (this) {
      case ReportPeriod.daily:
        return 'Daily';
      case ReportPeriod.weekly:
        return 'Weekly';
      case ReportPeriod.monthly:
        return 'Monthly';
    }
  }
}
