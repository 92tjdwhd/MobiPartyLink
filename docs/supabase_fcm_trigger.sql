-- ============================================
-- Supabase FCM 자동 푸시 Trigger
-- data_versions 테이블 업데이트 시 자동으로 FCM 전송
-- ============================================

-- ⚠️ 주의: FCM_SERVER_KEY를 실제 키로 변경하세요!
-- Firebase Console → 프로젝트 설정 → 클라우드 메시징 → 서버 키

-- FCM 푸시 전송 함수
CREATE OR REPLACE FUNCTION send_fcm_push_notification()
RETURNS TRIGGER AS $$
DECLARE
  fcm_url TEXT := 'https://fcm.googleapis.com/fcm/send';
  fcm_server_key TEXT := 'YOUR_FCM_SERVER_KEY';  -- ⚠️ 여기에 실제 FCM 서버 키 입력!
  notification_title TEXT;
  notification_body TEXT;
  topic TEXT := '/topics/all_users';
  http_response TEXT;
BEGIN
  -- 알림 메시지 설정
  IF NEW.data_type = 'jobs' THEN
    notification_title := '새로운 직업 추가!';
    notification_body := '새로운 직업이 추가되었습니다 🎮';
  ELSIF NEW.data_type = 'party_templates' THEN
    notification_title := '새로운 템플릿 추가!';
    notification_body := '새로운 파티 템플릿이 추가되었습니다 🎉';
  ELSE
    notification_title := '콘텐츠 업데이트!';
    notification_body := '새로운 콘텐츠가 업데이트되었습니다';
  END IF;

  -- FCM 푸시 전송 (iOS + Android 백그라운드 지원)
  SELECT content INTO http_response FROM net.http_post(
    url := fcm_url,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'key=' || fcm_server_key
    ),
    body := jsonb_build_object(
      'to', topic,
      'priority', 'high',
      'content_available', true,
      
      -- 데이터 페이로드 (백그라운드에서도 수신!)
      'data', jsonb_build_object(
        'type', 'data_update',
        'data_type', NEW.data_type,
        'version', NEW.version::text,
        'updated_at', NEW.last_updated::text,
        'click_action', 'FLUTTER_NOTIFICATION_CLICK'
      ),
      
      -- 알림 페이로드
      'notification', jsonb_build_object(
        'title', notification_title,
        'body', notification_body,
        'sound', 'default',
        'badge', '1'
      ),
      
      -- Android 전용 설정
      'android', jsonb_build_object(
        'priority', 'high',
        'notification', jsonb_build_object(
          'channel_id', 'data_update_channel',
          'sound', 'default',
          'priority', 'high',
          'default_vibrate_timings', true,
          'notification_count', 1
        )
      ),
      
      -- iOS 전용 설정 (APNS)
      'apns', jsonb_build_object(
        'headers', jsonb_build_object(
          'apns-priority', '10'
        ),
        'payload', jsonb_build_object(
          'aps', jsonb_build_object(
            'alert', jsonb_build_object(
              'title', notification_title,
              'body', notification_body
            ),
            'sound', 'default',
            'badge', 1,
            'content-available', 1  -- iOS 백그라운드 수신 필수!
          )
        )
      )
    )::text
  );
  
  -- 로그
  RAISE NOTICE '✅ FCM 푸시 전송: % v% → %', NEW.data_type, NEW.version, http_response;
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING '❌ FCM 전송 실패: %', SQLERRM;
    RETURN NEW;  -- 에러가 발생해도 업데이트는 계속 진행
END;
$$ LANGUAGE plpgsql;

-- 기존 Trigger 삭제 (있다면)
DROP TRIGGER IF EXISTS fcm_on_version_update ON data_versions;

-- 새 Trigger 생성
CREATE TRIGGER fcm_on_version_update
  AFTER UPDATE ON data_versions
  FOR EACH ROW
  WHEN (OLD.version IS DISTINCT FROM NEW.version)
  EXECUTE FUNCTION send_fcm_push_notification();

-- ============================================
-- 확인 쿼리
-- ============================================

-- Trigger 목록 확인
SELECT 
  trigger_name, 
  event_manipulation, 
  event_object_table,
  action_statement
FROM information_schema.triggers 
WHERE trigger_name = 'fcm_on_version_update';

-- Function 확인
SELECT 
  routine_name,
  routine_type,
  routine_definition
FROM information_schema.routines
WHERE routine_name = 'send_fcm_push_notification';

-- ============================================
-- 테스트
-- ============================================

-- 버전 업데이트로 Trigger 테스트
-- ⚠️ 실제로 FCM이 전송되므로 주의!

-- 직업 버전 업데이트 (테스트)
-- UPDATE data_versions 
-- SET version = version + 1, last_updated = NOW()
-- WHERE data_type = 'jobs';

-- 템플릿 버전 업데이트 (테스트)
-- UPDATE data_versions 
-- SET version = version + 1, last_updated = NOW()
-- WHERE data_type = 'party_templates';

-- ============================================
-- Trigger 비활성화/활성화
-- ============================================

-- Trigger 비활성화
-- ALTER TABLE data_versions DISABLE TRIGGER fcm_on_version_update;

-- Trigger 활성화
-- ALTER TABLE data_versions ENABLE TRIGGER fcm_on_version_update;

-- Trigger 삭제
-- DROP TRIGGER IF EXISTS fcm_on_version_update ON data_versions;
-- DROP FUNCTION IF EXISTS send_fcm_push_notification();
