import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/children_service.dart';
import '../capture/capture_screen.dart';
import '../profile/profile_screen.dart';
import '../children/child_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();
  final ChildrenService _childrenService = ChildrenService();
  List<Child> _children = [];
  bool _isLoadingChildren = true;
  Child? _selectedChild; // 선택된 아이

  String _getUserName() {
    final user = _authService.currentUser;
    if (user != null) {
      // user_metadata에서 이름 가져오기
      final name = user.userMetadata?['name'] as String?;
      if (name != null && name.isNotEmpty) {
        return '$name님';
      }
      // 이메일에서 이름 추출
      final email = user.email ?? '';
      if (email.isNotEmpty) {
        final emailName = email.split('@')[0];
        return '$emailName님';
      }
    }
    return '사용자님';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '좋은 아침이에요,';
    } else if (hour < 18) {
      return '안녕하세요,';
    } else {
      return '좋은 저녁이에요,';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingChildren = true;
    });
    try {
      print('홈 화면: 아이 목록 로드 시작');
      
      // 먼저 연결 테스트
      final connectionTest = await _childrenService.testConnection();
      print('연결 테스트 결과: $connectionTest');
      
      if (connectionTest['error'] != null) {
        print('연결 테스트 실패: ${connectionTest['error']}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Supabase 연결 오류:\n${connectionTest['error']}\n\n'
                'Supabase 대시보드에서 테이블을 확인해주세요.',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
      
      final children = await _childrenService.getChildren();
      print('홈 화면: 아이 목록 로드 완료 - ${children.length}개');
      
      if (!mounted) return;
      setState(() {
        _children = children;
        _isLoadingChildren = false;
        // 아이 목록이 있고 선택된 아이가 없으면 첫 번째 아이를 기본 선택
        if (_selectedChild == null && children.isNotEmpty) {
          _selectedChild = children.first;
        } else if (_selectedChild != null && children.isNotEmpty) {
          // 기존 선택된 아이가 있으면 업데이트된 리스트에서 찾아서 업데이트
          final updatedChild = children.firstWhere(
            (child) => child.childId == _selectedChild!.childId,
            orElse: () => children.first,
          );
          _selectedChild = updatedChild;
        }
      });
    } catch (e) {
      print('홈 화면: 아이 목록 로드 에러: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '아이 목록을 불러오는 중 오류가 발생했습니다:\n$e',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      if (mounted) {
        setState(() {
          _isLoadingChildren = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String dateString;
    try {
      final dateFormat = DateFormat('M월 d일, EEEE', 'ko_KR');
      dateString = dateFormat.format(now);
    } catch (e) {
      // 로케일 초기화가 안 된 경우 기본 형식 사용
      print('날짜 포맷 에러: $e');
      dateString = DateFormat('M월 d일', 'ko_KR').format(now);
    }
    
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // 날짜
                    Text(
                      dateString,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 인사말
                    Row(
                      children: [
                        Text(
                          _getGreeting(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getUserName(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryHover,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '👋',
                          style: TextStyle(fontSize: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 프로필 카드
                    _buildProfileCard(),
                    const SizedBox(height: 24),
                    // 그림 분석하기 메인 블록
                    _buildAnalyzeBlock(),
                    const SizedBox(height: 32),
                    // 최근 분석 기록
                    _buildRecentRecords(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 앱 이름
          const Text(
            'Shining Moments',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          // 아이콘들
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                color: AppTheme.textDark,
                onPressed: () {
                  print('알림 클릭');
                },
              ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                color: AppTheme.textDark,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showChildDropdown() {
    if (_children.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '아이 선택',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
            // 아이 목록
            ..._children.map((child) {
              final isSelected = _selectedChild?.childId == child.childId;
              final ageText = child.age != null ? '만 ${child.age}세' : '';
              final genderText = child.gender == 'M' ? '남자' : child.gender == 'F' ? '여자' : '';
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary.withOpacity(0.1) : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[100]!, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    // 프로필 아이콘 (클릭 시 선택)
                    InkWell(
                      onTap: () {
                        setState(() {
                          _selectedChild = child;
                        });
                        Navigator.of(context).pop();
                        print('아이 선택: ${child.name}');
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.child_care,
                          color: AppTheme.textDark,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 아이 정보 (클릭 시 선택)
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedChild = child;
                          });
                          Navigator.of(context).pop();
                          print('아이 선택: ${child.name}');
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              child.name ?? '이름 없음',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: AppTheme.textDark,
                              ),
                            ),
                            if (ageText.isNotEmpty || genderText.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                [ageText, genderText].where((e) => e.isNotEmpty).join(' • '),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    // 선택 표시
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.primaryHover,
                        size: 24,
                      ),
                    const SizedBox(width: 8),
                    // 편집 버튼 (프로필 페이지로 이동)
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop(); // 드롭다운 닫기
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChildProfileScreen(child: child),
                          ),
                        );
                        if (result == true) {
                          _loadChildren();
                        }
                      },
                      tooltip: '프로필 수정',
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 8),
            // 새 아이 추가 버튼
            Padding(
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: () async {
                  Navigator.of(context).pop();
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ChildProfileScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadChildren();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primary,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: AppTheme.primaryHover,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
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
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    // 아이가 없으면 추가 카드 표시
    if (_isLoadingChildren) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_children.isEmpty) {
      return InkWell(
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
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primary,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: AppTheme.primaryHover,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '아이 정보 추가하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryHover,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '첫 번째 아이를 등록해주세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 선택된 아이 정보 표시 (드롭다운 메뉴)
    final selectedChild = _selectedChild ?? _children.first;
    final ageText = selectedChild.age != null ? '만 ${selectedChild.age}세' : '';
    final genderText = selectedChild.gender == 'M' ? '남자' : selectedChild.gender == 'F' ? '여자' : '';

    return Container(
      padding: const EdgeInsets.all(16),
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
          // 아이 정보 표시 영역 (클릭 시 드롭다운)
          InkWell(
            onTap: () {
              _showChildDropdown();
            },
            child: Row(
              children: [
                // 프로필 사진
                Stack(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.child_care,
                        color: AppTheme.textDark,
                        size: 32,
                      ),
                    ),
                    // 온라인 상태 표시
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // 아이 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedChild.name ?? '이름 없음',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (ageText.isNotEmpty) ...[
                            Text(
                              ageText,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            if (genderText.isNotEmpty) ...[
                              Text(
                                ' • $genderText',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ] else if (genderText.isNotEmpty) ...[
                            Text(
                              genderText,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                          if (ageText.isEmpty && genderText.isEmpty) ...[
                            Text(
                              '오늘도 그림으로 대화해요',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text('🎨'),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // 드롭다운 아이콘
                Icon(
                  Icons.keyboard_arrow_down,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
          ),
          // 편집 버튼
          if (_children.length > 1) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChildProfileScreen(child: selectedChild),
                  ),
                );
                if (result == true) {
                  _loadChildren();
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.edit,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '프로필 수정',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalyzeBlock() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primary,
            AppTheme.primaryHover,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
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
          // 카메라 아이콘
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt,
              size: 40,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          // 타이틀
          const Text(
            '그림 분석하기',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          // 설명
          Text(
            '아이의 그림을 찍어서 숨겨진 마음을 알아보세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textDark.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          // 시작하기 버튼
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CaptureScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.textDark,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                '시작하기',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRecords() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '최근 분석 기록',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            TextButton(
              onPressed: () {
                print('전체보기 클릭');
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '전체보기',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 분석 기록 카드들
        _buildRecordCard(
          date: '2023.10.24',
          title: '우리 가족 소풍',
          tags: ['#맹독함', '#창의적'],
          emoji: '😊',
        ),
        const SizedBox(height: 12),
        _buildRecordCard(
          date: '2023.10.20',
          title: '놀이터 친구들',
          tags: ['#상상력'],
          emoji: '😐',
        ),
        const SizedBox(height: 12),
        _buildRecordCard(
          date: '2023.10.15',
          title: '사과나무',
          tags: ['#안정감'],
          emoji: '😊',
        ),
      ],
    );
  }

  Widget _buildRecordCard({
    required String date,
    required String title,
    required List<String> tags,
    required String emoji,
  }) {
    return Container(
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
          // 이미지 플레이스홀더
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.image_outlined,
              color: Colors.grey[400],
              size: 32,
            ),
          ),
          const SizedBox(width: 12),
          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                // 태그들
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: tags.map((tag) {
                    Color tagColor;
                    if (tag.contains('맹독함') || tag.contains('창의적')) {
                      tagColor = Colors.cyan;
                    } else if (tag.contains('상상력')) {
                      tagColor = Colors.purple;
                    } else {
                      tagColor = Colors.orange;
                    }
                    
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: tagColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 12,
                          color: tagColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          // 이모지와 화살표
          Column(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 8),
              Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
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
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, '홈', 0),
              _buildNavItem(Icons.history, '히스토리', 1),
              _buildNavItem(Icons.psychology, '코칭', 2),
              _buildNavItem(Icons.settings, '설정', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 3) {
          // 설정 탭 클릭 시 프로필 화면으로 이동
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ProfileScreen(),
            ),
          );
        } else {
          setState(() {
            _currentIndex = index;
          });
          print('$label 탭 클릭');
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppTheme.primaryHover : AppTheme.textSecondary,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? AppTheme.primaryHover : AppTheme.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

