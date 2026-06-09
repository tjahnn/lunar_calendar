// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SchedulesTable extends Schedules
    with TableInfo<$SchedulesTable, Schedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isLunarDateMeta = const VerificationMeta(
    'isLunarDate',
  );
  @override
  late final GeneratedColumn<bool> isLunarDate = GeneratedColumn<bool>(
    'is_lunar_date',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_lunar_date" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lunarMonthMeta = const VerificationMeta(
    'lunarMonth',
  );
  @override
  late final GeneratedColumn<int> lunarMonth = GeneratedColumn<int>(
    'lunar_month',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lunarDayMeta = const VerificationMeta(
    'lunarDay',
  );
  @override
  late final GeneratedColumn<int> lunarDay = GeneratedColumn<int>(
    'lunar_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isLeapMonthMeta = const VerificationMeta(
    'isLeapMonth',
  );
  @override
  late final GeneratedColumn<bool> isLeapMonth = GeneratedColumn<bool>(
    'is_leap_month',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_leap_month" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _repeatTypeMeta = const VerificationMeta(
    'repeatType',
  );
  @override
  late final GeneratedColumn<String> repeatType = GeneratedColumn<String>(
    'repeat_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _repeatIntervalMeta = const VerificationMeta(
    'repeatInterval',
  );
  @override
  late final GeneratedColumn<int> repeatInterval = GeneratedColumn<int>(
    'repeat_interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _alarmTimeMeta = const VerificationMeta(
    'alarmTime',
  );
  @override
  late final GeneratedColumn<String> alarmTime = GeneratedColumn<String>(
    'alarm_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    title,
    description,
    isLunarDate,
    lunarMonth,
    lunarDay,
    isLeapMonth,
    repeatType,
    repeatInterval,
    alarmTime,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<Schedule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('is_lunar_date')) {
      context.handle(
        _isLunarDateMeta,
        isLunarDate.isAcceptableOrUnknown(
          data['is_lunar_date']!,
          _isLunarDateMeta,
        ),
      );
    }
    if (data.containsKey('lunar_month')) {
      context.handle(
        _lunarMonthMeta,
        lunarMonth.isAcceptableOrUnknown(data['lunar_month']!, _lunarMonthMeta),
      );
    }
    if (data.containsKey('lunar_day')) {
      context.handle(
        _lunarDayMeta,
        lunarDay.isAcceptableOrUnknown(data['lunar_day']!, _lunarDayMeta),
      );
    }
    if (data.containsKey('is_leap_month')) {
      context.handle(
        _isLeapMonthMeta,
        isLeapMonth.isAcceptableOrUnknown(
          data['is_leap_month']!,
          _isLeapMonthMeta,
        ),
      );
    }
    if (data.containsKey('repeat_type')) {
      context.handle(
        _repeatTypeMeta,
        repeatType.isAcceptableOrUnknown(data['repeat_type']!, _repeatTypeMeta),
      );
    }
    if (data.containsKey('repeat_interval')) {
      context.handle(
        _repeatIntervalMeta,
        repeatInterval.isAcceptableOrUnknown(
          data['repeat_interval']!,
          _repeatIntervalMeta,
        ),
      );
    }
    if (data.containsKey('alarm_time')) {
      context.handle(
        _alarmTimeMeta,
        alarmTime.isAcceptableOrUnknown(data['alarm_time']!, _alarmTimeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Schedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Schedule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      isLunarDate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_lunar_date'],
      )!,
      lunarMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lunar_month'],
      ),
      lunarDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lunar_day'],
      ),
      isLeapMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_leap_month'],
      )!,
      repeatType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_type'],
      )!,
      repeatInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeat_interval'],
      )!,
      alarmTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alarm_time'],
      ),
    );
  }

  @override
  $SchedulesTable createAlias(String alias) {
    return $SchedulesTable(attachedDatabase, alias);
  }
}

class Schedule extends DataClass implements Insertable<Schedule> {
  final int id;
  final DateTime date;
  final String title;
  final String? description;
  final bool isLunarDate;
  final int? lunarMonth;
  final int? lunarDay;
  final bool isLeapMonth;
  final String repeatType;
  final int repeatInterval;
  final String? alarmTime;
  const Schedule({
    required this.id,
    required this.date,
    required this.title,
    this.description,
    required this.isLunarDate,
    this.lunarMonth,
    this.lunarDay,
    required this.isLeapMonth,
    required this.repeatType,
    required this.repeatInterval,
    this.alarmTime,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_lunar_date'] = Variable<bool>(isLunarDate);
    if (!nullToAbsent || lunarMonth != null) {
      map['lunar_month'] = Variable<int>(lunarMonth);
    }
    if (!nullToAbsent || lunarDay != null) {
      map['lunar_day'] = Variable<int>(lunarDay);
    }
    map['is_leap_month'] = Variable<bool>(isLeapMonth);
    map['repeat_type'] = Variable<String>(repeatType);
    map['repeat_interval'] = Variable<int>(repeatInterval);
    if (!nullToAbsent || alarmTime != null) {
      map['alarm_time'] = Variable<String>(alarmTime);
    }
    return map;
  }

  SchedulesCompanion toCompanion(bool nullToAbsent) {
    return SchedulesCompanion(
      id: Value(id),
      date: Value(date),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isLunarDate: Value(isLunarDate),
      lunarMonth: lunarMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(lunarMonth),
      lunarDay: lunarDay == null && nullToAbsent
          ? const Value.absent()
          : Value(lunarDay),
      isLeapMonth: Value(isLeapMonth),
      repeatType: Value(repeatType),
      repeatInterval: Value(repeatInterval),
      alarmTime: alarmTime == null && nullToAbsent
          ? const Value.absent()
          : Value(alarmTime),
    );
  }

  factory Schedule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Schedule(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      isLunarDate: serializer.fromJson<bool>(json['isLunarDate']),
      lunarMonth: serializer.fromJson<int?>(json['lunarMonth']),
      lunarDay: serializer.fromJson<int?>(json['lunarDay']),
      isLeapMonth: serializer.fromJson<bool>(json['isLeapMonth']),
      repeatType: serializer.fromJson<String>(json['repeatType']),
      repeatInterval: serializer.fromJson<int>(json['repeatInterval']),
      alarmTime: serializer.fromJson<String?>(json['alarmTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'isLunarDate': serializer.toJson<bool>(isLunarDate),
      'lunarMonth': serializer.toJson<int?>(lunarMonth),
      'lunarDay': serializer.toJson<int?>(lunarDay),
      'isLeapMonth': serializer.toJson<bool>(isLeapMonth),
      'repeatType': serializer.toJson<String>(repeatType),
      'repeatInterval': serializer.toJson<int>(repeatInterval),
      'alarmTime': serializer.toJson<String?>(alarmTime),
    };
  }

  Schedule copyWith({
    int? id,
    DateTime? date,
    String? title,
    Value<String?> description = const Value.absent(),
    bool? isLunarDate,
    Value<int?> lunarMonth = const Value.absent(),
    Value<int?> lunarDay = const Value.absent(),
    bool? isLeapMonth,
    String? repeatType,
    int? repeatInterval,
    Value<String?> alarmTime = const Value.absent(),
  }) => Schedule(
    id: id ?? this.id,
    date: date ?? this.date,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    isLunarDate: isLunarDate ?? this.isLunarDate,
    lunarMonth: lunarMonth.present ? lunarMonth.value : this.lunarMonth,
    lunarDay: lunarDay.present ? lunarDay.value : this.lunarDay,
    isLeapMonth: isLeapMonth ?? this.isLeapMonth,
    repeatType: repeatType ?? this.repeatType,
    repeatInterval: repeatInterval ?? this.repeatInterval,
    alarmTime: alarmTime.present ? alarmTime.value : this.alarmTime,
  );
  Schedule copyWithCompanion(SchedulesCompanion data) {
    return Schedule(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      isLunarDate: data.isLunarDate.present
          ? data.isLunarDate.value
          : this.isLunarDate,
      lunarMonth: data.lunarMonth.present
          ? data.lunarMonth.value
          : this.lunarMonth,
      lunarDay: data.lunarDay.present ? data.lunarDay.value : this.lunarDay,
      isLeapMonth: data.isLeapMonth.present
          ? data.isLeapMonth.value
          : this.isLeapMonth,
      repeatType: data.repeatType.present
          ? data.repeatType.value
          : this.repeatType,
      repeatInterval: data.repeatInterval.present
          ? data.repeatInterval.value
          : this.repeatInterval,
      alarmTime: data.alarmTime.present ? data.alarmTime.value : this.alarmTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Schedule(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('isLunarDate: $isLunarDate, ')
          ..write('lunarMonth: $lunarMonth, ')
          ..write('lunarDay: $lunarDay, ')
          ..write('isLeapMonth: $isLeapMonth, ')
          ..write('repeatType: $repeatType, ')
          ..write('repeatInterval: $repeatInterval, ')
          ..write('alarmTime: $alarmTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    title,
    description,
    isLunarDate,
    lunarMonth,
    lunarDay,
    isLeapMonth,
    repeatType,
    repeatInterval,
    alarmTime,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Schedule &&
          other.id == this.id &&
          other.date == this.date &&
          other.title == this.title &&
          other.description == this.description &&
          other.isLunarDate == this.isLunarDate &&
          other.lunarMonth == this.lunarMonth &&
          other.lunarDay == this.lunarDay &&
          other.isLeapMonth == this.isLeapMonth &&
          other.repeatType == this.repeatType &&
          other.repeatInterval == this.repeatInterval &&
          other.alarmTime == this.alarmTime);
}

class SchedulesCompanion extends UpdateCompanion<Schedule> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String> title;
  final Value<String?> description;
  final Value<bool> isLunarDate;
  final Value<int?> lunarMonth;
  final Value<int?> lunarDay;
  final Value<bool> isLeapMonth;
  final Value<String> repeatType;
  final Value<int> repeatInterval;
  final Value<String?> alarmTime;
  const SchedulesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.isLunarDate = const Value.absent(),
    this.lunarMonth = const Value.absent(),
    this.lunarDay = const Value.absent(),
    this.isLeapMonth = const Value.absent(),
    this.repeatType = const Value.absent(),
    this.repeatInterval = const Value.absent(),
    this.alarmTime = const Value.absent(),
  });
  SchedulesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required String title,
    this.description = const Value.absent(),
    this.isLunarDate = const Value.absent(),
    this.lunarMonth = const Value.absent(),
    this.lunarDay = const Value.absent(),
    this.isLeapMonth = const Value.absent(),
    this.repeatType = const Value.absent(),
    this.repeatInterval = const Value.absent(),
    this.alarmTime = const Value.absent(),
  }) : date = Value(date),
       title = Value(title);
  static Insertable<Schedule> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? title,
    Expression<String>? description,
    Expression<bool>? isLunarDate,
    Expression<int>? lunarMonth,
    Expression<int>? lunarDay,
    Expression<bool>? isLeapMonth,
    Expression<String>? repeatType,
    Expression<int>? repeatInterval,
    Expression<String>? alarmTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (isLunarDate != null) 'is_lunar_date': isLunarDate,
      if (lunarMonth != null) 'lunar_month': lunarMonth,
      if (lunarDay != null) 'lunar_day': lunarDay,
      if (isLeapMonth != null) 'is_leap_month': isLeapMonth,
      if (repeatType != null) 'repeat_type': repeatType,
      if (repeatInterval != null) 'repeat_interval': repeatInterval,
      if (alarmTime != null) 'alarm_time': alarmTime,
    });
  }

  SchedulesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<String>? title,
    Value<String?>? description,
    Value<bool>? isLunarDate,
    Value<int?>? lunarMonth,
    Value<int?>? lunarDay,
    Value<bool>? isLeapMonth,
    Value<String>? repeatType,
    Value<int>? repeatInterval,
    Value<String?>? alarmTime,
  }) {
    return SchedulesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      description: description ?? this.description,
      isLunarDate: isLunarDate ?? this.isLunarDate,
      lunarMonth: lunarMonth ?? this.lunarMonth,
      lunarDay: lunarDay ?? this.lunarDay,
      isLeapMonth: isLeapMonth ?? this.isLeapMonth,
      repeatType: repeatType ?? this.repeatType,
      repeatInterval: repeatInterval ?? this.repeatInterval,
      alarmTime: alarmTime ?? this.alarmTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isLunarDate.present) {
      map['is_lunar_date'] = Variable<bool>(isLunarDate.value);
    }
    if (lunarMonth.present) {
      map['lunar_month'] = Variable<int>(lunarMonth.value);
    }
    if (lunarDay.present) {
      map['lunar_day'] = Variable<int>(lunarDay.value);
    }
    if (isLeapMonth.present) {
      map['is_leap_month'] = Variable<bool>(isLeapMonth.value);
    }
    if (repeatType.present) {
      map['repeat_type'] = Variable<String>(repeatType.value);
    }
    if (repeatInterval.present) {
      map['repeat_interval'] = Variable<int>(repeatInterval.value);
    }
    if (alarmTime.present) {
      map['alarm_time'] = Variable<String>(alarmTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchedulesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('isLunarDate: $isLunarDate, ')
          ..write('lunarMonth: $lunarMonth, ')
          ..write('lunarDay: $lunarDay, ')
          ..write('isLeapMonth: $isLeapMonth, ')
          ..write('repeatType: $repeatType, ')
          ..write('repeatInterval: $repeatInterval, ')
          ..write('alarmTime: $alarmTime')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SchedulesTable schedules = $SchedulesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [schedules];
}

typedef $$SchedulesTableCreateCompanionBuilder =
    SchedulesCompanion Function({
      Value<int> id,
      required DateTime date,
      required String title,
      Value<String?> description,
      Value<bool> isLunarDate,
      Value<int?> lunarMonth,
      Value<int?> lunarDay,
      Value<bool> isLeapMonth,
      Value<String> repeatType,
      Value<int> repeatInterval,
      Value<String?> alarmTime,
    });
typedef $$SchedulesTableUpdateCompanionBuilder =
    SchedulesCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<String> title,
      Value<String?> description,
      Value<bool> isLunarDate,
      Value<int?> lunarMonth,
      Value<int?> lunarDay,
      Value<bool> isLeapMonth,
      Value<String> repeatType,
      Value<int> repeatInterval,
      Value<String?> alarmTime,
    });

class $$SchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLunarDate => $composableBuilder(
    column: $table.isLunarDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lunarMonth => $composableBuilder(
    column: $table.lunarMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lunarDay => $composableBuilder(
    column: $table.lunarDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLeapMonth => $composableBuilder(
    column: $table.isLeapMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatType => $composableBuilder(
    column: $table.repeatType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repeatInterval => $composableBuilder(
    column: $table.repeatInterval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alarmTime => $composableBuilder(
    column: $table.alarmTime,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLunarDate => $composableBuilder(
    column: $table.isLunarDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lunarMonth => $composableBuilder(
    column: $table.lunarMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lunarDay => $composableBuilder(
    column: $table.lunarDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLeapMonth => $composableBuilder(
    column: $table.isLeapMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatType => $composableBuilder(
    column: $table.repeatType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeatInterval => $composableBuilder(
    column: $table.repeatInterval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alarmTime => $composableBuilder(
    column: $table.alarmTime,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isLunarDate => $composableBuilder(
    column: $table.isLunarDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lunarMonth => $composableBuilder(
    column: $table.lunarMonth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lunarDay =>
      $composableBuilder(column: $table.lunarDay, builder: (column) => column);

  GeneratedColumn<bool> get isLeapMonth => $composableBuilder(
    column: $table.isLeapMonth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get repeatType => $composableBuilder(
    column: $table.repeatType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repeatInterval => $composableBuilder(
    column: $table.repeatInterval,
    builder: (column) => column,
  );

  GeneratedColumn<String> get alarmTime =>
      $composableBuilder(column: $table.alarmTime, builder: (column) => column);
}

class $$SchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SchedulesTable,
          Schedule,
          $$SchedulesTableFilterComposer,
          $$SchedulesTableOrderingComposer,
          $$SchedulesTableAnnotationComposer,
          $$SchedulesTableCreateCompanionBuilder,
          $$SchedulesTableUpdateCompanionBuilder,
          (Schedule, BaseReferences<_$AppDatabase, $SchedulesTable, Schedule>),
          Schedule,
          PrefetchHooks Function()
        > {
  $$SchedulesTableTableManager(_$AppDatabase db, $SchedulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> isLunarDate = const Value.absent(),
                Value<int?> lunarMonth = const Value.absent(),
                Value<int?> lunarDay = const Value.absent(),
                Value<bool> isLeapMonth = const Value.absent(),
                Value<String> repeatType = const Value.absent(),
                Value<int> repeatInterval = const Value.absent(),
                Value<String?> alarmTime = const Value.absent(),
              }) => SchedulesCompanion(
                id: id,
                date: date,
                title: title,
                description: description,
                isLunarDate: isLunarDate,
                lunarMonth: lunarMonth,
                lunarDay: lunarDay,
                isLeapMonth: isLeapMonth,
                repeatType: repeatType,
                repeatInterval: repeatInterval,
                alarmTime: alarmTime,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<bool> isLunarDate = const Value.absent(),
                Value<int?> lunarMonth = const Value.absent(),
                Value<int?> lunarDay = const Value.absent(),
                Value<bool> isLeapMonth = const Value.absent(),
                Value<String> repeatType = const Value.absent(),
                Value<int> repeatInterval = const Value.absent(),
                Value<String?> alarmTime = const Value.absent(),
              }) => SchedulesCompanion.insert(
                id: id,
                date: date,
                title: title,
                description: description,
                isLunarDate: isLunarDate,
                lunarMonth: lunarMonth,
                lunarDay: lunarDay,
                isLeapMonth: isLeapMonth,
                repeatType: repeatType,
                repeatInterval: repeatInterval,
                alarmTime: alarmTime,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SchedulesTable,
      Schedule,
      $$SchedulesTableFilterComposer,
      $$SchedulesTableOrderingComposer,
      $$SchedulesTableAnnotationComposer,
      $$SchedulesTableCreateCompanionBuilder,
      $$SchedulesTableUpdateCompanionBuilder,
      (Schedule, BaseReferences<_$AppDatabase, $SchedulesTable, Schedule>),
      Schedule,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SchedulesTableTableManager get schedules =>
      $$SchedulesTableTableManager(_db, _db.schedules);
}
