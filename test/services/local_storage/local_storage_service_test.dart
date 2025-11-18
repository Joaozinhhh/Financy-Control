import 'package:financy_control/core/models/transaction_model.dart';
import 'package:financy_control/services/storage/impl/local_storage_service.dart';
import 'package:financy_control/services/storage/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late StorageService storage;

  setUp(() async {
    // Set up mock SharedPreferences with empty values
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService();
    await storage.init();

    // Clear all data before each test
    await storage.clearAll();
  });

  group('User Management', () {
    test('should save and retrieve user', () async {
      // Arrange
      const userId = '123';
      const name = 'John Doe';
      const email = 'john@example.com';
      const password = 'password123';

      // Act
      final success = await storage.saveUser(
        id: userId,
        name: name,
        email: email,
        password: password,
      );

      // Assert
      expect(success, true);

      // Verify credentials
      final user = await storage.verifyCredentials(
        email: email,
        password: password,
      );
      expect(user, isNotNull);
      expect(user!.id, userId);
      expect(user.name, name);
      expect(user.email, email);
    });

    test('should prevent duplicate email registration', () async {
      // Arrange
      const email = 'john@example.com';
      await storage.saveUser(
        id: '1',
        name: 'John Doe',
        email: email,
        password: 'pass1',
      );

      // Act
      final success = await storage.saveUser(
        id: '2',
        name: 'Jane Doe',
        email: email,
        password: 'pass2',
      );

      // Assert
      expect(success, false);
    });

    test('should return null for invalid credentials', () async {
      // Arrange
      await storage.saveUser(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        password: 'correct_password',
      );

      // Act
      final user = await storage.verifyCredentials(
        email: 'john@example.com',
        password: 'wrong_password',
      );

      // Assert
      expect(user, isNull);
    });

    test('should set and get current user', () async {
      // Arrange
      const userId = '123';
      await storage.saveUser(
        id: userId,
        name: 'John Doe',
        email: 'john@example.com',
        password: 'password123',
      );

      // Act
      await storage.setCurrentUser(userId);
      final currentUser = await storage.getCurrentUser();

      // Assert
      expect(currentUser, isNotNull);
      expect(currentUser!.id, userId);
    });

    test('should clear current user on logout', () async {
      // Arrange
      const userId = '123';
      await storage.saveUser(
        id: userId,
        name: 'John Doe',
        email: 'john@example.com',
        password: 'password123',
      );
      await storage.setCurrentUser(userId);

      // Act
      await storage.clearCurrentUser();
      final currentUser = await storage.getCurrentUser();

      // Assert
      expect(currentUser, isNull);
    });
  });

  group('Transaction Management', () {
    test('should save and retrieve transaction', () async {
      // Arrange
      final transaction = TransactionModel(
        id: '1',
        amount: 100.0,
        description: 'Test Income',
        date: DateTime(2024, 1, 1),
        category: IncomeCategory.salary,
      );

      // Act
      await storage.saveTransaction(transaction);
      final transactions = await storage.getTransactions();

      // Assert
      expect(transactions.length, 1);
      expect(transactions.first.id, transaction.id);
      expect(transactions.first.amount, transaction.amount);
      expect(transactions.first.description, transaction.description);
    });

    test('should filter transactions by date range', () async {
      // Arrange
      await storage.saveTransaction(
        TransactionModel(
          id: '1',
          amount: 100.0,
          description: 'Old Transaction',
          date: DateTime(2024, 1, 1),
          category: IncomeCategory.salary,
        ),
      );
      await storage.saveTransaction(
        TransactionModel(
          id: '2',
          amount: 200.0,
          description: 'New Transaction',
          date: DateTime(2024, 6, 1),
          category: IncomeCategory.salary,
        ),
      );

      // Act
      final filtered = await storage.getTransactions(
        startDate: DateTime(2024, 5, 1),
      );

      // Assert
      expect(filtered.length, 1);
      expect(filtered.first.description, 'New Transaction');
    });

    test('should delete transaction', () async {
      // Arrange
      final transaction = TransactionModel(
        id: '1',
        amount: 100.0,
        description: 'Test',
        date: DateTime.now(),
        category: IncomeCategory.salary,
      );
      await storage.saveTransaction(transaction);

      // Act
      await storage.deleteTransaction(transaction.id);
      final transactions = await storage.getTransactions();

      // Assert
      expect(transactions, isEmpty);
    });

    test('should calculate balance correctly', () async {
      // Arrange
      await storage.saveTransaction(
        TransactionModel(
          id: '1',
          amount: 100.0,
          description: 'Income',
          date: DateTime.now(),
          category: IncomeCategory.salary,
        ),
      );
      await storage.saveTransaction(
        TransactionModel(
          id: '2',
          amount: -50.0,
          description: 'Expense',
          date: DateTime.now(),
          category: ExpenseCategory.food,
        ),
      );

      // Act
      final balance = await storage.getBalance();

      // Assert
      expect(balance, 50.0);
    });
  });
}
