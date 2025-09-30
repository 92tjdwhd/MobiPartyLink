-- ============================================
-- Supabase FCM HTTP v1 API 자동 푸시 Trigger
-- Legacy API 대신 최신 FCM v1 API 사용
-- ============================================

-- ⚠️ 주의사항:
-- 1. Firebase Console에서 "Cloud Messaging API (V1)" 활성화 필요
-- 2. 서비스 계정 키(JSON) 필요
-- 3. OAuth 2.0 토큰 생성 필요

-- ============================================
-- 방법 1: Supabase Edge Function 사용 (권장!)
-- ============================================

-- Edge Function을 통해 FCM v1 API 호출
-- 이 방법이 가장 간단하고 안전합니다.

CREATE OR REPLACE FUNCTION trigger_fcm_edge_function()
RETURNS TRIGGER AS $$
BEGIN
  -- Supabase Edge Function 호출
  PERFORM net.http_post(
    url := 'https://qpauuwmflnvdnnfctjyx.supabase.co/functions/v1/send-fcm-push',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFwYXV1d21mbG52ZG5uZmN0anl4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjY4OTczMzUsImV4cCI6MjA0MjQ3MzMzNX0.g5v8bXpvk2_zMR8ib9rbx15Ik6h_YxW6FrK_RN-u_LM'
    ),
    body := jsonb_build_object(
      'data_type', NEW.data_type,
      'version', NEW.version,
      'updated_at', NEW.last_updated
    )::text
  );
  
  RAISE NOTICE '✅ FCM Edge Function 호출: % v%', NEW.data_type, NEW.version;
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING '❌ Edge Function 호출 실패: %', SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger 생성
DROP TRIGGER IF EXISTS fcm_v1_on_version_update ON data_versions;

CREATE TRIGGER fcm_v1_on_version_update
  AFTER UPDATE ON data_versions
  FOR EACH ROW
  WHEN (OLD.version IS DISTINCT FROM NEW.version)
  EXECUTE FUNCTION trigger_fcm_edge_function();

-- ============================================
-- Edge Function 코드는 아래 파일 참조:
-- supabase/functions/send-fcm-push/index.ts
-- ============================================

-- 확인
SELECT trigger_name, event_object_table 
FROM information_schema.triggers 
WHERE trigger_name = 'fcm_v1_on_version_update';
