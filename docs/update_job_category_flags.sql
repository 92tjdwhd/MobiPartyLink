-- 직업 제한 플래그만 업데이트하는 SQL
-- Supabase SQL Editor에서 실행하세요

-- 1. parties 테이블에 직업 제한 플래그 추가
ALTER TABLE parties ADD COLUMN IF NOT EXISTS require_job_category BOOLEAN NOT NULL DEFAULT false;

-- 2. party_templates 테이블에 직업 제한 플래그 추가
ALTER TABLE party_templates ADD COLUMN IF NOT EXISTS require_job_category BOOLEAN NOT NULL DEFAULT false;

-- 3. 직업 제한 활성화 여부를 확인하는 제약조건 추가
-- 기존 제약조건이 있는지 확인 후 추가
DO $$
BEGIN
    -- parties 테이블 제약조건 추가
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'check_job_limits_consistency' 
        AND conrelid = 'parties'::regclass
    ) THEN
        ALTER TABLE parties ADD CONSTRAINT check_job_limits_consistency 
        CHECK (
            (require_job_category = false) OR 
            (require_job_category = true AND (tank_limit > 0 OR healer_limit > 0 OR dps_limit > 0))
        );
    END IF;
    
    -- party_templates 테이블 제약조건 추가
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'check_template_job_limits_consistency' 
        AND conrelid = 'party_templates'::regclass
    ) THEN
        ALTER TABLE party_templates ADD CONSTRAINT check_template_job_limits_consistency 
        CHECK (
            (require_job_category = false) OR 
            (require_job_category = true AND (tank_limit > 0 OR healer_limit > 0 OR dps_limit > 0))
        );
    END IF;
END $$;

-- 4. 기존 파티 템플릿들의 직업 제한 플래그 업데이트
-- 서큐버스 레이드 템플릿들 (탱커1, 힐러1, 딜러2)
UPDATE party_templates SET require_job_category = true
WHERE id IN (
  'template_succubus_raid_beginner',
  'template_succubus_raid_hard',
  'template_succubus_raid_extreme'
);

-- 글라스기브넨 레이드 템플릿들 (탱커2, 힐러2, 딜러4)
UPDATE party_templates SET require_job_category = true
WHERE id IN (
  'template_glasgibnen_raid_beginner',
  'template_glasgibnen_raid_hard',
  'template_glasgibnen_raid_extreme'
);

-- 마스던전 어비스 템플릿들 (탱커1, 힐러1, 딜러2)
UPDATE party_templates SET require_job_category = true
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

-- 5. 기존 파티들의 직업 제한 플래그 업데이트 (직업 제한이 설정된 파티들만)
UPDATE parties SET require_job_category = true
WHERE tank_limit > 0 OR healer_limit > 0 OR dps_limit > 0;

-- 완료 메시지
SELECT '직업 제한 플래그 업데이트가 완료되었습니다!' as message;
