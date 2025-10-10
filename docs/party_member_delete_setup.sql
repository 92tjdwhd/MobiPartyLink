

-- ============================================
-- 2. 파티 멤버 삭제 웹훅 함수 생성
-- ============================================

CREATE OR REPLACE FUNCTION notify_party_member_deleted()
RETURNS TRIGGER AS $$
DECLARE
  party_record RECORD;
  is_kicked BOOLEAN;
  action_type TEXT;
BEGIN
  -- 파티 정보 가져오기
  SELECT * INTO party_record
  FROM parties
  WHERE id = OLD.party_id;

  -- 강퇴인지 자진 나가기인지 판단
  -- auth.uid()가 파티장이면 강퇴, 본인이면 자진 나가기
  is_kicked := (auth.uid())::text = party_record.creator_id::text;
  
  IF is_kicked THEN
    action_type := 'kicked';
  ELSE
    action_type := 'left';
  END IF;

  -- Edge Function 호출 (fcm-send)
  -- party_member_deleted 이벤트로 전달
  PERFORM net.http_post(
    url := 'https://qpauuwmflnvdnnfctjyx.supabase.co/functions/v1/fcm-send',
    headers := jsonb_build_object(
      'Content-Type', 'application/json'
    ),
    body := jsonb_build_object(
      'type', 'DELETE',
      'table', 'party_members',
      'record', NULL,
      'old_record', jsonb_build_object(
        'id', OLD.id,
        'party_id', OLD.party_id,
        'user_id', OLD.user_id,
        'nickname', OLD.nickname,
        'fcm_token', OLD.fcm_token,
        'action_type', action_type,
        'party_name', party_record.name
      )
    )
  );
  
  RAISE NOTICE '📩 Webhook 호출: % - %', action_type, OLD.nickname;

  RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 3. Trigger 생성
-- ============================================

DROP TRIGGER IF EXISTS on_party_member_deleted ON party_members;

CREATE TRIGGER on_party_member_deleted
  AFTER DELETE ON party_members
  FOR EACH ROW
  EXECUTE FUNCTION notify_party_member_deleted();

-- ============================================
-- 확인
-- ============================================

-- 정책 확인
SELECT policyname, cmd, qual 
FROM pg_policies 
WHERE tablename = 'party_members' AND cmd = 'DELETE';

-- Trigger 확인
SELECT trigger_name, event_manipulation, event_object_table
FROM information_schema.triggers
WHERE trigger_name = 'on_party_member_deleted';

-- 함수 확인
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_name = 'notify_party_member_deleted';

