import 'package:uuid/uuid.dart';

enum TransactionCategory {
  // Income categories
  salary,
  investment,
  business,
  otherIncome,
  
  // Expense categories
  food,
  transportation,
  housing,
  utilities,
  entertainment,
  healthcare,
  education,
  shopping,
  travel,
  otherExpense
}

class TransactionData {
  final String id;
  final String title;
  final String date;
  final double amount;
  final bool isCredit;
  final bool isScheduled;
  final String? scheduledDateStr;
  final TransactionCategory category;

  TransactionData({
    String? id,
    required this.title,
    required this.date,
    required this.amount,
    required this.isCredit,
    required this.category,
    this.isScheduled = false,
    DateTime? scheduledDate,
  }) : id = id ?? const Uuid().v4(),
       scheduledDateStr = scheduledDate?.toIso8601String();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'amount': amount,
      'isCredit': isCredit ? 1 : 0,
      'isScheduled': isScheduled ? 1 : 0,
      'scheduledDate': scheduledDateStr,
      'category': category.toString().split('.').last,
    };
  }

  factory TransactionData.fromMap(Map<String, dynamic> map) {
    return TransactionData(
      id: map['id'] as String,
      title: map['title'] as String,
      date: map['date'] as String,
      amount: (map['amount'] as num).toDouble(),
      isCredit: map['isCredit'] == 1,
      isScheduled: map['isScheduled'] == 1,
      category: TransactionCategory.values.firstWhere(
        (e) => e.toString().split('.').last == map['category'],
        orElse: () => TransactionCategory.otherExpense,
      ),
      scheduledDate: map['scheduledDate'] != null 
          ? DateTime.parse(map['scheduledDate'] as String)
          : null,
    );
  }

  TransactionData copyWith({
    String? title,
    String? date,
    double? amount,
    bool? isCredit,
    bool? isScheduled,
    DateTime? scheduledDate,
    TransactionCategory? category,
  }) {
    return TransactionData(
      id: id,
      title: title ?? this.title,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      isCredit: isCredit ?? this.isCredit,
      isScheduled: isScheduled ?? this.isScheduled,
      category: category ?? this.category,
      scheduledDate: scheduledDate ?? (scheduledDateStr != null ? DateTime.parse(scheduledDateStr!) : null),
    );
  }

  DateTime? get scheduledDate => scheduledDateStr != null 
      ? DateTime.parse(scheduledDateStr!) 
      : null;
}