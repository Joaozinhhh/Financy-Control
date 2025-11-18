import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

@JsonSerializable()
class UserInputModel {
  @JsonKey(includeIfNull: false)
  final String? name;
  final String email;
  final String password;

  UserInputModel({
    this.name,
    required this.email,
    required this.password,
  });

  factory UserInputModel.fromJson(Map<String, dynamic> json) =>
      _$UserInputModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserInputModelToJson(this);
}
