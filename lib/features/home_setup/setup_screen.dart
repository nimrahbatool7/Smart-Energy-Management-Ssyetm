import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/neon_button.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  String _homeType = 'Apartment';
  int _people = 2;
  double _budget = 5000;
  double _unitCost = 15;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Smart Home'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Home Type', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildHomeTypeCard('Apartment', Icons.apartment),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildHomeTypeCard('House', Icons.house),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            Text('People', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            GlassCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: Colors.white),
                    onPressed: () => setState(() { if (_people > 1) _people--; }),
                  ),
                  Text('$_people', style: Theme.of(context).textTheme.displayMedium),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () => setState(() => _people++),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            Text('Monthly Budget (Rs)', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            GlassCard(
              child: Row(
                children: [
                  const Icon(Icons.attach_money, color: VioraColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      value: _budget,
                      min: 1000,
                      max: 20000,
                      divisions: 190,
                      activeColor: VioraColors.energyGlow,
                      onChanged: (val) => setState(() => _budget = val),
                    ),
                  ),
                  Text('$_budget', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            Text('Unit Price (Rs/unit)', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            GlassCard(
              child: TextFormField(
                initialValue: '$_unitCost',
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.electric_bolt, color: VioraColors.warningOrange),
                ),
                onChanged: (val) => setState(() => _unitCost = double.tryParse(val) ?? 15),
              ),
            ),
            const SizedBox(height: 48),
            
            // Output Preview
            Center(
              child: GlassCard(
                glowColor: VioraColors.savingGreen,
                child: Column(
                  children: [
                    Text('Target Monthly Usage', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Text(
                      '${(_budget / _unitCost).toStringAsFixed(1)} kWh',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: VioraColors.savingGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              child: NeonButton(
                text: 'Continue',
                onPressed: () => Get.offNamed(AppRoutes.dashboard),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTypeCard(String type, IconData icon) {
    bool isSelected = _homeType == type;
    return GestureDetector(
      onTap: () => setState(() => _homeType = type),
      child: GlassCard(
        glowColor: isSelected ? VioraColors.energyGlow : Colors.transparent,
        child: Column(
          children: [
            Icon(icon, size: 40, color: isSelected ? VioraColors.energyGlow : VioraColors.textSecondary),
            const SizedBox(height: 8),
            Text(type, style: TextStyle(color: isSelected ? Colors.white : VioraColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
