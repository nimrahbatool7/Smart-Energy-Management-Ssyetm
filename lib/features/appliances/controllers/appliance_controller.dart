import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../models/appliance_model.dart';
import 'package:flutter/material.dart';

class ApplianceController extends GetxController {
  // Mock data for initial appliances
  var appliances = <ApplianceModel>[
    ApplianceModel(
      id: '1',
      name: 'AC',
      category: 'Cooling',
      wattage: '1500W',
      usageHours: '8 hrs/day',
      status: 'High Usage',
      statusColor: VioraColors.dangerRed,
      fallbackIcon: Icons.ac_unit,
      imageAsset: 'assets/appliances/ac.png',
    ),
    ApplianceModel(
      id: '2',
      name: 'Fridge',
      category: 'Kitchen',
      wattage: '400W',
      usageHours: '24 hrs/day',
      status: 'Normal',
      statusColor: VioraColors.savingGreen,
      fallbackIcon: Icons.kitchen,
      imageAsset: 'assets/appliances/fridge.png',
    ),
    ApplianceModel(
      id: '3',
      name: 'TV',
      category: 'Entertainment',
      wattage: '200W',
      usageHours: '4 hrs/day',
      status: 'Normal',
      statusColor: VioraColors.savingGreen,
      fallbackIcon: Icons.tv,
      imageAsset: 'assets/appliances/tv.png',
    ),
    ApplianceModel(
      id: '4',
      name: 'Washing Machine',
      category: 'Laundry',
      wattage: '1000W',
      usageHours: '1 hr/day',
      status: 'Normal',
      statusColor: VioraColors.energyGlow,
      fallbackIcon: Icons.local_laundry_service,
      imageAsset: 'assets/appliances/washing_machine.png',
    ),
    ApplianceModel(
      id: '5',
      name: 'Lights',
      category: 'Lighting',
      wattage: '15W',
      usageHours: '6 hrs/day',
      status: 'Normal',
      statusColor: VioraColors.savingGreen,
      fallbackIcon: Icons.lightbulb,
      imageAsset: 'assets/appliances/light.png',
    ),
  ].obs;

  void addAppliance(ApplianceModel appliance) {
    appliances.add(appliance);
    // Automatically triggers update to Obx listeners
  }
}
