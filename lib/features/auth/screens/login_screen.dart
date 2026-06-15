import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
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
    final auth = Get.find<AuthService>();
    final result = await auth.signInWithGoogle();
    if (result != null) Get.offAllNamed('/dashboard');
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final auth = Get.find<AuthService>();
    final result = await auth.signInWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
    if (result != null) Get.offAllNamed('/dashboard');
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.5,
                colors: [Color(0xFF0D2E4D), VioraColors.primaryBackground],
              ),
            ),
          ),

          // Neon glow orb
          Positioned(
            top: -80, left: -80,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  VioraColors.energyGlow.withValues(alpha: 0.2),
                  Colors.transparent,
                ]),
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
                      // Logo / Title
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: VioraColors.energyGlow, width: 2),
                          boxShadow: [BoxShadow(color: VioraColors.energyGlow.withValues(alpha: 0.4), blurRadius: 30)],
                          color: VioraColors.glassBackground,
                        ),
                        child: const Icon(Icons.bolt, color: VioraColors.energyGlow, size: 48),
                      ),
                      const SizedBox(height: 24),
                      const Text('VIORA', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 8)),
                      const Text('Smart Energy Intelligence', style: TextStyle(color: VioraColors.textSecondary, fontSize: 14, letterSpacing: 2)),
                      const SizedBox(height: 56),

                      // Google Sign-In Button (PRIMARY)
                      GlassCard(
                        glowColor: VioraColors.energyGlow,
                        padding: EdgeInsets.zero,
                        onTap: _loading ? null : _signInWithGoogle,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_loading)
                                const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: VioraColors.energyGlow))
                              else ...[
                                const Icon(Icons.g_mobiledata, color: Colors.white, size: 28),
                                const SizedBox(width: 12),
                                const Text('Continue with Google', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Row(children: [
                        Expanded(child: Divider(color: VioraColors.glassBorder)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('or', style: TextStyle(color: VioraColors.textSecondary)),
                        ),
                        Expanded(child: Divider(color: VioraColors.glassBorder)),
                      ]),
                      const SizedBox(height: 24),

                      // Email field
                      _buildField(controller: _emailCtrl, label: 'Email', icon: Icons.email_outlined,
                        validator: (v) => v!.contains('@') ? null : 'Enter valid email'),
                      const SizedBox(height: 16),

                      // Password field
                      _buildField(controller: _passCtrl, label: 'Password', icon: Icons.lock_outline,
                        obscure: true,
                        validator: (v) => v!.length >= 6 ? null : 'Min 6 characters'),
                      const SizedBox(height: 32),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _signInWithEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: VioraColors.energyGlow,
                            foregroundColor: VioraColors.primaryBackground,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Register link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? ", style: TextStyle(color: VioraColors.textSecondary)),
                          GestureDetector(
                            onTap: () => Get.toNamed('/register'),
                            child: const Text('Sign Up', style: TextStyle(color: VioraColors.energyGlow, fontWeight: FontWeight.bold)),
                          ),
                        ],
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
        labelStyle: const TextStyle(color: VioraColors.textSecondary),
        prefixIcon: Icon(icon, color: VioraColors.textSecondary),
        filled: true,
        fillColor: VioraColors.glassBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: VioraColors.glassBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: VioraColors.glassBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: VioraColors.energyGlow, width: 2)),
      ),
    );
  }
}
