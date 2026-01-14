-- children 테이블에 profile_image_url 컬럼 추가
-- 아이의 프로필 이미지를 저장하기 위한 컬럼

-- profile_image_url 컬럼 추가
ALTER TABLE children 
ADD COLUMN IF NOT EXISTS profile_image_url TEXT;

-- 컬럼 설명 추가
COMMENT ON COLUMN children.profile_image_url IS '아이 프로필 이미지 URL (Supabase Storage)';

-- 인덱스 추가 (선택사항 - 성능 향상)
-- CREATE INDEX IF NOT EXISTS idx_children_profile_image ON children(profile_image_url) WHERE profile_image_url IS NOT NULL;








