import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/glass_card.dart';
import '../auth/services/auth_service.dart';
import 'services/alert_service.dart';
import 'models/alert_model.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final alertService = AlertService();
    final uid = authService.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Energy Alerts')),
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
          if (uid == null)
            const Center(
              child: Text(
                'Please sign in to view alerts',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
          else
            StreamBuilder<List<AlertModel>>(
              stream: alertService.watchAlerts(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: VioraColors.energyGlow));
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: VioraColors.dangerRed),
                    ),
                  );
                }

                final alerts = snapshot.data ?? [];

                if (alerts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none, size: 64, color: Colors.white.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        const Text(
                          'No active alerts',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your home energy usage looks stable.',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    final alert = alerts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildAlertCard(context, alert, uid, alertService),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, AlertModel alert, String uid, AlertService service) {
    Color severityColor;
    String titlePrefix;

    switch (alert.severity.toLowerCase()) {
      case 'high':
        severityColor = VioraColors.dangerRed;
        titlePrefix = '🚨 High Consumption';
        break;
      case 'medium':
        severityColor = VioraColors.warningOrange;
        titlePrefix = '⚠️ Energy Warning';
        break;
      case 'low':
      default:
        severityColor = VioraColors.savingGreen;
        titlePrefix = '💡 Optimal Usage';
        break;
    }

    return GlassCard(
      glowColor: alert.read ? Colors.transparent : severityColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    alert.read ? Icons.notifications_none : Icons.notifications_active,
                    color: alert.read ? Colors.white.withValues(alpha: 0.5) : severityColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    titlePrefix,
                    style: TextStyle(
                      color: alert.read ? Colors.white.withValues(alpha: 0.7) : severityColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              if (!alert.read)
                GestureDetector(
                  onTap: () => service.markRead(uid, alert.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: severityColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Mark Read',
                      style: TextStyle(color: severityColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            alert.message,
            style: TextStyle(
              color: alert.read ? Colors.white.withValues(alpha: 0.6) : Colors.white,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          if (alert.createdAt != null)
            Text(
              _formatDate(alert.createdAt!),
              style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
