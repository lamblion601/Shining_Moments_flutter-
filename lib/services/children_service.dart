import 'package:supabase_flutter/supabase_flutter.dart';

/// 아이 정보 모델
class Child {
  final int? childId;
  final String parentUserId;
  final String? name;
  final DateTime? birthDate;
  final String? gender; // 'M' 또는 'F'
  final String? profileImageUrl;
  final String? personality; // 성향 (쉼표로 구분된 문자열 또는 JSON)
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Child({
    this.childId,
    required this.parentUserId,
    this.name,
    this.birthDate,
    this.gender,
    this.profileImageUrl,
    this.personality,
    this.createdAt,
    this.updatedAt,
  });

  /// 연령 계산 (만 나이)
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  /// Supabase에서 받은 데이터로 Child 객체 생성
  factory Child.fromJson(Map<String, dynamic> json) {
    print('Child.fromJson 파싱 시작: $json');
    
    // child_id 또는 id 필드 처리
    int? childId;
    if (json.containsKey('child_id')) {
      childId = json['child_id'] is int 
          ? json['child_id'] as int
          : int.tryParse(json['child_id'].toString());
    } else if (json.containsKey('id')) {
      childId = json['id'] is int 
          ? json['id'] as int
          : int.tryParse(json['id'].toString());
    }

    // parent_user_id 또는 user_id 필드 처리
    String parentUserId = '';
    if (json.containsKey('parent_user_id')) {
      parentUserId = json['parent_user_id'].toString();
    } else if (json.containsKey('user_id')) {
      parentUserId = json['user_id'].toString();
    }

    // birth_date 파싱 (다양한 형식 지원)
    DateTime? birthDate;
    if (json['birth_date'] != null) {
      try {
        final dateStr = json['birth_date'].toString();
        birthDate = DateTime.parse(dateStr.split('T')[0]);
      } catch (e) {
        print('생년월일 파싱 에러: ${json['birth_date']}, $e');
      }
    }

    final child = Child(
      childId: childId,
      parentUserId: parentUserId,
      name: json['name']?.toString(),
      birthDate: birthDate,
      gender: json['gender']?.toString(),
      profileImageUrl: json['profile_image_url']?.toString(),
      personality: json['personality']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );

    print('Child 객체 생성 완료: childId=$childId, name=${child.name}');
    return child;
  }

  /// Child 객체를 Supabase에 저장할 수 있는 형태로 변환
  Map<String, dynamic> toJson() {
    return {
      if (childId != null) 'child_id': childId,
      'parent_user_id': parentUserId,
      if (name != null) 'name': name,
      if (birthDate != null) 'birth_date': birthDate!.toIso8601String().split('T')[0],
      if (gender != null) 'gender': gender,
      if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
      if (personality != null) 'personality': personality,
    };
  }

  /// 복사 생성자 (수정 시 사용)
  Child copyWith({
    int? childId,
    String? parentUserId,
    String? name,
    DateTime? birthDate,
    String? gender,
    String? profileImageUrl,
    String? personality,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Child(
      childId: childId ?? this.childId,
      parentUserId: parentUserId ?? this.parentUserId,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      personality: personality ?? this.personality,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 아이 정보 관리 서비스
class ChildrenService {
  final SupabaseClient _supabase = Supabase.instance.client;
  String? _tableName; // 캐시된 테이블 이름

  /// 테이블 이름 확인 및 캐싱
  Future<String> _getTableName() async {
    if (_tableName != null) {
      return _tableName!;
    }

    // 먼저 tb_children 테이블 확인
    try {
      await _supabase.from('tb_children').select().limit(0);
      _tableName = 'tb_children';
      print('테이블 이름 확인: tb_children');
      return _tableName!;
    } catch (e) {
      print('tb_children 테이블 없음: $e');
    }

    // children 테이블 확인
    try {
      await _supabase.from('children').select().limit(0);
      _tableName = 'children';
      print('테이블 이름 확인: children');
      return _tableName!;
    } catch (e) {
      print('children 테이블도 없음: $e');
      throw Exception(
        'Supabase에 children 테이블이 없습니다.\n'
        'Supabase 대시보드에서 테이블을 생성해주세요.\n'
        '에러: $e'
      );
    }
  }

  /// Supabase 연결 테스트
  Future<Map<String, dynamic>> testConnection() async {
    try {
      print('Supabase 연결 테스트 시작');
      final user = _supabase.auth.currentUser;
      
      final result = {
        'connected': true,
        'authenticated': user != null,
        'userId': user?.id,
        'userEmail': user?.email,
        'tableName': null as String?,
        'error': null as String?,
      };

      if (user == null) {
        result['error'] = '사용자가 로그인하지 않았습니다.';
        return result;
      }

      // 테이블 이름 확인
      try {
        final tableName = await _getTableName();
        result['tableName'] = tableName;
        print('연결 테스트 성공: 테이블=$tableName');
      } catch (e) {
        result['error'] = e.toString();
        print('연결 테스트 실패: $e');
      }

      return result;
    } catch (e) {
      print('연결 테스트 에러: $e');
      return {
        'connected': false,
        'authenticated': false,
        'userId': null,
        'userEmail': null,
        'tableName': null,
        'error': e.toString(),
      };
    }
  }

  /// 현재 로그인한 사용자의 아이들 조회
  Future<List<Child>> getChildren() async {
    try {
      print('아이 목록 조회 시작');
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('에러: 사용자가 로그인하지 않았습니다.');
        throw Exception('로그인이 필요합니다.');
      }

      print('현재 사용자 ID: ${user.id}');
      print('사용자 이메일: ${user.email}');

      final tableName = await _getTableName();
      final parentIdField = tableName == 'tb_children' ? 'parent_user_id' : 'user_id';

      final response = await _supabase
          .from(tableName)
          .select()
          .eq(parentIdField, user.id)
          .order('created_at', ascending: false);

      print('아이 목록 조회 성공: ${response.length}개');
      print('응답 데이터: $response');
      
      if (response.isEmpty) {
        print('아이 목록이 비어있습니다.');
        return [];
      }

      return (response as List)
          .map((json) {
            print('아이 데이터 파싱: $json');
            return Child.fromJson(json as Map<String, dynamic>);
          })
          .toList();
    } catch (e) {
      print('아이 목록 조회 에러 상세: $e');
      print('에러 타입: ${e.runtimeType}');
      // 빈 리스트 반환 (에러가 발생해도 앱이 크래시되지 않도록)
      return [];
    }
  }

  /// 특정 아이 정보 조회
  Future<Child?> getChild(int childId) async {
    try {
      print('아이 정보 조회 시작: childId=$childId');
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final tableName = await _getTableName();
      final idField = tableName == 'tb_children' ? 'child_id' : 'id';
      final parentIdField = tableName == 'tb_children' ? 'parent_user_id' : 'user_id';

      final response = await _supabase
          .from(tableName)
          .select()
          .eq(idField, childId)
          .eq(parentIdField, user.id)
          .single();

      print('아이 정보 조회 성공');
      return Child.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('아이 정보 조회 에러: $e');
      if (e.toString().contains('PGRST116') || 
          e.toString().contains('No rows returned')) {
        // 데이터가 없는 경우
        return null;
      }
      rethrow;
    }
  }

  /// 아이 정보 추가
  Future<Child> addChild({
    required String name,
    required DateTime birthDate,
    required String gender,
    String? profileImageUrl,
    String? personality,
  }) async {
    try {
      print('아이 추가 시작: name=$name, birthDate=$birthDate, gender=$gender, personality=$personality');
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('에러: 사용자가 로그인하지 않았습니다.');
        throw Exception('로그인이 필요합니다.');
      }

      print('현재 사용자 ID: ${user.id}');

      final tableName = await _getTableName();
      final parentIdField = tableName == 'tb_children' ? 'parent_user_id' : 'user_id';

      // 테이블 구조에 맞는 필드명 사용
      final childData = <String, dynamic>{
        parentIdField: user.id,
        'name': name,
        'birth_date': birthDate.toIso8601String().split('T')[0],
        'gender': gender,
        if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
        if (personality != null && personality.isNotEmpty) 'personality': personality,
      };

      print('추가할 데이터: $childData');
      print('사용할 테이블: $tableName, 부모 ID 필드: $parentIdField');

      final response = await _supabase
          .from(tableName)
          .insert(childData)
          .select()
          .single();

      print('아이 추가 성공: childId=${response['child_id'] ?? response['id']}');
      return Child.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('아이 추가 에러 상세: $e');
      print('에러 타입: ${e.runtimeType}');
      print('에러 스택: ${StackTrace.current}');
      rethrow;
    }
  }

  /// 아이 정보 수정
  Future<Child> updateChild({
    required int childId,
    String? name,
    DateTime? birthDate,
    String? gender,
    String? profileImageUrl,
    String? personality,
  }) async {
    try {
      print('아이 정보 수정 시작: childId=$childId');
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (birthDate != null) {
        updateData['birth_date'] = birthDate.toIso8601String().split('T')[0];
      }
      if (gender != null) updateData['gender'] = gender;
      if (profileImageUrl != null) updateData['profile_image_url'] = profileImageUrl;
      if (personality != null) updateData['personality'] = personality;

      print('수정할 데이터: $updateData');

      final tableName = await _getTableName();
      final idField = tableName == 'tb_children' ? 'child_id' : 'id';
      final parentIdField = tableName == 'tb_children' ? 'parent_user_id' : 'user_id';

      final response = await _supabase
          .from(tableName)
          .update(updateData)
          .eq(idField, childId)
          .eq(parentIdField, user.id)
          .select()
          .single();

      print('아이 정보 수정 성공');
      return Child.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('아이 정보 수정 에러: $e');
      rethrow;
    }
  }

  /// 아이 정보 삭제
  Future<void> deleteChild(int childId) async {
    try {
      print('아이 삭제 시작: childId=$childId');
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final tableName = await _getTableName();
      final idField = tableName == 'tb_children' ? 'child_id' : 'id';
      final parentIdField = tableName == 'tb_children' ? 'parent_user_id' : 'user_id';

      await _supabase
          .from(tableName)
          .delete()
          .eq(idField, childId)
          .eq(parentIdField, user.id);

      print('아이 삭제 성공');
    } catch (e) {
      print('아이 삭제 에러: $e');
      rethrow;
    }
  }
}

