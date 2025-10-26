import 'package:json_annotation/json_annotation.dart';

part 'transaction_model.g.dart';

abstract class TransactionCategory {
  bool get income;
  bool get expense;

  String get description;
}

enum IncomeCategory implements TransactionCategory {
  salary,
  business,
  gift,
  interest,
  other;

  @override
  bool get income => true;
  @override
  bool get expense => false;

  @override
  String get description => name;
}

enum ExpenseCategory implements TransactionCategory {
  food,
  transportation,
  entertainment,
  bills,
  healthcare,
  other;

  @override
  bool get income => false;
  @override
  bool get expense => true;

  @override
  String get description => name;
}

@JsonSerializable()
class TransactionModel {
  final String id;
  final double amount;
  final String description;
  final DateTime date;

  @TransactionCategoryConverter()
  final TransactionCategory category;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.category,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);
}

@JsonSerializable()
class TransactionInputModel {
  @JsonKey(includeIfNull: false)
  final double? amount;
  final String description;
  final DateTime date;

  @TransactionCategoryConverter()
  final TransactionCategory category;

  TransactionInputModel({
    this.amount,
    required this.description,
    required this.date,
    required this.category,
  });

  factory TransactionInputModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionInputModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionInputModelToJson(this);
}

class TransactionCategoryConverter
    implements JsonConverter<TransactionCategory, String> {
  const TransactionCategoryConverter();

  @override
  TransactionCategory fromJson(String json) {
    return IncomeCategory.values.firstWhere(
      (e) => e.name == json,
    );
  }

  @override
  String toJson(TransactionCategory category) {
    return category.income
        ? (category as IncomeCategory).name
        : (category as ExpenseCategory).name;
  }
}
