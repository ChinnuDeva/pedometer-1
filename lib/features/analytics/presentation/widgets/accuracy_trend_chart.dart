import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/analytics_entities.dart';

/// Displays a line chart of accuracy trends over time
class AccuracyTrendChart extends StatelessWidget {
  const AccuracyTrendChart({super.key, 
    required this.dailyReports,
    this.height = 300,
  });

  final List<DailyReport> dailyReports;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (dailyReports.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No data available',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ),
      );
    }

    // Sort by date and limit to last 30 days
    final sorted = List<DailyReport>.from(dailyReports)
      ..sort((a, b) => a.date.compareTo(b.date));
    final limited = sorted.length > 30
        ? sorted.sublist(sorted.length - 30)
        : sorted;

    // Create spots for the line chart
    final spots = <FlSpot>[];
    for (var i = 0; i < limited.length; i++) {
      spots.add(
        FlSpot(i.toDouble(), limited[i].accuracy),
      );
    }

    final minAccuracy =
        limited.map((r) => r.accuracy).reduce((a, b) => a < b ? a : b);
    final maxAccuracy =
        limited.map((r) => r.accuracy).reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'Accuracy Trend (${limited.length} days)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.only(right: 16, bottom: 16, left: 8),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey[200],
                      strokeWidth: 1,
                    ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (limited.length / 5).ceil().toDouble(),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= limited.length) {
                          return const SizedBox.shrink();
                        }
                        // Parse date string (format: YYYY-MM-DD)
                        final dateObj = DateTime.parse(limited[index].date);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${dateObj.month}-${dateObj.day}'.padLeft(5, '0'),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}%',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      reservedSize: 40,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(
                      color: Colors.grey[300]!,
                    ),
                    bottom: BorderSide(
                      color: Colors.grey[300]!,
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withOpacity(0.8),
                        Colors.cyan.withOpacity(0.8),
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                          radius: 4,
                          color: Colors.blue,
                          strokeWidth: 0,
                        ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(0.2),
                          Colors.cyan.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ],
                minY: (minAccuracy - 5).clamp(0, 100).toDouble(),
                maxY: (maxAccuracy + 5).clamp(0, 100).toDouble(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
