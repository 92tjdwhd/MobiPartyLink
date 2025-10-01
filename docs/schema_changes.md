# SQL 테이블 변경점 정리

## 📊 기존 스키마 vs 새로운 스키마

### **변경 사항 요약:**
1. ✅ **users 테이블 삭제** (서버에 사용자 프로필 저장 안 함)
2. ✅ **party_members 테이블 구조 변경** (로컬 프로필 + FCM 토큰 추가)
3. ✅ **creator_id 타입 변경** (UUID → TEXT, Supabase Auth userId)
4. ✅ **RLS 정책 업데이트** (익명 인증 지원)

---

## 🗑️ 1. 삭제된 테이블

### **users 테이블 (❌ 삭제)**
```sql
-- ❌ 기존 (삭제됨)
CREATE TABLE users (
  id UUID PRIMARY KEY,
  nickname TEXT NOT NULL,
  job_id TEXT REFERENCES jobs(id),
  power INTEGER,
  created_at TIMESTAMP
);
```

**이유:**
- 서버에 사용자 프로필을 저장할 필요 없음
- 로컬(SharedPreferences)에서 프로필 관리
- 파티 참가 시 프로필 스냅샷을 `party_members`에 저장

---

## 🔄 2. 변경된 테이블

### **A. parties 테이블**

#### **creator_id 타입 변경:**
```sql
-- ❌ 기존
creator_id UUID REFERENCES users(id)

-- ✅ 새로운
creator_id TEXT NOT NULL  -- Supabase Auth userId (익명 인증)
```

#### **비교:**
| 항목 | 기존 | 새로운 | 변경 이유 |
|------|------|--------|----------|
| `creator_id` 타입 | `UUID` | `TEXT` | Supabase Auth userId는 TEXT 타입 |
| 외래키 | `REFERENCES users(id)` | 없음 | users 테이블 삭제 |

---

### **B. party_members 테이블 (대폭 변경!)**

#### **전체 구조 비교:**
```sql
-- ❌ 기존
CREATE TABLE party_members (
  id UUID PRIMARY KEY,
  party_id UUID REFERENCES parties(id),
  user_id UUID REFERENCES users(id),  -- ← users 테이블 참조
  joined_at TIMESTAMP
);

-- ✅ 새로운
CREATE TABLE party_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  party_id UUID REFERENCES parties(id) ON DELETE CASCADE,
  user_id TEXT NOT NULL,  -- ← Supabase Auth userId (익명 인증)
  
  -- 로컬 프로필 스냅샷 (추가!)
  nickname TEXT NOT NULL,
  job TEXT,
  power INTEGER,
  
  -- FCM 푸시 알림용 (추가!)
  fcm_token TEXT,
  
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(party_id, user_id)  -- ← 중복 방지 제약 추가
);
```

#### **주요 변경점:**
| 항목 | 기존 | 새로운 | 변경 이유 |
|------|------|--------|----------|
| `user_id` 타입 | `UUID` (users 테이블 참조) | `TEXT` (Supabase Auth userId) | 익명 인증 사용 |
| `nickname` | ❌ 없음 | ✅ `TEXT NOT NULL` | 로컬 프로필 스냅샷 |
| `job` | ❌ 없음 | ✅ `TEXT` | 로컬 프로필 스냅샷 |
| `power` | ❌ 없음 | ✅ `INTEGER` | 로컬 프로필 스냅샷 |
| `fcm_token` | ❌ 없음 | ✅ `TEXT` | 푸시 알림용 |
| 유니크 제약 | ❌ 없음 | ✅ `UNIQUE(party_id, user_id)` | 중복 참가 방지 |

---

## 🔐 3. RLS (Row Level Security) 정책 변경

### **기존 RLS:**
```sql
-- 기존: 인증된 사용자만 접근
CREATE POLICY "Users can only access their own data"
  ON users FOR SELECT
  TO authenticated
  USING (auth.uid() = id);
```

### **새로운 RLS:**
```sql
-- 새로운: 익명 사용자도 접근 가능
CREATE POLICY "Allow authenticated users to create parties"
  ON parties FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid()::text = creator_id);

CREATE POLICY "Allow authenticated users to join parties"
  ON party_members FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid()::text = user_id);
```

#### **주요 변경점:**
| 정책 | 기존 | 새로운 | 변경 이유 |
|------|------|--------|----------|
| 파티 조회 | `authenticated` 필요 | `public` 허용 | 모든 사용자가 파티 목록 조회 가능 |
| 파티 생성 | `authenticated` 필요 | `authenticated` 필요 (익명 포함) | 익명 인증도 포함 |
| 파티 참가 | `authenticated` 필요 | `authenticated` 필요 (익명 포함) | 익명 인증도 포함 |

---

## 📝 4. 데이터 흐름 변경

### **기존 데이터 흐름:**
```
1. 사용자 회원가입 → users 테이블 저장
2. 파티 생성 → parties 테이블 저장 (creator_id = user_id)
3. 파티 참가 → party_members 테이블 저장 (user_id 참조)
4. 프로필 조회 → users 테이블에서 조회
```

### **새로운 데이터 흐름:**
```
1. 앱 설치 → 아무것도 안 함 (로컬 프로필만 생성)
2. 파티 생성/참가 → 익명 인증 (최초 1회)
3. 파티 생성 → parties 테이블 저장 (creator_id = Supabase Auth userId)
4. 파티 참가 → party_members 테이블 저장
   - user_id: Supabase Auth userId
   - nickname, job, power: 로컬 프로필에서 가져옴
   - fcm_token: FCM에서 가져옴
5. 프로필 조회 → 로컬(SharedPreferences)에서 조회
```

---

## 💾 5. 저장소 변경

### **기존 저장소:**
| 데이터 | 저장 위치 | 테이블 |
|--------|-----------|--------|
| 사용자 프로필 | 서버 | `users` |
| 파티 정보 | 서버 | `parties` |
| 파티 멤버 | 서버 | `party_members` |

### **새로운 저장소:**
| 데이터 | 저장 위치 | 테이블/저장소 |
|--------|-----------|---------------|
| 사용자 프로필 | ✅ **로컬** | `SharedPreferences` |
| userId | ✅ **로컬** | `SharedPreferences` |
| 파티 정보 | 서버 | `parties` |
| 파티 멤버 | 서버 | `party_members` (프로필 스냅샷 포함) |
| FCM 토큰 | 서버 | `party_members` |

---

## 🎯 6. 장점

### **비용 절감:**
- ✅ **DB 저장소 절감**: users 테이블 삭제
- ✅ **API 호출 절감**: 프로필 조회 API 불필요
- ✅ **인증 절감**: 파티 생성/참가 시에만 인증

### **성능 향상:**
- ✅ **빠른 프로필 조회**: 로컬에서 즉시 가져옴
- ✅ **오프라인 지원**: 네트워크 없어도 프로필 확인

### **프라이버시:**
- ✅ **개인정보 최소화**: 서버에 최소한의 정보만
- ✅ **프로필 자유 수정**: 로컬에서 자유롭게 변경

---

## 🚀 7. 마이그레이션 가이드

### **기존 데이터가 있는 경우:**
```sql
-- 1. 기존 데이터 백업
CREATE TABLE users_backup AS SELECT * FROM users;
CREATE TABLE party_members_backup AS SELECT * FROM party_members;

-- 2. 새로운 스키마 적용
-- (supabase_final_schema.sql 실행)

-- 3. 데이터 마이그레이션 (필요 시)
-- 기존 users 데이터를 party_members에 병합
UPDATE party_members pm
SET 
  nickname = u.nickname,
  job = (SELECT name FROM jobs WHERE id = u.job_id),
  power = u.power
FROM users u
WHERE pm.user_id = u.id::text;
```

### **신규 프로젝트:**
```sql
-- supabase_final_schema.sql 실행만 하면 됨!
```

---

## 📋 8. 체크리스트

- [ ] Supabase Dashboard에서 익명 인증 활성화
- [ ] `supabase_final_schema.sql` 실행
- [ ] 기존 테이블 백업 (마이그레이션 시)
- [ ] RLS 정책 확인
- [ ] 앱 코드 수정 (userId 로컬 저장 로직)
- [ ] FCM 토큰 저장 로직 추가
- [ ] 파티 생성/참가 API 테스트

---

## ✅ 완료!

