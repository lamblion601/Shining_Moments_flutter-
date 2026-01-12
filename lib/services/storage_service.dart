import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

/// Supabase Storage 서비스
/// 그림 이미지를 Supabase Storage에 업로드하고 관리합니다.
class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String bucketName = 'drawings';
  static const String profileBucketName = 'profiles'; // 프로필 이미지용 버킷
  
  /// Storage 버킷이 존재하는지 확인
  /// 버킷이 없으면 사용자에게 안내 메시지를 표시하도록 에러를 던짐
  Future<void> ensureBucketExists() async {
    try {
      print('📦 Storage 버킷 확인: $bucketName');
      
      // 버킷 목록 조회
      final buckets = await _supabase.storage.listBuckets();
      final bucketExists = buckets.any((bucket) => bucket.name == bucketName);
      
      if (!bucketExists) {
        print('❌ 버킷이 없습니다: $bucketName');
        throw Exception(
          'Supabase Storage 버킷이 설정되지 않았습니다.\n\n'
          '해결 방법:\n'
          '1. Supabase Dashboard에 접속\n'
          '2. Storage 메뉴로 이동\n'
          '3. "drawings" 버킷 생성 (public으로 설정)\n\n'
          '자세한 가이드는 docs/SUPABASE_SETUP.md를 참조하세요.'
        );
      } else {
        print('✅ 버킷이 존재합니다: $bucketName');
      }
    } catch (e) {
      print('❌ 버킷 확인 에러: $e');
      
      // RLS 정책 관련 에러인 경우
      if (e.toString().contains('row-level security') || 
          e.toString().contains('403') ||
          e.toString().contains('Unauthorized')) {
        throw Exception(
          'Supabase Storage 권한 문제가 발생했습니다.\n\n'
          '해결 방법:\n'
          '1. Supabase Dashboard → Storage로 이동\n'
          '2. "drawings" 버킷이 있는지 확인\n'
          '3. 없다면 새 버킷 생성:\n'
          '   - Name: drawings\n'
          '   - Public: 체크\n'
          '4. 이미 있다면 RLS 정책 확인\n\n'
          '자세한 가이드는 docs/SUPABASE_SETUP.md를 참조하세요.'
        );
      }
      
      rethrow;
    }
  }
  
  /// 그림 이미지 업로드
  /// userId와 childId, 타임스탬프를 조합하여 고유한 파일명 생성
  Future<String> uploadDrawing({
    required File imageFile,
    required String userId,
    required String childId,
  }) async {
    try {
      print('📤 이미지 업로드 시작: userId=$userId, childId=$childId');
      print('📁 파일 경로: ${imageFile.path}');
      
      // 파일이 존재하는지 확인
      if (!await imageFile.exists()) {
        throw Exception('이미지 파일이 존재하지 않습니다: ${imageFile.path}');
      }
      
      final fileSize = await imageFile.length();
      print('📊 파일 크기: ${(fileSize / 1024).toStringAsFixed(1)} KB');
      
      // 파일 크기 제한 (10MB)
      const maxFileSize = 10 * 1024 * 1024; // 10MB
      if (fileSize > maxFileSize) {
        throw Exception(
          '파일 크기가 너무 큽니다.\n'
          '현재: ${(fileSize / 1024 / 1024).toStringAsFixed(1)} MB\n'
          '최대: 10 MB'
        );
      }
      
      // 버킷 존재 확인
      await ensureBucketExists();
      
      // 고유한 파일명 생성
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imageFile.path).toLowerCase();
      final fileName = '${userId}_${childId}_$timestamp$extension';
      print('📝 파일명: $fileName');
      
      // Supabase Storage에 업로드
      print('🚀 Supabase Storage 업로드 중...');
      final uploadPath = await _supabase.storage
          .from(bucketName)
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );
      
      print('✅ 업로드 완료: $uploadPath');
      
      // Public URL 생성
      final publicUrl = _supabase.storage
          .from(bucketName)
          .getPublicUrl(fileName);
      
      print('🔗 Public URL: $publicUrl');
      return publicUrl;
    } catch (e, stackTrace) {
      print('❌ 이미지 업로드 에러: $e');
      print('📋 에러 스택: $stackTrace');
      
      // Storage 관련 에러인 경우 더 명확한 메시지
      if (e.toString().contains('Storage') || 
          e.toString().contains('버킷') ||
          e.toString().contains('bucket')) {
        rethrow; // 이미 명확한 메시지가 있음
      }
      
      throw Exception('이미지 업로드 실패: ${e.toString()}');
    }
  }
  
  /// 이미지 삭제
  /// URL에서 파일명을 추출하여 삭제
  Future<void> deleteDrawing(String imageUrl) async {
    try {
      print('이미지 삭제 시작: $imageUrl');
      
      // URL에서 파일명 추출
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      if (pathSegments.isEmpty) {
        throw Exception('잘못된 이미지 URL입니다.');
      }
      
      final fileName = pathSegments.last;
      print('파일명: $fileName');
      
      // Supabase Storage에서 삭제
      await _supabase.storage
          .from(bucketName)
          .remove([fileName]);
      
      print('이미지 삭제 완료');
    } catch (e) {
      print('이미지 삭제 에러: $e');
      rethrow;
    }
  }
  
  /// 여러 이미지 삭제
  Future<void> deleteDrawings(List<String> imageUrls) async {
    try {
      print('여러 이미지 삭제 시작: ${imageUrls.length}개');
      
      final fileNames = <String>[];
      for (final url in imageUrls) {
        final uri = Uri.parse(url);
        final pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty) {
          fileNames.add(pathSegments.last);
        }
      }
      
      if (fileNames.isEmpty) {
        print('삭제할 파일이 없습니다.');
        return;
      }
      
      print('삭제할 파일 목록: $fileNames');
      
      // Supabase Storage에서 일괄 삭제
      await _supabase.storage
          .from(bucketName)
          .remove(fileNames);
      
      print('여러 이미지 삭제 완료');
    } catch (e) {
      print('여러 이미지 삭제 에러: $e');
      rethrow;
    }
  }
  
  /// 이미지 URL이 유효한지 확인
  Future<bool> isValidImageUrl(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      if (pathSegments.isEmpty) {
        return false;
      }
      
      final fileName = pathSegments.last;
      
      // 파일 존재 여부 확인 (list 사용)
      final files = await _supabase.storage
          .from(bucketName)
          .list(
            path: '',
            searchOptions: SearchOptions(
              limit: 1,
              search: fileName,
            ),
          );
      
      return files.isNotEmpty;
    } catch (e) {
      print('이미지 URL 유효성 확인 에러: $e');
      return false;
    }
  }
  
  /// 프로필 이미지 업로드
  /// userId와 childId, 타임스탬프를 조합하여 고유한 파일명 생성
  Future<String> uploadProfileImage({
    required File imageFile,
    required String userId,
    String? childId, // null이면 부모 프로필, 있으면 아이 프로필
  }) async {
    try {
      print('📤 프로필 이미지 업로드 시작: userId=$userId, childId=$childId');
      print('📁 파일 경로: ${imageFile.path}');
      
      // 파일이 존재하는지 확인
      if (!await imageFile.exists()) {
        throw Exception('이미지 파일이 존재하지 않습니다: ${imageFile.path}');
      }
      
      final fileSize = await imageFile.length();
      print('📊 파일 크기: ${(fileSize / 1024).toStringAsFixed(1)} KB');
      
      // 파일 크기 제한 (5MB - 프로필은 더 작게)
      const maxFileSize = 5 * 1024 * 1024; // 5MB
      if (fileSize > maxFileSize) {
        throw Exception(
          '파일 크기가 너무 큽니다.\n'
          '현재: ${(fileSize / 1024 / 1024).toStringAsFixed(1)} MB\n'
          '최대: 5 MB'
        );
      }
      
      // 고유한 파일명 생성
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imageFile.path).toLowerCase();
      final fileName = childId != null
          ? 'child_${userId}_${childId}_$timestamp$extension'
          : 'user_${userId}_$timestamp$extension';
      print('📝 파일명: $fileName');
      
      // drawings 버킷 사용 (기존 버킷 활용)
      print('🚀 Supabase Storage 업로드 중...');
      final uploadPath = await _supabase.storage
          .from(bucketName) // drawings 버킷 사용
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );
      
      print('✅ 업로드 완료: $uploadPath');
      
      // Public URL 생성
      final publicUrl = _supabase.storage
          .from(bucketName)
          .getPublicUrl(fileName);
      
      print('🔗 Public URL: $publicUrl');
      return publicUrl;
    } catch (e, stackTrace) {
      print('❌ 프로필 이미지 업로드 에러: $e');
      print('📋 에러 스택: $stackTrace');
      
      throw Exception('프로필 이미지 업로드 실패: ${e.toString()}');
    }
  }
  
  /// 프로필 이미지 삭제
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      print('프로필 이미지 삭제 시작: $imageUrl');
      
      // URL에서 파일명 추출
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      if (pathSegments.isEmpty) {
        throw Exception('잘못된 이미지 URL입니다.');
      }
      
      final fileName = pathSegments.last;
      print('파일명: $fileName');
      
      // Supabase Storage에서 삭제
      await _supabase.storage
          .from(bucketName) // drawings 버킷 사용
          .remove([fileName]);
      
      print('프로필 이미지 삭제 완료');
    } catch (e) {
      print('프로필 이미지 삭제 에러: $e');
      rethrow;
    }
  }
}

