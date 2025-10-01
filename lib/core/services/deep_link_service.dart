import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

/// Deep Link 처리 서비스
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

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
      (uri) {
        _handleDeepLink(uri);
      },
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
      // mobipartylink://party/123
      // https://mobipartylink.page.link/party/123

      final pathSegments = uri.pathSegments;

      if (pathSegments.isNotEmpty) {
        // pathSegments[0] = "party"
        // pathSegments[1] = "123" (party ID)

        if (pathSegments.length >= 2 && pathSegments[0] == 'party') {
          final partyId = pathSegments[1];
          print('✅ 파티 ID 추출: $partyId');

          // 콜백 호출
          if (onPartyLinkReceived != null) {
            onPartyLinkReceived!(partyId);
          } else {
            print('⚠️ onPartyLinkReceived 콜백이 설정되지 않음');
          }
        } else {
          print('⚠️ 지원하지 않는 Deep Link 형식: $uri');
        }
      } else {
        print('⚠️ Path Segments가 비어있음: $uri');
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
