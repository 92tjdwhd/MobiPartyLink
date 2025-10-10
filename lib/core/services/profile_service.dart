import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  UserProfile({
    required this.id,
    required this.nickname,
    this.jobId,
    this.power,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      nickname: json['nickname'],
      jobId: json['jobId'] ?? json['job'], // 기존 'job' 필드와 호환성 유지
      power: json['power'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
  final String id;
  final String nickname;
  final String? jobId;
  final int? power;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'jobId': jobId,
      'power': power,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // copyWith 메서드
  UserProfile copyWith({
    String? id,
    String? nickname,
    String? jobId,
    int? power,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      jobId: jobId ?? this.jobId,
      power: power ?? this.power,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // 기존 코드와의 호환성을 위한 getter
  String get job => jobId ?? '';
}

class ProfileService {
  static const String _profileKey = 'user_profile';
  static const String _profileListKey = 'user_profile_list';
  static const String _mainProfileKey = 'main_profile_id';

  /// 프로필이 존재하는지 확인
  static Future<bool> hasProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_profileKey);
  }

  /// 프로필 저장 (기존 단일 프로필용)
  static Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  /// 프로필 로드 (기존 단일 프로필용)
  static Future<UserProfile?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_profileKey);

    if (profileJson == null) return null;

    try {
      final profileData = jsonDecode(profileJson) as Map<String, dynamic>;
      return UserProfile.fromJson(profileData);
    } catch (e) {
      return null;
    }
  }

  /// 프로필 삭제 (기존 단일 프로필용)
  static Future<void> deleteProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
  }

  /// 프로필 업데이트 (기존 단일 프로필용)
  static Future<void> updateProfile(UserProfile profile) async {
    await saveProfile(profile);
  }

  /// 프로필 리스트 가져오기 (최대 3개)
  static Future<List<UserProfile>> getProfileList() async {
    final prefs = await SharedPreferences.getInstance();
    final profileListJson = prefs.getString(_profileListKey);

    if (profileListJson == null) return [];

    try {
      final List<dynamic> profileListData = jsonDecode(profileListJson);
      return profileListData
          .map((data) => UserProfile.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 프로필 리스트에 프로필 추가 (최대 3개)
  static Future<bool> addProfileToList(UserProfile profile) async {
    final profiles = await getProfileList();

    if (profiles.length >= 3) {
      return false; // 최대 3개 제한
    }

    profiles.add(profile);
    await _saveProfileList(profiles);

    // 첫 번째 프로필이면 자동으로 메인 프로필로 설정
    if (profiles.length == 1) {
      await setMainProfile(profile.id);
    }

    return true;
  }

  /// 프로필 리스트에서 프로필 업데이트
  static Future<bool> updateProfileInList(UserProfile updatedProfile) async {
    final profiles = await getProfileList();

    final index = profiles.indexWhere((p) => p.id == updatedProfile.id);
    if (index == -1) return false;

    profiles[index] = updatedProfile;
    await _saveProfileList(profiles);
    return true;
  }

  /// 프로필 리스트에서 프로필 삭제
  static Future<bool> deleteProfileFromList(String profileId) async {
    final profiles = await getProfileList();
    final mainProfileId = await getMainProfileId();

    final index = profiles.indexWhere((p) => p.id == profileId);
    if (index == -1) return false;

    profiles.removeAt(index);
    await _saveProfileList(profiles);

    // 삭제된 프로필이 메인 프로필이었다면
    if (mainProfileId == profileId) {
      if (profiles.isNotEmpty) {
        // 다른 프로필이 있으면 첫 번째 프로필을 메인으로 설정
        await setMainProfile(profiles.first.id);
      } else {
        // 프로필이 없으면 메인 프로필 설정 해제
        await clearMainProfile();
      }
    }

    return true;
  }

  /// 프로필 리스트 저장
  static Future<void> _saveProfileList(List<UserProfile> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    final profileListJson =
        jsonEncode(profiles.map((p) => p.toJson()).toList());
    await prefs.setString(_profileListKey, profileListJson);
  }

  /// 프로필 리스트 전체 삭제
  static Future<void> clearProfileList() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileListKey);
  }

  /// 메인 프로필 ID 설정
  static Future<bool> setMainProfile(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_mainProfileKey, profileId);
  }

  /// 메인 프로필 ID 조회
  static Future<String?> getMainProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_mainProfileKey);
  }

  /// 메인 프로필 객체 조회
  static Future<UserProfile?> getMainProfile() async {
    final mainProfileId = await getMainProfileId();
    if (mainProfileId == null) return null;

    final profiles = await getProfileList();
    try {
      return profiles.firstWhere((profile) => profile.id == mainProfileId);
    } catch (e) {
      // 메인 프로필이 삭제된 경우 메인 프로필 설정 해제
      await clearMainProfile();
      return null;
    }
  }

  /// 메인 프로필 설정 해제
  static Future<void> clearMainProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_mainProfileKey);
  }

  /// 메인 프로필이 설정되어 있는지 확인
  static Future<bool> hasMainProfile() async {
    final mainProfileId = await getMainProfileId();
    if (mainProfileId == null) return false;

    final profiles = await getProfileList();
    return profiles.any((profile) => profile.id == mainProfileId);
  }
}
