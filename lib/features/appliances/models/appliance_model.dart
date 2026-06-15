import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class ApplianceModel {
  final String id;
  final String name;
  final String category;
  final String wattage;
  final String usageHours;
  final String status;
  final Color statusColor;
  final IconData fallbackIcon;
  final String imageAsset;
  // Firestore calculation fields
  final double wattageNum;
  final double dailyHours;
  final int quantity;

  ApplianceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.wattage,
    required this.usageHours,
    required this.status,
    required this.statusColor,
    required this.fallbackIcon,
    required this.imageAsset,
    this.wattageNum = 0,
    this.dailyHours = 0,
    this.quantity = 1,
  });

  // ─── Serialize to Firestore ───────────────────────────────────────────────
  Map<String, dynamic> toFirestore() => {
    'name': name,
    'category': category,
    'wattage': wattageNum,
    'quantity': quantity,
    'dailyUsageHours': dailyHours,
    'status': status,
    'imageAsset': imageAsset,
    'createdAt': FieldValue.serverTimestamp(),
  };

  // ─── Deserialize from Firestore ───────────────────────────────────────────
  factory ApplianceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final double w = (data['wattage'] as num?)?.toDouble() ?? 0;
    final double h = (data['dailyUsageHours'] as num?)?.toDouble() ?? 0;
    final int q = (data['quantity'] as int?) ?? 1;
    final String status = data['status'] ?? 'Normal';

    return ApplianceModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      wattage: '${w.toInt()}W',
      usageHours: '${h.toInt()} hrs/day',
      status: status,
      statusColor: status == 'High Usage' ? VioraColors.dangerRed : VioraColors.savingGreen,
      fallbackIcon: _iconForCategory(data['category'] ?? ''),
      imageAsset: data['imageAsset'] ?? '',
      wattageNum: w,
      dailyHours: h,
      quantity: q,
    );
  }

  static IconData _iconForCategory(String category) {
    switch (category) {
      case 'Cooling': return Icons.ac_unit;
      case 'Lighting': return Icons.lightbulb;
      case 'Kitchen': return Icons.kitchen;
      case 'Entertainment': return Icons.tv;
      case 'Laundry': return Icons.local_laundry_service;
      default: return Icons.electrical_services;
    }
  }
}
