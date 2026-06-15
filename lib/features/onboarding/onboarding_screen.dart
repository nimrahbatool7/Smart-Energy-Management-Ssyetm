import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/neon_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Understand your energy usage',
      'icon': Icons.home_repair_service_rounded,
      'color': VioraColors.energyGlow,
    },
    {
      'title': 'Get intelligent energy insights',
      'icon': Icons.psychology_rounded,
      'color': VioraColors.savingGreen,
    },
    {
      'title': 'Predict your electricity bill',
      'icon': Icons.insights_rounded,
      'color': VioraColors.warningOrange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [VioraColors.primaryBackground, Color(0xFF0A2540)],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _pages[index]['color'].withValues(alpha: 0.1),
                                boxShadow: [
                                  BoxShadow(
                                    color: _pages[index]['color'].withValues(alpha: 0.3),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _pages[index]['icon'],
                                size: 100,
                                color: _pages[index]['color'],
                              ),
                            ),
                            const SizedBox(height: 60),
                            Text(
                              _pages[index]['title'],
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontSize: 28,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                // Pagination Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index 
                            ? VioraColors.energyGlow 
                            : VioraColors.textSecondary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _currentPage == _pages.length - 1
                        ? SizedBox(
                            width: double.infinity,
                            child: NeonButton(
                              text: 'Get Started',
                              onPressed: () => Get.offNamed(AppRoutes.login),
                            ),
                          )
                        : SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: const Text('Next', style: TextStyle(color: Colors.white, fontSize: 18)),
                            ),
                          ),
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
