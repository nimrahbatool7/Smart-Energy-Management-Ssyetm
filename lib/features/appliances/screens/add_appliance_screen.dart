import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/neon_button.dart';
import '../../../features/auth/services/auth_service.dart';
import '../models/appliance_model.dart';
import '../services/appliance_service.dart';

class AddApplianceScreen extends StatefulWidget {
  const AddApplianceScreen({super.key});

  @override
  State<AddApplianceScreen> createState() => _AddApplianceScreenState();
}

class _AddApplianceScreenState extends State<AddApplianceScreen> {
  final _applianceService = ApplianceService();
  
  int _currentStep = 0;
  String _selectedCategory = '';
  ApplianceModel? _selectedAppliance;
  bool _submitting = false;
  
  double _hours = 4;
  double _wattage = 1000;
  int _quantity = 1;

  final Map<String, List<ApplianceModel>> _categoryAppliances = {
    'Cooling': [
      ApplianceModel(id: '', name: 'AC', category: 'Cooling', wattage: '1500W', usageHours: '', status: 'Normal', statusColor: VioraColors.energyGlow, fallbackIcon: Icons.ac_unit, imageAsset: 'assets/appliances/ac.png'),
      ApplianceModel(id: '', name: 'Fan', category: 'Cooling', wattage: '75W', usageHours: '', status: 'Normal', statusColor: VioraColors.savingGreen, fallbackIcon: Icons.mode_fan_off, imageAsset: 'assets/appliances/fan.png'),
      ApplianceModel(id: '', name: 'Cooler', category: 'Cooling', wattage: '200W', usageHours: '', status: 'Normal', statusColor: VioraColors.savingGreen, fallbackIcon: Icons.air, imageAsset: 'assets/appliances/cooler.png'),
    ],
    'Lighting': [
      ApplianceModel(id: '', name: 'LED Bulb', category: 'Lighting', wattage: '15W', usageHours: '', status: 'Normal', statusColor: VioraColors.savingGreen, fallbackIcon: Icons.lightbulb, imageAsset: 'assets/appliances/light.png'),
      ApplianceModel(id: '', name: 'Tube Light', category: 'Lighting', wattage: '40W', usageHours: '', status: 'Normal', statusColor: VioraColors.savingGreen, fallbackIcon: Icons.wb_incandescent, imageAsset: 'assets/appliances/tube.png'),
    ],
    'Kitchen': [
      ApplianceModel(id: '', name: 'Fridge', category: 'Kitchen', wattage: '400W', usageHours: '', status: 'Normal', statusColor: VioraColors.savingGreen, fallbackIcon: Icons.kitchen, imageAsset: 'assets/appliances/fridge.png'),
      ApplianceModel(id: '', name: 'Microwave', category: 'Kitchen', wattage: '1200W', usageHours: '', status: 'Normal', statusColor: VioraColors.warningOrange, fallbackIcon: Icons.microwave, imageAsset: 'assets/appliances/microwave.png'),
    ],
    'Entertainment': [
      ApplianceModel(id: '', name: 'TV', category: 'Entertainment', wattage: '200W', usageHours: '', status: 'Normal', statusColor: VioraColors.savingGreen, fallbackIcon: Icons.tv, imageAsset: 'assets/appliances/tv.png'),
      ApplianceModel(id: '', name: 'PC', category: 'Entertainment', wattage: '500W', usageHours: '', status: 'Normal', statusColor: VioraColors.energyGlow, fallbackIcon: Icons.computer, imageAsset: 'assets/appliances/pc.png'),
    ],
    'Laundry': [
      ApplianceModel(id: '', name: 'Washing Machine', category: 'Laundry', wattage: '1000W', usageHours: '', status: 'Normal', statusColor: VioraColors.energyGlow, fallbackIcon: Icons.local_laundry_service, imageAsset: 'assets/appliances/washing_machine.png'),
    ],
  };

  Future<void> _submitAppliance() async {
    if (_selectedAppliance == null) return;
    setState(() => _submitting = true);
    
    final uid = Get.find<AuthService>().uid;
    if (uid == null) {
      Get.snackbar('Error', 'Not logged in', backgroundColor: VioraColors.dangerRed.withValues(alpha: 0.8), colorText: Colors.white);
      return;
    }

    final newAppliance = ApplianceModel(
      id: '',
      name: _selectedAppliance!.name,
      category: _selectedCategory,
      wattage: '${_wattage.toInt()}W',
      usageHours: '${_hours.toInt()} hrs/day',
      status: _hours > 8 ? 'High Usage' : 'Normal',
      statusColor: _hours > 8 ? VioraColors.warningOrange : VioraColors.savingGreen,
      fallbackIcon: _selectedAppliance!.fallbackIcon,
      imageAsset: _selectedAppliance!.imageAsset,
      wattageNum: _wattage,
      dailyHours: _hours,
      quantity: _quantity,
    );

    await _applianceService.addAppliance(uid, newAppliance);
    
    Get.snackbar(
      '✓ Appliance Added',
      '${newAppliance.name} saved to your home',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: VioraColors.savingGreen.withValues(alpha: 0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
    
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Appliance')),
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
          Stepper(
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep == 0 && _selectedCategory.isEmpty) {
                Get.snackbar('Error', 'Please select a category', backgroundColor: VioraColors.dangerRed.withValues(alpha: 0.8), colorText: Colors.white);
                return;
              }
              if (_currentStep == 1 && _selectedAppliance == null) {
                Get.snackbar('Error', 'Please select an appliance', backgroundColor: VioraColors.dangerRed.withValues(alpha: 0.8), colorText: Colors.white);
                return;
              }
              
              if (_currentStep < 2) {
                setState(() => _currentStep++);
              } else {
                _submitAppliance();
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep--);
              } else {
                Navigator.pop(context);
              }
            },
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Row(
                  children: [
                    if (_currentStep < 2)
                      NeonButton(text: 'Next', onPressed: details.onStepContinue!)
                    else
                      NeonButton(
                        text: _submitting ? 'Adding...' : 'Add Appliance', 
                        glowColor: VioraColors.savingGreen, 
                        onPressed: _submitting ? null : details.onStepContinue!,
                      ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: _submitting ? null : details.onStepCancel,
                      child: const Text('Back', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: const Text('Select Category', style: TextStyle(color: Colors.white)),
                content: _buildCategorySelector(),
                isActive: _currentStep >= 0,
              ),
              Step(
                title: const Text('Select Appliance', style: TextStyle(color: Colors.white)),
                content: _buildApplianceSelector(),
                isActive: _currentStep >= 1,
              ),
              Step(
                title: const Text('Details & Usage', style: TextStyle(color: Colors.white)),
                content: _buildUsageDetails(),
                isActive: _currentStep >= 2,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = ['Cooling', 'Lighting', 'Kitchen', 'Entertainment', 'Laundry'];
    final icons = [Icons.ac_unit, Icons.lightbulb, Icons.kitchen, Icons.tv, Icons.local_laundry_service];
    
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = cat;
                _selectedAppliance = null; // Reset appliance selection when category changes
              });
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 12, bottom: 8, top: 8),
              child: GlassCard(
                glowColor: isSelected ? VioraColors.energyGlow : Colors.transparent,
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icons[index], color: isSelected ? VioraColors.energyGlow : Colors.white, size: 32),
                    const SizedBox(height: 8),
                    Text(cat, style: TextStyle(color: isSelected ? VioraColors.energyGlow : Colors.white, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildApplianceSelector() {
    if (_selectedCategory.isEmpty) {
      return const Text('Please select a category first', style: TextStyle(color: VioraColors.textSecondary));
    }
    
    final items = _categoryAppliances[_selectedCategory] ?? [];
    
    return Column(
      children: items.map((app) {
        final isSelected = _selectedAppliance?.name == app.name;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GlassCard(
            glowColor: isSelected ? VioraColors.energyGlow : Colors.transparent,
            onTap: () {
              setState(() {
                _selectedAppliance = app;
                _wattage = double.parse(app.wattage.replaceAll('W', ''));
              });
            },
            child: Row(
              children: [
                SizedBox(
                  height: 40,
                  width: 40,
                  child: Image.asset(
                    app.imageAsset,
                    errorBuilder: (context, error, stackTrace) => Icon(app.fallbackIcon, color: VioraColors.energyGlow),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app.name, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      Text('Avg: ${app.wattage}', style: const TextStyle(color: VioraColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                if (isSelected) const Icon(Icons.check_circle, color: VioraColors.energyGlow),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUsageDetails() {
    if (_selectedAppliance == null) return const SizedBox.shrink();
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildInputCard('Wattage (W)', '${_wattage.toInt()}')),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _quantity++),
                child: _buildInputCard('Quantity', '$_quantity'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Daily Usage Hours: ${_hours.toInt()}h', style: const TextStyle(color: Colors.white)),
              Slider(
                value: _hours,
                min: 1,
                max: 24,
                activeColor: VioraColors.energyGlow,
                onChanged: (val) => setState(() => _hours = val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          glowColor: VioraColors.warningOrange,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Est. Monthly Cost', style: TextStyle(color: VioraColors.textSecondary)),
                  Text('Rs ${((_wattage * _hours * 30 / 1000) * 15 * _quantity).toStringAsFixed(0)}', 
                    style: const TextStyle(color: VioraColors.warningOrange, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Monthly Usage', style: TextStyle(color: VioraColors.textSecondary)),
                  Text('${((_wattage * _hours * 30 / 1000) * _quantity).toStringAsFixed(1)} kWh', 
                    style: const TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputCard(String label, String value) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: VioraColors.textSecondary)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
