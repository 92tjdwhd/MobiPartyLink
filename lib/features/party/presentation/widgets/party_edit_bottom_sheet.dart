import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobi_party_link/features/party/domain/entities/party_entity.dart';
import 'package:mobi_party_link/features/party/presentation/providers/party_edit_provider.dart';
import 'package:mobi_party_link/core/constants/party_templates.dart';
import 'package:mobi_party_link/core/constants/party_constants.dart';

class PartyEditBottomSheet extends ConsumerStatefulWidget {
  final PartyEntity party;

  const PartyEditBottomSheet({
    super.key,
    required this.party,
  });

  @override
  ConsumerState<PartyEditBottomSheet> createState() =>
      _PartyEditBottomSheetState();
}

class _PartyEditBottomSheetState extends ConsumerState<PartyEditBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _partyNameController = TextEditingController();
  final TextEditingController _minPowerController = TextEditingController();
  final TextEditingController _maxPowerController = TextEditingController();

  String _selectedContentType = '';
  String _selectedCategory = '';
  String _selectedDifficulty = '';
  int _maxMembers = 4;
  DateTime _startTime = DateTime.now();
  bool _requireJob = false;
  bool _requirePower = false;
  bool _requireJobCategory = false;
  int _tankLimit = 0;
  int _healerLimit = 0;
  int _dpsLimit = 0;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _partyNameController.text = widget.party.name;
    _selectedContentType = widget.party.contentType;
    _selectedCategory = widget.party.category;
    _selectedDifficulty = widget.party.difficulty;
    _maxMembers = widget.party.maxMembers;
    _startTime = widget.party.startTime;
    _requireJob = widget.party.requireJob;
    _requirePower = widget.party.requirePower;
    _requireJobCategory = widget.party.requireJobCategory;
    _tankLimit = widget.party.tankLimit;
    _healerLimit = widget.party.healerLimit;
    _dpsLimit = widget.party.dpsLimit;

    if (widget.party.minPower != null) {
      _minPowerController.text = widget.party.minPower.toString();
    }
    if (widget.party.maxPower != null) {
      _maxPowerController.text = widget.party.maxPower.toString();
    }
  }

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
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, -2),
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
              padding: const EdgeInsets.all(20),
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
                    _buildMaxMembersField(),
                    const SizedBox(height: 20),
                    _buildPowerRequirementSection(),
                    const SizedBox(height: 20),
                    _buildJobRequirementSection(),
                    const SizedBox(height: 20),
                    _buildJobLimitSection(),
                    const SizedBox(height: 30),
                    _buildUpdateButton(),
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
      height: 5,
      width: 40,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[600]
            : Colors.grey[300],
        borderRadius: BorderRadius.circular(2.5),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '파티 수정',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            onPressed: () => Navigator.pop(context),
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
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _partyNameController,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            hintText: '파티명을 입력하세요',
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
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
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

  Widget _buildContentTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '템플릿 선택',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _showTemplateDialog,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).cardColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedContentType.isEmpty
                      ? '템플릿을 선택하세요'
                      : _selectedContentType,
                  style: TextStyle(
                    fontSize: 14,
                    color: _selectedContentType.isEmpty
                        ? Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.6)
                        : Theme.of(context).textTheme.bodyLarge?.color,
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

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '카테고리',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategory.isEmpty ? null : _selectedCategory,
          decoration: InputDecoration(
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
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          items: PartyConstants.categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCategory = newValue;
              });
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '카테고리를 선택해주세요';
            }
            return null;
          },
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
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedDifficulty.isEmpty ? null : _selectedDifficulty,
          decoration: InputDecoration(
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
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          items: PartyConstants.difficulties.map((String difficulty) {
            return DropdownMenuItem<String>(
              value: difficulty,
              child: Text(difficulty),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedDifficulty = newValue;
              });
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '난이도를 선택해주세요';
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
          '시작 날짜/시간',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
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
              color: Theme.of(context).cardColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_startTime.year}.${_startTime.month.toString().padLeft(2, '0')}.${_startTime.day.toString().padLeft(2, '0')} ${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Icon(
                  Icons.access_time,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaxMembersField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '최대 인원수',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _maxMembers,
          decoration: InputDecoration(
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
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          items: List.generate(8, (index) => index + 1).map((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text('$value명'),
            );
          }).toList(),
          onChanged: (int? newValue) {
            if (newValue != null) {
              setState(() {
                _maxMembers = newValue;
              });
            }
          },
          validator: (value) {
            if (value == null) {
              return '최대 인원수를 선택해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPowerRequirementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '투력 요구사항',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleMedium?.color,
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
              activeTrackColor: Colors.green.withOpacity(0.3),
              inactiveThumbColor: Theme.of(context).textTheme.bodyMedium?.color,
              inactiveTrackColor: Theme.of(context).dividerColor,
            ),
          ],
        ),
        if (_requirePower) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _minPowerController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                  decoration: InputDecoration(
                    labelText: '최소 투력',
                    hintText: '1000',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor, width: 1),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _maxPowerController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                  decoration: InputDecoration(
                    labelText: '최대 투력',
                    hintText: '2000',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor, width: 1),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildJobRequirementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '직업 선택 필수',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            Switch(
              value: _requireJob,
              onChanged: (value) {
                setState(() {
                  _requireJob = value;
                });
              },
              activeColor: Colors.green,
              activeTrackColor: Colors.green.withOpacity(0.3),
              inactiveThumbColor: Theme.of(context).textTheme.bodyMedium?.color,
              inactiveTrackColor: Theme.of(context).dividerColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildJobLimitSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '직업 제한',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            Switch(
              value: _requireJobCategory,
              onChanged: (value) {
                setState(() {
                  _requireJobCategory = value;
                });
              },
              activeColor: Colors.green,
              activeTrackColor: Colors.green.withOpacity(0.3),
              inactiveThumbColor: Theme.of(context).textTheme.bodyMedium?.color,
              inactiveTrackColor: Theme.of(context).dividerColor,
            ),
          ],
        ),
        if (_requireJobCategory) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildJobLimitField('탱커', _tankLimit, (value) {
                  setState(() {
                    _tankLimit = value;
                  });
                }),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildJobLimitField('힐러', _healerLimit, (value) {
                  setState(() {
                    _healerLimit = value;
                  });
                }),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildJobLimitField('딜러', _dpsLimit, (value) {
                  setState(() {
                    _dpsLimit = value;
                  });
                }),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildJobLimitField(String label, int value, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: value,
          decoration: InputDecoration(
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
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          items: List.generate(5, (index) => index).map((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text('$value'),
            );
          }).toList(),
          onChanged: (int? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _updateParty,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF76769A)
              : Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          '파티 수정하기',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  void _showTemplateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('템플릿 선택'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: PartyTemplates.templates.length,
            itemBuilder: (context, index) {
              final template = PartyTemplates.templates[index];
              return ListTile(
                title: Text(template['name']),
                subtitle: Text(
                    '${template['category']} • ${template['difficulty']} • ${template['maxMembers']}인'),
                onTap: () {
                  setState(() {
                    _selectedContentType = template['name'];
                    _selectedCategory = template['category'];
                    _selectedDifficulty = template['difficulty'];
                    _maxMembers = template['maxMembers'];
                    _requireJob = template['requireJob'];
                    _requirePower = template['requirePower'];
                    _requireJobCategory = template['requireJobCategory'];
                    _tankLimit = template['tankLimit'];
                    _healerLimit = template['healerLimit'];
                    _dpsLimit = template['dpsLimit'];
                    _minPowerController.text =
                        template['minPower']?.toString() ?? '';
                    _maxPowerController.text =
                        template['maxPower']?.toString() ?? '';
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startTime),
      );

      if (time != null) {
        setState(() {
          _startTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _updateParty() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref.read(partyEditNotifierProvider.notifier).editParty(
              partyId: widget.party.id,
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
              content: Text('파티가 성공적으로 수정되었습니다!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('파티 수정에 실패했습니다: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
