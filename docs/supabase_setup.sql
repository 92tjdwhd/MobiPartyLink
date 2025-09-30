-- ============================================
-- Mobi Party Link - Supabase 데이터베이스 설정
-- ============================================

-- 1. 직업 카테고리 테이블
CREATE TABLE IF NOT EXISTS job_categories (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 2. 직업 테이블
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

-- 3. 파티 템플릿 테이블
CREATE TABLE IF NOT EXISTS party_templates (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    dungeon_name TEXT NOT NULL,
    difficulty TEXT NOT NULL,
    min_members INTEGER NOT NULL,
    max_members INTEGER NOT NULL,
    required_jobs JSONB,
    recommended_power INTEGER,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 4. 데이터 버전 관리 테이블
CREATE TABLE IF NOT EXISTS data_versions (
    data_type TEXT PRIMARY KEY,
    version INTEGER NOT NULL DEFAULT 1,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- ============================================
-- 초기 데이터 삽입
-- ============================================

-- 직업 카테고리 샘플 데이터
INSERT INTO job_categories (id, name, description) VALUES
    ('warrior', '전사 계열', '근접 물리 공격 직업'),
    ('mage', '마법사 계열', '원거리 마법 공격 직업'),
    ('archer', '궁수 계열', '원거리 물리 공격 직업'),
    ('support', '서포터 계열', '아군 지원 및 힐러 직업'),
    ('rogue', '도적 계열', '암살 및 기습 직업')
ON CONFLICT (id) DO NOTHING;

-- 직업 샘플 데이터 (19개)
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

-- 파티 템플릿 샘플 데이터
INSERT INTO party_templates (id, name, description, dungeon_name, difficulty, min_members, max_members, required_jobs, recommended_power, is_active) VALUES
    ('abyss_beginner', '어비스 입문', '어비스 던전 입문자용 템플릿', '마스던전', '입문', 4, 6, '[]'::jsonb, 500000, true),
    ('abyss_normal', '어비스 일반', '어비스 던전 일반 난이도 템플릿', '마스던전', '일반', 4, 8, '[]'::jsonb, 800000, true),
    ('raid_hard', '레이드 하드', '레이드 하드 난이도 템플릿', '레이드', '하드', 8, 16, '["healer", "priest"]'::jsonb, 1500000, true),
    ('chaos_normal', '카오스 일반', '카오스 던전 일반 템플릿', '카오스던전', '일반', 4, 4, '[]'::jsonb, 600000, true),
    ('guardian_hard', '가디언 하드', '가디언 레이드 하드 템플릿', '가디언', '하드', 4, 4, '[]'::jsonb, 1200000, true)
ON CONFLICT (id) DO NOTHING;

-- 초기 버전 데이터 삽입
INSERT INTO data_versions (data_type, version) VALUES 
    ('jobs', 1),
    ('party_templates', 1)
ON CONFLICT (data_type) DO NOTHING;

-- ============================================
-- Row Level Security (RLS) 설정
-- ============================================

-- RLS 활성화
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE party_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE data_versions ENABLE ROW LEVEL SECURITY;

-- 읽기 정책 생성 (모든 사용자가 읽을 수 있음)
DROP POLICY IF EXISTS "Allow public read access on jobs" ON jobs;
CREATE POLICY "Allow public read access on jobs" ON jobs FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow public read access on job_categories" ON job_categories;
CREATE POLICY "Allow public read access on job_categories" ON job_categories FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow public read access on party_templates" ON party_templates;
CREATE POLICY "Allow public read access on party_templates" ON party_templates FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow public read access on data_versions" ON data_versions;
CREATE POLICY "Allow public read access on data_versions" ON data_versions FOR SELECT USING (true);

-- ============================================
-- 인덱스 생성 (성능 최적화)
-- ============================================

CREATE INDEX IF NOT EXISTS idx_jobs_category_id ON jobs(category_id);
CREATE INDEX IF NOT EXISTS idx_jobs_is_active ON jobs(is_active);
CREATE INDEX IF NOT EXISTS idx_party_templates_is_active ON party_templates(is_active);

-- ============================================
-- 테스트용 데이터 업데이트 SQL (버전 2로 업그레이드)
-- ============================================

-- 새 직업 추가 시 사용할 SQL (주석 처리)
-- INSERT INTO jobs (id, name, category_id, description, is_active) VALUES
--     ('test_job', '테스트직업', 'warrior', '테스트용 신규 직업', true);

-- 버전 업데이트 시 사용할 SQL (주석 처리)
-- UPDATE data_versions 
-- SET version = 2, last_updated = NOW() 
-- WHERE data_type = 'jobs';

-- ============================================
-- 확인 쿼리
-- ============================================

-- 모든 테이블 데이터 확인
-- SELECT * FROM job_categories ORDER BY name;
-- SELECT * FROM jobs ORDER BY name;
-- SELECT * FROM party_templates ORDER BY name;
-- SELECT * FROM data_versions;

-- 버전 확인
-- SELECT data_type, version, last_updated FROM data_versions;

-- 직업 개수 확인
-- SELECT COUNT(*) as total_jobs FROM jobs WHERE is_active = true;
