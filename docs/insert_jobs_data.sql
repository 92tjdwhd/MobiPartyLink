-- 직업 데이터 삽입 SQL
-- Supabase SQL Editor에서 실행하세요

-- 1. 직업 카테고리 데이터 삽입 (이미 있다면 건너뛰기)
INSERT INTO job_categories (id, name, description, icon_url) VALUES
  ('tank', '탱커', '방어와 어그로 관리 역할', 'assets/icons/job_category_tank.png'),
  ('healer', '힐러', '치유와 버프 지원 역할', 'assets/icons/job_category_healer.png'),
  ('dps', '딜러', '공격과 데미지 딜링 역할', 'assets/icons/job_category_dps.png')
ON CONFLICT (id) DO NOTHING;

-- 2. 직업 데이터 삽입
INSERT INTO jobs (id, name, category_id, description, icon_url, is_active) VALUES
  -- 탱커 직업들
  ('warrior', '전사', 'tank', '강력한 방어력과 어그로 관리 능력을 가진 탱커', 'assets/icons/job_warrior.png', true),
  ('monk', '수도사', 'tank', '신체 단련을 통한 높은 방어력을 가진 탱커', 'assets/icons/job_monk.png', true),
  ('ice_mage', '빙결술사', 'tank', '빙결 마법으로 적의 공격을 막는 탱커', 'assets/icons/job_ice_mage.png', true),
  
  -- 딜러 직업들
  ('greatsword_warrior', '대검전사', 'dps', '거대한 대검으로 강력한 물리 공격을 하는 딜러', 'assets/icons/job_greatsword_warrior.png', true),
  ('swordsman', '검술사', 'dps', '빠른 검술로 연속 공격을 하는 딜러', 'assets/icons/job_swordsman.png', true),
  ('mage', '마법사', 'dps', '다양한 마법으로 원거리 공격을 하는 딜러', 'assets/icons/job_mage.png', true),
  ('fire_mage', '화염술사', 'dps', '화염 마법으로 강력한 폭발 공격을 하는 딜러', 'assets/icons/job_fire_mage.png', true),
  ('lightning_mage', '전격술사', 'dps', '번개 마법으로 빠른 연속 공격을 하는 딜러', 'assets/icons/job_lightning_mage.png', true),
  ('archer', '궁수', 'dps', '정확한 활 쏘기로 원거리 공격을 하는 딜러', 'assets/icons/job_archer.png', true),
  ('crossbow_archer', '석궁사수', 'dps', '강력한 석궁으로 관통 공격을 하는 딜러', 'assets/icons/job_crossbow_archer.png', true),
  ('longbow_archer', '장궁병', 'dps', '긴 사거리의 장궁으로 원거리 공격을 하는 딜러', 'assets/icons/job_longbow_archer.png', true),
  ('bard', '음유시인', 'dps', '음악과 마법으로 버프와 공격을 하는 딜러', 'assets/icons/job_bard.png', true),
  ('dancer', '댄서', 'dps', '춤과 마법으로 아군을 강화하고 적을 공격하는 딜러', 'assets/icons/job_dancer.png', true),
  ('musician', '악사', 'dps', '악기 연주로 마법 공격과 버프를 하는 딜러', 'assets/icons/job_musician.png', true),
  ('rogue', '도적', 'dps', '은밀한 공격과 함정 설치로 공격하는 딜러', 'assets/icons/job_rogue.png', true),
  ('fighter', '격투가', 'dps', '맨손 격투로 빠른 연속 공격을 하는 딜러', 'assets/icons/job_fighter.png', true),
  ('dual_blade', '듀얼블레이드', 'dps', '쌍검을 사용하여 빠른 연속 공격을 하는 딜러', 'assets/icons/job_dual_blade.png', true),
  
  -- 힐러 직업들
  ('healer', '힐러', 'healer', '치유 마법으로 아군을 치료하는 힐러', 'assets/icons/job_healer.png', true),
  ('priest', '사제', 'healer', '신성한 마법으로 치유와 보호를 제공하는 힐러', 'assets/icons/job_priest.png', true)
ON CONFLICT (id) DO NOTHING;

-- 완료 메시지
SELECT '직업 데이터 삽입이 완료되었습니다!' as message;
