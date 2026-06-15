import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/alert_model.dart';

class AlertService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference _alertsRef(String uid) =>
      _db.collection('users').doc(uid).collection('alerts');

  Stream<List<AlertModel>> watchAlerts(String uid) {
    return _alertsRef(uid)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snap) => snap.docs.map((d) => AlertModel.fromFirestore(d)).toList());
  }

  Future<void> markRead(String uid, String alertId) async {
    await _alertsRef(uid).doc(alertId).update({'read': true});
  }
}
