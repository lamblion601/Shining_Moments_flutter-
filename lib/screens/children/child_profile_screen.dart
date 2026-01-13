import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../services/children_service.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';

/// 아이 프로필 화면 (추가/수정)
class ChildProfileScreen extends StatefulWidget {
  final Child? child; // null이면 추가, 있으면 수정

  const ChildProfileScreen({
    super.key,
    this.child,
  });

  @override
  State<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends State<ChildProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final ChildrenService _childrenService = ChildrenService();
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();

  DateTime? _selectedBirthDate;
  String? _selectedGender;
  bool _isLoading = false;
  
  // 프로필 이미지
  File? _selectedImageFile;
  String? _currentImageUrl;
  
  // 성향 목록 (traits 테이블에서 가져옴)
  List<String> _availablePersonalities = [];
  bool _isLoadingTraits = false;
  
  // 선택된 성향들
  final Set<String> _selectedPersonalities = {};

  @override
  void initState() {
    super.initState();
    _loadTraits();
    
    // 수정 모드인 경우 기존 데이터로 초기화
    if (widget.child != null) {
      _nameController.text = widget.child!.name ?? '';
      _selectedBirthDate = widget.child!.birthDate;
      _selectedGender = widget.child!.gender;
      _currentImageUrl = widget.child!.profileImageUrl;
      
      // 기존 성향 데이터 로드 (List<String>에서 가져옴)
      if (widget.child!.personality.isNotEmpty) {
        _selectedPersonalities.addAll(widget.child!.personality);
      }
    }
  }

  /// traits 테이블에서 성향 목록 로드
  Future<void> _loadTraits() async {
    setState(() {
      _isLoadingTraits = true;
    });
    
    try {
      print('성향 목록 로드 시작');
      final traits = await _childrenService.getTraits();
      print('성향 목록 로드 성공: ${traits.length}개');
      
      if (mounted) {
        setState(() {
          _availablePersonalities = traits
              .map((trait) => trait['name']?.toString() ?? '')
              .where((name) => name.isNotEmpty)
              .toList();
          _isLoadingTraits = false;
        });
        print('사용 가능한 성향 목록: $_availablePersonalities');
      }
    } catch (e) {
      print('성향 목록 로드 에러: $e');
      if (mounted) {
        setState(() {
          _isLoadingTraits = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('성향 목록을 불러오는 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
        print('프로필 이미지 선택: ${pickedFile.path}');
      }
    } catch (e) {
      print('이미지 선택 에러: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 선택 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
        print('프로필 사진 촬영: ${pickedFile.path}');
      }
    } catch (e) {
      print('사진 촬영 에러: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('사진 촬영 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리에서 선택'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('사진 촬영'),
              onTap: () {
                Navigator.of(context).pop();
                _takePhoto();
              },
            ),
            if (_selectedImageFile != null || _currentImageUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('프로필 이미지 제거', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _selectedImageFile = null;
                    _currentImageUrl = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectBirthDate() async {
    try {
      // MaterialApp의 context를 가져오기 위해 Navigator를 통해 접근
      final navigatorContext = Navigator.of(context, rootNavigator: true).context;
      
      final DateTime? picked = await showDatePicker(
        context: navigatorContext,
        initialDate: _selectedBirthDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
        locale: const Locale('ko', 'KR'),
        builder: (BuildContext dialogContext, Widget? child) {
          return Theme(
            data: Theme.of(dialogContext).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppTheme.primaryHover,
                onPrimary: AppTheme.textDark,
                surface: Colors.white,
                onSurface: AppTheme.textDark,
              ),
            ),
            child: child!,
          );
        },
      );
      if (picked != null && picked != _selectedBirthDate) {
        if (mounted) {
          setState(() {
            _selectedBirthDate = picked;
          });
        }
      }
    } catch (e) {
      print('날짜 선택 에러: $e');
      // 에러 발생 시 기본 다이얼로그 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('날짜 선택 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveChild() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('생년월일을 선택해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('성별을 선택해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 선택된 성향을 List<String>으로 변환
      final personalityList = _selectedPersonalities.toList();
      
      // 프로필 이미지 업로드 (새로 선택한 이미지가 있는 경우)
      String? profileImageUrl = _currentImageUrl;
      if (_selectedImageFile != null) {
        final user = _authService.currentUser;
        if (user != null) {
          print('프로필 이미지 업로드 시작...');
          profileImageUrl = await _storageService.uploadProfileImage(
            imageFile: _selectedImageFile!,
            userId: user.id,
            childId: widget.child?.childId,
          );
          print('프로필 이미지 업로드 완료: $profileImageUrl');
        }
      }
      
      if (widget.child == null) {
        // 추가 모드
        print('아이 추가 시작: ${_nameController.text}, 성향: $personalityList');
        await _childrenService.addChild(
          name: _nameController.text.trim(),
          birthDate: _selectedBirthDate!,
          gender: _selectedGender!,
          personality: personalityList.isEmpty ? null : personalityList,
          profileImageUrl: profileImageUrl,
        );
        print('아이 추가 완료');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('아이 정보가 추가되었습니다.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // true를 반환하여 목록 새로고침 신호
        }
      } else {
        // 수정 모드
        print('아이 정보 수정 시작: ${widget.child!.childId}, 성향: $personalityList');
        await _childrenService.updateChild(
          childId: widget.child!.childId!,
          name: _nameController.text.trim(),
          birthDate: _selectedBirthDate,
          gender: _selectedGender,
          personality: personalityList.isEmpty ? null : personalityList,
          profileImageUrl: profileImageUrl,
        );
        print('아이 정보 수정 완료');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('아이 정보가 수정되었습니다.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // true를 반환하여 목록 새로고침 신호
        }
      }
    } catch (e) {
      print('아이 정보 저장 에러: $e');
      print('에러 타입: ${e.runtimeType}');
      if (mounted) {
        String errorMessage = '오류가 발생했습니다.';
        
        if (e.toString().contains('relation') && e.toString().contains('does not exist')) {
          errorMessage = 'Supabase에 테이블이 없습니다.\n'
              'Supabase 대시보드에서 tb_children 또는 children 테이블을 생성해주세요.';
        } else if (e.toString().contains('permission denied') || 
                   e.toString().contains('RLS')) {
          errorMessage = '권한이 없습니다.\n'
              'Supabase 대시보드에서 RLS 정책을 확인해주세요.';
        } else {
          errorMessage = '오류: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteChild() async {
    if (widget.child == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('아이 정보 삭제'),
        content: Text('${widget.child!.name}님의 정보를 정말 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              '삭제',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      print('아이 삭제 시작: ${widget.child!.childId}');
      await _childrenService.deleteChild(widget.child!.childId!);
      print('아이 삭제 완료');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('아이 정보가 삭제되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // true를 반환하여 목록 새로고침 신호
      }
    } catch (e) {
      print('아이 삭제 에러: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('삭제 중 오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.child != null;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(isEditMode ? '아이 정보 수정' : '아이 정보 추가'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: isEditMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _isLoading ? null : _deleteChild,
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 프로필 이미지
                    Center(
                      child: GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[200],
                            border: Border.all(
                              color: AppTheme.primaryHover,
                              width: 3,
                            ),
                          ),
                          child: _selectedImageFile != null
                              ? ClipOval(
                                  child: Image.file(
                                    _selectedImageFile!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : _currentImageUrl != null && _currentImageUrl!.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        _currentImageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          // 네트워크 이미지 로드 실패 시 기본 이미지 표시
                                          return ClipOval(
                                            child: Image.asset(
                                              'assets/images/default_profile.png',
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error2, stackTrace2) {
                                                return const Icon(
                                                  Icons.child_care,
                                                  size: 50,
                                                  color: AppTheme.textSecondary,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : ClipOval(
                                      child: Image.asset(
                                        'assets/images/default_profile.png',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          // 기본 이미지도 없을 경우 아이콘 표시
                                          return const Icon(
                                            Icons.child_care,
                                            size: 50,
                                            color: AppTheme.textSecondary,
                                          );
                                        },
                                      ),
                                    ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: _showImageSourceDialog,
                        icon: const Icon(Icons.camera_alt, size: 18),
                        label: Text(
                          (_selectedImageFile != null || _currentImageUrl != null)
                              ? '프로필 이미지 변경'
                              : '프로필 이미지 추가',
                          style: TextStyle(
                            color: AppTheme.primaryHover,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 이름 입력
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: '이름',
                        hintText: '아이의 이름을 입력하세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '이름을 입력해주세요.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    // 생년월일 선택
                    InkWell(
                      onTap: _selectBirthDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '생년월일',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedBirthDate != null
                                      ? DateFormat('yyyy년 M월 d일', 'ko_KR')
                                          .format(_selectedBirthDate!)
                                      : '생년월일을 선택하세요',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _selectedBirthDate != null
                                        ? AppTheme.textDark
                                        : AppTheme.textSecondary,
                                  ),
                                ),
                                if (_selectedBirthDate != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '만 ${_calculateAge(_selectedBirthDate!)}세',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.primaryHover,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: AppTheme.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 성별 선택
                    Text(
                      '성별',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildGenderOption('M', '남자'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGenderOption('F', '여자'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // 성향 선택
                    Text(
                      '성향',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '아이의 성향을 선택해주세요 (여러 개 선택 가능)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 성향 태그들
                    _isLoadingTraits
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _availablePersonalities.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '성향 목록을 불러올 수 없습니다.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _availablePersonalities.map((personality) {
                        final isSelected = _selectedPersonalities.contains(personality);
                        return FilterChip(
                          label: Text(personality),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedPersonalities.add(personality);
                              } else {
                                _selectedPersonalities.remove(personality);
                              }
                            });
                            print('성향 선택 변경: $personality -> $selected, 선택된 성향: $_selectedPersonalities');
                          },
                          selectedColor: AppTheme.primary.withOpacity(0.3),
                          checkmarkColor: AppTheme.primaryHover,
                          labelStyle: TextStyle(
                            color: isSelected ? AppTheme.primaryHover : AppTheme.textDark,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          side: BorderSide(
                            color: isSelected ? AppTheme.primaryHover : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                        );
                      }).toList(),
                            ),
                    if (_selectedPersonalities.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppTheme.primaryHover,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '선택된 성향: ${_selectedPersonalities.join(', ')}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textDark,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    // 저장 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveChild,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryHover,
                          foregroundColor: AppTheme.textDark,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          isEditMode ? '수정하기' : '추가하기',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildGenderOption(String gender, String label) {
    final isSelected = _selectedGender == gender;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withOpacity(0.3) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryHover : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppTheme.primaryHover : AppTheme.textDark,
            ),
          ),
        ),
      ),
    );
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}

