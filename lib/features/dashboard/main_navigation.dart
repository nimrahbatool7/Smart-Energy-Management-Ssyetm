import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import 'dashboard_screen.dart';
import '../appliances/screens/appliances_screen.dart';
import '../ai_assistant/ai_screen.dart';
import '../analytics/analytics_screen.dart';
import '../profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const AppliancesScreen(),
    const AiScreen(),
    const AnalyticsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: VioraColors.primaryBackground.withValues(alpha: 0.9),
          boxShadow: [
            BoxShadow(
              color: VioraColors.energyGlow.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: VioraColors.energyGlow,
          unselectedItemColor: VioraColors.textSecondary,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.electric_bolt_rounded), label: 'Usage'),
            BottomNavigationBarItem(icon: Icon(Icons.smart_toy_rounded), label: 'AI'),
            BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded), label: 'Analytics'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
