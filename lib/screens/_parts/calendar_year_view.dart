part of '../calendar_screen.dart';

// ──────────────────────────────────────────────
// _CalendarYearView
// ──────────────────────────────────────────────

class _CalendarYearView extends StatefulWidget {
  final int year;
  final int month;
  final CalendarMode mode;
  final DateTime today;
  final AppDatabase db;
  final ValueChanged<DateTime> onMonthSelected;

  const _CalendarYearView({
    required this.year,
    required this.month,
    required this.mode,
    required this.today,
    required this.db,
    required this.onMonthSelected,
  });

  @override
  State<_CalendarYearView> createState() => _CalendarYearViewState();
}

class _CalendarYearViewState extends State<_CalendarYearView> {
  static const int _minYear = 1900;
  static const int _maxYear = 2100;

  late int _selectedYear;
  int? _selectedMonth;
  late final FixedExtentScrollController _yearController;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.year;
    _selectedMonth = widget.month;
    _yearController = FixedExtentScrollController(initialItem: widget.year - _minYear);
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  Widget _monthGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          final month = index + 1;
          final isThisMonth = widget.today.year == _selectedYear && widget.today.month == month;

          String? lunarLabel;
          if (widget.mode == CalendarMode.lunar) {
            klc.setSolarDate(_selectedYear, month, 1);
            final lm = klc.getLunarMonth();
            final isLeap = klc.isIntercalation;
            lunarLabel = '음력 ${isLeap ? '윤' : ''}$lm월';
          }

          final isSelected = _selectedMonth == month;
          return InkWell(
            onTap: () {
              if (isSelected) {
                widget.onMonthSelected(DateTime(_selectedYear, month));
              } else {
                setState(() => _selectedMonth = month);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue.shade50
                    : isThisMonth ? Colors.red.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.blue.shade300
                      : isThisMonth ? Colors.red.shade300 : Colors.grey.shade200,
                  width: isSelected || isThisMonth ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$month월',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isThisMonth ? Colors.red.shade600 : Colors.black87,
                    ),
                  ),
                  if (lunarLabel != null) ...[
                    const SizedBox(height: 2),
                    Text(lunarLabel, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _monthScheduleList(int month) {
    return StreamBuilder<List<(DateTime, Schedule)>>(
      stream: widget.db.watchSchedulesInMonth(_selectedYear, month),
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return Center(
            child: Text(
              '$_selectedYear년 $month월 일정 없음',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: items.length,
          separatorBuilder: (_, _) => Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.grey.shade100,
          ),
          itemBuilder: (context, index) {
            final (date, schedule) = items[index];
            return ListTile(
              dense: true,
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
              title: Text(schedule.title, style: const TextStyle(fontSize: 14)),
              subtitle: (schedule.description?.isNotEmpty ?? false)
                  ? Text(
                      schedule.description!,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              onTap: () => widget.onMonthSelected(date),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 연도 롤러 (좌우 수평 슬라이딩)
        SizedBox(
          height: 60,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              return Stack(
                alignment: Alignment.center,
                children: [
                  // 중앙 선택 강조 박스
                  Container(
                    width: 80,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  OverflowBox(
                    alignment: Alignment.center,
                    maxWidth: availableWidth,
                    maxHeight: availableWidth,
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: SizedBox(
                        width: 60,
                        height: availableWidth,
                        child: ListWheelScrollView.useDelegate(
                          controller: _yearController,
                          itemExtent: 80,
                          perspective: 0.003,
                          diameterRatio: 8.0,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) => setState(() {
                            _selectedYear = _minYear + index;
                            _selectedMonth = null;
                          }),
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: _maxYear - _minYear + 1,
                            builder: (context, index) {
                              final year = _minYear + index;
                              final isSelected = year == _selectedYear;
                              return GestureDetector(
                                onTap: () => _yearController.animateToItem(
                                  index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                ),
                                child: RotatedBox(
                                  quarterTurns: 1,
                                  child: Center(
                                    child: Text(
                                      '$year년',
                                      style: TextStyle(
                                        fontSize: isSelected ? 20 : 15,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? Colors.black87
                                            : Colors.grey.shade400,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const Divider(height: 1, thickness: 0.5),
        // 월 그리드 + 일정 목록
        Expanded(
          child: Column(
            children: [
              Flexible(
                flex: _selectedMonth != null ? 2 : 1,
                fit: FlexFit.tight,
                child: _monthGrid(),
              ),
              if (_selectedMonth != null) ...[
                const Divider(height: 1, thickness: 0.5),
                Flexible(
                  fit: FlexFit.tight,
                  child: _monthScheduleList(_selectedMonth!),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
