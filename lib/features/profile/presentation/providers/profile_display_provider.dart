import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobi_party_link/core/services/profile_service.dart';
import 'package:mobi_party_link/features/party/presentation/providers/job_provider.dart';
import 'package:mobi_party_link/features/profile/presentation/providers/profile_provider.dart';

/// 메인 프로필 + 직업 이름 표시용 Provider
final mainProfileDisplayProvider =
    FutureProvider<MainProfileDisplay?>((ref) async {
  ref.watch(profileRefreshProvider); // profile_provider.dart의 것 사용

  final profile = await ProfileService.getMainProfile();
  if (profile == null) return null;

  // jobId → job 이름 변환
  String? jobName;
  if (profile.jobId != null) {
    jobName = await ref.read(jobIdToNameProvider(profile.jobId!).future);
  }

  return MainProfileDisplay(
    nickname: profile.nickname,
    jobName: jobName ?? '미설정',
    power: profile.power ?? 0,
  );
});

/// 메인 프로필 표시용 데이터 클래스
class MainProfileDisplay {
  final String nickname;
  final String jobName; // 직업 이름 (예: "전사")
  final int power;

  MainProfileDisplay({
    required this.nickname,
    required this.jobName,
    required this.power,
  });
}
