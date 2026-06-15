import 'package:cloud_firestore/cloud_firestore.dart';

class HomeSetupModel {
  final String homeType;
  final int peopleCount;
  final double monthlyBudget;
  final double unitPrice;

  HomeSetupModel({
    required this.homeType,
    required this.peopleCount,
    required this.monthlyBudget,
    required this.unitPrice,
  });

  Map<String, dynamic> toFirestore() => {
    'homeType': homeType,
    'peopleCount': peopleCount,
    'monthlyBudget': monthlyBudget,
    'unitPrice': unitPrice,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  factory HomeSetupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return HomeSetupModel(
      homeType: data['homeType'] ?? 'apartment',
      peopleCount: (data['peopleCount'] as int?) ?? 1,
      monthlyBudget: (data['monthlyBudget'] as num?)?.toDouble() ?? 5000,
      unitPrice: (data['unitPrice'] as num?)?.toDouble() ?? 15,
    );
  }
}
