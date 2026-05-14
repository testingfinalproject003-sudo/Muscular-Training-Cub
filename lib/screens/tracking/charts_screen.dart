import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/animated_background.dart';
import '../../providers/progress_provider.dart';
import '../../providers/auth_provider.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      context.read<ProgressProvider>().loadProgressData(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressProvider = context.watch<ProgressProvider>();
    final weightLogs = progressProvider.weightLogs;
    final workoutLogs = progressProvider.workoutLogs;

    // Build real weight chart data
    final weightSpots = <FlSpot>[];
    for (int i = 0; i < weightLogs.length; i++) {
      weightSpots.add(FlSpot(i.toDouble(), weightLogs[i].weight));
    }
    // Fallback demo data if no logs yet
    if (weightSpots.isEmpty) {
      weightSpots.addAll([
        const FlSpot(0, 75), const FlSpot(1, 74.2), const FlSpot(2, 73.8),
        const FlSpot(3, 73.1), const FlSpot(4, 72.5), const FlSpot(5, 72.0),
        const FlSpot(6, 71.5),
      ]);
    }

    // Build real calorie chart data (last 7 workouts)
    final calorieSpots = <FlSpot>[];
    final recentLogs = workoutLogs.take(7).toList().reversed.toList();
    for (int i = 0; i < recentLogs.length; i++) {
      calorieSpots.add(FlSpot(i.toDouble(), recentLogs[i].caloriesBurned));
    }
    if (calorieSpots.isEmpty) {
      calorieSpots.addAll([
        const FlSpot(0, 320), const FlSpot(1, 450), const FlSpot(2, 280),
        const FlSpot(3, 510), const FlSpot(4, 390), const FlSpot(5, 620),
        const FlSpot(6, 340),
      ]);
    }

    // Weekly frequency real data
    final dayCounts = [0, 0, 0, 0, 0, 0, 0];
    for (final log in workoutLogs) {
      final day = log.date.weekday - 1; // 0=Mon
      if (day >= 0 && day < 7) dayCounts[day]++;
    }

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
          title: Text('Analytics', style: AppTextStyles.headingSmall),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => _loadData(),
            color: AppColors.glowColor,
            backgroundColor: AppColors.secondaryBackground,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Weight History
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Weight History', style: AppTextStyles.headingSmall),
                      if (weightLogs.isNotEmpty)
                        Text(
                          '${weightLogs.length} entries',
                          style: AppTextStyles.bodySmall,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GlassCard(
                    height: 250,
                    padding: const EdgeInsets.all(16),
                    child: weightLogs.isEmpty
                        ? _buildEmptyState('No weight data yet')
                        : LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 2,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.white.withValues(alpha: 0.1),
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
                                        '${value.toInt()}',
                                        style: AppTextStyles.bodySmall,
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    getTitlesWidget: (value, meta) {
                                      final idx = value.toInt();
                                      if (idx >= 0 && idx < weightLogs.length) {
                                        return Text(
                                          DateFormat('MM/dd').format(weightLogs[idx].date),
                                          style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: weightSpots,
                                  isCurved: true,
                                  gradient: const LinearGradient(
                                    colors: [AppColors.accentPurple, AppColors.glowColor],
                                  ),
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, percent, bar, index) {
                                      return FlDotCirclePainter(
                                        radius: 4,
                                        color: AppColors.glowColor,
                                        strokeWidth: 2,
                                        strokeColor: Colors.white,
                                      );
                                    },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.accentPurple.withValues(alpha: 0.3),
                                        AppColors.accentPurple.withValues(alpha: 0.0),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Weekly Workout Frequency
                  Text('Weekly Workout Frequency', style: AppTextStyles.headingSmall),
                  const SizedBox(height: 12),
                  GlassCard(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    child: BarChart(
                      BarChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.white.withValues(alpha: 0.1),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                                return Text(
                                  days[value.toInt()],
                                  style: AppTextStyles.bodySmall,
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}',
                                  style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(7, (index) {
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: dayCounts[index].toDouble(),
                                gradient: const LinearGradient(
                                  colors: [AppColors.accentPurple, AppColors.glowColor],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                width: 20,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Calorie Burn History
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Calorie Burn History', style: AppTextStyles.headingSmall),
                      if (workoutLogs.isNotEmpty)
                        Text(
                          '${workoutLogs.length} workouts',
                          style: AppTextStyles.bodySmall,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GlassCard(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    child: workoutLogs.isEmpty
                        ? _buildEmptyState('No workout data yet')
                        : LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.white.withValues(alpha: 0.1),
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
                                        '${value.toInt()}',
                                        style: AppTextStyles.bodySmall,
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    getTitlesWidget: (value, meta) {
                                      final idx = value.toInt();
                                      if (idx >= 0 && idx < recentLogs.length) {
                                        return Text(
                                          DateFormat('MM/dd').format(recentLogs[idx].date),
                                          style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: calorieSpots,
                                  isCurved: true,
                                  gradient: const LinearGradient(
                                    colors: [AppColors.warning, AppColors.error],
                                  ),
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, percent, bar, index) {
                                      return FlDotCirclePainter(
                                        radius: 4,
                                        color: AppColors.warning,
                                        strokeWidth: 2,
                                        strokeColor: Colors.white,
                                      );
                                    },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.warning.withValues(alpha: 0.3),
                                        AppColors.warning.withValues(alpha: 0.0),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 40,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}