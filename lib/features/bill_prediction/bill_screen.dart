import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/glass_card.dart';

class BillPredictionScreen extends StatelessWidget {
  const BillPredictionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Future Bill Prediction')),
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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 32),
                
                // Main Prediction Card
                Center(
                  child: GlassCard(
                    glowColor: VioraColors.energyGlow,
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        const Text('Estimated Bill', style: TextStyle(color: VioraColors.textSecondary, fontSize: 18)),
                        const SizedBox(height: 16),
                        // Simulated Number Counter Animation
                        Text(
                          'Rs 8500',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 48,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Range: 8000 - 9000',
                          style: TextStyle(color: VioraColors.energyGlow, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                
                // Comparison Card
                GlassCard(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Last Month:', style: TextStyle(color: VioraColors.textSecondary, fontSize: 16)),
                          const Text('Rs 7000', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: VioraColors.glassBorder),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Increase:', style: TextStyle(color: VioraColors.textSecondary, fontSize: 16)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: VioraColors.dangerRed.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: VioraColors.dangerRed.withValues(alpha: 0.5)),
                            ),
                            child: const Text('+21%', style: TextStyle(color: VioraColors.dangerRed, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // AI Suggestion
                GlassCard(
                  glowColor: VioraColors.warningOrange,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.psychology, color: VioraColors.warningOrange, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('AI Prediction Analysis', style: TextStyle(color: VioraColors.warningOrange, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text(
                              'The projected increase is mainly due to higher AC usage during the afternoon. Consider using the fan between 2 PM and 4 PM to keep the bill under Rs 8000.',
                              style: TextStyle(color: Colors.white, height: 1.5),
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
}
