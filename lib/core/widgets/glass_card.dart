import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/sizes.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? glowColor;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(VioraSizes.p16),
    this.onTap,
    this.glowColor,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isHovered = true),
        onTapUp: (_) => setState(() => _isHovered = false),
        onTapCancel: () => setState(() => _isHovered = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: AnimatedSlide(
            offset: _isHovered ? const Offset(0, -0.05) : Offset.zero,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(VioraSizes.radius24),
                boxShadow: [
                  if (_isHovered)
                    BoxShadow(
                      color: (widget.glowColor ?? VioraColors.energyGlow).withValues(alpha: 0.4),
                      blurRadius: 24,
                      spreadRadius: 3,
                    )
                  else
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(VioraSizes.radius24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: _isHovered ? 15.0 : 10.0, sigmaY: _isHovered ? 15.0 : 10.0),
                  child: Container(
                    padding: widget.padding,
                    decoration: BoxDecoration(
                      color: VioraColors.glassBackground,
                      borderRadius: BorderRadius.circular(VioraSizes.radius24),
                      border: Border.all(
                        color: _isHovered 
                            ? (widget.glowColor ?? VioraColors.energyGlow).withValues(alpha: 0.7) 
                            : VioraColors.glassBorder,
                        width: _isHovered ? 2.0 : 1.5,
                      ),
                    ),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
