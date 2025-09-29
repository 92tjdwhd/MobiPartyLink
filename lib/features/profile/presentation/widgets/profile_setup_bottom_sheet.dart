import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobi_party_link/core/services/profile_service.dart';
import 'package:mobi_party_link/features/profile/presentation/providers/profile_provider.dart';

class ProfileSetupBottomSheet extends ConsumerStatefulWidget {
  final VoidCallback? onProfileSaved;

  const ProfileSetupBottomSheet({
    super.key,
    this.onProfileSaved,
  });

  @override
  ConsumerState<ProfileSetupBottomSheet> createState() =>
      _ProfileSetupBottomSheetState();
}

class _ProfileSetupBottomSheetState
    extends ConsumerState<ProfileSetupBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _powerController = TextEditingController();

  String _selectedJob = '전사';
  bool _isLoading = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _powerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
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
            : Text(
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
    final String? selectedJob = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('직업 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            '전사',
            '수도사',
            '빙결술사',
            '대검전사',
            '검술사',
            '마법사',
            '화염술사',
            '전격술사',
            '궁수',
            '석궁사수',
            '장궁병',
            '음유시인',
            '댄서',
            '악사',
            '도적',
            '격투가',
            '듀얼블레이드',
            '힐러',
            '사제',
          ]
              .map((job) => ListTile(
                    title: Text(job),
                    onTap: () => Navigator.pop(context, job),
                  ))
              .toList(),
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
        final profile = UserProfile(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          nickname: _nicknameController.text.trim(),
          jobId: _selectedJob,
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
