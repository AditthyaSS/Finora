import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'category.g.dart';

@HiveType(typeId: 2)
class Category extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String icon;

  @HiveField(3)
  late int colorValue;

  @HiveField(4)
  late String type; // 'income' or 'expense'

  @HiveField(5)
  bool isDefault;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    required this.type,
    this.isDefault = false,
  });

  Color get color => Color(colorValue);

  IconData get iconData {
    switch (icon) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'movie':
        return Icons.movie;
      case 'receipt_long':
        return Icons.receipt_long;
      case 'medical_services':
        return Icons.medical_services;
      case 'school':
        return Icons.school;
      case 'flight':
        return Icons.flight;
      case 'local_grocery_store':
        return Icons.local_grocery_store;
      case 'work':
        return Icons.work;
      case 'laptop':
        return Icons.laptop;
      case 'trending_up':
        return Icons.trending_up;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'more_horiz':
      default:
        return Icons.more_horiz;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'colorValue': colorValue,
    'type': type,
    'isDefault': isDefault,
  };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'],
    name: json['name'],
    icon: json['icon'],
    colorValue: json['colorValue'] ?? json['color'],
    type: json['type'],
    isDefault: json['isDefault'] ?? false,
  );
}
