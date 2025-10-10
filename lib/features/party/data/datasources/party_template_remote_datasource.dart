import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/party_template_entity.dart';
import '../../domain/entities/party_entity.dart';
import '../../domain/entities/party_member_entity.dart';
import '../models/party_template_model.dart';
import '../models/party_model.dart';
import '../models/party_member_model.dart';

abstract class PartyTemplateRemoteDataSource {
  Future<List<PartyTemplateEntity>> getTemplates();
  Future<List<PartyTemplateEntity>> getTemplatesByContentType(
      String contentType);
  Future<List<PartyTemplateEntity>> getDefaultTemplates();
  Future<PartyEntity> createPartyFromTemplate(
    String templateId,
    String partyName,
    DateTime startTime,
    String creatorId,
  );
}

class PartyTemplateRemoteDataSourceImpl
    implements PartyTemplateRemoteDataSource {

  PartyTemplateRemoteDataSourceImpl({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;
  final SupabaseClient _supabaseClient;

  @override
  Future<List<PartyTemplateEntity>> getTemplates() async {
    try {
      final response = await _supabaseClient
          .from('party_templates')
          .select('*')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PartyTemplateModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw ServerException(message: '파티 템플릿을 가져오는데 실패했습니다: $e');
    }
  }

  @override
  Future<List<PartyTemplateEntity>> getTemplatesByContentType(
      String contentType) async {
    try {
      final response = await _supabaseClient
          .from('party_templates')
          .select('*')
          .eq('content_type', contentType)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PartyTemplateModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw ServerException(message: '파티 템플릿을 가져오는데 실패했습니다: $e');
    }
  }

  @override
  Future<List<PartyTemplateEntity>> getDefaultTemplates() async {
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
      throw ServerException(message: '기본 파티 템플릿을 가져오는데 실패했습니다: $e');
    }
  }

  @override
  Future<PartyEntity> createPartyFromTemplate(
    String templateId,
    String partyName,
    DateTime startTime,
    String creatorId,
  ) async {
    try {
      // 템플릿 정보 가져오기
      final templateResponse = await _supabaseClient
          .from('party_templates')
          .select('*')
          .eq('id', templateId)
          .single();

      final template = PartyTemplateModel.fromJson(templateResponse).toEntity();

      // 파티 생성
      final party = PartyEntity(
        id: _generateId(),
        name: partyName,
        startTime: startTime,
        maxMembers: template.maxMembers,
        contentType: template.contentType,
        requireJob: template.requireJob,
        requirePower: template.requirePower,
        status: PartyStatus.pending,
        creatorId: creatorId,
        members: [
          PartyMemberEntity(
            id: _generateId(),
            partyId: _generateId(),
            userId: creatorId,
            nickname: '파티장',
            job: null,
            power: null,
            joinedAt: DateTime.now(),
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 파티 저장
      final partyResponse = await _supabaseClient
          .from('parties')
          .insert(PartyModel.fromEntity(party).toJson())
          .select()
          .single();

      // 생성자를 첫 번째 멤버로 추가
      await _supabaseClient
          .from('party_members')
          .insert(PartyMemberModel.fromEntity(party.members.first).toJson());

      // 완전한 파티 정보 조회
      final fullParty = await _supabaseClient.from('parties').select('''
            *,
            party_members(*)
          ''').eq('id', partyResponse['id']).single();

      return PartyModel.fromJson(fullParty).toEntity();
    } catch (e) {
      throw ServerException(message: '템플릿으로 파티 생성에 실패했습니다: $e');
    }
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
