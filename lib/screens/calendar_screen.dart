import 'package:flutter/material.dart';
import 'package:klc/klc.dart' as klc;
import '../database/app_database.dart';

enum CalendarMode { solar, lunar }

class _CalendarDay {
  final DateTime solarDate;
  final int lunarMonth;
  final int lunarDay;
  final bool isLeapMonth;
  final bool isCurrentMonth;

  const _CalendarDay({
    required this.solarDate,
    required this.lunarMonth,
    required this.lunarDay,
    required this.isLeapMonth,
    required this.isCurrentMonth,
  });
}

// ──────────────────────────────────────────────
// CalendarScreen
// ──────────────────────────────────────────────

class CalendarScreen extends StatefulWidget {
  final AppDatabase db;

  const CalendarScreen({super.key, required this.db});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedMonth;
  CalendarMode _mode = CalendarMode.solar;
  final DateTime _today = DateTime.now();
  DateTime? _selectedDate;

  // 1 = 다음 달(위 스와이프), -1 = 이전 달(아래 스와이프)
  int _slideDir = 1;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(_today.year, _today.month);
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _goPrev() => setState(() {
    _slideDir = -1;
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
  });

  void _goNext() => setState(() {
    _slideDir = 1;
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
  });

  void _goToday() {
    final target = DateTime(_today.year, _today.month);
    final alreadyHere = _focusedMonth.year == target.year && _focusedMonth.month == target.month;
    if (alreadyHere) return;
    setState(() {
      _slideDir = _focusedMonth.isBefore(target) ? 1 : -1;
      _focusedMonth = target;
    });
  }

  void _onDaySelected(DateTime date) {
    setState(() {
      final newMonth = DateTime(date.year, date.month);
      final sameMonth =
          _focusedMonth.year == newMonth.year && _focusedMonth.month == newMonth.month;
      if (!sameMonth) {
        _slideDir = _focusedMonth.isBefore(newMonth) ? 1 : -1;
        _focusedMonth = newMonth;
      }
      _selectedDate = (_selectedDate != null && _sameDay(_selectedDate!, date)) ? null : date;
    });
  }

  // 슬라이드 트랜지션: 진입 위젯은 아래/위에서 들어오고, 이탈 위젯은 위/아래로 나감
  Widget _transitionBuilder(Widget child, Animation<double> animation) {
    final isEntering = child.key == ValueKey(_focusedMonth);
    if (isEntering) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, _slideDir > 0 ? 1.0 : -1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      );
    }
    // animation이 1→0으로 역방향이므로 이탈 방향을 자연스럽게 처리
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset.zero,
        end: Offset(0, _slideDir > 0 ? -1.0 : 1.0),
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn)),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: IconButton(
          icon: const Icon(Icons.today, color: Colors.black87),
          tooltip: '오늘',
          onPressed: _goToday,
        ),
        actions: [_ModeToggle(mode: _mode, onChanged: (m) => setState(() => _mode = m))],
      ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border(top: BorderSide(color: Colors.grey.shade300, width: 0.5)),
        ),
        alignment: Alignment.center,
        child: Text(
          'AD',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade400, letterSpacing: 1.5),
        ),
      ),
      body: Column(
        children: [
          // ── 달력 영역 (스와이프 감지 + 슬라이드 애니메이션) ──
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragEnd: (details) {
              final v = details.primaryVelocity ?? 0;
              if (v < -200) {
                _goNext();
              } else if (v > 200) {
                _goPrev();
              }
            },
            child: ClipRect(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: _transitionBuilder,
                layoutBuilder: (current, previous) =>
                    Stack(alignment: Alignment.topLeft, children: [...previous, ?current]),
                child: _CalendarMonthView(
                  key: ValueKey(_focusedMonth),
                  month: _focusedMonth,
                  db: widget.db,
                  mode: _mode,
                  today: _today,
                  selectedDate: _selectedDate,
                  onDaySelected: _onDaySelected,
                ),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          // ── 날짜 상세 / 일정 영역 ──
          Expanded(
            child: _selectedDate != null
                ? _DateDetailPanel(
                    key: ValueKey(_selectedDate!.toIso8601String()),
                    selectedDate: _selectedDate!,
                    db: widget.db,
                  )
                : const _EmptyDetailState(),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// _CalendarMonthView  — 월별 달력 뷰 (자체 스트림 관리)
// AnimatedSwitcher가 애니메이션 중 두 인스턴스를 유지하므로
// 각 인스턴스가 자신의 스트림을 보유해야 스트림 혼선을 방지할 수 있음
// ──────────────────────────────────────────────

class _CalendarMonthView extends StatefulWidget {
  final DateTime month;
  final AppDatabase db;
  final CalendarMode mode;
  final DateTime today;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDaySelected;

  const _CalendarMonthView({
    super.key,
    required this.month,
    required this.db,
    required this.mode,
    required this.today,
    required this.selectedDate,
    required this.onDaySelected,
  });

  @override
  State<_CalendarMonthView> createState() => _CalendarMonthViewState();
}

class _CalendarMonthViewState extends State<_CalendarMonthView> {
  late final Stream<Set<DateTime>> _scheduledDatesStream;
  late final List<_CalendarDay> _days;

  @override
  void initState() {
    super.initState();
    _scheduledDatesStream = widget.db.watchScheduledDatesInMonth(
      widget.month.year,
      widget.month.month,
    );
    _days = _buildDays();
  }

  List<_CalendarDay> _buildDays() {
    final year = widget.month.year;
    final month = widget.month.month;
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startOffset = firstDay.weekday % 7;

    final days = <_CalendarDay>[];
    for (int i = startOffset; i > 0; i--) {
      days.add(_toCalendarDay(firstDay.subtract(Duration(days: i)), false));
    }
    for (int d = 1; d <= daysInMonth; d++) {
      days.add(_toCalendarDay(DateTime(year, month, d), true));
    }
    int next = 1;
    while (days.length < 42) {
      days.add(_toCalendarDay(DateTime(year, month + 1, next++), false));
    }
    return days;
  }

  static _CalendarDay _toCalendarDay(DateTime date, bool isCurrentMonth) {
    klc.setSolarDate(date.year, date.month, date.day);
    return _CalendarDay(
      solarDate: date,
      lunarMonth: klc.getLunarMonth(),
      lunarDay: klc.getLunarDay(),
      isLeapMonth: klc.isIntercalation,
      isCurrentMonth: isCurrentMonth,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MonthHeader(focusedMonth: widget.month, mode: widget.mode),
        const _WeekdayHeader(),
        const Divider(height: 1, thickness: 0.5),
        StreamBuilder<Set<DateTime>>(
          stream: _scheduledDatesStream,
          builder: (context, snapshot) {
            return _CalendarGrid(
              days: _days,
              mode: widget.mode,
              today: widget.today,
              selectedDate: widget.selectedDate,
              scheduledDates: snapshot.data ?? const {},
              onDaySelected: widget.onDaySelected,
            );
          },
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// _MonthHeader
// ──────────────────────────────────────────────

class _MonthHeader extends StatelessWidget {
  final DateTime focusedMonth;
  final CalendarMode mode;

  const _MonthHeader({required this.focusedMonth, required this.mode});

  @override
  Widget build(BuildContext context) {
    String title;
    if (mode == CalendarMode.solar) {
      title = '${focusedMonth.year}년 ${focusedMonth.month}월';
    } else {
      klc.setSolarDate(focusedMonth.year, focusedMonth.month, 15);
      final leapPrefix = klc.isIntercalation ? '윤' : '';
      title = '${klc.getLunarYear()}년 $leapPrefix${klc.getLunarMonth()}월 (음력)';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// _WeekdayHeader
// ──────────────────────────────────────────────

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  static const _labels = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: _labels.asMap().entries.map((e) {
          final color = e.key == 0
              ? Colors.red.shade400
              : e.key == 6
              ? Colors.blue.shade400
              : Colors.black54;
          return Expanded(
            child: Center(
              child: Text(
                e.value,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// _CalendarGrid
// ──────────────────────────────────────────────

class _CalendarGrid extends StatelessWidget {
  final List<_CalendarDay> days;
  final CalendarMode mode;
  final DateTime today;
  final DateTime? selectedDate;
  final Set<DateTime> scheduledDates;
  final ValueChanged<DateTime> onDaySelected;

  const _CalendarGrid({
    required this.days,
    required this.mode,
    required this.today,
    required this.selectedDate,
    required this.scheduledDates,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final isSelected =
            selectedDate != null &&
            selectedDate!.year == day.solarDate.year &&
            selectedDate!.month == day.solarDate.month &&
            selectedDate!.day == day.solarDate.day;
        final normalized = DateTime(day.solarDate.year, day.solarDate.month, day.solarDate.day);
        return _DayCell(
          day: day,
          mode: mode,
          today: today,
          isSelected: isSelected,
          hasSchedule: scheduledDates.contains(normalized),
          columnIndex: index % 7,
          onTap: () => onDaySelected(day.solarDate),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────
// _DayCell
// ──────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final _CalendarDay day;
  final CalendarMode mode;
  final DateTime today;
  final bool isSelected;
  final bool hasSchedule;
  final int columnIndex;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.mode,
    required this.today,
    required this.isSelected,
    required this.hasSchedule,
    required this.columnIndex,
    required this.onTap,
  });

  bool get _isToday =>
      day.solarDate.year == today.year &&
      day.solarDate.month == today.month &&
      day.solarDate.day == today.day;

  Color _primaryTextColor(BuildContext context) {
    if (isSelected || _isToday) return Colors.white;
    if (!day.isCurrentMonth) return Colors.grey.shade400;
    if (columnIndex == 0) return Colors.red.shade500;
    if (columnIndex == 6) return Colors.blue.shade500;
    return Colors.black87;
  }

  String get _primaryLabel => '${mode == CalendarMode.solar ? day.solarDate.day : day.lunarDay}';

  // 양력 모드: 음력 날짜 표시, 음력 1일엔 달 이름 (윤달 포함)
  // 음력 모드: 양력 날짜 표시, 음력 1일엔 달 이름 (윤달 포함) — 달 경계 식별용
  String get _secondaryLabel {
    if (mode == CalendarMode.solar) {
      return day.lunarDay == 1
          ? '${day.isLeapMonth ? '윤' : ''}${day.lunarMonth}월'
          : '${day.lunarDay}';
    } else {
      return day.lunarDay == 1
          ? '${day.isLeapMonth ? '윤' : ''}${day.lunarMonth}월'
          : '${day.solarDate.day}';
    }
  }

  // 윤달 1일: teal  /  일반 1일: indigo  /  나머지: grey
  Color _secondaryLabelColor(BuildContext context) {
    if (!day.isCurrentMonth) return Colors.grey.shade300;
    if (day.lunarDay == 1) {
      return day.isLeapMonth ? Colors.teal.shade400 : Colors.indigo.shade300;
    }
    return Colors.grey.shade500;
  }

  @override
  Widget build(BuildContext context) {
    final Color? circleColor = isSelected
        ? Colors.red.shade500
        : _isToday
        ? Theme.of(context).colorScheme.primary
        : null;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: circleColor != null
                ? BoxDecoration(color: circleColor, shape: BoxShape.circle)
                : null,
            alignment: Alignment.center,
            child: Text(
              _primaryLabel,
              style: TextStyle(
                fontSize: 16,
                fontWeight: (isSelected || _isToday) ? FontWeight.bold : FontWeight.w600,
                color: _primaryTextColor(context),
              ),
            ),
          ),
          Text(
            _secondaryLabel,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _secondaryLabelColor(context)),
          ),
          SizedBox(
            height: 6,
            child: hasSchedule
                ? Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(color: Colors.red.shade400, shape: BoxShape.circle),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// _ModeToggle  (☀️ / 🌙 단일 아이콘 토글)
// ──────────────────────────────────────────────

class _ModeToggle extends StatelessWidget {
  final CalendarMode mode;
  final ValueChanged<CalendarMode> onChanged;

  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isLunar = mode == CalendarMode.lunar;
    return IconButton(
      tooltip: isLunar ? '양력으로 전환' : '음력으로 전환',
      onPressed: () => onChanged(isLunar ? CalendarMode.solar : CalendarMode.lunar),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Icon(
          isLunar ? Icons.nightlight_round : Icons.wb_sunny,
          key: ValueKey(mode),
          color: Colors.black87,
          size: 24,
        ),
      ),
    );
  }
}

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

  void _addSchedule(String title) => widget.db.addSchedule(widget.selectedDate, title);

  void _deleteSchedule(int id) => widget.db.deleteSchedule(id);

  void _showAddDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('일정 추가'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(hintText: '일정 내용을 입력하세요', border: OutlineInputBorder()),
          onSubmitted: (v) {
            if (v.trim().isNotEmpty) {
              _addSchedule(v.trim());
              Navigator.pop(ctx);
            }
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _addSchedule(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('추가'),
          ),
        ],
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
                    title: Text(s.title, style: const TextStyle(fontSize: 14)),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, size: 18, color: Colors.grey.shade400),
                      onPressed: () => _deleteSchedule(s.id),
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
