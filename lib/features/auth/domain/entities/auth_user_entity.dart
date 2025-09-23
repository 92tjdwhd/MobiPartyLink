import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user_entity.freezed.dart';

@freezed
class AuthUserEntity with _$AuthUserEntity {
  const factory AuthUserEntity({
    required String id,
    required String email,
    required bool isAnonymous,
    required DateTime createdAt,
    DateTime? lastSignInAt,
  }) = _AuthUserEntity;
}
