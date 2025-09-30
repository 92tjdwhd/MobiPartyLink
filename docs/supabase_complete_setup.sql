-- ============================================
-- Mobi Party Link - 완전한 Supabase 설정
-- 이 파일을 먼저 실행한 후 버전 업데이트 테스트를 진행하세요
-- ============================================

-- Step 1: 기존 데이터 정리 (선택사항 - 처음이면 실행)
-- DROP TABLE IF EXISTS jobs CASCADE;
-- DROP TABLE IF EXISTS job_categories CASCADE;
-- DROP TABLE IF EXISTS party_templates CASCADE;
-- DROP TABLE IF EXISTS data_versions CASCADE;

-- Step 2: 테이블 생성
CREATE TABLE IF NOT EXISTS job_categories (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

CREATE TABLE IF NOT EXISTS jobs (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    category_id TEXT REFERENCES job_categories(id),
    description TEXT,
    icon_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

CREATE TABLE IF NOT EXISTS party_templates (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    content_type TEXT NOT NULL,
    category TEXT NOT NULL,
    difficulty TEXT NOT NULL,
    max_members INTEGER NOT NULL,
    require_job BOOLEAN DEFAULT false,
    require_power BOOLEAN DEFAULT false,
    min_power INTEGER,
    max_power INTEGER,
    require_job_category BOOLEAN DEFAULT false,
    tank_limit INTEGER DEFAULT 0,
    healer_limit INTEGER DEFAULT 0,
    dps_limit INTEGER DEFAULT 0,
    icon_url TEXT NOT NULL,
    is_default BOOLEAN DEFAULT true,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

CREATE TABLE IF NOT EXISTS data_versions (
    data_type TEXT PRIMARY KEY,
    version INTEGER NOT NULL DEFAULT 1,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Step 3: 직업 카테고리 데이터 삽입 (FK 때문에 먼저 실행!)
INSERT INTO job_categories (id, name, description) VALUES
    ('warrior', '전사 계열', '근접 물리 공격 직업'),
    ('mage', '마법사 계열', '원거리 마법 공격 직업'),
    ('archer', '궁수 계열', '원거리 물리 공격 직업'),
    ('support', '서포터 계열', '아군 지원 및 힐러 직업'),
    ('rogue', '도적 계열', '암살 및 기습 직업')
ON CONFLICT (id) DO NOTHING;

-- Step 4: 직업 데이터 삽입 (19개)
INSERT INTO jobs (id, name, category_id, description, icon_url, is_active) VALUES
    ('warrior', '전사', 'warrior', '기본 전사', NULL, true),
    ('monk', '수도사', 'warrior', '격투형 전사', NULL, true),
    ('ice_mage', '빙결술사', 'mage', '얼음 마법 전문', NULL, true),
    ('greatsword', '대검전사', 'warrior', '대검 사용 전사', NULL, true),
    ('swordsman', '검술사', 'warrior', '검술 전문가', NULL, true),
    ('mage', '마법사', 'mage', '기본 마법사', NULL, true),
    ('fire_mage', '화염술사', 'mage', '화염 마법 전문', NULL, true),
    ('lightning_mage', '전격술사', 'mage', '번개 마법 전문', NULL, true),
    ('archer', '궁수', 'archer', '기본 궁수', NULL, true),
    ('crossbow', '석궁사수', 'archer', '석궁 전문가', NULL, true),
    ('longbow', '장궁병', 'archer', '장궁 전문가', NULL, true),
    ('bard', '음유시인', 'support', '음악으로 지원', NULL, true),
    ('dancer', '댄서', 'support', '춤으로 지원', NULL, true),
    ('musician', '악사', 'support', '악기 연주 지원', NULL, true),
    ('rogue', '도적', 'rogue', '기본 도적', NULL, true),
    ('fighter', '격투가', 'rogue', '맨손 격투', NULL, true),
    ('dual_blade', '듀얼블레이드', 'rogue', '쌍검 사용', NULL, true),
    ('healer', '힐러', 'support', '회복 전문', NULL, true),
    ('priest', '사제', 'support', '신성 마법 사용', NULL, true)
ON CONFLICT (id) DO NOTHING;

-- Step 5: 파티 템플릿 데이터 삽입
INSERT INTO party_templates (id, name, description, content_type, category, difficulty, max_members, require_job, require_power, min_power, max_power, icon_url, is_default) VALUES
    ('abyss_beginner', '어비스 입문', '어비스 던전 입문자용 템플릿', '던전', '어비스', '입문', 6, false, true, 500000, 600000, 'https://via.placeholder.com/100', true),
    ('abyss_normal', '어비스 일반', '어비스 던전 일반 난이도 템플릿', '던전', '어비스', '일반', 8, false, true, 800000, 900000, 'https://via.placeholder.com/100', true),
    ('raid_hard', '레이드 하드', '레이드 하드 난이도 템플릿', '레이드', '레이드', '하드', 16, true, true, 1500000, 2000000, 'https://via.placeholder.com/100', true),
    ('chaos_normal', '카오스 일반', '카오스 던전 일반 템플릿', '던전', '카오스', '일반', 4, false, true, 600000, 700000, 'https://via.placeholder.com/100', true),
    ('guardian_hard', '가디언 하드', '가디언 레이드 하드 템플릿', '가디언', '가디언', '하드', 4, false, true, 1200000, 1500000, 'https://via.placeholder.com/100', true)
ON CONFLICT (id) DO NOTHING;

-- Step 6: 버전 데이터 삽입 (v1로 시작)
INSERT INTO data_versions (data_type, version) VALUES 
    ('jobs', 1),
    ('party_templates', 1)
ON CONFLICT (data_type) DO NOTHING;

-- Step 7: RLS (Row Level Security) 설정
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE party_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE data_versions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read access on jobs" ON jobs;
CREATE POLICY "Allow public read access on jobs" ON jobs FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow public read access on job_categories" ON job_categories;
CREATE POLICY "Allow public read access on job_categories" ON job_categories FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow public read access on party_templates" ON party_templates;
CREATE POLICY "Allow public read access on party_templates" ON party_templates FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow public read access on data_versions" ON data_versions;
CREATE POLICY "Allow public read access on data_versions" ON data_versions FOR SELECT USING (true);

-- Step 8: 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_jobs_category_id ON jobs(category_id);
CREATE INDEX IF NOT EXISTS idx_jobs_is_active ON jobs(is_active);
CREATE INDEX IF NOT EXISTS idx_party_templates_is_active ON party_templates(is_active);
CREATE INDEX IF NOT EXISTS idx_party_templates_is_default ON party_templates(is_default);

-- ============================================
-- 확인 쿼리 (설치 완료 후 확인)
-- ============================================

-- 1. 모든 테이블 확인
SELECT 'job_categories' as table_name, COUNT(*) as count FROM job_categories
UNION ALL
SELECT 'jobs', COUNT(*) FROM jobs WHERE is_active = true
UNION ALL
SELECT 'party_templates', COUNT(*) FROM party_templates WHERE is_active = true
UNION ALL
SELECT 'data_versions', COUNT(*) FROM data_versions;

-- 2. 버전 확인 (둘 다 1이어야 함)
SELECT * FROM data_versions ORDER BY data_type;

-- 3. 직업 목록
SELECT id, name, category_id FROM jobs WHERE is_active = true ORDER BY name;

-- 4. 템플릿 목록
SELECT id, name, content_type, difficulty FROM party_templates WHERE is_active = true ORDER BY name;
