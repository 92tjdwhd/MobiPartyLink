import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

/// Deep Link 처리 서비스
class DeepLinkService {
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();
  static final DeepLinkService _instance = DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  /// Deep Link 콜백 (파티 ID를 받아서 처리)
  Function(String partyId)? onPartyLinkReceived;

  /// Deep Link 리스닝 시작
  Future<void> initialize() async {
    // 앱이 종료된 상태에서 링크로 실행된 경우 (Initial Link)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      print('❌ Initial Link 처리 실패: $e');
    }

    // 앱이 실행 중일 때 링크를 받은 경우 (Stream)
    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (err) {
        print('❌ Deep Link Stream 에러: $err');
      },
    );

    print('✅ Deep Link Service 초기화 완료');
  }

  /// Deep Link 파싱 및 처리
  void _handleDeepLink(Uri uri) {
    print('📩 Deep Link 수신: $uri');

    try {
      String? partyId;

      // 1. URL Path에서 파티 ID 추출
      // mobipartylink://party/123
      // https://mobipartylink.page.link/party/123
      final pathSegments = uri.pathSegments;
      if (pathSegments.length >= 2 && pathSegments[0] == 'party') {
        partyId = pathSegments[1];
        print('✅ Path에서 파티 ID 추출: $partyId');
      }

      // 2. Query Parameters에서 파티 ID 추출 (카카오톡에서 전달)
      // mobipartylink://party?partyId=123
      // kakaoa552b4938e0195fdcec43c291f5ddcdc://kakaolink?partyId=123
      if (partyId == null) {
        partyId = uri.queryParameters['partyId'];
        if (partyId != null) {
          print('✅ Query Parameter에서 파티 ID 추출: $partyId');
        }
      }

      // 3. party_id 파라미터도 확인 (카카오톡에서 전달)
      // kakaoa552b4938e0195fdcec43c291f5ddcdc://kakaolink?party_id=123
      if (partyId == null) {
        partyId = uri.queryParameters['party_id'];
        if (partyId != null) {
          print('✅ party_id Parameter에서 파티 ID 추출: $partyId');
        }
      }

      // 4. Fragment에서 파티 ID 추출
      // mobipartylink://party#partyId=123
      if (partyId == null && uri.fragment.isNotEmpty) {
        final fragmentParams = Uri.splitQueryString(uri.fragment);
        partyId = fragmentParams['partyId'];
        if (partyId != null) {
          print('✅ Fragment에서 파티 ID 추출: $partyId');
        }
      }

      // 파티 ID가 있으면 콜백 호출
      if (partyId != null && partyId.isNotEmpty) {
        if (onPartyLinkReceived != null) {
          onPartyLinkReceived!(partyId);
        } else {
          print('⚠️ onPartyLinkReceived 콜백이 설정되지 않음');
        }
      } else {
        print('⚠️ 파티 ID를 찾을 수 없음: $uri');
        print('   - Path Segments: $pathSegments');
        print('   - Query Parameters: ${uri.queryParameters}');
        print('   - Fragment: ${uri.fragment}');
      }
    } catch (e) {
      print('❌ Deep Link 파싱 실패: $e');
    }
  }

  /// 리소스 정리
  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }
}
