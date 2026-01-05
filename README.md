# 빛나는 순간들 (Shining Moments)

아이의 그림을 AI로 분석하여 심리 상태를 파악하고 부모에게 조언을 제공하는 Flutter 앱입니다.

## 주요 기능

- 📸 **그림 촬영/업로드**: 카메라 또는 갤러리에서 아이의 그림 선택
- 🤖 **AI 분석**: Google Gemini AI를 사용한 그림 심리 분석
  - 색채 분석
  - 구도 및 형태 분석
  - 감정 상태 파악
  - 긍정 지수 및 창의성 점수
- 💡 **부모 가이드**: 아이와 소통하는 방법 제안
- 👨‍👩‍👧‍👦 **아이 관리**: 여러 아이의 프로필 관리
- 💾 **분석 기록**: Supabase에 저장된 분석 결과 조회

## 시작하기

### 1. 필수 요구사항

- Flutter SDK 3.10.3 이상
- Dart SDK
- Android Studio / Xcode (플랫폼에 따라)
- Supabase 계정
- Google Gemini API 키

### 2. 패키지 설치

```bash
flutter pub get
```

### 3. Gemini API 설정 ⚠️ 중요!

앱을 실행하기 전에 **반드시** Gemini API 키를 설정해야 합니다.

상세한 설정 방법은 [GEMINI_SETUP.md](GEMINI_SETUP.md) 파일을 참조하세요.

**빠른 설정:**
1. [Google AI Studio](https://aistudio.google.com/app/apikey)에서 API 키 발급
2. 프로젝트 루트에 `.env` 파일 생성
3. 다음 내용 추가:
   ```
   GEMINI_API_KEY=여기에_발급받은_API_키_입력
   ```

### 4. Supabase 설정

`lib/config/supabase_config.dart` 파일에 Supabase URL과 Anon Key가 설정되어 있습니다.

필요시 자신의 Supabase 프로젝트 정보로 변경하세요.

### 5. 앱 실행

```bash
flutter run
```

## 프로젝트 구조

```
lib/
├── config/              # 설정 파일
│   └── supabase_config.dart
├── screens/             # 화면
│   ├── analysis/        # 분석 관련 화면
│   ├── auth/            # 인증 화면
│   ├── capture/         # 그림 촬영 화면
│   ├── children/        # 아이 관리 화면
│   ├── home/            # 홈 화면
│   ├── landing/         # 랜딩 페이지
│   └── profile/         # 프로필 화면
├── services/            # 비즈니스 로직
│   ├── auth_service.dart
│   ├── children_service.dart
│   ├── gemini_service.dart       # Gemini AI 연동
│   ├── storage_service.dart      # Supabase Storage
│   └── drawings_service.dart     # 그림 데이터 관리
├── theme/               # 앱 테마
│   └── app_theme.dart
└── main.dart            # 진입점
```

## 기술 스택

- **프레임워크**: Flutter 3.10.3
- **언어**: Dart
- **백엔드**: Supabase (인증, 데이터베이스, Storage)
- **AI**: Google Gemini API (gemini-1.5-flash)
- **라우팅**: go_router
- **환경변수**: flutter_dotenv
- **이미지 처리**: image_picker

## 주요 의존성

```yaml
dependencies:
  flutter_localizations: sdk
  cupertino_icons: ^1.0.8
  go_router: ^14.0.0
  image_picker: ^1.0.7
  intl: ^0.20.2
  supabase_flutter: ^2.5.0
  flutter_dotenv: ^5.1.0
  google_generative_ai: ^0.2.2
```

## 데이터베이스 구조

### Supabase 테이블

1. **children**: 아이 프로필 정보
2. **drawings**: 그림 이미지 및 분석 결과
3. **traits**: 성향 목록
4. **children_traits**: 아이별 성향 매핑

자세한 스키마는 `docs/` 폴더를 참조하세요.

## 문제 해결

### "GEMINI_API_KEY가 설정되지 않았습니다" 에러

`.env` 파일이 없거나 API 키가 설정되지 않은 경우입니다.
[GEMINI_SETUP.md](GEMINI_SETUP.md)의 설정 가이드를 따라주세요.

### 이미지 업로드 실패

Supabase Storage에 `drawings` 버킷이 생성되어 있는지 확인하세요.
버킷은 public으로 설정되어야 합니다.

### 분석 결과가 표시되지 않음

1. Gemini API 키가 올바른지 확인
2. 네트워크 연결 확인
3. Gemini API 할당량 확인 (무료: 일일 1,500회)

## 개발 로그

주요 로그는 `print()` 문으로 출력됩니다:
- 이미지 업로드 진행 상황
- Gemini API 호출 및 응답
- 데이터베이스 쿼리 결과

터미널에서 `flutter run`으로 실행하면 실시간 로그를 확인할 수 있습니다.

## 라이선스

MIT License

## 기여

이슈 및 PR은 언제든지 환영합니다!

## 문의

문제가 발생하면 GitHub Issues에 등록해주세요.
