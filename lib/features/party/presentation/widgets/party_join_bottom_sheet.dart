import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobi_party_link/features/party/domain/entities/party_entity.dart';
import 'package:mobi_party_link/features/party/presentation/widgets/party_card.dart';
import 'package:mobi_party_link/core/services/profile_service.dart';
import 'package:mobi_party_link/features/notification/presentation/providers/notification_provider.dart';
import 'package:mobi_party_link/features/notification/presentation/providers/notification_settings_provider.dart';

class PartyJoinBottomSheet extends ConsumerStatefulWidget {
  final PartyEntity party;
  final VoidCallback? onProfileSaved;

  const PartyJoinBottomSheet({
    super.key,
    required this.party,
    this.onProfileSaved,
  });

  @override
  ConsumerState<PartyJoinBottomSheet> createState() =>
      _PartyJoinBottomSheetState();
}

class _PartyJoinBottomSheetState extends ConsumerState<PartyJoinBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _powerController = TextEditingController();

  String _selectedJob = '전사';
  bool _saveProfile = false;
  bool _hasExistingProfile = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    final existingProfile = await ProfileService.getProfile();
    if (existingProfile != null) {
      setState(() {
        _nicknameController.text = existingProfile.nickname;
        _selectedJob = existingProfile.job;
        _powerController.text = existingProfile.power.toString();
        _hasExistingProfile = true;
        _saveProfile = false; // 기존 프로필이 있으면 저장 플래그 비활성화
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
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
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
        children: [
          _buildHandle(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildPartyCard(),
                    const SizedBox(height: 24),
                    _buildProfileSection(),
                    const SizedBox(height: 24),
                    if (!_hasExistingProfile) _buildSaveProfileSwitch(),
                    if (!_hasExistingProfile) const SizedBox(height: 24),
                    const SizedBox(height: 8),
                    _buildJoinButton(),
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
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      '파티 참여하기',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF000000),
      ),
    );
  }

  Widget _buildPartyCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: PartyCard(
        party: widget.party,
        onTap: null, // 참여 바텀시트에서는 클릭 비활성화
        onShare: null, // 공유 버튼 숨김
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '프로필 정보',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 16),
        _buildNicknameField(),
        const SizedBox(height: 16),
        _buildJobField(),
        const SizedBox(height: 16),
        _buildPowerField(),
      ],
    );
  }

  Widget _buildNicknameField() {
    final isRequired =
        widget.party.requireJob || (!_hasExistingProfile && _saveProfile);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '닉네임',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF000000),
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nicknameController,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            hintText: '닉네임을 입력하세요',
            hintStyle: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.6),
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
            fillColor: Theme.of(context).cardColor,
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '닉네임을 입력해주세요';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildJobField() {
    final isRequired =
        widget.party.requireJob || (!_hasExistingProfile && _saveProfile);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '직업',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF000000),
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
            ],
          ],
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
              color: Theme.of(context).cardColor,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedJob,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPowerField() {
    final isRequired =
        widget.party.requirePower || (!_hasExistingProfile && _saveProfile);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '투력',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF000000),
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _powerController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            hintText: '투력을 입력하세요',
            hintStyle: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.6),
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
            fillColor: Theme.of(context).cardColor,
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '투력을 입력해주세요';
                  }
                  final power = int.tryParse(value);
                  if (power == null) {
                    return '숫자를 입력해주세요';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildSaveProfileSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '프로필 저장하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '체크하면 모든 필드가 필수 입력됩니다',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _saveProfile,
            onChanged: (value) {
              setState(() {
                _saveProfile = value;
              });
            },
            activeColor: Colors.green,
            activeTrackColor: Colors.green.withOpacity(0.3),
            inactiveThumbColor: Theme.of(context).textTheme.bodyMedium?.color,
            inactiveTrackColor: Theme.of(context).dividerColor,
          ),
        ],
      ),
    );
  }

  Widget _buildJoinButton() {
    // 제한 체크
    final joinRestriction = _checkJoinRestrictions();
    final isDisabled = _isLoading || joinRestriction != null;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isDisabled ? null : _joinParty,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF76769A)
              : Theme.of(context).primaryColor,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.onPrimary),
                ),
              )
            : Text(
                joinRestriction != null ? '참여할 수 없습니다' : '파티 참여하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDisabled
                      ? Colors.grey[400]
                      : Theme.of(context).colorScheme.onPrimary,
                ),
              ),
      ),
    );
  }

  Future<void> _selectJob() async {
    final jobs = [
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
      '사제'
    ];

    final selectedJob = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('직업 선택'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return ListTile(
                title: Text(job),
                selected: job == _selectedJob,
                onTap: () => Navigator.pop(context, job),
              );
            },
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

  String? _checkJoinRestrictions() {
    // 1. 파티 인원수 체크
    if (widget.party.members.length >= widget.party.maxMembers) {
      return '파티 인원이 가득 찼습니다.';
    }

    // 2. 직업 제한 체크 (직업 제한이 활성화된 경우에만)
    if (widget.party.requireJobCategory) {
      final jobCounts = _getJobCategoryCounts();
      final selectedJobCategory = _getJobCategory(_selectedJob);

      switch (selectedJobCategory) {
        case 'tank':
          if (jobCounts['tank']! >= widget.party.tankLimit) {
            return '탱커 직업이 가득 찼습니다.';
          }
          break;
        case 'healer':
          if (jobCounts['healer']! >= widget.party.healerLimit) {
            return '힐러 직업이 가득 찼습니다.';
          }
          break;
        case 'dps':
          if (jobCounts['dps']! >= widget.party.dpsLimit) {
            return '딜러 직업이 가득 찼습니다.';
          }
          break;
      }
    }

    return null; // 제한 없음
  }

  Map<String, int> _getJobCategoryCounts() {
    final counts = <String, int>{
      'tank': 0,
      'healer': 0,
      'dps': 0,
    };

    for (final member in widget.party.members) {
      if (member.jobId != null) {
        final category = _getJobCategory(member.jobId!);
        if (counts.containsKey(category)) {
          counts[category] = counts[category]! + 1;
        }
      }
    }

    return counts;
  }

  String _getJobCategory(String jobId) {
    // 탱커 직업들
    if (['전사', '수도사', '빙결술사'].contains(jobId)) {
      return 'tank';
    }
    // 힐러 직업들
    if (['힐러', '사제'].contains(jobId)) {
      return 'healer';
    }
    // 딜러 직업들 (나머지)
    return 'dps';
  }

  Future<void> _joinParty() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 파티 참여 제한 체크
    final joinRestriction = _checkJoinRestrictions();
    if (joinRestriction != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(joinRestriction),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 기존 프로필이 없고 저장하기가 체크된 경우에만 프로필 저장
      if (!_hasExistingProfile && _saveProfile) {
        final profile = UserProfile(
          nickname: _nicknameController.text.trim(),
          job: _selectedJob,
          power: int.parse(_powerController.text),
          createdAt: DateTime.now(),
        );
        await ProfileService.saveProfile(profile);
      }

      // TODO: 파티 참여 로직 구현
      await Future.delayed(const Duration(seconds: 1)); // 임시 딜레이

      // 파티 참여 성공 시 알림 예약
      final notificationTime =
          await ref.read(notificationSettingsNotifierProvider);
      await ref
          .read(notificationNotifierProvider.notifier)
          .schedulePartyNotification(widget.party, notificationTime);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('파티에 성공적으로 참여했습니다!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
        // 프로필 저장 후 콜백 호출
        if (!_hasExistingProfile && _saveProfile) {
          widget.onProfileSaved?.call();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('파티 참여에 실패했습니다: $e'),
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
