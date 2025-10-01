-- ============================================
-- Mobi Party Link - Final Database Schema
-- ============================================

-- 익명 인증 활성화 (Supabase Dashboard에서 수동 설정)
-- Authentication → Providers → Anonymous → Enable

-- ============================================
-- 1. 직업 카테고리 테이블
-- ============================================
CREATE TABLE IF NOT EXISTS job_categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  icon_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 2. 직업 테이블
-- ============================================
CREATE TABLE IF NOT EXISTS jobs (
  id TEXT PRIMARY KEY,
  category_id TEXT NOT NULL REFERENCES job_categories(id),
  name TEXT NOT NULL,
  description TEXT,
  icon_url TEXT, -- Supabase Storage URL (나중에 추가)
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 3. 파티 템플릿 테이블
-- ============================================
CREATE TABLE IF NOT EXISTS party_templates (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  content_type TEXT NOT NULL, -- 'dungeon', 'raid', 'field_boss', 'quest', 'custom'
  category TEXT, -- 'beginner', 'intermediate', 'advanced', 'endgame'
  description TEXT,
  max_members INTEGER NOT NULL DEFAULT 4,
  require_job BOOLEAN DEFAULT false,
  require_power BOOLEAN DEFAULT false,
  min_power INTEGER,
  icon_url TEXT, -- Supabase Storage URL (나중에 추가)
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 4. 데이터 버전 관리 테이블
-- ============================================
CREATE TABLE IF NOT EXISTS data_versions (
  id SERIAL PRIMARY KEY,
  data_type TEXT NOT NULL UNIQUE, -- 'jobs', 'templates'
  version INTEGER NOT NULL DEFAULT 1,
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 5. 파티 테이블 (수정됨!)
-- ============================================
CREATE TABLE IF NOT EXISTS parties (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  content_type TEXT NOT NULL, -- 'dungeon', 'raid', 'field_boss', 'quest', 'custom'
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  max_members INTEGER NOT NULL DEFAULT 4,
  require_job BOOLEAN DEFAULT false,
  require_power BOOLEAN DEFAULT false,
  min_power INTEGER,
  status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'active', 'completed', 'cancelled'
  creator_id TEXT NOT NULL, -- ← 변경: UUID에서 TEXT로 (Supabase Auth userId)
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 6. 파티 멤버 테이블 (대폭 수정!)
-- ============================================
CREATE TABLE IF NOT EXISTS party_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  party_id UUID NOT NULL REFERENCES parties(id) ON DELETE CASCADE,
  user_id TEXT NOT NULL, -- ← 변경: Supabase Auth userId (익명 인증)
  
  -- 로컬 프로필 스냅샷 (파티 참가 시점 정보)
  nickname TEXT NOT NULL,
  job TEXT,              -- ← 추가: 직업 이름 (로컬에서 가져옴)
  power INTEGER,         -- ← 추가: 전투력 (로컬에서 가져옴)
  
  -- FCM 푸시 알림용
  fcm_token TEXT,        -- ← 추가: FCM 토큰
  
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 복합 유니크 제약: 같은 파티에 같은 사용자 중복 방지
  UNIQUE(party_id, user_id)
);

-- ============================================
-- RLS (Row Level Security) 정책
-- ============================================

-- 익명 사용자도 접근 가능하도록 설정
ALTER TABLE job_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE party_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE data_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE parties ENABLE ROW LEVEL SECURITY;
ALTER TABLE party_members ENABLE ROW LEVEL SECURITY;

-- 1. 직업 카테고리: 모든 사용자 읽기 가능
CREATE POLICY "Allow public read access on job_categories"
  ON job_categories FOR SELECT
  TO public
  USING (true);

-- 2. 직업: 모든 사용자 읽기 가능
CREATE POLICY "Allow public read access on jobs"
  ON jobs FOR SELECT
  TO public
  USING (true);

-- 3. 파티 템플릿: 모든 사용자 읽기 가능
CREATE POLICY "Allow public read access on party_templates"
  ON party_templates FOR SELECT
  TO public
  USING (true);

-- 4. 데이터 버전: 모든 사용자 읽기 가능
CREATE POLICY "Allow public read access on data_versions"
  ON data_versions FOR SELECT
  TO public
  USING (true);

-- 5. 파티: 모든 사용자 읽기/생성 가능
CREATE POLICY "Allow public read access on parties"
  ON parties FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow authenticated users to create parties"
  ON parties FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid()::text = creator_id);

CREATE POLICY "Allow party creator to update parties"
  ON parties FOR UPDATE
  TO authenticated
  USING (auth.uid()::text = creator_id);

CREATE POLICY "Allow party creator to delete parties"
  ON parties FOR DELETE
  TO authenticated
  USING (auth.uid()::text = creator_id);

-- 6. 파티 멤버: 모든 사용자 읽기/생성 가능, 본인만 삭제 가능
CREATE POLICY "Allow public read access on party_members"
  ON party_members FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow authenticated users to join parties"
  ON party_members FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid()::text = user_id);

CREATE POLICY "Allow users to leave parties"
  ON party_members FOR DELETE
  TO authenticated
  USING (auth.uid()::text = user_id);

-- ============================================
-- 초기 데이터 삽입
-- ============================================

-- 직업 카테고리 초기 데이터
INSERT INTO job_categories (id, name, description, icon_url) VALUES
  ('tank', '탱커', '방어와 어그로 관리 역할', 'assets/icons/job_category_tank.png'),
  ('dps', '딜러', '공격과 데미지 딜링 역할', 'assets/icons/job_category_dps.png'),
  ('healer', '힐러', '치유와 버프 지원 역할', 'assets/icons/job_category_healer.png')
ON CONFLICT (id) DO NOTHING;

-- 직업 초기 데이터
INSERT INTO jobs (id, category_id, name, description, icon_url) VALUES
  ('warrior', 'tank', '워리어', '강력한 방어력과 체력을 가진 근접 탱커', NULL),
  ('paladin', 'tank', '팔라딘', '신성한 힘으로 아군을 보호하는 탱커', NULL),
  ('berserker', 'dps', '버서커', '강력한 근접 공격력을 가진 딜러', NULL),
  ('archer', 'dps', '아처', '원거리에서 정확한 공격을 하는 딜러', NULL),
  ('mage', 'dps', '메이지', '강력한 마법 공격을 하는 딜러', NULL),
  ('priest', 'healer', '프리스트', '강력한 치유 능력을 가진 힐러', NULL),
  ('bard', 'healer', '바드', '음악으로 아군을 지원하는 힐러', NULL)
ON CONFLICT (id) DO NOTHING;

-- 파티 템플릿 초기 데이터
INSERT INTO party_templates (id, name, content_type, category, description, max_members, require_job, require_power, min_power) VALUES
  ('coill_basic', '코일 던전 - 입문', 'dungeon', 'beginner', '초보자를 위한 기본 던전', 4, false, false, NULL),
  ('peaca_normal', '페카 던전 - 일반', 'dungeon', 'intermediate', '중급자를 위한 던전', 4, true, true, 5000),
  ('alban_elite', '알반 엘리트 - 상급', 'dungeon', 'advanced', '상급자를 위한 던전', 4, true, true, 10000),
  ('crom_cruaich', '크롬 크루아흐', 'raid', 'endgame', '고난도 필드 보스 레이드', 8, true, true, 15000)
ON CONFLICT (id) DO NOTHING;

-- 데이터 버전 초기화
INSERT INTO data_versions (data_type, version) VALUES
  ('jobs', 1),
  ('templates', 1)
ON CONFLICT (data_type) DO UPDATE SET version = 1;

-- ============================================
-- 인덱스 생성 (성능 최적화)
-- ============================================
CREATE INDEX IF NOT EXISTS idx_parties_creator_id ON parties(creator_id);
CREATE INDEX IF NOT EXISTS idx_parties_start_time ON parties(start_time);
CREATE INDEX IF NOT EXISTS idx_parties_status ON parties(status);
CREATE INDEX IF NOT EXISTS idx_party_members_party_id ON party_members(party_id);
CREATE INDEX IF NOT EXISTS idx_party_members_user_id ON party_members(user_id);
CREATE INDEX IF NOT EXISTS idx_jobs_category_id ON jobs(category_id);

-- ============================================
-- 완료!
-- ============================================

