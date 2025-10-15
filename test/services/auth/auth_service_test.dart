import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:financy_control/core/data/data.dart';
import 'package:financy_control/core/models/user_model.dart';
import 'package:financy_control/services/auth/auth_service.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  late MockAuthService mockAuthService;

  provideDummy<DataResult<UserModel>>(
    DataResult.success(
      UserModel(
        id: 'dummy',
        name: 'Dummy User',
        email: 'dummy@example.com',
      ),
    ),
  );
  provideDummy<DataResult<bool>>(DataResult.success(true));

  setUp(() {
    mockAuthService = MockAuthService();
  });

  group('AuthService Tests', () {
    test('signUp should return a DataResult<UserModel>', () async {
      final userInput = UserInputModel(
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
      );
      final userModel = UserModel(
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
      );

      when(
        mockAuthService.signUp(userInput),
      ).thenAnswer((_) async => DataResult.success(userModel));

      final result = await mockAuthService.signUp(userInput);
      expect(result.data, isNotNull);
      expect(result.data, userModel);
    });

    test('signIn should return a DataResult<UserModel>', () async {
      final email = 'test@example.com';
      final password = 'password123';
      final userModel = UserModel(id: '1', name: 'Test User', email: email);
      when(
        mockAuthService.signIn(email: email, password: password),
      ).thenAnswer((_) async => DataResult.success(userModel));

      final result = await mockAuthService.signIn(
        email: email,
        password: password,
      );

      expect(result.data, isNotNull);
      expect(result.data, userModel);
    });

    test('signOut should complete without errors', () async {
      when(mockAuthService.signOut()).thenAnswer((_) async {});

      await mockAuthService.signOut();

      verify(mockAuthService.signOut()).called(1);
    });

    test('forgotPassword should return a DataResult<bool>', () async {
      final email = 'test@example.com';
      when(
        mockAuthService.forgotPassword(email),
      ).thenAnswer((_) async => DataResult.success(true));

      final result = await mockAuthService.forgotPassword(email);

      expect(result.data, isNotNull);
      expect(result.data, true);
    });

    test('currentUser should return the current user', () {
      final userModel = UserModel(
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
      );
      when(mockAuthService.currentUser).thenReturn(userModel);

      final currentUser = mockAuthService.currentUser;

      expect(currentUser, userModel);
    });
  });
}
