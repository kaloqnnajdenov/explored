// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visited_grid_database.dart';

// ignore_for_file: type=lint
class $VisitsDailyTable extends VisitsDaily
    with TableInfo<$VisitsDailyTable, VisitsDailyData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitsDailyTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _resMeta = const VerificationMeta('res');
  @override
  late final GeneratedColumn<int> res = GeneratedColumn<int>(
    'res',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cellIdMeta = const VerificationMeta('cellId');
  @override
  late final GeneratedColumn<String> cellId = GeneratedColumn<String>(
    'cell_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayYyyyMmddMeta = const VerificationMeta(
    'dayYyyyMmdd',
  );
  @override
  late final GeneratedColumn<int> dayYyyyMmdd = GeneratedColumn<int>(
    'day_yyyy_mmdd',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hourMaskMeta = const VerificationMeta(
    'hourMask',
  );
  @override
  late final GeneratedColumn<int> hourMask = GeneratedColumn<int>(
    'hour_mask',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstTsMeta = const VerificationMeta(
    'firstTs',
  );
  @override
  late final GeneratedColumn<int> firstTs = GeneratedColumn<int>(
    'first_ts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastTsMeta = const VerificationMeta('lastTs');
  @override
  late final GeneratedColumn<int> lastTs = GeneratedColumn<int>(
    'last_ts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _samplesMeta = const VerificationMeta(
    'samples',
  );
  @override
  late final GeneratedColumn<int> samples = GeneratedColumn<int>(
    'samples',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latE5Meta = const VerificationMeta('latE5');
  @override
  late final GeneratedColumn<int> latE5 = GeneratedColumn<int>(
    'lat_e5',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lonE5Meta = const VerificationMeta('lonE5');
  @override
  late final GeneratedColumn<int> lonE5 = GeneratedColumn<int>(
    'lon_e5',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    res,
    cellId,
    dayYyyyMmdd,
    hourMask,
    firstTs,
    lastTs,
    samples,
    latE5,
    lonE5,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visits_daily';
  @override
  VerificationContext validateIntegrity(
    Insertable<VisitsDailyData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('res')) {
      context.handle(
        _resMeta,
        res.isAcceptableOrUnknown(data['res']!, _resMeta),
      );
    } else if (isInserting) {
      context.missing(_resMeta);
    }
    if (data.containsKey('cell_id')) {
      context.handle(
        _cellIdMeta,
        cellId.isAcceptableOrUnknown(data['cell_id']!, _cellIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cellIdMeta);
    }
    if (data.containsKey('day_yyyy_mmdd')) {
      context.handle(
        _dayYyyyMmddMeta,
        dayYyyyMmdd.isAcceptableOrUnknown(
          data['day_yyyy_mmdd']!,
          _dayYyyyMmddMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dayYyyyMmddMeta);
    }
    if (data.containsKey('hour_mask')) {
      context.handle(
        _hourMaskMeta,
        hourMask.isAcceptableOrUnknown(data['hour_mask']!, _hourMaskMeta),
      );
    } else if (isInserting) {
      context.missing(_hourMaskMeta);
    }
    if (data.containsKey('first_ts')) {
      context.handle(
        _firstTsMeta,
        firstTs.isAcceptableOrUnknown(data['first_ts']!, _firstTsMeta),
      );
    } else if (isInserting) {
      context.missing(_firstTsMeta);
    }
    if (data.containsKey('last_ts')) {
      context.handle(
        _lastTsMeta,
        lastTs.isAcceptableOrUnknown(data['last_ts']!, _lastTsMeta),
      );
    } else if (isInserting) {
      context.missing(_lastTsMeta);
    }
    if (data.containsKey('samples')) {
      context.handle(
        _samplesMeta,
        samples.isAcceptableOrUnknown(data['samples']!, _samplesMeta),
      );
    } else if (isInserting) {
      context.missing(_samplesMeta);
    }
    if (data.containsKey('lat_e5')) {
      context.handle(
        _latE5Meta,
        latE5.isAcceptableOrUnknown(data['lat_e5']!, _latE5Meta),
      );
    } else if (isInserting) {
      context.missing(_latE5Meta);
    }
    if (data.containsKey('lon_e5')) {
      context.handle(
        _lonE5Meta,
        lonE5.isAcceptableOrUnknown(data['lon_e5']!, _lonE5Meta),
      );
    } else if (isInserting) {
      context.missing(_lonE5Meta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {res, cellId, dayYyyyMmdd};
  @override
  VisitsDailyData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VisitsDailyData(
      res: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}res'],
      )!,
      cellId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cell_id'],
      )!,
      dayYyyyMmdd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_yyyy_mmdd'],
      )!,
      hourMask: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hour_mask'],
      )!,
      firstTs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_ts'],
      )!,
      lastTs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_ts'],
      )!,
      samples: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}samples'],
      )!,
      latE5: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lat_e5'],
      )!,
      lonE5: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lon_e5'],
      )!,
    );
  }

  @override
  $VisitsDailyTable createAlias(String alias) {
    return $VisitsDailyTable(attachedDatabase, alias);
  }
}

class VisitsDailyData extends DataClass implements Insertable<VisitsDailyData> {
  final int res;
  final String cellId;
  final int dayYyyyMmdd;
  final int hourMask;
  final int firstTs;
  final int lastTs;
  final int samples;
  final int latE5;
  final int lonE5;
  const VisitsDailyData({
    required this.res,
    required this.cellId,
    required this.dayYyyyMmdd,
    required this.hourMask,
    required this.firstTs,
    required this.lastTs,
    required this.samples,
    required this.latE5,
    required this.lonE5,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['res'] = Variable<int>(res);
    map['cell_id'] = Variable<String>(cellId);
    map['day_yyyy_mmdd'] = Variable<int>(dayYyyyMmdd);
    map['hour_mask'] = Variable<int>(hourMask);
    map['first_ts'] = Variable<int>(firstTs);
    map['last_ts'] = Variable<int>(lastTs);
    map['samples'] = Variable<int>(samples);
    map['lat_e5'] = Variable<int>(latE5);
    map['lon_e5'] = Variable<int>(lonE5);
    return map;
  }

  VisitsDailyCompanion toCompanion(bool nullToAbsent) {
    return VisitsDailyCompanion(
      res: Value(res),
      cellId: Value(cellId),
      dayYyyyMmdd: Value(dayYyyyMmdd),
      hourMask: Value(hourMask),
      firstTs: Value(firstTs),
      lastTs: Value(lastTs),
      samples: Value(samples),
      latE5: Value(latE5),
      lonE5: Value(lonE5),
    );
  }

  factory VisitsDailyData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VisitsDailyData(
      res: serializer.fromJson<int>(json['res']),
      cellId: serializer.fromJson<String>(json['cellId']),
      dayYyyyMmdd: serializer.fromJson<int>(json['dayYyyyMmdd']),
      hourMask: serializer.fromJson<int>(json['hourMask']),
      firstTs: serializer.fromJson<int>(json['firstTs']),
      lastTs: serializer.fromJson<int>(json['lastTs']),
      samples: serializer.fromJson<int>(json['samples']),
      latE5: serializer.fromJson<int>(json['latE5']),
      lonE5: serializer.fromJson<int>(json['lonE5']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'res': serializer.toJson<int>(res),
      'cellId': serializer.toJson<String>(cellId),
      'dayYyyyMmdd': serializer.toJson<int>(dayYyyyMmdd),
      'hourMask': serializer.toJson<int>(hourMask),
      'firstTs': serializer.toJson<int>(firstTs),
      'lastTs': serializer.toJson<int>(lastTs),
      'samples': serializer.toJson<int>(samples),
      'latE5': serializer.toJson<int>(latE5),
      'lonE5': serializer.toJson<int>(lonE5),
    };
  }

  VisitsDailyData copyWith({
    int? res,
    String? cellId,
    int? dayYyyyMmdd,
    int? hourMask,
    int? firstTs,
    int? lastTs,
    int? samples,
    int? latE5,
    int? lonE5,
  }) => VisitsDailyData(
    res: res ?? this.res,
    cellId: cellId ?? this.cellId,
    dayYyyyMmdd: dayYyyyMmdd ?? this.dayYyyyMmdd,
    hourMask: hourMask ?? this.hourMask,
    firstTs: firstTs ?? this.firstTs,
    lastTs: lastTs ?? this.lastTs,
    samples: samples ?? this.samples,
    latE5: latE5 ?? this.latE5,
    lonE5: lonE5 ?? this.lonE5,
  );
  VisitsDailyData copyWithCompanion(VisitsDailyCompanion data) {
    return VisitsDailyData(
      res: data.res.present ? data.res.value : this.res,
      cellId: data.cellId.present ? data.cellId.value : this.cellId,
      dayYyyyMmdd: data.dayYyyyMmdd.present
          ? data.dayYyyyMmdd.value
          : this.dayYyyyMmdd,
      hourMask: data.hourMask.present ? data.hourMask.value : this.hourMask,
      firstTs: data.firstTs.present ? data.firstTs.value : this.firstTs,
      lastTs: data.lastTs.present ? data.lastTs.value : this.lastTs,
      samples: data.samples.present ? data.samples.value : this.samples,
      latE5: data.latE5.present ? data.latE5.value : this.latE5,
      lonE5: data.lonE5.present ? data.lonE5.value : this.lonE5,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VisitsDailyData(')
          ..write('res: $res, ')
          ..write('cellId: $cellId, ')
          ..write('dayYyyyMmdd: $dayYyyyMmdd, ')
          ..write('hourMask: $hourMask, ')
          ..write('firstTs: $firstTs, ')
          ..write('lastTs: $lastTs, ')
          ..write('samples: $samples, ')
          ..write('latE5: $latE5, ')
          ..write('lonE5: $lonE5')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    res,
    cellId,
    dayYyyyMmdd,
    hourMask,
    firstTs,
    lastTs,
    samples,
    latE5,
    lonE5,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VisitsDailyData &&
          other.res == this.res &&
          other.cellId == this.cellId &&
          other.dayYyyyMmdd == this.dayYyyyMmdd &&
          other.hourMask == this.hourMask &&
          other.firstTs == this.firstTs &&
          other.lastTs == this.lastTs &&
          other.samples == this.samples &&
          other.latE5 == this.latE5 &&
          other.lonE5 == this.lonE5);
}

class VisitsDailyCompanion extends UpdateCompanion<VisitsDailyData> {
  final Value<int> res;
  final Value<String> cellId;
  final Value<int> dayYyyyMmdd;
  final Value<int> hourMask;
  final Value<int> firstTs;
  final Value<int> lastTs;
  final Value<int> samples;
  final Value<int> latE5;
  final Value<int> lonE5;
  final Value<int> rowid;
  const VisitsDailyCompanion({
    this.res = const Value.absent(),
    this.cellId = const Value.absent(),
    this.dayYyyyMmdd = const Value.absent(),
    this.hourMask = const Value.absent(),
    this.firstTs = const Value.absent(),
    this.lastTs = const Value.absent(),
    this.samples = const Value.absent(),
    this.latE5 = const Value.absent(),
    this.lonE5 = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VisitsDailyCompanion.insert({
    required int res,
    required String cellId,
    required int dayYyyyMmdd,
    required int hourMask,
    required int firstTs,
    required int lastTs,
    required int samples,
    required int latE5,
    required int lonE5,
    this.rowid = const Value.absent(),
  }) : res = Value(res),
       cellId = Value(cellId),
       dayYyyyMmdd = Value(dayYyyyMmdd),
       hourMask = Value(hourMask),
       firstTs = Value(firstTs),
       lastTs = Value(lastTs),
       samples = Value(samples),
       latE5 = Value(latE5),
       lonE5 = Value(lonE5);
  static Insertable<VisitsDailyData> custom({
    Expression<int>? res,
    Expression<String>? cellId,
    Expression<int>? dayYyyyMmdd,
    Expression<int>? hourMask,
    Expression<int>? firstTs,
    Expression<int>? lastTs,
    Expression<int>? samples,
    Expression<int>? latE5,
    Expression<int>? lonE5,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (res != null) 'res': res,
      if (cellId != null) 'cell_id': cellId,
      if (dayYyyyMmdd != null) 'day_yyyy_mmdd': dayYyyyMmdd,
      if (hourMask != null) 'hour_mask': hourMask,
      if (firstTs != null) 'first_ts': firstTs,
      if (lastTs != null) 'last_ts': lastTs,
      if (samples != null) 'samples': samples,
      if (latE5 != null) 'lat_e5': latE5,
      if (lonE5 != null) 'lon_e5': lonE5,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VisitsDailyCompanion copyWith({
    Value<int>? res,
    Value<String>? cellId,
    Value<int>? dayYyyyMmdd,
    Value<int>? hourMask,
    Value<int>? firstTs,
    Value<int>? lastTs,
    Value<int>? samples,
    Value<int>? latE5,
    Value<int>? lonE5,
    Value<int>? rowid,
  }) {
    return VisitsDailyCompanion(
      res: res ?? this.res,
      cellId: cellId ?? this.cellId,
      dayYyyyMmdd: dayYyyyMmdd ?? this.dayYyyyMmdd,
      hourMask: hourMask ?? this.hourMask,
      firstTs: firstTs ?? this.firstTs,
      lastTs: lastTs ?? this.lastTs,
      samples: samples ?? this.samples,
      latE5: latE5 ?? this.latE5,
      lonE5: lonE5 ?? this.lonE5,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (res.present) {
      map['res'] = Variable<int>(res.value);
    }
    if (cellId.present) {
      map['cell_id'] = Variable<String>(cellId.value);
    }
    if (dayYyyyMmdd.present) {
      map['day_yyyy_mmdd'] = Variable<int>(dayYyyyMmdd.value);
    }
    if (hourMask.present) {
      map['hour_mask'] = Variable<int>(hourMask.value);
    }
    if (firstTs.present) {
      map['first_ts'] = Variable<int>(firstTs.value);
    }
    if (lastTs.present) {
      map['last_ts'] = Variable<int>(lastTs.value);
    }
    if (samples.present) {
      map['samples'] = Variable<int>(samples.value);
    }
    if (latE5.present) {
      map['lat_e5'] = Variable<int>(latE5.value);
    }
    if (lonE5.present) {
      map['lon_e5'] = Variable<int>(lonE5.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitsDailyCompanion(')
          ..write('res: $res, ')
          ..write('cellId: $cellId, ')
          ..write('dayYyyyMmdd: $dayYyyyMmdd, ')
          ..write('hourMask: $hourMask, ')
          ..write('firstTs: $firstTs, ')
          ..write('lastTs: $lastTs, ')
          ..write('samples: $samples, ')
          ..write('latE5: $latE5, ')
          ..write('lonE5: $lonE5, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VisitsLifetimeTable extends VisitsLifetime
    with TableInfo<$VisitsLifetimeTable, VisitsLifetimeData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitsLifetimeTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _resMeta = const VerificationMeta('res');
  @override
  late final GeneratedColumn<int> res = GeneratedColumn<int>(
    'res',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cellIdMeta = const VerificationMeta('cellId');
  @override
  late final GeneratedColumn<String> cellId = GeneratedColumn<String>(
    'cell_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstTsMeta = const VerificationMeta(
    'firstTs',
  );
  @override
  late final GeneratedColumn<int> firstTs = GeneratedColumn<int>(
    'first_ts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastTsMeta = const VerificationMeta('lastTs');
  @override
  late final GeneratedColumn<int> lastTs = GeneratedColumn<int>(
    'last_ts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _samplesMeta = const VerificationMeta(
    'samples',
  );
  @override
  late final GeneratedColumn<int> samples = GeneratedColumn<int>(
    'samples',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daysVisitedMeta = const VerificationMeta(
    'daysVisited',
  );
  @override
  late final GeneratedColumn<int> daysVisited = GeneratedColumn<int>(
    'days_visited',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _latE5Meta = const VerificationMeta('latE5');
  @override
  late final GeneratedColumn<int> latE5 = GeneratedColumn<int>(
    'lat_e5',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lonE5Meta = const VerificationMeta('lonE5');
  @override
  late final GeneratedColumn<int> lonE5 = GeneratedColumn<int>(
    'lon_e5',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    res,
    cellId,
    firstTs,
    lastTs,
    samples,
    daysVisited,
    latE5,
    lonE5,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visits_lifetime';
  @override
  VerificationContext validateIntegrity(
    Insertable<VisitsLifetimeData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('res')) {
      context.handle(
        _resMeta,
        res.isAcceptableOrUnknown(data['res']!, _resMeta),
      );
    } else if (isInserting) {
      context.missing(_resMeta);
    }
    if (data.containsKey('cell_id')) {
      context.handle(
        _cellIdMeta,
        cellId.isAcceptableOrUnknown(data['cell_id']!, _cellIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cellIdMeta);
    }
    if (data.containsKey('first_ts')) {
      context.handle(
        _firstTsMeta,
        firstTs.isAcceptableOrUnknown(data['first_ts']!, _firstTsMeta),
      );
    } else if (isInserting) {
      context.missing(_firstTsMeta);
    }
    if (data.containsKey('last_ts')) {
      context.handle(
        _lastTsMeta,
        lastTs.isAcceptableOrUnknown(data['last_ts']!, _lastTsMeta),
      );
    } else if (isInserting) {
      context.missing(_lastTsMeta);
    }
    if (data.containsKey('samples')) {
      context.handle(
        _samplesMeta,
        samples.isAcceptableOrUnknown(data['samples']!, _samplesMeta),
      );
    } else if (isInserting) {
      context.missing(_samplesMeta);
    }
    if (data.containsKey('days_visited')) {
      context.handle(
        _daysVisitedMeta,
        daysVisited.isAcceptableOrUnknown(
          data['days_visited']!,
          _daysVisitedMeta,
        ),
      );
    }
    if (data.containsKey('lat_e5')) {
      context.handle(
        _latE5Meta,
        latE5.isAcceptableOrUnknown(data['lat_e5']!, _latE5Meta),
      );
    } else if (isInserting) {
      context.missing(_latE5Meta);
    }
    if (data.containsKey('lon_e5')) {
      context.handle(
        _lonE5Meta,
        lonE5.isAcceptableOrUnknown(data['lon_e5']!, _lonE5Meta),
      );
    } else if (isInserting) {
      context.missing(_lonE5Meta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {res, cellId};
  @override
  VisitsLifetimeData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VisitsLifetimeData(
      res: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}res'],
      )!,
      cellId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cell_id'],
      )!,
      firstTs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_ts'],
      )!,
      lastTs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_ts'],
      )!,
      samples: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}samples'],
      )!,
      daysVisited: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days_visited'],
      )!,
      latE5: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lat_e5'],
      )!,
      lonE5: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lon_e5'],
      )!,
    );
  }

  @override
  $VisitsLifetimeTable createAlias(String alias) {
    return $VisitsLifetimeTable(attachedDatabase, alias);
  }
}

class VisitsLifetimeData extends DataClass
    implements Insertable<VisitsLifetimeData> {
  final int res;
  final String cellId;
  final int firstTs;
  final int lastTs;
  final int samples;
  final int daysVisited;
  final int latE5;
  final int lonE5;
  const VisitsLifetimeData({
    required this.res,
    required this.cellId,
    required this.firstTs,
    required this.lastTs,
    required this.samples,
    required this.daysVisited,
    required this.latE5,
    required this.lonE5,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['res'] = Variable<int>(res);
    map['cell_id'] = Variable<String>(cellId);
    map['first_ts'] = Variable<int>(firstTs);
    map['last_ts'] = Variable<int>(lastTs);
    map['samples'] = Variable<int>(samples);
    map['days_visited'] = Variable<int>(daysVisited);
    map['lat_e5'] = Variable<int>(latE5);
    map['lon_e5'] = Variable<int>(lonE5);
    return map;
  }

  VisitsLifetimeCompanion toCompanion(bool nullToAbsent) {
    return VisitsLifetimeCompanion(
      res: Value(res),
      cellId: Value(cellId),
      firstTs: Value(firstTs),
      lastTs: Value(lastTs),
      samples: Value(samples),
      daysVisited: Value(daysVisited),
      latE5: Value(latE5),
      lonE5: Value(lonE5),
    );
  }

  factory VisitsLifetimeData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VisitsLifetimeData(
      res: serializer.fromJson<int>(json['res']),
      cellId: serializer.fromJson<String>(json['cellId']),
      firstTs: serializer.fromJson<int>(json['firstTs']),
      lastTs: serializer.fromJson<int>(json['lastTs']),
      samples: serializer.fromJson<int>(json['samples']),
      daysVisited: serializer.fromJson<int>(json['daysVisited']),
      latE5: serializer.fromJson<int>(json['latE5']),
      lonE5: serializer.fromJson<int>(json['lonE5']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'res': serializer.toJson<int>(res),
      'cellId': serializer.toJson<String>(cellId),
      'firstTs': serializer.toJson<int>(firstTs),
      'lastTs': serializer.toJson<int>(lastTs),
      'samples': serializer.toJson<int>(samples),
      'daysVisited': serializer.toJson<int>(daysVisited),
      'latE5': serializer.toJson<int>(latE5),
      'lonE5': serializer.toJson<int>(lonE5),
    };
  }

  VisitsLifetimeData copyWith({
    int? res,
    String? cellId,
    int? firstTs,
    int? lastTs,
    int? samples,
    int? daysVisited,
    int? latE5,
    int? lonE5,
  }) => VisitsLifetimeData(
    res: res ?? this.res,
    cellId: cellId ?? this.cellId,
    firstTs: firstTs ?? this.firstTs,
    lastTs: lastTs ?? this.lastTs,
    samples: samples ?? this.samples,
    daysVisited: daysVisited ?? this.daysVisited,
    latE5: latE5 ?? this.latE5,
    lonE5: lonE5 ?? this.lonE5,
  );
  VisitsLifetimeData copyWithCompanion(VisitsLifetimeCompanion data) {
    return VisitsLifetimeData(
      res: data.res.present ? data.res.value : this.res,
      cellId: data.cellId.present ? data.cellId.value : this.cellId,
      firstTs: data.firstTs.present ? data.firstTs.value : this.firstTs,
      lastTs: data.lastTs.present ? data.lastTs.value : this.lastTs,
      samples: data.samples.present ? data.samples.value : this.samples,
      daysVisited: data.daysVisited.present
          ? data.daysVisited.value
          : this.daysVisited,
      latE5: data.latE5.present ? data.latE5.value : this.latE5,
      lonE5: data.lonE5.present ? data.lonE5.value : this.lonE5,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VisitsLifetimeData(')
          ..write('res: $res, ')
          ..write('cellId: $cellId, ')
          ..write('firstTs: $firstTs, ')
          ..write('lastTs: $lastTs, ')
          ..write('samples: $samples, ')
          ..write('daysVisited: $daysVisited, ')
          ..write('latE5: $latE5, ')
          ..write('lonE5: $lonE5')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    res,
    cellId,
    firstTs,
    lastTs,
    samples,
    daysVisited,
    latE5,
    lonE5,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VisitsLifetimeData &&
          other.res == this.res &&
          other.cellId == this.cellId &&
          other.firstTs == this.firstTs &&
          other.lastTs == this.lastTs &&
          other.samples == this.samples &&
          other.daysVisited == this.daysVisited &&
          other.latE5 == this.latE5 &&
          other.lonE5 == this.lonE5);
}

class VisitsLifetimeCompanion extends UpdateCompanion<VisitsLifetimeData> {
  final Value<int> res;
  final Value<String> cellId;
  final Value<int> firstTs;
  final Value<int> lastTs;
  final Value<int> samples;
  final Value<int> daysVisited;
  final Value<int> latE5;
  final Value<int> lonE5;
  final Value<int> rowid;
  const VisitsLifetimeCompanion({
    this.res = const Value.absent(),
    this.cellId = const Value.absent(),
    this.firstTs = const Value.absent(),
    this.lastTs = const Value.absent(),
    this.samples = const Value.absent(),
    this.daysVisited = const Value.absent(),
    this.latE5 = const Value.absent(),
    this.lonE5 = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VisitsLifetimeCompanion.insert({
    required int res,
    required String cellId,
    required int firstTs,
    required int lastTs,
    required int samples,
    this.daysVisited = const Value.absent(),
    required int latE5,
    required int lonE5,
    this.rowid = const Value.absent(),
  }) : res = Value(res),
       cellId = Value(cellId),
       firstTs = Value(firstTs),
       lastTs = Value(lastTs),
       samples = Value(samples),
       latE5 = Value(latE5),
       lonE5 = Value(lonE5);
  static Insertable<VisitsLifetimeData> custom({
    Expression<int>? res,
    Expression<String>? cellId,
    Expression<int>? firstTs,
    Expression<int>? lastTs,
    Expression<int>? samples,
    Expression<int>? daysVisited,
    Expression<int>? latE5,
    Expression<int>? lonE5,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (res != null) 'res': res,
      if (cellId != null) 'cell_id': cellId,
      if (firstTs != null) 'first_ts': firstTs,
      if (lastTs != null) 'last_ts': lastTs,
      if (samples != null) 'samples': samples,
      if (daysVisited != null) 'days_visited': daysVisited,
      if (latE5 != null) 'lat_e5': latE5,
      if (lonE5 != null) 'lon_e5': lonE5,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VisitsLifetimeCompanion copyWith({
    Value<int>? res,
    Value<String>? cellId,
    Value<int>? firstTs,
    Value<int>? lastTs,
    Value<int>? samples,
    Value<int>? daysVisited,
    Value<int>? latE5,
    Value<int>? lonE5,
    Value<int>? rowid,
  }) {
    return VisitsLifetimeCompanion(
      res: res ?? this.res,
      cellId: cellId ?? this.cellId,
      firstTs: firstTs ?? this.firstTs,
      lastTs: lastTs ?? this.lastTs,
      samples: samples ?? this.samples,
      daysVisited: daysVisited ?? this.daysVisited,
      latE5: latE5 ?? this.latE5,
      lonE5: lonE5 ?? this.lonE5,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (res.present) {
      map['res'] = Variable<int>(res.value);
    }
    if (cellId.present) {
      map['cell_id'] = Variable<String>(cellId.value);
    }
    if (firstTs.present) {
      map['first_ts'] = Variable<int>(firstTs.value);
    }
    if (lastTs.present) {
      map['last_ts'] = Variable<int>(lastTs.value);
    }
    if (samples.present) {
      map['samples'] = Variable<int>(samples.value);
    }
    if (daysVisited.present) {
      map['days_visited'] = Variable<int>(daysVisited.value);
    }
    if (latE5.present) {
      map['lat_e5'] = Variable<int>(latE5.value);
    }
    if (lonE5.present) {
      map['lon_e5'] = Variable<int>(lonE5.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitsLifetimeCompanion(')
          ..write('res: $res, ')
          ..write('cellId: $cellId, ')
          ..write('firstTs: $firstTs, ')
          ..write('lastTs: $lastTs, ')
          ..write('samples: $samples, ')
          ..write('daysVisited: $daysVisited, ')
          ..write('latE5: $latE5, ')
          ..write('lonE5: $lonE5, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VisitsLifetimeDaysTable extends VisitsLifetimeDays
    with TableInfo<$VisitsLifetimeDaysTable, VisitsLifetimeDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitsLifetimeDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _resMeta = const VerificationMeta('res');
  @override
  late final GeneratedColumn<int> res = GeneratedColumn<int>(
    'res',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cellIdMeta = const VerificationMeta('cellId');
  @override
  late final GeneratedColumn<String> cellId = GeneratedColumn<String>(
    'cell_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayYyyyMmddMeta = const VerificationMeta(
    'dayYyyyMmdd',
  );
  @override
  late final GeneratedColumn<int> dayYyyyMmdd = GeneratedColumn<int>(
    'day_yyyy_mmdd',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [res, cellId, dayYyyyMmdd];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visits_lifetime_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<VisitsLifetimeDay> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('res')) {
      context.handle(
        _resMeta,
        res.isAcceptableOrUnknown(data['res']!, _resMeta),
      );
    } else if (isInserting) {
      context.missing(_resMeta);
    }
    if (data.containsKey('cell_id')) {
      context.handle(
        _cellIdMeta,
        cellId.isAcceptableOrUnknown(data['cell_id']!, _cellIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cellIdMeta);
    }
    if (data.containsKey('day_yyyy_mmdd')) {
      context.handle(
        _dayYyyyMmddMeta,
        dayYyyyMmdd.isAcceptableOrUnknown(
          data['day_yyyy_mmdd']!,
          _dayYyyyMmddMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dayYyyyMmddMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {res, cellId, dayYyyyMmdd};
  @override
  VisitsLifetimeDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VisitsLifetimeDay(
      res: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}res'],
      )!,
      cellId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cell_id'],
      )!,
      dayYyyyMmdd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_yyyy_mmdd'],
      )!,
    );
  }

  @override
  $VisitsLifetimeDaysTable createAlias(String alias) {
    return $VisitsLifetimeDaysTable(attachedDatabase, alias);
  }
}

class VisitsLifetimeDay extends DataClass
    implements Insertable<VisitsLifetimeDay> {
  final int res;
  final String cellId;
  final int dayYyyyMmdd;
  const VisitsLifetimeDay({
    required this.res,
    required this.cellId,
    required this.dayYyyyMmdd,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['res'] = Variable<int>(res);
    map['cell_id'] = Variable<String>(cellId);
    map['day_yyyy_mmdd'] = Variable<int>(dayYyyyMmdd);
    return map;
  }

  VisitsLifetimeDaysCompanion toCompanion(bool nullToAbsent) {
    return VisitsLifetimeDaysCompanion(
      res: Value(res),
      cellId: Value(cellId),
      dayYyyyMmdd: Value(dayYyyyMmdd),
    );
  }

  factory VisitsLifetimeDay.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VisitsLifetimeDay(
      res: serializer.fromJson<int>(json['res']),
      cellId: serializer.fromJson<String>(json['cellId']),
      dayYyyyMmdd: serializer.fromJson<int>(json['dayYyyyMmdd']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'res': serializer.toJson<int>(res),
      'cellId': serializer.toJson<String>(cellId),
      'dayYyyyMmdd': serializer.toJson<int>(dayYyyyMmdd),
    };
  }

  VisitsLifetimeDay copyWith({int? res, String? cellId, int? dayYyyyMmdd}) =>
      VisitsLifetimeDay(
        res: res ?? this.res,
        cellId: cellId ?? this.cellId,
        dayYyyyMmdd: dayYyyyMmdd ?? this.dayYyyyMmdd,
      );
  VisitsLifetimeDay copyWithCompanion(VisitsLifetimeDaysCompanion data) {
    return VisitsLifetimeDay(
      res: data.res.present ? data.res.value : this.res,
      cellId: data.cellId.present ? data.cellId.value : this.cellId,
      dayYyyyMmdd: data.dayYyyyMmdd.present
          ? data.dayYyyyMmdd.value
          : this.dayYyyyMmdd,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VisitsLifetimeDay(')
          ..write('res: $res, ')
          ..write('cellId: $cellId, ')
          ..write('dayYyyyMmdd: $dayYyyyMmdd')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(res, cellId, dayYyyyMmdd);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VisitsLifetimeDay &&
          other.res == this.res &&
          other.cellId == this.cellId &&
          other.dayYyyyMmdd == this.dayYyyyMmdd);
}

class VisitsLifetimeDaysCompanion extends UpdateCompanion<VisitsLifetimeDay> {
  final Value<int> res;
  final Value<String> cellId;
  final Value<int> dayYyyyMmdd;
  final Value<int> rowid;
  const VisitsLifetimeDaysCompanion({
    this.res = const Value.absent(),
    this.cellId = const Value.absent(),
    this.dayYyyyMmdd = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VisitsLifetimeDaysCompanion.insert({
    required int res,
    required String cellId,
    required int dayYyyyMmdd,
    this.rowid = const Value.absent(),
  }) : res = Value(res),
       cellId = Value(cellId),
       dayYyyyMmdd = Value(dayYyyyMmdd);
  static Insertable<VisitsLifetimeDay> custom({
    Expression<int>? res,
    Expression<String>? cellId,
    Expression<int>? dayYyyyMmdd,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (res != null) 'res': res,
      if (cellId != null) 'cell_id': cellId,
      if (dayYyyyMmdd != null) 'day_yyyy_mmdd': dayYyyyMmdd,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VisitsLifetimeDaysCompanion copyWith({
    Value<int>? res,
    Value<String>? cellId,
    Value<int>? dayYyyyMmdd,
    Value<int>? rowid,
  }) {
    return VisitsLifetimeDaysCompanion(
      res: res ?? this.res,
      cellId: cellId ?? this.cellId,
      dayYyyyMmdd: dayYyyyMmdd ?? this.dayYyyyMmdd,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (res.present) {
      map['res'] = Variable<int>(res.value);
    }
    if (cellId.present) {
      map['cell_id'] = Variable<String>(cellId.value);
    }
    if (dayYyyyMmdd.present) {
      map['day_yyyy_mmdd'] = Variable<int>(dayYyyyMmdd.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitsLifetimeDaysCompanion(')
          ..write('res: $res, ')
          ..write('cellId: $cellId, ')
          ..write('dayYyyyMmdd: $dayYyyyMmdd, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VisitedGridMetaTable extends VisitedGridMeta
    with TableInfo<$VisitedGridMetaTable, VisitedGridMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitedGridMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastCleanupTsMeta = const VerificationMeta(
    'lastCleanupTs',
  );
  @override
  late final GeneratedColumn<int> lastCleanupTs = GeneratedColumn<int>(
    'last_cleanup_ts',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, lastCleanupTs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visited_grid_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<VisitedGridMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('last_cleanup_ts')) {
      context.handle(
        _lastCleanupTsMeta,
        lastCleanupTs.isAcceptableOrUnknown(
          data['last_cleanup_ts']!,
          _lastCleanupTsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VisitedGridMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VisitedGridMetaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lastCleanupTs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_cleanup_ts'],
      ),
    );
  }

  @override
  $VisitedGridMetaTable createAlias(String alias) {
    return $VisitedGridMetaTable(attachedDatabase, alias);
  }
}

class VisitedGridMetaData extends DataClass
    implements Insertable<VisitedGridMetaData> {
  final int id;
  final int? lastCleanupTs;
  const VisitedGridMetaData({required this.id, this.lastCleanupTs});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || lastCleanupTs != null) {
      map['last_cleanup_ts'] = Variable<int>(lastCleanupTs);
    }
    return map;
  }

  VisitedGridMetaCompanion toCompanion(bool nullToAbsent) {
    return VisitedGridMetaCompanion(
      id: Value(id),
      lastCleanupTs: lastCleanupTs == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCleanupTs),
    );
  }

  factory VisitedGridMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VisitedGridMetaData(
      id: serializer.fromJson<int>(json['id']),
      lastCleanupTs: serializer.fromJson<int?>(json['lastCleanupTs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lastCleanupTs': serializer.toJson<int?>(lastCleanupTs),
    };
  }

  VisitedGridMetaData copyWith({
    int? id,
    Value<int?> lastCleanupTs = const Value.absent(),
  }) => VisitedGridMetaData(
    id: id ?? this.id,
    lastCleanupTs: lastCleanupTs.present
        ? lastCleanupTs.value
        : this.lastCleanupTs,
  );
  VisitedGridMetaData copyWithCompanion(VisitedGridMetaCompanion data) {
    return VisitedGridMetaData(
      id: data.id.present ? data.id.value : this.id,
      lastCleanupTs: data.lastCleanupTs.present
          ? data.lastCleanupTs.value
          : this.lastCleanupTs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VisitedGridMetaData(')
          ..write('id: $id, ')
          ..write('lastCleanupTs: $lastCleanupTs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, lastCleanupTs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VisitedGridMetaData &&
          other.id == this.id &&
          other.lastCleanupTs == this.lastCleanupTs);
}

class VisitedGridMetaCompanion extends UpdateCompanion<VisitedGridMetaData> {
  final Value<int> id;
  final Value<int?> lastCleanupTs;
  const VisitedGridMetaCompanion({
    this.id = const Value.absent(),
    this.lastCleanupTs = const Value.absent(),
  });
  VisitedGridMetaCompanion.insert({
    this.id = const Value.absent(),
    this.lastCleanupTs = const Value.absent(),
  });
  static Insertable<VisitedGridMetaData> custom({
    Expression<int>? id,
    Expression<int>? lastCleanupTs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastCleanupTs != null) 'last_cleanup_ts': lastCleanupTs,
    });
  }

  VisitedGridMetaCompanion copyWith({
    Value<int>? id,
    Value<int?>? lastCleanupTs,
  }) {
    return VisitedGridMetaCompanion(
      id: id ?? this.id,
      lastCleanupTs: lastCleanupTs ?? this.lastCleanupTs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lastCleanupTs.present) {
      map['last_cleanup_ts'] = Variable<int>(lastCleanupTs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitedGridMetaCompanion(')
          ..write('id: $id, ')
          ..write('lastCleanupTs: $lastCleanupTs')
          ..write(')'))
        .toString();
  }
}

abstract class _$VisitedGridDatabase extends GeneratedDatabase {
  _$VisitedGridDatabase(QueryExecutor e) : super(e);
  $VisitedGridDatabaseManager get managers => $VisitedGridDatabaseManager(this);
  late final $VisitsDailyTable visitsDaily = $VisitsDailyTable(this);
  late final $VisitsLifetimeTable visitsLifetime = $VisitsLifetimeTable(this);
  late final $VisitsLifetimeDaysTable visitsLifetimeDays =
      $VisitsLifetimeDaysTable(this);
  late final $VisitedGridMetaTable visitedGridMeta = $VisitedGridMetaTable(
    this,
  );
  late final VisitedGridDao visitedGridDao = VisitedGridDao(
    this as VisitedGridDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    visitsDaily,
    visitsLifetime,
    visitsLifetimeDays,
    visitedGridMeta,
  ];
}

typedef $$VisitsDailyTableCreateCompanionBuilder =
    VisitsDailyCompanion Function({
      required int res,
      required String cellId,
      required int dayYyyyMmdd,
      required int hourMask,
      required int firstTs,
      required int lastTs,
      required int samples,
      required int latE5,
      required int lonE5,
      Value<int> rowid,
    });
typedef $$VisitsDailyTableUpdateCompanionBuilder =
    VisitsDailyCompanion Function({
      Value<int> res,
      Value<String> cellId,
      Value<int> dayYyyyMmdd,
      Value<int> hourMask,
      Value<int> firstTs,
      Value<int> lastTs,
      Value<int> samples,
      Value<int> latE5,
      Value<int> lonE5,
      Value<int> rowid,
    });

class $$VisitsDailyTableFilterComposer
    extends Composer<_$VisitedGridDatabase, $VisitsDailyTable> {
  $$VisitsDailyTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get res => $composableBuilder(
    column: $table.res,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cellId => $composableBuilder(
    column: $table.cellId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayYyyyMmdd => $composableBuilder(
    column: $table.dayYyyyMmdd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hourMask => $composableBuilder(
    column: $table.hourMask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstTs => $composableBuilder(
    column: $table.firstTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastTs => $composableBuilder(
    column: $table.lastTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get samples => $composableBuilder(
    column: $table.samples,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get latE5 => $composableBuilder(
    column: $table.latE5,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lonE5 => $composableBuilder(
    column: $table.lonE5,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VisitsDailyTableOrderingComposer
    extends Composer<_$VisitedGridDatabase, $VisitsDailyTable> {
  $$VisitsDailyTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get res => $composableBuilder(
    column: $table.res,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cellId => $composableBuilder(
    column: $table.cellId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayYyyyMmdd => $composableBuilder(
    column: $table.dayYyyyMmdd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hourMask => $composableBuilder(
    column: $table.hourMask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstTs => $composableBuilder(
    column: $table.firstTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastTs => $composableBuilder(
    column: $table.lastTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get samples => $composableBuilder(
    column: $table.samples,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get latE5 => $composableBuilder(
    column: $table.latE5,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lonE5 => $composableBuilder(
    column: $table.lonE5,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VisitsDailyTableAnnotationComposer
    extends Composer<_$VisitedGridDatabase, $VisitsDailyTable> {
  $$VisitsDailyTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get res =>
      $composableBuilder(column: $table.res, builder: (column) => column);

  GeneratedColumn<String> get cellId =>
      $composableBuilder(column: $table.cellId, builder: (column) => column);

  GeneratedColumn<int> get dayYyyyMmdd => $composableBuilder(
    column: $table.dayYyyyMmdd,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hourMask =>
      $composableBuilder(column: $table.hourMask, builder: (column) => column);

  GeneratedColumn<int> get firstTs =>
      $composableBuilder(column: $table.firstTs, builder: (column) => column);

  GeneratedColumn<int> get lastTs =>
      $composableBuilder(column: $table.lastTs, builder: (column) => column);

  GeneratedColumn<int> get samples =>
      $composableBuilder(column: $table.samples, builder: (column) => column);

  GeneratedColumn<int> get latE5 =>
      $composableBuilder(column: $table.latE5, builder: (column) => column);

  GeneratedColumn<int> get lonE5 =>
      $composableBuilder(column: $table.lonE5, builder: (column) => column);
}

class $$VisitsDailyTableTableManager
    extends
        RootTableManager<
          _$VisitedGridDatabase,
          $VisitsDailyTable,
          VisitsDailyData,
          $$VisitsDailyTableFilterComposer,
          $$VisitsDailyTableOrderingComposer,
          $$VisitsDailyTableAnnotationComposer,
          $$VisitsDailyTableCreateCompanionBuilder,
          $$VisitsDailyTableUpdateCompanionBuilder,
          (
            VisitsDailyData,
            BaseReferences<
              _$VisitedGridDatabase,
              $VisitsDailyTable,
              VisitsDailyData
            >,
          ),
          VisitsDailyData,
          PrefetchHooks Function()
        > {
  $$VisitsDailyTableTableManager(
    _$VisitedGridDatabase db,
    $VisitsDailyTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitsDailyTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitsDailyTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VisitsDailyTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> res = const Value.absent(),
                Value<String> cellId = const Value.absent(),
                Value<int> dayYyyyMmdd = const Value.absent(),
                Value<int> hourMask = const Value.absent(),
                Value<int> firstTs = const Value.absent(),
                Value<int> lastTs = const Value.absent(),
                Value<int> samples = const Value.absent(),
                Value<int> latE5 = const Value.absent(),
                Value<int> lonE5 = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitsDailyCompanion(
                res: res,
                cellId: cellId,
                dayYyyyMmdd: dayYyyyMmdd,
                hourMask: hourMask,
                firstTs: firstTs,
                lastTs: lastTs,
                samples: samples,
                latE5: latE5,
                lonE5: lonE5,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int res,
                required String cellId,
                required int dayYyyyMmdd,
                required int hourMask,
                required int firstTs,
                required int lastTs,
                required int samples,
                required int latE5,
                required int lonE5,
                Value<int> rowid = const Value.absent(),
              }) => VisitsDailyCompanion.insert(
                res: res,
                cellId: cellId,
                dayYyyyMmdd: dayYyyyMmdd,
                hourMask: hourMask,
                firstTs: firstTs,
                lastTs: lastTs,
                samples: samples,
                latE5: latE5,
                lonE5: lonE5,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VisitsDailyTableProcessedTableManager =
    ProcessedTableManager<
      _$VisitedGridDatabase,
      $VisitsDailyTable,
      VisitsDailyData,
      $$VisitsDailyTableFilterComposer,
      $$VisitsDailyTableOrderingComposer,
      $$VisitsDailyTableAnnotationComposer,
      $$VisitsDailyTableCreateCompanionBuilder,
      $$VisitsDailyTableUpdateCompanionBuilder,
      (
        VisitsDailyData,
        BaseReferences<
          _$VisitedGridDatabase,
          $VisitsDailyTable,
          VisitsDailyData
        >,
      ),
      VisitsDailyData,
      PrefetchHooks Function()
    >;
typedef $$VisitsLifetimeTableCreateCompanionBuilder =
    VisitsLifetimeCompanion Function({
      required int res,
      required String cellId,
      required int firstTs,
      required int lastTs,
      required int samples,
      Value<int> daysVisited,
      required int latE5,
      required int lonE5,
      Value<int> rowid,
    });
typedef $$VisitsLifetimeTableUpdateCompanionBuilder =
    VisitsLifetimeCompanion Function({
      Value<int> res,
      Value<String> cellId,
      Value<int> firstTs,
      Value<int> lastTs,
      Value<int> samples,
      Value<int> daysVisited,
      Value<int> latE5,
      Value<int> lonE5,
      Value<int> rowid,
    });

class $$VisitsLifetimeTableFilterComposer
    extends Composer<_$VisitedGridDatabase, $VisitsLifetimeTable> {
  $$VisitsLifetimeTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get res => $composableBuilder(
    column: $table.res,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cellId => $composableBuilder(
    column: $table.cellId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstTs => $composableBuilder(
    column: $table.firstTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastTs => $composableBuilder(
    column: $table.lastTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get samples => $composableBuilder(
    column: $table.samples,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get daysVisited => $composableBuilder(
    column: $table.daysVisited,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get latE5 => $composableBuilder(
    column: $table.latE5,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lonE5 => $composableBuilder(
    column: $table.lonE5,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VisitsLifetimeTableOrderingComposer
    extends Composer<_$VisitedGridDatabase, $VisitsLifetimeTable> {
  $$VisitsLifetimeTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get res => $composableBuilder(
    column: $table.res,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cellId => $composableBuilder(
    column: $table.cellId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstTs => $composableBuilder(
    column: $table.firstTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastTs => $composableBuilder(
    column: $table.lastTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get samples => $composableBuilder(
    column: $table.samples,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get daysVisited => $composableBuilder(
    column: $table.daysVisited,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get latE5 => $composableBuilder(
    column: $table.latE5,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lonE5 => $composableBuilder(
    column: $table.lonE5,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VisitsLifetimeTableAnnotationComposer
    extends Composer<_$VisitedGridDatabase, $VisitsLifetimeTable> {
  $$VisitsLifetimeTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get res =>
      $composableBuilder(column: $table.res, builder: (column) => column);

  GeneratedColumn<String> get cellId =>
      $composableBuilder(column: $table.cellId, builder: (column) => column);

  GeneratedColumn<int> get firstTs =>
      $composableBuilder(column: $table.firstTs, builder: (column) => column);

  GeneratedColumn<int> get lastTs =>
      $composableBuilder(column: $table.lastTs, builder: (column) => column);

  GeneratedColumn<int> get samples =>
      $composableBuilder(column: $table.samples, builder: (column) => column);

  GeneratedColumn<int> get daysVisited => $composableBuilder(
    column: $table.daysVisited,
    builder: (column) => column,
  );

  GeneratedColumn<int> get latE5 =>
      $composableBuilder(column: $table.latE5, builder: (column) => column);

  GeneratedColumn<int> get lonE5 =>
      $composableBuilder(column: $table.lonE5, builder: (column) => column);
}

class $$VisitsLifetimeTableTableManager
    extends
        RootTableManager<
          _$VisitedGridDatabase,
          $VisitsLifetimeTable,
          VisitsLifetimeData,
          $$VisitsLifetimeTableFilterComposer,
          $$VisitsLifetimeTableOrderingComposer,
          $$VisitsLifetimeTableAnnotationComposer,
          $$VisitsLifetimeTableCreateCompanionBuilder,
          $$VisitsLifetimeTableUpdateCompanionBuilder,
          (
            VisitsLifetimeData,
            BaseReferences<
              _$VisitedGridDatabase,
              $VisitsLifetimeTable,
              VisitsLifetimeData
            >,
          ),
          VisitsLifetimeData,
          PrefetchHooks Function()
        > {
  $$VisitsLifetimeTableTableManager(
    _$VisitedGridDatabase db,
    $VisitsLifetimeTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitsLifetimeTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitsLifetimeTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VisitsLifetimeTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> res = const Value.absent(),
                Value<String> cellId = const Value.absent(),
                Value<int> firstTs = const Value.absent(),
                Value<int> lastTs = const Value.absent(),
                Value<int> samples = const Value.absent(),
                Value<int> daysVisited = const Value.absent(),
                Value<int> latE5 = const Value.absent(),
                Value<int> lonE5 = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitsLifetimeCompanion(
                res: res,
                cellId: cellId,
                firstTs: firstTs,
                lastTs: lastTs,
                samples: samples,
                daysVisited: daysVisited,
                latE5: latE5,
                lonE5: lonE5,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int res,
                required String cellId,
                required int firstTs,
                required int lastTs,
                required int samples,
                Value<int> daysVisited = const Value.absent(),
                required int latE5,
                required int lonE5,
                Value<int> rowid = const Value.absent(),
              }) => VisitsLifetimeCompanion.insert(
                res: res,
                cellId: cellId,
                firstTs: firstTs,
                lastTs: lastTs,
                samples: samples,
                daysVisited: daysVisited,
                latE5: latE5,
                lonE5: lonE5,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VisitsLifetimeTableProcessedTableManager =
    ProcessedTableManager<
      _$VisitedGridDatabase,
      $VisitsLifetimeTable,
      VisitsLifetimeData,
      $$VisitsLifetimeTableFilterComposer,
      $$VisitsLifetimeTableOrderingComposer,
      $$VisitsLifetimeTableAnnotationComposer,
      $$VisitsLifetimeTableCreateCompanionBuilder,
      $$VisitsLifetimeTableUpdateCompanionBuilder,
      (
        VisitsLifetimeData,
        BaseReferences<
          _$VisitedGridDatabase,
          $VisitsLifetimeTable,
          VisitsLifetimeData
        >,
      ),
      VisitsLifetimeData,
      PrefetchHooks Function()
    >;
typedef $$VisitsLifetimeDaysTableCreateCompanionBuilder =
    VisitsLifetimeDaysCompanion Function({
      required int res,
      required String cellId,
      required int dayYyyyMmdd,
      Value<int> rowid,
    });
typedef $$VisitsLifetimeDaysTableUpdateCompanionBuilder =
    VisitsLifetimeDaysCompanion Function({
      Value<int> res,
      Value<String> cellId,
      Value<int> dayYyyyMmdd,
      Value<int> rowid,
    });

class $$VisitsLifetimeDaysTableFilterComposer
    extends Composer<_$VisitedGridDatabase, $VisitsLifetimeDaysTable> {
  $$VisitsLifetimeDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get res => $composableBuilder(
    column: $table.res,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cellId => $composableBuilder(
    column: $table.cellId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayYyyyMmdd => $composableBuilder(
    column: $table.dayYyyyMmdd,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VisitsLifetimeDaysTableOrderingComposer
    extends Composer<_$VisitedGridDatabase, $VisitsLifetimeDaysTable> {
  $$VisitsLifetimeDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get res => $composableBuilder(
    column: $table.res,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cellId => $composableBuilder(
    column: $table.cellId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayYyyyMmdd => $composableBuilder(
    column: $table.dayYyyyMmdd,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VisitsLifetimeDaysTableAnnotationComposer
    extends Composer<_$VisitedGridDatabase, $VisitsLifetimeDaysTable> {
  $$VisitsLifetimeDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get res =>
      $composableBuilder(column: $table.res, builder: (column) => column);

  GeneratedColumn<String> get cellId =>
      $composableBuilder(column: $table.cellId, builder: (column) => column);

  GeneratedColumn<int> get dayYyyyMmdd => $composableBuilder(
    column: $table.dayYyyyMmdd,
    builder: (column) => column,
  );
}

class $$VisitsLifetimeDaysTableTableManager
    extends
        RootTableManager<
          _$VisitedGridDatabase,
          $VisitsLifetimeDaysTable,
          VisitsLifetimeDay,
          $$VisitsLifetimeDaysTableFilterComposer,
          $$VisitsLifetimeDaysTableOrderingComposer,
          $$VisitsLifetimeDaysTableAnnotationComposer,
          $$VisitsLifetimeDaysTableCreateCompanionBuilder,
          $$VisitsLifetimeDaysTableUpdateCompanionBuilder,
          (
            VisitsLifetimeDay,
            BaseReferences<
              _$VisitedGridDatabase,
              $VisitsLifetimeDaysTable,
              VisitsLifetimeDay
            >,
          ),
          VisitsLifetimeDay,
          PrefetchHooks Function()
        > {
  $$VisitsLifetimeDaysTableTableManager(
    _$VisitedGridDatabase db,
    $VisitsLifetimeDaysTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitsLifetimeDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitsLifetimeDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VisitsLifetimeDaysTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> res = const Value.absent(),
                Value<String> cellId = const Value.absent(),
                Value<int> dayYyyyMmdd = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitsLifetimeDaysCompanion(
                res: res,
                cellId: cellId,
                dayYyyyMmdd: dayYyyyMmdd,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int res,
                required String cellId,
                required int dayYyyyMmdd,
                Value<int> rowid = const Value.absent(),
              }) => VisitsLifetimeDaysCompanion.insert(
                res: res,
                cellId: cellId,
                dayYyyyMmdd: dayYyyyMmdd,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VisitsLifetimeDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$VisitedGridDatabase,
      $VisitsLifetimeDaysTable,
      VisitsLifetimeDay,
      $$VisitsLifetimeDaysTableFilterComposer,
      $$VisitsLifetimeDaysTableOrderingComposer,
      $$VisitsLifetimeDaysTableAnnotationComposer,
      $$VisitsLifetimeDaysTableCreateCompanionBuilder,
      $$VisitsLifetimeDaysTableUpdateCompanionBuilder,
      (
        VisitsLifetimeDay,
        BaseReferences<
          _$VisitedGridDatabase,
          $VisitsLifetimeDaysTable,
          VisitsLifetimeDay
        >,
      ),
      VisitsLifetimeDay,
      PrefetchHooks Function()
    >;
typedef $$VisitedGridMetaTableCreateCompanionBuilder =
    VisitedGridMetaCompanion Function({
      Value<int> id,
      Value<int?> lastCleanupTs,
    });
typedef $$VisitedGridMetaTableUpdateCompanionBuilder =
    VisitedGridMetaCompanion Function({
      Value<int> id,
      Value<int?> lastCleanupTs,
    });

class $$VisitedGridMetaTableFilterComposer
    extends Composer<_$VisitedGridDatabase, $VisitedGridMetaTable> {
  $$VisitedGridMetaTableFilterComposer({
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

  ColumnFilters<int> get lastCleanupTs => $composableBuilder(
    column: $table.lastCleanupTs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VisitedGridMetaTableOrderingComposer
    extends Composer<_$VisitedGridDatabase, $VisitedGridMetaTable> {
  $$VisitedGridMetaTableOrderingComposer({
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

  ColumnOrderings<int> get lastCleanupTs => $composableBuilder(
    column: $table.lastCleanupTs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VisitedGridMetaTableAnnotationComposer
    extends Composer<_$VisitedGridDatabase, $VisitedGridMetaTable> {
  $$VisitedGridMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get lastCleanupTs => $composableBuilder(
    column: $table.lastCleanupTs,
    builder: (column) => column,
  );
}

class $$VisitedGridMetaTableTableManager
    extends
        RootTableManager<
          _$VisitedGridDatabase,
          $VisitedGridMetaTable,
          VisitedGridMetaData,
          $$VisitedGridMetaTableFilterComposer,
          $$VisitedGridMetaTableOrderingComposer,
          $$VisitedGridMetaTableAnnotationComposer,
          $$VisitedGridMetaTableCreateCompanionBuilder,
          $$VisitedGridMetaTableUpdateCompanionBuilder,
          (
            VisitedGridMetaData,
            BaseReferences<
              _$VisitedGridDatabase,
              $VisitedGridMetaTable,
              VisitedGridMetaData
            >,
          ),
          VisitedGridMetaData,
          PrefetchHooks Function()
        > {
  $$VisitedGridMetaTableTableManager(
    _$VisitedGridDatabase db,
    $VisitedGridMetaTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitedGridMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitedGridMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VisitedGridMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> lastCleanupTs = const Value.absent(),
              }) => VisitedGridMetaCompanion(
                id: id,
                lastCleanupTs: lastCleanupTs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> lastCleanupTs = const Value.absent(),
              }) => VisitedGridMetaCompanion.insert(
                id: id,
                lastCleanupTs: lastCleanupTs,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VisitedGridMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$VisitedGridDatabase,
      $VisitedGridMetaTable,
      VisitedGridMetaData,
      $$VisitedGridMetaTableFilterComposer,
      $$VisitedGridMetaTableOrderingComposer,
      $$VisitedGridMetaTableAnnotationComposer,
      $$VisitedGridMetaTableCreateCompanionBuilder,
      $$VisitedGridMetaTableUpdateCompanionBuilder,
      (
        VisitedGridMetaData,
        BaseReferences<
          _$VisitedGridDatabase,
          $VisitedGridMetaTable,
          VisitedGridMetaData
        >,
      ),
      VisitedGridMetaData,
      PrefetchHooks Function()
    >;

class $VisitedGridDatabaseManager {
  final _$VisitedGridDatabase _db;
  $VisitedGridDatabaseManager(this._db);
  $$VisitsDailyTableTableManager get visitsDaily =>
      $$VisitsDailyTableTableManager(_db, _db.visitsDaily);
  $$VisitsLifetimeTableTableManager get visitsLifetime =>
      $$VisitsLifetimeTableTableManager(_db, _db.visitsLifetime);
  $$VisitsLifetimeDaysTableTableManager get visitsLifetimeDays =>
      $$VisitsLifetimeDaysTableTableManager(_db, _db.visitsLifetimeDays);
  $$VisitedGridMetaTableTableManager get visitedGridMeta =>
      $$VisitedGridMetaTableTableManager(_db, _db.visitedGridMeta);
}

mixin _$VisitedGridDaoMixin on DatabaseAccessor<VisitedGridDatabase> {
  $VisitsDailyTable get visitsDaily => attachedDatabase.visitsDaily;
  $VisitsLifetimeTable get visitsLifetime => attachedDatabase.visitsLifetime;
  $VisitsLifetimeDaysTable get visitsLifetimeDays =>
      attachedDatabase.visitsLifetimeDays;
  $VisitedGridMetaTable get visitedGridMeta => attachedDatabase.visitedGridMeta;
  VisitedGridDaoManager get managers => VisitedGridDaoManager(this);
}

class VisitedGridDaoManager {
  final _$VisitedGridDaoMixin _db;
  VisitedGridDaoManager(this._db);
  $$VisitsDailyTableTableManager get visitsDaily =>
      $$VisitsDailyTableTableManager(_db.attachedDatabase, _db.visitsDaily);
  $$VisitsLifetimeTableTableManager get visitsLifetime =>
      $$VisitsLifetimeTableTableManager(
        _db.attachedDatabase,
        _db.visitsLifetime,
      );
  $$VisitsLifetimeDaysTableTableManager get visitsLifetimeDays =>
      $$VisitsLifetimeDaysTableTableManager(
        _db.attachedDatabase,
        _db.visitsLifetimeDays,
      );
  $$VisitedGridMetaTableTableManager get visitedGridMeta =>
      $$VisitedGridMetaTableTableManager(
        _db.attachedDatabase,
        _db.visitedGridMeta,
      );
}
