import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class EnergyMeter extends StatefulWidget {
  final double percentage; // 0.0 to 1.0
  final double todayKwh;
  final double size;

  const EnergyMeter({
    super.key,
    required this.percentage,
    this.todayKwh = 0.0,
    this.size = 200.0,
  });

  @override
  State<EnergyMeter> createState() => _EnergyMeterState();
}

class _EnergyMeterState extends State<EnergyMeter> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 0.0, end: widget.percentage).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant EnergyMeter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.percentage,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.percentage > 0.8
        ? VioraColors.dangerRed
        : (widget.percentage > 0.5 ? VioraColors.warningOrange : VioraColors.energyGlow);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: VioraColors.primaryBackground.withValues(alpha: 0.2),
            boxShadow: [
              BoxShadow(
                color: themeColor.withValues(alpha: 0.08),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _EnergyMeterPainter(
                  progress: _animation.value,
                  color: themeColor,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(_animation.value * 100).toInt()}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.size * 0.18,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                          color: themeColor.withValues(alpha: 0.8),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Energy Used',
                    style: TextStyle(
                      color: VioraColors.textSecondary,
                      fontSize: widget.size * 0.06,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Today: ${widget.todayKwh.toStringAsFixed(1)} kWh',
                    style: TextStyle(
                      color: themeColor,
                      fontSize: widget.size * 0.065,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EnergyMeterPainter extends CustomPainter {
  final double progress;
  final Color color;

  _EnergyMeterPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;
    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    // 1. Background Track
    final trackPaint = Paint()
      ..color = VioraColors.glassBorder.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0;
    canvas.drawCircle(center, radius, trackPaint);

    // 2. Neon Glow (Multiple layers of blurred paths)
    for (double i = 1; i <= 3; i++) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.15 / i)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 12.0 + (i * 6.0);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        glowPaint,
      );
    }

    // 3. Foreground Progress Arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          color.withValues(alpha: 0.7),
          color,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12.0;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _EnergyMeterPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
