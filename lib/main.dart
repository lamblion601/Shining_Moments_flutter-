import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/supabase_config.dart';
import 'theme/app_theme.dart';
import 'screens/landing/landing_screen.dart';
import 'screens/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 환경 변수 로드
  try {
    await dotenv.load(fileName: '.env');
    print('환경 변수 로드 완료');
  } catch (e) {
    print('환경 변수 로드 실패: $e');
    print('경고: .env 파일이 없습니다. Gemini API를 사용하려면 .env 파일을 생성하고 GEMINI_API_KEY를 설정하세요.');
  }

  // 한국어 로케일 데이터 초기화
  await initializeDateFormatting('ko_KR', null);

  // Supabase 초기화
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const MyApp());
}

// Supabase 클라이언트 전역 접근
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shining Moments',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('ko', 'KR'),
      home: _AuthWrapper(),
    );
  }
}

// 인증 상태에 따라 화면을 결정하는 위젯
class _AuthWrapper extends StatelessWidget {
  const _AuthWrapper();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // 인증 상태 확인
        final session = supabase.auth.currentSession;
        
        print('인증 상태 확인: ${session != null ? "로그인됨" : "로그인 안됨"}');
        
        // 세션이 있으면 홈 화면, 없으면 랜딩 화면
        if (session != null) {
          return const HomeScreen();
        } else {
          return const LandingScreen();
        }
      },
    );
  }
}
