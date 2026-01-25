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

class $VisitedCellBoundsTable extends VisitedCellBounds
    with TableInfo<$VisitedCellBoundsTable, VisitedCellBound> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitedCellBoundsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _segmentMeta = const VerificationMeta(
    'segment',
  );
  @override
  late final GeneratedColumn<int> segment = GeneratedColumn<int>(
    'segment',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minLatE5Meta = const VerificationMeta(
    'minLatE5',
  );
  @override
  late final GeneratedColumn<int> minLatE5 = GeneratedColumn<int>(
    'min_lat_e5',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxLatE5Meta = const VerificationMeta(
    'maxLatE5',
  );
  @override
  late final GeneratedColumn<int> maxLatE5 = GeneratedColumn<int>(
    'max_lat_e5',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minLonE5Meta = const VerificationMeta(
    'minLonE5',
  );
  @override
  late final GeneratedColumn<int> minLonE5 = GeneratedColumn<int>(
    'min_lon_e5',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxLonE5Meta = const VerificationMeta(
    'maxLonE5',
  );
  @override
  late final GeneratedColumn<int> maxLonE5 = GeneratedColumn<int>(
    'max_lon_e5',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    res,
    cellId,
    segment,
    minLatE5,
    maxLatE5,
    minLonE5,
    maxLonE5,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visited_cell_bounds';
  @override
  VerificationContext validateIntegrity(
    Insertable<VisitedCellBound> instance, {
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
    if (data.containsKey('segment')) {
      context.handle(
        _segmentMeta,
        segment.isAcceptableOrUnknown(data['segment']!, _segmentMeta),
      );
    } else if (isInserting) {
      context.missing(_segmentMeta);
    }
    if (data.containsKey('min_lat_e5')) {
      context.handle(
        _minLatE5Meta,
        minLatE5.isAcceptableOrUnknown(data['min_lat_e5']!, _minLatE5Meta),
      );
    } else if (isInserting) {
      context.missing(_minLatE5Meta);
    }
    if (data.containsKey('max_lat_e5')) {
      context.handle(
        _maxLatE5Meta,
        maxLatE5.isAcceptableOrUnknown(data['max_lat_e5']!, _maxLatE5Meta),
      );
    } else if (isInserting) {
      context.missing(_maxLatE5Meta);
    }
    if (data.containsKey('min_lon_e5')) {
      context.handle(
        _minLonE5Meta,
        minLonE5.isAcceptableOrUnknown(data['min_lon_e5']!, _minLonE5Meta),
      );
    } else if (isInserting) {
      context.missing(_minLonE5Meta);
    }
    if (data.containsKey('max_lon_e5')) {
      context.handle(
        _maxLonE5Meta,
        maxLonE5.isAcceptableOrUnknown(data['max_lon_e5']!, _maxLonE5Meta),
      );
    } else if (isInserting) {
      context.missing(_maxLonE5Meta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {res, cellId, segment};
  @override
  VisitedCellBound map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VisitedCellBound(
      res: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}res'],
      )!,
      cellId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cell_id'],
      )!,
      segment: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}segment'],
      )!,
      minLatE5: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_lat_e5'],
      )!,
      maxLatE5: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_lat_e5'],
      )!,
      minLonE5: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_lon_e5'],
      )!,
      maxLonE5: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_lon_e5'],
      )!,
    );
  }

  @override
  $VisitedCellBoundsTable createAlias(String alias) {
    return $VisitedCellBoundsTable(attachedDatabase, alias);
  }
}

class VisitedCellBound extends DataClass
    implements Insertable<VisitedCellBound> {
  final int res;
  final String cellId;
  final int segment;
  final int minLatE5;
  final int maxLatE5;
  final int minLonE5;
  final int maxLonE5;
  const VisitedCellBound({
    required this.res,
    required this.cellId,
    required this.segment,
    required this.minLatE5,
    required this.maxLatE5,
    required this.minLonE5,
    required this.maxLonE5,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['res'] = Variable<int>(res);
    map['cell_id'] = Variable<String>(cellId);
    map['segment'] = Variable<int>(segment);
    map['min_lat_e5'] = Variable<int>(minLatE5);
    map['max_lat_e5'] = Variable<int>(maxLatE5);
    map['min_lon_e5'] = Variable<int>(minLonE5);
    map['max_lon_e5'] = Variable<int>(maxLonE5);
    return map;
  }

  VisitedCellBoundsCompanion toCompanion(bool nullToAbsent) {
    return VisitedCellBoundsCompanion(
      res: Value(res),
      cellId: Value(cellId),
      segment: Value(segment),
      minLatE5: Value(minLatE5),
      maxLatE5: Value(maxLatE5),
      minLonE5: Value(minLonE5),
      maxLonE5: Value(maxLonE5),
    );
  }

  factory VisitedCellBound.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VisitedCellBound(
      res: serializer.fromJson<int>(json['res']),
      cellId: serializer.fromJson<String>(json['cellId']),
      segment: serializer.fromJson<int>(json['segment']),
      minLatE5: serializer.fromJson<int>(json['minLatE5']),
      maxLatE5: serializer.fromJson<int>(json['maxLatE5']),
      minLonE5: serializer.fromJson<int>(json['minLonE5']),
      maxLonE5: serializer.fromJson<int>(json['maxLonE5']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'res': serializer.toJson<int>(res),
      'cellId': serializer.toJson<String>(cellId),
      'segment': serializer.toJson<int>(segment),
      'minLatE5': serializer.toJson<int>(minLatE5),
      'maxLatE5': serializer.toJson<int>(maxLatE5),
      'minLonE5': serializer.toJson<int>(minLonE5),
      'maxLonE5': serializer.toJson<int>(maxLonE5),
    };
  }

  VisitedCellBound copyWith({
    int? res,
    String? cellId,
    int? segment,
    int? minLatE5,
    int? maxLatE5,
    int? minLonE5,
    int? maxLonE5,
  }) => VisitedCellBound(
    res: res ?? this.res,
    cellId: cellId ?? this.cellId,
    segment: segment ?? this.segment,
    minLatE5: minLatE5 ?? this.minLatE5,
    maxLatE5: maxLatE5 ?? this.maxLatE5,
    minLonE5: minLonE5 ?? this.minLonE5,
    maxLonE5: maxLonE5 ?? this.maxLonE5,
  );
  VisitedCellBound copyWithCompanion(VisitedCellBoundsCompanion data) {
    return VisitedCellBound(
      res: data.res.present ? data.res.value : this.res,
      cellId: data.cellId.present ? data.cellId.value : this.cellId,
      segment: data.segment.present ? data.segment.value : this.segment,
      minLatE5: data.minLatE5.present ? data.minLatE5.value : this.minLatE5,
      maxLatE5: data.maxLatE5.present ? data.maxLatE5.value : this.maxLatE5,
      minLonE5: data.minLonE5.present ? data.minLonE5.value : this.minLonE5,
      maxLonE5: data.maxLonE5.present ? data.maxLonE5.value : this.maxLonE5,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VisitedCellBound(')
          ..write('res: $res, ')
          ..write('cellId: $cellId, ')
          ..write('segment: $segment, ')
          ..write('minLatE5: $minLatE5, ')
          ..write('maxLatE5: $maxLatE5, ')
          ..write('minLonE5: $minLonE5, ')
          ..write('maxLonE5: $maxLonE5')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(res, cellId, segment, minLatE5, maxLatE5, minLonE5, maxLonE5);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VisitedCellBound &&
          other.res == this.res &&
          other.cellId == this.cellId &&
          other.segment == this.segment &&
          other.minLatE5 == this.minLatE5 &&
          other.maxLatE5 == this.maxLatE5 &&
          other.minLonE5 == this.minLonE5 &&
          other.maxLonE5 == this.maxLonE5);
}

class VisitedCellBoundsCompanion extends UpdateCompanion<VisitedCellBound> {
  final Value<int> res;
  final Value<String> cellId;
  final Value<int> segment;
  final Value<int> minLatE5;
  final Value<int> maxLatE5;
  final Value<int> minLonE5;
  final Value<int> maxLonE5;
  final Value<int> rowid;
  const VisitedCellBoundsCompanion({
    this.res = const Value.absent(),
    this.cellId = const Value.absent(),
    this.segment = const Value.absent(),
    this.minLatE5 = const Value.absent(),
    this.maxLatE5 = const Value.absent(),
    this.minLonE5 = const Value.absent(),
    this.maxLonE5 = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VisitedCellBoundsCompanion.insert({
    required int res,
    required String cellId,
    required int segment,
    required int minLatE5,
    required int maxLatE5,
    required int minLonE5,
    required int maxLonE5,
    this.rowid = const Value.absent(),
  }) : res = Value(res),
       cellId = Value(cellId),
       segment = Value(segment),
       minLatE5 = Value(minLatE5),
       maxLatE5 = Value(maxLatE5),
       minLonE5 = Value(minLonE5),
       maxLonE5 = Value(maxLonE5);
  static Insertable<VisitedCellBound> custom({
    Expression<int>? res,
    Expression<String>? cellId,
    Expression<int>? segment,
    Expression<int>? minLatE5,
    Expression<int>? maxLatE5,
    Expression<int>? minLonE5,
    Expression<int>? maxLonE5,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (res != null) 'res': res,
      if (cellId != null) 'cell_id': cellId,
      if (segment != null) 'segment': segment,
      if (minLatE5 != null) 'min_lat_e5': minLatE5,
      if (maxLatE5 != null) 'max_lat_e5': maxLatE5,
      if (minLonE5 != null) 'min_lon_e5': minLonE5,
      if (maxLonE5 != null) 'max_lon_e5': maxLonE5,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VisitedCellBoundsCompanion copyWith({
    Value<int>? res,
    Value<String>? cellId,
    Value<int>? segment,
    Value<int>? minLatE5,
    Value<int>? maxLatE5,
    Value<int>? minLonE5,
    Value<int>? maxLonE5,
    Value<int>? rowid,
  }) {
    return VisitedCellBoundsCompanion(
      res: res ?? this.res,
      cellId: cellId ?? this.cellId,
      segment: segment ?? this.segment,
      minLatE5: minLatE5 ?? this.minLatE5,
      maxLatE5: maxLatE5 ?? this.maxLatE5,
      minLonE5: minLonE5 ?? this.minLonE5,
      maxLonE5: maxLonE5 ?? this.maxLonE5,
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
    if (segment.present) {
      map['segment'] = Variable<int>(segment.value);
    }
    if (minLatE5.present) {
      map['min_lat_e5'] = Variable<int>(minLatE5.value);
    }
    if (maxLatE5.present) {
      map['max_lat_e5'] = Variable<int>(maxLatE5.value);
    }
    if (minLonE5.present) {
      map['min_lon_e5'] = Variable<int>(minLonE5.value);
    }
    if (maxLonE5.present) {
      map['max_lon_e5'] = Variable<int>(maxLonE5.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitedCellBoundsCompanion(')
          ..write('res: $res, ')
          ..write('cellId: $cellId, ')
          ..write('segment: $segment, ')
          ..write('minLatE5: $minLatE5, ')
          ..write('maxLatE5: $maxLatE5, ')
          ..write('minLonE5: $minLonE5, ')
          ..write('maxLonE5: $maxLonE5, ')
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
  static const VerificationMeta _gridVersionMeta = const VerificationMeta(
    'gridVersion',
  );
  @override
  late final GeneratedColumn<int> gridVersion = GeneratedColumn<int>(
    'grid_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, lastCleanupTs, gridVersion];
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
    if (data.containsKey('grid_version')) {
      context.handle(
        _gridVersionMeta,
        gridVersion.isAcceptableOrUnknown(
          data['grid_version']!,
          _gridVersionMeta,
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
      gridVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grid_version'],
      )!,
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
  final int gridVersion;
  const VisitedGridMetaData({
    required this.id,
    this.lastCleanupTs,
    required this.gridVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || lastCleanupTs != null) {
      map['last_cleanup_ts'] = Variable<int>(lastCleanupTs);
    }
    map['grid_version'] = Variable<int>(gridVersion);
    return map;
  }

  VisitedGridMetaCompanion toCompanion(bool nullToAbsent) {
    return VisitedGridMetaCompanion(
      id: Value(id),
      lastCleanupTs: lastCleanupTs == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCleanupTs),
      gridVersion: Value(gridVersion),
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
      gridVersion: serializer.fromJson<int>(json['gridVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lastCleanupTs': serializer.toJson<int?>(lastCleanupTs),
      'gridVersion': serializer.toJson<int>(gridVersion),
    };
  }

  VisitedGridMetaData copyWith({
    int? id,
    Value<int?> lastCleanupTs = const Value.absent(),
    int? gridVersion,
  }) => VisitedGridMetaData(
    id: id ?? this.id,
    lastCleanupTs: lastCleanupTs.present
        ? lastCleanupTs.value
        : this.lastCleanupTs,
    gridVersion: gridVersion ?? this.gridVersion,
  );
  VisitedGridMetaData copyWithCompanion(VisitedGridMetaCompanion data) {
    return VisitedGridMetaData(
      id: data.id.present ? data.id.value : this.id,
      lastCleanupTs: data.lastCleanupTs.present
          ? data.lastCleanupTs.value
          : this.lastCleanupTs,
      gridVersion: data.gridVersion.present
          ? data.gridVersion.value
          : this.gridVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VisitedGridMetaData(')
          ..write('id: $id, ')
          ..write('lastCleanupTs: $lastCleanupTs, ')
          ..write('gridVersion: $gridVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, lastCleanupTs, gridVersion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VisitedGridMetaData &&
          other.id == this.id &&
          other.lastCleanupTs == this.lastCleanupTs &&
          other.gridVersion == this.gridVersion);
}

class VisitedGridMetaCompanion extends UpdateCompanion<VisitedGridMetaData> {
  final Value<int> id;
  final Value<int?> lastCleanupTs;
  final Value<int> gridVersion;
  const VisitedGridMetaCompanion({
    this.id = const Value.absent(),
    this.lastCleanupTs = const Value.absent(),
    this.gridVersion = const Value.absent(),
  });
  VisitedGridMetaCompanion.insert({
    this.id = const Value.absent(),
    this.lastCleanupTs = const Value.absent(),
    this.gridVersion = const Value.absent(),
  });
  static Insertable<VisitedGridMetaData> custom({
    Expression<int>? id,
    Expression<int>? lastCleanupTs,
    Expression<int>? gridVersion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastCleanupTs != null) 'last_cleanup_ts': lastCleanupTs,
      if (gridVersion != null) 'grid_version': gridVersion,
    });
  }

  VisitedGridMetaCompanion copyWith({
    Value<int>? id,
    Value<int?>? lastCleanupTs,
    Value<int>? gridVersion,
  }) {
    return VisitedGridMetaCompanion(
      id: id ?? this.id,
      lastCleanupTs: lastCleanupTs ?? this.lastCleanupTs,
      gridVersion: gridVersion ?? this.gridVersion,
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
    if (gridVersion.present) {
      map['grid_version'] = Variable<int>(gridVersion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitedGridMetaCompanion(')
          ..write('id: $id, ')
          ..write('lastCleanupTs: $lastCleanupTs, ')
          ..write('gridVersion: $gridVersion')
          ..write(')'))
        .toString();
  }
}

class $VisitedGridStatsTableTable extends VisitedGridStatsTable
    with TableInfo<$VisitedGridStatsTableTable, VisitedGridStatsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitedGridStatsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _totalAreaM2Meta = const VerificationMeta(
    'totalAreaM2',
  );
  @override
  late final GeneratedColumn<double> totalAreaM2 = GeneratedColumn<double>(
    'total_area_m2',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cellCountMeta = const VerificationMeta(
    'cellCount',
  );
  @override
  late final GeneratedColumn<int> cellCount = GeneratedColumn<int>(
    'cell_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _canonicalVersionMeta = const VerificationMeta(
    'canonicalVersion',
  );
  @override
  late final GeneratedColumn<int> canonicalVersion = GeneratedColumn<int>(
    'canonical_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastUpdatedTsMeta = const VerificationMeta(
    'lastUpdatedTs',
  );
  @override
  late final GeneratedColumn<int> lastUpdatedTs = GeneratedColumn<int>(
    'last_updated_ts',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastReconciledTsMeta = const VerificationMeta(
    'lastReconciledTs',
  );
  @override
  late final GeneratedColumn<int> lastReconciledTs = GeneratedColumn<int>(
    'last_reconciled_ts',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    totalAreaM2,
    cellCount,
    canonicalVersion,
    lastUpdatedTs,
    lastReconciledTs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visited_grid_stats';
  @override
  VerificationContext validateIntegrity(
    Insertable<VisitedGridStatsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('total_area_m2')) {
      context.handle(
        _totalAreaM2Meta,
        totalAreaM2.isAcceptableOrUnknown(
          data['total_area_m2']!,
          _totalAreaM2Meta,
        ),
      );
    }
    if (data.containsKey('cell_count')) {
      context.handle(
        _cellCountMeta,
        cellCount.isAcceptableOrUnknown(data['cell_count']!, _cellCountMeta),
      );
    }
    if (data.containsKey('canonical_version')) {
      context.handle(
        _canonicalVersionMeta,
        canonicalVersion.isAcceptableOrUnknown(
          data['canonical_version']!,
          _canonicalVersionMeta,
        ),
      );
    }
    if (data.containsKey('last_updated_ts')) {
      context.handle(
        _lastUpdatedTsMeta,
        lastUpdatedTs.isAcceptableOrUnknown(
          data['last_updated_ts']!,
          _lastUpdatedTsMeta,
        ),
      );
    }
    if (data.containsKey('last_reconciled_ts')) {
      context.handle(
        _lastReconciledTsMeta,
        lastReconciledTs.isAcceptableOrUnknown(
          data['last_reconciled_ts']!,
          _lastReconciledTsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VisitedGridStatsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VisitedGridStatsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      totalAreaM2: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_area_m2'],
      )!,
      cellCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cell_count'],
      )!,
      canonicalVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}canonical_version'],
      )!,
      lastUpdatedTs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_updated_ts'],
      ),
      lastReconciledTs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_reconciled_ts'],
      ),
    );
  }

  @override
  $VisitedGridStatsTableTable createAlias(String alias) {
    return $VisitedGridStatsTableTable(attachedDatabase, alias);
  }
}

class VisitedGridStatsRow extends DataClass
    implements Insertable<VisitedGridStatsRow> {
  final int id;
  final double totalAreaM2;
  final int cellCount;
  final int canonicalVersion;
  final int? lastUpdatedTs;
  final int? lastReconciledTs;
  const VisitedGridStatsRow({
    required this.id,
    required this.totalAreaM2,
    required this.cellCount,
    required this.canonicalVersion,
    this.lastUpdatedTs,
    this.lastReconciledTs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['total_area_m2'] = Variable<double>(totalAreaM2);
    map['cell_count'] = Variable<int>(cellCount);
    map['canonical_version'] = Variable<int>(canonicalVersion);
    if (!nullToAbsent || lastUpdatedTs != null) {
      map['last_updated_ts'] = Variable<int>(lastUpdatedTs);
    }
    if (!nullToAbsent || lastReconciledTs != null) {
      map['last_reconciled_ts'] = Variable<int>(lastReconciledTs);
    }
    return map;
  }

  VisitedGridStatsTableCompanion toCompanion(bool nullToAbsent) {
    return VisitedGridStatsTableCompanion(
      id: Value(id),
      totalAreaM2: Value(totalAreaM2),
      cellCount: Value(cellCount),
      canonicalVersion: Value(canonicalVersion),
      lastUpdatedTs: lastUpdatedTs == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUpdatedTs),
      lastReconciledTs: lastReconciledTs == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReconciledTs),
    );
  }

  factory VisitedGridStatsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VisitedGridStatsRow(
      id: serializer.fromJson<int>(json['id']),
      totalAreaM2: serializer.fromJson<double>(json['totalAreaM2']),
      cellCount: serializer.fromJson<int>(json['cellCount']),
      canonicalVersion: serializer.fromJson<int>(json['canonicalVersion']),
      lastUpdatedTs: serializer.fromJson<int?>(json['lastUpdatedTs']),
      lastReconciledTs: serializer.fromJson<int?>(json['lastReconciledTs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'totalAreaM2': serializer.toJson<double>(totalAreaM2),
      'cellCount': serializer.toJson<int>(cellCount),
      'canonicalVersion': serializer.toJson<int>(canonicalVersion),
      'lastUpdatedTs': serializer.toJson<int?>(lastUpdatedTs),
      'lastReconciledTs': serializer.toJson<int?>(lastReconciledTs),
    };
  }

  VisitedGridStatsRow copyWith({
    int? id,
    double? totalAreaM2,
    int? cellCount,
    int? canonicalVersion,
    Value<int?> lastUpdatedTs = const Value.absent(),
    Value<int?> lastReconciledTs = const Value.absent(),
  }) => VisitedGridStatsRow(
    id: id ?? this.id,
    totalAreaM2: totalAreaM2 ?? this.totalAreaM2,
    cellCount: cellCount ?? this.cellCount,
    canonicalVersion: canonicalVersion ?? this.canonicalVersion,
    lastUpdatedTs: lastUpdatedTs.present
        ? lastUpdatedTs.value
        : this.lastUpdatedTs,
    lastReconciledTs: lastReconciledTs.present
        ? lastReconciledTs.value
        : this.lastReconciledTs,
  );
  VisitedGridStatsRow copyWithCompanion(VisitedGridStatsTableCompanion data) {
    return VisitedGridStatsRow(
      id: data.id.present ? data.id.value : this.id,
      totalAreaM2: data.totalAreaM2.present
          ? data.totalAreaM2.value
          : this.totalAreaM2,
      cellCount: data.cellCount.present ? data.cellCount.value : this.cellCount,
      canonicalVersion: data.canonicalVersion.present
          ? data.canonicalVersion.value
          : this.canonicalVersion,
      lastUpdatedTs: data.lastUpdatedTs.present
          ? data.lastUpdatedTs.value
          : this.lastUpdatedTs,
      lastReconciledTs: data.lastReconciledTs.present
          ? data.lastReconciledTs.value
          : this.lastReconciledTs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VisitedGridStatsRow(')
          ..write('id: $id, ')
          ..write('totalAreaM2: $totalAreaM2, ')
          ..write('cellCount: $cellCount, ')
          ..write('canonicalVersion: $canonicalVersion, ')
          ..write('lastUpdatedTs: $lastUpdatedTs, ')
          ..write('lastReconciledTs: $lastReconciledTs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    totalAreaM2,
    cellCount,
    canonicalVersion,
    lastUpdatedTs,
    lastReconciledTs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VisitedGridStatsRow &&
          other.id == this.id &&
          other.totalAreaM2 == this.totalAreaM2 &&
          other.cellCount == this.cellCount &&
          other.canonicalVersion == this.canonicalVersion &&
          other.lastUpdatedTs == this.lastUpdatedTs &&
          other.lastReconciledTs == this.lastReconciledTs);
}

class VisitedGridStatsTableCompanion
    extends UpdateCompanion<VisitedGridStatsRow> {
  final Value<int> id;
  final Value<double> totalAreaM2;
  final Value<int> cellCount;
  final Value<int> canonicalVersion;
  final Value<int?> lastUpdatedTs;
  final Value<int?> lastReconciledTs;
  const VisitedGridStatsTableCompanion({
    this.id = const Value.absent(),
    this.totalAreaM2 = const Value.absent(),
    this.cellCount = const Value.absent(),
    this.canonicalVersion = const Value.absent(),
    this.lastUpdatedTs = const Value.absent(),
    this.lastReconciledTs = const Value.absent(),
  });
  VisitedGridStatsTableCompanion.insert({
    this.id = const Value.absent(),
    this.totalAreaM2 = const Value.absent(),
    this.cellCount = const Value.absent(),
    this.canonicalVersion = const Value.absent(),
    this.lastUpdatedTs = const Value.absent(),
    this.lastReconciledTs = const Value.absent(),
  });
  static Insertable<VisitedGridStatsRow> custom({
    Expression<int>? id,
    Expression<double>? totalAreaM2,
    Expression<int>? cellCount,
    Expression<int>? canonicalVersion,
    Expression<int>? lastUpdatedTs,
    Expression<int>? lastReconciledTs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (totalAreaM2 != null) 'total_area_m2': totalAreaM2,
      if (cellCount != null) 'cell_count': cellCount,
      if (canonicalVersion != null) 'canonical_version': canonicalVersion,
      if (lastUpdatedTs != null) 'last_updated_ts': lastUpdatedTs,
      if (lastReconciledTs != null) 'last_reconciled_ts': lastReconciledTs,
    });
  }

  VisitedGridStatsTableCompanion copyWith({
    Value<int>? id,
    Value<double>? totalAreaM2,
    Value<int>? cellCount,
    Value<int>? canonicalVersion,
    Value<int?>? lastUpdatedTs,
    Value<int?>? lastReconciledTs,
  }) {
    return VisitedGridStatsTableCompanion(
      id: id ?? this.id,
      totalAreaM2: totalAreaM2 ?? this.totalAreaM2,
      cellCount: cellCount ?? this.cellCount,
      canonicalVersion: canonicalVersion ?? this.canonicalVersion,
      lastUpdatedTs: lastUpdatedTs ?? this.lastUpdatedTs,
      lastReconciledTs: lastReconciledTs ?? this.lastReconciledTs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (totalAreaM2.present) {
      map['total_area_m2'] = Variable<double>(totalAreaM2.value);
    }
    if (cellCount.present) {
      map['cell_count'] = Variable<int>(cellCount.value);
    }
    if (canonicalVersion.present) {
      map['canonical_version'] = Variable<int>(canonicalVersion.value);
    }
    if (lastUpdatedTs.present) {
      map['last_updated_ts'] = Variable<int>(lastUpdatedTs.value);
    }
    if (lastReconciledTs.present) {
      map['last_reconciled_ts'] = Variable<int>(lastReconciledTs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitedGridStatsTableCompanion(')
          ..write('id: $id, ')
          ..write('totalAreaM2: $totalAreaM2, ')
          ..write('cellCount: $cellCount, ')
          ..write('canonicalVersion: $canonicalVersion, ')
          ..write('lastUpdatedTs: $lastUpdatedTs, ')
          ..write('lastReconciledTs: $lastReconciledTs')
          ..write(')'))
        .toString();
  }
}

class $VisitedCellAreaCacheTable extends VisitedCellAreaCache
    with TableInfo<$VisitedCellAreaCacheTable, VisitedCellAreaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitedCellAreaCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cellIdMeta = const VerificationMeta('cellId');
  @override
  late final GeneratedColumn<String> cellId = GeneratedColumn<String>(
    'cell_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _areaKm2Meta = const VerificationMeta(
    'areaKm2',
  );
  @override
  late final GeneratedColumn<double> areaKm2 = GeneratedColumn<double>(
    'area_km2',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [cellId, areaKm2];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visited_cell_area_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<VisitedCellAreaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cell_id')) {
      context.handle(
        _cellIdMeta,
        cellId.isAcceptableOrUnknown(data['cell_id']!, _cellIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cellIdMeta);
    }
    if (data.containsKey('area_km2')) {
      context.handle(
        _areaKm2Meta,
        areaKm2.isAcceptableOrUnknown(data['area_km2']!, _areaKm2Meta),
      );
    } else if (isInserting) {
      context.missing(_areaKm2Meta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cellId};
  @override
  VisitedCellAreaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VisitedCellAreaRow(
      cellId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cell_id'],
      )!,
      areaKm2: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}area_km2'],
      )!,
    );
  }

  @override
  $VisitedCellAreaCacheTable createAlias(String alias) {
    return $VisitedCellAreaCacheTable(attachedDatabase, alias);
  }
}

class VisitedCellAreaRow extends DataClass
    implements Insertable<VisitedCellAreaRow> {
  final String cellId;
  final double areaKm2;
  const VisitedCellAreaRow({required this.cellId, required this.areaKm2});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cell_id'] = Variable<String>(cellId);
    map['area_km2'] = Variable<double>(areaKm2);
    return map;
  }

  VisitedCellAreaCacheCompanion toCompanion(bool nullToAbsent) {
    return VisitedCellAreaCacheCompanion(
      cellId: Value(cellId),
      areaKm2: Value(areaKm2),
    );
  }

  factory VisitedCellAreaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VisitedCellAreaRow(
      cellId: serializer.fromJson<String>(json['cellId']),
      areaKm2: serializer.fromJson<double>(json['areaKm2']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cellId': serializer.toJson<String>(cellId),
      'areaKm2': serializer.toJson<double>(areaKm2),
    };
  }

  VisitedCellAreaRow copyWith({String? cellId, double? areaKm2}) =>
      VisitedCellAreaRow(
        cellId: cellId ?? this.cellId,
        areaKm2: areaKm2 ?? this.areaKm2,
      );
  VisitedCellAreaRow copyWithCompanion(VisitedCellAreaCacheCompanion data) {
    return VisitedCellAreaRow(
      cellId: data.cellId.present ? data.cellId.value : this.cellId,
      areaKm2: data.areaKm2.present ? data.areaKm2.value : this.areaKm2,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VisitedCellAreaRow(')
          ..write('cellId: $cellId, ')
          ..write('areaKm2: $areaKm2')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cellId, areaKm2);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VisitedCellAreaRow &&
          other.cellId == this.cellId &&
          other.areaKm2 == this.areaKm2);
}

class VisitedCellAreaCacheCompanion
    extends UpdateCompanion<VisitedCellAreaRow> {
  final Value<String> cellId;
  final Value<double> areaKm2;
  final Value<int> rowid;
  const VisitedCellAreaCacheCompanion({
    this.cellId = const Value.absent(),
    this.areaKm2 = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VisitedCellAreaCacheCompanion.insert({
    required String cellId,
    required double areaKm2,
    this.rowid = const Value.absent(),
  }) : cellId = Value(cellId),
       areaKm2 = Value(areaKm2);
  static Insertable<VisitedCellAreaRow> custom({
    Expression<String>? cellId,
    Expression<double>? areaKm2,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cellId != null) 'cell_id': cellId,
      if (areaKm2 != null) 'area_km2': areaKm2,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VisitedCellAreaCacheCompanion copyWith({
    Value<String>? cellId,
    Value<double>? areaKm2,
    Value<int>? rowid,
  }) {
    return VisitedCellAreaCacheCompanion(
      cellId: cellId ?? this.cellId,
      areaKm2: areaKm2 ?? this.areaKm2,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cellId.present) {
      map['cell_id'] = Variable<String>(cellId.value);
    }
    if (areaKm2.present) {
      map['area_km2'] = Variable<double>(areaKm2.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitedCellAreaCacheCompanion(')
          ..write('cellId: $cellId, ')
          ..write('areaKm2: $areaKm2, ')
          ..write('rowid: $rowid')
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
  late final $VisitedCellBoundsTable visitedCellBounds =
      $VisitedCellBoundsTable(this);
  late final $VisitedGridMetaTable visitedGridMeta = $VisitedGridMetaTable(
    this,
  );
  late final $VisitedGridStatsTableTable visitedGridStatsTable =
      $VisitedGridStatsTableTable(this);
  late final $VisitedCellAreaCacheTable visitedCellAreaCache =
      $VisitedCellAreaCacheTable(this);
  late final Index visitsDailyResDay = Index(
    'visits_daily_res_day',
    'CREATE INDEX visits_daily_res_day ON visits_daily (res, day_yyyy_mmdd)',
  );
  late final Index visitsDailyResCell = Index(
    'visits_daily_res_cell',
    'CREATE INDEX visits_daily_res_cell ON visits_daily (res, cell_id)',
  );
  late final Index visitsLifetimeRes = Index(
    'visits_lifetime_res',
    'CREATE INDEX visits_lifetime_res ON visits_lifetime (res)',
  );
  late final Index visitsLifetimeDaysResDay = Index(
    'visits_lifetime_days_res_day',
    'CREATE INDEX visits_lifetime_days_res_day ON visits_lifetime_days (res, day_yyyy_mmdd)',
  );
  late final Index cellBoundsResLat = Index(
    'cell_bounds_res_lat',
    'CREATE INDEX cell_bounds_res_lat ON visited_cell_bounds (res, min_lat_e5, max_lat_e5)',
  );
  late final Index cellBoundsResLon = Index(
    'cell_bounds_res_lon',
    'CREATE INDEX cell_bounds_res_lon ON visited_cell_bounds (res, min_lon_e5, max_lon_e5)',
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
    visitedCellBounds,
    visitedGridMeta,
    visitedGridStatsTable,
    visitedCellAreaCache,
    visitsDailyResDay,
    visitsDailyResCell,
    visitsLifetimeRes,
    visitsLifetimeDaysResDay,
    cellBoundsResLat,
    cellBoundsResLon,
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
typedef $$VisitedCellBoundsTableCreateCompanionBuilder =
    VisitedCellBoundsCompanion Function({
      required int res,
      required String cellId,
      required int segment,
      required int minLatE5,
      required int maxLatE5,
      required int minLonE5,
      required int maxLonE5,
      Value<int> rowid,
    });
typedef $$VisitedCellBoundsTableUpdateCompanionBuilder =
    VisitedCellBoundsCompanion Function({
      Value<int> res,
      Value<String> cellId,
      Value<int> segment,
      Value<int> minLatE5,
      Value<int> maxLatE5,
      Value<int> minLonE5,
      Value<int> maxLonE5,
      Value<int> rowid,
    });

class $$VisitedCellBoundsTableFilterComposer
    extends Composer<_$VisitedGridDatabase, $VisitedCellBoundsTable> {
  $$VisitedCellBoundsTableFilterComposer({
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

  ColumnFilters<int> get segment => $composableBuilder(
    column: $table.segment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minLatE5 => $composableBuilder(
    column: $table.minLatE5,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxLatE5 => $composableBuilder(
    column: $table.maxLatE5,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minLonE5 => $composableBuilder(
    column: $table.minLonE5,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxLonE5 => $composableBuilder(
    column: $table.maxLonE5,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VisitedCellBoundsTableOrderingComposer
    extends Composer<_$VisitedGridDatabase, $VisitedCellBoundsTable> {
  $$VisitedCellBoundsTableOrderingComposer({
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

  ColumnOrderings<int> get segment => $composableBuilder(
    column: $table.segment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minLatE5 => $composableBuilder(
    column: $table.minLatE5,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxLatE5 => $composableBuilder(
    column: $table.maxLatE5,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minLonE5 => $composableBuilder(
    column: $table.minLonE5,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxLonE5 => $composableBuilder(
    column: $table.maxLonE5,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VisitedCellBoundsTableAnnotationComposer
    extends Composer<_$VisitedGridDatabase, $VisitedCellBoundsTable> {
  $$VisitedCellBoundsTableAnnotationComposer({
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

  GeneratedColumn<int> get segment =>
      $composableBuilder(column: $table.segment, builder: (column) => column);

  GeneratedColumn<int> get minLatE5 =>
      $composableBuilder(column: $table.minLatE5, builder: (column) => column);

  GeneratedColumn<int> get maxLatE5 =>
      $composableBuilder(column: $table.maxLatE5, builder: (column) => column);

  GeneratedColumn<int> get minLonE5 =>
      $composableBuilder(column: $table.minLonE5, builder: (column) => column);

  GeneratedColumn<int> get maxLonE5 =>
      $composableBuilder(column: $table.maxLonE5, builder: (column) => column);
}

class $$VisitedCellBoundsTableTableManager
    extends
        RootTableManager<
          _$VisitedGridDatabase,
          $VisitedCellBoundsTable,
          VisitedCellBound,
          $$VisitedCellBoundsTableFilterComposer,
          $$VisitedCellBoundsTableOrderingComposer,
          $$VisitedCellBoundsTableAnnotationComposer,
          $$VisitedCellBoundsTableCreateCompanionBuilder,
          $$VisitedCellBoundsTableUpdateCompanionBuilder,
          (
            VisitedCellBound,
            BaseReferences<
              _$VisitedGridDatabase,
              $VisitedCellBoundsTable,
              VisitedCellBound
            >,
          ),
          VisitedCellBound,
          PrefetchHooks Function()
        > {
  $$VisitedCellBoundsTableTableManager(
    _$VisitedGridDatabase db,
    $VisitedCellBoundsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitedCellBoundsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitedCellBoundsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VisitedCellBoundsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> res = const Value.absent(),
                Value<String> cellId = const Value.absent(),
                Value<int> segment = const Value.absent(),
                Value<int> minLatE5 = const Value.absent(),
                Value<int> maxLatE5 = const Value.absent(),
                Value<int> minLonE5 = const Value.absent(),
                Value<int> maxLonE5 = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitedCellBoundsCompanion(
                res: res,
                cellId: cellId,
                segment: segment,
                minLatE5: minLatE5,
                maxLatE5: maxLatE5,
                minLonE5: minLonE5,
                maxLonE5: maxLonE5,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int res,
                required String cellId,
                required int segment,
                required int minLatE5,
                required int maxLatE5,
                required int minLonE5,
                required int maxLonE5,
                Value<int> rowid = const Value.absent(),
              }) => VisitedCellBoundsCompanion.insert(
                res: res,
                cellId: cellId,
                segment: segment,
                minLatE5: minLatE5,
                maxLatE5: maxLatE5,
                minLonE5: minLonE5,
                maxLonE5: maxLonE5,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VisitedCellBoundsTableProcessedTableManager =
    ProcessedTableManager<
      _$VisitedGridDatabase,
      $VisitedCellBoundsTable,
      VisitedCellBound,
      $$VisitedCellBoundsTableFilterComposer,
      $$VisitedCellBoundsTableOrderingComposer,
      $$VisitedCellBoundsTableAnnotationComposer,
      $$VisitedCellBoundsTableCreateCompanionBuilder,
      $$VisitedCellBoundsTableUpdateCompanionBuilder,
      (
        VisitedCellBound,
        BaseReferences<
          _$VisitedGridDatabase,
          $VisitedCellBoundsTable,
          VisitedCellBound
        >,
      ),
      VisitedCellBound,
      PrefetchHooks Function()
    >;
typedef $$VisitedGridMetaTableCreateCompanionBuilder =
    VisitedGridMetaCompanion Function({
      Value<int> id,
      Value<int?> lastCleanupTs,
      Value<int> gridVersion,
    });
typedef $$VisitedGridMetaTableUpdateCompanionBuilder =
    VisitedGridMetaCompanion Function({
      Value<int> id,
      Value<int?> lastCleanupTs,
      Value<int> gridVersion,
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

  ColumnFilters<int> get gridVersion => $composableBuilder(
    column: $table.gridVersion,
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

  ColumnOrderings<int> get gridVersion => $composableBuilder(
    column: $table.gridVersion,
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

  GeneratedColumn<int> get gridVersion => $composableBuilder(
    column: $table.gridVersion,
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
                Value<int> gridVersion = const Value.absent(),
              }) => VisitedGridMetaCompanion(
                id: id,
                lastCleanupTs: lastCleanupTs,
                gridVersion: gridVersion,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> lastCleanupTs = const Value.absent(),
                Value<int> gridVersion = const Value.absent(),
              }) => VisitedGridMetaCompanion.insert(
                id: id,
                lastCleanupTs: lastCleanupTs,
                gridVersion: gridVersion,
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
typedef $$VisitedGridStatsTableTableCreateCompanionBuilder =
    VisitedGridStatsTableCompanion Function({
      Value<int> id,
      Value<double> totalAreaM2,
      Value<int> cellCount,
      Value<int> canonicalVersion,
      Value<int?> lastUpdatedTs,
      Value<int?> lastReconciledTs,
    });
typedef $$VisitedGridStatsTableTableUpdateCompanionBuilder =
    VisitedGridStatsTableCompanion Function({
      Value<int> id,
      Value<double> totalAreaM2,
      Value<int> cellCount,
      Value<int> canonicalVersion,
      Value<int?> lastUpdatedTs,
      Value<int?> lastReconciledTs,
    });

class $$VisitedGridStatsTableTableFilterComposer
    extends Composer<_$VisitedGridDatabase, $VisitedGridStatsTableTable> {
  $$VisitedGridStatsTableTableFilterComposer({
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

  ColumnFilters<double> get totalAreaM2 => $composableBuilder(
    column: $table.totalAreaM2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cellCount => $composableBuilder(
    column: $table.cellCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get canonicalVersion => $composableBuilder(
    column: $table.canonicalVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastUpdatedTs => $composableBuilder(
    column: $table.lastUpdatedTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastReconciledTs => $composableBuilder(
    column: $table.lastReconciledTs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VisitedGridStatsTableTableOrderingComposer
    extends Composer<_$VisitedGridDatabase, $VisitedGridStatsTableTable> {
  $$VisitedGridStatsTableTableOrderingComposer({
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

  ColumnOrderings<double> get totalAreaM2 => $composableBuilder(
    column: $table.totalAreaM2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cellCount => $composableBuilder(
    column: $table.cellCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get canonicalVersion => $composableBuilder(
    column: $table.canonicalVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastUpdatedTs => $composableBuilder(
    column: $table.lastUpdatedTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastReconciledTs => $composableBuilder(
    column: $table.lastReconciledTs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VisitedGridStatsTableTableAnnotationComposer
    extends Composer<_$VisitedGridDatabase, $VisitedGridStatsTableTable> {
  $$VisitedGridStatsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get totalAreaM2 => $composableBuilder(
    column: $table.totalAreaM2,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cellCount =>
      $composableBuilder(column: $table.cellCount, builder: (column) => column);

  GeneratedColumn<int> get canonicalVersion => $composableBuilder(
    column: $table.canonicalVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastUpdatedTs => $composableBuilder(
    column: $table.lastUpdatedTs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastReconciledTs => $composableBuilder(
    column: $table.lastReconciledTs,
    builder: (column) => column,
  );
}

class $$VisitedGridStatsTableTableTableManager
    extends
        RootTableManager<
          _$VisitedGridDatabase,
          $VisitedGridStatsTableTable,
          VisitedGridStatsRow,
          $$VisitedGridStatsTableTableFilterComposer,
          $$VisitedGridStatsTableTableOrderingComposer,
          $$VisitedGridStatsTableTableAnnotationComposer,
          $$VisitedGridStatsTableTableCreateCompanionBuilder,
          $$VisitedGridStatsTableTableUpdateCompanionBuilder,
          (
            VisitedGridStatsRow,
            BaseReferences<
              _$VisitedGridDatabase,
              $VisitedGridStatsTableTable,
              VisitedGridStatsRow
            >,
          ),
          VisitedGridStatsRow,
          PrefetchHooks Function()
        > {
  $$VisitedGridStatsTableTableTableManager(
    _$VisitedGridDatabase db,
    $VisitedGridStatsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitedGridStatsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$VisitedGridStatsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$VisitedGridStatsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> totalAreaM2 = const Value.absent(),
                Value<int> cellCount = const Value.absent(),
                Value<int> canonicalVersion = const Value.absent(),
                Value<int?> lastUpdatedTs = const Value.absent(),
                Value<int?> lastReconciledTs = const Value.absent(),
              }) => VisitedGridStatsTableCompanion(
                id: id,
                totalAreaM2: totalAreaM2,
                cellCount: cellCount,
                canonicalVersion: canonicalVersion,
                lastUpdatedTs: lastUpdatedTs,
                lastReconciledTs: lastReconciledTs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> totalAreaM2 = const Value.absent(),
                Value<int> cellCount = const Value.absent(),
                Value<int> canonicalVersion = const Value.absent(),
                Value<int?> lastUpdatedTs = const Value.absent(),
                Value<int?> lastReconciledTs = const Value.absent(),
              }) => VisitedGridStatsTableCompanion.insert(
                id: id,
                totalAreaM2: totalAreaM2,
                cellCount: cellCount,
                canonicalVersion: canonicalVersion,
                lastUpdatedTs: lastUpdatedTs,
                lastReconciledTs: lastReconciledTs,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VisitedGridStatsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$VisitedGridDatabase,
      $VisitedGridStatsTableTable,
      VisitedGridStatsRow,
      $$VisitedGridStatsTableTableFilterComposer,
      $$VisitedGridStatsTableTableOrderingComposer,
      $$VisitedGridStatsTableTableAnnotationComposer,
      $$VisitedGridStatsTableTableCreateCompanionBuilder,
      $$VisitedGridStatsTableTableUpdateCompanionBuilder,
      (
        VisitedGridStatsRow,
        BaseReferences<
          _$VisitedGridDatabase,
          $VisitedGridStatsTableTable,
          VisitedGridStatsRow
        >,
      ),
      VisitedGridStatsRow,
      PrefetchHooks Function()
    >;
typedef $$VisitedCellAreaCacheTableCreateCompanionBuilder =
    VisitedCellAreaCacheCompanion Function({
      required String cellId,
      required double areaKm2,
      Value<int> rowid,
    });
typedef $$VisitedCellAreaCacheTableUpdateCompanionBuilder =
    VisitedCellAreaCacheCompanion Function({
      Value<String> cellId,
      Value<double> areaKm2,
      Value<int> rowid,
    });

class $$VisitedCellAreaCacheTableFilterComposer
    extends Composer<_$VisitedGridDatabase, $VisitedCellAreaCacheTable> {
  $$VisitedCellAreaCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cellId => $composableBuilder(
    column: $table.cellId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get areaKm2 => $composableBuilder(
    column: $table.areaKm2,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VisitedCellAreaCacheTableOrderingComposer
    extends Composer<_$VisitedGridDatabase, $VisitedCellAreaCacheTable> {
  $$VisitedCellAreaCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cellId => $composableBuilder(
    column: $table.cellId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get areaKm2 => $composableBuilder(
    column: $table.areaKm2,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VisitedCellAreaCacheTableAnnotationComposer
    extends Composer<_$VisitedGridDatabase, $VisitedCellAreaCacheTable> {
  $$VisitedCellAreaCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cellId =>
      $composableBuilder(column: $table.cellId, builder: (column) => column);

  GeneratedColumn<double> get areaKm2 =>
      $composableBuilder(column: $table.areaKm2, builder: (column) => column);
}

class $$VisitedCellAreaCacheTableTableManager
    extends
        RootTableManager<
          _$VisitedGridDatabase,
          $VisitedCellAreaCacheTable,
          VisitedCellAreaRow,
          $$VisitedCellAreaCacheTableFilterComposer,
          $$VisitedCellAreaCacheTableOrderingComposer,
          $$VisitedCellAreaCacheTableAnnotationComposer,
          $$VisitedCellAreaCacheTableCreateCompanionBuilder,
          $$VisitedCellAreaCacheTableUpdateCompanionBuilder,
          (
            VisitedCellAreaRow,
            BaseReferences<
              _$VisitedGridDatabase,
              $VisitedCellAreaCacheTable,
              VisitedCellAreaRow
            >,
          ),
          VisitedCellAreaRow,
          PrefetchHooks Function()
        > {
  $$VisitedCellAreaCacheTableTableManager(
    _$VisitedGridDatabase db,
    $VisitedCellAreaCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitedCellAreaCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitedCellAreaCacheTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$VisitedCellAreaCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> cellId = const Value.absent(),
                Value<double> areaKm2 = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitedCellAreaCacheCompanion(
                cellId: cellId,
                areaKm2: areaKm2,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cellId,
                required double areaKm2,
                Value<int> rowid = const Value.absent(),
              }) => VisitedCellAreaCacheCompanion.insert(
                cellId: cellId,
                areaKm2: areaKm2,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VisitedCellAreaCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$VisitedGridDatabase,
      $VisitedCellAreaCacheTable,
      VisitedCellAreaRow,
      $$VisitedCellAreaCacheTableFilterComposer,
      $$VisitedCellAreaCacheTableOrderingComposer,
      $$VisitedCellAreaCacheTableAnnotationComposer,
      $$VisitedCellAreaCacheTableCreateCompanionBuilder,
      $$VisitedCellAreaCacheTableUpdateCompanionBuilder,
      (
        VisitedCellAreaRow,
        BaseReferences<
          _$VisitedGridDatabase,
          $VisitedCellAreaCacheTable,
          VisitedCellAreaRow
        >,
      ),
      VisitedCellAreaRow,
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
  $$VisitedCellBoundsTableTableManager get visitedCellBounds =>
      $$VisitedCellBoundsTableTableManager(_db, _db.visitedCellBounds);
  $$VisitedGridMetaTableTableManager get visitedGridMeta =>
      $$VisitedGridMetaTableTableManager(_db, _db.visitedGridMeta);
  $$VisitedGridStatsTableTableTableManager get visitedGridStatsTable =>
      $$VisitedGridStatsTableTableTableManager(_db, _db.visitedGridStatsTable);
  $$VisitedCellAreaCacheTableTableManager get visitedCellAreaCache =>
      $$VisitedCellAreaCacheTableTableManager(_db, _db.visitedCellAreaCache);
}

mixin _$VisitedGridDaoMixin on DatabaseAccessor<VisitedGridDatabase> {
  $VisitsDailyTable get visitsDaily => attachedDatabase.visitsDaily;
  $VisitsLifetimeTable get visitsLifetime => attachedDatabase.visitsLifetime;
  $VisitsLifetimeDaysTable get visitsLifetimeDays =>
      attachedDatabase.visitsLifetimeDays;
  $VisitedCellBoundsTable get visitedCellBounds =>
      attachedDatabase.visitedCellBounds;
  $VisitedGridMetaTable get visitedGridMeta => attachedDatabase.visitedGridMeta;
  $VisitedGridStatsTableTable get visitedGridStatsTable =>
      attachedDatabase.visitedGridStatsTable;
  $VisitedCellAreaCacheTable get visitedCellAreaCache =>
      attachedDatabase.visitedCellAreaCache;
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
  $$VisitedCellBoundsTableTableManager get visitedCellBounds =>
      $$VisitedCellBoundsTableTableManager(
        _db.attachedDatabase,
        _db.visitedCellBounds,
      );
  $$VisitedGridMetaTableTableManager get visitedGridMeta =>
      $$VisitedGridMetaTableTableManager(
        _db.attachedDatabase,
        _db.visitedGridMeta,
      );
  $$VisitedGridStatsTableTableTableManager get visitedGridStatsTable =>
      $$VisitedGridStatsTableTableTableManager(
        _db.attachedDatabase,
        _db.visitedGridStatsTable,
      );
  $$VisitedCellAreaCacheTableTableManager get visitedCellAreaCache =>
      $$VisitedCellAreaCacheTableTableManager(
        _db.attachedDatabase,
        _db.visitedCellAreaCache,
      );
}
