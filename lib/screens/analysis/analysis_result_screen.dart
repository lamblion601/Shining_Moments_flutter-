import 'package:flutter/material.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../services/children_service.dart';
import '../../services/drawings_service.dart';

/// 그림 분석 결과 화면
class AnalysisResultScreen extends StatefulWidget {
  final File? imageFile;
  final Child? selectedChild;
  final Map<String, dynamic>? analysisData;
  final String? drawingId; // DB에서 조회할 경우
  final String? imageUrl; // 네트워크 이미지 URL
  
  const AnalysisResultScreen({
    super.key,
    this.imageFile,
    this.selectedChild,
    this.analysisData,
    this.drawingId,
    this.imageUrl,
  });

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  final DrawingsService _drawingsService = DrawingsService();
  Map<String, dynamic>? _analysisData;
  String? _imageUrl;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAnalysisData();
  }

  Future<void> _loadAnalysisData() async {
    try {
      print('분석 결과 화면 초기화');
      
      // 이미 분석 데이터가 전달된 경우
      if (widget.analysisData != null) {
        print('전달받은 분석 데이터 사용');
        setState(() {
          _analysisData = widget.analysisData;
          _imageUrl = widget.imageUrl; // 네트워크 이미지 URL
          _isLoading = false;
        });
        return;
      }
      
      // drawingId로 DB에서 조회
      if (widget.drawingId != null) {
        print('DB에서 분석 데이터 조회: ${widget.drawingId}');
        final drawing = await _drawingsService.getDrawing(widget.drawingId!);
        
        if (drawing != null) {
          print('DB 조회 성공');
          setState(() {
            _analysisData = drawing.analysisResult;
            _imageUrl = drawing.imageUrl;
            _isLoading = false;
          });
          return;
        }
      }
      
      // 데이터가 없으면 기본 데이터 사용
      print('기본 분석 데이터 사용');
      setState(() {
        _analysisData = _defaultAnalysisData;
        _isLoading = false;
      });
      
    } catch (e) {
      print('분석 결과 로드 에러: $e');
      setState(() {
        _errorMessage = '분석 결과를 불러오는 중 오류가 발생했습니다.';
        _analysisData = _defaultAnalysisData;
        _isLoading = false;
      });
    }
  }

  // 테스트용 기본 분석 데이터
  static final Map<String, dynamic> _defaultAnalysisData = {
    'emotion': '신나는',
    'emotionEmoji': '😄',
    'emotionDescription': '밝고 활기찬 색채와 자유로운 선으로 표현된 그림입니다.',
    'summary': '아이가 현재 매우 긍정적이고 창의적인 상태에 있습니다.',
    'interpretation': '이 그림에서 보이는 밝은 색상과 자유로운 선은 아이의 내적 자유로움과 긍정적인 정서 상태를 나타냅니다. 특히 노란색과 파란색의 조화는 창의력과 평온함을 동시에 보여줍니다.',
    'parentGuide': [
      '오늘 아이에게 "정말 멋진 그림이네요! 어떤 이야기가 담겨있나요?"라고 물어보세요.',
      '아이의 그림에 대해 구체적으로 칭찬해주세요. "이 색깔이 정말 예쁘다"처럼요.',
      '아이와 함께 그림에 대해 이야기하는 시간을 가져보세요.',
    ],
    'tags': ['행복함', '창의적', '활발함'],
    'positivityScore': 85,
    'creativityScore': 90,
    'colorAnalysis': '밝은 색상 위주 (노란색, 파란색, 빨간색)',
    'lineAnalysis': '자유롭고 유연한 선',
    'compositionAnalysis': '중앙 집중형 구성으로 안정감 있음',
  };

  @override
  Widget build(BuildContext context) {
    final childName = widget.selectedChild?.name ?? '아이';
    
    // 로딩 중
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            '분석 결과',
            style: TextStyle(
              color: AppTheme.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // 에러 메시지 표시
    if (_errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() {
          _errorMessage = null;
        });
      });
    }
    
    final analysisData = _analysisData ?? _defaultAnalysisData;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '분석 결과',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 그림 이미지
            Container(
              width: double.infinity,
              height: 300,
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: _buildImage(),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 감정 분석 카드
                  _buildEmotionCard(childName, analysisData),
                  const SizedBox(height: 24),
                  
                  // 요약 카드
                  _buildSummaryCard(analysisData),
                  const SizedBox(height: 24),
                  
                  // 해석 카드
                  _buildInterpretationCard(analysisData),
                  const SizedBox(height: 24),
                  
                  // 분석 상세 정보
                  _buildAnalysisDetails(analysisData),
                  const SizedBox(height: 24),
                  
                  // 부모 가이드 카드
                  _buildParentGuideCard(analysisData),
                  const SizedBox(height: 32),
                  
                  // 목록으로 돌아가기 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryHover,
                        foregroundColor: AppTheme.textDark,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '목록으로 돌아가기',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionCard(String childName, Map<String, dynamic> analysisData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary,
            AppTheme.primaryHover,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '지금 $childName는',
            style: const TextStyle(
              fontSize: 18,
              color: AppTheme.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "'${analysisData['emotion']}'",
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                analysisData['emotionEmoji'] ?? '😊',
                style: const TextStyle(fontSize: 32),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '상태예요!',
            style: const TextStyle(
              fontSize: 18,
              color: AppTheme.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> analysisData) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppTheme.primaryHover,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'AI 분석 요약',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            analysisData['summary'] ?? '',
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textDark,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          // 태그들
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (analysisData['tags'] as List<dynamic>? ?? []).map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '#$tag',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.primaryHover,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInterpretationCard(Map<String, dynamic> analysisData) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: Colors.purple[400],
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                '심리 해석',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            analysisData['interpretation'] ?? '',
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textDark,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisDetails(Map<String, dynamic> analysisData) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: Colors.blue[400],
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                '상세 분석',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 점수 표시
          Row(
            children: [
              Expanded(
                child: _buildScoreItem(
                  '긍정 지수',
                  analysisData['positivityScore'] ?? 0,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildScoreItem(
                  '창의성',
                  analysisData['creativityScore'] ?? 0,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          // 색상 분석
          _buildDetailItem(
            Icons.palette,
            '색상 분석',
            analysisData['colorAnalysis'] ?? '',
          ),
          const SizedBox(height: 12),
          // 선 분석
          _buildDetailItem(
            Icons.brush,
            '선의 특징',
            analysisData['lineAnalysis'] ?? '',
          ),
          const SizedBox(height: 12),
          // 구도 분석
          _buildDetailItem(
            Icons.grid_view,
            '구도 분석',
            analysisData['compositionAnalysis'] ?? '',
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, int score, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          // 진행 바
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: score / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 이미지 표시 (로컬 파일 또는 네트워크 이미지)
  Widget _buildImage() {
    // 로컬 파일이 있으면 우선 사용
    if (widget.imageFile != null && widget.imageFile!.existsSync()) {
      return Image.file(
        widget.imageFile!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('이미지 로드 에러: $error');
          return _buildImagePlaceholder();
        },
      );
    }
    
    // 네트워크 이미지 URL이 있으면 사용
    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      return Image.network(
        _imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('네트워크 이미지 로드 에러: $error');
          return _buildImagePlaceholder();
        },
      );
    }
    
    // 이미지가 없으면 플레이스홀더
    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppTheme.primary.withOpacity(0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image,
            size: 80,
            color: AppTheme.primaryHover,
          ),
          const SizedBox(height: 8),
          Text(
            '그림 이미지',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParentGuideCard(Map<String, dynamic> analysisData) {
    final guides = analysisData['parentGuide'] as List<dynamic>? ?? [];
    
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: Colors.amber[700],
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                '부모 가이드',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '이렇게 대화해 보세요',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ...guides.asMap().entries.map((entry) {
            final index = entry.key;
            final guide = entry.value.toString();
            return Padding(
              padding: EdgeInsets.only(bottom: index < guides.length - 1 ? 12 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryHover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      guide,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppTheme.textDark,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

