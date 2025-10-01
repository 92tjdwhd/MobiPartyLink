import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobi_party_link/core/constants/supabase_constants.dart';

/// FCM 푸시 알림 전송 서비스 (Supabase Edge Function 사용)
class FcmPushService {
  static const String _edgeFunctionUrl =
      'https://qpauuwmflnvdnnfctjyx.supabase.co/functions/v1/fcm-send';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${SupabaseConstants.supabaseAnonKey}',
      };

  /// 파티 수정 알림 전송
  static Future<void> sendPartyUpdateNotification({
    required List<String> fcmTokens,
    required String partyName,
    required String message,
  }) async {
    if (fcmTokens.isEmpty) {
      print('⚠️ FCM 토큰이 없어 푸시를 전송하지 않습니다');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(_edgeFunctionUrl),
        headers: _headers,
        body: jsonEncode({
          'fcm_tokens': fcmTokens,
          'title': '파티 정보 변경',
          'body': '[$partyName] $message',
          'data': {
            'type': 'party_update',
            'party_name': partyName,
          },
        }),
      );

      if (response.statusCode == 200) {
        print('✅ FCM 푸시 전송 성공: ${fcmTokens.length}명');
      } else {
        print('❌ FCM 푸시 전송 실패: ${response.statusCode}');
        print('응답: ${response.body}');
      }
    } catch (e) {
      print('❌ FCM 푸시 전송 에러: $e');
    }
  }

  /// 파티 삭제 알림 전송
  static Future<void> sendPartyDeleteNotification({
    required List<String> fcmTokens,
    required String partyName,
  }) async {
    if (fcmTokens.isEmpty) {
      print('⚠️ FCM 토큰이 없어 푸시를 전송하지 않습니다');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(_edgeFunctionUrl),
        headers: _headers,
        body: jsonEncode({
          'fcm_tokens': fcmTokens,
          'title': '파티 삭제',
          'body': '[$partyName] 파티가 삭제되었습니다',
          'data': {
            'type': 'party_delete',
            'party_name': partyName,
          },
        }),
      );

      if (response.statusCode == 200) {
        print('✅ FCM 푸시 전송 성공: ${fcmTokens.length}명');
      } else {
        print('❌ FCM 푸시 전송 실패: ${response.statusCode}');
        print('응답: ${response.body}');
      }
    } catch (e) {
      print('❌ FCM 푸시 전송 에러: $e');
    }
  }

  /// 멤버 강퇴 알림 전송
  static Future<void> sendKickNotification({
    required String fcmToken,
    required String partyName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_edgeFunctionUrl),
        headers: _headers,
        body: jsonEncode({
          'fcm_tokens': [fcmToken],
          'title': '파티에서 강퇴됨',
          'body': '[$partyName] 파티에서 강퇴되었습니다',
          'data': {
            'type': 'member_kicked',
            'party_name': partyName,
          },
        }),
      );

      if (response.statusCode == 200) {
        print('✅ 강퇴 FCM 푸시 전송 성공');
      } else {
        print('❌ 강퇴 FCM 푸시 전송 실패: ${response.statusCode}');
        print('응답: ${response.body}');
      }
    } catch (e) {
      print('❌ 강퇴 FCM 푸시 전송 에러: $e');
    }
  }
}
