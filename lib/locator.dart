import 'package:financy_control/services/auth/auth_service.dart';
import 'package:financy_control/services/auth/local_auth.dart';
import 'package:financy_control/services/local_storage/local_storage_service.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  // Initialize local storage first
  final localStorage = LocalStorageService();
  await localStorage.init();
  locator.registerLazySingleton<LocalStorageService>(() => localStorage);

  // Register auth service
  locator.registerLazySingleton<AuthService>(() => LocalAuth());
}
