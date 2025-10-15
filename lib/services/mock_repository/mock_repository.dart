import 'package:financy_control/core/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

enum Endpoints {
  signIn('/api/sign-in'),
  signUp('/api/sign-up'),
  forgotPassword('/api/forgot-password'),
  getUser('/api/user');

  final String path;
  const Endpoints(this.path);
}

final mockClient = MockClient((request) async {
  if (request.url.path == Endpoints.signIn.path && request.method == 'POST') {
    return http.Response('{"token":"dummy_token"}', 200);
  }
  if (request.url.path == Endpoints.getUser.path && request.method == 'GET') {
    return http.Response(
      '{"id":"1","name":"Test User","email":"test@example.com"}',
      200,
    );
  }
  if (request.url.path == Endpoints.signUp.path && request.method == 'POST') {
    final body = request.body;
    if (body.contains('email') && body.contains('password')) {
      return http.Response(
        '{"id":"1","name":"Test User","email":"test@example.com"}',
        200,
      );
    }
  }
  if (request.url.path == Endpoints.forgotPassword.path &&
      request.method == 'POST') {
    final body = request.body;
    if (body.contains('email')) {
      return http.Response('{"message":"Password reset link sent"}', 200);
    }
  }
  return http.Response('Not Found', 404);
});

Future<UserModel> mockCreateUser(UserInputModel input) async {
  mockClient.post(
    Uri.parse(Endpoints.signUp.path),
    body: input.toJson(),
  );

  return UserModel(
    id: '1',
    name: input.name ?? 'Test User',
    email: input.email,
  );
}

Future<UserModel> mockLogin(UserInputModel input) async {
  mockClient.post(
    Uri.parse(Endpoints.signIn.path),
    body: input.toJson(),
  );

  return UserModel(
    id: '1',
    name: 'Test User',
    email: input.email,
  );
}

Future<bool> mockForgotPassword(String email) async {
  final response = await mockClient.post(
    Uri.parse(Endpoints.forgotPassword.path),
    body: {'email': email},
  );

  return response.statusCode == 200;
}
