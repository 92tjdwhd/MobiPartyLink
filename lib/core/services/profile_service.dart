import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String nickname;
  final String job;
  final int power;
  final DateTime createdAt;

  UserProfile({
    required this.nickname,
    required this.job,
    required this.power,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'job': job,
      'power': power,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      nickname: json['nickname'],
      job: json['job'],
      power: json['power'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ProfileService {
  static const String _profileKey = 'user_profile';

  /// 프로필이 존재하는지 확인
  static Future<bool> hasProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_profileKey);
  }

  /// 프로필 저장
  static Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  /// 프로필 로드
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

  /// 프로필 삭제
  static Future<void> deleteProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
  }

  /// 프로필 업데이트
  static Future<void> updateProfile(UserProfile profile) async {
    await saveProfile(profile);
  }
}
