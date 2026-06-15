import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/energy_meter.dart';
import '../alerts/alert_screen.dart';
import '../bill_prediction/bill_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Greeting
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Good Morning,', style: Theme.of(context).textTheme.bodyLarge),
                          Text('User', style: Theme.of(context).textTheme.displayMedium),
                        ],
                      ),
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: VioraColors.glassBackground,
                        child: Icon(Icons.person, color: VioraColors.energyGlow),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Main Energy Circle
                  const Center(
                    child: EnergyMeter(
                      percentage: 0.68,
                      size: 200,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // AI Insight Banner
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AlertsScreen())),
                    child: GlassCard(
                      glowColor: VioraColors.warningOrange,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.smart_toy_rounded, color: VioraColors.warningOrange),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Your AC is the highest energy consumer today. Consider turning it off for 1 hour.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(context, 'Today', '8.5', 'kWh', VioraColors.energyGlow, null),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(context, 'Est. Bill', 'Rs 4200', '', VioraColors.warningOrange, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const BillPredictionScreen()));
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(context, 'Saving Potential', 'Rs 800', '', VioraColors.savingGreen, null),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GlassCard(
                          glowColor: VioraColors.savingGreen,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Status', style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 8),
                              const Text('Optimized', style: TextStyle(color: VioraColors.savingGreen, fontWeight: FontWeight.bold, fontSize: 18)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100), // Bottom padding for nav bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, String unit, Color glowColor, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        glowColor: glowColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(unit, style: const TextStyle(color: VioraColors.textSecondary, fontSize: 12)),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}
