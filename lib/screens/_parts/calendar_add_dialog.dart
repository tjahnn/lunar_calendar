part of '../calendar_screen.dart';

// ──────────────────────────────────────────────
// _AddScheduleDialog
// ──────────────────────────────────────────────

class _AddScheduleDialog extends StatefulWidget {
  final DateTime selectedDate;
  final Schedule? initialSchedule;
  final void Function({
    required String title,
    String? description,
    bool isLunarDate,
    int? lunarMonth,
    int? lunarDay,
    bool isLeapMonth,
    String repeatType,
    int repeatInterval,
    String? alarmTime,
  })
  onSubmit;

  const _AddScheduleDialog({
    required this.selectedDate,
    required this.onSubmit,
    this.initialSchedule,
  });

  @override
  State<_AddScheduleDialog> createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends State<_AddScheduleDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _intervalController = TextEditingController(text: '1');
  bool _isLunarDate = false;
  String _repeatType = 'none';
  int _repeatInterval = 1;
  TimeOfDay? _alarmTime;

  late final int _lunarYear;
  late final int _lunarMonth;
  late final int _lunarDay;
  late final bool _isLeapMonth;
  late final String _gapja;

  static const _repeatUnits = [
    ('none', '없음'),
    ('daily', '일'),
    ('weekly', '주'),
    ('monthly', '월'),
    ('yearly', '년'),
  ];

  @override
  void initState() {
    super.initState();
    // 수정 모드: 기존 값으로 pre-fill
    if (widget.initialSchedule case final s?) {
      _titleController.text = s.title;
      _descController.text = s.description ?? '';
      _isLunarDate = s.isLunarDate;
      _repeatType = s.repeatType;
      _repeatInterval = s.repeatInterval;
      _intervalController.text = s.repeatInterval.toString();
      if (s.alarmTime != null) {
        final parts = s.alarmTime!.split(':');
        _alarmTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }
    klc.setSolarDate(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day);
    _lunarYear = klc.getLunarYear();
    _lunarMonth = klc.getLunarMonth();
    _lunarDay = klc.getLunarDay();
    _isLeapMonth = klc.isIntercalation;
    _gapja = klc.getGapjaString();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final desc = _descController.text.trim();
    widget.onSubmit(
      title: title,
      description: desc.isEmpty ? null : desc,
      isLunarDate: _isLunarDate,
      lunarMonth: _isLunarDate ? _lunarMonth : null,
      lunarDay: _isLunarDate ? _lunarDay : null,
      isLeapMonth: _isLunarDate ? _isLeapMonth : false,
      repeatType: _repeatType,
      repeatInterval: _repeatInterval,
      alarmTime: _alarmTime == null
          ? null
          : '${_alarmTime!.hour.toString().padLeft(2, '0')}:${_alarmTime!.minute.toString().padLeft(2, '0')}',
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final solarPreview =
        '${widget.selectedDate.year}년 ${widget.selectedDate.month}월 ${widget.selectedDate.day}일 (양력)';
    final lunarPreview =
        '음력 $_lunarYear년 ${_isLeapMonth ? '윤' : ''}$_lunarMonth월 $_lunarDay일  ·  $_gapja년';

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.initialSchedule == null ? '일정 추가' : '일정 수정',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: '제목',
                  hintText: '일정 이름을 입력하세요',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descController,
                maxLines: 3,
                minLines: 2,
                decoration: const InputDecoration(
                  labelText: '설명 (선택)',
                  hintText: '상세 내용을 입력하세요',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 16),
              Text('날짜 타입', style: theme.textTheme.labelMedium?.copyWith(color: Colors.black54)),
              const SizedBox(height: 6),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('양력'),
                    selected: !_isLunarDate,
                    onSelected: (_) => setState(() => _isLunarDate = false),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('음력'),
                    selected: _isLunarDate,
                    onSelected: (_) => setState(() => _isLunarDate = true),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _isLunarDate ? lunarPreview : solarPreview,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              Text('반복', style: theme.textTheme.labelMedium?.copyWith(color: Colors.black54)),
              const SizedBox(height: 6),
              Row(
                children: [
                  if (_repeatType != 'none') ...[
                    SizedBox(
                      width: 56,
                      child: TextField(
                        controller: _intervalController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        ),
                        onChanged: (v) {
                          final n = int.tryParse(v);
                          if (n != null && n > 0) {
                            setState(() => _repeatInterval = n);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _repeatType,
                      isDense: true,
                      items: _repeatUnits
                          .map((u) => DropdownMenuItem(value: u.$1, child: Text(u.$2)))
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() {
                          _repeatType = v;
                          if (v == 'none') {
                            _repeatInterval = 1;
                            _intervalController.text = '1';
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('알람', style: theme.textTheme.labelMedium?.copyWith(color: Colors.black54)),
              const SizedBox(height: 6),
              Row(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.alarm, size: 16),
                    label: Text(
                      _alarmTime == null ? '알람 없음' : _alarmTime!.format(context),
                    ),
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _alarmTime ?? TimeOfDay.now(),
                      );
                      if (picked != null) setState(() => _alarmTime = picked);
                    },
                  ),
                  if (_alarmTime != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => setState(() => _alarmTime = null),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _submit,
                    child: Text(widget.initialSchedule == null ? '추가' : '저장'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
