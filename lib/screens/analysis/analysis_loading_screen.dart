import 'package:flutter/material.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../services/children_service.dart';
import 'analysis_result_screen.dart';

/// 그림 분석 로딩 화면
class AnalysisLoadingScreen extends StatefulWidget {
  final File? imageFile;
  final Child? selectedChild;

  const AnalysisLoadingScreen({
    super.key,
    this.imageFile,
    this.selectedChild,
  });

  @override
  State<AnalysisLoadingScreen> createState() => _AnalysisLoadingScreenState();
}

class _AnalysisLoadingScreenState extends State<AnalysisLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    print('그림 분석 로딩 화면 시작: ${widget.imageFile?.path ?? "이미지 없음"}');
    
    // 펄스 애니메이션 (확대/축소)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 회전 애니메이션
    _rotateController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _rotateAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );

    // 실제 분석 시작 (시뮬레이션)
    _startAnalysis();
  }

  Future<void> _startAnalysis() async {
    try {
      print('그림 분석 시작');
      if (widget.imageFile != null && widget.imageFile!.existsSync()) {
        print('이미지 파일 경로: ${widget.imageFile!.path}');
      }
      print('선택된 아이: ${widget.selectedChild?.name ?? "없음"}');
      
      // TODO: 실제 AI 분석 API 호출
      // 여기서는 시뮬레이션으로 10초 대기
      await Future.delayed(const Duration(seconds: 10));
      
      print('그림 분석 완료 - 결과 페이지로 이동 준비');
      
      if (!mounted) {
        print('위젯이 dispose되어 이동 불가');
        return;
      }
      
      // 분석 결과 페이지로 이동 (더 확실하게 처리)
      print('AnalysisResultScreen 생성 및 네비게이션 시작');
      
      // 이미지 파일이 존재하는지 확인
      File? imageFileToPass;
      if (widget.imageFile != null && widget.imageFile!.existsSync()) {
        imageFileToPass = widget.imageFile;
      }
      
      // pushReplacement로 현재 화면을 결과 화면으로 교체
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) {
              print('AnalysisResultScreen 생성 중...');
              return AnalysisResultScreen(
                imageFile: imageFileToPass,
                selectedChild: widget.selectedChild,
              );
            },
          ),
        );
        print('분석 결과 페이지로 이동 완료');
      }
    } catch (e, stackTrace) {
      print('분석 에러 발생: $e');
      print('에러 타입: ${e.runtimeType}');
      print('에러 스택: $stackTrace');
      
      if (!mounted) {
        print('에러 발생 후 위젯이 dispose됨');
        return;
      }
      
      // 에러가 발생해도 결과 페이지는 보여주기
      try {
        print('에러 발생 후에도 결과 페이지로 이동 시도');
        await Future.delayed(const Duration(milliseconds: 200));
        
        if (!mounted) return;
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AnalysisResultScreen(
              imageFile: widget.imageFile != null && widget.imageFile!.existsSync() 
                  ? widget.imageFile 
                  : null,
              selectedChild: widget.selectedChild,
            ),
          ),
        );
        print('에러 후 결과 페이지 이동 성공');
      } catch (finalError, finalStack) {
        print('최종 네비게이션 에러: $finalError');
        print('최종 에러 스택: $finalStack');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('분석 중 오류가 발생했습니다: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
          // 에러 발생 시 이전 화면으로 돌아가기
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final childName = widget.selectedChild?.name ?? '아이';
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            // 메인 콘텐츠
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // 이미지 미리보기
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary.withOpacity(0.3),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: widget.imageFile != null && widget.imageFile!.existsSync()
                                    ? Image.file(
                                        widget.imageFile!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          // 이미지 로드 실패 시 플레이스홀더
                                          return Container(
                                            color: AppTheme.primary.withOpacity(0.1),
                                            child: Icon(
                                              Icons.image,
                                              size: 80,
                                              color: AppTheme.primaryHover,
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        // 테스트 모드: 이미지 파일이 없을 때
                                        color: AppTheme.primary.withOpacity(0.1),
                                        child: Icon(
                                          Icons.image,
                                          size: 80,
                                          color: AppTheme.primaryHover,
                                        ),
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 48),
                      // 로딩 아이콘
                      AnimatedBuilder(
                        animation: _rotateAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotateAnimation.value * 2 * 3.14159,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                size: 40,
                                color: AppTheme.primaryHover,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      // 메시지
                      Text(
                        '$childName의 그림을\n분석하고 있어요...',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'AI가 색채, 구도, 필압 등을\n정밀하게 분석 중입니다',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 48),
                      // 진행 단계 표시
                      _buildProgressSteps(),
                      const SizedBox(height: 32),
                      // 로딩 인디케이터
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryHover),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSteps() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildStepItem(
            icon: Icons.palette,
            title: '색채 분석',
            isCompleted: true,
          ),
          const SizedBox(height: 16),
          _buildStepItem(
            icon: Icons.auto_awesome,
            title: '구도 및 형태 분석',
            isCompleted: true,
          ),
          const SizedBox(height: 16),
          _buildStepItem(
            icon: Icons.psychology,
            title: '심리 상태 분석',
            isCompleted: false,
            isActive: true,
          ),
          const SizedBox(height: 16),
          _buildStepItem(
            icon: Icons.lightbulb,
            title: '맞춤 조언 생성',
            isCompleted: false,
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required IconData icon,
    required String title,
    required bool isCompleted,
    bool isActive = false,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppTheme.primaryHover
                : isActive
                    ? AppTheme.primary.withOpacity(0.3)
                    : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: isCompleted
              ? const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                )
              : isActive
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryHover),
                      ),
                    )
                  : Icon(
                      icon,
                      color: Colors.grey[400],
                      size: 20,
                    ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isCompleted || isActive
                  ? AppTheme.textDark
                  : AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

