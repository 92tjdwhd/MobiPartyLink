

-- ============================================
-- STEP 2: parties 테이블 RLS 정책 임시 삭제
-- ============================================

-- RLS를 임시로 비활성화
ALTER TABLE parties DISABLE ROW LEVEL SECURITY;

-- parties 테이블의 모든 정책을 한번에 삭제
DO $$
DECLARE
    policy_rec RECORD;
BEGIN
    FOR policy_rec IN 
        SELECT policyname 
        FROM pg_policies 
        WHERE tablename = 'parties'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON parties', policy_rec.policyname);
        RAISE NOTICE '정책 삭제: %', policy_rec.policyname;
    END LOOP;
END $$;

-- ============================================
-- STEP 3: parties 테이블 수정
-- ============================================

-- creator_id 타입 변경 (UUID → TEXT)
DO $$
BEGIN
    -- 외래키 제약 조건 삭제 (존재하는 경우)
    IF EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'parties_creator_id_fkey' 
        AND table_name = 'parties'
    ) THEN
        ALTER TABLE parties DROP CONSTRAINT parties_creator_id_fkey;
        RAISE NOTICE 'parties_creator_id_fkey 제약 조건 삭제 완료';
    END IF;

    -- creator_id 타입 변경
    ALTER TABLE parties ALTER COLUMN creator_id TYPE TEXT;
    RAISE NOTICE 'parties.creator_id 타입 변경 완료 (UUID → TEXT)';
END $$;

-- ============================================
-- STEP 4: party_members 테이블 RLS 정책 임시 삭제
-- ============================================

-- RLS를 임시로 비활성화
ALTER TABLE party_members DISABLE ROW LEVEL SECURITY;

-- party_members 테이블의 모든 정책을 한번에 삭제
DO $$
DECLARE
    policy_rec RECORD;
BEGIN
    FOR policy_rec IN 
        SELECT policyname 
        FROM pg_policies 
        WHERE tablename = 'party_members'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON party_members', policy_rec.policyname);
        RAISE NOTICE '정책 삭제: %', policy_rec.policyname;
    END LOOP;
END $$;

-- ============================================
-- STEP 5: party_members 테이블 수정
-- ============================================

-- 3-1. 외래키 제약 조건 삭제
DO $$
BEGIN
    -- user_id 외래키 삭제
    IF EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'party_members_user_id_fkey' 
        AND table_name = 'party_members'
    ) THEN
        ALTER TABLE party_members DROP CONSTRAINT party_members_user_id_fkey;
        RAISE NOTICE 'party_members_user_id_fkey 제약 조건 삭제 완료';
    END IF;
END $$;

-- 3-2. user_id 타입 변경 (UUID → TEXT)
ALTER TABLE party_members ALTER COLUMN user_id TYPE TEXT;

-- 3-3. 새로운 컬럼 추가
ALTER TABLE party_members ADD COLUMN IF NOT EXISTS nickname TEXT;
ALTER TABLE party_members ADD COLUMN IF NOT EXISTS job TEXT;
ALTER TABLE party_members ADD COLUMN IF NOT EXISTS power INTEGER;
ALTER TABLE party_members ADD COLUMN IF NOT EXISTS fcm_token TEXT;

-- 3-4. nickname을 NOT NULL로 설정 (기본값 설정 후)
UPDATE party_members SET nickname = '알 수 없음' WHERE nickname IS NULL;
ALTER TABLE party_members ALTER COLUMN nickname SET NOT NULL;

-- 3-5. 중복 방지 제약 조건 추가
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'party_members_party_id_user_id_key' 
        AND table_name = 'party_members'
    ) THEN
        ALTER TABLE party_members ADD CONSTRAINT party_members_party_id_user_id_key UNIQUE(party_id, user_id);
        RAISE NOTICE 'party_members 중복 방지 제약 조건 추가 완료';
    END IF;
END $$;

-- ============================================
-- STEP 6: users 테이블 삭제 (선택사항)
-- ============================================

-- users 테이블이 더 이상 필요 없으므로 삭제
-- 주의: 백업을 먼저 확인하세요!
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'users') THEN
        DROP TABLE users CASCADE;
        RAISE NOTICE 'users 테이블 삭제 완료';
    ELSE
        RAISE NOTICE 'users 테이블이 존재하지 않습니다';
    END IF;
END $$;

-- ============================================
-- STEP 7: RLS 정책 업데이트
-- ============================================

-- parties 테이블 RLS 활성화
ALTER TABLE parties ENABLE ROW LEVEL SECURITY;

-- parties 새로운 정책 생성
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

-- party_members 테이블 RLS 활성화
ALTER TABLE party_members ENABLE ROW LEVEL SECURITY;

-- party_members 새로운 정책 생성
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
-- STEP 8: 인덱스 추가 (성능 최적화)
-- ============================================

-- 기존 인덱스가 없으면 추가
CREATE INDEX IF NOT EXISTS idx_parties_creator_id ON parties(creator_id);
CREATE INDEX IF NOT EXISTS idx_parties_start_time ON parties(start_time);
CREATE INDEX IF NOT EXISTS idx_parties_status ON parties(status);
CREATE INDEX IF NOT EXISTS idx_party_members_party_id ON party_members(party_id);
CREATE INDEX IF NOT EXISTS idx_party_members_user_id ON party_members(user_id);

-- ============================================
-- STEP 9: 데이터 마이그레이션 (필요 시)
-- ============================================

-- users 테이블 데이터를 party_members로 마이그레이션 (users_backup이 존재하는 경우)
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'users_backup') THEN
        -- party_members의 nickname, job, power를 users_backup에서 가져옴
        UPDATE party_members pm
        SET 
            nickname = COALESCE(u.nickname, '알 수 없음'),
            job = (SELECT name FROM jobs WHERE id = u.job_id),
            power = u.power
        FROM users_backup u
        WHERE pm.user_id = u.id::text;
        
        RAISE NOTICE 'users_backup 데이터 마이그레이션 완료';
    ELSE
        RAISE NOTICE 'users_backup 테이블이 존재하지 않습니다';
    END IF;
END $$;

-- ============================================
-- 완료!
-- ============================================

-- 마이그레이션 결과 확인
DO $$
BEGIN
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'Migration 완료!';
    RAISE NOTICE '==============================================';
    RAISE NOTICE '1. parties.creator_id 타입: TEXT';
    RAISE NOTICE '2. party_members.user_id 타입: TEXT';
    RAISE NOTICE '3. party_members 새 컬럼: nickname, job, power, fcm_token';
    RAISE NOTICE '4. users 테이블: 삭제됨';
    RAISE NOTICE '5. RLS 정책: 업데이트됨';
    RAISE NOTICE '6. 인덱스: 생성됨';
    RAISE NOTICE '==============================================';
END $$;

-- 변경 사항 확인 쿼리
SELECT 
    table_name, 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns
WHERE table_name IN ('parties', 'party_members')
ORDER BY table_name, ordinal_position;

