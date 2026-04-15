import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:word_pedometer/features/analytics/domain/entities/analytics_entities.dart';
import 'package:word_pedometer/features/grammar_checker/domain/entities/grammar_mistake.dart';

/// Displays a bar chart of top error types by frequency
class ErrorFrequencyChart extends StatelessWidget {
  const ErrorFrequencyChart({
    required this.errorPatterns,
    this.height = 300,
    this.maxBars = 5,
  });

  final List<ErrorPattern> errorPatterns;
  final double height;
  final int maxBars;

  @override
  Widget build(BuildContext context) {
    if (errorPatterns.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No error data available',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ),
      );
    }

    // Get top N error patterns
    final topPatterns = errorPatterns.length > maxBars
        ? errorPatterns.sublist(0, maxBars)
        : errorPatterns;

    // Create bars for the chart
    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < topPatterns.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: topPatterns[i].occurrences.toDouble(),
              color: _getColorForIndex(i),
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
          ],
        ),
      );
    }

    final maxY = topPatterns
        .map((p) => p.occurrences)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'Top Error Types',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.only(right: 16, bottom: 16, left: 8),
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxY / 5).ceil().toDouble(),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[200],
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= topPatterns.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            topPatterns[index].errorType.shortName,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                    bottom: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                ),
                barGroups: barGroups,
                maxY: maxY + (maxY * 0.1),
              ),
            ),
          ),
        ),
        // Legend
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Wrap(
            spacing: 16,
            runSpacing: 8,
            children: List.generate(topPatterns.length, (index) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getColorForIndex(index),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    topPatterns[index].errorType.displayName,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    ' (${topPatterns[index].frequency.toStringAsFixed(1)}%)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Color _getColorForIndex(int index) {
    const colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.purple,
    ];
    return colors[index % colors.length];
  }
}
