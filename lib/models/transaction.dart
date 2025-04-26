import 'package:flutter/foundation.dart';

class TransactionData {
  final String title;
  final String date;
  final double amount;
  final bool isCredit;
  final bool isScheduled;
  final DateTime? scheduledDate;

  String? get scheduledDateStr => scheduledDate?.toIso8601String();

  TransactionData({
    required this.title,
    required this.date,
    required this.amount,
    required this.isCredit,
    required this.isScheduled,
    this.scheduledDate,
  });

  TransactionData copyWith({
    String? title,
    String? date,
    double? amount,
    bool? isCredit,
    bool? isScheduled,
    DateTime? scheduledDate,
  }) {
    return TransactionData(
      title: title ?? this.title,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      isCredit: isCredit ?? this.isCredit,
      isScheduled: isScheduled ?? this.isScheduled,
      scheduledDate: scheduledDate ?? this.scheduledDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date,
      'amount': amount,
      'isCredit': isCredit,
      'isScheduled': isScheduled,
      'scheduledDate': scheduledDateStr,
    };
  }

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
      title: json['title'] as String,
      date: json['date'] as String,
      amount: json['amount'] as double,
      isCredit: json['isCredit'] as bool,
      isScheduled: json['isScheduled'] as bool,
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'] as String)
          : null,
    );
  }
} 