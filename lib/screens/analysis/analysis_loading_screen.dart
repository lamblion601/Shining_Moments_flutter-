import 'package:flutter/material.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../services/children_service.dart';
import '../../services/gemini_service.dart';
import '../../services/storage_service.dart';
import '../../services/drawings_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  
  // 서비스 인스턴스
  final GeminiService _geminiService = GeminiService();
  final StorageService _storageService = StorageService();
  final DrawingsService _drawingsService = DrawingsService();
  
  // 진행 상태
  String _currentStep = '이미지 업로드 중...';
  int _completedSteps = 0;

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
    String? imageUrl;
    String? drawingId;
    
    try {
      print('=== 그림 분석 프로세스 시작 ===');
      
      // 필수 정보 확인
      if (widget.imageFile == null || !widget.imageFile!.existsSync()) {
        throw Exception('이미지 파일이 없습니다.');
      }
      
      if (widget.selectedChild == null || widget.selectedChild!.childId == null) {
        throw Exception('아이 정보가 없습니다.');
      }
      
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }
      
      print('이미지 파일: ${widget.imageFile!.path}');
      print('아이: ${widget.selectedChild!.name}');
      print('사용자: ${user.id}');
      
      // ========== 1단계: 이미지 업로드 ==========
      if (mounted) {
        setState(() {
          _currentStep = '이미지 업로드 중...';
          _completedSteps = 0;
        });
      }
      
      print('[1/4] Storage 업로드 시작...');
      imageUrl = await _storageService.uploadDrawing(
        imageFile: widget.imageFile!,
        userId: user.id,
        childId: widget.selectedChild!.childId!,
      );
      print('[1/4] Storage 업로드 완료: $imageUrl');
      
      if (mounted) {
        setState(() {
          _completedSteps = 1;
        });
      }
      
      // ========== 2단계: Gemini AI 분석 ==========
      if (mounted) {
        setState(() {
          _currentStep = 'AI가 그림을 분석하는 중...';
          _completedSteps = 1;
        });
      }
      
      print('[2/4] Gemini 분석 시작...');
      final analysisResult = await _geminiService.analyzeDrawing(
        imageFile: widget.imageFile!,
        child: widget.selectedChild!,
      );
      print('[2/4] Gemini 분석 완료: emotion=${analysisResult['emotion']}');
      
      if (mounted) {
        setState(() {
          _completedSteps = 2;
        });
      }
      
      // ========== 3단계: 데이터베이스 저장 ==========
      if (mounted) {
        setState(() {
          _currentStep = '분석 결과 저장 중...';
          _completedSteps = 2;
        });
      }
      
      print('[3/4] DB 저장 시작...');
      final drawing = await _drawingsService.saveDrawing(
        childId: widget.selectedChild!.childId!,
        imageUrl: imageUrl,
        analysisResult: analysisResult,
      );
      drawingId = drawing.id;
      print('[3/4] DB 저장 완료: drawingId=$drawingId');
      
      if (mounted) {
        setState(() {
          _completedSteps = 3;
        });
      }
      
      // ========== 4단계: 결과 화면으로 이동 ==========
      if (mounted) {
        setState(() {
          _currentStep = '완료!';
          _completedSteps = 4;
        });
      }
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) {
        print('위젯이 dispose되어 이동 불가');
        return;
      }
      
      print('[4/4] 결과 화면으로 이동...');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AnalysisResultScreen(
            imageFile: widget.imageFile,
            selectedChild: widget.selectedChild,
            analysisData: analysisResult,
            drawingId: drawingId,
          ),
        ),
      );
      print('=== 그림 분석 프로세스 완료 ===');
      
    } catch (e, stackTrace) {
      print('=== 분석 에러 발생 ===');
      print('에러: $e');
      print('에러 타입: ${e.runtimeType}');
      print('에러 스택: $stackTrace');
      
      if (!mounted) {
        print('에러 발생 후 위젯이 dispose됨');
        return;
      }
      
      // 에러 메시지 표시
      String errorMessage = '분석 중 오류가 발생했습니다.';
      
      if (e.toString().contains('GEMINI_API_KEY')) {
        errorMessage = 'Gemini API 키가 설정되지 않았습니다.\n.env 파일에 GEMINI_API_KEY를 추가해주세요.';
      } else if (e.toString().contains('Storage')) {
        errorMessage = '이미지 업로드에 실패했습니다.';
      } else if (e.toString().contains('로그인')) {
        errorMessage = '로그인이 필요합니다.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: '확인',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
      
      // 업로드된 이미지가 있다면 삭제 (클린업)
      if (imageUrl != null) {
        try {
          print('에러 발생으로 업로드된 이미지 삭제 시도...');
          await _storageService.deleteDrawing(imageUrl);
          print('업로드된 이미지 삭제 완료');
        } catch (cleanupError) {
          print('이미지 삭제 실패: $cleanupError');
        }
      }
      
      // 2초 후 이전 화면으로 돌아가기
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        Navigator.of(context).pop();
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
                        _currentStep,
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
            icon: Icons.cloud_upload,
            title: '이미지 업로드',
            isCompleted: _completedSteps > 0,
            isActive: _completedSteps == 0,
          ),
          const SizedBox(height: 16),
          _buildStepItem(
            icon: Icons.auto_awesome,
            title: 'AI 그림 분석',
            isCompleted: _completedSteps > 1,
            isActive: _completedSteps == 1,
          ),
          const SizedBox(height: 16),
          _buildStepItem(
            icon: Icons.psychology,
            title: '심리 해석',
            isCompleted: _completedSteps > 2,
            isActive: _completedSteps == 2,
          ),
          const SizedBox(height: 16),
          _buildStepItem(
            icon: Icons.save,
            title: '결과 저장',
            isCompleted: _completedSteps > 3,
            isActive: _completedSteps == 3,
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

