# 📡 서버 연동 가이드

## 1단계: Supabase SQL 실행 🗄️

### A. Supabase Dashboard 접속
1. https://supabase.com/dashboard 접속
2. 프로젝트 선택: `qpauuwmflnvdnnfctjyx`
3. 왼쪽 메뉴에서 **SQL Editor** 클릭

### B. SQL 스크립트 실행
1. **"New query"** 버튼 클릭
2. `docs/supabase_setup.sql` 파일의 내용을 복사
3. SQL Editor에 붙여넣기
4. **"Run"** 버튼 클릭 (또는 Cmd/Ctrl + Enter)

### C. 실행 결과 확인
성공 메시지가 나타나야 합니다:
```
Success. No rows returned
```

## 2단계: 데이터 확인 ✅

### A. 테이블 확인
왼쪽 메뉴에서 **Table Editor** 클릭 후 다음 테이블이 있는지 확인:
- ✅ `job_categories` (5개 행)
- ✅ `jobs` (19개 행)
- ✅ `party_templates` (5개 행)
- ✅ `data_versions` (2개 행)

### B. SQL로 데이터 확인
SQL Editor에서 실행:
```sql
-- 직업 카테고리 확인
SELECT * FROM job_categories ORDER BY name;

-- 직업 확인 (19개여야 함)
SELECT COUNT(*) as total_jobs FROM jobs WHERE is_active = true;
SELECT * FROM jobs ORDER BY name;

-- 템플릿 확인 (5개여야 함)
SELECT COUNT(*) as total_templates FROM party_templates WHERE is_active = true;
SELECT * FROM party_templates ORDER BY name;

-- 버전 확인 (둘 다 1이어야 함)
SELECT * FROM data_versions;
```

## 3단계: 앱에서 동기화 테스트 📱

### A. 앱 실행
```bash
flutter run -d R5CT501NKTK
```

### B. 테스트 화면 진입
1. **설정** 탭 클릭
2. **"개발자"** 섹션으로 스크롤
3. **"데이터 동기화 테스트"** 클릭

### C. 첫 동기화 실행
1. **"직업 데이터 동기화"** 버튼 클릭
2. 콘솔 로그 확인:
```
🔄 직업 데이터 동기화 시작...
📱 로컬 직업 버전: 0
☁️ 서버 직업 버전: 1
⬇️ 서버에서 직업 데이터 다운로드 중...
✅ 직업 데이터 19개 다운로드 완료
✅ 직업 데이터 19개 로컬 저장 완료
✅ 직업 버전 1 저장 완료
🎉 직업 데이터 동기화 완료! (v0 → v1)
```

3. 캐시 상태 확인:
   - 직업: **19개 (v1)** ✅
   - 마지막 업데이트 시간 표시

### D. 재동기화 테스트 (이미 최신인 경우)
1. **"직업 데이터 동기화"** 다시 클릭
2. 예상 로그:
```
🔄 직업 데이터 동기화 시작...
📱 로컬 직업 버전: 1
☁️ 서버 직업 버전: 1
✅ 직업 데이터가 최신 상태입니다 (v1)
```

## 4단계: 버전 업데이트 테스트 🔄

### A. Supabase에서 새 데이터 추가
SQL Editor에서 실행:
```sql
-- 1. 새 직업 추가
INSERT INTO jobs (id, name, category_id, description, is_active) VALUES
    ('test_job', '테스트직업', 'warrior', '테스트용 신규 직업', true);

-- 2. 버전 업데이트
UPDATE data_versions 
SET version = 2, last_updated = NOW() 
WHERE data_type = 'jobs';

-- 3. 확인
SELECT * FROM data_versions WHERE data_type = 'jobs';
SELECT COUNT(*) FROM jobs WHERE is_active = true; -- 20개여야 함
```

### B. 앱에서 업데이트 확인
1. **"직업 데이터 동기화"** 클릭
2. 예상 로그:
```
🔄 직업 데이터 동기화 시작...
📱 로컬 직업 버전: 1
☁️ 서버 직업 버전: 2
⬇️ 서버에서 직업 데이터 다운로드 중...
✅ 직업 데이터 20개 다운로드 완료
✅ 직업 데이터 20개 로컬 저장 완료
✅ 직업 버전 2 저장 완료
🎉 직업 데이터 동기화 완료! (v1 → v2)
```

3. 캐시 상태 확인:
   - 직업: **20개 (v2)** ✅
   - 업데이트 시간 갱신됨

## 5단계: 캐시 삭제 및 재동기화 테스트 🗑️

### A. 캐시 삭제
1. **"캐시 삭제"** 버튼 클릭
2. 캐시 상태 확인:
   - 직업: **0개 (v0)** ❌

### B. 재동기화
1. **"직업 데이터 동기화"** 클릭
2. 서버에서 최신 데이터(v2, 20개) 다운로드
3. 캐시 상태 복구 확인

## 트러블슈팅 🔧

### 문제 1: "직업 목록을 가져오는데 실패했습니다"
**원인**: RLS(Row Level Security) 정책이 제대로 설정되지 않음
**해결**:
```sql
-- RLS 정책 재설정
DROP POLICY IF EXISTS "Allow public read access on jobs" ON jobs;
CREATE POLICY "Allow public read access on jobs" ON jobs FOR SELECT USING (true);
```

### 문제 2: "직업 버전 정보를 가져오는데 실패했습니다"
**원인**: data_versions 테이블에 데이터가 없음
**해결**:
```sql
-- 버전 데이터 확인 및 재삽입
SELECT * FROM data_versions;

INSERT INTO data_versions (data_type, version) VALUES 
    ('jobs', 1),
    ('party_templates', 1)
ON CONFLICT (data_type) DO UPDATE SET version = 1;
```

### 문제 3: "인터넷 연결을 확인해주세요"
**원인**: 네트워크 연결 문제 또는 Supabase URL 오류
**해결**:
1. 인터넷 연결 확인
2. `lib/core/constants/supabase_constants.dart`에서 URL 확인
3. Supabase 프로젝트가 일시 중지되지 않았는지 확인

### 문제 4: 콘솔에 로그가 안 나옴
**원인**: print 문이 필터링됨
**해결**:
```bash
# Android Studio/VSCode 터미널에서 로그 필터 설정
flutter run -d R5CT501NKTK --verbose
```

## 검증 체크리스트 ✅

- [ ] Supabase SQL 스크립트가 오류 없이 실행됨
- [ ] job_categories 테이블에 5개 데이터 존재
- [ ] jobs 테이블에 19개 데이터 존재
- [ ] party_templates 테이블에 5개 데이터 존재
- [ ] data_versions 테이블에 2개 데이터 존재 (jobs: v1, party_templates: v1)
- [ ] RLS 정책이 모든 테이블에 적용됨
- [ ] 앱에서 "직업 데이터 동기화" 성공
- [ ] 로컬에 19개 직업 데이터 저장됨
- [ ] 캐시 상태에 v1, 19개 표시됨
- [ ] 재동기화 시 "이미 최신" 메시지 표시
- [ ] 서버 버전 업데이트 후 자동 감지 및 동기화
- [ ] 캐시 삭제 및 재동기화 정상 작동

## 다음 단계 🚀

1. **템플릿 동기화 구현** (동일한 패턴)
2. **앱 시작 시 자동 동기화** (main.dart에서 호출)
3. **동기화 상태 UI** (설정 화면에 표시)
4. **백그라운드 동기화** (주기적 업데이트)
5. **파티 API 연동** (실시간 데이터)

## 참고 사항 📝

- **로컬 저장소**: SharedPreferences 사용 (JSON 직렬화)
- **버전 관리**: 서버 버전 > 로컬 버전일 때만 다운로드
- **에러 처리**: Either 패턴으로 안전한 에러 처리
- **로깅**: 모든 단계에서 상세한 로그 출력
- **캐시 전략**: 한 번 다운로드하면 계속 사용 (버전 변경 시에만 업데이트)
