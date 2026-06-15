import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/energy_meter.dart';
import '../alerts/alert_screen.dart';
import '../bill_prediction/bill_screen.dart';
import '../auth/services/auth_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = Get.find<AuthService>().uid;

    if (uid == null || uid.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            'Please sign in to view your dashboard',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

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
          
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: VioraColors.energyGlow));
              }

              final userData = userSnapshot.data?.data() as Map<String, dynamic>? ?? {};
              final name = userData['name'] ?? 'User';
              final profileImage = userData['profileImage'] ?? '';
              final double monthlyBudget = (userData['monthlyBudget'] as num?)?.toDouble() ?? 5000.0;
              final double unitPrice = (userData['unitPrice'] as num?)?.toDouble() ?? 15.0;

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('appliances')
                    .snapshots(),
                builder: (context, appliancesSnapshot) {
                  double todayKwh = 0.0;
                  double estBill = 0.0;

                  if (appliancesSnapshot.hasData) {
                    for (var doc in appliancesSnapshot.data!.docs) {
                      final appData = doc.data() as Map<String, dynamic>? ?? {};
                      final kwh = (appData['computedDailyKwh'] as num?)?.toDouble() ?? 0.0;
                      final cost = (appData['computedMonthlyCost'] as num?)?.toDouble() ?? 0.0;
                      todayKwh += kwh;
                      estBill += cost;
                    }
                  }

                  // Target daily kWh based on budget and unit price
                  final dailyTargetKwh = (monthlyBudget / unitPrice) / 30.0;
                  final percentage = dailyTargetKwh > 0 ? (todayKwh / dailyTargetKwh).clamp(0.0, 1.0) : 0.0;

                  // Save potential (e.g. 15% optimization potential)
                  final savingPotential = estBill * 0.15;

                  return SafeArea(
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
                                  const Text('Good Morning,', style: TextStyle(color: VioraColors.textSecondary, fontSize: 16)),
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: VioraColors.glassBackground,
                                backgroundImage: (profileImage.isNotEmpty)
                                    ? NetworkImage(profileImage)
                                    : null,
                                child: (profileImage.isEmpty)
                                    ? const Icon(Icons.person, color: VioraColors.energyGlow)
                                    : null,
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          
                          // Main Energy Circle
                          Center(
                            child: EnergyMeter(
                              percentage: percentage,
                              todayKwh: todayKwh,
                              size: 200,
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // AI Insight Banner
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AlertsScreen())),
                            child: GlassCard(
                              glowColor: percentage > 0.8 ? VioraColors.dangerRed : VioraColors.warningOrange,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.smart_toy_rounded,
                                    color: percentage > 0.8 ? VioraColors.dangerRed : VioraColors.warningOrange,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      percentage > 0.8
                                          ? 'Your energy usage is close to exceeding your budget limit. Consider optimizing.'
                                          : 'Your appliances are running optimally. Energy usage is within safe limits.',
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
                                child: _buildStatCard(context, 'Today', todayKwh.toStringAsFixed(1), 'kWh', VioraColors.energyGlow, null),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  'Est. Bill',
                                  'Rs ${estBill.toStringAsFixed(0)}',
                                  '',
                                  VioraColors.warningOrange,
                                  () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const BillPredictionScreen()));
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  'Saving Potential',
                                  'Rs ${savingPotential.toStringAsFixed(0)}',
                                  '',
                                  VioraColors.savingGreen,
                                  null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: GlassCard(
                                  glowColor: VioraColors.savingGreen,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Status', style: TextStyle(color: VioraColors.textSecondary, fontSize: 12)),
                                      const SizedBox(height: 8),
                                      Text(
                                        percentage > 0.8 ? 'Warning' : 'Optimized',
                                        style: TextStyle(
                                          color: percentage > 0.8 ? VioraColors.dangerRed : VioraColors.savingGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
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
                  );
                },
              );
            },
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
            Text(title, style: const TextStyle(color: VioraColors.textSecondary, fontSize: 12)),
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
