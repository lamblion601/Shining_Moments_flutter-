import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../landing/landing_screen.dart';

class SignUpCompleteScreen extends StatelessWidget {
  const SignUpCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              
              // 중앙 일러스트 카드
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // 메인 카드
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // 어린 소년 일러스트 (간단한 표현)
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.amber[50],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // 소년 얼굴 (원형)
                              Positioned(
                                top: 20,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD4A574), // 갈색 피부
                                    shape: BoxShape.circle,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // 곱슬머리
                                      Positioned(
                                        top: -10,
                                        child: Container(
                                          width: 90,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2C2C2C), // 어두운 곱슬머리
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(45),
                                              topRight: Radius.circular(45),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // 눈
                                      Positioned(
                                        left: 20,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 20,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                      // 미소
                                      Positioned(
                                        bottom: 15,
                                        child: Container(
                                          width: 30,
                                          height: 15,
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                            borderRadius: const BorderRadius.only(
                                              bottomLeft: Radius.circular(15),
                                              bottomRight: Radius.circular(15),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // 몸통 (노란 셔츠)
                              Positioned(
                                bottom: 40,
                                child: Container(
                                  width: 100,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary, // 노란 셔츠
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              // 그림판
                              Positioned(
                                bottom: 20,
                                right: 20,
                                child: Container(
                                  width: 80,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                      width: 2,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      // 왼쪽 그림 (파란 원 + 빨간 선)
                                      Positioned(
                                        left: 10,
                                        top: 15,
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: 20,
                                              height: 20,
                                              decoration: const BoxDecoration(
                                                color: Colors.blue,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            Positioned(
                                              top: -5,
                                              left: -5,
                                              child: CustomPaint(
                                                size: const Size(30, 30),
                                                painter: ScribblePainter(Colors.red),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // 오른쪽 그림 (노란 원 + 주황 선)
                                      Positioned(
                                        right: 10,
                                        top: 20,
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: 18,
                                              height: 18,
                                              decoration: const BoxDecoration(
                                                color: Colors.orange,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            Positioned(
                                              top: -5,
                                              right: -5,
                                              child: CustomPaint(
                                                size: const Size(28, 28),
                                                painter: ScribblePainter(Colors.deepOrange),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 체크마크 아이콘 (카드 오른쪽 하단)
                  Positioned(
                    bottom: -15,
                    right: 20,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: AppTheme.primary,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 60),
              
              // 제목
              const Text(
                '회원가입이 완료되었습니다!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                  height: 1.3,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 서브텍스트
              Column(
                children: [
                  Text(
                    '아이의 마음을 이해하는 첫 걸음,',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  Text(
                    'AI 미술 심리 분석이 준비되었습니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 60),
              
              // 보안 인증 텍스트
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Securely verified via Clerk',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // 서비스 시작하기 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    print('서비스 시작하기 버튼 클릭');
                    // 메인 화면으로 이동
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LandingScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.textDark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '서비스 시작하기',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// 낙서 효과를 위한 커스텀 페인터
class ScribblePainter extends CustomPainter {
  final Color color;
  
  ScribblePainter(this.color);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    // 불규칙한 낙서 선 그리기
    path.moveTo(size.width * 0.2, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.1, size.width * 0.8, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.7, size.width * 0.3, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.1, size.height * 0.5, size.width * 0.2, size.height * 0.3);
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


