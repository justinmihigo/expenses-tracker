
class SavingsPlan {
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final String description;

  SavingsPlan({
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.description,
  });

  double get progressPercentage => (currentAmount / targetAmount) * 100;
  double get remainingAmount => targetAmount - currentAmount;
  int get daysRemaining => targetDate.difference(DateTime.now()).inDays;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate.toIso8601String(),
      'description': description,
    };
  }

  factory SavingsPlan.fromJson(Map<String, dynamic> json) {
    return SavingsPlan(
      title: json['title'] as String,
      targetAmount: json['targetAmount'] as double,
      currentAmount: json['currentAmount'] as double,
      targetDate: DateTime.parse(json['targetDate'] as String),
      description: json['description'] as String,
    );
  }

  SavingsPlan copyWith({
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    String? description,
  }) {
    return SavingsPlan(
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      description: description ?? this.description,
    );
  }
} 