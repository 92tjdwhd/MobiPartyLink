import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String id;
  final String nickname;
  final String? jobId;
  final int? power;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.nickname,
    this.jobId,
    this.power,
    required this.createdAt,
    required this.updatedAt,
  });

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

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      nickname: json['nickname'],
      jobId: json['jobId'],
      power: json['power'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // 기존 코드와의 호환성을 위한 getter
  String get job => jobId ?? '';
}

class ProfileService {
  static const String _profileKey = 'user_profile';
  static const String _profileListKey = 'user_profile_list';

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

    final index = profiles.indexWhere((p) => p.id == profileId);
    if (index == -1) return false;

    profiles.removeAt(index);
    await _saveProfileList(profiles);
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
}
