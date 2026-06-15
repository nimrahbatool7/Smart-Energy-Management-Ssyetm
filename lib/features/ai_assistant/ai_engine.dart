import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/services/auth_service.dart';
import 'package:get/get.dart';

class AiEngine {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> evaluateRulesAndGenerateInsights() async {
    final uid = Get.find<AuthService>().uid;
    if (uid == null || uid.isEmpty) return;

    // 1. Get user configuration (budget, unit price)
    final userSnap = await _db.collection('users').doc(uid).get();
    if (!userSnap.exists) return;

    final userData = userSnap.data() ?? {};
    final double budget = (userData['monthlyBudget'] as num?)?.toDouble() ?? 5000.0;
    
    // 2. Get appliances
    final appliancesSnap = await _db.collection('users').doc(uid).collection('appliances').get();
    final appliances = appliancesSnap.docs;

    double totalDailyKwh = 0.0;
    double totalMonthlyCost = 0.0;
    final Map<String, double> applianceKwhMap = {};
    final List<Map<String, dynamic>> rulesMatched = [];

    for (var doc in appliances) {
      final data = doc.data();
      final name = data['name'] ?? 'Unknown';
      final double wattage = (data['wattage'] as num?)?.toDouble() ?? 0.0;
      final double hours = (data['dailyUsageHours'] as num?)?.toDouble() ?? 0.0;
      final int quantity = (data['quantity'] as int?) ?? 1;

      final double dailyKwh = (wattage * hours * quantity) / 1000.0;
      final double monthlyCost = (data['computedMonthlyCost'] as num?)?.toDouble() ?? 0.0;

      totalDailyKwh += dailyKwh;
      totalMonthlyCost += monthlyCost;
      applianceKwhMap[name] = dailyKwh;

      // Rule 1: High appliance usage (> 8 hours)
      if (hours > 8) {
        rulesMatched.add({
          'type': 'warning',
          'message': 'Your $name usage is higher than normal (${hours.toStringAsFixed(0)} hours/day). Consider reducing it.',
        });
      }
    }

    // Rule 2: Estimated monthly bill exceeds budget
    if (totalMonthlyCost > budget) {
      rulesMatched.add({
        'type': 'budget',
        'message': 'Your estimated monthly bill (Rs ${totalMonthlyCost.toStringAsFixed(0)}) exceeds your budget limit (Rs ${budget.toStringAsFixed(0)}).',
      });
    }

    // Rule 3: Appliance contributes > 40% of total energy
    applianceKwhMap.forEach((name, kwh) {
      if (totalDailyKwh > 0 && (kwh / totalDailyKwh) > 0.4) {
        rulesMatched.add({
          'type': 'optimization',
          'message': '$name is your highest energy consuming appliance, contributing ${((kwh / totalDailyKwh) * 100).toStringAsFixed(0)}% of your daily usage.',
        });
      }
    });

    // Write new insights to Firestore
    final insightsCol = _db.collection('users').doc(uid).collection('insights');

    // Get existing insights to avoid duplicates
    final existingSnap = await insightsCol.get();
    final existingMessages = existingSnap.docs.map((doc) => doc.data()['message'] as String?).toSet();

    for (var rule in rulesMatched) {
      final msg = rule['message'];
      if (!existingMessages.contains(msg)) {
        await insightsCol.add({
          'type': rule['type'],
          'message': msg,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Stream<QuerySnapshot> watchInsights(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('insights')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
