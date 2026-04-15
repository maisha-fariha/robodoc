import 'package:firebase_auth/firebase_auth.dart';
import 'package:gems_data_layer/gems_data_layer.dart' show DatabaseService;
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../controllers/auth_controller.dart';
import '../../services/local_auth_service.dart';
import '../di_helper.dart';

/// Registers auth-related services and [AuthController] (get_it + GetX bridge in main).
Future<void> setupAuthDomainServices() async {
  final getIt = GetIt.instance;

  if (!getIt.isRegistered<FirebaseAuth>()) {
    getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  }

  if (!getIt.isRegistered<GoogleSignIn>()) {
    getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
  }

  if (!getIt.isRegistered<DatabaseService>()) {
    final db = DatabaseService();
    await db.initialize(boxName: 'robodoc_database');
    getIt.registerSingleton<DatabaseService>(db);
  }

  if (!getIt.isRegistered<LocalAuthService>()) {
    final localAuth = LocalAuthService(getIt<DatabaseService>());
    await localAuth.initialize();
    getIt.registerSingleton<LocalAuthService>(localAuth);
  }

  DIHelper.registerController<AuthController>(
    factory: () => AuthController(
      auth: getIt<FirebaseAuth>(),
      googleSignIn: getIt<GoogleSignIn>(),
      localAuth: getIt<LocalAuthService>(),
    ),
  );
}
