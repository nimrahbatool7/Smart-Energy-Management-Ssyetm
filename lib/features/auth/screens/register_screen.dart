import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/config/app_config.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  // 🔥 TEMP BYPASS (REMOVE LATER)
  final bool debugBypassLogin = AppConfig.skipAuthentication;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() => _loading = true);

    // 🔥 BYPASS MODE
    if (debugBypassLogin) {
      await Future.delayed(const Duration(milliseconds: 300));
      Get.offAllNamed('/dashboard');
      if (mounted) setState(() => _loading = false);
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    final auth = Get.find<AuthService>();
    final result = await auth.registerWithEmail(_nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text);
    if (result != null) Get.offAllNamed('/homeSetup');
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);

    // 🔥 BYPASS MODE
    if (debugBypassLogin) {
      await Future.delayed(const Duration(milliseconds: 300));
      Get.offAllNamed('/dashboard');
      if (mounted) setState(() => _loading = false);
      return;
    }

    final auth = Get.find<AuthService>();
    final result = await auth.signInWithGoogle();
    if (result != null) Get.offAllNamed('/homeSetup');
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account'), backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0A2540), VioraColors.primaryBackground],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    const Text('Join Viora', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    const Text('Start managing your smart energy', style: TextStyle(color: VioraColors.textSecondary)),
                    const SizedBox(height: 40),

                    // Google Button
                    GlassCard(
                      glowColor: VioraColors.energyGlow,
                      padding: EdgeInsets.zero,
                      onTap: _loading ? null : _signInWithGoogle,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.g_mobiledata, color: Colors.white, size: 28),
                            const SizedBox(width: 12),
                            const Text('Sign up with Google', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
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

                    _buildField(ctrl: _nameCtrl, label: 'Full Name', icon: Icons.person_outline,
                      validator: (v) => v!.isNotEmpty ? null : 'Name required'),
                    const SizedBox(height: 16),
                    _buildField(ctrl: _emailCtrl, label: 'Email', icon: Icons.email_outlined,
                      validator: (v) => v!.contains('@') ? null : 'Enter valid email'),
                    const SizedBox(height: 16),
                    _buildField(ctrl: _passCtrl, label: 'Password', icon: Icons.lock_outline, obscure: true,
                      validator: (v) => v!.length >= 6 ? null : 'Min 6 characters'),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: _loading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VioraColors.energyGlow,
                        foregroundColor: VioraColors.primaryBackground,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _loading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: VioraColors.primaryBackground))
                          : const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account? ', style: TextStyle(color: VioraColors.textSecondary)),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: const Text('Sign In', style: TextStyle(color: VioraColors.energyGlow, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({required TextEditingController ctrl, required String label, required IconData icon, bool obscure = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
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
