import 'package:supabase_flutter/supabase_flutter.dart';

/// 아이 정보 모델
class Child {
  final String? childId; // UUID를 문자열로 처리
  final String parentUserId;
  final String? name;
  final DateTime? birthDate;
  final String? gender; // 'M' 또는 'F'
  final String? profileImageUrl;
  final List<String> personality; // 성향 목록 (traits 테이블의 name 값들)
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Child({
    this.childId,
    required this.parentUserId,
    this.name,
    this.birthDate,
    this.gender,
    this.profileImageUrl,
    List<String>? personality,
    this.createdAt,
    this.updatedAt,
  }) : personality = personality ?? [];

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
    
    // child_id 또는 id 필드 처리 (UUID를 문자열로 처리)
    String? childId;
    if (json.containsKey('child_id')) {
      childId = json['child_id']?.toString();
    } else if (json.containsKey('id')) {
      childId = json['id']?.toString();
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
      personality: [], // 성향은 별도로 조회해야 함 (children_traits 테이블)
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
      // personality는 children_traits 테이블에 별도로 저장
    };
  }

  /// 복사 생성자 (수정 시 사용)
  Child copyWith({
    String? childId,
    String? parentUserId,
    String? name,
    DateTime? birthDate,
    String? gender,
    String? profileImageUrl,
    List<String>? personality,
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

      final children = <Child>[];
      for (var json in response as List) {
        print('아이 데이터 파싱: $json');
        final child = Child.fromJson(json as Map<String, dynamic>);
        
        // 각 아이의 성향 정보 조회
        if (child.childId != null) {
          final traits = await getChildTraits(child.childId!);
          children.add(child.copyWith(personality: traits));
        } else {
          children.add(child);
        }
      }
      
      return children;
    } catch (e) {
      print('아이 목록 조회 에러 상세: $e');
      print('에러 타입: ${e.runtimeType}');
      // 빈 리스트 반환 (에러가 발생해도 앱이 크래시되지 않도록)
      return [];
    }
  }

  /// 특정 아이 정보 조회
  Future<Child?> getChild(String childId) async {
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
      final child = Child.fromJson(response as Map<String, dynamic>);
      
      // 성향 정보 조회
      final traits = await getChildTraits(childId);
      return child.copyWith(personality: traits);
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

  /// 성향 목록 조회 (traits 테이블)
  Future<List<Map<String, dynamic>>> getTraits() async {
    try {
      print('성향 목록 조회 시작');
      final response = await _supabase
          .from('traits')
          .select()
          .order('id');
      
      print('성향 목록 조회 성공: ${response.length}개');
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('성향 목록 조회 에러: $e');
      return [];
    }
  }

  /// 아이의 성향 조회 (children_traits 테이블)
  Future<List<String>> getChildTraits(String childId) async {
    try {
      print('아이 성향 조회 시작: childId=$childId');
      
      // children_traits에서 trait_id 목록 조회
      final childrenTraitsResponse = await _supabase
          .from('children_traits')
          .select('trait_id')
          .eq('child_id', childId);
      
      print('아이 성향 조회 응답: $childrenTraitsResponse');
      
      if (childrenTraitsResponse.isEmpty) {
        return [];
      }
      
      // trait_id 목록 추출
      final traitIds = <int>[];
      for (var item in childrenTraitsResponse as List) {
        final traitId = item['trait_id'];
        if (traitId != null) {
          traitIds.add(traitId is int ? traitId : int.tryParse(traitId.toString()) ?? 0);
        }
      }
      
      if (traitIds.isEmpty) {
        return [];
      }
      
      // traits 테이블에서 name 조회 (각 trait_id에 대해 개별 조회)
      final traitNames = <String>[];
      for (final traitId in traitIds) {
        try {
          final traitResponse = await _supabase
              .from('traits')
              .select('name')
              .eq('id', traitId)
              .maybeSingle();
          
          if (traitResponse != null) {
            final name = traitResponse['name']?.toString();
            if (name != null && name.isNotEmpty) {
              traitNames.add(name);
            }
          }
        } catch (e) {
          print('성향 조회 에러 (id=$traitId): $e');
        }
      }
      
      print('아이 성향 조회 성공: $traitNames');
      return traitNames;
    } catch (e) {
      print('아이 성향 조회 에러: $e');
      return [];
    }
  }

  /// 아이의 성향 저장/수정 (children_traits 테이블)
  Future<void> setChildTraits(String childId, List<String> traitNames) async {
    try {
      print('아이 성향 저장 시작: childId=$childId, traitNames=$traitNames');
      
      // 먼저 traits 테이블에서 trait_id 조회
      // Supabase에서는 inFilter 대신 각각 조회하거나 or 조건 사용
      // traitNames가 많을 수 있으므로 각각 조회
      final traitIds = <int>[];
      for (final traitName in traitNames) {
        try {
          final traitResponse = await _supabase
              .from('traits')
              .select('id')
              .eq('name', traitName)
              .maybeSingle();
          
          if (traitResponse != null) {
            final id = traitResponse['id'] as int?;
            if (id != null) {
              traitIds.add(id);
            }
          }
        } catch (e) {
          print('성향 조회 에러 (name=$traitName): $e');
        }
      }
      
      print('조회된 trait_ids: $traitIds');
      
      // 기존 성향 삭제
      await _supabase
          .from('children_traits')
          .delete()
          .eq('child_id', childId);
      
      // 새로운 성향 추가
      if (traitIds.isNotEmpty) {
        final insertData = traitIds.map((traitId) => {
          'child_id': childId,
          'trait_id': traitId,
        }).toList();
        
        await _supabase
            .from('children_traits')
            .insert(insertData);
      }
      
      print('아이 성향 저장 성공');
    } catch (e) {
      print('아이 성향 저장 에러: $e');
      rethrow;
    }
  }

  /// 아이 정보 추가
  Future<Child> addChild({
    required String name,
    required DateTime birthDate,
    required String gender,
    String? profileImageUrl,
    List<String>? personality,
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
        // personality는 children_traits 테이블에 별도로 저장
      };

      print('추가할 데이터: $childData');
      print('사용할 테이블: $tableName, 부모 ID 필드: $parentIdField');

      final response = await _supabase
          .from(tableName)
          .insert(childData)
          .select()
          .single();

      final childId = (response['child_id'] ?? response['id'])?.toString();
      print('아이 추가 성공: childId=$childId');
      
      final child = Child.fromJson(response as Map<String, dynamic>);
      
      // 성향 저장
      if (childId != null && personality != null && personality.isNotEmpty) {
        await setChildTraits(childId, personality);
        return child.copyWith(personality: personality);
      }
      
      return child;
    } catch (e) {
      print('아이 추가 에러 상세: $e');
      print('에러 타입: ${e.runtimeType}');
      print('에러 스택: ${StackTrace.current}');
      rethrow;
    }
  }

  /// 아이 정보 수정
  Future<Child> updateChild({
    required String childId,
    String? name,
    DateTime? birthDate,
    String? gender,
    String? profileImageUrl,
    List<String>? personality,
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
      // personality는 children_traits 테이블에 별도로 저장

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
      final child = Child.fromJson(response as Map<String, dynamic>);
      
      // 성향 수정
      if (personality != null) {
        await setChildTraits(childId, personality);
        return child.copyWith(personality: personality);
      }
      
      // 성향 정보 조회
      final traits = await getChildTraits(childId);
      return child.copyWith(personality: traits);
    } catch (e) {
      print('아이 정보 수정 에러: $e');
      rethrow;
    }
  }

  /// 아이 정보 삭제
  Future<void> deleteChild(String childId) async {
    try {
      print('아이 삭제 시작: childId=$childId');
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      // 먼저 children_traits 테이블에서 성향 삭제
      await _supabase
          .from('children_traits')
          .delete()
          .eq('child_id', childId);
      
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

  /// 최근 분석 기록 조회 (drawings 테이블)
  Future<List<Map<String, dynamic>>> getRecentDrawings({int limit = 5}) async {
    try {
      print('최근 분석 기록 조회 시작: limit=$limit');
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('에러: 사용자가 로그인하지 않았습니다.');
        throw Exception('로그인이 필요합니다.');
      }

      print('현재 사용자 ID: ${user.id}');

      // drawings 테이블에서 직접 조회 (조인 없이)
      final response = await _supabase
          .from('drawings')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(limit);

      print('최근 분석 기록 조회 성공: ${response.length}개');
      print('응답 데이터: $response');
      
      final drawings = <Map<String, dynamic>>[];
      
      // 아이 정보 미리 조회 (캐시용)
      final children = await getChildren();
      final childrenMap = <String, String>{};
      for (var child in children) {
        if (child.childId != null && child.name != null) {
          childrenMap[child.childId!] = child.name!;
        }
      }
      print('아이 목록 캐시: ${childrenMap.keys.length}개');
      
      for (var item in response as List) {
        print('분석 기록 항목: $item');
        
        final childId = item['child_id']?.toString();
        final childName = childId != null ? childrenMap[childId] : null;
        
        final drawing = <String, dynamic>{
          'id': item['id']?.toString(),
          'image_url': item['image_url']?.toString(),
          'description': item['description']?.toString(),
          'analysis_result': item['analysis_result'],
          'created_at': item['created_at']?.toString(),
          'child_id': childId,
          'child_name': childName ?? '아이',
        };
        
        drawings.add(drawing);
        print('변환된 drawing: id=${drawing['id']}, child_name=${drawing['child_name']}');
      }
      
      print('최종 반환 drawings: ${drawings.length}개');
      return drawings;
    } catch (e, stackTrace) {
      print('최근 분석 기록 조회 에러: $e');
      print('에러 스택: $stackTrace');
      return [];
    }
  }
}

