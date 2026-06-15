import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/glass_card.dart';
import '../auth/services/auth_service.dart';
import 'usage_service.dart';
import '../appliances/screens/add_appliance_screen.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = Get.find<AuthService>().uid;

    if (uid == null || uid.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('Please sign in to view analytics', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final usageService = UsageService();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Energy Analytics'),
          bottom: const TabBar(
            indicatorColor: VioraColors.energyGlow,
            labelColor: VioraColors.energyGlow,
            unselectedLabelColor: VioraColors.textSecondary,
            tabs: [
              Tab(text: 'Daily'),
              Tab(text: 'Weekly'),
              Tab(text: 'Monthly'),
            ],
          ),
        ),
        body: Stack(
          children: [
            // Background Gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0A2540), VioraColors.primaryBackground],
                ),
              ),
            ),
            StreamBuilder<List<UsageLogModel>>(
              stream: usageService.watchUsageLogs(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: VioraColors.energyGlow));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                }

                final logs = snapshot.data ?? [];
                if (logs.isEmpty) {
                  return _buildEmptyState(context);
                }

                return TabBarView(
                  children: [
                    _buildDailyTab(context, logs),
                    _buildWeeklyTab(context, logs),
                    _buildMonthlyTab(context, logs),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: VioraColors.energyGlow.withValues(alpha: 0.05),
                border: Border.all(color: VioraColors.energyGlow.withValues(alpha: 0.2), width: 2),
              ),
              child: const Icon(Icons.bar_chart_rounded, size: 64, color: VioraColors.energyGlow),
            ),
            const SizedBox(height: 24),
            const Text(
              'No usage data yet',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add appliances to start tracking your energy usage and bills.',
              textAlign: TextAlign.center,
              style: TextStyle(color: VioraColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddApplianceScreen())),
              style: ElevatedButton.styleFrom(
                backgroundColor: VioraColors.energyGlow,
                foregroundColor: VioraColors.primaryBackground,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Add Appliance', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTab(BuildContext context, List<UsageLogModel> logs) {
    // Filter logs for today
    final now = DateTime.now();
    final todayLogs = logs.where((log) =>
        log.date.year == now.year &&
        log.date.month == now.month &&
        log.date.day == now.day).toList();

    double totalKwh = 0.0;
    double totalCost = 0.0;

    for (var log in todayLogs) {
      totalKwh += log.dailyKwh;
      totalCost += log.dailyCost;
    }

    // Fallback if no logs today (show latest)
    if (todayLogs.isEmpty && logs.isNotEmpty) {
      totalKwh = logs.first.dailyKwh;
      totalCost = logs.first.dailyCost;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Today\'s Energy Consumed', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GlassCard(
            glowColor: VioraColors.energyGlow,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.bolt, color: VioraColors.energyGlow, size: 48),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${totalKwh.toStringAsFixed(2)} kWh', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    const Text('Total Consumption', style: TextStyle(color: VioraColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Estimated Cost', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GlassCard(
            glowColor: VioraColors.warningOrange,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.monetization_on_outlined, color: VioraColors.warningOrange, size: 48),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Rs ${totalCost.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    const Text('Based on unit tariff', style: TextStyle(color: VioraColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTab(BuildContext context, List<UsageLogModel> logs) {
    // Get last 7 days of data
    final Map<int, double> weekdayUsage = {1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0, 5: 0.0, 6: 0.0, 7: 0.0};
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    for (var log in logs) {
      if (log.date.isAfter(sevenDaysAgo)) {
        final day = log.date.weekday;
        weekdayUsage[day] = (weekdayUsage[day] ?? 0.0) + log.dailyKwh;
      }
    }

    final barGroups = weekdayUsage.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: VioraColors.energyGlow,
            width: 14,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 20,
              color: VioraColors.glassBorder.withValues(alpha: 0.1),
            ),
          ),
        ],
      );
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weekly Energy Trend (kWh)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          GlassCard(
            height: 260,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          final index = value.toInt() - 1;
                          if (index >= 0 && index < weekdays.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(weekdays[index], style: const TextStyle(color: VioraColors.textSecondary, fontSize: 10)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTab(BuildContext context, List<UsageLogModel> logs) {
    double monthlyKwh = 0.0;
    double monthlyCost = 0.0;

    // Sum last 30 days of data
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    for (var log in logs) {
      if (log.date.isAfter(thirtyDaysAgo)) {
        monthlyKwh += log.dailyKwh;
        monthlyCost += log.dailyCost;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Monthly Total Summary', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GlassCard(
            glowColor: VioraColors.savingGreen,
            child: Column(
              children: [
                _buildSummaryRow('Total Consumption', '${monthlyKwh.toStringAsFixed(1)} kWh', VioraColors.energyGlow),
                const Divider(color: VioraColors.glassBorder, height: 24),
                _buildSummaryRow('Estimated Bill', 'Rs ${monthlyCost.toStringAsFixed(0)}', VioraColors.savingGreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: VioraColors.textSecondary, fontSize: 14)),
        Text(value, style: TextStyle(color: valueColor, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
