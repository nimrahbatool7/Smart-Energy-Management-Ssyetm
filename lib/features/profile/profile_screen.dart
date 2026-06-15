import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/neon_button.dart';
import '../auth/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  String _profileImage = 'assets/profile/default_avatar.png';
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = Get.find<AuthService>().currentUser.value;
    if (user != null) {
      _nameController.text = user.displayName ?? 'Viora User';
      _profileImage = user.photoURL ?? 'assets/profile/default_avatar.png';
    } else {
      _nameController.text = 'Guest User';
    }
  }

  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: VioraColors.primaryBackground,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            border: Border(top: BorderSide(color: VioraColors.energyGlow, width: 2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Update Profile Picture', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBottomSheetOption(Icons.photo_library, 'Gallery', () {
                    setState(() => _profileImage = 'assets/profile/user_gallery.png');
                    Navigator.pop(context);
                  }),
                  _buildBottomSheetOption(Icons.camera_alt, 'Camera', () {
                    setState(() => _profileImage = 'assets/profile/user_camera.png');
                    Navigator.pop(context);
                  }),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: VioraColors.glassBackground,
              shape: BoxShape.circle,
              border: Border.all(color: VioraColors.energyGlow),
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: VioraColors.textSecondary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: Stack(
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Animated Circular Avatar Container
                GestureDetector(
                  onTap: _showImagePickerBottomSheet,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: VioraColors.glassBackground,
                      border: Border.all(color: VioraColors.energyGlow, width: 3),
                      boxShadow: [
                        BoxShadow(color: VioraColors.energyGlow.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 5),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: _profileImage.startsWith('http')
                          ? Image.network(
                              _profileImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.white, size: 60),
                            )
                          : Image.asset(
                              _profileImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.white, size: 60),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _showImagePickerBottomSheet,
                  icon: const Icon(Icons.upload, color: VioraColors.energyGlow),
                  label: const Text('Upload Profile Image', style: TextStyle(color: VioraColors.energyGlow)),
                ),
                const SizedBox(height: 32),

                // Editable Name & Email
                GlassCard(
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(color: VioraColors.textSecondary),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: VioraColors.glassBorder)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: VioraColors.energyGlow)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        enabled: false,
                        style: const TextStyle(color: VioraColors.textSecondary),
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: VioraColors.textSecondary),
                          disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: VioraColors.glassBorder)),
                        ),
                        controller: TextEditingController(text: Get.find<AuthService>().currentUser.value?.email ?? 'guest@viora.ai'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Home Summary Card
                GlassCard(
                  glowColor: VioraColors.savingGreen,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Home Profile', style: TextStyle(color: VioraColors.textSecondary)),
                          SizedBox(height: 4),
                          Text('Smart Apartment', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: VioraColors.savingGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: VioraColors.savingGreen.withValues(alpha: 0.5)),
                        ),
                        child: const Text('Optimized', style: TextStyle(color: VioraColors.savingGreen, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Settings Section
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Settings', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
                        subtitle: const Text('Alerts and AI Insights', style: TextStyle(color: VioraColors.textSecondary)),
                        value: _notificationsEnabled,
                        activeThumbColor: VioraColors.energyGlow,
                        onChanged: (val) => setState(() => _notificationsEnabled = val),
                      ),
                      const Divider(color: VioraColors.glassBorder, height: 1),
                      ListTile(
                        title: const Text('Energy Goals', style: TextStyle(color: Colors.white)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: VioraColors.textSecondary),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: NeonButton(
                    text: 'Logout',
                    glowColor: VioraColors.dangerRed,
                    onPressed: () {
                      Get.find<AuthService>().signOut();
                    },
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
