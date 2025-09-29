import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_entity.freezed.dart';

@freezed
class UserProfileEntity with _$UserProfileEntity {
  const factory UserProfileEntity({
    required String id,
    required String userId,
    required String nickname,
    String? jobId, // job -> jobId로 변경
    int? power,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserProfileEntity;
}
