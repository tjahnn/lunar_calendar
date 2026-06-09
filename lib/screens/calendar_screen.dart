import 'package:flutter/material.dart';
import 'package:klc/klc.dart' as klc;
import '../database/app_database.dart';

part '_parts/calendar_month_view.dart';
part '_parts/calendar_detail_panel.dart';
part '_parts/calendar_add_dialog.dart';
part '_parts/calendar_year_view.dart';

enum CalendarMode { solar, lunar }

enum _ViewLevel { year, month }

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
  _ViewLevel _viewLevel = _ViewLevel.month;
  final DateTime _today = DateTime.now();
  DateTime? _selectedDate;

  // 1 = 다음 달(위 스와이프), -1 = 이전 달(아래 스와이프)
  int _slideDir = 1;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(_today.year, _today.month);
    _selectedDate = _today;
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _goPrev() => setState(() {
    _slideDir = -1;
    if (_viewLevel == _ViewLevel.year) {
      _focusedMonth = DateTime(_focusedMonth.year - 1, _focusedMonth.month);
    } else {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    }
  });

  void _goNext() => setState(() {
    _slideDir = 1;
    if (_viewLevel == _ViewLevel.year) {
      _focusedMonth = DateTime(_focusedMonth.year + 1, _focusedMonth.month);
    } else {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    }
  });

  void _goToday() {
    final target = DateTime(_today.year, _today.month);
    setState(() {
      _viewLevel = _ViewLevel.month;
      _slideDir = _focusedMonth.isBefore(target) ? 1 : -1;
      _focusedMonth = target;
      _selectedDate = _today;
    });
  }

  void _goYearView() => setState(() => _viewLevel = _ViewLevel.year);

  void _onMonthSelected(DateTime month) => setState(() {
    _focusedMonth = month;
    _viewLevel = _ViewLevel.month;
  });

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
        leading: _viewLevel == _ViewLevel.month
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black87),
                tooltip: '월 목록',
                onPressed: _goYearView,
              )
            : null,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.today, color: Colors.black87),
                    tooltip: '오늘',
                    visualDensity: VisualDensity.compact,
                    onPressed: _goToday,
                  ),
                  _ModeToggle(mode: _mode, onChanged: (m) => setState(() => _mode = m)),
                ],
              ),
            ),
          ),
        ],
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
      body: _viewLevel == _ViewLevel.year
          ? _CalendarYearView(
              year: _focusedMonth.year,
              month: _focusedMonth.month,
              mode: _mode,
              today: _today,
              db: widget.db,
              onMonthSelected: _onMonthSelected,
            )
          : Column(
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
