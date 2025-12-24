import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 회원가입 (이메일 인증 없이)
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('회원가입 시도: $email');
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
        },
        emailRedirectTo: null, // 이메일 리다이렉트 비활성화
      );
      
      // 사용자가 생성되었는지 확인
      if (response.user != null) {
        print('회원가입 성공: ${response.user?.email}');
        
        // 세션이 없으면 (이메일 확인이 필요한 경우) 자동으로 로그인 시도
        if (response.session == null) {
          print('이메일 확인 없이 사용자 생성됨. 자동 로그인 시도...');
          // 잠시 대기 후 로그인 시도 (사용자 생성이 완료될 시간 확보)
          await Future.delayed(const Duration(milliseconds: 500));
          
          try {
            final loginResponse = await _supabase.auth.signInWithPassword(
              email: email,
              password: password,
            );
            print('자동 로그인 성공: ${loginResponse.user?.email}');
            return loginResponse;
          } catch (loginError) {
            print('자동 로그인 실패: $loginError');
            // 사용자는 생성되었으므로 성공으로 처리
            return response;
          }
        }
        
        // 세션이 있으면 바로 반환
        return response;
      }
      
      throw Exception('사용자 생성에 실패했습니다.');
    } catch (e) {
      print('회원가입 에러: $e');
      
      // 이메일 프로바이더가 비활성화된 경우
      if (e.toString().contains('email_provider_disabled') ||
          e.toString().contains('Email signups are disabled')) {
        throw Exception(
          '이메일 회원가입이 비활성화되어 있습니다.\n'
          'Supabase 대시보드에서 이메일 프로바이더를 활성화해주세요:\n'
          '1. Supabase 대시보드 접속\n'
          '2. Authentication > Providers > Email\n'
          '3. "Enable Email Provider" 활성화'
        );
      }
      
      // 이메일 전송 실패 에러인 경우, 사용자가 생성되었는지 확인
      if (e.toString().contains('Error sending confirmation email') ||
          e.toString().contains('unexpected_failure')) {
        print('이메일 전송 실패 감지. 사용자 생성 여부 확인 중...');
        
        // 사용자가 생성되었는지 확인하기 위해 여러 번 시도
        for (int i = 0; i < 3; i++) {
          await Future.delayed(Duration(milliseconds: 500 * (i + 1)));
          
          try {
            final loginResponse = await _supabase.auth.signInWithPassword(
              email: email,
              password: password,
            );
            print('이메일 전송 실패했지만 사용자는 생성됨. 로그인 성공: ${loginResponse.user?.email}');
            return loginResponse;
          } catch (loginError) {
            print('로그인 시도 ${i + 1}/3 실패: $loginError');
            
            // 마지막 시도에서도 실패하면 에러 메시지 개선
            if (i == 2) {
              if (loginError.toString().contains('Invalid login credentials') ||
                  loginError.toString().contains('invalid_credentials')) {
                throw Exception(
                  '회원가입은 완료되었지만 이메일 확인이 필요합니다.\n'
                  'Supabase 대시보드에서 "Confirm email" 옵션을 비활성화해주세요:\n'
                  '1. Authentication > Providers > Email\n'
                  '2. "Confirm email" 옵션을 OFF로 설정'
                );
              }
              // 원래 에러를 다시 던짐
              rethrow;
            }
          }
        }
      }
      
      rethrow;
    }
  }

  // 로그인
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('로그인 시도: $email');
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      print('로그인 성공: ${response.user?.email}');
      return response;
    } catch (e) {
      print('로그인 에러: $e');
      rethrow;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    print('로그아웃 완료');
  }

  // 현재 사용자 정보
  User? get currentUser => _supabase.auth.currentUser;

  // 인증 상태 스트림
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
  
  // 현재 세션이 유효한지 확인
  bool get isAuthenticated => _supabase.auth.currentSession != null;
}

