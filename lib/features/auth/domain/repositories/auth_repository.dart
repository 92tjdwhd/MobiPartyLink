import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_user_entity.dart';

abstract class AuthRepository {
  /// 현재 인증된 사용자 정보를 가져옵니다
  Future<Either<Failure, AuthUserEntity?>> getCurrentUser();

  /// 익명 로그인을 수행합니다
  Future<Either<Failure, AuthUserEntity>> signInAnonymously();

  /// 로그아웃을 수행합니다
  Future<Either<Failure, void>> signOut();

  /// 인증 상태 변화를 스트림으로 구독합니다
  Stream<AuthUserEntity?> get authStateChanges;
}
