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
  Future<List<PartyEntity>> getMyParties(String userId);
  Future<List<PartyEntity>> getJoinedParties(String userId);
  Future<void> kickMember(
      String partyId, String memberId, String creatorId); // 멤버 강퇴
  Future<List<String>> getPartyMemberFcmTokens(
      String partyId); // 파티 멤버 FCM 토큰 조회
  Stream<List<PartyEntity>> get partiesStream;
  Stream<PartyEntity?> watchParty(String partyId);
}

class PartyRemoteDataSourceImpl implements PartyRemoteDataSource {
  PartyRemoteDataSourceImpl({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;
  final SupabaseClient _supabaseClient;

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
      final response = await queryBuilder.order('created_at', ascending: false);
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
      // 파티만 생성 (members는 Repository에서 별도로 추가)
      final partyResponse = await _supabaseClient
          .from('parties')
          .insert(PartyModel.fromEntity(party).toJson())
          .select()
          .single();

      // PartyModel로 변환하여 반환
      return PartyModel.fromJson(partyResponse).toEntity();
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
        throw const ServerException(message: '파티를 찾을 수 없습니다');
      }
      if (party.members.length >= party.maxMembers) {
        throw const ServerException(message: '파티가 가득 찼습니다');
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
        throw const ServerException(message: '파티를 찾을 수 없습니다');
      }
      if (party.creatorId != userId) {
        throw const ServerException(message: '파티 삭제 권한이 없습니다');
      }

      // 파티 삭제 전에 멤버들의 FCM 토큰 수집
      final fcmTokens = party.members
          .map((m) => m.fcmToken)
          .where(
              (token) => token != null && !token!.contains('dummy_fcm_token'))
          .cast<String>()
          .toList();

      print('📩 파티 삭제 푸시 대상: ${fcmTokens.length}명');

      // 파티 삭제 (CASCADE로 멤버들도 자동 삭제됨)
      await _supabaseClient.from('parties').delete().eq('id', partyId);

      // 파티 삭제 푸시 전송
      if (fcmTokens.isNotEmpty) {
        try {
          await _supabaseClient.functions.invoke(
            'fcm-send',
            body: {
              'fcm_tokens': fcmTokens,
              'title': '파티 삭제',
              'body': '[${party.name}] 파티가 삭제되었습니다',
              'data': {
                'type': 'party_delete',
                'party_name': party.name,
              }
            },
          );
          print('✅ 파티 삭제 푸시 전송 완료');
        } catch (e) {
          print('⚠️ 파티 삭제 푸시 전송 실패: $e');
          // 푸시 실패해도 파티 삭제는 성공으로 처리
        }
      }
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
  Future<List<PartyEntity>> getMyParties(String userId) async {
    try {
      final response = await _supabaseClient.from('parties').select('''
            *,
            party_members(*)
          ''').eq('creator_id', userId).order('created_at', ascending: false);

      print('🔍 getMyParties 응답: ${response.length}개');
      final parties = (response as List).map((json) {
        print(
            '🔍 파티 JSON: ${json['name']}, members: ${json['party_members']?.length ?? 0}개');
        return PartyModel.fromJson(json).toEntity();
      }).toList();

      print(
          '🔍 변환된 파티: ${parties.length}개, 첫 번째 파티 멤버: ${parties.isNotEmpty ? parties.first.members.length : 0}개');
      return parties;
    } catch (e) {
      throw ServerException(message: '내 파티 목록을 가져오는데 실패했습니다: $e');
    }
  }

  @override
  Future<List<PartyEntity>> getJoinedParties(String userId) async {
    try {
      // 1. 먼저 내가 참여한 파티 ID 목록 가져오기
      final memberResponse = await _supabaseClient
          .from('party_members')
          .select('party_id')
          .eq('user_id', userId);

      final partyIds =
          (memberResponse as List).map((m) => m['party_id'] as String).toList();

      if (partyIds.isEmpty) {
        return [];
      }

      // 2. 해당 파티들의 전체 정보 (모든 멤버 포함) 가져오기
      final response = await _supabaseClient.from('parties').select('''
            *,
            party_members(*)
          ''').inFilter('id', partyIds).order('created_at', ascending: false);

      print('🔍 getJoinedParties 응답: ${response.length}개');
      final parties = (response as List).map((json) {
        print(
            '🔍 참가 파티 JSON: ${json['name']}, members: ${json['party_members']?.length ?? 0}개');
        return PartyModel.fromJson(json).toEntity();
      }).toList();

      print(
          '🔍 변환된 참가 파티: ${parties.length}개, 첫 번째 파티 멤버: ${parties.isNotEmpty ? parties.first.members.length : 0}개');
      return parties;
    } catch (e) {
      throw ServerException(message: '참가한 파티 목록을 가져오는데 실패했습니다: $e');
    }
  }

  @override
  Future<void> kickMember(
      String partyId, String memberId, String creatorId) async {
    try {
      // 생성자 권한 확인
      final party = await getPartyById(partyId);
      if (party == null) {
        throw const ServerException(message: '파티를 찾을 수 없습니다');
      }
      if (party.creatorId != creatorId) {
        throw const ServerException(message: '멤버 강퇴 권한이 없습니다');
      }

      // 멤버 삭제
      print('🔄 멤버 삭제 요청: partyId=$partyId, memberId=$memberId');
      final deleteResult = await _supabaseClient
          .from('party_members')
          .delete()
          .eq('id', memberId)
          .eq('party_id', partyId);
      print('✅ 멤버 삭제 완료: $deleteResult');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: '멤버 강퇴에 실패했습니다: $e');
    }
  }

  @override
  Future<List<String>> getPartyMemberFcmTokens(String partyId) async {
    try {
      final response = await _supabaseClient
          .from('party_members')
          .select('fcm_token')
          .eq('party_id', partyId)
          .not('fcm_token', 'is', null);

      return (response as List)
          .map((json) => json['fcm_token'] as String)
          .toList();
    } catch (e) {
      throw ServerException(message: 'FCM 토큰 조회에 실패했습니다: $e');
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
