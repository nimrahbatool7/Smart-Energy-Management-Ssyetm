import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/glass_card.dart';
// Note: We would import fl_chart here, but simulating it with containers for the UI skeleton
// import 'package:fl_chart/fl_chart.dart';

class ApplianceDetailScreen extends StatelessWidget {
  final String name;
  final IconData icon;

  const ApplianceDetailScreen({super.key, required this.name, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$name Analytics')),
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: VioraColors.glassBackground,
                        shape: BoxShape.circle,
                        border: Border.all(color: VioraColors.energyGlow),
                      ),
                      child: Icon(icon, size: 40, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: Theme.of(context).textTheme.displayMedium),
                        const Text('1500W', style: TextStyle(color: VioraColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                Row(
                  children: [
                    Expanded(child: _buildStatBox('Today', '6 hrs')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatBox('Weekly', '42 hrs')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatBox('Monthly', '180 hrs')),
                  ],
                ),
                const SizedBox(height: 32),
                
                const Text('Usage History', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                GlassCard(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.show_chart, color: VioraColors.energyGlow, size: 48),
                        const SizedBox(height: 8),
                        Text('[Animated Line Chart Here]', style: TextStyle(color: VioraColors.textSecondary.withValues(alpha: 0.5))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                GlassCard(
                  glowColor: VioraColors.energyGlow,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.smart_toy_rounded, color: VioraColors.energyGlow, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Viora AI Insight', style: TextStyle(color: VioraColors.energyGlow, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(
                              'Reducing $name usage by 1 hour daily saves approximately Rs 1200 per month.',
                              style: const TextStyle(color: Colors.white, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String title, String value) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: VioraColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
