import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobi_party_link/core/services/data_sync_service.dart';
import 'package:mobi_party_link/core/services/local_storage_service.dart';
import 'package:mobi_party_link/core/di/injection.dart';

/// 데이터 동기화 테스트 화면
class DataSyncTestScreen extends ConsumerStatefulWidget {
  const DataSyncTestScreen({super.key});

  @override
  ConsumerState<DataSyncTestScreen> createState() => _DataSyncTestScreenState();
}

class _DataSyncTestScreenState extends ConsumerState<DataSyncTestScreen> {
  Map<String, dynamic>? _cacheStatus;
  bool _isLoading = false;
  String? _lastAction;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCacheStatus();
  }

  Future<void> _loadCacheStatus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final status = await LocalStorageService.getCacheStatus();
      setState(() {
        _cacheStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '캐시 상태 확인 실패: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _syncJobs() async {
    setState(() {
      _isLoading = true;
      _lastAction = '직업 데이터 동기화 중...';
      _errorMessage = null;
    });

    try {
      // Riverpod Provider를 통해 Repository 가져오기
      final jobRepository = ref.read(jobRepositoryProvider);
      final templateRepository = ref.read(partyTemplateRepositoryProvider);

      // DataSyncService 생성
      final syncService = DataSyncService(
        jobRepository: jobRepository,
        templateRepository: templateRepository,
      );

      final success = await syncService.syncJobs();

      setState(() {
        _lastAction = success ? '✅ 직업 데이터 동기화 완료!' : '❌ 직업 데이터 동기화 실패';
        _isLoading = false;
      });

      await _loadCacheStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_lastAction!),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = '동기화 중 오류: $e';
        _lastAction = '❌ 오류 발생';
        _isLoading = false;
      });
    }
  }

  Future<void> _syncTemplates() async {
    setState(() {
      _isLoading = true;
      _lastAction = '컨텐츠 데이터 동기화 중...';
      _errorMessage = null;
    });

    try {
      // Riverpod Provider를 통해 Repository 가져오기
      final jobRepository = ref.read(jobRepositoryProvider);
      final templateRepository = ref.read(partyTemplateRepositoryProvider);

      // DataSyncService 생성
      final syncService = DataSyncService(
        jobRepository: jobRepository,
        templateRepository: templateRepository,
      );

      final success = await syncService.syncTemplates();

      setState(() {
        _lastAction = success ? '✅ 컨텐츠 데이터 동기화 완료!' : '❌ 컨텐츠 데이터 동기화 실패';
        _isLoading = false;
      });

      await _loadCacheStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_lastAction!),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = '동기화 중 오류: $e';
        _lastAction = '❌ 오류 발생';
        _isLoading = false;
      });
    }
  }

  Future<void> _syncAll() async {
    setState(() {
      _isLoading = true;
      _lastAction = '전체 데이터 동기화 중...';
      _errorMessage = null;
    });

    try {
      // Riverpod Provider를 통해 Repository 가져오기
      final jobRepository = ref.read(jobRepositoryProvider);
      final templateRepository = ref.read(partyTemplateRepositoryProvider);

      // DataSyncService 생성
      final syncService = DataSyncService(
        jobRepository: jobRepository,
        templateRepository: templateRepository,
      );

      final results = await syncService.syncAll();
      final allSuccess = results['jobs']! && results['templates']!;

      setState(() {
        _lastAction = allSuccess ? '✅ 전체 데이터 동기화 완료!' : '⚠️ 일부 데이터 동기화 실패';
        _isLoading = false;
      });

      await _loadCacheStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_lastAction!),
            backgroundColor: allSuccess ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = '동기화 중 오류: $e';
        _lastAction = '❌ 오류 발생';
        _isLoading = false;
      });
    }
  }

  Future<void> _clearCache() async {
    setState(() {
      _isLoading = true;
      _lastAction = '캐시 삭제 중...';
      _errorMessage = null;
    });

    try {
      await LocalStorageService.clearAll();
      setState(() {
        _lastAction = '🗑️ 캐시 삭제 완료';
        _isLoading = false;
      });

      await _loadCacheStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('캐시가 삭제되었습니다'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = '캐시 삭제 실패: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('데이터 동기화 테스트'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 캐시 상태 카드
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '📊 캐시 상태',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              IconButton(
                                onPressed: _loadCacheStatus,
                                icon: const Icon(Icons.refresh),
                              ),
                            ],
                          ),
                          const Divider(),
                          if (_cacheStatus != null) ...[
                            _buildCacheInfo('직업', _cacheStatus!['jobs']),
                            const SizedBox(height: 16),
                            _buildCacheInfo('컨텐츠', _cacheStatus!['templates']),
                          ] else
                            const Text('캐시 정보 없음'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 마지막 작업 상태
                  if (_lastAction != null)
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _lastAction!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // 에러 메시지
                  if (_errorMessage != null)
                    Card(
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // 버튼들
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _syncAll,
                    icon: const Icon(Icons.sync),
                    label: const Text('전체 데이터 동기화 (직업 + 템플릿)'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _syncJobs,
                    icon: const Icon(Icons.work_outline),
                    label: const Text('직업 데이터만 동기화'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _syncTemplates,
                    icon: const Icon(Icons.dashboard_outlined),
                    label: const Text('컨텐츠 데이터만 동기화'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _clearCache,
                    icon: const Icon(Icons.delete_sweep),
                    label: const Text('캐시 삭제'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCacheInfo(String title, Map<String, dynamic> info) {
    final hasData = info['hasData'] as bool;
    final version = info['version'] as int;
    final count = info['count'] as int;
    final lastUpdated = info['lastUpdated'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              hasData ? Icons.check_circle : Icons.cancel,
              color: hasData ? Colors.green : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('버전: v$version'),
        Text('데이터 개수: $count개'),
        if (lastUpdated != null)
          Text(
            '마지막 업데이트: ${DateTime.parse(lastUpdated).toString().substring(0, 19)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
      ],
    );
  }
}
