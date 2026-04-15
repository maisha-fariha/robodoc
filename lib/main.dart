import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/ai_assessment_controller.dart';
import 'controllers/auth_controller.dart';
import 'firebase_options.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'services/app_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final appServices = AppServices();
  await appServices.initialize();

  Get.put(AppServices.getIt<AuthController>(), permanent: true);
  Get.put(AppServices.getIt<AiAssessmentController>(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const _primary = Color(0xFF0E204D);
  static const _secondary = Color(0xFF21CDC0);

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return GetMaterialApp(
      title: 'RoboDoc',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: _primary,
          secondary: _secondary,
          surface: Colors.white,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: _primary,
          selectionColor: Color(0x3321CDC0),
          selectionHandleColor: _secondary,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFEFEFEF),
          hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.35)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _secondary, width: 1.6),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      getPages: AppPages.routes,
      initialRoute: auth.isLoggedIn ? AppRoutes.assessment : AppRoutes.login,
    );
  }
}

