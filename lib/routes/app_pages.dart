import 'package:get/get.dart';

import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/sign_up_page.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: AppRoutes.signUp,
      page: () => const SignUpPage(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
    ),
  ];
}

