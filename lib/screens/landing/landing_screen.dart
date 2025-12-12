import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더: 로고 + 로그인 버튼
              _buildHeader(context),
              
              const SizedBox(height: 24),
              
              // 프로젝트 태그
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildProjectTag(),
              ),
              
              const SizedBox(height: 16),
              
              // 메인 타이틀
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildMainTitle(),
              ),
              
              const SizedBox(height: 12),
              
              // 서브타이틀
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildSubtitle(),
              ),
              
              const SizedBox(height: 24),
              
              // 일러스트레이션 영역
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildIllustrationSection(),
              ),
              
              const SizedBox(height: 48),
              
              // 3초 만에 시작하는 섹션
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildHowItWorksSection(),
              ),
              
              const SizedBox(height: 48),
              
              // AI 분석 리포트 예시
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildAnalysisReportSection(),
              ),
              
              const SizedBox(height: 48),
              
              // 사용자 후기
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildTestimonialsSection(),
              ),
              
              const SizedBox(height: 48),
              
              // 개인정보 보호 안내 + CTA 버튼
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildFooterSection(context),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 로고
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.lightYellow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.psychology,
                  color: AppTheme.textPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'ArtMind',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          // 로그인 버튼
          TextButton(
            onPressed: () {
              // 로그인 화면으로 이동
              print('로그인 버튼 클릭');
            },
            child: const Text(
              '로그인',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.lightYellow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_awesome,
            size: 16,
            color: AppTheme.textPrimary,
          ),
          const SizedBox(width: 4),
          const Text(
            '우리 아이 마음 읽기 프로젝트',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainTitle() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
          height: 1.3,
        ),
        children: [
          TextSpan(text: '아이가 그린 그림, '),
          TextSpan(
            text: '무엇을',
            style: TextStyle(
              decoration: TextDecoration.underline,
              decorationColor: AppTheme.lightYellow,
              decorationThickness: 3,
            ),
          ),
          TextSpan(text: ' 말할까요?'),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return const Text(
      '말로는 표현하지 못하는 아이의 속마음. AI 분석으로 이해하고 따뜻하게 안아주세요.',
      style: TextStyle(
        fontSize: 16,
        color: AppTheme.textPrimary,
        height: 1.5,
      ),
    );
  }

  Widget _buildIllustrationSection() {
    return Stack(
      children: [
        // 일러스트레이션 영역 (나중에 실제 이미지로 교체)
        Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Icon(
              Icons.child_care,
              size: 120,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        // 분석 완료 오버레이
        Positioned(
          bottom: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.lightGreen,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '분석 완료',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  '창의력 점수 상위 10%',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHowItWorksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '3초 만에 시작하는 우리아이 마음 케어',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
        _buildStepCard(
          stepNumber: 1,
          stepColor: AppTheme.lightBlue,
          title: '그림 촬영하기',
          description: '아이가 그린 그림을 스마트폰 카메라로 선명하게 찍어주세요.',
        ),
        const SizedBox(height: 16),
        _buildStepCard(
          stepNumber: 2,
          stepColor: AppTheme.lightOrange,
          title: 'AI 심리 분석',
          description: '색채, 구도, 필압 등을 AI가 3초 만에 정밀하게 분석합니다.',
        ),
        const SizedBox(height: 16),
        _buildStepCard(
          stepNumber: 3,
          stepColor: AppTheme.lightPurple,
          title: '맞춤 코칭 받기',
          description: '아이의 현재 심리 상태에 맞는 부모님 행동 가이드를 제공합니다.',
        ),
      ],
    );
  }

  Widget _buildStepCard({
    required int stepNumber,
    required Color stepColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: stepColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisReportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'AI INSIGHT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentYellow,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '분석 리포트 예시',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            // 사용자 수 아이콘
            Row(
              children: [
                _buildUserAvatar(),
                const SizedBox(width: -8),
                _buildUserAvatar(),
                const SizedBox(width: -8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      '+2k',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildReportCard(),
      ],
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.lightBlue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Icon(
        Icons.person,
        size: 18,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildReportCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단: 아이 정보 + 감정 태그
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.lightYellow,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.child_care,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '지우의 그림 (6세)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        '2023. 10. 24 분석완료',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.lightYellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '불안감 감지',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 아이 이미지 영역
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.image,
                size: 60,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 아이의 말
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '"엄마, 아빠가 싸우는 게 무서워요"',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // AI 분석
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: AppTheme.accentYellow,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI 심리 분석',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '검은색과 빨간색의 강한 대비는 현재 느끼는 갈등 상황에 대한 불안감을 나타냅니다. 선이 거칠고 끊겨있는 것은...',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 전체 리포트 보기 버튼
          TextButton(
            onPressed: () {
              print('전체 리포트 보기 클릭');
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '전체 리포트 보기',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.lightOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: AppTheme.lightOrange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '먼저 사용해본 부모님들의 이야기',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _buildTestimonialCard()),
            const SizedBox(width: 12),
            Expanded(child: _buildTestimonialCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildTestimonialCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 별점
          Row(
            children: List.generate(
              5,
              (index) => const Icon(
                Icons.star,
                color: AppTheme.accentYellow,
                size: 16,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 후기 텍스트
          const Text(
            '"아이 마음을 이해하게 되어서 정말 다행이에요. 대화 방법도 알려주셔서 감사합니다."',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // 작성자 정보
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 18,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '민준맘 (5세 남)',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSection(BuildContext context) {
    return Column(
      children: [
        // 개인정보 보호 안내
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 14,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: 4),
            const Text(
              '개인정보는 안전하게 암호화됩니다',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // CTA 버튼
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              print('3초 만에 시작하기 클릭');
              // 회원가입 또는 홈 화면으로 이동
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightYellow,
              foregroundColor: AppTheme.textPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.rocket_launch,
                  color: AppTheme.textPrimary,
                ),
                SizedBox(width: 8),
                Text(
                  '3초 만에 시작하기',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
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

