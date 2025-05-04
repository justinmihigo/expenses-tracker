import 'package:uuid/uuid.dart';

class BudgetGoal {
  final String id;
  final double monthlyIncome;
  final double savingsTarget;
  final Map<String, double> categoryLimits;
  final DateTime startDate;
  final DateTime endDate;

  BudgetGoal({
    String? id,
    required this.monthlyIncome,
    required this.savingsTarget,
    required this.categoryLimits,
    required this.startDate,
    required this.endDate,
  }) : id = id ?? const Uuid().v4();

  double get totalSpendingLimit => monthlyIncome - savingsTarget;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'monthlyIncome': monthlyIncome,
      'savingsTarget': savingsTarget,
      'categoryLimits': categoryLimits,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  factory BudgetGoal.fromMap(Map<String, dynamic> map) {
    return BudgetGoal(
      id: map['id'] as String,
      monthlyIncome: (map['monthlyIncome'] as num).toDouble(),
      savingsTarget: (map['savingsTarget'] as num).toDouble(),
      categoryLimits: Map<String, double>.from(map['categoryLimits'] as Map),
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
    );
  }

  BudgetGoal copyWith({
    double? monthlyIncome,
    double? savingsTarget,
    Map<String, double>? categoryLimits,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return BudgetGoal(
      id: id,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      savingsTarget: savingsTarget ?? this.savingsTarget,
      categoryLimits: categoryLimits ?? this.categoryLimits,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
} 