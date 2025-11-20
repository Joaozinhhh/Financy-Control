import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financy_control/core/models/transaction_model.dart';
import 'package:financy_control/services/storage/storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseStorageService implements StorageService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;
  CollectionReference<Map<String, dynamic>> get userCollection => _db.collection('users');
  CollectionReference<Map<String, dynamic>> get transactionCollection => _db.collection('transactions');

  @override
  Future<bool> clearAll() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = userCollection.doc(user.uid);
        final transactionsSnapshot = await transactionCollection.where('userId', isEqualTo: user.uid).get();
        for (final doc in transactionsSnapshot.docs) {
          await doc.reference.delete();
        }
        await userDoc.delete();
        if (!kDebugMode) {
          await user.delete();
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteTransaction(String id) async {
    try {
      await transactionCollection.doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<double> getBalance() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final transactionsSnapshot = await transactionCollection.where('userId', isEqualTo: user.uid).get();
        double balance = 0.0;
        for (final doc in transactionsSnapshot.docs) {
          final data = doc.data();
          balance += (data['amount'] as num).toDouble();
        }
        return balance;
      } else {
        return 0.0;
      }
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Future<TransactionModel?> getTransactionById(String id) async {
    try {
      final doc = await transactionCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        return TransactionModel(
          id: doc.id,
          amount: (data['amount'] as num).toDouble(),
          date: (data['date'] as Timestamp).toDate(),
          category: const TransactionCategoryConverter().fromJson(data['category']),
          description: data['description'] ?? '',
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<TransactionModel>> getTransactions({DateTime? startDate, DateTime? endDate}) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final transactionsSnapshot = await transactionCollection.where('userId', isEqualTo: user.uid).get();
        List<TransactionModel> transactions = [];
        for (final doc in transactionsSnapshot.docs) {
          final data = doc.data();
          final transactionDate = (data['date'] as Timestamp).toDate();
          if ((startDate == null ||
                  transactionDate.isAfter(startDate) ||
                  transactionDate.isAtSameMomentAs(startDate)) &&
              (endDate == null || transactionDate.isBefore(endDate) || transactionDate.isAtSameMomentAs(endDate))) {
            transactions.add(
              TransactionModel(
                id: doc.id,
                amount: (data['amount'] as num).toDouble(),
                date: transactionDate,
                category: const TransactionCategoryConverter().fromJson(data['category']),
                description: data['description'] ?? '',
              ),
            );
          }
        }
        return transactions;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> saveTransaction(TransactionModel transaction) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await transactionCollection.doc(transaction.id).set({
          'userId': user.uid,
          'amount': transaction.amount,
          'date': Timestamp.fromDate(transaction.date),
          'category': const TransactionCategoryConverter().toJson(transaction.category),
          'description': transaction.description,
        });
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> saveUser({
    required String id,
    required String name,
    required String email,
  }) async {
    try {
      await _auth.currentUser?.updateDisplayName(name);
      await userCollection.doc(id).set({
        'name': name,
        'email': email,
      });
      await SharedPreferences.getInstance().then((prefs) async => await prefs.setString('userId', id));
      return true;
    } catch (e) {
      return false;
    }
  }
}
