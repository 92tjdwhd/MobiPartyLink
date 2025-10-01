import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import '../constants/kakao_constants.dart';
import '../../features/party/domain/entities/party_entity.dart';

/// 카카오톡 공유 서비스
class KakaoShareService {
  /// 파티 링크를 카카오톡으로 공유
  static Future<bool> shareParty(PartyEntity party) async {
    try {
      // Deep Link URL 생성
      final deepLink =
          '${KakaoConstants.deepLinkScheme}://${KakaoConstants.deepLinkHost}/${party.id}';

      // 최대 투력 표시 처리
      final maxPowerText = party.maxPower != null
          ? '투력 ${party.maxPower! ~/ 10000}만'
          : '투력 30000만 이상';

      // 파티 정보 요약
      final description =
          '${party.contentType} · $maxPowerText · ${party.members.length}/${party.maxMembers}명';

      // 카카오톡 공유 템플릿 생성
      final template = FeedTemplate(
        content: Content(
          title: '🎉 ${party.name}',
          description: description,
          imageUrl: Uri.parse(
              'https://mud-central.com/images/mabinogi_icon.png'), // 기본 이미지
          link: Link(
            mobileWebUrl: Uri.parse(deepLink),
            webUrl: Uri.parse(deepLink),
          ),
        ),
        buttons: [
          Button(
            title: '파티 참가하기',
            link: Link(
              mobileWebUrl: Uri.parse(deepLink),
              webUrl: Uri.parse(deepLink),
            ),
          ),
        ],
      );

      // 카카오톡 설치 여부 확인
      bool isKakaoTalkSharingAvailable =
          await ShareClient.instance.isKakaoTalkSharingAvailable();

      if (isKakaoTalkSharingAvailable) {
        // 카카오톡으로 공유
        Uri shareUri =
            await ShareClient.instance.shareDefault(template: template);
        await ShareClient.instance.launchKakaoTalk(shareUri);
        print('✅ 카카오톡 공유 성공: ${party.name}');
        return true;
      } else {
        // 카카오톡이 설치되지 않은 경우 웹 공유
        Uri shareUrl =
            await ShareClient.instance.shareDefault(template: template);
        await launchBrowserTab(shareUrl, popupOpen: true);
        print('✅ 웹 브라우저로 공유: ${party.name}');
        return true;
      }
    } catch (error) {
      print('❌ 카카오톡 공유 실패: $error');
      return false;
    }
  }

  /// 커스텀 메시지로 파티 공유 (더 상세한 정보)
  static Future<bool> sharePartyWithDetails(PartyEntity party) async {
    try {
      final deepLink =
          '${KakaoConstants.deepLinkScheme}://${KakaoConstants.deepLinkHost}/${party.id}';

      // 파티 상세 정보
      final maxPowerText = party.maxPower != null
          ? '투력 ${party.maxPower! ~/ 10000}만'
          : '투력 30000만 이상';

      final minPowerText = party.minPower != null
          ? '투력 ${party.minPower! ~/ 10000}만'
          : '투력 제한 없음';

      // 직업 제한 정보
      String jobLimitText = '';
      if (party.requireJobCategory) {
        final totalLimit = party.tankLimit + party.healerLimit + party.dpsLimit;
        if (totalLimit > 0) {
          jobLimitText =
              '\n직업 제한: 탱커 ${party.tankLimit}, 힐러 ${party.healerLimit}, 딜러 ${party.dpsLimit}';
        }
      }

      final template = FeedTemplate(
        content: Content(
          title: '${party.name}',
          description: '''
📋 ${party.contentType}
💪 $minPowerText ~ $maxPowerText
👥 ${party.members.length}/${party.maxMembers}명$jobLimitText
📝 파티원을 모집합니다!
          '''
              .trim(),
          imageUrl:
              Uri.parse('https://mud-central.com/images/mabinogi_icon.png'),
          link: Link(
            mobileWebUrl: Uri.parse(deepLink),
            webUrl: Uri.parse(deepLink),
          ),
        ),
        social: Social(
          likeCount: party.members.length,
          commentCount: party.maxMembers - party.members.length,
        ),
        buttons: [
          Button(
            title: '파티 참가하기',
            link: Link(
              mobileWebUrl: Uri.parse(deepLink),
              webUrl: Uri.parse(deepLink),
            ),
          ),
          Button(
            title: '앱에서 보기',
            link: Link(
              mobileWebUrl: Uri.parse(deepLink),
              webUrl: Uri.parse(deepLink),
            ),
          ),
        ],
      );

      bool isKakaoTalkSharingAvailable =
          await ShareClient.instance.isKakaoTalkSharingAvailable();

      if (isKakaoTalkSharingAvailable) {
        Uri shareUri =
            await ShareClient.instance.shareDefault(template: template);
        await ShareClient.instance.launchKakaoTalk(shareUri);
        print('✅ 카카오톡 상세 공유 성공: ${party.name}');
        return true;
      } else {
        Uri shareUrl =
            await ShareClient.instance.shareDefault(template: template);
        await launchBrowserTab(shareUrl, popupOpen: true);
        print('✅ 웹 브라우저로 상세 공유: ${party.name}');
        return true;
      }
    } catch (error) {
      print('❌ 카카오톡 상세 공유 실패: $error');
      return false;
    }
  }
}
