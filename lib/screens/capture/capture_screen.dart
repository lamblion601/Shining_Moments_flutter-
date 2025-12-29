import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../services/children_service.dart';
import '../analysis/analysis_loading_screen.dart';
import '../analysis/analysis_result_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  bool _isLoading = false;
  final ChildrenService _childrenService = ChildrenService();
  Child? _selectedChild;

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _pickedImage = image;
          _isLoading = false;
        });
        
        // TODO: 이미지 분석 페이지로 이동
        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (context) => AnalysisScreen(image: image),
        //   ),
        // );
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지를 가져오는 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToAnalysisLoading() {
    print('그림 분석중 버튼 클릭 - 분석 로딩 페이지로 이동');
    
    // 이미지 파일이 있으면 사용하고, 없으면 null로 처리
    File? testImageFile;
    
    if (_pickedImage != null) {
      testImageFile = File(_pickedImage!.path);
    }
    
    // 분석 로딩 페이지로 이동
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AnalysisLoadingScreen(
          imageFile: testImageFile,
          selectedChild: _selectedChild,
        ),
      ),
    );
  }

  void _navigateToAnalysisResult() {
    print('그림 분석 결과 버튼 클릭 - 테스트 모드');
    
    // 테스트용: 이미지 파일이 있으면 사용하고, 없으면 null로 처리
    File? testImageFile;
    
    if (_pickedImage != null) {
      testImageFile = File(_pickedImage!.path);
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AnalysisResultScreen(
          imageFile: testImageFile,
          selectedChild: _selectedChild,
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 헤더
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '그림 가져오기',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // 카메라 옵션
              ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.blue,
                  ),
                ),
                title: const Text(
                  '카메라로 촬영',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                subtitle: const Text(
                  '새로운 그림을 촬영합니다',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              // 갤러리 옵션
              ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: Colors.amber,
                  ),
                ),
                title: const Text(
                  '갤러리에서 선택',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                subtitle: const Text(
                  '저장된 그림을 선택합니다',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '그림 촬영',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      '이미지를 불러오는 중...',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            : _pickedImage == null
                ? _buildEmptyState()
                : _buildImagePreview(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          // 아이콘
          Container(
            width: 120,
            height: 120,
            margin: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 60,
              color: AppTheme.primary,
            ),
          ),
          // 타이틀
          const Text(
            '아이가 그린 그림을\n촬영해주세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          // 설명
          Text(
            '카메라로 직접 촬영하거나\n갤러리에서 저장된 그림을 선택할 수 있습니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          // 촬영 버튼
          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _showImageSourceDialog,
              icon: const Icon(Icons.camera_alt, size: 24),
              label: const Text(
                '그림 촬영하기',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.textDark,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 갤러리 버튼
          SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library, size: 24),
              label: const Text(
                '갤러리에서 선택',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppTheme.primary,
                  width: 2,
                ),
                foregroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 그림 분석중 버튼 (테스트용)
          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                print('그림 분석중 버튼 클릭 - 테스트');
                // 테스트용 더미 이미지 파일 생성
                // 실제 파일이 없어도 테스트할 수 있도록 처리
                _navigateToAnalysisLoading();
              },
              icon: const Icon(Icons.auto_awesome, size: 24),
              label: const Text(
                '그림 분석중',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryHover,
                foregroundColor: AppTheme.textDark,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 그림 분석 결과 버튼 (테스트용)
          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                print('그림 분석 결과 버튼 클릭 - 테스트');
                _navigateToAnalysisResult();
              },
              icon: const Icon(Icons.assessment, size: 24),
              label: const Text(
                '그림 분석 결과',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // 안내 문구
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue[200]!,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[700],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '선명하게 촬영할수록\n더 정확한 분석이 가능합니다',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[900],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        Expanded(
          child: Container(
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
              child: Image.file(
                File(_pickedImage!.path),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        // 하단 버튼들
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 다시 촬영 버튼
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _pickedImage = null;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                      '다시 촬영',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppTheme.textSecondary.withOpacity(0.3),
                      ),
                      foregroundColor: AppTheme.textSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // 분석하기 버튼
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      print('AI 분석하기 버튼 클릭');
                      // 분석 로딩 페이지로 이동
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AnalysisLoadingScreen(
                            imageFile: File(_pickedImage!.path),
                            selectedChild: _selectedChild,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.auto_awesome, size: 24),
                    label: const Text(
                      'AI 분석하기',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: AppTheme.textDark,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}



