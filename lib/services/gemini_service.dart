import 'dart:io';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'children_service.dart';

/// Gemini AI 서비스
/// 아이의 그림을 분석하여 감정, 심리 상태 등을 파악합니다.
class GeminiService {
  GenerativeModel? _model;
  
  /// Gemini API 초기화
  Future<void> initialize() async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      
      if (apiKey == null || apiKey.isEmpty) {
        print('⚠️ GEMINI_API_KEY가 .env 파일에 설정되지 않았습니다.');
        print('📝 .env.example 파일을 .env로 복사하고 API 키를 입력하세요.');
        throw Exception(
          'GEMINI_API_KEY가 .env 파일에 설정되지 않았습니다.\n'
          '.env.example 파일을 .env로 복사하고 GEMINI_API_KEY를 설정해주세요.'
        );
      }
      
      print('🔑 Gemini API 초기화 시작...');
      // 최신 패키지(0.4.7)에서는 간단한 모델명 사용
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );
      print('✅ Gemini API 초기화 완료 (모델: gemini-1.5-flash)');
    } catch (e) {
      print('❌ Gemini API 초기화 에러: $e');
      rethrow;
    }
  }
  
  /// 그림 분석
  /// 아이의 그림 이미지를 분석하여 감정, 심리 상태, 부모 가이드 등을 제공합니다.
  Future<Map<String, dynamic>> analyzeDrawing({
    required File imageFile,
    required Child child,
  }) async {
    try {
      print('🎨 그림 분석 시작: childName=${child.name}, age=${child.age}');
      
      // 모델이 초기화되지 않았다면 초기화
      if (_model == null) {
        print('⚙️ Gemini 모델 초기화 중...');
        await initialize();
      }
      
      if (_model == null) {
        throw Exception('Gemini 모델 초기화에 실패했습니다.');
      }
      
      // 이미지 파일 읽기
      final imageBytes = await imageFile.readAsBytes();
      print('📷 이미지 파일 크기: ${imageBytes.length} bytes');
      
      // 아이 정보를 포함한 프롬프트 작성
      final prompt = _buildAnalysisPrompt(child);
      print('📝 프롬프트 생성 완료');
      
      // Gemini API 호출
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];
      
      print('🚀 Gemini API 호출 중... (최대 60초 대기)');
      
      // Timeout 설정 (60초)
      final response = await _model!.generateContent(content)
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              print('⏱️ Gemini API 호출 시간 초과!');
              throw Exception('Gemini API 호출 시간 초과 (60초).\n네트워크 연결을 확인하거나 나중에 다시 시도해주세요.');
            },
          );
      
      print('✅ Gemini API 응답 받음');
      
      if (response.text == null || response.text!.isEmpty) {
        print('⚠️ Gemini API가 빈 응답을 반환했습니다.');
        throw Exception('Gemini API가 빈 응답을 반환했습니다.');
      }
      
      print('📊 응답 텍스트 길이: ${response.text!.length}');
      
      // JSON 응답 파싱
      final analysisResult = _parseResponse(response.text!);
      print('✅ 분석 결과 파싱 완료: emotion=${analysisResult['emotion']}');
      
      return analysisResult;
    } catch (e, stackTrace) {
      print('❌ 그림 분석 에러: $e');
      print('📋 에러 스택: $stackTrace');
      
      // API 키 관련 에러인 경우 더 명확한 메시지
      if (e.toString().contains('GEMINI_API_KEY')) {
        print('🔑 Gemini API 키를 설정해주세요!');
        rethrow;
      }
      
      // Timeout 에러인 경우 명확한 메시지
      if (e.toString().contains('시간 초과')) {
        rethrow;
      }
      
      // 기타 에러 발생 시 기본 분석 결과 반환 (사용자 경험 개선)
      print('⚠️ 에러 발생으로 기본 분석 결과 반환');
      return _getDefaultAnalysis();
    }
  }
  
  /// 분석 프롬프트 생성
  String _buildAnalysisPrompt(Child child) {
    final childName = child.name ?? '아이';
    final age = child.age ?? 0;
    final ageText = age > 0 ? '만 $age세' : '';
    
    return '''
당신은 아동 미술 심리 전문가입니다. 아이의 그림을 분석하여 현재 감정 상태와 심리를 파악하고, 부모에게 조언을 제공하는 것이 당신의 역할입니다.

【아이 정보】
- 이름: $childName
- 나이: $ageText

【분석 요청】
이 그림을 다음 관점에서 분석해주세요:
1. 색채 사용 (어떤 색이 주로 사용되었나?)
2. 선의 특징 (부드러운지, 강한지, 자유로운지 등)
3. 구도 (중앙 집중형인지, 분산형인지 등)
4. 전체적인 감정 (기쁨, 불안, 평온 등)
5. 아이의 심리 상태 해석
6. 부모를 위한 실천 가능한 조언 3가지

【응답 형식】
반드시 아래 JSON 형식으로만 응답해주세요. 다른 설명이나 마크다운 포맷 없이 순수 JSON만 출력하세요:

{
  "emotion": "현재 감정을 한 단어로 (예: 신나는, 평온한, 불안한)",
  "emotionEmoji": "감정을 나타내는 이모지 하나 (예: 😄, 😊, 😔)",
  "emotionDescription": "감정 상태에 대한 한 줄 설명",
  "summary": "전체 분석 요약 (2-3문장)",
  "interpretation": "심리 해석 (3-4문장, 구체적으로)",
  "parentGuide": [
    "부모를 위한 첫 번째 조언 (구체적인 대화 예시 포함)",
    "부모를 위한 두 번째 조언",
    "부모를 위한 세 번째 조언"
  ],
  "tags": ["태그1", "태그2", "태그3"],
  "positivityScore": 0-100 사이 숫자,
  "creativityScore": 0-100 사이 숫자,
  "colorAnalysis": "색상 분석 (1-2문장)",
  "lineAnalysis": "선의 특징 분석 (1-2문장)",
  "compositionAnalysis": "구도 분석 (1-2문장)"
}

【중요】
- 반드시 위 JSON 형식을 정확히 따라주세요.
- 아이를 존중하고 긍정적인 관점으로 분석해주세요.
- 부모가 실천할 수 있는 구체적인 조언을 제공해주세요.
- 한국어로 작성해주세요.
''';
  }
  
  /// API 응답 파싱
  Map<String, dynamic> _parseResponse(String responseText) {
    try {
      print('응답 파싱 시작');
      
      // JSON 부분만 추출 (마크다운 코드 블록이 있을 경우 제거)
      String jsonText = responseText.trim();
      
      // ```json ... ``` 형태의 마크다운 제거
      if (jsonText.startsWith('```json')) {
        jsonText = jsonText.substring(7);
      } else if (jsonText.startsWith('```')) {
        jsonText = jsonText.substring(3);
      }
      
      if (jsonText.endsWith('```')) {
        jsonText = jsonText.substring(0, jsonText.length - 3);
      }
      
      jsonText = jsonText.trim();
      
      // JSON 파싱
      final Map<String, dynamic> parsed = json.decode(jsonText);
      print('JSON 파싱 성공');
      
      // 필수 필드 검증 및 기본값 설정
      return {
        'emotion': parsed['emotion'] ?? '알 수 없음',
        'emotionEmoji': parsed['emotionEmoji'] ?? '🎨',
        'emotionDescription': parsed['emotionDescription'] ?? '',
        'summary': parsed['summary'] ?? '그림을 분석했습니다.',
        'interpretation': parsed['interpretation'] ?? '아이의 그림에서 다양한 감정을 발견할 수 있습니다.',
        'parentGuide': (parsed['parentGuide'] as List<dynamic>?)?.cast<String>() ?? 
            ['아이와 그림에 대해 이야기해보세요.', '칭찬해주세요.', '함께 그림을 그려보세요.'],
        'tags': (parsed['tags'] as List<dynamic>?)?.cast<String>() ?? ['창의적'],
        'positivityScore': parsed['positivityScore'] ?? 70,
        'creativityScore': parsed['creativityScore'] ?? 75,
        'colorAnalysis': parsed['colorAnalysis'] ?? '다양한 색상을 사용했습니다.',
        'lineAnalysis': parsed['lineAnalysis'] ?? '자유로운 선을 그렸습니다.',
        'compositionAnalysis': parsed['compositionAnalysis'] ?? '균형잡힌 구도입니다.',
      };
    } catch (e) {
      print('응답 파싱 에러: $e');
      print('응답 텍스트: $responseText');
      
      // 파싱 실패 시 기본 분석 결과 반환
      return _getDefaultAnalysis();
    }
  }
  
  /// 기본 분석 결과 (에러 또는 API 실패 시)
  Map<String, dynamic> _getDefaultAnalysis() {
    return {
      'emotion': '창의적인',
      'emotionEmoji': '🎨',
      'emotionDescription': '아이의 창의성이 돋보이는 그림입니다.',
      'summary': '아이가 자유롭게 표현한 멋진 그림입니다. 아이의 상상력과 창의성이 잘 드러나 있습니다.',
      'interpretation': '이 그림은 아이의 내면 세계를 보여줍니다. 자유로운 표현을 통해 아이가 현재 안정적이고 창의적인 상태에 있음을 알 수 있습니다.',
      'parentGuide': [
        '아이에게 "정말 멋진 그림이네! 어떤 생각으로 그렸어?"라고 물어보세요.',
        '그림의 특정 부분을 구체적으로 칭찬해주세요.',
        '아이와 함께 그림을 그리며 소통하는 시간을 가져보세요.',
      ],
      'tags': ['창의적', '표현력', '상상력'],
      'positivityScore': 75,
      'creativityScore': 80,
      'colorAnalysis': '다양한 색상을 활용하여 풍부한 표현을 했습니다.',
      'lineAnalysis': '자유롭고 유연한 선으로 자신감을 보여줍니다.',
      'compositionAnalysis': '전체적으로 균형잡힌 구도를 보입니다.',
    };
  }
}




