// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    TransactionModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      category: const TransactionCategoryConverter().fromJson(
        json['category'] as String,
      ),
    );

Map<String, dynamic> _$TransactionModelToJson(
  TransactionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'amount': instance.amount,
  'description': instance.description,
  'date': instance.date.toIso8601String(),
  'category': const TransactionCategoryConverter().toJson(instance.category),
};

TransactionInputModel _$TransactionInputModelFromJson(
  Map<String, dynamic> json,
) => TransactionInputModel(
  amount: (json['amount'] as num?)?.toDouble(),
  description: json['description'] as String,
  date: DateTime.parse(json['date'] as String),
  category: const TransactionCategoryConverter().fromJson(
    json['category'] as String,
  ),
);

Map<String, dynamic> _$TransactionInputModelToJson(
  TransactionInputModel instance,
) => <String, dynamic>{
  'amount': ?instance.amount,
  'description': instance.description,
  'date': instance.date.toIso8601String(),
  'category': const TransactionCategoryConverter().toJson(instance.category),
};
