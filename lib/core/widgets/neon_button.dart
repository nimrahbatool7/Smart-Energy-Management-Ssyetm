import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/sizes.dart';

class NeonButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color glowColor;

  const NeonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.glowColor = VioraColors.energyGlow,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> {
  bool _isHovered = false;

  bool get _isEnabled => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final hasHover = _isHovered && _isEnabled;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: VioraSizes.p16, horizontal: VioraSizes.p32),
          decoration: BoxDecoration(
            color: _isEnabled
                ? widget.glowColor.withValues(alpha: hasHover ? 0.2 : 0.1)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(VioraSizes.radius24),
            border: Border.all(
              color: _isEnabled
                  ? widget.glowColor.withValues(alpha: hasHover ? 1.0 : 0.5)
                  : Colors.white.withValues(alpha: 0.2),
              width: 2,
            ),
            boxShadow: [
              if (hasHover)
                BoxShadow(
                  color: widget.glowColor.withValues(alpha: 0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                color: _isEnabled ? Colors.white : Colors.white.withValues(alpha: 0.4),
                fontWeight: FontWeight.bold,
                fontSize: 16,
                shadows: [
                  if (hasHover)
                    Shadow(color: widget.glowColor, blurRadius: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
