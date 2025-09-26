import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/party_template_entity.dart';
import '../../domain/entities/template_version_entity.dart';
import '../models/party_template_model.dart';
import '../models/template_version_model.dart';

abstract class PartyTemplateServerDataSource {
  Future<TemplateVersionEntity> getTemplateVersion();
  Future<List<PartyTemplateEntity>> getServerTemplates();
}

class PartyTemplateServerDataSourceImpl
    implements PartyTemplateServerDataSource {
  final SupabaseClient _supabaseClient;

  PartyTemplateServerDataSourceImpl({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  @override
  Future<TemplateVersionEntity> getTemplateVersion() async {
    try {
      // 서버에서 템플릿 버전 정보 가져오기
      final response = await _supabaseClient
          .from('template_versions')
          .select('*')
          .order('version', ascending: false)
          .limit(1)
          .single();

      return TemplateVersionModel.fromJson(response).toEntity();
    } catch (e) {
      // 버전 테이블이 없으면 기본값 반환
      return TemplateVersionEntity(
        version: 1,
        lastUpdated: DateTime.now(),
        templateCount: 4,
      );
    }
  }

  @override
  Future<List<PartyTemplateEntity>> getServerTemplates() async {
    try {
      final response = await _supabaseClient
          .from('party_templates')
          .select('*')
          .eq('is_default', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PartyTemplateModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw ServerException(message: '서버 템플릿을 가져오는데 실패했습니다: $e');
    }
  }
}
