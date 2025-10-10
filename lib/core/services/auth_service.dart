import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase 익명 인증 및 userId 관리 서비스
class AuthService {

  AuthService({
    required SupabaseClient supabaseClient,
    required SharedPreferences prefs,
  })  : _supabaseClient = supabaseClient,
        _prefs = prefs;
  static const String _userIdKey = 'supabase_user_id';

  final SupabaseClient _supabaseClient;
  final SharedPreferences _prefs;

  /// userId 가져오기 (로컬 우선, 없으면 Supabase 세션에서)
  Future<String?> getUserId() async {
    // 1. 로컬에서 userId 확인
    final localUserId = _prefs.getString(_userIdKey);
    if (localUserId != null) {
      print('✅ 로컬 userId 사용: $localUserId');
      return localUserId;
    }

    // 2. Supabase 세션에서 userId 확인
    final currentUser = _supabaseClient.auth.currentUser;
    if (currentUser != null) {
      final userId = currentUser.id;
      await _saveLocalUserId(userId);
      print('✅ Supabase 세션 userId 사용: $userId');
      return userId;
    }

    // 3. userId 없음
    print('⚠️ userId 없음');
    return null;
  }

  /// userId 확보 (없으면 익명 로그인)
  Future<String> ensureUserId() async {
    // 1. 기존 userId 확인
    final existingUserId = await getUserId();
    if (existingUserId != null) {
      return existingUserId;
    }

    // 2. 익명 로그인 (최초 1회만 API 호출)
    try {
      print('🔐 익명 로그인 시작...');
      final response = await _supabaseClient.auth.signInAnonymously();
      final userId = response.user?.id;

      if (userId == null) {
        throw Exception('익명 로그인 실패: userId가 null입니다');
      }

      // 3. 로컬에 저장
      await _saveLocalUserId(userId);
      print('✅ 익명 로그인 완료: $userId');

      return userId;
    } catch (e) {
      print('❌ 익명 로그인 에러: $e');
      rethrow;
    }
  }

  /// 로컬에 userId 저장
  Future<void> _saveLocalUserId(String userId) async {
    await _prefs.setString(_userIdKey, userId);
    print('💾 userId 로컬 저장: $userId');
  }

  /// userId 삭제 (로그아웃)
  Future<void> clearUserId() async {
    await _prefs.remove(_userIdKey);
    await _supabaseClient.auth.signOut();
    print('🔓 로그아웃 완료');
  }

  /// userId 존재 여부 확인
  Future<bool> hasUserId() async {
    final userId = await getUserId();
    return userId != null;
  }

  /// Supabase 세션 상태 확인
  bool isSignedIn() {
    return _supabaseClient.auth.currentUser != null;
  }

  /// 현재 사용자 정보
  User? get currentUser => _supabaseClient.auth.currentUser;
}
