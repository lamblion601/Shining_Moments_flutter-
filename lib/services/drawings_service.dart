import 'package:supabase_flutter/supabase_flutter.dart';

/// Drawing 정보 모델
class Drawing {
  final String? id;
  final String childId;
  final String userId;
  final String imageUrl;
  final String? description;
  final Map<String, dynamic> analysisResult;
  final DateTime? createdAt;
  
  Drawing({
    this.id,
    required this.childId,
    required this.userId,
    required this.imageUrl,
    this.description,
    required this.analysisResult,
    this.createdAt,
  });
  
  /// Supabase에서 받은 데이터로 Drawing 객체 생성
  factory Drawing.fromJson(Map<String, dynamic> json) {
    print('Drawing.fromJson 파싱 시작: $json');
    
    return Drawing(
      id: json['id']?.toString(),
      childId: json['child_id']?.toString() ?? json['children_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      description: json['description']?.toString(),
      analysisResult: json['analysis_result'] as Map<String, dynamic>? ?? {},
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
  
  /// Drawing 객체를 Supabase에 저장할 수 있는 형태로 변환
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'child_id': childId,
      'user_id': userId,
      'image_url': imageUrl,
      if (description != null) 'description': description,
      'analysis_result': analysisResult,
    };
  }
}

/// Drawings 관리 서비스
/// Supabase drawings 테이블과 상호작용합니다.
class DrawingsService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String tableName = 'drawings';
  
  /// 그림 저장
  /// 분석 결과와 함께 drawings 테이블에 저장합니다.
  Future<Drawing> saveDrawing({
    required String childId,
    required String imageUrl,
    String? description,
    required Map<String, dynamic> analysisResult,
  }) async {
    try {
      print('그림 저장 시작: childId=$childId');
      print('이미지 URL: $imageUrl');
      print('분석 결과 키: ${analysisResult.keys}');
      
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }
      
      print('현재 사용자 ID: ${user.id}');
      
      // 저장할 데이터 준비
      final drawingData = {
        'child_id': childId,
        'user_id': user.id,
        'image_url': imageUrl,
        if (description != null && description.isNotEmpty) 'description': description,
        'analysis_result': analysisResult,
      };
      
      print('저장할 데이터: ${drawingData.keys}');
      
      // drawings 테이블에 저장
      final response = await _supabase
          .from(tableName)
          .insert(drawingData)
          .select()
          .single();
      
      print('그림 저장 완료: id=${response['id']}');
      
      return Drawing.fromJson(response as Map<String, dynamic>);
    } catch (e, stackTrace) {
      print('그림 저장 에러: $e');
      print('에러 스택: $stackTrace');
      rethrow;
    }
  }
  
  /// 특정 그림 조회
  Future<Drawing?> getDrawing(String drawingId) async {
    try {
      print('그림 조회 시작: drawingId=$drawingId');
      
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }
      
      final response = await _supabase
          .from(tableName)
          .select()
          .eq('id', drawingId)
          .eq('user_id', user.id)
          .maybeSingle();
      
      if (response == null) {
        print('그림을 찾을 수 없습니다.');
        return null;
      }
      
      print('그림 조회 완료');
      return Drawing.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('그림 조회 에러: $e');
      if (e.toString().contains('PGRST116') || 
          e.toString().contains('No rows returned')) {
        return null;
      }
      rethrow;
    }
  }
  
  /// 사용자의 모든 그림 조회
  Future<List<Drawing>> getDrawings({
    String? childId,
    int limit = 10,
  }) async {
    try {
      print('그림 목록 조회 시작: childId=$childId, limit=$limit');
      
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }
      
      var query = _supabase
          .from(tableName)
          .select()
          .eq('user_id', user.id);
      
      // 특정 아이의 그림만 조회
      if (childId != null) {
        query = query.eq('child_id', childId);
      }
      
      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);
      
      print('그림 목록 조회 완료: ${response.length}개');
      
      final drawings = <Drawing>[];
      for (var json in response as List) {
        drawings.add(Drawing.fromJson(json as Map<String, dynamic>));
      }
      
      return drawings;
    } catch (e) {
      print('그림 목록 조회 에러: $e');
      return [];
    }
  }
  
  /// 아이 정보와 함께 그림 목록 조회
  Future<List<Map<String, dynamic>>> getDrawingsWithChild({
    String? childId,
    int limit = 10,
  }) async {
    try {
      print('그림 목록 조회 시작 (아이 정보 포함): childId=$childId, limit=$limit');
      
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }
      
      // children 테이블 이름 확인 (tb_children 또는 children)
      String childrenTable = 'children';
      try {
        await _supabase.from('tb_children').select().limit(0);
        childrenTable = 'tb_children';
      } catch (e) {
        // tb_children이 없으면 children 사용
      }
      
      var query = _supabase
          .from(tableName)
          .select('*, $childrenTable(name)')
          .eq('user_id', user.id);
      
      // 특정 아이의 그림만 조회
      if (childId != null) {
        query = query.eq('child_id', childId);
      }
      
      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);
      
      print('그림 목록 조회 완료 (아이 정보 포함): ${response.length}개');
      
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('그림 목록 조회 에러 (아이 정보 포함): $e');
      return [];
    }
  }
  
  /// 그림 설명 업데이트
  Future<void> updateDescription({
    required String drawingId,
    required String description,
  }) async {
    try {
      print('그림 설명 업데이트 시작: drawingId=$drawingId');
      
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }
      
      await _supabase
          .from(tableName)
          .update({'description': description})
          .eq('id', drawingId)
          .eq('user_id', user.id);
      
      print('그림 설명 업데이트 완료');
    } catch (e) {
      print('그림 설명 업데이트 에러: $e');
      rethrow;
    }
  }
  
  /// 그림 삭제
  Future<void> deleteDrawing(String drawingId) async {
    try {
      print('그림 삭제 시작: drawingId=$drawingId');
      
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }
      
      await _supabase
          .from(tableName)
          .delete()
          .eq('id', drawingId)
          .eq('user_id', user.id);
      
      print('그림 삭제 완료');
    } catch (e) {
      print('그림 삭제 에러: $e');
      rethrow;
    }
  }
  
  /// 특정 아이의 모든 그림 삭제
  Future<void> deleteChildDrawings(String childId) async {
    try {
      print('아이의 모든 그림 삭제 시작: childId=$childId');
      
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }
      
      await _supabase
          .from(tableName)
          .delete()
          .eq('child_id', childId)
          .eq('user_id', user.id);
      
      print('아이의 모든 그림 삭제 완료');
    } catch (e) {
      print('아이의 모든 그림 삭제 에러: $e');
      rethrow;
    }
  }
  
  /// 그림 개수 조회
  Future<int> getDrawingCount({String? childId}) async {
    try {
      print('그림 개수 조회 시작: childId=$childId');
      
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }
      
      var query = _supabase
          .from(tableName)
          .select('id')
          .eq('user_id', user.id);
      
      if (childId != null) {
        query = query.eq('child_id', childId);
      }
      
      final response = await query as List;
      final count = response.length;
      
      print('그림 개수: $count개');
      return count;
    } catch (e) {
      print('그림 개수 조회 에러: $e');
      return 0;
    }
  }
}

