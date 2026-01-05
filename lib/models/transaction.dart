import 'package:hive/hive.dart';

part 'transaction.g.dart';

enum TransactionType { income, expense }

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late double amount;

  @HiveField(3)
  late String category;

  @HiveField(4)
  late DateTime date;

  @HiveField(5)
  late String type; // 'income' or 'expense'

  @HiveField(6)
  String? notes;

  @HiveField(7)
  late DateTime createdAt;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isExpense => type == 'expense';
  bool get isIncome => type == 'income';

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'category': category,
    'date': date.toIso8601String(),
    'type': type,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    title: json['title'],
    amount: json['amount'].toDouble(),
    category: json['category'],
    date: DateTime.parse(json['date']),
    type: json['type'],
    notes: json['notes'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}
