import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;

  // 🔥 TEMP BYPASS (REMOVE LATER)
  final bool debugBypassLogin = true;

  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);

    // 🔥 BYPASS MODE
    if (debugBypassLogin) {
      await Future.delayed(const Duration(milliseconds: 300));
      Get.offAllNamed('/dashboard');
      setState(() => _loading = false);
      return;
    }

    final auth = Get.find<AuthService>();
    final result = await auth.signInWithGoogle();

    if (result != null) {
      final uid = result.user?.uid;

      final homeDoc =
          await FirebaseFirestore.instance.doc('users/$uid/home').get();

      if (homeDoc.exists) {
        Get.offAllNamed('/dashboard');
      } else {
        Get.offAllNamed('/homeSetup');
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _signInWithEmail() async {
    setState(() => _loading = true);

    // 🔥 BYPASS MODE
    if (debugBypassLogin) {
      await Future.delayed(const Duration(milliseconds: 300));
      Get.offAllNamed('/dashboard');
      setState(() => _loading = false);
      return;
    }

    if (!_formKey.currentState!.validate()) {
      setState(() => _loading = false);
      return;
    }

    final auth = Get.find<AuthService>();

    final result = await auth.signInWithEmail(
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );

    if (result != null) {
      final uid = result.user?.uid;

      final homeDoc =
          await FirebaseFirestore.instance.doc('users/$uid/home').get();

      if (homeDoc.exists) {
        Get.offAllNamed('/dashboard');
      } else {
        Get.offAllNamed('/homeSetup');
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.5,
                colors: [Color(0xFF0D2E4D), VioraColors.primaryBackground],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeIn,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 60),

                      const Text(
                        'VIORA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 8,
                        ),
                      ),

                      const SizedBox(height: 56),

                      // GOOGLE BUTTON
                      GlassCard(
                        glowColor: VioraColors.energyGlow,
                        padding: EdgeInsets.zero,
                        onTap: _loading ? null : _signInWithGoogle,
                        child: SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: Center(
                              child: _loading
                                  ? const CircularProgressIndicator()
                                  : const Text(
                                      'Continue with Google',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      _buildField(
                        controller: _emailCtrl,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        validator: (v) =>
                            v != null && v.contains('@')
                                ? null
                                : 'Invalid email',
                      ),

                      const SizedBox(height: 16),

                      _buildField(
                        controller: _passCtrl,
                        label: 'Password',
                        icon: Icons.lock_outline,
                        obscure: true,
                        validator: (v) =>
                            v != null && v.length >= 6
                                ? null
                                : 'Min 6 characters',
                      ),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _loading ? null : _signInWithEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: VioraColors.energyGlow,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Sign In'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
}