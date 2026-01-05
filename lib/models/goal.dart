import 'package:hive/hive.dart';

part 'goal.g.dart';

@HiveType(typeId: 1)
class Goal extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late double targetAmount;

  @HiveField(3)
  late double currentAmount;

  @HiveField(4)
  late DateTime targetDate;

  @HiveField(5)
  String? description;

  @HiveField(6)
  String? aiPlan;

  @HiveField(7)
  late DateTime createdAt;

  @HiveField(8)
  bool isCompleted;

  Goal({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.targetDate,
    this.description,
    this.aiPlan,
    DateTime? createdAt,
    this.isCompleted = false,
  }) : createdAt = createdAt ?? DateTime.now();

  double get progress => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0;
  
  double get remainingAmount => (targetAmount - currentAmount).clamp(0, targetAmount);
  
  int get daysRemaining => targetDate.difference(DateTime.now()).inDays;
  
  double get monthlyTarget {
    final months = daysRemaining / 30;
    return months > 0 ? remainingAmount / months : remainingAmount;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'targetDate': targetDate.toIso8601String(),
    'description': description,
    'aiPlan': aiPlan,
    'createdAt': createdAt.toIso8601String(),
    'isCompleted': isCompleted,
  };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
    id: json['id'],
    title: json['title'],
    targetAmount: json['targetAmount'].toDouble(),
    currentAmount: json['currentAmount']?.toDouble() ?? 0,
    targetDate: DateTime.parse(json['targetDate']),
    description: json['description'],
    aiPlan: json['aiPlan'],
    createdAt: DateTime.parse(json['createdAt']),
    isCompleted: json['isCompleted'] ?? false,
  );
}
