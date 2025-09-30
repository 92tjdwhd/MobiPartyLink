import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobi_party_link/core/services/local_storage_service.dart';
import 'package:mobi_party_link/features/party/domain/entities/party_template_entity.dart';

/// 로컬에 저장된 파티 템플릿 목록을 제공하는 Provider
final localTemplatesProvider =
    FutureProvider<List<PartyTemplateEntity>>((ref) async {
  // 로컬 저장소에서 템플릿 목록 가져오기
  final templates = await LocalStorageService.getPartyTemplates();

  if (templates == null || templates.isEmpty) {
    print('⚠️ 로컬에 저장된 템플릿이 없습니다. 동기화가 필요합니다.');
    return [];
  }

  return templates;
});

/// 컨텐츠 타입별 템플릿 Provider
final templatesByContentTypeProvider =
    FutureProvider.family<List<PartyTemplateEntity>, String>(
        (ref, contentType) async {
  final templates = await ref.watch(localTemplatesProvider.future);
  return templates
      .where((template) => template.contentType == contentType)
      .toList();
});

/// 카테고리별 템플릿 Provider
final templatesByCategoryProvider =
    FutureProvider.family<List<PartyTemplateEntity>, String>(
        (ref, category) async {
  final templates = await ref.watch(localTemplatesProvider.future);
  return templates.where((template) => template.category == category).toList();
});
