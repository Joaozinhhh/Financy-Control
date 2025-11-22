import 'package:financy_control/repositories/impl/transaction_repository_impl.dart';
import 'package:financy_control/repositories/transaction_repository.dart';
import 'package:financy_control/services/auth/auth_service.dart';
import 'package:financy_control/services/auth/impl/firebase_auth_service.dart';
import 'package:financy_control/services/profile_image/impl/base64_profile_image_service.dart';
import 'package:financy_control/services/profile_image/profile_image_service.dart';
import 'package:financy_control/services/storage/impl/firebase_storage_service.dart';
import 'package:financy_control/services/storage/storage_service.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  // Initialize storage service first
  final storageService = FirebaseStorageService();
  locator.registerLazySingleton<StorageService>(() => storageService);

  // Register auth service
  final authService = FirebaseAuthService(storage: storageService);
  locator.registerLazySingleton<AuthService>(() => authService);

  // Register repositories
  locator.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(storage: storageService),
  );

  // Profile image service (Base64 in Firestore user doc)
  locator.registerLazySingleton<ProfileImageService>(
    () => Base64ProfileImageService(),
  );
}
