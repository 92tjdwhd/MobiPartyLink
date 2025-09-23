import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/party_utils.dart';
import '../entities/party_entity.dart';
import '../entities/party_member_entity.dart';
import '../repositories/party_repository.dart';

class CreatePartyWithCategory {
  final PartyRepository repository;

  CreatePartyWithCategory(this.repository);

  Future<Either<Failure, PartyEntity>> call({
    required String partyName,
    required DateTime startTime,
    required String creatorId,
    required String creatorNickname,
    required String category,
    required String difficulty,
    String? creatorJob,
    int? creatorPower,
    int? customMaxMembers,
    bool? customRequireJob,
    bool? customRequirePower,
    int? customMinPower,
    int? customMaxPower,
    List<String>? customRecommendedJobs,
  }) async {
    try {
      // 카테고리와 난이도에 따른 기본 설정 가져오기
      final partySettings = _getPartySettingsByCategoryAndDifficulty(
        category: category,
        difficulty: difficulty,
        customMaxMembers: customMaxMembers,
        customRequireJob: customRequireJob,
        customRequirePower: customRequirePower,
        customMinPower: customMinPower,
        customMaxPower: customMaxPower,
        customRecommendedJobs: customRecommendedJobs,
      );

      // 파티 생성
      final party = PartyEntity(
        id: PartyUtils.generateId(),
        name: partyName,
        startTime: startTime,
        maxMembers: partySettings['maxMembers'] as int,
        contentType: category, // 카테고리를 contentType으로 사용
        category: category,
        difficulty: difficulty,
        requireJob: partySettings['requireJob'] as bool,
        requirePower: partySettings['requirePower'] as bool,
        minPower: partySettings['minPower'] as int?,
        maxPower: partySettings['maxPower'] as int?,
        recommendedJobs: partySettings['recommendedJobs'] as List<String>,
        status: PartyStatus.pending,
        creatorId: creatorId,
        members: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 생성자를 첫 멤버로 추가
      final creatorMember = PartyMemberEntity(
        id: PartyUtils.generateId(),
        partyId: party.id,
        userId: creatorId,
        nickname: creatorNickname,
        job: creatorJob,
        power: creatorPower,
        joinedAt: DateTime.now(),
      );

      // 파티 생성 및 생성자 추가
      final createResult = await repository.createParty(party);
      if (createResult.isLeft()) {
        return createResult;
      }

      final createdParty =
          createResult.getOrElse(() => throw Exception('파티 생성 실패'));

      // 생성자를 파티에 추가
      final joinResult =
          await repository.joinParty(createdParty.id, creatorMember);
      if (joinResult.isLeft()) {
        return createResult; // 파티는 생성되었으므로 파티 정보 반환
      }

      // 멤버가 추가된 파티 정보 반환
      final updatedParty = createdParty.copyWith(
        members: [creatorMember],
      );

      return Right(updatedParty);
    } catch (e) {
      return Left(ServerFailure(message: '파티 생성 중 오류가 발생했습니다: $e'));
    }
  }

  Map<String, dynamic> _getPartySettingsByCategoryAndDifficulty({
    required String category,
    required String difficulty,
    int? customMaxMembers,
    bool? customRequireJob,
    bool? customRequirePower,
    int? customMinPower,
    int? customMaxPower,
    List<String>? customRecommendedJobs,
  }) {
    // 카테고리별 기본 설정
    final categoryDefaults = _getCategoryDefaults(category);

    // 난이도별 설정 적용
    final difficultySettings = _getDifficultySettings(difficulty);

    // 사용자 커스텀 설정이 있으면 우선 적용
    return {
      'maxMembers': customMaxMembers ?? categoryDefaults['maxMembers'],
      'requireJob': customRequireJob ?? categoryDefaults['requireJob'],
      'requirePower': customRequirePower ?? categoryDefaults['requirePower'],
      'minPower': customMinPower ?? difficultySettings['minPower'],
      'maxPower': customMaxPower ?? difficultySettings['maxPower'],
      'recommendedJobs':
          customRecommendedJobs ?? difficultySettings['recommendedJobs'],
    };
  }

  Map<String, dynamic> _getCategoryDefaults(String category) {
    // 카테고리별 기본 설정 (실제로는 PartyCategoryConstants에서 가져와야 함)
    switch (category) {
      case 'raid':
        return {
          'maxMembers': 8,
          'requireJob': true,
          'requirePower': true,
        };
      case 'dungeon':
        return {
          'maxMembers': 4,
          'requireJob': true,
          'requirePower': false,
        };
      case 'pvp':
        return {
          'maxMembers': 2,
          'requireJob': false,
          'requirePower': true,
        };
      case 'guild':
        return {
          'maxMembers': 10,
          'requireJob': false,
          'requirePower': false,
        };
      case 'quest':
        return {
          'maxMembers': 4,
          'requireJob': false,
          'requirePower': false,
        };
      default:
        return {
          'maxMembers': 4,
          'requireJob': false,
          'requirePower': false,
        };
    }
  }

  Map<String, dynamic> _getDifficultySettings(String difficulty) {
    // 난이도별 설정 (실제로는 PartyDifficultyConstants에서 가져와야 함)
    switch (difficulty) {
      case 'easy':
        return {
          'minPower': 500,
          'maxPower': null,
          'recommendedJobs': ['warrior', 'archer', 'mage', 'priest'],
        };
      case 'normal':
        return {
          'minPower': 1000,
          'maxPower': null,
          'recommendedJobs': ['warrior', 'archer', 'mage', 'priest'],
        };
      case 'hard':
        return {
          'minPower': 2000,
          'maxPower': null,
          'recommendedJobs': ['warrior', 'archer', 'mage', 'priest', 'rogue'],
        };
      case 'extreme':
        return {
          'minPower': 4000,
          'maxPower': null,
          'recommendedJobs': [
            'warrior',
            'archer',
            'mage',
            'priest',
            'rogue',
            'paladin'
          ],
        };
      case 'nightmare':
        return {
          'minPower': 8000,
          'maxPower': null,
          'recommendedJobs': [
            'warrior',
            'archer',
            'mage',
            'priest',
            'rogue',
            'paladin',
            'monk'
          ],
        };
      default:
        return {
          'minPower': 1000,
          'maxPower': null,
          'recommendedJobs': ['warrior', 'archer', 'mage', 'priest'],
        };
    }
  }
}
