import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:klc/klc.dart' as klc;

part 'app_database.g.dart';

class Schedules extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isLunarDate =>
      boolean().withDefault(const Constant(false))();
  IntColumn get lunarMonth => integer().nullable()();
  IntColumn get lunarDay => integer().nullable()();
  BoolColumn get isLeapMonth =>
      boolean().withDefault(const Constant(false))();
  // none | daily | weekly | monthly | yearly
  TextColumn get repeatType =>
      text().withDefault(const Constant('none'))();
  IntColumn get repeatInterval =>
      integer().withDefault(const Constant(1))();
}

@DriftDatabase(tables: [Schedules])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(schedules, schedules.description);
        await m.addColumn(schedules, schedules.isLunarDate);
        await m.addColumn(schedules, schedules.lunarMonth);
        await m.addColumn(schedules, schedules.lunarDay);
        await m.addColumn(schedules, schedules.isLeapMonth);
        await m.addColumn(schedules, schedules.repeatType);
      }
      if (from < 3) {
        await m.addColumn(schedules, schedules.repeatInterval);
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'lunar_calendar');
  }

  /// 주어진 양력 날짜에 대해 일정이 적용되는지 반복 규칙을 포함해 판단
  static bool scheduleAppliesTo(
    Schedule s,
    DateTime targetSolar,
    int targetLunarMonth,
    int targetLunarDay,
  ) {
    final base = DateTime(s.date.year, s.date.month, s.date.day);
    final target = DateTime(
      targetSolar.year,
      targetSolar.month,
      targetSolar.day,
    );

    if (base.isAfter(target)) return false;

    final interval = s.repeatInterval;

    switch (s.repeatType) {
      case 'none':
        if (s.isLunarDate) {
          return s.lunarMonth == targetLunarMonth &&
              s.lunarDay == targetLunarDay;
        }
        return base == target;

      case 'daily':
        return target.difference(base).inDays % interval == 0;

      case 'weekly':
        return target.difference(base).inDays % (interval * 7) == 0;

      case 'monthly':
        if (s.isLunarDate) {
          return s.lunarDay == targetLunarDay;
        }
        final monthDiff = (target.year * 12 + target.month) -
            (base.year * 12 + base.month);
        return monthDiff % interval == 0 && target.day == base.day;

      case 'yearly':
        if (s.isLunarDate) {
          return s.lunarMonth == targetLunarMonth &&
              s.lunarDay == targetLunarDay;
        }
        return (target.year - base.year) % interval == 0 &&
            target.month == base.month &&
            target.day == base.day;

      default:
        return false;
    }
  }

  /// 특정 날짜의 일정 목록을 실시간 스트림으로 반환 (반복 일정 포함)
  Stream<List<Schedule>> watchSchedulesForDate(DateTime date) {
    final target = DateTime(date.year, date.month, date.day);
    klc.setSolarDate(target.year, target.month, target.day);
    final tLunarMonth = klc.getLunarMonth();
    final tLunarDay = klc.getLunarDay();

    return select(schedules)
        .watch()
        .map(
          (all) =>
              all
                  .where(
                    (s) => scheduleAppliesTo(
                      s,
                      target,
                      tLunarMonth,
                      tLunarDay,
                    ),
                  )
                  .toList(),
        );
  }

  /// 특정 월에서 일정이 있는 날짜 집합을 실시간 스트림으로 반환 (반복 일정 포함)
  Stream<Set<DateTime>> watchScheduledDatesInMonth(int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    // 월 내 각 날짜의 음력 정보 사전 계산
    final lunarInfos = List.generate(daysInMonth, (i) {
      final d = DateTime(year, month, i + 1);
      klc.setSolarDate(d.year, d.month, d.day);
      return (lunarMonth: klc.getLunarMonth(), lunarDay: klc.getLunarDay());
    });

    return select(schedules)
        .watch()
        .map((all) {
          final result = <DateTime>{};
          for (var dayIdx = 0; dayIdx < daysInMonth; dayIdx++) {
            final solar = DateTime(year, month, dayIdx + 1);
            final lm = lunarInfos[dayIdx].lunarMonth;
            final ld = lunarInfos[dayIdx].lunarDay;
            for (final s in all) {
              if (scheduleAppliesTo(s, solar, lm, ld)) {
                result.add(solar);
                break;
              }
            }
          }
          return result;
        });
  }

  Future<void> addSchedule(
    DateTime date,
    String title, {
    String? description,
    bool isLunarDate = false,
    int? lunarMonth,
    int? lunarDay,
    bool isLeapMonth = false,
    String repeatType = 'none',
    int repeatInterval = 1,
  }) {
    return into(schedules).insert(
      SchedulesCompanion.insert(
        date: DateTime(date.year, date.month, date.day),
        title: title,
        description: Value(description),
        isLunarDate: Value(isLunarDate),
        lunarMonth: Value(lunarMonth),
        lunarDay: Value(lunarDay),
        isLeapMonth: Value(isLeapMonth),
        repeatType: Value(repeatType),
        repeatInterval: Value(repeatInterval),
      ),
    );
  }

  Future<void> updateSchedule(
    int id, {
    required String title,
    String? description,
    bool isLunarDate = false,
    int? lunarMonth,
    int? lunarDay,
    bool isLeapMonth = false,
    String repeatType = 'none',
    int repeatInterval = 1,
  }) {
    return (update(schedules)..where((t) => t.id.equals(id))).write(
      SchedulesCompanion(
        title: Value(title),
        description: Value(description),
        isLunarDate: Value(isLunarDate),
        lunarMonth: Value(lunarMonth),
        lunarDay: Value(lunarDay),
        isLeapMonth: Value(isLeapMonth),
        repeatType: Value(repeatType),
        repeatInterval: Value(repeatInterval),
      ),
    );
  }

  Future<void> deleteSchedule(int id) {
    return (delete(schedules)..where((t) => t.id.equals(id))).go();
  }

  /// 특정 월에 발생하는 모든 일정을 (양력날짜, 일정) 쌍으로 반환 (반복 일정 포함, 날짜 오름차순)
  Stream<List<(DateTime, Schedule)>> watchSchedulesInMonth(int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final lunarInfos = List.generate(daysInMonth, (i) {
      final d = DateTime(year, month, i + 1);
      klc.setSolarDate(d.year, d.month, d.day);
      return (lunarMonth: klc.getLunarMonth(), lunarDay: klc.getLunarDay());
    });

    return select(schedules).watch().map((all) {
      final result = <(DateTime, Schedule)>[];
      for (var dayIdx = 0; dayIdx < daysInMonth; dayIdx++) {
        final solar = DateTime(year, month, dayIdx + 1);
        final lm = lunarInfos[dayIdx].lunarMonth;
        final ld = lunarInfos[dayIdx].lunarDay;
        for (final s in all) {
          if (scheduleAppliesTo(s, solar, lm, ld)) {
            result.add((solar, s));
          }
        }
      }
      return result;
    });
  }
}
