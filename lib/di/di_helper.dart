import 'package:get_it/get_it.dart';

/// Helper for common DI registration patterns (matches flutter_gems / gems_core).
class DIHelper {
  static void registerRepository<T extends Object>({
    required T Function() factory,
    bool lazy = true,
  }) {
    final getIt = GetIt.instance;
    if (getIt.isRegistered<T>()) return;

    if (lazy) {
      getIt.registerLazySingleton<T>(factory);
    } else {
      getIt.registerSingleton<T>(factory());
    }
  }

  static void registerUseCase<U extends Object, R extends Object>({
    required U Function(R repository) factory,
    bool lazy = true,
  }) {
    final getIt = GetIt.instance;
    if (getIt.isRegistered<U>()) return;

    if (lazy) {
      getIt.registerLazySingleton<U>(
        () => factory(getIt<R>()),
      );
    } else {
      getIt.registerSingleton<U>(factory(getIt<R>()));
    }
  }

  static void registerController<T extends Object>({
    required T Function() factory,
    bool lazy = true,
  }) {
    final getIt = GetIt.instance;
    if (getIt.isRegistered<T>()) return;

    if (lazy) {
      getIt.registerLazySingleton<T>(factory);
    } else {
      getIt.registerSingleton<T>(factory());
    }
  }
}
