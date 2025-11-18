import 'package:financy_control/repositories/impl/mock_transaction_repository.dart';
import 'package:financy_control/repositories/impl/mock_user_repository.dart';
import 'package:financy_control/repositories/transaction_repository.dart';
import 'package:financy_control/repositories/user_repository.dart';
import 'package:financy_control/services/auth/auth_service.dart';
import 'package:financy_control/services/auth/mock_auth_service.dart';
import 'package:financy_control/services/storage/impl/local_storage_service.dart';
import 'package:financy_control/services/storage/storage_service.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  // Initialize storage service first
  final storageService = LocalStorageService();
  await storageService.init();
  locator.registerLazySingleton<StorageService>(() => storageService);

  // Register auth service
  final authService = MockAuthService(storage: storageService);
  await authService.init();
  locator.registerLazySingleton<AuthService>(() => authService);

  // Register repositories
  locator.registerLazySingleton<TransactionRepository>(
    () => MockTransactionRepository(storage: storageService),
  );
  locator.registerLazySingleton<UserRepository>(
    () => MockUserRepository(storage: storageService),
  );
}
