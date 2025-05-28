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

  static String formatDateForStorage(DateTime date) {
    // Always store in ISO format to avoid ambiguity
    return date.toIso8601String();
  }

  static DateTime parseStoredDate(String dateStr) {
    try {
      // First try parsing as ISO format
      return DateTime.parse(dateStr);
    } catch (e) {
      // If parsing fails, handle special cases
      if (dateStr == "Today") {
        return DateTime.now();
      } else if (dateStr == "Yesterday") {
        return DateTime.now().subtract(const Duration(days: 1));
      }
      // Try parsing as MMM DD, YYYY format
      final months = {
        'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
        'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
      };
      
      final parts = dateStr.split(' ');
      if (parts.length == 3) {
        final month = months[parts[0]] ?? 1;
        final day = int.parse(parts[1].replaceAll(',', ''));
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
      // If all parsing fails, return current date
      return DateTime.now();
    }
  }

  static String formatDateForDisplay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
    }
  }

  static String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  DateTime get parsedDate => parseStoredDate(date);
  DateTime? get parsedScheduledDate => 
    scheduledDateStr != null ? parseStoredDate(scheduledDateStr!) : null;

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