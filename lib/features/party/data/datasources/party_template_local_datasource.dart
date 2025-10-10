import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/party_template_entity.dart';
import '../../domain/entities/template_version_entity.dart';
import '../models/party_template_model.dart';
import '../models/template_version_model.dart';

abstract class PartyTemplateLocalDataSource {
  Future<List<PartyTemplateEntity>> getServerTemplates();
  Future<List<PartyTemplateEntity>> getCustomTemplates();
  Future<List<PartyTemplateEntity>> getAllTemplates();
  Future<void> saveServerTemplates(List<PartyTemplateEntity> templates);
  Future<void> saveCustomTemplate(PartyTemplateEntity template);
  Future<void> deleteCustomTemplate(String templateId);
  Future<TemplateVersionEntity?> getTemplateVersion();
  Future<void> saveTemplateVersion(TemplateVersionEntity version);
  Future<void> clearAllTemplates();
}

class PartyTemplateLocalDataSourceImpl implements PartyTemplateLocalDataSource {

  PartyTemplateLocalDataSourceImpl(
      {required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences;
  final SharedPreferences _sharedPreferences;

  // 서버 템플릿 관련 키
  static const String _serverTemplatesKey = 'server_templates';
  static const String _templateVersionKey = 'template_version';

  // 커스텀 템플릿 관련 키
  static const String _customTemplatesKey = 'custom_templates';

  @override
  Future<List<PartyTemplateEntity>> getServerTemplates() async {
    try {
      final templatesJson = _sharedPreferences.getString(_serverTemplatesKey);
      if (templatesJson == null) return [];

      final List<dynamic> templatesList = jsonDecode(templatesJson);
      return templatesList
          .map((json) => PartyTemplateModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw CacheException(message: '서버 템플릿을 가져오는데 실패했습니다: $e');
    }
  }

  @override
  Future<List<PartyTemplateEntity>> getCustomTemplates() async {
    try {
      final templatesJson = _sharedPreferences.getString(_customTemplatesKey);
      if (templatesJson == null) return [];

      final List<dynamic> templatesList = jsonDecode(templatesJson);
      return templatesList
          .map((json) => PartyTemplateModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw CacheException(message: '커스텀 템플릿을 가져오는데 실패했습니다: $e');
    }
  }

  @override
  Future<List<PartyTemplateEntity>> getAllTemplates() async {
    try {
      final serverTemplates = await getServerTemplates();
      final customTemplates = await getCustomTemplates();

      // 서버 템플릿 + 커스텀 템플릿 합치기
      return [...serverTemplates, ...customTemplates];
    } catch (e) {
      throw CacheException(message: '모든 템플릿을 가져오는데 실패했습니다: $e');
    }
  }

  @override
  Future<void> saveServerTemplates(List<PartyTemplateEntity> templates) async {
    try {
      final templatesJson = jsonEncode(templates
          .map((template) => PartyTemplateModel.fromEntity(template).toJson())
          .toList());
      await _sharedPreferences.setString(_serverTemplatesKey, templatesJson);
    } catch (e) {
      throw CacheException(message: '서버 템플릿 저장에 실패했습니다: $e');
    }
  }

  @override
  Future<void> saveCustomTemplate(PartyTemplateEntity template) async {
    try {
      final existingTemplates = await getCustomTemplates();

      // 기존 템플릿이 있으면 업데이트, 없으면 추가
      final updatedTemplates = [...existingTemplates];
      final existingIndex =
          updatedTemplates.indexWhere((t) => t.id == template.id);

      if (existingIndex >= 0) {
        updatedTemplates[existingIndex] = template;
      } else {
        updatedTemplates.add(template);
      }

      final templatesJson = jsonEncode(updatedTemplates
          .map((t) => PartyTemplateModel.fromEntity(t).toJson())
          .toList());
      await _sharedPreferences.setString(_customTemplatesKey, templatesJson);
    } catch (e) {
      throw CacheException(message: '커스텀 템플릿 저장에 실패했습니다: $e');
    }
  }

  @override
  Future<void> deleteCustomTemplate(String templateId) async {
    try {
      final existingTemplates = await getCustomTemplates();
      final updatedTemplates =
          existingTemplates.where((t) => t.id != templateId).toList();

      final templatesJson = jsonEncode(updatedTemplates
          .map((t) => PartyTemplateModel.fromEntity(t).toJson())
          .toList());
      await _sharedPreferences.setString(_customTemplatesKey, templatesJson);
    } catch (e) {
      throw CacheException(message: '커스텀 템플릿 삭제에 실패했습니다: $e');
    }
  }

  @override
  Future<TemplateVersionEntity?> getTemplateVersion() async {
    try {
      final versionJson = _sharedPreferences.getString(_templateVersionKey);
      if (versionJson == null) return null;

      return TemplateVersionModel.fromJson(jsonDecode(versionJson)).toEntity();
    } catch (e) {
      throw CacheException(message: '템플릿 버전을 가져오는데 실패했습니다: $e');
    }
  }

  @override
  Future<void> saveTemplateVersion(TemplateVersionEntity version) async {
    try {
      final versionJson =
          jsonEncode(TemplateVersionModel.fromEntity(version).toJson());
      await _sharedPreferences.setString(_templateVersionKey, versionJson);
    } catch (e) {
      throw CacheException(message: '템플릿 버전 저장에 실패했습니다: $e');
    }
  }

  @override
  Future<void> clearAllTemplates() async {
    try {
      await _sharedPreferences.remove(_serverTemplatesKey);
      await _sharedPreferences.remove(_customTemplatesKey);
      await _sharedPreferences.remove(_templateVersionKey);
    } catch (e) {
      throw CacheException(message: '모든 템플릿 삭제에 실패했습니다: $e');
    }
  }
}
