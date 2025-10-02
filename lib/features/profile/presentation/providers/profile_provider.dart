import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobi_party_link/core/services/profile_service.dart';

// 프로필 새로고침 트리거 Provider
final profileRefreshProvider = StateProvider<int>((ref) => 0);

// 프로필 존재 여부 Provider (프로필 리스트 기반)
final hasProfileProvider = FutureProvider<bool>((ref) async {
  // 프로필 새로고침 트리거를 구독
  ref.watch(profileRefreshProvider);
  final profiles = await ProfileService.getProfileList();
  return profiles.isNotEmpty;
});

// 프로필 데이터 Provider
final profileDataProvider = FutureProvider<UserProfile?>((ref) async {
  // 프로필 새로고침 트리거를 구독
  ref.watch(profileRefreshProvider);
  return ProfileService.getMainProfile();
});

// 프로필 리스트 Provider (최대 3개)
final profileListProvider = FutureProvider<List<UserProfile>>((ref) async {
  // 프로필 새로고침 트리거를 구독
  ref.watch(profileRefreshProvider);
  return ProfileService.getProfileList();
});

// 메인 프로필 ID Provider
final mainProfileIdProvider = FutureProvider<String?>((ref) async {
  // 프로필 새로고침 트리거를 구독
  ref.watch(profileRefreshProvider);
  return ProfileService.getMainProfileId();
});

// 메인 프로필 객체 Provider
final mainProfileProvider = FutureProvider<UserProfile?>((ref) async {
  // 프로필 새로고침 트리거를 구독
  ref.watch(profileRefreshProvider);
  return ProfileService.getMainProfile();
});

// 프로필 새로고침 함수
void refreshProfile(WidgetRef ref) {
  ref.read(profileRefreshProvider.notifier).state++;
}
