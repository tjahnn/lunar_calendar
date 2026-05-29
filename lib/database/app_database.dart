import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Schedules extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get title => text()();
}

@DriftDatabase(tables: [Schedules])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'lunar_calendar');
  }

  /// 특정 날짜의 일정 목록을 실시간 스트림으로 반환
  Stream<List<Schedule>> watchSchedulesForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (select(schedules)
          ..where(
            (t) =>
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerThanValue(end),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .watch();
  }

  /// 특정 월에서 일정이 있는 날짜 집합을 실시간 스트림으로 반환
  Stream<Set<DateTime>> watchScheduledDatesInMonth(int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    return (select(schedules)
          ..where(
            (t) =>
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerThanValue(end),
          ))
        .watch()
        .map(
          (rows) => rows
              .map((r) => DateTime(r.date.year, r.date.month, r.date.day))
              .toSet(),
        );
  }

  Future<void> addSchedule(DateTime date, String title) {
    return into(schedules).insert(
      SchedulesCompanion.insert(
        date: DateTime(date.year, date.month, date.day),
        title: title,
      ),
    );
  }

  Future<void> deleteSchedule(int id) {
    return (delete(schedules)..where((t) => t.id.equals(id))).go();
  }
}
