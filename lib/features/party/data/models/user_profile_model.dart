import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user_profile_entity.dart';

part 'user_profile_model.freezed.dart';
part 'user_profile_model.g.dart';

@freezed
class UserProfileModel with _$UserProfileModel {
  const factory UserProfileModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String nickname,
    @JsonKey(name: 'job_id') String? jobId, // job -> jobId로 변경
    int? power,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _UserProfileModel;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);

  factory UserProfileModel.fromEntity(UserProfileEntity entity) =>
      UserProfileModel(
        id: entity.id,
        userId: entity.userId,
        nickname: entity.nickname,
        jobId: entity.jobId, // job -> jobId로 변경
        power: entity.power,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );
}

extension UserProfileModelX on UserProfileModel {
  UserProfileEntity toEntity() => UserProfileEntity(
        id: id,
        userId: userId,
        nickname: nickname,
        jobId: jobId, // job -> jobId로 변경
        power: power,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
