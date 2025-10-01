-- ========================================
-- 모든 FCM 관련 트리거 및 함수 삭제
-- ========================================

-- 1. 모든 트리거 삭제
DROP TRIGGER IF EXISTS fcm_party_update_trigger ON parties CASCADE;
DROP TRIGGER IF EXISTS fcm_party_delete_trigger ON parties CASCADE;
DROP TRIGGER IF EXISTS fcm_member_kick_trigger ON party_members CASCADE;
DROP TRIGGER IF EXISTS fcm_data_version_update_trigger ON data_versions CASCADE;
DROP TRIGGER IF EXISTS fcm_auto_push_trigger ON data_versions CASCADE;

-- 2. 모든 트리거 함수 삭제
DROP FUNCTION IF EXISTS trigger_party_fcm_push() CASCADE;
DROP FUNCTION IF EXISTS trigger_member_kick_fcm_push() CASCADE;
DROP FUNCTION IF EXISTS trigger_data_version_fcm_push() CASCADE;
DROP FUNCTION IF EXISTS trigger_fcm_push() CASCADE;
DROP FUNCTION IF EXISTS trigger_fcm_edge_function() CASCADE;
DROP FUNCTION IF EXISTS test_trigger() CASCADE;

-- 3. 확인
SELECT 
  trigger_name, 
  event_object_table, 
  action_statement
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;


