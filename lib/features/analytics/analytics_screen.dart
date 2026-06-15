import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/glass_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0A2540), VioraColors.primaryBackground],
                ),
              ),
            ),
            TabBarView(
              children: [
                _buildTabContent(context, 'Daily Energy Wave'),
                _buildTabContent(context, 'Weekly Energy Trend'),
                _buildTabContent(context, 'Monthly Energy Comparison'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, String chartTitle) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(chartTitle, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GlassCard(
            height: 250,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.waves, color: VioraColors.energyGlow, size: 60),
                  const SizedBox(height: 8),
                  Text('[Animated Wave Graph Here]', style: TextStyle(color: VioraColors.textSecondary.withValues(alpha: 0.5))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          const Text('Appliance Contribution', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              children: [
                _buildContributionBar('AC', 0.45, VioraColors.dangerRed),
                const SizedBox(height: 12),
                _buildContributionBar('Fridge', 0.20, VioraColors.warningOrange),
                const SizedBox(height: 12),
                _buildContributionBar('Fans', 0.15, VioraColors.energyGlow),
                const SizedBox(height: 12),
                _buildContributionBar('Lights', 0.10, VioraColors.savingGreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributionBar(String name, double percentage, Color color) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(name, style: const TextStyle(color: Colors.white))),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: VioraColors.glassBorder,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(width: 40, child: Text('${(percentage * 100).toInt()}%', style: const TextStyle(color: VioraColors.textSecondary))),
      ],
    );
  }
}
