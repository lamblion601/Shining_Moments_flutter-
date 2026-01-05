# Supabase 데이터베이스 설정 가이드

## 개요
이 앱은 Supabase를 백엔드로 사용합니다. 아래 단계를 따라 필요한 테이블을 생성하세요.

## drawings 테이블 생성

### 1. Supabase 대시보드 접속

1. [Supabase 대시보드](https://supabase.com/dashboard) 접속
2. 프로젝트 선택
3. 왼쪽 메뉴에서 "SQL Editor" 클릭

### 2. drawings 테이블 생성 SQL 실행

다음 SQL을 복사하여 SQL Editor에 붙여넣고 실행하세요:

```sql
-- drawings 테이블 생성
CREATE TABLE IF NOT EXISTS public.drawings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    child_id UUID NOT NULL,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    description TEXT,
    analysis_result JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 인덱스 생성 (성능 향상)
CREATE INDEX IF NOT EXISTS idx_drawings_user_id ON public.drawings(user_id);
CREATE INDEX IF NOT EXISTS idx_drawings_child_id ON public.drawings(child_id);
CREATE INDEX IF NOT EXISTS idx_drawings_created_at ON public.drawings(created_at DESC);

-- RLS (Row Level Security) 활성화
ALTER TABLE public.drawings ENABLE ROW LEVEL SECURITY;

-- RLS 정책: 사용자는 자신의 drawings만 조회 가능
CREATE POLICY "Users can view their own drawings"
ON public.drawings
FOR SELECT
USING (auth.uid() = user_id);

-- RLS 정책: 사용자는 자신의 drawings만 삽입 가능
CREATE POLICY "Users can insert their own drawings"
ON public.drawings
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- RLS 정책: 사용자는 자신의 drawings만 수정 가능
CREATE POLICY "Users can update their own drawings"
ON public.drawings
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- RLS 정책: 사용자는 자신의 drawings만 삭제 가능
CREATE POLICY "Users can delete their own drawings"
ON public.drawings
FOR DELETE
USING (auth.uid() = user_id);

-- 설명 추가
COMMENT ON TABLE public.drawings IS '아이의 그림과 AI 분석 결과를 저장하는 테이블';
COMMENT ON COLUMN public.drawings.id IS '그림 고유 ID';
COMMENT ON COLUMN public.drawings.child_id IS '그린 아이의 ID (children 테이블 참조)';
COMMENT ON COLUMN public.drawings.user_id IS '업로드한 사용자 ID (부모)';
COMMENT ON COLUMN public.drawings.image_url IS 'Supabase Storage에 저장된 이미지 URL';
COMMENT ON COLUMN public.drawings.description IS '부모가 작성한 그림 설명 (선택)';
COMMENT ON COLUMN public.drawings.analysis_result IS 'Gemini AI 분석 결과 (JSON 형식)';
COMMENT ON COLUMN public.drawings.created_at IS '그림 업로드 날짜';
```

### 3. Supabase Storage 버킷 생성

#### 3.1 Storage 메뉴 접속

1. 왼쪽 메뉴에서 "Storage" 클릭
2. "Create a new bucket" 버튼 클릭

#### 3.2 버킷 설정

- **Name**: `drawings`
- **Public bucket**: ✅ 체크 (이미지를 웹에서 직접 볼 수 있도록)
- **Allowed MIME types**: (비워두거나) `image/jpeg,image/png,image/jpg`
- **File size limit**: `10 MB` (선택사항)

#### 3.3 버킷 정책 설정 (선택사항)

기본적으로 public 버킷은 누구나 파일을 읽을 수 있습니다.
더 세밀한 권한 제어가 필요하다면 Storage Policies를 설정하세요.

**읽기 권한 (모두 허용)**:
```sql
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING ( bucket_id = 'drawings' );
```

**업로드 권한 (인증된 사용자만)**:
```sql
CREATE POLICY "Authenticated users can upload"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'drawings' 
  AND auth.role() = 'authenticated'
);
```

**삭제 권한 (파일 소유자만)**:
```sql
CREATE POLICY "Users can delete their own files"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'drawings' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

## 기존 테이블 확인

앱이 사용하는 다른 테이블들이 이미 생성되어 있는지 확인하세요:

### children 테이블 (또는 tb_children)

아이의 프로필 정보를 저장합니다.

```sql
-- 테이블 존재 여부 확인
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_schema = 'public' 
  AND table_name = 'children'
);

-- 또는
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_schema = 'public' 
  AND table_name = 'tb_children'
);
```

만약 테이블이 없다면 기존 프로젝트 문서의 SQL을 참조하여 생성하세요.

## 테이블 구조 확인

### drawings 테이블이 제대로 생성되었는지 확인

```sql
-- 테이블 구조 확인
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'drawings'
ORDER BY ordinal_position;
```

### 예상 출력:

| column_name     | data_type                   | is_nullable | column_default         |
|-----------------|----------------------------|-------------|------------------------|
| id              | uuid                       | NO          | gen_random_uuid()      |
| child_id        | uuid                       | NO          |                        |
| user_id         | uuid                       | NO          |                        |
| image_url       | text                       | NO          |                        |
| description     | text                       | YES         |                        |
| analysis_result | jsonb                      | NO          |                        |
| created_at      | timestamp with time zone   | NO          | timezone('utc'...)     |

## 테스트

### 1. 테스트 데이터 삽입 (선택사항)

```sql
-- 현재 로그인한 사용자의 ID 확인
SELECT auth.uid();

-- 테스트 drawing 삽입 (child_id는 실제 children 테이블의 ID로 교체)
INSERT INTO public.drawings (
  child_id,
  user_id,
  image_url,
  description,
  analysis_result
) VALUES (
  'YOUR_CHILD_ID_HERE'::uuid,
  auth.uid(),
  'https://example.com/test-image.jpg',
  '테스트 그림',
  '{
    "emotion": "행복한",
    "emotionEmoji": "😊",
    "summary": "테스트 분석 결과입니다.",
    "interpretation": "아이가 밝은 상태입니다.",
    "tags": ["행복", "밝음"],
    "positivityScore": 85,
    "creativityScore": 80,
    "colorAnalysis": "밝은 색상 사용",
    "lineAnalysis": "부드러운 선",
    "compositionAnalysis": "균형잡힌 구도",
    "parentGuide": ["칭찬해주세요", "함께 그림을 그려보세요"]
  }'::jsonb
);
```

### 2. 데이터 조회 테스트

```sql
-- 내 drawings 조회
SELECT 
  id,
  child_id,
  image_url,
  description,
  analysis_result->>'emotion' as emotion,
  created_at
FROM public.drawings
WHERE user_id = auth.uid()
ORDER BY created_at DESC;
```

## 문제 해결

### 에러: "permission denied for table drawings"

**원인**: RLS 정책이 제대로 설정되지 않았습니다.

**해결**: 위의 RLS 정책 SQL을 다시 실행하세요.

### 에러: "foreign key constraint fails"

**원인**: child_id가 children 테이블에 존재하지 않습니다.

**해결**: 
1. children 테이블에 아이 프로필을 먼저 생성하세요.
2. 또는 foreign key 제약 조건을 제거하세요 (권장하지 않음).

### Storage 업로드 실패

**에러 메시지**: 
```
StorageException(message: new row violates row-level security policy, statusCode: 403, error: Unauthorized)
```

**원인**: Storage 버킷이 생성되지 않았거나 권한이 없습니다.

**해결 방법**:

#### 1단계: 버킷 생성 확인

1. Supabase Dashboard 접속
2. 왼쪽 메뉴에서 **Storage** 클릭
3. `drawings` 버킷이 있는지 확인

#### 2단계: 버킷 생성 (없는 경우)

1. **"New bucket"** 또는 **"Create a new bucket"** 버튼 클릭
2. 다음 정보 입력:
   - **Name**: `drawings` (정확히 입력)
   - **Public bucket**: ✅ **반드시 체크** (중요!)
   - **Allowed MIME types**: `image/jpeg,image/png,image/jpg`
   - **File size limit**: `10 MB`
3. **"Create bucket"** 클릭

#### 3단계: Storage Policies 설정

버킷을 생성한 후, Storage Policies를 설정해야 합니다.

1. Storage 메뉴에서 `drawings` 버킷 클릭
2. **"Policies"** 탭 클릭
3. 다음 SQL을 실행:

```sql
-- 읽기 권한 (모두 허용)
CREATE POLICY "Anyone can view drawings"
ON storage.objects FOR SELECT
USING ( bucket_id = 'drawings' );

-- 업로드 권한 (인증된 사용자만)
CREATE POLICY "Authenticated users can upload drawings"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'drawings' 
  AND auth.role() = 'authenticated'
);

-- 삭제 권한 (파일 소유자만)
CREATE POLICY "Users can delete their own drawings"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'drawings' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

#### 4단계: 테스트

앱을 다시 실행하고 그림 분석을 시도해보세요.

#### 여전히 실패하는 경우

1. **버킷 이름 확인**: 정확히 `drawings`인지 확인 (대소문자 구분)
2. **Public 설정 확인**: 버킷이 Public으로 설정되어 있는지 확인
3. **로그인 상태 확인**: 앱에서 로그인되어 있는지 확인
4. **네트워크 확인**: 인터넷 연결 상태 확인

## 데이터베이스 마이그레이션 (추가 기능)

나중에 테이블 구조를 변경해야 한다면:

```sql
-- 예: description 필드 최대 길이 설정
ALTER TABLE public.drawings
ALTER COLUMN description TYPE VARCHAR(500);

-- 예: 새 컬럼 추가
ALTER TABLE public.drawings
ADD COLUMN tags TEXT[];
```

## 백업 권장사항

중요한 데이터는 정기적으로 백업하세요:

1. Supabase 대시보드 → Database → Backups
2. 자동 백업 활성화 (Pro 플랜 이상)
3. 또는 수동으로 SQL 덤프 생성:

```bash
pg_dump -h db.your-project.supabase.co -U postgres -d postgres > backup.sql
```

## 추가 리소스

- [Supabase 문서](https://supabase.com/docs)
- [PostgreSQL JSON 함수](https://www.postgresql.org/docs/current/functions-json.html)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)

