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
  others
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

  // Helper method to format date for storage
  static String formatDateForStorage(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Helper method to parse stored date
  static DateTime parseStoredDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      // Fallback for old format dates
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
      throw FormatException('Invalid date format: $dateStr');
    }
  }

  // Helper method to format date for display
  static String formatDateForDisplay(DateTime date) {
    final months = {
      1: 'Jan', 2: 'Feb', 3: 'Mar', 4: 'Apr', 5: 'May', 6: 'Jun',
      7: 'Jul', 8: 'Aug', 9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dec'
    };
    return "${months[date.month]} ${date.day}, ${date.year}";
  }

  // Getter for parsed date
  DateTime get parsedDate => parseStoredDate(date);

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
    final categoryStr = map['category'] as String?;
    TransactionCategory category;
    if (categoryStr != null) {
      category = TransactionCategory.values.firstWhere(
        (e) => e.toString().split('.').last == categoryStr,
        orElse: () => TransactionCategory.others,
      );
    } else {
      // For existing records without a category, determine based on isCredit
      category = map['isCredit'] == 1 
          ? TransactionCategory.otherIncome 
          : TransactionCategory.others;
    }

    return TransactionData(
      id: map['id'] as String,
      title: map['title'] as String,
      date: map['date'] as String,
      amount: (map['amount'] as num).toDouble(),
      isCredit: map['isCredit'] == 1,
      isScheduled: map['isScheduled'] == 1,
      category: category,
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