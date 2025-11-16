import 'dart:convert';

import 'package:financy_control/core/models/transaction_model.dart';
import 'package:financy_control/core/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

enum Endpoints {
  signIn('/api/sign-in'),
  signUp('/api/sign-up'),
  forgotPassword('/api/forgot-password'),
  getUser('/api/user'),
  getTransactions('/api/transactions'),
  createTransaction('/api/transactions'),
  updateTransaction('/api/transactions'),
  deleteTransaction('/api/transactions');

  final String path;
  const Endpoints(this.path);
}

const Duration mockNetworkDelay = Duration(seconds: 1);

final mockClient = MockClient((request) async {
  await Future.delayed(mockNetworkDelay);
  if (request.url.path == Endpoints.signIn.path && request.method == 'POST') {
    final body = request.body;
    if (body.contains('email') && body.contains('password')) {
      return http.Response(
        '{"id":"1","name":"Test User","email":"test@example.com"}',
        200,
      );
    }
  }
  if (request.url.path == Endpoints.getUser.path && request.method == 'GET') {
    return http.Response(
      '{"id":"1","name":"Test User","email":"test@example.com"}',
      200,
    );
  }
  if (request.url.path == Endpoints.signUp.path && request.method == 'POST') {
    final body = request.body;
    if (body.contains('name') &&
        body.contains('email') &&
        body.contains('password')) {
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
  if (request.url.path == Endpoints.getTransactions.path &&
      request.method == 'GET') {
    return http.Response(
      '[{"id":"1","amount":100.0,"description":"Test Transaction","date":"2023-01-01T00:00:00.000Z","category":"salary"}]',
      200,
    );
  }
  if (request.url.path == Endpoints.createTransaction.path &&
      request.method == 'POST') {
    final body = request.body;
    if (body.contains('amount') &&
        body.contains('description') &&
        body.contains('date') &&
        body.contains('category')) {
      return http.Response(
        '{"id":"1","amount":100.0,"description":"Test Transaction","date":"2023-01-01T00:00:00.000Z","category":"salary"}',
        201,
      );
    }
  }
  if (request.url.path == Endpoints.updateTransaction.path &&
      request.method == 'PUT') {
    final body = request.body;
    if (body.contains('id') &&
        body.contains('amount') &&
        body.contains('description') &&
        body.contains('date') &&
        body.contains('category')) {
      return http.Response(
        '{"id":"1","amount":100.0,"description":"Test Transaction","date":"2023-01-01T00:00:00.000Z","category":"salary"}',
        200,
      );
    }
  }
  if (request.url.path == Endpoints.deleteTransaction.path &&
      request.method == 'DELETE') {
    final body = request.body;
    if (body.contains('id')) {
      return http.Response('', 204);
    }
  }

  return http.Response('Not Found', 404);
});

Future<UserModel> mockCreateUser(UserInputModel input) async {
  final response = await mockClient.post(
    Uri.parse(Endpoints.signUp.path),
    body: input.toJson(),
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to create user');
  }

  final user = UserModel.fromJson(jsonDecode(response.body));
  _currentUser = user;

  return user;
}

Future<UserModel> mockLogin(UserInputModel input) async {
  final response = await mockClient.post(
    Uri.parse(Endpoints.signIn.path),
    body: input.toJson(),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to log in');
  }

  final user = UserModel.fromJson(jsonDecode(response.body));
  _currentUser = user;

  return user;
}

Future<bool> mockForgotPassword(String email) async {
  final response = await mockClient.post(
    Uri.parse(Endpoints.forgotPassword.path),
    body: {'email': email},
  );

  return response.statusCode == 200;
}

final List<TransactionModel> _inMemoryTransactions = [];

Future<TransactionModel> mockCreateTransaction(
  TransactionInputModel input,
) async {
  final transaction = TransactionModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    amount: input.category.income
        ? input.amount ?? 0.0
        : -(input.amount ?? 0.0),
    description: input.description,
    date: input.date,
    category: input.category,
  );
  _inMemoryTransactions.add(transaction);
  return transaction;
}

Future<TransactionModel> mockUpdateTransaction(
  String id,
  TransactionInputModel input,
) async {
  final index = _inMemoryTransactions.indexWhere((t) => t.id == id);
  if (index == -1) {
    throw Exception('Transaction not found');
  }
  final updatedTransaction = TransactionModel(
    id: id,
    amount: input.category.income
        ? input.amount ?? _inMemoryTransactions[index].amount
        : -(input.amount ?? _inMemoryTransactions[index].amount),
    description: input.description,
    date: input.date,
    category: input.category,
  );
  _inMemoryTransactions[index] = updatedTransaction;
  return updatedTransaction;
}

Future<bool> mockDeleteTransaction(String id) async {
  final index = _inMemoryTransactions.indexWhere((t) => t.id == id);
  if (index == -1) {
    throw Exception('Transaction not found');
  }
  _inMemoryTransactions.removeAt(index);
  return true;
}

Future<List<TransactionModel>> mockGetTransactions({
  DateTime? startDate,
  DateTime? endDate,
}) async {
  // Filter transactions by date range if provided
  List<TransactionModel> filteredTransactions = _inMemoryTransactions;
  if (startDate != null) {
    filteredTransactions = filteredTransactions
        .where(
          (transaction) =>
              transaction.date.millisecondsSinceEpoch >=
              startDate.millisecondsSinceEpoch,
        )
        .toList();
  }
  if (endDate != null) {
    filteredTransactions = filteredTransactions
        .where(
          (transaction) =>
              transaction.date.millisecondsSinceEpoch <=
              endDate.millisecondsSinceEpoch,
        )
        .toList();
  }

  return List.unmodifiable(filteredTransactions);
}

Future<Map<String, String>> mockGetUserProfile() async {
  return {
    'name': 'Test User',
    'email': 'test@example.com',
    'photoUrl': 'https://i.pravatar.cc/300',
  };
}

Future<bool> mockUpdateUserName(String newName) async {
  // Simulate success
  return true;
}

Future<bool> mockUpdateUserPassword(String newPassword) async {
  // Simulate success
  return true;
}

Future<bool> mockLogout() async {
  // Simulate success
  _currentUser = null;
  return true;
}

Future<double> mockGetBalance() async {
  // Simulate balance calculation
  return _inMemoryTransactions.fold<double>(
    0.0,
    (sum, transaction) =>
        sum +
        (transaction.category.income
            ? transaction.amount
            : -transaction.amount),
  );
}

UserModel? _currentUser;

Future<UserModel?> mockCheckAuthStatus() async {
  await Future.delayed(mockNetworkDelay);
  return _currentUser;
}

UserModel? mockGetCurrentUser() {
  return _currentUser;
}
