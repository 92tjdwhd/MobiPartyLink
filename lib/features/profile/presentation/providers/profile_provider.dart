import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobi_party_link/core/services/profile_service.dart';

// 프로필 새로고침 트리거 Provider
final profileRefreshProvider = StateProvider<int>((ref) => 0);

// 프로필 존재 여부 Provider
final hasProfileProvider = FutureProvider<bool>((ref) async {
  // 프로필 새로고침 트리거를 구독
  ref.watch(profileRefreshProvider);
  return await ProfileService.hasProfile();
});

// 프로필 데이터 Provider
final profileDataProvider = FutureProvider<UserProfile?>((ref) async {
  // 프로필 새로고침 트리거를 구독
  ref.watch(profileRefreshProvider);
  return await ProfileService.getProfile();
});

// 프로필 새로고침 함수
void refreshProfile(WidgetRef ref) {
  ref.read(profileRefreshProvider.notifier).state++;
}
