import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'package:intl/intl.dart';
import '../constants/kakao_constants.dart';
import '../../features/party/domain/entities/party_entity.dart';

/// 카카오톡 공유 서비스
class KakaoShareService {
  /// 날짜를 "MM월 dd일 HH:mm" 형식으로 포맷
  static String _formatDateTime(DateTime dateTime) {
    return DateFormat('M월 d일 HH:mm').format(dateTime);
  }

  /// 직업 제한 정보 텍스트 생성
  static String _getJobLimitInfo(PartyEntity party) {
    if (!party.requireJobCategory) {
      return '';
    }

    final totalLimit = party.tankLimit + party.healerLimit + party.dpsLimit;
    if (totalLimit == 0) {
      return '';
    }

    return '\n직업 제한: 탱커 ${party.tankLimit}, 힐러 ${party.healerLimit}, 딜러 ${party.dpsLimit}';
  }

  /// 파티 링크를 카카오톡으로 공유
  static Future<bool> shareParty(PartyEntity party) async {
    try {
      // Deep Link URL 생성 (카카오톡용)
      final kakaoDeepLink =
          '${KakaoConstants.nativeAppKey}://kakaolink?partyId=${party.id}';

      // 웹 URL 생성 (앱이 설치되어 있으면 앱으로 리다이렉트)
      final webUrl = kakaoDeepLink;

      // 직업 제한 정보
      final jobLimitInfo = _getJobLimitInfo(party);

      // 카카오톡 공유 템플릿 생성 (ListTemplate으로 변경)
      final template = ListTemplate(
        headerTitle: '모비링크 파티 초대',
        headerLink: Link(
          mobileWebUrl: Uri.parse(webUrl),
          webUrl: Uri.parse(webUrl),
        ),
        contents: [
          Content(
            title: party.name,
            description: party.contentType,
            imageUrl:
                Uri.parse('https://mud-central.com/images/mabinogi_icon.png'),
            link: Link(
              mobileWebUrl: Uri.parse(webUrl),
              webUrl: Uri.parse(webUrl),
            ),
          ),
          Content(
            title: '모집 인원',
            description: '${party.members.length}/${party.maxMembers}명',
            link: Link(
              mobileWebUrl: Uri.parse(webUrl),
              webUrl: Uri.parse(webUrl),
            ),
          ),
          Content(
            title: '시작 시간',
            description: _formatDateTime(party.startTime),
            link: Link(
              mobileWebUrl: Uri.parse(webUrl),
              webUrl: Uri.parse(webUrl),
            ),
          ),
          if (jobLimitInfo.isNotEmpty)
            Content(
              title: '직업 제한',
              description: jobLimitInfo.trim(),
              link: Link(
                mobileWebUrl: Uri.parse(webUrl),
                webUrl: Uri.parse(webUrl),
              ),
            ),
        ],
        buttons: [
          Button(
            title: '파티 참가하기',
            link: Link(
              mobileWebUrl: Uri.parse(webUrl),
              webUrl: Uri.parse(webUrl),
              androidExecutionParams: {
                'partyId': party.id,
              },
              iosExecutionParams: {
                'partyId': party.id,
              },
            ),
          ),
        ],
      );

      // 카카오톡 설치 여부 확인
      final bool isKakaoTalkSharingAvailable =
          await ShareClient.instance.isKakaoTalkSharingAvailable();

      if (isKakaoTalkSharingAvailable) {
        // 카카오톡으로 공유
        final Uri shareUri =
            await ShareClient.instance.shareDefault(template: template);
        await ShareClient.instance.launchKakaoTalk(shareUri);
        print('✅ 카카오톡 공유 성공: ${party.name}');
        return true;
      } else {
        // 카카오톡이 설치되지 않은 경우 웹 공유
        final Uri shareUrl =
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
      // Deep Link URL 생성 (카카오톡용)
      final kakaoDeepLink =
          '${KakaoConstants.nativeAppKey}://kakaolink?partyId=${party.id}';

      // 웹 URL 생성 (앱이 설치되어 있으면 앱으로 리다이렉트)
      final webUrl = kakaoDeepLink;

      // 직업 제한 정보
      final jobLimitInfo = _getJobLimitInfo(party);

      // 카카오톡 공유 템플릿 생성 (ListTemplate으로 변경)
      final template = ListTemplate(
        headerTitle: '모비링크 파티 초대',
        headerLink: Link(
          mobileWebUrl: Uri.parse(webUrl),
          webUrl: Uri.parse(webUrl),
        ),
        contents: [
          Content(
            title: party.name,
            description: party.contentType,
            imageUrl:
                Uri.parse('https://mud-central.com/images/mabinogi_icon.png'),
            link: Link(
              mobileWebUrl: Uri.parse(webUrl),
              webUrl: Uri.parse(webUrl),
            ),
          ),
          Content(
            title: '모집 인원',
            description: '${party.members.length}/${party.maxMembers}명',
            link: Link(
              mobileWebUrl: Uri.parse(webUrl),
              webUrl: Uri.parse(webUrl),
            ),
          ),
          Content(
            title: '시작 시간',
            description: _formatDateTime(party.startTime),
            link: Link(
              mobileWebUrl: Uri.parse(webUrl),
              webUrl: Uri.parse(webUrl),
            ),
          ),
          if (jobLimitInfo.isNotEmpty)
            Content(
              title: '직업 제한',
              description: jobLimitInfo.trim(),
              link: Link(
                mobileWebUrl: Uri.parse(webUrl),
                webUrl: Uri.parse(webUrl),
              ),
            ),
        ],
        buttons: [
          Button(
            title: '파티 참가하기',
            link: Link(
              mobileWebUrl: Uri.parse(webUrl),
              webUrl: Uri.parse(webUrl),
              androidExecutionParams: {
                'partyId': party.id,
              },
              iosExecutionParams: {
                'partyId': party.id,
              },
            ),
          ),
        ],
      );

      final bool isKakaoTalkSharingAvailable =
          await ShareClient.instance.isKakaoTalkSharingAvailable();

      if (isKakaoTalkSharingAvailable) {
        final Uri shareUri =
            await ShareClient.instance.shareDefault(template: template);
        await ShareClient.instance.launchKakaoTalk(shareUri);
        print('✅ 카카오톡 상세 공유 성공: ${party.name}');
        return true;
      } else {
        final Uri shareUrl =
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
