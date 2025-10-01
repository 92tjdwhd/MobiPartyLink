import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobi_party_link/core/services/profile_service.dart';
import 'package:mobi_party_link/features/profile/presentation/providers/profile_provider.dart';
import 'package:mobi_party_link/features/party/presentation/providers/job_provider.dart';

class ProfileEditBottomSheet extends ConsumerStatefulWidget {
  final UserProfile profile;

  const ProfileEditBottomSheet({
    super.key,
    required this.profile,
  });

  @override
  ConsumerState<ProfileEditBottomSheet> createState() =>
      _ProfileEditBottomSheetState();
}

class _ProfileEditBottomSheetState
    extends ConsumerState<ProfileEditBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _powerController = TextEditingController();

  String? _selectedJob;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  Future<void> _initializeFields() async {
    _nicknameController.text = widget.profile.nickname ?? '';
    _powerController.text = widget.profile.power?.toString() ?? '';

    // 직업 ID → 직업 이름 변환 (UI 표시용)
    if (widget.profile.jobId != null) {
      final jobName =
          await ref.read(jobIdToNameProvider(widget.profile.jobId!).future);
      setState(() {
        _selectedJob = jobName ?? widget.profile.jobId; // null이면 ID 그대로 표시
      });
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _powerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 핸들
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[600]
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 헤더
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  '프로필 수정',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 폼
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 닉네임
                    _buildTextField(
                      controller: _nicknameController,
                      label: '닉네임',
                      hint: '닉네임을 입력하세요',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '닉네임을 입력해주세요';
                        }
                        if (value.trim().length < 2 ||
                            value.trim().length > 10) {
                          return '닉네임은 2~10자 사이여야 합니다';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // 직업 선택
                    Text(
                      '직업',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectJob,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Theme.of(context).dividerColor),
                          borderRadius: BorderRadius.circular(12),
                          color: Theme.of(context).cardColor,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedJob ?? '직업을 선택하세요',
                              style: TextStyle(
                                fontSize: 14,
                                color: _selectedJob != null
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color
                                    : Theme.of(context).hintColor,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 파워
                    _buildTextField(
                      controller: _powerController,
                      label: '파워',
                      hint: '파워를 입력하세요',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '파워를 입력해주세요';
                        }
                        final power = int.tryParse(value.trim());
                        if (power == null) {
                          return '올바른 숫자를 입력해주세요';
                        }
                        if (power < 0 || power > 1000000) {
                          return '파워는 0~1,000,000 사이여야 합니다';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          // 버튼
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF76769A)
                          : Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        '수정하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.6),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
          ),
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          validator: validator,
        ),
      ],
    );
  }

  Future<void> _selectJob() async {
    // 로컬 저장소에서 직업 목록 가져오기
    final jobNames = await ref.read(jobNamesProvider.future);

    if (jobNames.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('직업 데이터가 없습니다. 설정에서 데이터 동기화를 진행해주세요.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final String? selectedJob = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('직업 선택'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: jobNames
                  .map((job) => ListTile(
                        title: Text(job),
                        onTap: () => Navigator.pop(context, job),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );

    if (selectedJob != null) {
      setState(() {
        _selectedJob = selectedJob;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedJob == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('직업을 선택해주세요'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // 직업 이름 → 직업 ID 변환
        final jobId = await ref.read(jobNameToIdProvider(_selectedJob!).future);

        // 업데이트된 프로필 객체 생성
        final updatedProfile = widget.profile.copyWith(
          nickname: _nicknameController.text.trim(),
          jobId: jobId, // 직업 ID 저장 (예: "varechar")
          power: int.parse(_powerController.text.trim()),
          updatedAt: DateTime.now(),
        );

        // 프로필 업데이트
        final success =
            await ProfileService.updateProfileInList(updatedProfile);

        if (success) {
          // 프로필 새로고침
          refreshProfile(ref);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('프로필이 수정되었습니다!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('프로필 수정에 실패했습니다'),
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
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
