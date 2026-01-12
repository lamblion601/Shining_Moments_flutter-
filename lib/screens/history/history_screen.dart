import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/drawings_service.dart';
import '../../services/children_service.dart';
import '../analysis/analysis_result_screen.dart';
import 'dart:io';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DrawingsService _drawingsService = DrawingsService();
  final ChildrenService _childrenService = ChildrenService();
  
  List<Drawing> _allDrawings = [];
  List<Drawing> _filteredDrawings = [];
  List<Child> _children = [];
  bool _isLoading = true;
  
  String _selectedFilter = 'All';
  final List<String> _emotionFilters = ['All'];
  
  // 통계
  int _totalDrawings = 0;
  int _thisMonthDrawings = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('History: 데이터 로드 시작');
      
      // 아이 목록과 그림 목록 동시 로드
      final results = await Future.wait([
        _childrenService.getChildren(),
        _drawingsService.getDrawings(limit: 100),
      ]);

      final children = results[0] as List<Child>;
      final drawings = results[1] as List<Drawing>;

      print('History: 아이 ${children.length}명, 그림 ${drawings.length}개 로드 완료');

      // 감정 필터 추출
      final emotionSet = <String>{'All'};
      for (var drawing in drawings) {
        final emotion = drawing.analysisResult['emotion']?.toString();
        if (emotion != null && emotion.isNotEmpty) {
          emotionSet.add(emotion);
        }
      }

      // 이번 달 계산
      final now = DateTime.now();
      final thisMonthCount = drawings.where((d) {
        if (d.createdAt == null) return false;
        return d.createdAt!.year == now.year && 
               d.createdAt!.month == now.month;
      }).length;

      setState(() {
        _children = children;
        _allDrawings = drawings;
        _filteredDrawings = drawings;
        _emotionFilters.clear();
        _emotionFilters.addAll(emotionSet.toList()..sort());
        _totalDrawings = drawings.length;
        _thisMonthDrawings = thisMonthCount;
        _isLoading = false;
      });

      print('History: 데이터 로드 완료 - 총 $_totalDrawings개, 이번 달 $_thisMonthDrawings개');
    } catch (e) {
      print('History: 데이터 로드 에러: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'All') {
        _filteredDrawings = _allDrawings;
      } else {
        _filteredDrawings = _allDrawings.where((drawing) {
          final emotion = drawing.analysisResult['emotion']?.toString();
          return emotion == filter;
        }).toList();
      }
    });
    print('History: 필터 적용 - $filter (${_filteredDrawings.length}개)');
  }

  // 월별로 그룹화
  Map<String, List<Drawing>> _groupByMonth() {
    final grouped = <String, List<Drawing>>{};
    
    for (var drawing in _filteredDrawings) {
      if (drawing.createdAt == null) continue;
      
      final monthKey = DateFormat('yyyy-MM', 'ko_KR').format(drawing.createdAt!);
      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = [];
      }
      grouped[monthKey]!.add(drawing);
    }
    
    // 최신 월부터 정렬
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final sortedMap = <String, List<Drawing>>{};
    for (var key in sortedKeys) {
      sortedMap[key] = grouped[key]!;
    }
    
    return sortedMap;
  }

  String _formatMonthHeader(String monthKey) {
    try {
      final date = DateTime.parse('$monthKey-01');
      return DateFormat('MMMM yyyy', 'ko_KR').format(date);
    } catch (e) {
      return monthKey;
    }
  }

  Child? _findChild(String childId) {
    try {
      return _children.firstWhere((c) => c.childId == childId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_isLoading)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryHover,
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadData,
                  child: CustomScrollView(
                    slivers: [
                      // 통계 카드
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                          child: _buildStatsCards(),
                        ),
                      ),
                      // 필터
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildFilters(),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      // 월별 그림 목록
                      ..._buildMonthlyDrawings(),
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _children.isNotEmpty ? '${_children.first.name}\'s Gallery' : 'Gallery',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$_totalDrawings drawings analyzed',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search),
                color: AppTheme.textDark,
                onPressed: () {
                  // TODO: 검색 기능
                  print('검색 클릭');
                },
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                color: AppTheme.textDark,
                onPressed: () {
                  // TODO: 추가 필터
                  print('필터 클릭');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: Container(
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('🎨', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Total\nDrawings',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '$_totalDrawings',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('📅', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'This\nMonth',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '$_thisMonthDrawings',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _emotionFilters.length,
        itemBuilder: (context, index) {
          final filter = _emotionFilters[index];
          final isSelected = filter == _selectedFilter;
          
          // 이모지 매핑
          String emoji = '';
          if (filter == 'All') {
            emoji = '';
          } else if (filter.contains('행복') || filter.contains('신나')) {
            emoji = '😊';
          } else if (filter.contains('불안') || filter.contains('걱정')) {
            emoji = '😰';
          } else if (filter.contains('창의') || filter.contains('상상')) {
            emoji = '🎨';
          } else if (filter.contains('평온') || filter.contains('차분')) {
            emoji = '😌';
          } else if (filter.contains('호기심')) {
            emoji = '🤔';
          } else {
            emoji = '😊';
          }

          return Padding(
            padding: EdgeInsets.only(right: index < _emotionFilters.length - 1 ? 8 : 0),
            child: InkWell(
              onTap: () => _applyFilter(filter),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.textDark : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? AppTheme.textDark : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (emoji.isNotEmpty) ...[
                      Text(emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      filter,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildMonthlyDrawings() {
    final groupedDrawings = _groupByMonth();
    
    if (groupedDrawings.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '분석한 그림이 없습니다',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }

    final widgets = <Widget>[];
    
    groupedDrawings.forEach((monthKey, drawings) {
      // 월 헤더
      widgets.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatMonthHeader(monthKey),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
          ),
        ),
      );
      
      // 그림 그리드
      widgets.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildDrawingCard(drawings[index]);
              },
              childCount: drawings.length,
            ),
          ),
        ),
      );
    });
    
    return widgets;
  }

  Widget _buildDrawingCard(Drawing drawing) {
    final emotion = drawing.analysisResult['emotion']?.toString() ?? '';
    final emotionEmoji = drawing.analysisResult['emotionEmoji']?.toString() ?? '🎨';
    final tags = drawing.analysisResult['tags'] as List?;
    final firstTag = tags != null && tags.isNotEmpty ? tags[0].toString() : emotion;
    
    final dateText = drawing.createdAt != null
        ? DateFormat('MMM d, yyyy', 'ko_KR').format(drawing.createdAt!).toUpperCase()
        : 'Date unknown';
    
    final title = drawing.description?.isNotEmpty == true 
        ? drawing.description! 
        : firstTag.isNotEmpty ? firstTag : 'Drawing';

    // 태그에 따른 색상
    Color tagColor = Colors.orange;
    if (firstTag.contains('행복') || firstTag.contains('신나')) {
      tagColor = Colors.amber;
    } else if (firstTag.contains('창의') || firstTag.contains('상상')) {
      tagColor = Colors.purple;
    } else if (firstTag.contains('평온') || firstTag.contains('차분')) {
      tagColor = Colors.blue;
    } else if (firstTag.contains('사랑') || firstTag.contains('긍정')) {
      tagColor = Colors.pink;
    }

    return InkWell(
      onTap: () {
        print('Drawing 클릭: ${drawing.id}');
        final child = _findChild(drawing.childId);
        
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AnalysisResultScreen(
              imageFile: null,
              selectedChild: child,
              analysisData: drawing.analysisResult,
              imageUrl: drawing.imageUrl,
            ),
          ),
        );
      },
      child: Container(
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
            // 이미지
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Container(
                      width: double.infinity,
                      color: Colors.grey[100],
                      child: drawing.imageUrl.isNotEmpty
                          ? Image.network(
                              drawing.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                );
                              },
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
                            )
                          : Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                            ),
                    ),
                  ),
                  // 감정 태그 (오른쪽 상단)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            emotionEmoji,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            firstTag.length > 6 ? '${firstTag.substring(0, 6)}...' : firstTag,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: tagColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 정보
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateText,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

