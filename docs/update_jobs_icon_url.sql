-- jobs 테이블 icon_url 업데이트 SQL
-- Supabase SQL Editor에서 실행하세요
-- 
-- 주의: 이 스크립트를 실행하기 전에 Supabase Storage에 jobs_image 버켓이 생성되어 있고,
-- 각 직업 ID에 해당하는 SVG 파일이 업로드되어 있어야 합니다.
-- 예: warrior.svg, mage.svg, healer.svg 등

-- jobs 테이블 icon_url 업데이트 (PNG)
UPDATE jobs
SET icon_url = 'https://qpauuwmflnvdnnfctjyx.supabase.co/storage/v1/object/public/jobs_image/' || id || '.png'
WHERE is_active = true;

-- 업데이트 결과 확인
SELECT 
  id, 
  name, 
  category_id,
  icon_url,
  is_active
FROM jobs 
WHERE is_active = true 
ORDER BY category_id, name;

-- Storage 버켓 공개 설정 (jobs_image 버켓이 private인 경우에만 필요)
-- INSERT INTO storage.policies (name, bucket_id, command, definition)
-- VALUES (
--   'Public Access',
--   'jobs_image',
--   'SELECT',
--   'true'
-- );

-- 완료 메시지
SELECT '직업 아이콘 URL 업데이트가 완료되었습니다!' as message;

