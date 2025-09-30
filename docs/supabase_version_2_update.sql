-- ============================================
-- 버전 2 업데이트 테스트 SQL
-- 기존 DB 구조에 맞춰 작성됨
-- 
-- 주의: job_categories 테이블에 tank, dps, healer가 있어야 합니다!
-- ============================================

-- 1. 새 직업 추가 (테스트용 - 탱커 카테고리 사용)
INSERT INTO jobs (id, name, category_id, description, icon_url, is_active) VALUES
    ('test_warrior', '테스트전사', 'tank', '버전 2 테스트용 신규 탱커 직업', NULL, true)
ON CONFLICT (id) DO NOTHING;

-- 2. 새 템플릿 추가 (테스트용)
INSERT INTO party_templates (
    id, 
    name, 
    description, 
    content_type, 
    category, 
    difficulty, 
    max_members, 
    require_job, 
    require_power, 
    min_power, 
    max_power,
    require_job_category,
    tank_limit,
    healer_limit,
    dps_limit,
    icon_url, 
    is_default
) VALUES
    (
        'test_dungeon', 
        '테스트 던전', 
        '버전 2 테스트용 신규 던전 템플릿', 
        '던전', 
        '테스트', 
        '일반', 
        8, 
        true, 
        true, 
        700000, 
        800000,
        true,
        1,
        1,
        6,
        'https://via.placeholder.com/100', 
        true
    );

-- 3. 직업 버전을 2로 업데이트
UPDATE data_versions 
SET version = 2, last_updated = NOW() 
WHERE data_type = 'jobs';

-- 4. 템플릿 버전을 2로 업데이트
UPDATE data_versions 
SET version = 2, last_updated = NOW() 
WHERE data_type = 'party_templates';

-- ============================================
-- 확인 쿼리
-- ============================================

-- 버전 확인 (둘 다 2여야 함)
SELECT data_type, version, last_updated FROM data_versions ORDER BY data_type;

-- 직업 개수 확인 (기존 19개 + 1개 = 20개)
SELECT COUNT(*) as total_jobs FROM jobs WHERE is_active = true;

-- 새로 추가된 직업 확인
SELECT id, name, category_id, description FROM jobs WHERE id = 'test_warrior';

-- 템플릿 개수 확인 (기존 + 1개)
SELECT COUNT(*) as total_templates FROM party_templates;

-- 새로 추가된 템플릿 확인
SELECT id, name, content_type, difficulty, max_members FROM party_templates WHERE id = 'test_dungeon';

-- 모든 템플릿 리스트
SELECT id, name, content_type, category FROM party_templates ORDER BY name;

-- ============================================
-- 롤백 SQL (테스트 후 원래대로 되돌리기)
-- ============================================

-- 테스트 데이터 삭제
-- DELETE FROM jobs WHERE id = 'test_warrior';
-- DELETE FROM party_templates WHERE id = 'test_dungeon';

-- 버전 되돌리기
-- UPDATE data_versions SET version = 1, last_updated = NOW() WHERE data_type = 'jobs';
-- UPDATE data_versions SET version = 1, last_updated = NOW() WHERE data_type = 'party_templates';
