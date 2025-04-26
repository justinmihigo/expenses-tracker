import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wallet_data.dart';
import '../models/transaction.dart';

class WalletService {
  static const String _walletKey = 'wallet_data';

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
    final walletData = await loadWalletData();
    final updatedTransactions = List<TransactionData>.from(walletData.transactions);
    final updatedBills = List<TransactionData>.from(walletData.upcomingBills);
    
    // Remove old transaction
    if (oldTransaction.isScheduled) {
      updatedBills.removeWhere((t) => t.title == oldTransaction.title && t.date == oldTransaction.date);
    } else {
      updatedTransactions.removeWhere((t) => t.title == oldTransaction.title && t.date == oldTransaction.date);
    }

    // Add new transaction
    if (newTransaction.isScheduled) {
      updatedBills.add(newTransaction);
    } else {
      updatedTransactions.add(newTransaction);
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

  static Future<void> deleteTransaction(TransactionData transaction) async {
    final walletData = await loadWalletData();
    final updatedTransactions = List<TransactionData>.from(walletData.transactions);
    final updatedBills = List<TransactionData>.from(walletData.upcomingBills);
    
    if (transaction.isScheduled) {
      updatedBills.removeWhere((t) => t.title == transaction.title && t.date == transaction.date);
    } else {
      updatedTransactions.removeWhere((t) => t.title == transaction.title && t.date == transaction.date);
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
} 