import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appliance_model.dart';

class ApplianceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference _appliancesRef(String uid) =>
      _db.collection('users').doc(uid).collection('appliances');

  // ─── Real-time Stream ─────────────────────────────────────────────────────
  Stream<List<ApplianceModel>> watchAppliances(String uid) {
    return _appliancesRef(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ApplianceModel.fromFirestore(doc))
            .toList());
  }

  // ─── Add Appliance ────────────────────────────────────────────────────────
  Future<void> addAppliance(String uid, ApplianceModel appliance) async {
    await _appliancesRef(uid).add(appliance.toFirestore());
  }

  // ─── Update Appliance ─────────────────────────────────────────────────────
  Future<void> updateAppliance(String uid, String id, Map<String, dynamic> data) async {
    await _appliancesRef(uid).doc(id).update(data);
  }

  // ─── Delete Appliance ─────────────────────────────────────────────────────
  Future<void> deleteAppliance(String uid, String id) async {
    await _appliancesRef(uid).doc(id).delete();
  }
}
