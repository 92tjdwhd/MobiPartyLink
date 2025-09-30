-- ============================================
-- 버전 업데이트 테스트 SQL
-- Supabase SQL Editor에서 실행하세요
-- ============================================

-- 1. 새 직업 추가
INSERT INTO jobs (id, name, category_id, description, icon_url, is_active) VALUES
    ('test_warrior', '테스트전사', 'warrior', '버전 2 테스트용 신규 직업', NULL, true);

-- 2. 새 템플릿 추가
INSERT INTO party_templates (id, name, description, dungeon_name, difficulty, min_members, max_members, required_jobs, recommended_power, is_active) VALUES
    ('test_template', '테스트 던전', '버전 2 테스트용 신규 템플릿', '테스트던전', '일반', 4, 8, '[]'::jsonb, 700000, true);

-- 3. 직업 버전을 2로 업데이트
UPDATE data_versions 
SET version = 2, last_updated = NOW() 
WHERE data_type = 'jobs';

-- 4. 템플릿 버전을 2로 업데이트
UPDATE data_versions 
SET version = 2, last_updated = NOW() 
WHERE data_type = 'party_templates';

-- ============================================
-- 확인 쿼리 (실행 후 확인용)
-- ============================================

-- 버전 확인 (둘 다 2여야 함)
SELECT * FROM data_versions ORDER BY data_type;

-- 직업 개수 확인 (20개여야 함)
SELECT COUNT(*) as total_jobs FROM jobs WHERE is_active = true;

-- 새로 추가된 직업 확인
SELECT * FROM jobs WHERE id = 'test_warrior';

-- 템플릿 개수 확인 (6개여야 함 - 기존 5개 + 신규 1개)
SELECT COUNT(*) as total_templates FROM party_templates WHERE is_active = true;

-- 새로 추가된 템플릿 확인
SELECT * FROM party_templates WHERE id = 'test_template';

-- ============================================
-- 전체 데이터 확인
-- ============================================

-- 모든 직업 (이름순)
-- SELECT id, name, category_id FROM jobs WHERE is_active = true ORDER BY name;

-- 모든 템플릿 (이름순)
-- SELECT id, name, dungeon_name, difficulty FROM party_templates WHERE is_active = true ORDER BY name;
