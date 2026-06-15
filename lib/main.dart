import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/auth/services/auth_service.dart';
import 'app/routes.dart';
import 'app/theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }
  runApp(const VioraApp());
}

class VioraApp extends StatelessWidget {
  const VioraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Viora',
      debugShowCheckedModeBanner: false,
      theme: VioraTheme.darkTheme,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,
      initialBinding: BindingsBuilder(() {
        Get.put(AuthService(), permanent: true);
      }),
    );
  }
}
