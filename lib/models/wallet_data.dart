import 'transaction.dart';

class WalletData {
  final double totalBalance;
  final List<TransactionData> transactions;
  final List<TransactionData> upcomingBills;

  WalletData({
    required this.totalBalance,
    required this.transactions,
    required this.upcomingBills,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalBalance': totalBalance,
      'transactions': transactions.map((x) => x.toMap()).toList(),
      'upcomingBills': upcomingBills.map((x) => x.toMap()).toList(),
    };
  }

  factory WalletData.fromJson(Map<String, dynamic> json) {
    return WalletData(
      totalBalance: json['totalBalance'] as double,
      transactions: (json['transactions'] as List)
          .map((x) => TransactionData.fromMap(x as Map<String, dynamic>))
          .toList(),
      upcomingBills: (json['upcomingBills'] as List)
          .map((x) => TransactionData.fromMap(x as Map<String, dynamic>))
          .toList(),
    );
  }

  factory WalletData.initial() {
    return WalletData(
      totalBalance: 0,
      transactions: [],
      upcomingBills: [],
    );
  }
}