import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:word_pedometer/features/analytics/domain/entities/analytics_entities.dart';
import 'package:word_pedometer/features/grammar_checker/domain/entities/grammar_mistake.dart';

/// Displays a pie chart of error type distribution
class ErrorDistributionChart extends StatefulWidget {
  const ErrorDistributionChart({
    required this.errorPatterns,
    this.height = 300,
  });

  final List<ErrorPattern> errorPatterns;
  final double height;

  @override
  State<ErrorDistributionChart> createState() => _ErrorDistributionChartState();
}

class _ErrorDistributionChartState extends State<ErrorDistributionChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.errorPatterns.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            'No error data available',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ),
      );
    }

    // Create sections for the pie chart
    final sections = <PieChartSectionData>[];
    for (int i = 0; i < widget.errorPatterns.length; i++) {
      final pattern = widget.errorPatterns[i];
      final isSelected = touchedIndex == i;

      sections.add(
        PieChartSectionData(
          color: _getColorForIndex(i),
          value: pattern.frequency,
          title: isSelected ? '${pattern.frequency.toStringAsFixed(1)}%' : '',
          radius: isSelected ? 110 : 90,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          badgeWidget: isSelected
              ? _Badge(
                  pattern.errorType.shortName,
                  _getColorForIndex(i),
                  i,
                )
              : null,
          badgePositionPercentageOffset: 0.98,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'Error Distribution',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: widget.height,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
            ),
          ),
        ),
        // Legend
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            children: List.generate(widget.errorPatterns.length, (index) {
              final pattern = widget.errorPatterns[index];
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
                    pattern.errorType.displayName,
                    style: Theme.of(context).textTheme.bodySmall,
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
      Colors.teal,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final int index;

  const _Badge(this.text, this.backgroundColor, this.index);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
