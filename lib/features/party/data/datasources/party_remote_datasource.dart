import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/party_entity.dart';
import '../../domain/entities/party_member_entity.dart';
import '../models/party_model.dart';
import '../models/party_member_model.dart';

abstract class PartyRemoteDataSource {
  Future<List<PartyEntity>> getParties();
  Future<List<PartyEntity>> searchParties({
    String? query,
    String? contentType,
    bool? requireJob,
    bool? requirePower,
    int? minPower,
    int? maxPower,
    PartyStatus? status,
  });
  Future<PartyEntity?> getPartyById(String partyId);
  Future<PartyEntity> createParty(PartyEntity party);
  Future<PartyMemberEntity> joinParty(String partyId, PartyMemberEntity member);
  Future<void> leaveParty(String partyId, String userId);
  Future<void> deleteParty(String partyId, String userId);
  Future<PartyEntity> updateParty(PartyEntity party);
  Stream<List<PartyEntity>> get partiesStream;
  Stream<PartyEntity?> watchParty(String partyId);
}

class PartyRemoteDataSourceImpl implements PartyRemoteDataSource {
  final SupabaseClient _supabaseClient;

  PartyRemoteDataSourceImpl({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  @override
  Future<List<PartyEntity>> getParties() async {
    try {
      final response = await _supabaseClient.from('parties').select('''
            *,
            party_members(*)
          ''').order('created_at', ascending: false);

      return (response as List)
          .map((json) => PartyModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw ServerException(message: '파티 목록을 가져오는데 실패했습니다: $e');
    }
  }

  @override
  Future<List<PartyEntity>> searchParties({
    String? query,
    String? contentType,
    bool? requireJob,
    bool? requirePower,
    int? minPower,
    int? maxPower,
    PartyStatus? status,
  }) async {
    try {
      var queryBuilder = _supabaseClient.from('parties').select('''
            *,
            party_members(*)
          ''');

      // 텍스트 검색
      if (query != null && query.isNotEmpty) {
        queryBuilder = queryBuilder.ilike('name', '%$query%');
      }

      // 콘텐츠 타입 필터
      if (contentType != null && contentType.isNotEmpty) {
        queryBuilder = queryBuilder.eq('content_type', contentType);
      }

      // 직업 필수 여부 필터
      if (requireJob != null) {
        queryBuilder = queryBuilder.eq('require_job', requireJob);
      }

      // 투력 필수 여부 필터
      if (requirePower != null) {
        queryBuilder = queryBuilder.eq('require_power', requirePower);
      }

      // 파티 상태 필터
      if (status != null) {
        queryBuilder = queryBuilder.eq('status', status.name);
      }

      // 정렬
      queryBuilder = queryBuilder.order('created_at', ascending: false);

      final response = await queryBuilder;
      return (response as List)
          .map((json) => PartyModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw ServerException(message: '파티 검색에 실패했습니다: $e');
    }
  }

  @override
  Future<PartyEntity?> getPartyById(String partyId) async {
    try {
      final response = await _supabaseClient.from('parties').select('''
            *,
            party_members(*)
          ''').eq('id', partyId).single();

      return PartyModel.fromJson(response).toEntity();
    } catch (e) {
      if (e.toString().contains('No rows found')) {
        return null;
      }
      throw ServerException(message: '파티 정보를 가져오는데 실패했습니다: $e');
    }
  }

  @override
  Future<PartyEntity> createParty(PartyEntity party) async {
    try {
      // 파티 생성
      final partyResponse = await _supabaseClient
          .from('parties')
          .insert(PartyModel.fromEntity(party).toJson())
          .select()
          .single();

      // 생성자를 첫 번째 멤버로 추가
      if (party.members.isNotEmpty) {
        await _supabaseClient
            .from('party_members')
            .insert(PartyMemberModel.fromEntity(party.members.first).toJson());
      }

      // 완전한 파티 정보 조회
      final fullParty = await getPartyById(partyResponse['id']);
      return fullParty!;
    } catch (e) {
      throw ServerException(message: '파티 생성에 실패했습니다: $e');
    }
  }

  @override
  Future<PartyMemberEntity> joinParty(
      String partyId, PartyMemberEntity member) async {
    try {
      // 파티 인원수 확인
      final party = await getPartyById(partyId);
      if (party == null) {
        throw ServerException(message: '파티를 찾을 수 없습니다');
      }
      if (party.members.length >= party.maxMembers) {
        throw ServerException(message: '파티가 가득 찼습니다');
      }

      // 멤버 추가
      final response = await _supabaseClient
          .from('party_members')
          .insert(PartyMemberModel.fromEntity(member).toJson())
          .select()
          .single();

      return PartyMemberModel.fromJson(response).toEntity();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: '파티 참여에 실패했습니다: $e');
    }
  }

  @override
  Future<void> leaveParty(String partyId, String userId) async {
    try {
      await _supabaseClient
          .from('party_members')
          .delete()
          .eq('party_id', partyId)
          .eq('user_id', userId);
    } catch (e) {
      throw ServerException(message: '파티 나가기에 실패했습니다: $e');
    }
  }

  @override
  Future<void> deleteParty(String partyId, String userId) async {
    try {
      // 생성자 권한 확인
      final party = await getPartyById(partyId);
      if (party == null) {
        throw ServerException(message: '파티를 찾을 수 없습니다');
      }
      if (party.creatorId != userId) {
        throw ServerException(message: '파티 삭제 권한이 없습니다');
      }

      // 파티 삭제 (CASCADE로 멤버들도 자동 삭제됨)
      await _supabaseClient.from('parties').delete().eq('id', partyId);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: '파티 삭제에 실패했습니다: $e');
    }
  }

  @override
  Future<PartyEntity> updateParty(PartyEntity party) async {
    try {
      await _supabaseClient
          .from('parties')
          .update(PartyModel.fromEntity(party).toJson())
          .eq('id', party.id);

      final updatedParty = await getPartyById(party.id);
      return updatedParty!;
    } catch (e) {
      throw ServerException(message: '파티 업데이트에 실패했습니다: $e');
    }
  }

  @override
  Stream<List<PartyEntity>> get partiesStream {
    return _supabaseClient.from('parties').stream(primaryKey: ['id']).map(
        (data) =>
            data.map((json) => PartyModel.fromJson(json).toEntity()).toList());
  }

  @override
  Stream<PartyEntity?> watchParty(String partyId) {
    return _supabaseClient
        .from('parties')
        .stream(primaryKey: ['id'])
        .eq('id', partyId)
        .map((data) {
          if (data.isEmpty) return null;
          return PartyModel.fromJson(data.first).toEntity();
        });
  }
}
