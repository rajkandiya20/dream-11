import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Revenue line chart widget using fl_chart.
class RevenueLineChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  final String title;

  const RevenueLineChart({
    super.key,
    required this.data,
    required this.labels,
    this.title = 'Revenue Trend',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleMedium),
          AppSpacing.gapH16,
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _maxValue / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.border.withOpacity(0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatValue(value),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < labels.length) {
                          return Text(
                            labels[index],
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 10,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(data.length,
                        (i) => FlSpot(i.toDouble(), data[i])),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                ],
                minY: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double get _maxValue =>
      data.isEmpty ? 100 : data.reduce((a, b) => a > b ? a : b);

  String _formatValue(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toStringAsFixed(0);
  }
}

/// Bar chart widget for user registrations or match stats.
class StatsBarChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  final String title;
  final Color barColor;

  const StatsBarChart({
    super.key,
    required this.data,
    required this.labels,
    this.title = 'Statistics',
    this.barColor = AppColors.info,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleMedium),
          AppSpacing.gapH16,
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _maxValue * 1.2,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _maxValue / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.border.withOpacity(0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < labels.length) {
                          return Text(
                            labels[index],
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 10,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(data.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data[i],
                        color: barColor,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double get _maxValue =>
      data.isEmpty ? 100 : data.reduce((a, b) => a > b ? a : b);
}

/// Pie chart widget for distribution visualization.
class DistributionPieChart extends StatelessWidget {
  final Map<String, double> data;
  final String title;

  const DistributionPieChart({
    super.key,
    required this.data,
    this.title = 'Distribution',
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.primary,
      AppColors.info,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
      AppColors.primaryLight,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleMedium),
          AppSpacing.gapH16,
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: data.entries.toList().asMap().entries.map((e) {
                        final color = colors[e.key % colors.length];
                        return PieChartSectionData(
                          value: e.value.value,
                          color: color,
                          radius: 60,
                          titleStyle: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          title:
                              '${e.value.value.toStringAsFixed(0)}%',
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                    ),
                  ),
                ),
                // Legend
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.entries.toList().asMap().entries.map((e) {
                    final color = colors[e.key % colors.length];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            e.value.key,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
