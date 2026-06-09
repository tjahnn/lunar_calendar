part of '../calendar_screen.dart';

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
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _secondaryLabelColor(context),
            ),
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
      visualDensity: VisualDensity.compact,
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
