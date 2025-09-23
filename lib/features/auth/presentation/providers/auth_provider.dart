import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in_anonymously.dart';
import '../../domain/usecases/sign_out.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<AuthUserEntity?> build() async {
    // 초기 로드 시 현재 사용자 정보 가져오기
    final getCurrentUser = ref.read(getCurrentUserProvider);
    final result = await getCurrentUser();
    return result.fold(
      (failure) => null,
      (user) => user,
    );
  }

  /// 익명 로그인
  Future<void> signInAnonymously() async {
    state = const AsyncLoading();

    final signInAnonymously = ref.read(signInAnonymouslyProvider);
    final result = await signInAnonymously();

    result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
      },
      (user) {
        state = AsyncData(user);
      },
    );
  }

  /// 로그아웃
  Future<void> signOut() async {
    state = const AsyncLoading();

    final signOut = ref.read(signOutProvider);
    final result = await signOut();

    result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
      },
      (_) {
        state = const AsyncData(null);
      },
    );
  }

  /// 현재 사용자 정보 새로고침
  Future<void> refresh() async {
    final getCurrentUser = ref.read(getCurrentUserProvider);
    final result = await getCurrentUser();

    result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
      },
      (user) {
        state = AsyncData(user);
      },
    );
  }
}

// UseCase Providers
@riverpod
GetCurrentUser getCurrentUser(GetCurrentUserRef ref) {
  return GetCurrentUser(ref.watch(authRepositoryProvider));
}

@riverpod
SignInAnonymously signInAnonymously(SignInAnonymouslyRef ref) {
  return SignInAnonymously(ref.watch(authRepositoryProvider));
}

@riverpod
SignOut signOut(SignOutRef ref) {
  return SignOut(ref.watch(authRepositoryProvider));
}
