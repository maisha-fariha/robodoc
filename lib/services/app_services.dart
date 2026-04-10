import 'package:get_it/get_it.dart';

import '../di/auth/auth_di.dart';

/// App-wide dependency injection using get_it (same pattern as flutter_gems).
class AppServices {
  static final getIt = GetIt.instance;

  Future<void> initialize() async {
    await setupAuthDomainServices();
  }

  /// Reset all registrations (e.g. tests).
  Future<void> reset() async {
    await getIt.reset();
  }
}
