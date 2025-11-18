import 'package:financy_control/core/models/transaction_model.dart';
import 'package:financy_control/core/models/user_model.dart';
import 'package:financy_control/services/local_storage/local_storage_service.dart';
import 'package:uuid/v7.dart';

const Duration mockNetworkDelay = Duration(milliseconds: 500);

final _storage = LocalStorageService();

Future<UserModel> mockCreateUser(UserInputModel input) async {
  await Future.delayed(mockNetworkDelay);

  // Generate a unique user ID
  final userId = const UuidV7().generate();

  // Save user to local storage
  final success = await _storage.saveUser(
    id: userId,
    name: input.name ?? 'User',
    email: input.email,
    password: input.password,
  );

  if (!success) {
    throw Exception('User with this email already exists');
  }

  final user = UserModel(
    id: userId,
    name: input.name ?? 'User',
    email: input.email,
  );

  // Set as current user
  await _storage.setCurrentUser(userId);
  _currentUser = user;

  return user;
}

Future<UserModel> mockLogin(UserInputModel input) async {
  await Future.delayed(mockNetworkDelay);

  // Verify credentials against local storage
  final user = await _storage.verifyCredentials(
    email: input.email,
    password: input.password,
  );

  if (user == null) {
    throw Exception('Invalid email or password');
  }

  // Set as current user
  await _storage.setCurrentUser(user.id);
  _currentUser = user;

  return user;
}

Future<bool> mockForgotPassword(String email) async {
  await Future.delayed(mockNetworkDelay);

  // Check if user exists
  final user = await _storage.getUserByEmail(email);

  if (user == null) {
    throw Exception('User with this email not found');
  }

  // In a real app, you'd send a password reset email
  // For now, just return success
  return true;
}

Future<TransactionModel> mockCreateTransaction(
  TransactionInputModel input,
) async {
  await Future.delayed(mockNetworkDelay);

  final transaction = TransactionModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    amount: input.category.income ? input.amount ?? 0.0 : -(input.amount ?? 0.0),
    description: input.description,
    date: input.date,
    category: input.category,
  );

  await _storage.saveTransaction(transaction);
  return transaction;
}

Future<TransactionModel> mockUpdateTransaction(
  String id,
  TransactionInputModel input,
) async {
  await Future.delayed(mockNetworkDelay);

  // Get existing transaction
  final existingTransaction = await _storage.getTransactionById(id);
  if (existingTransaction == null) {
    throw Exception('Transaction not found');
  }

  final updatedTransaction = TransactionModel(
    id: id,
    amount: input.category.income
        ? input.amount ?? existingTransaction.amount
        : -(input.amount ?? existingTransaction.amount.abs()),
    description: input.description,
    date: input.date,
    category: input.category,
  );

  await _storage.saveTransaction(updatedTransaction);
  return updatedTransaction;
}

Future<bool> mockDeleteTransaction(String id) async {
  await Future.delayed(mockNetworkDelay);

  final success = await _storage.deleteTransaction(id);
  if (!success) {
    throw Exception('Transaction not found');
  }

  return true;
}

Future<List<TransactionModel>> mockGetTransactions({
  DateTime? startDate,
  DateTime? endDate,
}) async {
  await Future.delayed(mockNetworkDelay);

  return _storage.getTransactions(
    startDate: startDate,
    endDate: endDate,
  );
}

Future<Map<String, String>> mockGetUserProfile() async {
  await Future.delayed(mockNetworkDelay);

  final user = await _storage.getCurrentUser();
  if (user == null) {
    throw Exception('No user logged in');
  }

  return {
    'name': user.name,
    'email': user.email,
    'photoUrl': 'https://i.pravatar.cc/300',
  };
}

Future<bool> mockUpdateUserName(String newName) async {
  await Future.delayed(mockNetworkDelay);

  final user = await _storage.getCurrentUser();
  if (user == null) {
    throw Exception('No user logged in');
  }

  return _storage.updateUserName(user.id, newName);
}

Future<bool> mockUpdateUserPassword(String newPassword) async {
  await Future.delayed(mockNetworkDelay);

  final user = await _storage.getCurrentUser();
  if (user == null) {
    throw Exception('No user logged in');
  }

  // In a real app, you'd need the old password to verify
  // For now, we'll skip that check in the mock
  // This would need to be enhanced for production
  return true;
}

Future<void> mockLogout() async {
  await Future.delayed(mockNetworkDelay);

  await _storage.clearCurrentUser();
  _currentUser = null;
}

Future<double> mockGetBalance() async {
  await Future.delayed(mockNetworkDelay);

  return _storage.getBalance();
}

UserModel? _currentUser;

Future<UserModel?> mockCheckAuthStatus() async {
  await Future.delayed(mockNetworkDelay);

  // Check if there's a user in local storage
  _currentUser = await _storage.getCurrentUser();
  return _currentUser;
}

UserModel? mockGetCurrentUser() {
  return _currentUser;
}
