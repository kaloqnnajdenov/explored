// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_history_database.dart';

// ignore_for_file: type=lint
class $LocationSamplesTable extends LocationSamples
    with TableInfo<$LocationSamplesTable, LocationSample> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationSamplesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<String> timestamp = GeneratedColumn<String>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accuracyMetersMeta = const VerificationMeta(
    'accuracyMeters',
  );
  @override
  late final GeneratedColumn<double> accuracyMeters = GeneratedColumn<double>(
    'accuracy_meters',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isInterpolatedMeta = const VerificationMeta(
    'isInterpolated',
  );
  @override
  late final GeneratedColumn<bool> isInterpolated = GeneratedColumn<bool>(
    'is_interpolated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_interpolated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LatLngSampleSource, String>
  source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<LatLngSampleSource>($LocationSamplesTable.$convertersource);
  static const VerificationMeta _h3BaseMeta = const VerificationMeta('h3Base');
  @override
  late final GeneratedColumn<String> h3Base = GeneratedColumn<String>(
    'h3_base',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    latitude,
    longitude,
    timestamp,
    accuracyMeters,
    isInterpolated,
    source,
    h3Base,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'location_samples';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocationSample> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('accuracy_meters')) {
      context.handle(
        _accuracyMetersMeta,
        accuracyMeters.isAcceptableOrUnknown(
          data['accuracy_meters']!,
          _accuracyMetersMeta,
        ),
      );
    }
    if (data.containsKey('is_interpolated')) {
      context.handle(
        _isInterpolatedMeta,
        isInterpolated.isAcceptableOrUnknown(
          data['is_interpolated']!,
          _isInterpolatedMeta,
        ),
      );
    }
    if (data.containsKey('h3_base')) {
      context.handle(
        _h3BaseMeta,
        h3Base.isAcceptableOrUnknown(data['h3_base']!, _h3BaseMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  LocationSample map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocationSample(
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timestamp'],
      )!,
      accuracyMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy_meters'],
      ),
      isInterpolated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_interpolated'],
      )!,
      source: $LocationSamplesTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      h3Base: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}h3_base'],
      ),
    );
  }

  @override
  $LocationSamplesTable createAlias(String alias) {
    return $LocationSamplesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LatLngSampleSource, String, String>
  $convertersource = const EnumNameConverter<LatLngSampleSource>(
    LatLngSampleSource.values,
  );
}

class LocationSample extends DataClass implements Insertable<LocationSample> {
  final double latitude;
  final double longitude;

  /// ISO-8601 UTC timestamp for stable ordering and export.
  final String timestamp;
  final double? accuracyMeters;
  final bool isInterpolated;
  final LatLngSampleSource source;
  final String? h3Base;
  const LocationSample({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracyMeters,
    required this.isInterpolated,
    required this.source,
    this.h3Base,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['timestamp'] = Variable<String>(timestamp);
    if (!nullToAbsent || accuracyMeters != null) {
      map['accuracy_meters'] = Variable<double>(accuracyMeters);
    }
    map['is_interpolated'] = Variable<bool>(isInterpolated);
    {
      map['source'] = Variable<String>(
        $LocationSamplesTable.$convertersource.toSql(source),
      );
    }
    if (!nullToAbsent || h3Base != null) {
      map['h3_base'] = Variable<String>(h3Base);
    }
    return map;
  }

  LocationSamplesCompanion toCompanion(bool nullToAbsent) {
    return LocationSamplesCompanion(
      latitude: Value(latitude),
      longitude: Value(longitude),
      timestamp: Value(timestamp),
      accuracyMeters: accuracyMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracyMeters),
      isInterpolated: Value(isInterpolated),
      source: Value(source),
      h3Base: h3Base == null && nullToAbsent
          ? const Value.absent()
          : Value(h3Base),
    );
  }

  factory LocationSample.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocationSample(
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      timestamp: serializer.fromJson<String>(json['timestamp']),
      accuracyMeters: serializer.fromJson<double?>(json['accuracyMeters']),
      isInterpolated: serializer.fromJson<bool>(json['isInterpolated']),
      source: $LocationSamplesTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      h3Base: serializer.fromJson<String?>(json['h3Base']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'timestamp': serializer.toJson<String>(timestamp),
      'accuracyMeters': serializer.toJson<double?>(accuracyMeters),
      'isInterpolated': serializer.toJson<bool>(isInterpolated),
      'source': serializer.toJson<String>(
        $LocationSamplesTable.$convertersource.toJson(source),
      ),
      'h3Base': serializer.toJson<String?>(h3Base),
    };
  }

  LocationSample copyWith({
    double? latitude,
    double? longitude,
    String? timestamp,
    Value<double?> accuracyMeters = const Value.absent(),
    bool? isInterpolated,
    LatLngSampleSource? source,
    Value<String?> h3Base = const Value.absent(),
  }) => LocationSample(
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    timestamp: timestamp ?? this.timestamp,
    accuracyMeters: accuracyMeters.present
        ? accuracyMeters.value
        : this.accuracyMeters,
    isInterpolated: isInterpolated ?? this.isInterpolated,
    source: source ?? this.source,
    h3Base: h3Base.present ? h3Base.value : this.h3Base,
  );
  LocationSample copyWithCompanion(LocationSamplesCompanion data) {
    return LocationSample(
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      accuracyMeters: data.accuracyMeters.present
          ? data.accuracyMeters.value
          : this.accuracyMeters,
      isInterpolated: data.isInterpolated.present
          ? data.isInterpolated.value
          : this.isInterpolated,
      source: data.source.present ? data.source.value : this.source,
      h3Base: data.h3Base.present ? data.h3Base.value : this.h3Base,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocationSample(')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('timestamp: $timestamp, ')
          ..write('accuracyMeters: $accuracyMeters, ')
          ..write('isInterpolated: $isInterpolated, ')
          ..write('source: $source, ')
          ..write('h3Base: $h3Base')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    latitude,
    longitude,
    timestamp,
    accuracyMeters,
    isInterpolated,
    source,
    h3Base,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocationSample &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.timestamp == this.timestamp &&
          other.accuracyMeters == this.accuracyMeters &&
          other.isInterpolated == this.isInterpolated &&
          other.source == this.source &&
          other.h3Base == this.h3Base);
}

class LocationSamplesCompanion extends UpdateCompanion<LocationSample> {
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String> timestamp;
  final Value<double?> accuracyMeters;
  final Value<bool> isInterpolated;
  final Value<LatLngSampleSource> source;
  final Value<String?> h3Base;
  final Value<int> rowid;
  const LocationSamplesCompanion({
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.accuracyMeters = const Value.absent(),
    this.isInterpolated = const Value.absent(),
    this.source = const Value.absent(),
    this.h3Base = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocationSamplesCompanion.insert({
    required double latitude,
    required double longitude,
    required String timestamp,
    this.accuracyMeters = const Value.absent(),
    this.isInterpolated = const Value.absent(),
    required LatLngSampleSource source,
    this.h3Base = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : latitude = Value(latitude),
       longitude = Value(longitude),
       timestamp = Value(timestamp),
       source = Value(source);
  static Insertable<LocationSample> custom({
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? timestamp,
    Expression<double>? accuracyMeters,
    Expression<bool>? isInterpolated,
    Expression<String>? source,
    Expression<String>? h3Base,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (timestamp != null) 'timestamp': timestamp,
      if (accuracyMeters != null) 'accuracy_meters': accuracyMeters,
      if (isInterpolated != null) 'is_interpolated': isInterpolated,
      if (source != null) 'source': source,
      if (h3Base != null) 'h3_base': h3Base,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocationSamplesCompanion copyWith({
    Value<double>? latitude,
    Value<double>? longitude,
    Value<String>? timestamp,
    Value<double?>? accuracyMeters,
    Value<bool>? isInterpolated,
    Value<LatLngSampleSource>? source,
    Value<String?>? h3Base,
    Value<int>? rowid,
  }) {
    return LocationSamplesCompanion(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      isInterpolated: isInterpolated ?? this.isInterpolated,
      source: source ?? this.source,
      h3Base: h3Base ?? this.h3Base,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<String>(timestamp.value);
    }
    if (accuracyMeters.present) {
      map['accuracy_meters'] = Variable<double>(accuracyMeters.value);
    }
    if (isInterpolated.present) {
      map['is_interpolated'] = Variable<bool>(isInterpolated.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $LocationSamplesTable.$convertersource.toSql(source.value),
      );
    }
    if (h3Base.present) {
      map['h3_base'] = Variable<String>(h3Base.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationSamplesCompanion(')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('timestamp: $timestamp, ')
          ..write('accuracyMeters: $accuracyMeters, ')
          ..write('isInterpolated: $isInterpolated, ')
          ..write('source: $source, ')
          ..write('h3Base: $h3Base, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocationHistoryDatabase extends GeneratedDatabase {
  _$LocationHistoryDatabase(QueryExecutor e) : super(e);
  $LocationHistoryDatabaseManager get managers =>
      $LocationHistoryDatabaseManager(this);
  late final $LocationSamplesTable locationSamples = $LocationSamplesTable(
    this,
  );
  late final Index locationSamplesTimestamp = Index(
    'location_samples_timestamp',
    'CREATE INDEX location_samples_timestamp ON location_samples (timestamp)',
  );
  late final Index locationSamplesH3Base = Index(
    'location_samples_h3_base',
    'CREATE INDEX location_samples_h3_base ON location_samples (h3_base)',
  );
  late final LocationHistoryDao locationHistoryDao = LocationHistoryDao(
    this as LocationHistoryDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    locationSamples,
    locationSamplesTimestamp,
    locationSamplesH3Base,
  ];
}

typedef $$LocationSamplesTableCreateCompanionBuilder =
    LocationSamplesCompanion Function({
      required double latitude,
      required double longitude,
      required String timestamp,
      Value<double?> accuracyMeters,
      Value<bool> isInterpolated,
      required LatLngSampleSource source,
      Value<String?> h3Base,
      Value<int> rowid,
    });
typedef $$LocationSamplesTableUpdateCompanionBuilder =
    LocationSamplesCompanion Function({
      Value<double> latitude,
      Value<double> longitude,
      Value<String> timestamp,
      Value<double?> accuracyMeters,
      Value<bool> isInterpolated,
      Value<LatLngSampleSource> source,
      Value<String?> h3Base,
      Value<int> rowid,
    });

class $$LocationSamplesTableFilterComposer
    extends Composer<_$LocationHistoryDatabase, $LocationSamplesTable> {
  $$LocationSamplesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracyMeters => $composableBuilder(
    column: $table.accuracyMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isInterpolated => $composableBuilder(
    column: $table.isInterpolated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LatLngSampleSource, LatLngSampleSource, String>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get h3Base => $composableBuilder(
    column: $table.h3Base,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocationSamplesTableOrderingComposer
    extends Composer<_$LocationHistoryDatabase, $LocationSamplesTable> {
  $$LocationSamplesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracyMeters => $composableBuilder(
    column: $table.accuracyMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isInterpolated => $composableBuilder(
    column: $table.isInterpolated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get h3Base => $composableBuilder(
    column: $table.h3Base,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocationSamplesTableAnnotationComposer
    extends Composer<_$LocationHistoryDatabase, $LocationSamplesTable> {
  $$LocationSamplesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<double> get accuracyMeters => $composableBuilder(
    column: $table.accuracyMeters,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isInterpolated => $composableBuilder(
    column: $table.isInterpolated,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<LatLngSampleSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get h3Base =>
      $composableBuilder(column: $table.h3Base, builder: (column) => column);
}

class $$LocationSamplesTableTableManager
    extends
        RootTableManager<
          _$LocationHistoryDatabase,
          $LocationSamplesTable,
          LocationSample,
          $$LocationSamplesTableFilterComposer,
          $$LocationSamplesTableOrderingComposer,
          $$LocationSamplesTableAnnotationComposer,
          $$LocationSamplesTableCreateCompanionBuilder,
          $$LocationSamplesTableUpdateCompanionBuilder,
          (
            LocationSample,
            BaseReferences<
              _$LocationHistoryDatabase,
              $LocationSamplesTable,
              LocationSample
            >,
          ),
          LocationSample,
          PrefetchHooks Function()
        > {
  $$LocationSamplesTableTableManager(
    _$LocationHistoryDatabase db,
    $LocationSamplesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationSamplesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationSamplesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocationSamplesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String> timestamp = const Value.absent(),
                Value<double?> accuracyMeters = const Value.absent(),
                Value<bool> isInterpolated = const Value.absent(),
                Value<LatLngSampleSource> source = const Value.absent(),
                Value<String?> h3Base = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocationSamplesCompanion(
                latitude: latitude,
                longitude: longitude,
                timestamp: timestamp,
                accuracyMeters: accuracyMeters,
                isInterpolated: isInterpolated,
                source: source,
                h3Base: h3Base,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required double latitude,
                required double longitude,
                required String timestamp,
                Value<double?> accuracyMeters = const Value.absent(),
                Value<bool> isInterpolated = const Value.absent(),
                required LatLngSampleSource source,
                Value<String?> h3Base = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocationSamplesCompanion.insert(
                latitude: latitude,
                longitude: longitude,
                timestamp: timestamp,
                accuracyMeters: accuracyMeters,
                isInterpolated: isInterpolated,
                source: source,
                h3Base: h3Base,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocationSamplesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocationHistoryDatabase,
      $LocationSamplesTable,
      LocationSample,
      $$LocationSamplesTableFilterComposer,
      $$LocationSamplesTableOrderingComposer,
      $$LocationSamplesTableAnnotationComposer,
      $$LocationSamplesTableCreateCompanionBuilder,
      $$LocationSamplesTableUpdateCompanionBuilder,
      (
        LocationSample,
        BaseReferences<
          _$LocationHistoryDatabase,
          $LocationSamplesTable,
          LocationSample
        >,
      ),
      LocationSample,
      PrefetchHooks Function()
    >;

class $LocationHistoryDatabaseManager {
  final _$LocationHistoryDatabase _db;
  $LocationHistoryDatabaseManager(this._db);
  $$LocationSamplesTableTableManager get locationSamples =>
      $$LocationSamplesTableTableManager(_db, _db.locationSamples);
}

mixin _$LocationHistoryDaoMixin on DatabaseAccessor<LocationHistoryDatabase> {
  $LocationSamplesTable get locationSamples => attachedDatabase.locationSamples;
  LocationHistoryDaoManager get managers => LocationHistoryDaoManager(this);
}

class LocationHistoryDaoManager {
  final _$LocationHistoryDaoMixin _db;
  LocationHistoryDaoManager(this._db);
  $$LocationSamplesTableTableManager get locationSamples =>
      $$LocationSamplesTableTableManager(
        _db.attachedDatabase,
        _db.locationSamples,
      );
}
