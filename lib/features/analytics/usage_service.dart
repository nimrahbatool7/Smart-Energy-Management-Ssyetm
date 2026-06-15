import 'package:cloud_firestore/cloud_firestore.dart';

class UsageLogModel {
  final String id;
  final String applianceId;
  final String applianceName;
  final DateTime date;
  final double dailyKwh;
  final double dailyCost;

  UsageLogModel({
    required this.id,
    required this.applianceId,
    required this.applianceName,
    required this.date,
    required this.dailyKwh,
    required this.dailyCost,
  });

  factory UsageLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final Timestamp? ts = data['date'] as Timestamp?;
    return UsageLogModel(
      id: doc.id,
      applianceId: data['applianceId'] ?? '',
      applianceName: data['applianceName'] ?? 'Unknown',
      date: ts?.toDate() ?? DateTime.now(),
      dailyKwh: (data['dailyKwh'] as num?)?.toDouble() ?? 0.0,
      dailyCost: (data['dailyCost'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class UsageService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<UsageLogModel>> watchUsageLogs(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('usageLogs')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UsageLogModel.fromFirestore(doc))
            .toList());
  }
}
