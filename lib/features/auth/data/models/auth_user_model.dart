import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/auth_user_entity.dart';

part 'auth_user_model.freezed.dart';
part 'auth_user_model.g.dart';

@freezed
class AuthUserModel with _$AuthUserModel {
  const factory AuthUserModel({
    required String id,
    required String email,
    required bool isAnonymous,
    required DateTime createdAt,
    DateTime? lastSignInAt,
  }) = _AuthUserModel;

  factory AuthUserModel.fromJson(Map<String, dynamic> json) =>
      _$AuthUserModelFromJson(json);

  factory AuthUserModel.fromEntity(AuthUserEntity entity) => AuthUserModel(
        id: entity.id,
        email: entity.email,
        isAnonymous: entity.isAnonymous,
        createdAt: entity.createdAt,
        lastSignInAt: entity.lastSignInAt,
      );
}

extension AuthUserModelX on AuthUserModel {
  AuthUserEntity toEntity() => AuthUserEntity(
        id: id,
        email: email,
        isAnonymous: isAnonymous,
        createdAt: createdAt,
        lastSignInAt: lastSignInAt,
      );
}
