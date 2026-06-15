import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/routes.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeOutQuad),
    );

    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Get.offNamed(AppRoutes.dashboard);
    } else {
      final prefs = await SharedPreferences.getInstance();
      final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
      if (onboardingCompleted) {
        Get.offNamed(AppRoutes.login);
      } else {
        Get.offNamed(AppRoutes.onboarding);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [VioraColors.primaryBackground, Color(0xFF030D16)],
              ),
            ),
          ),
          
          // Floating Particles Custom Painter
          Positioned.fill(
            child: CustomPaint(
              painter: ParticlePainter(),
            ),
          ),

          // Expanding wave
          AnimatedBuilder(
            animation: _waveAnimation,
            builder: (context, child) {
              return Center(
                child: Container(
                  width: _waveAnimation.value * 500,
                  height: _waveAnimation.value * 500,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: VioraColors.energyGlow.withValues(alpha: 0.05 * (1 - _waveAnimation.value)),
                  ),
                ),
              );
            },
          ),

          // Center Logo and Text
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: VioraColors.energyGlow.withValues(alpha: 0.5),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                      border: Border.all(
                        color: VioraColors.energyGlow.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.home_rounded, // Home icon with energy vibe
                      size: 80, 
                      color: VioraColors.energyGlow
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  VioraStrings.appName,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  VioraStrings.tagline,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: VioraColors.energyGlow,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final Random random = Random();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = VioraColors.energyGlow.withValues(alpha: 0.2);
    
    for (int i = 0; i < 30; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 3 + 1;
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
