import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/children_service.dart';
import '../../services/storage_service.dart';
import '../landing/landing_screen.dart';
import '../children/child_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ChildrenService _childrenService = ChildrenService();
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();
  List<Child> _children = [];
  bool _isLoadingChildren = true;
  String? _userProfileImageUrl;
  File? _selectedUserImage;

  String _getUserName() {
    final user = _authService.currentUser;
    if (user != null) {
      final name = user.userMetadata?['name'] as String?;
      if (name != null && name.isNotEmpty) {
        return name;
      }
      final email = user.email ?? '';
      if (email.isNotEmpty) {
        return email.split('@')[0];
      }
    }
    return '사용자';
  }

  String _getUserEmail() {
    final user = _authService.currentUser;
    return user?.email ?? 'user@example.com';
  }

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    setState(() {
      _isLoadingChildren = true;
    });
    try {
      print('프로필 화면: 아이 목록 로드 시작');
      final children = await _childrenService.getChildren();
      print('프로필 화면: 아이 목록 로드 완료 - ${children.length}개');
      setState(() {
        _children = children;
        _isLoadingChildren = false;
      });
    } catch (e) {
      print('프로필 화면: 아이 목록 로드 에러: $e');
      setState(() {
        _isLoadingChildren = false;
      });
    }
  }

  Future<void> _pickUserProfileImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리에서 선택'),
              onTap: () async {
                Navigator.of(context).pop();
                try {
                  final XFile? pickedFile = await _imagePicker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 800,
                    maxHeight: 800,
                    imageQuality: 85,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _selectedUserImage = File(pickedFile.path);
                    });
                    await _uploadUserProfileImage();
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
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('사진 촬영'),
              onTap: () async {
                Navigator.of(context).pop();
                try {
                  final XFile? pickedFile = await _imagePicker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 800,
                    maxHeight: 800,
                    imageQuality: 85,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _selectedUserImage = File(pickedFile.path);
                    });
                    await _uploadUserProfileImage();
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
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadUserProfileImage() async {
    if (_selectedUserImage == null) return;

    try {
      final user = _authService.currentUser;
      if (user == null) return;

      print('부모 프로필 이미지 업로드 시작...');
      final imageUrl = await _storageService.uploadProfileImage(
        imageFile: _selectedUserImage!,
        userId: user.id,
        childId: null, // 부모 프로필
      );
      
      setState(() {
        _userProfileImageUrl = imageUrl;
      });
      
      print('부모 프로필 이미지 업로드 완료: $imageUrl');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필 이미지가 변경되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('프로필 이미지 업로드 에러: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 업로드 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              '로그아웃',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _authService.signOut();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LandingScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('로그아웃 중 오류가 발생했습니다: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더
            _buildHeader(),
            // 메인 콘텐츠
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // 사용자 프로필 섹션
                    _buildUserProfile(),
                    const SizedBox(height: 32),
                    // 등록된 아이들 섹션
                    _buildChildrenSection(),
                    const SizedBox(height: 80), // 하단 네비게이션 바 공간
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'My Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          // 로그아웃 버튼
          TextButton.icon(
            onPressed: _handleLogout,
            icon: const Icon(
              Icons.arrow_forward,
              size: 16,
              color: AppTheme.primaryHover,
            ),
            label: const Text(
              'Log Out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryHover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    return Column(
      children: [
        // 프로필 사진
        GestureDetector(
          onTap: _pickUserProfileImage,
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                ),
                child: _selectedUserImage != null
                    ? ClipOval(
                        child: Image.file(
                          _selectedUserImage!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      )
                    : _userProfileImageUrl != null && _userProfileImageUrl!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              _userProfileImageUrl!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: AppTheme.textDark,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 60,
                            color: AppTheme.textDark,
                          ),
              ),
              // 편집 아이콘
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 18,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 사용자 이름
        Text(
          _getUserName(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        // 이메일
        Text(
          _getUserEmail(),
          style: const TextStyle(
            fontSize: 16,
            color: AppTheme.primaryHover,
          ),
        ),
        const SizedBox(height: 16),
        // Premium Member 배지
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryHover,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'Premium Member',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // 계정 관리 링크
        TextButton(
          onPressed: () {
            print('계정 관리 클릭');
          },
          child: const Text(
            'Manage Account via Clerk',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.primaryHover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChildrenSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '등록된 아이 (${_children.length})',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 16),
        if (_isLoadingChildren)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          )
        else ...[
          // 아이 카드들
          ..._children.asMap().entries.map((entry) {
            final index = entry.key;
            final child = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: index < _children.length - 1 ? 12 : 12),
              child: _buildChildCard(child: child),
            );
          }),
          // Add New Child 카드
          _buildAddChildCard(),
        ],
      ],
    );
  }

  Widget _buildChildCard({required Child child}) {
    final ageText = child.age != null ? '만 ${child.age}세' : '';
    final birthDateText = child.birthDate != null
        ? DateFormat('yyyy년 M월 d일', 'ko_KR').format(child.birthDate!)
        : '';
    final genderText = child.gender == 'M'
        ? '남자'
        : child.gender == 'F'
            ? '여자'
            : '';
    
    // 아이별로 다른 색상 할당
    final colors = [
      Colors.teal,
      Colors.lightBlue,
      Colors.purple,
      Colors.orange,
      Colors.pink,
    ];
    final avatarColor = colors[child.childId != null 
        ? (child.childId!.hashCode.abs() % colors.length) 
        : 0];

    return InkWell(
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChildProfileScreen(child: child),
          ),
        );
        if (result == true) {
          _loadChildren();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 아이 아바타
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: avatarColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: child.profileImageUrl != null && child.profileImageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        child.profileImageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.child_care,
                            size: 50,
                            color: avatarColor,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.child_care,
                      size: 50,
                      color: avatarColor,
                    ),
            ),
            const SizedBox(width: 16),
            // 아이 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.name ?? '이름 없음',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (birthDateText.isNotEmpty || ageText.isNotEmpty || genderText.isNotEmpty)
                    Text(
                      [
                        if (birthDateText.isNotEmpty) birthDateText,
                        if (ageText.isNotEmpty) ageText,
                        if (genderText.isNotEmpty) genderText,
                      ].join(' • '),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            // 편집 아이콘
            IconButton(
              icon: Icon(
                Icons.edit,
                color: AppTheme.textSecondary,
              ),
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChildProfileScreen(child: child),
                  ),
                );
                if (result == true) {
                  _loadChildren();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddChildCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primary,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ChildProfileScreen(),
            ),
          );
          if (result == true) {
            _loadChildren();
          }
        },
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                size: 32,
                color: AppTheme.primaryHover,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '새 아이 추가',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryHover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

