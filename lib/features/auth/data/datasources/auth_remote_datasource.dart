import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../models/auth_user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthUserEntity?> getCurrentUser();
  Future<AuthUserEntity> signInAnonymously();
  Future<void> signOut();
  Stream<AuthUserEntity?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabaseClient;

  AuthRemoteDataSourceImpl({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  @override
  Future<AuthUserEntity?> getCurrentUser() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return null;

      return AuthUserModel(
        id: user.id,
        email: user.email ?? '',
        isAnonymous: user.isAnonymous,
        createdAt: DateTime.parse(user.createdAt),
        lastSignInAt: user.lastSignInAt != null
            ? DateTime.parse(user.lastSignInAt!)
            : null,
      ).toEntity();
    } catch (e) {
      throw ServerException(message: '사용자 정보를 가져오는데 실패했습니다: $e');
    }
  }

  @override
  Future<AuthUserEntity> signInAnonymously() async {
    try {
      final response = await _supabaseClient.auth.signInAnonymously();

      if (response.user == null) {
        throw ServerException(message: '익명 로그인에 실패했습니다');
      }

      final user = response.user!;
      return AuthUserModel(
        id: user.id,
        email: user.email ?? '',
        isAnonymous: user.isAnonymous,
        createdAt: DateTime.parse(user.createdAt),
        lastSignInAt: user.lastSignInAt != null
            ? DateTime.parse(user.lastSignInAt!)
            : null,
      ).toEntity();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: '익명 로그인 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (e) {
      throw ServerException(message: '로그아웃 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Stream<AuthUserEntity?> get authStateChanges {
    return _supabaseClient.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      if (user == null) return null;

      return AuthUserModel(
        id: user.id,
        email: user.email ?? '',
        isAnonymous: user.isAnonymous,
        createdAt: DateTime.parse(user.createdAt),
        lastSignInAt: user.lastSignInAt != null
            ? DateTime.parse(user.lastSignInAt!)
            : null,
      ).toEntity();
    });
  }
}
