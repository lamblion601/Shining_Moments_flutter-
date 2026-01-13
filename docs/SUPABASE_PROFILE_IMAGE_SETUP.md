# Supabase 프로필 이미지 컬럼 추가 가이드

## 문제 상황

프로필 이미지를 업로드하려고 하면 다음 에러가 발생합니다:

```
PostgrestException(message: Could not find the 'profile_image_url' column of 'children' in the schema cache)
```

## 원인

`children` 테이블에 `profile_image_url` 컬럼이 없기 때문입니다.

## 해결 방법

### 🚀 방법 1: Supabase 대시보드에서 직접 추가 (추천)

1. **Supabase Dashboard 접속**
   - https://supabase.com/dashboard 로그인

2. **프로젝트 선택**
   - Shining Moments 프로젝트 선택

3. **Table Editor로 이동**
   - 왼쪽 메뉴에서 "Table Editor" 클릭

4. **children 테이블 선택**

5. **새 컬럼 추가**
   - "New Column" 버튼 클릭
   - 다음 정보 입력:
     ```
     Name: profile_image_url
     Type: text
     Default value: (비워두기)
     Is nullable: ✅ 체크
     Is unique: ☐ 체크 안 함
     Is primary key: ☐ 체크 안 함
     ```
   - "Save" 클릭

6. **완료!** 🎉

---

### 💻 방법 2: SQL 편집기에서 실행

1. **Supabase Dashboard** → **SQL Editor**로 이동

2. **New Query** 클릭

3. **다음 SQL 복사 후 붙여넣기:**

```sql
-- children 테이블에 profile_image_url 컬럼 추가
ALTER TABLE children 
ADD COLUMN IF NOT EXISTS profile_image_url TEXT;

-- 컬럼 설명 추가
COMMENT ON COLUMN children.profile_image_url IS '아이 프로필 이미지 URL (Supabase Storage)';
```

4. **"Run"** 버튼 클릭

5. **완료!** 🎉

---

### 🔧 방법 3: 로컬 마이그레이션 파일 사용

마이그레이션 파일이 이미 생성되어 있습니다:
- 파일 위치: `supabase/migrations/20260112_add_profile_image_url.sql`

**Supabase CLI가 설치되어 있다면:**

```bash
# Supabase 링크
supabase link --project-ref YOUR_PROJECT_REF

# 마이그레이션 실행
supabase db push
```

---

## 확인 방법

1. **Supabase Dashboard** → **Table Editor** → **children** 테이블
2. 컬럼 목록에서 `profile_image_url` 컬럼이 있는지 확인
3. 있으면 성공! ✅

---

## 다음 단계

1. **앱을 hot restart** (R키)
2. **아이 프로필 수정** 화면으로 이동
3. **프로필 이미지 선택** 및 저장
4. **정상적으로 저장되는지 확인** ✅

---

## 문제가 계속되면

다음을 확인해주세요:

1. **테이블 이름 확인**
   - `children` 테이블이 맞는지 확인
   - `tb_children`이 아닌 `children` 사용 중

2. **RLS 정책 확인**
   - `children` 테이블의 RLS 정책이 올바른지 확인
   - UPDATE 권한이 있는지 확인

3. **캐시 새로고침**
   - Supabase Dashboard에서 "Refresh" 클릭
   - 앱을 완전히 재시작

---

## 참고

- 이 컬럼은 Supabase Storage에 업로드된 이미지의 Public URL을 저장합니다
- 형식: `https://[project].supabase.co/storage/v1/object/public/drawings/child_[userId]_[childId]_[timestamp].png`
- nullable이므로 프로필 이미지가 없어도 아이 정보를 저장할 수 있습니다



