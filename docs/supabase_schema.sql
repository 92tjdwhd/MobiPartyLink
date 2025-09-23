-- Mobi Party Link 데이터베이스 스키마
-- Supabase SQL Editor에서 실행하세요

-- 1. 파티 테이블
CREATE TABLE parties (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  start_time TIMESTAMPTZ NOT NULL,
  max_members INTEGER NOT NULL CHECK (max_members > 0 AND max_members <= 20),
  content_type VARCHAR(50) NOT NULL,
  category VARCHAR(50) NOT NULL,
  difficulty VARCHAR(20) NOT NULL,
  require_job BOOLEAN NOT NULL DEFAULT false,
  require_power BOOLEAN NOT NULL DEFAULT false,
  min_power INTEGER CHECK (min_power >= 0 AND min_power <= 1000000),
  max_power INTEGER CHECK (max_power >= 0 AND max_power <= 1000000),
  -- 직업 제한 설정
  require_job_category BOOLEAN NOT NULL DEFAULT false,
  tank_limit INTEGER DEFAULT 0 CHECK (tank_limit >= 0),
  healer_limit INTEGER DEFAULT 0 CHECK (healer_limit >= 0),
  dps_limit INTEGER DEFAULT 0 CHECK (dps_limit >= 0),
  status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'ongoing', 'ended')),
  creator_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. 파티 멤버 테이블
CREATE TABLE party_members (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  party_id UUID NOT NULL REFERENCES parties(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  nickname VARCHAR(50) NOT NULL,
  job_id VARCHAR(50) REFERENCES jobs(id),
  power INTEGER CHECK (power >= 0 AND power <= 1000000),
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(party_id, user_id) -- 한 파티에 같은 사용자는 한 번만 참여 가능
);

-- 3. 직업 카테고리 테이블
CREATE TABLE job_categories (
  id VARCHAR(20) PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  description TEXT,
  icon_url VARCHAR(255),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. 직업 테이블
CREATE TABLE jobs (
  id VARCHAR(50) PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  category_id VARCHAR(20) NOT NULL REFERENCES job_categories(id),
  description TEXT,
  icon_url VARCHAR(255),
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. 사용자 프로필 테이블
CREATE TABLE user_profiles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  nickname VARCHAR(50) NOT NULL,
  job_id VARCHAR(50) REFERENCES jobs(id),
  power INTEGER CHECK (power >= 0 AND power <= 1000000),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. 파티 템플릿 테이블
CREATE TABLE party_templates (
  id VARCHAR(50) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT NOT NULL,
  content_type VARCHAR(50) NOT NULL,
  category VARCHAR(50) NOT NULL,
  difficulty VARCHAR(20) NOT NULL,
  max_members INTEGER NOT NULL CHECK (max_members > 0 AND max_members <= 20),
  require_job BOOLEAN NOT NULL DEFAULT false,
  require_power BOOLEAN NOT NULL DEFAULT false,
  min_power INTEGER CHECK (min_power >= 0 AND min_power <= 1000000),
  max_power INTEGER CHECK (max_power >= 0 AND max_power <= 1000000),
  -- 직업 제한 설정
  require_job_category BOOLEAN NOT NULL DEFAULT false,
  tank_limit INTEGER DEFAULT 0 CHECK (tank_limit >= 0),
  healer_limit INTEGER DEFAULT 0 CHECK (healer_limit >= 0),
  dps_limit INTEGER DEFAULT 0 CHECK (dps_limit >= 0),
  icon_url VARCHAR(255) NOT NULL,
  is_default BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. 인덱스 생성 (성능 최적화)
CREATE INDEX idx_parties_creator_id ON parties(creator_id);
CREATE INDEX idx_parties_status ON parties(status);
CREATE INDEX idx_parties_start_time ON parties(start_time);
CREATE INDEX idx_parties_content_type ON parties(content_type);
CREATE INDEX idx_parties_category ON parties(category);
CREATE INDEX idx_parties_difficulty ON parties(difficulty);
CREATE INDEX idx_parties_category_difficulty ON parties(category, difficulty);
CREATE INDEX idx_party_members_party_id ON party_members(party_id);
CREATE INDEX idx_party_members_user_id ON party_members(user_id);
CREATE INDEX idx_party_members_job_id ON party_members(job_id);
CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);
CREATE INDEX idx_user_profiles_job_id ON user_profiles(job_id);
CREATE INDEX idx_jobs_category_id ON jobs(category_id);
CREATE INDEX idx_jobs_is_active ON jobs(is_active);
CREATE INDEX idx_party_templates_content_type ON party_templates(content_type);
CREATE INDEX idx_party_templates_category ON party_templates(category);
CREATE INDEX idx_party_templates_difficulty ON party_templates(difficulty);
CREATE INDEX idx_party_templates_category_difficulty ON party_templates(category, difficulty);
CREATE INDEX idx_party_templates_is_default ON party_templates(is_default);

-- 8. RLS (Row Level Security) 정책 설정
ALTER TABLE parties ENABLE ROW LEVEL SECURITY;
ALTER TABLE party_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE party_templates ENABLE ROW LEVEL SECURITY;

-- 7. 파티 테이블 정책
-- 모든 사용자가 파티를 조회할 수 있음
CREATE POLICY "Anyone can view parties" ON parties
  FOR SELECT USING (true);

-- 인증된 사용자만 파티를 생성할 수 있음
CREATE POLICY "Authenticated users can create parties" ON parties
  FOR INSERT WITH CHECK (auth.uid() = creator_id);

-- 파티 생성자만 수정/삭제할 수 있음
CREATE POLICY "Party creators can update parties" ON parties
  FOR UPDATE USING (auth.uid() = creator_id);

CREATE POLICY "Party creators can delete parties" ON parties
  FOR DELETE USING (auth.uid() = creator_id);

-- 8. 파티 멤버 테이블 정책
-- 모든 사용자가 파티 멤버를 조회할 수 있음
CREATE POLICY "Anyone can view party members" ON party_members
  FOR SELECT USING (true);

-- 인증된 사용자만 파티에 참여할 수 있음
CREATE POLICY "Authenticated users can join parties" ON party_members
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 본인만 파티에서 나갈 수 있음
CREATE POLICY "Users can leave parties" ON party_members
  FOR DELETE USING (auth.uid() = user_id);

-- 9. 사용자 프로필 테이블 정책
-- 모든 사용자가 프로필을 조회할 수 있음
CREATE POLICY "Anyone can view user profiles" ON user_profiles
  FOR SELECT USING (true);

-- 본인만 프로필을 생성/수정할 수 있음
CREATE POLICY "Users can create their own profile" ON user_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own profile" ON user_profiles
  FOR UPDATE USING (auth.uid() = user_id);

-- 10. 파티 템플릿 테이블 정책
-- 모든 사용자가 파티 템플릿을 조회할 수 있음
-- 12. 직업 카테고리 정책
CREATE POLICY "Anyone can view job categories" ON job_categories
  FOR SELECT USING (true);

-- 13. 직업 정책
CREATE POLICY "Anyone can view active jobs" ON jobs
  FOR SELECT USING (is_active = true);

-- 14. 파티 템플릿 정책
CREATE POLICY "Anyone can view party templates" ON party_templates
  FOR SELECT USING (true);

-- 11. 트리거 함수 (updated_at 자동 업데이트)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- 12. 트리거 적용
CREATE TRIGGER update_parties_updated_at BEFORE UPDATE ON parties
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_party_templates_updated_at BEFORE UPDATE ON party_templates
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_job_categories_updated_at BEFORE UPDATE ON job_categories
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_jobs_updated_at BEFORE UPDATE ON jobs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 13. 기본 직업 카테고리 데이터 삽입
INSERT INTO job_categories (id, name, description, icon_url) VALUES
  ('tank', '탱커', '방어와 어그로 관리 역할', 'assets/icons/job_category_tank.png'),
  ('healer', '힐러', '치유와 버프 지원 역할', 'assets/icons/job_category_healer.png'),
  ('dps', '딜러', '공격과 데미지 딜링 역할', 'assets/icons/job_category_dps.png');

-- 14. 기본 파티 템플릿 데이터 삽입 (카테고리 + 난이도별)
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
  ('template_master_dungeon_abyss_hell7', '마스던전 어비스 (지옥7)', '마스던전 어비스 지옥7 난이도 파티입니다.', 'dungeon', '어비스', '지옥7', 4, true, true, 11000, true, 1, 1, 2, 'assets/icons/master_dungeon_abyss_hell7.png', true);

-- 14. 익명 사용자 정책 (Anonymous Auth용)
-- 익명 사용자도 파티를 조회하고 참여할 수 있도록 설정
CREATE POLICY "Anonymous users can view parties" ON parties
  FOR SELECT USING (true);

CREATE POLICY "Anonymous users can view party members" ON party_members
  FOR SELECT USING (true);

CREATE POLICY "Anonymous users can view user profiles" ON user_profiles
  FOR SELECT USING (true);

CREATE POLICY "Anonymous users can view party templates" ON party_templates
  FOR SELECT USING (true);
