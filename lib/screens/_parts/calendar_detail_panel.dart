part of '../calendar_screen.dart';

// ──────────────────────────────────────────────
// _DateDetailPanel  (StatefulWidget — 자체 스트림 관리)
// ──────────────────────────────────────────────

class _DateDetailPanel extends StatefulWidget {
  final DateTime selectedDate;
  final AppDatabase db;

  const _DateDetailPanel({super.key, required this.selectedDate, required this.db});

  @override
  State<_DateDetailPanel> createState() => _DateDetailPanelState();
}

class _DateDetailPanelState extends State<_DateDetailPanel> {
  late final Stream<List<Schedule>> _schedulesStream;

  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  void initState() {
    super.initState();
    _schedulesStream = widget.db.watchSchedulesForDate(widget.selectedDate);
  }

  void _addSchedule({
    required String title,
    String? description,
    bool isLunarDate = false,
    int? lunarMonth,
    int? lunarDay,
    bool isLeapMonth = false,
    String repeatType = 'none',
    int repeatInterval = 1,
  }) => widget.db.addSchedule(
    widget.selectedDate,
    title,
    description: description,
    isLunarDate: isLunarDate,
    lunarMonth: lunarMonth,
    lunarDay: lunarDay,
    isLeapMonth: isLeapMonth,
    repeatType: repeatType,
    repeatInterval: repeatInterval,
  );

  void _deleteSchedule(int id) => widget.db.deleteSchedule(id);

  void _updateSchedule(
    int id, {
    required String title,
    String? description,
    bool isLunarDate = false,
    int? lunarMonth,
    int? lunarDay,
    bool isLeapMonth = false,
    String repeatType = 'none',
    int repeatInterval = 1,
  }) => widget.db.updateSchedule(
    id,
    title: title,
    description: description,
    isLunarDate: isLunarDate,
    lunarMonth: lunarMonth,
    lunarDay: lunarDay,
    isLeapMonth: isLeapMonth,
    repeatType: repeatType,
    repeatInterval: repeatInterval,
  );

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _AddScheduleDialog(
        selectedDate: widget.selectedDate,
        onSubmit:
            ({
              required String title,
              String? description,
              bool isLunarDate = false,
              int? lunarMonth,
              int? lunarDay,
              bool isLeapMonth = false,
              String repeatType = 'none',
              int repeatInterval = 1,
            }) => _addSchedule(
              title: title,
              description: description,
              isLunarDate: isLunarDate,
              lunarMonth: lunarMonth,
              lunarDay: lunarDay,
              isLeapMonth: isLeapMonth,
              repeatType: repeatType,
              repeatInterval: repeatInterval,
            ),
      ),
    );
  }

  void _showEditDialog(Schedule s) {
    showDialog(
      context: context,
      builder: (ctx) => _AddScheduleDialog(
        selectedDate: s.date,
        initialSchedule: s,
        onSubmit:
            ({
              required String title,
              String? description,
              bool isLunarDate = false,
              int? lunarMonth,
              int? lunarDay,
              bool isLeapMonth = false,
              String repeatType = 'none',
              int repeatInterval = 1,
            }) => _updateSchedule(
              s.id,
              title: title,
              description: description,
              isLunarDate: isLunarDate,
              lunarMonth: lunarMonth,
              lunarDay: lunarDay,
              isLeapMonth: isLeapMonth,
              repeatType: repeatType,
              repeatInterval: repeatInterval,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    klc.setSolarDate(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day);
    final lunarYear = klc.getLunarYear();
    final lunarMonth = klc.getLunarMonth();
    final lunarDay = klc.getLunarDay();
    final isLeap = klc.isIntercalation;
    final gapja = klc.getGapjaString();

    final weekdayStr = _weekdays[widget.selectedDate.weekday - 1];
    final solarStr =
        '${widget.selectedDate.year}년 ${widget.selectedDate.month}월 '
        '${widget.selectedDate.day}일 ($weekdayStr요일)';
    final lunarStr = '음력 $lunarYear년 ${isLeap ? '윤' : ''}$lunarMonth월 $lunarDay일  ·  $gapja년';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.grey.shade50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                solarStr,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 3),
              Text(lunarStr, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 2),
          child: Row(
            children: [
              const Text('일정', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton.icon(
                onPressed: _showAddDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('추가'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  foregroundColor: Colors.red.shade400,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 0.5),
        Expanded(
          child: StreamBuilder<List<Schedule>>(
            stream: _schedulesStream,
            builder: (context, snapshot) {
              final schedules = snapshot.data ?? const [];
              if (schedules.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event_note_outlined, size: 36, color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      Text(
                        '등록된 일정이 없습니다',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: schedules.length,
                separatorBuilder: (_, _) => const Divider(height: 1, thickness: 0.5, indent: 16),
                itemBuilder: (context, index) {
                  final s = schedules[index];
                  return ListTile(
                    dense: true,
                    leading: Icon(Icons.circle, size: 7, color: Colors.red.shade400),
                    title: Row(
                      children: [
                        if (s.isLunarDate)
                          Container(
                            margin: const EdgeInsets.only(right: 5),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Text(
                              '음',
                              style: TextStyle(fontSize: 9, color: Colors.blue.shade700),
                            ),
                          ),
                        Expanded(child: Text(s.title, style: const TextStyle(fontSize: 14))),
                      ],
                    ),
                    subtitle: s.description != null
                        ? Text(
                            s.description!,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (s.repeatType != 'none')
                          Padding(
                            padding: const EdgeInsets.only(right: 2),
                            child: Icon(Icons.repeat, size: 14, color: Colors.orange.shade400),
                          ),
                        IconButton(
                          icon: Icon(Icons.edit_outlined, size: 18, color: Colors.grey.shade400),
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _showEditDialog(s),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, size: 18, color: Colors.grey.shade400),
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _deleteSchedule(s.id),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// _EmptyDetailState
// ──────────────────────────────────────────────

class _EmptyDetailState extends StatelessWidget {
  const _EmptyDetailState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app_outlined, size: 40, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text(
            '날짜를 선택하면 상세 정보가 표시됩니다',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
