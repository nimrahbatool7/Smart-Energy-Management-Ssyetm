import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../app/routes.dart';
import '../../../features/auth/services/auth_service.dart';
import '../models/appliance_model.dart';
import '../services/appliance_service.dart';
import 'add_appliance_screen.dart';
import 'appliance_detail.dart';

class AppliancesScreen extends StatelessWidget {
  const AppliancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = Get.find<AuthService>().uid;
    final service = ApplianceService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appliances'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: VioraColors.energyGlow),
            onPressed: uid == null || uid.isEmpty
                ? null
                : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddApplianceScreen())),
          ),
        ],
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
          if (uid == null || uid.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 64, color: VioraColors.energyGlow),
                  const SizedBox(height: 16),
                  const Text(
                    'Please sign in to view your appliances',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Get.offAllNamed(AppRoutes.login),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VioraColors.energyGlow,
                      foregroundColor: VioraColors.primaryBackground,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Go to Login', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )
          else
            StreamBuilder<List<ApplianceModel>>(
              stream: service.watchAppliances(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: VioraColors.energyGlow));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                }
                final appliances = snapshot.data ?? [];
                if (appliances.isEmpty) {
                  return _buildEmptyState(context);
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: appliances.length,
                  itemBuilder: (context, index) => _buildApplianceCard(context, appliances[index]),
                );
              },
            ),
        ],
      ),
      floatingActionButton: uid == null || uid.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddApplianceScreen())),
              backgroundColor: VioraColors.energyGlow,
              child: const Icon(Icons.add, color: VioraColors.primaryBackground),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.electrical_services, size: 72, color: VioraColors.energyGlow.withValues(alpha: 0.4)),
          const SizedBox(height: 24),
          const Text('No Appliances Yet', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Add your first appliance to start\ntracking your energy usage', style: TextStyle(color: VioraColors.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddApplianceScreen())),
            icon: const Icon(Icons.add),
            label: const Text('Add Appliance'),
            style: ElevatedButton.styleFrom(backgroundColor: VioraColors.energyGlow, foregroundColor: VioraColors.primaryBackground),
          ),
        ],
      ),
    );
  }

  Widget _buildApplianceCard(BuildContext context, ApplianceModel appliance) {
    return GlassCard(
      glowColor: appliance.statusColor,
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ApplianceDetailScreen(name: appliance.name, icon: appliance.fallbackIcon)));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 3D Asset Image with fallback to icon
          SizedBox(
            height: 48,
            width: 48,
            child: Image.asset(
              appliance.imageAsset,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: VioraColors.glassBackground,
                    shape: BoxShape.circle,
                    border: Border.all(color: appliance.statusColor),
                  ),
                  child: Icon(appliance.fallbackIcon, color: Colors.white, size: 28),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(appliance.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text('${appliance.wattage} • ${appliance.usageHours}', style: const TextStyle(color: VioraColors.textSecondary, fontSize: 11)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: appliance.statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: appliance.statusColor.withValues(alpha: 0.5)),
            ),
            child: Text(
              appliance.status,
              style: TextStyle(color: appliance.statusColor, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
