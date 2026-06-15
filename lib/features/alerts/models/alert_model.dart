import 'package:cloud_firestore/cloud_firestore.dart';

class AlertModel {
  final String id;
  final String type;
  final String message;
  final String severity; // low / medium / high
  final bool read;
  final DateTime? createdAt;

  AlertModel({
    required this.id,
    required this.type,
    required this.message,
    required this.severity,
    required this.read,
    this.createdAt,
  });

  factory AlertModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AlertModel(
      id: doc.id,
      type: data['type'] ?? 'usage',
      message: data['message'] ?? '',
      severity: data['severity'] ?? 'medium',
      read: data['read'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
