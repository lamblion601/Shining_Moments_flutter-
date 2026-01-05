# Gemini API 설정 가이드

## 개요
이 앱은 Google Gemini AI를 사용하여 아이의 그림을 분석합니다. Gemini API를 사용하려면 API 키가 필요합니다.

## 1단계: Gemini API 키 발급받기

### 1.1 Google AI Studio 접속
1. 브라우저에서 [Google AI Studio](https://aistudio.google.com/app/apikey) 접속
2. Google 계정으로 로그인

### 1.2 API 키 생성
1. "Get API key" 버튼 클릭
2. "Create API key" 선택
3. 프로젝트 선택 (새 프로젝트 생성 가능)
4. API 키가 생성됨 - **반드시 안전한 곳에 복사해두세요!**

> ⚠️ **주의**: API 키는 다시 확인할 수 없으므로 안전한 곳에 보관하세요.

## 2단계: 프로젝트에 API 키 설정

### 2.1 .env 파일 생성

프로젝트 루트 디렉토리(pubspec.yaml이 있는 위치)에 `.env` 파일을 생성하세요:

```bash
# Windows PowerShell
cd c:\project\Shining_Moments_flutter
New-Item -Path ".env" -ItemType File

# Windows CMD
cd c:\project\Shining_Moments_flutter
type nul > .env
```

### 2.2 API 키 추가

`.env` 파일을 텍스트 에디터로 열고 다음 내용을 추가하세요:

```env
GEMINI_API_KEY=여기에_발급받은_API_키를_붙여넣기
```

**예시:**
```env
GEMINI_API_KEY=AIzaSyDq1234567890abcdefghijklmnopqrstuvwxyz
```

> 💡 **팁**: API 키 앞뒤에 따옴표나 공백이 없어야 합니다.

### 2.3 .env 파일 확인

`.env` 파일이 제대로 생성되었는지 확인:

```bash
# Windows PowerShell
Get-Content .env

# Windows CMD
type .env
```

출력 예시:
```
GEMINI_API_KEY=AIzaSyDq1234567890abcdefghijklmnopqrstuvwxyz
```

## 3단계: 앱 실행

### 3.1 패키지 설치 (이미 완료됨)

```bash
flutter pub get
```

### 3.2 앱 실행

```bash
flutter run
```

## 4단계: 기능 테스트

1. 앱을 실행하고 로그인
2. 아이 프로필 추가 (아직 없다면)
3. "그림 촬영" 메뉴로 이동
4. 그림을 촬영하거나 갤러리에서 선택
5. "AI 분석하기" 버튼 클릭
6. 분석 로딩 화면에서 진행 상황 확인
7. 분석 결과 확인

## 문제 해결

### 에러: "GEMINI_API_KEY가 설정되지 않았습니다"

**원인**: `.env` 파일이 없거나 API 키가 설정되지 않았습니다.

**해결 방법**:
1. 프로젝트 루트에 `.env` 파일이 있는지 확인
2. `.env` 파일에 `GEMINI_API_KEY=...` 형식으로 작성되었는지 확인
3. API 키 앞뒤에 공백이나 따옴표가 없는지 확인
4. 앱을 재시작 (Hot Reload가 아닌 완전 재시작)

### 에러: "API 호출 실패" 또는 "403 Forbidden"

**원인**: API 키가 유효하지 않거나 권한이 없습니다.

**해결 방법**:
1. [Google AI Studio](https://aistudio.google.com/app/apikey)에서 API 키가 활성화되어 있는지 확인
2. API 키를 다시 생성하고 `.env` 파일 업데이트
3. Gemini API가 사용 가능한 지역인지 확인

### 에러: "할당량 초과" 또는 "429 Too Many Requests"

**원인**: 무료 할당량을 초과했습니다.

**해결 방법**:
1. [Google Cloud Console](https://console.cloud.google.com/)에서 할당량 확인
2. 24시간 후 다시 시도 (무료 할당량은 일일 리셋됨)
3. 필요시 유료 플랜으로 업그레이드

## Gemini API 할당량 정보

### 무료 플랜
- **요청 제한**: 분당 15회, 일일 1,500회
- **토큰 제한**: 분당 1백만 토큰, 일일 1,500만 토큰
- **비용**: 무료

### 유료 플랜
- 자세한 정보는 [Google AI Pricing](https://ai.google.dev/pricing) 참조

## 보안 주의사항

⚠️ **중요**: API 키는 절대 공개 저장소에 업로드하지 마세요!

### .gitignore 확인

프로젝트의 `.gitignore` 파일에 다음이 포함되어 있는지 확인:

```gitignore
# Environment variables
.env
.env.local
.env.*.local
```

### API 키가 실수로 노출된 경우

1. 즉시 [Google AI Studio](https://aistudio.google.com/app/apikey)에서 해당 API 키 삭제
2. 새 API 키 생성
3. `.env` 파일 업데이트
4. Git 히스토리에서 키 제거 (필요시)

## 추가 리소스

- [Gemini API 문서](https://ai.google.dev/docs)
- [Google AI Studio](https://aistudio.google.com/)
- [Flutter dotenv 패키지](https://pub.dev/packages/flutter_dotenv)
- [Google Generative AI Dart 패키지](https://pub.dev/packages/google_generative_ai)

## 도움이 필요하신가요?

문제가 계속되면:
1. 터미널에 표시되는 에러 메시지 확인
2. 앱 로그 확인 (`flutter run` 실행 중인 터미널)
3. 위의 문제 해결 가이드 참조




