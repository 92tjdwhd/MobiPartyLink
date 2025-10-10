import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobi_party_link/core/services/profile_service.dart';
import 'package:mobi_party_link/features/profile/presentation/providers/profile_provider.dart';
import 'package:mobi_party_link/features/party/presentation/providers/job_provider.dart';

class ProfileSetupBottomSheet extends ConsumerStatefulWidget {

  const ProfileSetupBottomSheet({
    super.key,
    this.onProfileSaved,
  });
  final VoidCallback? onProfileSaved;

  @override
  ConsumerState<ProfileSetupBottomSheet> createState() =>
      _ProfileSetupBottomSheetState();
}

class _ProfileSetupBottomSheetState
    extends ConsumerState<ProfileSetupBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _powerController = TextEditingController();

  String _selectedJob = '전사'; // 기본값
  bool _isLoading = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _powerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNicknameField(),
                    const SizedBox(height: 20),
                    _buildJobField(),
                    const SizedBox(height: 20),
                    _buildPowerField(),
                    const SizedBox(height: 30),
                    _buildSaveButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 0),
      child: Row(
        children: [
          Text(
            '프로필 설정',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNicknameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '닉네임',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nicknameController,
          style:
              TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
          decoration: InputDecoration(
            hintText: '닉네임을 입력하세요',
            hintStyle: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColor, width: 1),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '닉네임을 입력해주세요';
            }
            if (value.length < 2) {
              return '닉네임은 2자 이상 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildJobField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '직업',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectJob,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Text(
              _selectedJob,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPowerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '투력',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _powerController,
          keyboardType: TextInputType.number,
          style:
              TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
          decoration: InputDecoration(
            hintText: '투력을 입력하세요',
            hintStyle: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColor, width: 1),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '투력을 입력해주세요';
            }
            final power = int.tryParse(value);
            if (power == null || power < 0) {
              return '올바른 투력을 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF76769A)
              : Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '프로필 저장',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
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
          height: 400, // 고정 높이 설정
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

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // 직업 이름 → 직업 ID 변환
        final jobId = await ref.read(jobNameToIdProvider(_selectedJob).future);

        final profile = UserProfile(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          nickname: _nicknameController.text.trim(),
          jobId: jobId, // 직업 ID 저장 (예: "varechar")
          power: int.parse(_powerController.text.trim()),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // 프로필 리스트에 추가
        final success = await ProfileService.addProfileToList(profile);

        if (success) {
          // 프로필 새로고침
          refreshProfile(ref);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('프로필이 저장되었습니다!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
            // 프로필 저장 후 콜백 호출
            widget.onProfileSaved?.call();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('프로필은 최대 3개까지 저장할 수 있습니다.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('프로필 저장에 실패했습니다: $e'),
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
