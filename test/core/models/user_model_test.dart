import 'package:flutter_test/flutter_test.dart';
import 'package:financy_control/core/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    test('UserModel should serialize and deserialize correctly', () {
      final userModel = UserModel(
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
      );

      final json = userModel.toJson();
      final deserializedUser = UserModel.fromJson(json);

      expect(deserializedUser.id, userModel.id);
      expect(deserializedUser.name, userModel.name);
      expect(deserializedUser.email, userModel.email);
    });
  });

  group('UserInputModel Tests', () {
    test('UserInputModel should serialize and deserialize correctly', () {
      final userInputModel = UserInputModel(
        name: 'Test Input',
        email: 'input@example.com',
        password: 'password123',
      );

      final json = userInputModel.toJson();
      final deserializedInput = UserInputModel.fromJson(json);

      expect(deserializedInput.name, userInputModel.name);
      expect(deserializedInput.email, userInputModel.email);
      expect(deserializedInput.password, userInputModel.password);
    });
  });
}
