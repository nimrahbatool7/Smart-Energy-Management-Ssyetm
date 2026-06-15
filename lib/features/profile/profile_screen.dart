import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  String _profileImage = '';
  final TextEditingController _nameController = TextEditingController();
  bool _uploading = false;
  double _monthlyBudget = 5000;
  double _savingTarget = 20;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = Get.find<AuthService>().uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        setState(() {
          _nameController.text = data['name'] ?? 'Viora User';
          _profileImage = data['profileImage'] ?? '';
          _monthlyBudget = (data['monthlyBudget'] as num?)?.toDouble() ?? 5000;
          _savingTarget = (data['savingTarget'] as num?)?.toDouble() ?? 20;
        });
      }
    }
  }

  Future<void> _saveProfileName() async {
    final uid = Get.find<AuthService>().uid;
    if (uid != null && _nameController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameController.text.trim(),
      }, SetOptions(merge: true));
      Get.snackbar('Success', 'Profile name updated',
          backgroundColor: VioraColors.savingGreen, colorText: Colors.white);
    }
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    final uid = Get.find<AuthService>().uid;
    if (uid == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 50);

    if (pickedFile == null) return;

    setState(() => _uploading = true);

    try {
      final storageRef = FirebaseStorage.instance.ref().child('profileImages/$uid.jpg');
      final file = File(pickedFile.path);
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'profileImage': downloadUrl,
      }, SetOptions(merge: true));

      setState(() {
        _profileImage = downloadUrl;
      });
      Get.snackbar('Success', 'Profile picture updated successfully',
          backgroundColor: VioraColors.savingGreen, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Upload Failed', e.toString(),
          backgroundColor: VioraColors.dangerRed, colorText: Colors.white);
    } finally {
      setState(() => _uploading = false);
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
                    Navigator.pop(context);
                    _pickAndUploadImage(ImageSource.gallery);
                  }),
                  _buildBottomSheetOption(Icons.camera_alt, 'Camera', () {
                    Navigator.pop(context);
                    _pickAndUploadImage(ImageSource.camera);
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

  void _showEnergyGoalsDialog() {
    double tempBudget = _monthlyBudget;
    double tempSaving = _savingTarget;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: VioraColors.primaryBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: VioraColors.energyGlow, width: 2),
              ),
              title: const Text('Set Energy Goals', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Monthly Budget (Rs)', style: TextStyle(color: VioraColors.textSecondary)),
                  Slider(
                    value: tempBudget,
                    min: 1000,
                    max: 20000,
                    divisions: 19,
                    activeColor: VioraColors.energyGlow,
                    onChanged: (val) => setDialogState(() => tempBudget = val),
                  ),
                  Text('Rs ${tempBudget.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Target Saving (%)', style: TextStyle(color: VioraColors.textSecondary)),
                  Slider(
                    value: tempSaving,
                    min: 5,
                    max: 50,
                    divisions: 9,
                    activeColor: VioraColors.savingGreen,
                    onChanged: (val) => setDialogState(() => tempSaving = val),
                  ),
                  Text('${tempSaving.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: VioraColors.textSecondary)),
                ),
                TextButton(
                  onPressed: () async {
                    final uid = Get.find<AuthService>().uid;
                    if (uid != null) {
                      await FirebaseFirestore.instance.collection('users').doc(uid).set({
                        'monthlyBudget': tempBudget,
                        'savingTarget': tempSaving,
                      }, SetOptions(merge: true));
                      setState(() {
                        _monthlyBudget = tempBudget;
                        _savingTarget = tempSaving;
                      });
                    }
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save', style: TextStyle(color: VioraColors.energyGlow)),
                ),
              ],
            );
          },
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
                      child: _uploading
                          ? const Center(child: CircularProgressIndicator(color: VioraColors.energyGlow))
                          : _profileImage.isNotEmpty
                              ? Image.network(
                                  _profileImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.white, size: 60),
                                )
                              : const Icon(Icons.person, color: Colors.white, size: 60),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _uploading ? null : _showImagePickerBottomSheet,
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
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: const TextStyle(color: VioraColors.textSecondary),
                          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: VioraColors.glassBorder)),
                          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: VioraColors.energyGlow)),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.save, color: VioraColors.energyGlow),
                            onPressed: _saveProfileName,
                          ),
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
                        children: [
                          const Text('Monthly Budget', style: TextStyle(color: VioraColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text('Rs ${_monthlyBudget.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: VioraColors.savingGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: VioraColors.savingGreen.withValues(alpha: 0.5)),
                        ),
                        child: Text('Save $_savingTarget%', style: const TextStyle(color: VioraColors.savingGreen, fontWeight: FontWeight.bold)),
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
                        onTap: _showEnergyGoalsDialog,
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
