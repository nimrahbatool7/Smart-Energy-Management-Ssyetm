import 'package:flutter/material.dart';
import '../constants/colors.dart';

class EnergyMeter extends StatelessWidget {
  final double percentage; // 0.0 to 1.0
  final double size;

  const EnergyMeter({
    super.key,
    required this.percentage,
    this.size = 150.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 10,
            color: VioraColors.glassBorder,
          ),
          // Foreground energy circle
          CircularProgressIndicator(
            value: percentage,
            strokeWidth: 10,
            color: percentage > 0.8 
                ? VioraColors.dangerRed 
                : (percentage > 0.5 ? VioraColors.warningOrange : VioraColors.energyGlow),
            backgroundColor: Colors.transparent,
          ),
          // Inner text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(percentage * 100).toInt()}%',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: percentage > 0.8 ? VioraColors.dangerRed : VioraColors.textPrimary,
                ),
              ),
              Text(
                'Energy Used',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
