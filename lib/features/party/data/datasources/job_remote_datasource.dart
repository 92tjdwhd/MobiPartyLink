import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobi_party_link/core/error/exceptions.dart';
import 'package:mobi_party_link/features/party/data/models/job_category_model.dart';
import 'package:mobi_party_link/features/party/data/models/job_model.dart';
import 'package:mobi_party_link/features/party/domain/entities/job_category_entity.dart';
import 'package:mobi_party_link/features/party/domain/entities/job_entity.dart';

abstract class JobRemoteDataSource {
  Future<List<JobCategoryEntity>> getJobCategories();
  Future<List<JobEntity>> getJobs();
  Future<List<JobEntity>> getJobsByCategory(String categoryId);
  Future<JobEntity> getJobById(String jobId);
}

class JobRemoteDataSourceImpl implements JobRemoteDataSource {
  final SupabaseClient _supabaseClient;

  JobRemoteDataSourceImpl({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  @override
  Future<List<JobCategoryEntity>> getJobCategories() async {
    try {
      final response = await _supabaseClient
          .from('job_categories')
          .select('*')
          .order('name', ascending: true);

      return (response as List)
          .map((json) => JobCategoryModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw ServerException(message: '직업 카테고리를 가져오는데 실패했습니다: $e');
    }
  }

  @override
  Future<List<JobEntity>> getJobs() async {
    try {
      final response = await _supabaseClient
          .from('jobs')
          .select('*')
          .eq('is_active', true)
          .order('name', ascending: true);

      return (response as List)
          .map((json) => JobModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw ServerException(message: '직업 목록을 가져오는데 실패했습니다: $e');
    }
  }

  @override
  Future<List<JobEntity>> getJobsByCategory(String categoryId) async {
    try {
      final response = await _supabaseClient
          .from('jobs')
          .select('*')
          .eq('category_id', categoryId)
          .eq('is_active', true)
          .order('name', ascending: true);

      return (response as List)
          .map((json) => JobModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw ServerException(message: '카테고리별 직업을 가져오는데 실패했습니다: $e');
    }
  }

  @override
  Future<JobEntity> getJobById(String jobId) async {
    try {
      final response = await _supabaseClient
          .from('jobs')
          .select('*')
          .eq('id', jobId)
          .eq('is_active', true)
          .single();

      return JobModel.fromJson(response).toEntity();
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw ServerException(message: '직업을 찾을 수 없습니다', code: e.code);
      }
      throw ServerException(message: e.message, code: e.code);
    } catch (e) {
      throw ServerException(message: '직업 정보를 가져오는데 실패했습니다: $e');
    }
  }
}
