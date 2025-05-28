import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wallet_data.dart';
import '../models/transaction.dart';
import '../sqlite.dart';

class WalletService {
  static const String _walletKey = 'wallet_data';
  static final SQLiteDB _db = SQLiteDB.instance;

  static Future<WalletData> loadWalletData() async {
    final prefs = await SharedPreferences.getInstance();
    final walletJson = prefs.getString(_walletKey);
    
    if (walletJson == null) {
      return WalletData.initial();
    }

    try {
      final Map<String, dynamic> walletMap = json.decode(walletJson);
      final walletData = WalletData.fromJson(walletMap);
      
      // Recalculate total balance from transactions
      double calculatedBalance = walletData.transactions.fold(0.0, (sum, t) {
        return sum + (t.isCredit ? t.amount : -t.amount);
      });
      
      // Return new instance with recalculated balance
      return WalletData(
        totalBalance: calculatedBalance,
        transactions: walletData.transactions,
        upcomingBills: walletData.upcomingBills,
      );
    } catch (e) {
      print('Error loading wallet data: $e');
      return WalletData.initial();
    }
  }

  static Future<void> saveWalletData(WalletData walletData) async {
    // Recalculate balance before saving
    double calculatedBalance = walletData.transactions.fold(0.0, (sum, t) {
      return sum + (t.isCredit ? t.amount : -t.amount);
    });

    // Create new instance with recalculated balance
    final updatedWalletData = WalletData(
      totalBalance: calculatedBalance,
      transactions: walletData.transactions,
      upcomingBills: walletData.upcomingBills,
    );

    final prefs = await SharedPreferences.getInstance();
    final walletJson = json.encode(updatedWalletData.toJson());
    await prefs.setString(_walletKey, walletJson);
  }

  static Future<void> addTransaction(TransactionData transaction, bool isScheduled) async {
    final walletData = await loadWalletData();
    final updatedTransactions = List<TransactionData>.from(walletData.transactions);
    final updatedBills = List<TransactionData>.from(walletData.upcomingBills);
    
    if (isScheduled) {
      updatedBills.add(transaction);
    } else {
      updatedTransactions.add(transaction);
    }

    // Calculate new balance from all transactions
    double newBalance = updatedTransactions.fold(0.0, (sum, t) {
      return sum + (t.isCredit ? t.amount : -t.amount);
    });
    
    final updatedWalletData = WalletData(
      totalBalance: newBalance,
      transactions: updatedTransactions,
      upcomingBills: updatedBills,
    );

    await saveWalletData(updatedWalletData);
  }

  static Future<void> updateTransaction(TransactionData oldTransaction, TransactionData newTransaction) async {
    try {
      // Update in SQLite
      await _db.updateTransaction(oldTransaction.id, newTransaction.toMap());
      
      // Update total balance in SQLite
      final currentBalance = await _db.getTotalBalance();
      final oldAmount = oldTransaction.isCredit ? oldTransaction.amount : -oldTransaction.amount;
      final newAmount = newTransaction.isCredit ? newTransaction.amount : -newTransaction.amount;
      final balanceDiff = newAmount - oldAmount;
      final newBalance = currentBalance + balanceDiff;
      await _db.updateTotalBalance(newBalance);
      
      // Also update SharedPreferences for backward compatibility
      final walletData = await loadWalletData();
      final updatedTransactions = List<TransactionData>.from(walletData.transactions);
      final updatedBills = List<TransactionData>.from(walletData.upcomingBills);
      
      // Remove old transaction using ID
      if (oldTransaction.isScheduled) {
        updatedBills.removeWhere((t) => t.id == oldTransaction.id);
      } else {
        updatedTransactions.removeWhere((t) => t.id == oldTransaction.id);
      }

      // Add new transaction
      if (newTransaction.isScheduled) {
        updatedBills.add(newTransaction);
      } else {
        updatedTransactions.add(newTransaction);
      }

      final updatedWalletData = WalletData(
        totalBalance: newBalance,
        transactions: updatedTransactions,
        upcomingBills: updatedBills,
      );

      await saveWalletData(updatedWalletData);
    } catch (e) {
      print('Error updating transaction: $e');
      rethrow;
    }
  }

  static Future<void> deleteTransaction(TransactionData transaction) async {
    try {
      // Delete from SQLite
      await _db.deleteTransaction(transaction.id);
      
      // Update total balance in SQLite
      final currentBalance = await _db.getTotalBalance();
      final newBalance = currentBalance - (transaction.isCredit ? transaction.amount : -transaction.amount);
      await _db.updateTotalBalance(newBalance);
      
      // Also update SharedPreferences for backward compatibility
      final walletData = await loadWalletData();
      final updatedTransactions = List<TransactionData>.from(walletData.transactions);
      final updatedBills = List<TransactionData>.from(walletData.upcomingBills);
      
      if (transaction.isScheduled) {
        updatedBills.removeWhere((t) => t.id == transaction.id);
      } else {
        updatedTransactions.removeWhere((t) => t.id == transaction.id);
      }

      final updatedWalletData = WalletData(
        totalBalance: newBalance,
        transactions: updatedTransactions,
        upcomingBills: updatedBills,
      );

      await saveWalletData(updatedWalletData);
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    }
  }
} 