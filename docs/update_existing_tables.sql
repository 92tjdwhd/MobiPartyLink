-- 기존 테이블 업데이트 SQL
-- Supabase SQL Editor에서 실행하세요

-- 1. 직업 카테고리 테이블 생성
CREATE TABLE IF NOT EXISTS job_categories (
  id VARCHAR(20) PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  description TEXT,
  icon_url VARCHAR(255),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. 직업 테이블 생성
CREATE TABLE IF NOT EXISTS jobs (
  id VARCHAR(50) PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  category_id VARCHAR(20) NOT NULL REFERENCES job_categories(id),
  description TEXT,
  icon_url VARCHAR(255),
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. parties 테이블 업데이트
-- 기존 recommended_jobs 컬럼 제거 (있다면)
ALTER TABLE parties DROP COLUMN IF EXISTS recommended_jobs;

-- 새로운 직업 제한 컬럼들 추가
ALTER TABLE parties ADD COLUMN IF NOT EXISTS require_job_category BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE parties ADD COLUMN IF NOT EXISTS tank_limit INTEGER DEFAULT 0 CHECK (tank_limit >= 0);
ALTER TABLE parties ADD COLUMN IF NOT EXISTS healer_limit INTEGER DEFAULT 0 CHECK (healer_limit >= 0);
ALTER TABLE parties ADD COLUMN IF NOT EXISTS dps_limit INTEGER DEFAULT 0 CHECK (dps_limit >= 0);

-- 직업 제한 활성화 여부를 확인하는 제약조건 추가
ALTER TABLE parties ADD CONSTRAINT check_job_limits_consistency 
  CHECK (
    (require_job_category = false) OR 
    (require_job_category = true AND (tank_limit > 0 OR healer_limit > 0 OR dps_limit > 0))
  );

-- 4. party_members 테이블 업데이트
-- 기존 job 컬럼을 job_id로 변경
ALTER TABLE party_members ADD COLUMN IF NOT EXISTS job_id VARCHAR(50) REFERENCES jobs(id);
-- 기존 job 컬럼이 있다면 데이터 마이그레이션 후 제거
-- ALTER TABLE party_members DROP COLUMN IF EXISTS job;

-- 5. user_profiles 테이블 업데이트
-- 기존 job 컬럼을 job_id로 변경
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS job_id VARCHAR(50) REFERENCES jobs(id);
-- 기존 job 컬럼이 있다면 데이터 마이그레이션 후 제거
-- ALTER TABLE user_profiles DROP COLUMN IF EXISTS job;

-- 6. party_templates 테이블 업데이트
-- 기존 recommended_jobs 컬럼 제거 (있다면)
ALTER TABLE party_templates DROP COLUMN IF EXISTS recommended_jobs;

-- 새로운 직업 제한 컬럼들 추가
ALTER TABLE party_templates ADD COLUMN IF NOT EXISTS require_job_category BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE party_templates ADD COLUMN IF NOT EXISTS tank_limit INTEGER DEFAULT 0 CHECK (tank_limit >= 0);
ALTER TABLE party_templates ADD COLUMN IF NOT EXISTS healer_limit INTEGER DEFAULT 0 CHECK (healer_limit >= 0);
ALTER TABLE party_templates ADD COLUMN IF NOT EXISTS dps_limit INTEGER DEFAULT 0 CHECK (dps_limit >= 0);

-- 직업 제한 활성화 여부를 확인하는 제약조건 추가
ALTER TABLE party_templates ADD CONSTRAINT check_template_job_limits_consistency 
  CHECK (
    (require_job_category = false) OR 
    (require_job_category = true AND (tank_limit > 0 OR healer_limit > 0 OR dps_limit > 0))
  );

-- 7. 인덱스 추가
CREATE INDEX IF NOT EXISTS idx_party_members_job_id ON party_members(job_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_job_id ON user_profiles(job_id);
CREATE INDEX IF NOT EXISTS idx_jobs_category_id ON jobs(category_id);
CREATE INDEX IF NOT EXISTS idx_jobs_is_active ON jobs(is_active);

-- 8. RLS 정책 추가
ALTER TABLE job_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view job categories" ON job_categories
  FOR SELECT USING (true);

CREATE POLICY "Anyone can view active jobs" ON jobs
  FOR SELECT USING (is_active = true);

-- 9. 트리거 추가
CREATE TRIGGER update_job_categories_updated_at BEFORE UPDATE ON job_categories
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_jobs_updated_at BEFORE UPDATE ON jobs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 10. 기본 직업 카테고리 데이터 삽입
INSERT INTO job_categories (id, name, description, icon_url) VALUES
  ('tank', '탱커', '방어와 어그로 관리 역할', 'assets/icons/job_category_tank.png'),
  ('healer', '힐러', '치유와 버프 지원 역할', 'assets/icons/job_category_healer.png'),
  ('dps', '딜러', '공격과 데미지 딜링 역할', 'assets/icons/job_category_dps.png')
ON CONFLICT (id) DO NOTHING;

-- 11. 기존 파티 템플릿 데이터 업데이트
-- 서큐버스 레이드 템플릿들 (탱커1, 힐러1, 딜러2)
UPDATE party_templates SET 
  require_job_category = true,
  tank_limit = 1,
  healer_limit = 1,
  dps_limit = 2
WHERE id IN (
  'template_succubus_raid_beginner',
  'template_succubus_raid_hard',
  'template_succubus_raid_extreme'
);

-- 글라스기브넨 레이드 템플릿들 (탱커2, 힐러2, 딜러4)
UPDATE party_templates SET 
  require_job_category = true,
  tank_limit = 2,
  healer_limit = 2,
  dps_limit = 4
WHERE id IN (
  'template_glasgibnen_raid_beginner',
  'template_glasgibnen_raid_hard',
  'template_glasgibnen_raid_extreme'
);

-- 마스던전 어비스 템플릿들 (탱커1, 힐러1, 딜러2)
UPDATE party_templates SET 
  require_job_category = true,
  tank_limit = 1,
  healer_limit = 1,
  dps_limit = 2
WHERE id IN (
  'template_master_dungeon_abyss_beginner',
  'template_master_dungeon_abyss_hard',
  'template_master_dungeon_abyss_extreme',
  'template_master_dungeon_abyss_hell1',
  'template_master_dungeon_abyss_hell2',
  'template_master_dungeon_abyss_hell3',
  'template_master_dungeon_abyss_hell4',
  'template_master_dungeon_abyss_hell5',
  'template_master_dungeon_abyss_hell6',
  'template_master_dungeon_abyss_hell7'
);

-- 12. 기존 파티 템플릿이 없다면 새로 삽입
INSERT INTO party_templates (id, name, description, content_type, category, difficulty, max_members, require_job, require_power, min_power, require_job_category, tank_limit, healer_limit, dps_limit, icon_url, is_default) VALUES
  -- 서큐버스 레이드 템플릿들 (탱커1, 힐러1, 딜러2)
  ('template_succubus_raid_beginner', '서큐버스 레이드 (입문)', '서큐버스 레이드 입문자용 파티입니다.', 'raid', '레이드', '입문', 4, true, true, 500, true, 1, 1, 2, 'assets/icons/succubus_raid_beginner.png', true),
  ('template_succubus_raid_hard', '서큐버스 레이드 (어려움)', '서큐버스 레이드 어려움 난이도 파티입니다.', 'raid', '레이드', '어려움', 4, true, true, 2000, true, 1, 1, 2, 'assets/icons/succubus_raid_hard.png', true),
  ('template_succubus_raid_extreme', '서큐버스 레이드 (매우어려움)', '서큐버스 레이드 매우어려움 난이도 파티입니다.', 'raid', '레이드', '매우어려움', 4, true, true, 4000, true, 1, 1, 2, 'assets/icons/succubus_raid_extreme.png', true),
  
  -- 글라스기브넨 레이드 템플릿들 (탱커2, 힐러2, 딜러4)
  ('template_glasgibnen_raid_beginner', '글라스기브넨 레이드 (입문)', '글라스기브넨 레이드 입문자용 파티입니다.', 'raid', '레이드', '입문', 8, true, true, 800, true, 2, 2, 4, 'assets/icons/glasgibnen_raid_beginner.png', true),
  ('template_glasgibnen_raid_hard', '글라스기브넨 레이드 (어려움)', '글라스기브넨 레이드 어려움 난이도 파티입니다.', 'raid', '레이드', '어려움', 8, true, true, 3000, true, 2, 2, 4, 'assets/icons/glasgibnen_raid_hard.png', true),
  ('template_glasgibnen_raid_extreme', '글라스기브넨 레이드 (매우어려움)', '글라스기브넨 레이드 매우어려움 난이도 파티입니다.', 'raid', '레이드', '매우어려움', 8, true, true, 6000, true, 2, 2, 4, 'assets/icons/glasgibnen_raid_extreme.png', true),
  
  -- 마스던전 어비스 템플릿들 (탱커1, 힐러1, 딜러2)
  ('template_master_dungeon_abyss_beginner', '마스던전 어비스 (입문)', '마스던전 어비스 입문자용 파티입니다.', 'dungeon', '어비스', '입문', 4, true, false, null, true, 1, 1, 2, 'assets/icons/master_dungeon_abyss_beginner.png', true),
  ('template_master_dungeon_abyss_hard', '마스던전 어비스 (어려움)', '마스던전 어비스 어려움 난이도 파티입니다.', 'dungeon', '어비스', '어려움', 4, true, true, 1500, true, 1, 1, 2, 'assets/icons/master_dungeon_abyss_hard.png', true),
  ('template_master_dungeon_abyss_extreme', '마스던전 어비스 (매우어려움)', '마스던전 어비스 매우어려움 난이도 파티입니다.', 'dungeon', '어비스', '매우어려움', 4, true, true, 3000, true, 1, 1, 2, 'assets/icons/master_dungeon_abyss_extreme.png', true),
  ('template_master_dungeon_abyss_hell1', '마스던전 어비스 (지옥1)', '마스던전 어비스 지옥1 난이도 파티입니다.', 'dungeon', '어비스', '지옥1', 4, true, true, 5000, true, 1, 1, 2, 'assets/icons/master_dungeon_abyss_hell1.png', true),
  ('template_master_dungeon_abyss_hell2', '마스던전 어비스 (지옥2)', '마스던전 어비스 지옥2 난이도 파티입니다.', 'dungeon', '어비스', '지옥2', 4, true, true, 6000, true, 1, 1, 2, 'assets/icons/master_dungeon_abyss_hell2.png', true),
  ('template_master_dungeon_abyss_hell3', '마스던전 어비스 (지옥3)', '마스던전 어비스 지옥3 난이도 파티입니다.', 'dungeon', '어비스', '지옥3', 4, true, true, 7000, true, 1, 1, 2, 'assets/icons/master_dungeon_abyss_hell3.png', true),
  ('template_master_dungeon_abyss_hell4', '마스던전 어비스 (지옥4)', '마스던전 어비스 지옥4 난이도 파티입니다.', 'dungeon', '어비스', '지옥4', 4, true, true, 8000, true, 1, 1, 2, 'assets/icons/master_dungeon_abyss_hell4.png', true),
  ('template_master_dungeon_abyss_hell5', '마스던전 어비스 (지옥5)', '마스던전 어비스 지옥5 난이도 파티입니다.', 'dungeon', '어비스', '지옥5', 4, true, true, 9000, true, 1, 1, 2, 'assets/icons/master_dungeon_abyss_hell5.png', true),
  ('template_master_dungeon_abyss_hell6', '마스던전 어비스 (지옥6)', '마스던전 어비스 지옥6 난이도 파티입니다.', 'dungeon', '어비스', '지옥6', 4, true, true, 10000, true, 1, 1, 2, 'assets/icons/master_dungeon_abyss_hell6.png', true),
  ('template_master_dungeon_abyss_hell7', '마스던전 어비스 (지옥7)', '마스던전 어비스 지옥7 난이도 파티입니다.', 'dungeon', '어비스', '지옥7', 4, true, true, 11000, true, 1, 1, 2, 'assets/icons/master_dungeon_abyss_hell7.png', true)
ON CONFLICT (id) DO NOTHING;

-- 완료 메시지
SELECT '기존 테이블 업데이트가 완료되었습니다!' as message;
