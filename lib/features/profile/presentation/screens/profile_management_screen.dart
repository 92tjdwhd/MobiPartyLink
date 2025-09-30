import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobi_party_link/features/profile/presentation/providers/profile_provider.dart';
import 'package:mobi_party_link/features/profile/presentation/widgets/profile_setup_bottom_sheet.dart';
import 'package:mobi_party_link/features/profile/presentation/widgets/profile_edit_bottom_sheet.dart';
import 'package:mobi_party_link/core/services/profile_service.dart';

class ProfileManagementScreen extends ConsumerStatefulWidget {
  const ProfileManagementScreen({super.key});

  @override
  ConsumerState<ProfileManagementScreen> createState() =>
      _ProfileManagementScreenState();
}

class _ProfileManagementScreenState
    extends ConsumerState<ProfileManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final profilesAsync = ref.watch(profileListProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          '프로필 관리',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleLarge?.color,
            letterSpacing: -0.5,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Theme.of(context).textTheme.titleLarge?.color,
            size: 20,
          ),
        ),
      ),
      body: profilesAsync.when(
        data: (profiles) {
          if (profiles.isEmpty) {
            return _buildEmptyState();
          }
          return _buildProfileList(profiles);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF76769A)
                    : Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.person_add_rounded,
                color: Colors.white,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '프로필이 없습니다',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '첫 번째 프로필을 만들어보세요',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _showAddProfileSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF76769A)
                    : Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '프로필 추가하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileList(List<UserProfile> profiles) {
    return Column(
      children: [
        // 헤더
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '프로필 목록 (${profiles.length}/3)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              if (profiles.length < 3)
                TextButton.icon(
                  onPressed: _showAddProfileSheet,
                  icon: Icon(
                    Icons.add_rounded,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  label: Text(
                    '추가',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // 프로필 리스트
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              return _buildProfileCard(profile, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(UserProfile profile, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF76769A)
                : Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.person_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Consumer(
          builder: (context, ref, child) {
            final mainProfileId = ref.watch(mainProfileIdProvider);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    profile.nickname ?? '프로필 ${index + 1}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ),
                if (mainProfileId.when(
                  data: (id) => id == profile.id,
                  loading: () => false,
                  error: (_, __) => false,
                ))
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '대표',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onPrimary,
                        height: 1.0,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        subtitle: Text(
          '${profile.job ?? '직업 미설정'} • ${profile.power ?? '파워 미설정'}',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        trailing: Consumer(
          builder: (context, ref, child) {
            final mainProfileId = ref.watch(mainProfileIdProvider);

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 대표 프로필 설정 버튼
                IconButton(
                  onPressed: () => _setMainProfile(profile),
                  icon: Icon(
                    mainProfileId.when(
                      data: (id) => id == profile.id
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      loading: () => Icons.star_outline_rounded,
                      error: (_, __) => Icons.star_outline_rounded,
                    ),
                    color: mainProfileId.when(
                      data: (id) => id == profile.id
                          ? Colors.amber
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      loading: () =>
                          Theme.of(context).textTheme.bodyMedium?.color,
                      error: (_, __) =>
                          Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    size: 20,
                  ),
                ),
                // 수정 버튼
                IconButton(
                  onPressed: () => _showEditProfileSheet(profile),
                  icon: Icon(
                    Icons.edit_rounded,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    size: 20,
                  ),
                ),
                // 삭제 버튼
                IconButton(
                  onPressed: () => _showDeleteConfirmDialog(profile),
                  icon: Icon(
                    Icons.delete_rounded,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                ),
              ],
            );
          },
        ),
        onTap: () => _showEditProfileSheet(profile),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              '오류가 발생했습니다',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '다시 시도해주세요',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(profileListProvider);
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProfileSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ProfileSetupBottomSheet(),
    );
  }

  void _setMainProfile(UserProfile profile) async {
    try {
      final success = await ProfileService.setMainProfile(profile.id);

      if (success) {
        // 프로필 새로고침
        refreshProfile(ref);

        // 성공 메시지 표시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${profile.nickname}을(를) 대표 프로필로 설정했습니다'),
              backgroundColor: Theme.of(context).primaryColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('대표 프로필 설정에 실패했습니다: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showEditProfileSheet(UserProfile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfileEditBottomSheet(profile: profile),
    );
  }

  void _showDeleteConfirmDialog(UserProfile profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          '프로필 삭제',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        content: Text(
          '${profile.nickname ?? '이 프로필'}을(를) 삭제하시겠습니까?',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '취소',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteProfile(profile);
            },
            child: Text(
              '삭제',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteProfile(UserProfile profile) async {
    try {
      final success = await ProfileService.deleteProfileFromList(profile.id);

      if (success) {
        // 프로필 새로고침
        refreshProfile(ref);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${profile.nickname ?? '프로필'}이 삭제되었습니다'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('프로필 삭제에 실패했습니다'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
