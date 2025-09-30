import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobi_party_link/features/party/presentation/providers/party_creation_provider.dart';
import 'package:mobi_party_link/core/constants/party_templates.dart';
import 'package:mobi_party_link/core/services/profile_service.dart';
import 'package:mobi_party_link/features/profile/presentation/widgets/profile_setup_bottom_sheet.dart';
import 'package:mobi_party_link/features/party/presentation/providers/party_list_provider.dart';
import 'package:mobi_party_link/features/party/presentation/providers/party_template_provider.dart';

class PartyRecruitmentBottomSheet extends ConsumerStatefulWidget {
  const PartyRecruitmentBottomSheet({super.key});

  @override
  ConsumerState<PartyRecruitmentBottomSheet> createState() =>
      _PartyRecruitmentBottomSheetState();
}

class _PartyRecruitmentBottomSheetState
    extends ConsumerState<PartyRecruitmentBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _partyNameController = TextEditingController();
  final TextEditingController _minPowerController = TextEditingController();
  final TextEditingController _maxPowerController = TextEditingController();

  String _selectedCategory = '레이드';
  String _selectedDifficulty = '입문';
  String _selectedContentType = '아르카나 레이드';
  int _maxMembers = 6;
  DateTime _startTime = DateTime.now().add(const Duration(hours: 1));
  DateTime _endTime = DateTime.now().add(const Duration(hours: 2));
  bool _requirePower = true;
  bool _requireJob = true;
  bool _requireJobCategory = false;
  int _tankLimit = 0;
  int _healerLimit = 0;
  int _dpsLimit = 0;

  @override
  void dispose() {
    _partyNameController.dispose();
    _minPowerController.dispose();
    _maxPowerController.dispose();
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
                    _buildPartyNameField(),
                    const SizedBox(height: 20),
                    _buildContentTypeField(),
                    const SizedBox(height: 20),
                    _buildCategoryField(),
                    const SizedBox(height: 20),
                    _buildDifficultyField(),
                    const SizedBox(height: 20),
                    _buildDateTimeField(),
                    const SizedBox(height: 20),
                    _buildMembersField(),
                    const SizedBox(height: 20),
                    _buildCombatPowerToggle(),
                    if (_requirePower) ...[
                      const SizedBox(height: 16),
                      _buildPowerRangeFields(),
                    ],
                    const SizedBox(height: 20),
                    _buildJobSelectionToggle(),
                    const SizedBox(height: 20),
                    _buildJobCategoryToggle(),
                    if (_requireJobCategory) ...[
                      const SizedBox(height: 16),
                      _buildJobLimitFields(),
                    ],
                    const SizedBox(height: 30),
                    _buildCreateButton(),
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
            '파티 만들기',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          Spacer(),
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

  Widget _buildPartyNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '파티명',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _partyNameController,
          style: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.color), // 입력 텍스트 색상 테마 기반
          decoration: InputDecoration(
            hintText: '파티명을 입력하세요',
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
            fillColor: Theme.of(context).cardColor,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '파티명을 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '날짜/시간',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDateTime,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Text(
              _formatDateTime(_startTime),
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

  Widget _buildMembersField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '인원수',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectMembers,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Text(
              '$_maxMembers명',
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

  Widget _buildCombatPowerToggle() {
    return Row(
      children: [
        Expanded(
          child: Text(
            '전투력 입력 필수',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ),
        Switch(
          value: _requirePower,
          onChanged: (value) {
            setState(() {
              _requirePower = value;
            });
          },
          activeColor: Colors.green,
          activeThumbColor: Colors.green,
          activeTrackColor: Colors.green.withOpacity(0.3),
          inactiveThumbColor: Theme.of(context).textTheme.bodyMedium?.color,
          inactiveTrackColor: Theme.of(context).dividerColor,
        ),
      ],
    );
  }

  Widget _buildJobSelectionToggle() {
    return Row(
      children: [
        Expanded(
          child: Text(
            '직업 선택 필수',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ),
        Switch(
          value: _requireJob,
          onChanged: (value) {
            setState(() {
              _requireJob = value;
            });
          },
          activeColor: Theme.of(context).primaryColor,
          activeTrackColor: Theme.of(context).primaryColor.withOpacity(0.8),
          inactiveThumbColor: Theme.of(context).textTheme.bodyMedium?.color,
          inactiveTrackColor: Theme.of(context).dividerColor,
        ),
      ],
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '카테고리',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectCategory,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Text(
              _selectedCategory,
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

  Widget _buildDifficultyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '난이도',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDifficulty,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Text(
              _selectedDifficulty,
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

  Widget _buildContentTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '템플릿 선택',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectTemplate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Text(
              _selectedContentType,
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

  Widget _buildPowerRangeFields() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _minPowerController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '최소 투력',
              hintText: '1000',
              labelStyle: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color),
              hintStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color),
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
            style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.color), // 입력 텍스트 색상 테마 기반
            validator: (value) {
              if (_requirePower && (value == null || value.isEmpty)) {
                return '최소 투력을 입력해주세요';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: _maxPowerController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '최대 투력',
              hintText: '2000',
              labelStyle: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color),
              hintStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color),
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
            style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.color), // 입력 텍스트 색상 테마 기반
            validator: (value) {
              if (_requirePower && (value == null || value.isEmpty)) {
                return '최대 투력을 입력해주세요';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildJobCategoryToggle() {
    return Row(
      children: [
        Expanded(
          child: Text(
            '직업 제한',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ),
        Switch(
          value: _requireJobCategory,
          onChanged: (value) {
            setState(() {
              _requireJobCategory = value;
            });
          },
          activeColor: Theme.of(context).primaryColor,
          activeTrackColor: Theme.of(context).primaryColor.withOpacity(0.8),
          inactiveThumbColor: Theme.of(context).textTheme.bodyMedium?.color,
          inactiveTrackColor: Theme.of(context).dividerColor,
        ),
      ],
    );
  }

  Widget _buildJobLimitFields() {
    return Column(
      children: [
        _buildJobLimitField('탱커', _tankLimit, (value) {
          setState(() {
            _tankLimit = value;
          });
        }),
        const SizedBox(height: 12),
        _buildJobLimitField('힐러', _healerLimit, (value) {
          setState(() {
            _healerLimit = value;
          });
        }),
        const SizedBox(height: 12),
        _buildJobLimitField('딜러', _dpsLimit, (value) {
          setState(() {
            _dpsLimit = value;
          });
        }),
      ],
    );
  }

  Widget _buildJobLimitField(
      String jobCategory, int limit, ValueChanged<int> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Text(
            jobCategory,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ),
        Container(
          width: 120,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove, size: 20),
                onPressed: () {
                  if (limit > 0) onChanged(limit - 1);
                },
              ),
              Text(
                limit.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, size: 20),
                onPressed: () {
                  onChanged(limit + 1);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _createParty,
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
        child: Text(
          '파티 생성하기',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _createParty() async {
    if (_formKey.currentState!.validate()) {
      // 프로필 체크
      final hasProfile = await ProfileService.hasProfile();
      if (!hasProfile) {
        _showProfileSetupDialog();
        return;
      }

      try {
        await ref.read(partyCreationNotifierProvider.notifier).createParty(
              name: _partyNameController.text.trim(),
              startTime: _startTime,
              maxMembers: _maxMembers,
              contentType: _selectedContentType,
              category: _selectedCategory,
              difficulty: _selectedDifficulty,
              requireJob: _requireJob,
              requirePower: _requirePower,
              minPower: _requirePower
                  ? int.tryParse(_minPowerController.text) ?? 1000
                  : null,
              maxPower: _requirePower
                  ? int.tryParse(_maxPowerController.text) ?? 2000
                  : null,
              requireJobCategory: _requireJobCategory,
              tankLimit: _tankLimit,
              healerLimit: _healerLimit,
              dpsLimit: _dpsLimit,
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('파티가 성공적으로 생성되었습니다!'),
              backgroundColor: Colors.green,
            ),
          );
          // 파티 리스트 새로고침
          refreshPartyList(ref);
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('파티 생성에 실패했습니다: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showProfileSetupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('프로필 설정 필요'),
        content: Text('파티를 생성하기 전에 프로필을 설정해주세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showProfileSetupBottomSheet();
            },
            child: Text('프로필 설정'),
          ),
        ],
      ),
    );
  }

  void _showProfileSetupBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ProfileSetupBottomSheet(),
    ).then((_) {
      // 프로필 설정 완료 후 파티 생성 재시도
      _createParty();
    });
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startTime),
      );
      if (pickedTime != null) {
        setState(() {
          _startTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _selectMembers() async {
    final int? selectedMembers = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('인원수 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(7, (index) {
            final members = index + 2;
            return ListTile(
              title: Text('${members}명'),
              onTap: () => Navigator.pop(context, members),
            );
          }),
        ),
      ),
    );
    if (selectedMembers != null) {
      setState(() {
        _maxMembers = selectedMembers;
      });
    }
  }

  Future<void> _selectTemplate() async {
    // 로컬 저장소에서 템플릿 목록 가져오기
    final templates = await ref.read(localTemplatesProvider.future);

    if (!mounted) return;

    if (templates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('템플릿 데이터가 없습니다. 설정에서 데이터 동기화를 진행해주세요.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final template = await showDialog<dynamic>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('템플릿 선택'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final t = templates[index];
              return ListTile(
                title: Text('${t.name} (${t.difficulty})'),
                subtitle: Text(
                    '${t.category} • ${t.maxMembers}명 • 투력 ${t.minPower}-${t.maxPower}'),
                onTap: () => Navigator.pop(context, t),
              );
            },
          ),
        ),
      ),
    );

    if (template != null) {
      setState(() {
        _selectedContentType = '${template.name} (${template.difficulty})';
        _selectedCategory = template.category;
        _selectedDifficulty = template.difficulty;
        _maxMembers = template.maxMembers;
        _requireJob = template.requireJob;
        _requirePower = template.requirePower;
        _requireJobCategory = template.requireJobCategory ?? false;
        _tankLimit = template.tankLimit ?? 0;
        _healerLimit = template.healerLimit ?? 0;
        _dpsLimit = template.dpsLimit ?? 0;

        // 투력 필드에 기본값 설정
        if (_requirePower) {
          _minPowerController.text = template.minPower.toString();
          _maxPowerController.text = template.maxPower.toString();
        }
      });
    }
  }

  Future<void> _selectCategory() async {
    final String? selectedCategory = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('카테고리 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            '레이드',
            '던전',
            'PvP',
            '길드',
            '퀘스트',
            '이벤트',
            '연습',
            '소셜',
          ]
              .map((category) => ListTile(
                    title: Text(category),
                    onTap: () => Navigator.pop(context, category),
                  ))
              .toList(),
        ),
      ),
    );
    if (selectedCategory != null) {
      setState(() {
        _selectedCategory = selectedCategory;
      });
    }
  }

  Future<void> _selectDifficulty() async {
    final String? selectedDifficulty = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('난이도 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            '입문',
            '쉬움',
            '보통',
            '어려움',
            '매우어려움',
            '지옥1',
            '지옥2',
            '지옥3',
            '지옥4',
            '지옥5',
            '지옥6',
            '지옥7',
          ]
              .map((difficulty) => ListTile(
                    title: Text(difficulty),
                    onTap: () => Navigator.pop(context, difficulty),
                  ))
              .toList(),
        ),
      ),
    );
    if (selectedDifficulty != null) {
      setState(() {
        _selectedDifficulty = selectedDifficulty;
      });
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
