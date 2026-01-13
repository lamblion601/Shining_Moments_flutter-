import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/home/home_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/profile/profile_screen.dart';

/// MainLayout의 상태를 전역적으로 접근할 수 있게 하는 InheritedWidget
class MainLayoutProvider extends InheritedWidget {
  final MainLayoutController controller;

  const MainLayoutProvider({
    super.key,
    required this.controller,
    required super.child,
  });

  static MainLayoutController? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainLayoutProvider>()?.controller;
  }

  @override
  bool updateShouldNotify(MainLayoutProvider oldWidget) {
    return controller != oldWidget.controller;
  }
}

/// MainLayout의 탭 변경을 제어하는 컨트롤러
class MainLayoutController extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void changeTab(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
      print('탭 변경: $_currentIndex');
    }
  }
}

/// MainLayout의 탭을 변경하는 유틸리티 함수
/// 각 화면에서 사용할 수 있습니다
class MainLayoutHelper {
  /// 현재 화면에서 MainLayout의 탭을 변경합니다
  /// [context]: BuildContext
  /// [index]: 변경할 탭 인덱스 (0: 홈, 1: 히스토리, 2: 프로필)
  static void changeTab(BuildContext context, int index) {
    final controller = MainLayoutProvider.of(context);
    if (controller != null) {
      controller.changeTab(index);
    } else {
      print('MainLayoutProvider를 찾을 수 없습니다. MainLayout 안에서만 사용할 수 있습니다.');
    }
  }

  /// 홈 화면으로 이동
  static void goToHome(BuildContext context) {
    changeTab(context, 0);
  }

  /// 히스토리 화면으로 이동
  static void goToHistory(BuildContext context) {
    changeTab(context, 1);
  }

  /// 프로필 화면으로 이동
  static void goToProfile(BuildContext context) {
    changeTab(context, 2);
  }
}

/// 앱의 메인 레이아웃 (하단 네비게이션 바 포함)
/// 모든 주요 화면을 관리하는 메인 컨테이너
class MainLayout extends StatefulWidget {
  final int initialIndex;

  const MainLayout({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late MainLayoutController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = MainLayoutController();
    _controller._currentIndex = widget.initialIndex;
    _controller.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTabChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    setState(() {
      _currentIndex = _controller.currentIndex;
    });
  }

  // 각 탭에 해당하는 화면들
  final List<Widget> _screens = [
    const HomeScreenContent(), // 홈
    const HistoryScreenContent(), // 히스토리
    const ProfileScreen(), // 설정
  ];

  @override
  Widget build(BuildContext context) {
    return MainLayoutProvider(
      controller: _controller,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: _buildBottomNavBar(),
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
              _buildNavItem(Icons.settings, '설정', 2),
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
        _controller.changeTab(index);
        print('$label 탭 클릭 (index: $index)');
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


/// 홈 화면의 실제 콘텐츠 (네비게이션 바 제외)
class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    // 기존 HomeScreen에서 네비게이션 바를 제외한 부분만 사용
    return const HomeScreen();
  }
}

/// 히스토리 화면의 실제 콘텐츠 (네비게이션 바 제외)
class HistoryScreenContent extends StatelessWidget {
  const HistoryScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const HistoryScreen();
  }
}


