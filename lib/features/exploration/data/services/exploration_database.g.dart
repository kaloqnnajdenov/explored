// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exploration_database.dart';

// ignore_for_file: type=lint
class $StaticEntitiesTable extends StaticEntities
    with TableInfo<$StaticEntitiesTable, StaticEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StaticEntitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _osmTypeMeta = const VerificationMeta(
    'osmType',
  );
  @override
  late final GeneratedColumn<String> osmType = GeneratedColumn<String>(
    'osm_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _osmIdMeta = const VerificationMeta('osmId');
  @override
  late final GeneratedColumn<int> osmId = GeneratedColumn<int>(
    'osm_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _areaIdMeta = const VerificationMeta('areaId');
  @override
  late final GeneratedColumn<String> areaId = GeneratedColumn<String>(
    'area_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _adminLevelMeta = const VerificationMeta(
    'adminLevel',
  );
  @override
  late final GeneratedColumn<int> adminLevel = GeneratedColumn<int>(
    'admin_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bboxJsonMeta = const VerificationMeta(
    'bboxJson',
  );
  @override
  late final GeneratedColumn<String> bboxJson = GeneratedColumn<String>(
    'bbox_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _centroidJsonMeta = const VerificationMeta(
    'centroidJson',
  );
  @override
  late final GeneratedColumn<String> centroidJson = GeneratedColumn<String>(
    'centroid_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countryIdMeta = const VerificationMeta(
    'countryId',
  );
  @override
  late final GeneratedColumn<String> countryId = GeneratedColumn<String>(
    'country_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _regionIdMeta = const VerificationMeta(
    'regionId',
  );
  @override
  late final GeneratedColumn<String> regionId = GeneratedColumn<String>(
    'region_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cityIdMeta = const VerificationMeta('cityId');
  @override
  late final GeneratedColumn<String> cityId = GeneratedColumn<String>(
    'city_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _geometryGeojsonMeta = const VerificationMeta(
    'geometryGeojson',
  );
  @override
  late final GeneratedColumn<String> geometryGeojson = GeneratedColumn<String>(
    'geometry_geojson',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countrySlugMeta = const VerificationMeta(
    'countrySlug',
  );
  @override
  late final GeneratedColumn<String> countrySlug = GeneratedColumn<String>(
    'country_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packVersionMeta = const VerificationMeta(
    'packVersion',
  );
  @override
  late final GeneratedColumn<String> packVersion = GeneratedColumn<String>(
    'pack_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    entityId,
    type,
    osmType,
    osmId,
    areaId,
    name,
    adminLevel,
    bboxJson,
    centroidJson,
    countryId,
    regionId,
    cityId,
    geometryGeojson,
    countrySlug,
    packVersion,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'static_entities';
  @override
  VerificationContext validateIntegrity(
    Insertable<StaticEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('osm_type')) {
      context.handle(
        _osmTypeMeta,
        osmType.isAcceptableOrUnknown(data['osm_type']!, _osmTypeMeta),
      );
    }
    if (data.containsKey('osm_id')) {
      context.handle(
        _osmIdMeta,
        osmId.isAcceptableOrUnknown(data['osm_id']!, _osmIdMeta),
      );
    }
    if (data.containsKey('area_id')) {
      context.handle(
        _areaIdMeta,
        areaId.isAcceptableOrUnknown(data['area_id']!, _areaIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('admin_level')) {
      context.handle(
        _adminLevelMeta,
        adminLevel.isAcceptableOrUnknown(data['admin_level']!, _adminLevelMeta),
      );
    }
    if (data.containsKey('bbox_json')) {
      context.handle(
        _bboxJsonMeta,
        bboxJson.isAcceptableOrUnknown(data['bbox_json']!, _bboxJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_bboxJsonMeta);
    }
    if (data.containsKey('centroid_json')) {
      context.handle(
        _centroidJsonMeta,
        centroidJson.isAcceptableOrUnknown(
          data['centroid_json']!,
          _centroidJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_centroidJsonMeta);
    }
    if (data.containsKey('country_id')) {
      context.handle(
        _countryIdMeta,
        countryId.isAcceptableOrUnknown(data['country_id']!, _countryIdMeta),
      );
    }
    if (data.containsKey('region_id')) {
      context.handle(
        _regionIdMeta,
        regionId.isAcceptableOrUnknown(data['region_id']!, _regionIdMeta),
      );
    }
    if (data.containsKey('city_id')) {
      context.handle(
        _cityIdMeta,
        cityId.isAcceptableOrUnknown(data['city_id']!, _cityIdMeta),
      );
    }
    if (data.containsKey('geometry_geojson')) {
      context.handle(
        _geometryGeojsonMeta,
        geometryGeojson.isAcceptableOrUnknown(
          data['geometry_geojson']!,
          _geometryGeojsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_geometryGeojsonMeta);
    }
    if (data.containsKey('country_slug')) {
      context.handle(
        _countrySlugMeta,
        countrySlug.isAcceptableOrUnknown(
          data['country_slug']!,
          _countrySlugMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_countrySlugMeta);
    }
    if (data.containsKey('pack_version')) {
      context.handle(
        _packVersionMeta,
        packVersion.isAcceptableOrUnknown(
          data['pack_version']!,
          _packVersionMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityId};
  @override
  StaticEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StaticEntity(
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      osmType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}osm_type'],
      ),
      osmId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}osm_id'],
      ),
      areaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      adminLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}admin_level'],
      ),
      bboxJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bbox_json'],
      )!,
      centroidJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}centroid_json'],
      )!,
      countryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country_id'],
      ),
      regionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region_id'],
      ),
      cityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city_id'],
      ),
      geometryGeojson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}geometry_geojson'],
      )!,
      countrySlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country_slug'],
      )!,
      packVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_version'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $StaticEntitiesTable createAlias(String alias) {
    return $StaticEntitiesTable(attachedDatabase, alias);
  }
}

class StaticEntity extends DataClass implements Insertable<StaticEntity> {
  final String entityId;
  final String type;
  final String? osmType;
  final int? osmId;
  final String? areaId;
  final String name;
  final int? adminLevel;
  final String bboxJson;
  final String centroidJson;
  final String? countryId;
  final String? regionId;
  final String? cityId;
  final String geometryGeojson;
  final String countrySlug;
  final String? packVersion;
  final int updatedAt;
  const StaticEntity({
    required this.entityId,
    required this.type,
    this.osmType,
    this.osmId,
    this.areaId,
    required this.name,
    this.adminLevel,
    required this.bboxJson,
    required this.centroidJson,
    this.countryId,
    this.regionId,
    this.cityId,
    required this.geometryGeojson,
    required this.countrySlug,
    this.packVersion,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_id'] = Variable<String>(entityId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || osmType != null) {
      map['osm_type'] = Variable<String>(osmType);
    }
    if (!nullToAbsent || osmId != null) {
      map['osm_id'] = Variable<int>(osmId);
    }
    if (!nullToAbsent || areaId != null) {
      map['area_id'] = Variable<String>(areaId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || adminLevel != null) {
      map['admin_level'] = Variable<int>(adminLevel);
    }
    map['bbox_json'] = Variable<String>(bboxJson);
    map['centroid_json'] = Variable<String>(centroidJson);
    if (!nullToAbsent || countryId != null) {
      map['country_id'] = Variable<String>(countryId);
    }
    if (!nullToAbsent || regionId != null) {
      map['region_id'] = Variable<String>(regionId);
    }
    if (!nullToAbsent || cityId != null) {
      map['city_id'] = Variable<String>(cityId);
    }
    map['geometry_geojson'] = Variable<String>(geometryGeojson);
    map['country_slug'] = Variable<String>(countrySlug);
    if (!nullToAbsent || packVersion != null) {
      map['pack_version'] = Variable<String>(packVersion);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  StaticEntitiesCompanion toCompanion(bool nullToAbsent) {
    return StaticEntitiesCompanion(
      entityId: Value(entityId),
      type: Value(type),
      osmType: osmType == null && nullToAbsent
          ? const Value.absent()
          : Value(osmType),
      osmId: osmId == null && nullToAbsent
          ? const Value.absent()
          : Value(osmId),
      areaId: areaId == null && nullToAbsent
          ? const Value.absent()
          : Value(areaId),
      name: Value(name),
      adminLevel: adminLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(adminLevel),
      bboxJson: Value(bboxJson),
      centroidJson: Value(centroidJson),
      countryId: countryId == null && nullToAbsent
          ? const Value.absent()
          : Value(countryId),
      regionId: regionId == null && nullToAbsent
          ? const Value.absent()
          : Value(regionId),
      cityId: cityId == null && nullToAbsent
          ? const Value.absent()
          : Value(cityId),
      geometryGeojson: Value(geometryGeojson),
      countrySlug: Value(countrySlug),
      packVersion: packVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(packVersion),
      updatedAt: Value(updatedAt),
    );
  }

  factory StaticEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StaticEntity(
      entityId: serializer.fromJson<String>(json['entityId']),
      type: serializer.fromJson<String>(json['type']),
      osmType: serializer.fromJson<String?>(json['osmType']),
      osmId: serializer.fromJson<int?>(json['osmId']),
      areaId: serializer.fromJson<String?>(json['areaId']),
      name: serializer.fromJson<String>(json['name']),
      adminLevel: serializer.fromJson<int?>(json['adminLevel']),
      bboxJson: serializer.fromJson<String>(json['bboxJson']),
      centroidJson: serializer.fromJson<String>(json['centroidJson']),
      countryId: serializer.fromJson<String?>(json['countryId']),
      regionId: serializer.fromJson<String?>(json['regionId']),
      cityId: serializer.fromJson<String?>(json['cityId']),
      geometryGeojson: serializer.fromJson<String>(json['geometryGeojson']),
      countrySlug: serializer.fromJson<String>(json['countrySlug']),
      packVersion: serializer.fromJson<String?>(json['packVersion']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityId': serializer.toJson<String>(entityId),
      'type': serializer.toJson<String>(type),
      'osmType': serializer.toJson<String?>(osmType),
      'osmId': serializer.toJson<int?>(osmId),
      'areaId': serializer.toJson<String?>(areaId),
      'name': serializer.toJson<String>(name),
      'adminLevel': serializer.toJson<int?>(adminLevel),
      'bboxJson': serializer.toJson<String>(bboxJson),
      'centroidJson': serializer.toJson<String>(centroidJson),
      'countryId': serializer.toJson<String?>(countryId),
      'regionId': serializer.toJson<String?>(regionId),
      'cityId': serializer.toJson<String?>(cityId),
      'geometryGeojson': serializer.toJson<String>(geometryGeojson),
      'countrySlug': serializer.toJson<String>(countrySlug),
      'packVersion': serializer.toJson<String?>(packVersion),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  StaticEntity copyWith({
    String? entityId,
    String? type,
    Value<String?> osmType = const Value.absent(),
    Value<int?> osmId = const Value.absent(),
    Value<String?> areaId = const Value.absent(),
    String? name,
    Value<int?> adminLevel = const Value.absent(),
    String? bboxJson,
    String? centroidJson,
    Value<String?> countryId = const Value.absent(),
    Value<String?> regionId = const Value.absent(),
    Value<String?> cityId = const Value.absent(),
    String? geometryGeojson,
    String? countrySlug,
    Value<String?> packVersion = const Value.absent(),
    int? updatedAt,
  }) => StaticEntity(
    entityId: entityId ?? this.entityId,
    type: type ?? this.type,
    osmType: osmType.present ? osmType.value : this.osmType,
    osmId: osmId.present ? osmId.value : this.osmId,
    areaId: areaId.present ? areaId.value : this.areaId,
    name: name ?? this.name,
    adminLevel: adminLevel.present ? adminLevel.value : this.adminLevel,
    bboxJson: bboxJson ?? this.bboxJson,
    centroidJson: centroidJson ?? this.centroidJson,
    countryId: countryId.present ? countryId.value : this.countryId,
    regionId: regionId.present ? regionId.value : this.regionId,
    cityId: cityId.present ? cityId.value : this.cityId,
    geometryGeojson: geometryGeojson ?? this.geometryGeojson,
    countrySlug: countrySlug ?? this.countrySlug,
    packVersion: packVersion.present ? packVersion.value : this.packVersion,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  StaticEntity copyWithCompanion(StaticEntitiesCompanion data) {
    return StaticEntity(
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      type: data.type.present ? data.type.value : this.type,
      osmType: data.osmType.present ? data.osmType.value : this.osmType,
      osmId: data.osmId.present ? data.osmId.value : this.osmId,
      areaId: data.areaId.present ? data.areaId.value : this.areaId,
      name: data.name.present ? data.name.value : this.name,
      adminLevel: data.adminLevel.present
          ? data.adminLevel.value
          : this.adminLevel,
      bboxJson: data.bboxJson.present ? data.bboxJson.value : this.bboxJson,
      centroidJson: data.centroidJson.present
          ? data.centroidJson.value
          : this.centroidJson,
      countryId: data.countryId.present ? data.countryId.value : this.countryId,
      regionId: data.regionId.present ? data.regionId.value : this.regionId,
      cityId: data.cityId.present ? data.cityId.value : this.cityId,
      geometryGeojson: data.geometryGeojson.present
          ? data.geometryGeojson.value
          : this.geometryGeojson,
      countrySlug: data.countrySlug.present
          ? data.countrySlug.value
          : this.countrySlug,
      packVersion: data.packVersion.present
          ? data.packVersion.value
          : this.packVersion,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StaticEntity(')
          ..write('entityId: $entityId, ')
          ..write('type: $type, ')
          ..write('osmType: $osmType, ')
          ..write('osmId: $osmId, ')
          ..write('areaId: $areaId, ')
          ..write('name: $name, ')
          ..write('adminLevel: $adminLevel, ')
          ..write('bboxJson: $bboxJson, ')
          ..write('centroidJson: $centroidJson, ')
          ..write('countryId: $countryId, ')
          ..write('regionId: $regionId, ')
          ..write('cityId: $cityId, ')
          ..write('geometryGeojson: $geometryGeojson, ')
          ..write('countrySlug: $countrySlug, ')
          ..write('packVersion: $packVersion, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    entityId,
    type,
    osmType,
    osmId,
    areaId,
    name,
    adminLevel,
    bboxJson,
    centroidJson,
    countryId,
    regionId,
    cityId,
    geometryGeojson,
    countrySlug,
    packVersion,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StaticEntity &&
          other.entityId == this.entityId &&
          other.type == this.type &&
          other.osmType == this.osmType &&
          other.osmId == this.osmId &&
          other.areaId == this.areaId &&
          other.name == this.name &&
          other.adminLevel == this.adminLevel &&
          other.bboxJson == this.bboxJson &&
          other.centroidJson == this.centroidJson &&
          other.countryId == this.countryId &&
          other.regionId == this.regionId &&
          other.cityId == this.cityId &&
          other.geometryGeojson == this.geometryGeojson &&
          other.countrySlug == this.countrySlug &&
          other.packVersion == this.packVersion &&
          other.updatedAt == this.updatedAt);
}

class StaticEntitiesCompanion extends UpdateCompanion<StaticEntity> {
  final Value<String> entityId;
  final Value<String> type;
  final Value<String?> osmType;
  final Value<int?> osmId;
  final Value<String?> areaId;
  final Value<String> name;
  final Value<int?> adminLevel;
  final Value<String> bboxJson;
  final Value<String> centroidJson;
  final Value<String?> countryId;
  final Value<String?> regionId;
  final Value<String?> cityId;
  final Value<String> geometryGeojson;
  final Value<String> countrySlug;
  final Value<String?> packVersion;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const StaticEntitiesCompanion({
    this.entityId = const Value.absent(),
    this.type = const Value.absent(),
    this.osmType = const Value.absent(),
    this.osmId = const Value.absent(),
    this.areaId = const Value.absent(),
    this.name = const Value.absent(),
    this.adminLevel = const Value.absent(),
    this.bboxJson = const Value.absent(),
    this.centroidJson = const Value.absent(),
    this.countryId = const Value.absent(),
    this.regionId = const Value.absent(),
    this.cityId = const Value.absent(),
    this.geometryGeojson = const Value.absent(),
    this.countrySlug = const Value.absent(),
    this.packVersion = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StaticEntitiesCompanion.insert({
    required String entityId,
    required String type,
    this.osmType = const Value.absent(),
    this.osmId = const Value.absent(),
    this.areaId = const Value.absent(),
    required String name,
    this.adminLevel = const Value.absent(),
    required String bboxJson,
    required String centroidJson,
    this.countryId = const Value.absent(),
    this.regionId = const Value.absent(),
    this.cityId = const Value.absent(),
    required String geometryGeojson,
    required String countrySlug,
    this.packVersion = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : entityId = Value(entityId),
       type = Value(type),
       name = Value(name),
       bboxJson = Value(bboxJson),
       centroidJson = Value(centroidJson),
       geometryGeojson = Value(geometryGeojson),
       countrySlug = Value(countrySlug),
       updatedAt = Value(updatedAt);
  static Insertable<StaticEntity> custom({
    Expression<String>? entityId,
    Expression<String>? type,
    Expression<String>? osmType,
    Expression<int>? osmId,
    Expression<String>? areaId,
    Expression<String>? name,
    Expression<int>? adminLevel,
    Expression<String>? bboxJson,
    Expression<String>? centroidJson,
    Expression<String>? countryId,
    Expression<String>? regionId,
    Expression<String>? cityId,
    Expression<String>? geometryGeojson,
    Expression<String>? countrySlug,
    Expression<String>? packVersion,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityId != null) 'entity_id': entityId,
      if (type != null) 'type': type,
      if (osmType != null) 'osm_type': osmType,
      if (osmId != null) 'osm_id': osmId,
      if (areaId != null) 'area_id': areaId,
      if (name != null) 'name': name,
      if (adminLevel != null) 'admin_level': adminLevel,
      if (bboxJson != null) 'bbox_json': bboxJson,
      if (centroidJson != null) 'centroid_json': centroidJson,
      if (countryId != null) 'country_id': countryId,
      if (regionId != null) 'region_id': regionId,
      if (cityId != null) 'city_id': cityId,
      if (geometryGeojson != null) 'geometry_geojson': geometryGeojson,
      if (countrySlug != null) 'country_slug': countrySlug,
      if (packVersion != null) 'pack_version': packVersion,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StaticEntitiesCompanion copyWith({
    Value<String>? entityId,
    Value<String>? type,
    Value<String?>? osmType,
    Value<int?>? osmId,
    Value<String?>? areaId,
    Value<String>? name,
    Value<int?>? adminLevel,
    Value<String>? bboxJson,
    Value<String>? centroidJson,
    Value<String?>? countryId,
    Value<String?>? regionId,
    Value<String?>? cityId,
    Value<String>? geometryGeojson,
    Value<String>? countrySlug,
    Value<String?>? packVersion,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return StaticEntitiesCompanion(
      entityId: entityId ?? this.entityId,
      type: type ?? this.type,
      osmType: osmType ?? this.osmType,
      osmId: osmId ?? this.osmId,
      areaId: areaId ?? this.areaId,
      name: name ?? this.name,
      adminLevel: adminLevel ?? this.adminLevel,
      bboxJson: bboxJson ?? this.bboxJson,
      centroidJson: centroidJson ?? this.centroidJson,
      countryId: countryId ?? this.countryId,
      regionId: regionId ?? this.regionId,
      cityId: cityId ?? this.cityId,
      geometryGeojson: geometryGeojson ?? this.geometryGeojson,
      countrySlug: countrySlug ?? this.countrySlug,
      packVersion: packVersion ?? this.packVersion,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (osmType.present) {
      map['osm_type'] = Variable<String>(osmType.value);
    }
    if (osmId.present) {
      map['osm_id'] = Variable<int>(osmId.value);
    }
    if (areaId.present) {
      map['area_id'] = Variable<String>(areaId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (adminLevel.present) {
      map['admin_level'] = Variable<int>(adminLevel.value);
    }
    if (bboxJson.present) {
      map['bbox_json'] = Variable<String>(bboxJson.value);
    }
    if (centroidJson.present) {
      map['centroid_json'] = Variable<String>(centroidJson.value);
    }
    if (countryId.present) {
      map['country_id'] = Variable<String>(countryId.value);
    }
    if (regionId.present) {
      map['region_id'] = Variable<String>(regionId.value);
    }
    if (cityId.present) {
      map['city_id'] = Variable<String>(cityId.value);
    }
    if (geometryGeojson.present) {
      map['geometry_geojson'] = Variable<String>(geometryGeojson.value);
    }
    if (countrySlug.present) {
      map['country_slug'] = Variable<String>(countrySlug.value);
    }
    if (packVersion.present) {
      map['pack_version'] = Variable<String>(packVersion.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StaticEntitiesCompanion(')
          ..write('entityId: $entityId, ')
          ..write('type: $type, ')
          ..write('osmType: $osmType, ')
          ..write('osmId: $osmId, ')
          ..write('areaId: $areaId, ')
          ..write('name: $name, ')
          ..write('adminLevel: $adminLevel, ')
          ..write('bboxJson: $bboxJson, ')
          ..write('centroidJson: $centroidJson, ')
          ..write('countryId: $countryId, ')
          ..write('regionId: $regionId, ')
          ..write('cityId: $cityId, ')
          ..write('geometryGeojson: $geometryGeojson, ')
          ..write('countrySlug: $countrySlug, ')
          ..write('packVersion: $packVersion, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StaticObjectsTable extends StaticObjects
    with TableInfo<$StaticObjectsTable, StaticObject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StaticObjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _objectIdMeta = const VerificationMeta(
    'objectId',
  );
  @override
  late final GeneratedColumn<String> objectId = GeneratedColumn<String>(
    'object_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtypeMeta = const VerificationMeta(
    'subtype',
  );
  @override
  late final GeneratedColumn<String> subtype = GeneratedColumn<String>(
    'subtype',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _geometryGeojsonMeta = const VerificationMeta(
    'geometryGeojson',
  );
  @override
  late final GeneratedColumn<String> geometryGeojson = GeneratedColumn<String>(
    'geometry_geojson',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countryIdMeta = const VerificationMeta(
    'countryId',
  );
  @override
  late final GeneratedColumn<String> countryId = GeneratedColumn<String>(
    'country_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _regionIdMeta = const VerificationMeta(
    'regionId',
  );
  @override
  late final GeneratedColumn<String> regionId = GeneratedColumn<String>(
    'region_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cityIdMeta = const VerificationMeta('cityId');
  @override
  late final GeneratedColumn<String> cityId = GeneratedColumn<String>(
    'city_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cityCenterIdMeta = const VerificationMeta(
    'cityCenterId',
  );
  @override
  late final GeneratedColumn<String> cityCenterId = GeneratedColumn<String>(
    'city_center_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _drivableMeta = const VerificationMeta(
    'drivable',
  );
  @override
  late final GeneratedColumn<bool> drivable = GeneratedColumn<bool>(
    'drivable',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("drivable" IN (0, 1))',
    ),
  );
  static const VerificationMeta _walkableMeta = const VerificationMeta(
    'walkable',
  );
  @override
  late final GeneratedColumn<bool> walkable = GeneratedColumn<bool>(
    'walkable',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("walkable" IN (0, 1))',
    ),
  );
  static const VerificationMeta _cyclewayMeta = const VerificationMeta(
    'cycleway',
  );
  @override
  late final GeneratedColumn<bool> cycleway = GeneratedColumn<bool>(
    'cycleway',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("cycleway" IN (0, 1))',
    ),
  );
  static const VerificationMeta _lengthMMeta = const VerificationMeta(
    'lengthM',
  );
  @override
  late final GeneratedColumn<double> lengthM = GeneratedColumn<double>(
    'length_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countrySlugMeta = const VerificationMeta(
    'countrySlug',
  );
  @override
  late final GeneratedColumn<String> countrySlug = GeneratedColumn<String>(
    'country_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    objectId,
    category,
    subtype,
    name,
    geometryGeojson,
    countryId,
    regionId,
    cityId,
    cityCenterId,
    drivable,
    walkable,
    cycleway,
    lengthM,
    countrySlug,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'static_objects';
  @override
  VerificationContext validateIntegrity(
    Insertable<StaticObject> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('object_id')) {
      context.handle(
        _objectIdMeta,
        objectId.isAcceptableOrUnknown(data['object_id']!, _objectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_objectIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('subtype')) {
      context.handle(
        _subtypeMeta,
        subtype.isAcceptableOrUnknown(data['subtype']!, _subtypeMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('geometry_geojson')) {
      context.handle(
        _geometryGeojsonMeta,
        geometryGeojson.isAcceptableOrUnknown(
          data['geometry_geojson']!,
          _geometryGeojsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_geometryGeojsonMeta);
    }
    if (data.containsKey('country_id')) {
      context.handle(
        _countryIdMeta,
        countryId.isAcceptableOrUnknown(data['country_id']!, _countryIdMeta),
      );
    }
    if (data.containsKey('region_id')) {
      context.handle(
        _regionIdMeta,
        regionId.isAcceptableOrUnknown(data['region_id']!, _regionIdMeta),
      );
    }
    if (data.containsKey('city_id')) {
      context.handle(
        _cityIdMeta,
        cityId.isAcceptableOrUnknown(data['city_id']!, _cityIdMeta),
      );
    }
    if (data.containsKey('city_center_id')) {
      context.handle(
        _cityCenterIdMeta,
        cityCenterId.isAcceptableOrUnknown(
          data['city_center_id']!,
          _cityCenterIdMeta,
        ),
      );
    }
    if (data.containsKey('drivable')) {
      context.handle(
        _drivableMeta,
        drivable.isAcceptableOrUnknown(data['drivable']!, _drivableMeta),
      );
    }
    if (data.containsKey('walkable')) {
      context.handle(
        _walkableMeta,
        walkable.isAcceptableOrUnknown(data['walkable']!, _walkableMeta),
      );
    }
    if (data.containsKey('cycleway')) {
      context.handle(
        _cyclewayMeta,
        cycleway.isAcceptableOrUnknown(data['cycleway']!, _cyclewayMeta),
      );
    }
    if (data.containsKey('length_m')) {
      context.handle(
        _lengthMMeta,
        lengthM.isAcceptableOrUnknown(data['length_m']!, _lengthMMeta),
      );
    }
    if (data.containsKey('country_slug')) {
      context.handle(
        _countrySlugMeta,
        countrySlug.isAcceptableOrUnknown(
          data['country_slug']!,
          _countrySlugMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_countrySlugMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {objectId};
  @override
  StaticObject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StaticObject(
      objectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}object_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      subtype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtype'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      geometryGeojson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}geometry_geojson'],
      )!,
      countryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country_id'],
      ),
      regionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region_id'],
      ),
      cityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city_id'],
      ),
      cityCenterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city_center_id'],
      ),
      drivable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}drivable'],
      ),
      walkable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}walkable'],
      ),
      cycleway: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}cycleway'],
      ),
      lengthM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}length_m'],
      ),
      countrySlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country_slug'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $StaticObjectsTable createAlias(String alias) {
    return $StaticObjectsTable(attachedDatabase, alias);
  }
}

class StaticObject extends DataClass implements Insertable<StaticObject> {
  final String objectId;
  final String category;
  final String? subtype;
  final String? name;
  final String geometryGeojson;
  final String? countryId;
  final String? regionId;
  final String? cityId;
  final String? cityCenterId;
  final bool? drivable;
  final bool? walkable;
  final bool? cycleway;
  final double? lengthM;
  final String countrySlug;
  final int updatedAt;
  const StaticObject({
    required this.objectId,
    required this.category,
    this.subtype,
    this.name,
    required this.geometryGeojson,
    this.countryId,
    this.regionId,
    this.cityId,
    this.cityCenterId,
    this.drivable,
    this.walkable,
    this.cycleway,
    this.lengthM,
    required this.countrySlug,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['object_id'] = Variable<String>(objectId);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || subtype != null) {
      map['subtype'] = Variable<String>(subtype);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['geometry_geojson'] = Variable<String>(geometryGeojson);
    if (!nullToAbsent || countryId != null) {
      map['country_id'] = Variable<String>(countryId);
    }
    if (!nullToAbsent || regionId != null) {
      map['region_id'] = Variable<String>(regionId);
    }
    if (!nullToAbsent || cityId != null) {
      map['city_id'] = Variable<String>(cityId);
    }
    if (!nullToAbsent || cityCenterId != null) {
      map['city_center_id'] = Variable<String>(cityCenterId);
    }
    if (!nullToAbsent || drivable != null) {
      map['drivable'] = Variable<bool>(drivable);
    }
    if (!nullToAbsent || walkable != null) {
      map['walkable'] = Variable<bool>(walkable);
    }
    if (!nullToAbsent || cycleway != null) {
      map['cycleway'] = Variable<bool>(cycleway);
    }
    if (!nullToAbsent || lengthM != null) {
      map['length_m'] = Variable<double>(lengthM);
    }
    map['country_slug'] = Variable<String>(countrySlug);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  StaticObjectsCompanion toCompanion(bool nullToAbsent) {
    return StaticObjectsCompanion(
      objectId: Value(objectId),
      category: Value(category),
      subtype: subtype == null && nullToAbsent
          ? const Value.absent()
          : Value(subtype),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      geometryGeojson: Value(geometryGeojson),
      countryId: countryId == null && nullToAbsent
          ? const Value.absent()
          : Value(countryId),
      regionId: regionId == null && nullToAbsent
          ? const Value.absent()
          : Value(regionId),
      cityId: cityId == null && nullToAbsent
          ? const Value.absent()
          : Value(cityId),
      cityCenterId: cityCenterId == null && nullToAbsent
          ? const Value.absent()
          : Value(cityCenterId),
      drivable: drivable == null && nullToAbsent
          ? const Value.absent()
          : Value(drivable),
      walkable: walkable == null && nullToAbsent
          ? const Value.absent()
          : Value(walkable),
      cycleway: cycleway == null && nullToAbsent
          ? const Value.absent()
          : Value(cycleway),
      lengthM: lengthM == null && nullToAbsent
          ? const Value.absent()
          : Value(lengthM),
      countrySlug: Value(countrySlug),
      updatedAt: Value(updatedAt),
    );
  }

  factory StaticObject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StaticObject(
      objectId: serializer.fromJson<String>(json['objectId']),
      category: serializer.fromJson<String>(json['category']),
      subtype: serializer.fromJson<String?>(json['subtype']),
      name: serializer.fromJson<String?>(json['name']),
      geometryGeojson: serializer.fromJson<String>(json['geometryGeojson']),
      countryId: serializer.fromJson<String?>(json['countryId']),
      regionId: serializer.fromJson<String?>(json['regionId']),
      cityId: serializer.fromJson<String?>(json['cityId']),
      cityCenterId: serializer.fromJson<String?>(json['cityCenterId']),
      drivable: serializer.fromJson<bool?>(json['drivable']),
      walkable: serializer.fromJson<bool?>(json['walkable']),
      cycleway: serializer.fromJson<bool?>(json['cycleway']),
      lengthM: serializer.fromJson<double?>(json['lengthM']),
      countrySlug: serializer.fromJson<String>(json['countrySlug']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'objectId': serializer.toJson<String>(objectId),
      'category': serializer.toJson<String>(category),
      'subtype': serializer.toJson<String?>(subtype),
      'name': serializer.toJson<String?>(name),
      'geometryGeojson': serializer.toJson<String>(geometryGeojson),
      'countryId': serializer.toJson<String?>(countryId),
      'regionId': serializer.toJson<String?>(regionId),
      'cityId': serializer.toJson<String?>(cityId),
      'cityCenterId': serializer.toJson<String?>(cityCenterId),
      'drivable': serializer.toJson<bool?>(drivable),
      'walkable': serializer.toJson<bool?>(walkable),
      'cycleway': serializer.toJson<bool?>(cycleway),
      'lengthM': serializer.toJson<double?>(lengthM),
      'countrySlug': serializer.toJson<String>(countrySlug),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  StaticObject copyWith({
    String? objectId,
    String? category,
    Value<String?> subtype = const Value.absent(),
    Value<String?> name = const Value.absent(),
    String? geometryGeojson,
    Value<String?> countryId = const Value.absent(),
    Value<String?> regionId = const Value.absent(),
    Value<String?> cityId = const Value.absent(),
    Value<String?> cityCenterId = const Value.absent(),
    Value<bool?> drivable = const Value.absent(),
    Value<bool?> walkable = const Value.absent(),
    Value<bool?> cycleway = const Value.absent(),
    Value<double?> lengthM = const Value.absent(),
    String? countrySlug,
    int? updatedAt,
  }) => StaticObject(
    objectId: objectId ?? this.objectId,
    category: category ?? this.category,
    subtype: subtype.present ? subtype.value : this.subtype,
    name: name.present ? name.value : this.name,
    geometryGeojson: geometryGeojson ?? this.geometryGeojson,
    countryId: countryId.present ? countryId.value : this.countryId,
    regionId: regionId.present ? regionId.value : this.regionId,
    cityId: cityId.present ? cityId.value : this.cityId,
    cityCenterId: cityCenterId.present ? cityCenterId.value : this.cityCenterId,
    drivable: drivable.present ? drivable.value : this.drivable,
    walkable: walkable.present ? walkable.value : this.walkable,
    cycleway: cycleway.present ? cycleway.value : this.cycleway,
    lengthM: lengthM.present ? lengthM.value : this.lengthM,
    countrySlug: countrySlug ?? this.countrySlug,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  StaticObject copyWithCompanion(StaticObjectsCompanion data) {
    return StaticObject(
      objectId: data.objectId.present ? data.objectId.value : this.objectId,
      category: data.category.present ? data.category.value : this.category,
      subtype: data.subtype.present ? data.subtype.value : this.subtype,
      name: data.name.present ? data.name.value : this.name,
      geometryGeojson: data.geometryGeojson.present
          ? data.geometryGeojson.value
          : this.geometryGeojson,
      countryId: data.countryId.present ? data.countryId.value : this.countryId,
      regionId: data.regionId.present ? data.regionId.value : this.regionId,
      cityId: data.cityId.present ? data.cityId.value : this.cityId,
      cityCenterId: data.cityCenterId.present
          ? data.cityCenterId.value
          : this.cityCenterId,
      drivable: data.drivable.present ? data.drivable.value : this.drivable,
      walkable: data.walkable.present ? data.walkable.value : this.walkable,
      cycleway: data.cycleway.present ? data.cycleway.value : this.cycleway,
      lengthM: data.lengthM.present ? data.lengthM.value : this.lengthM,
      countrySlug: data.countrySlug.present
          ? data.countrySlug.value
          : this.countrySlug,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StaticObject(')
          ..write('objectId: $objectId, ')
          ..write('category: $category, ')
          ..write('subtype: $subtype, ')
          ..write('name: $name, ')
          ..write('geometryGeojson: $geometryGeojson, ')
          ..write('countryId: $countryId, ')
          ..write('regionId: $regionId, ')
          ..write('cityId: $cityId, ')
          ..write('cityCenterId: $cityCenterId, ')
          ..write('drivable: $drivable, ')
          ..write('walkable: $walkable, ')
          ..write('cycleway: $cycleway, ')
          ..write('lengthM: $lengthM, ')
          ..write('countrySlug: $countrySlug, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    objectId,
    category,
    subtype,
    name,
    geometryGeojson,
    countryId,
    regionId,
    cityId,
    cityCenterId,
    drivable,
    walkable,
    cycleway,
    lengthM,
    countrySlug,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StaticObject &&
          other.objectId == this.objectId &&
          other.category == this.category &&
          other.subtype == this.subtype &&
          other.name == this.name &&
          other.geometryGeojson == this.geometryGeojson &&
          other.countryId == this.countryId &&
          other.regionId == this.regionId &&
          other.cityId == this.cityId &&
          other.cityCenterId == this.cityCenterId &&
          other.drivable == this.drivable &&
          other.walkable == this.walkable &&
          other.cycleway == this.cycleway &&
          other.lengthM == this.lengthM &&
          other.countrySlug == this.countrySlug &&
          other.updatedAt == this.updatedAt);
}

class StaticObjectsCompanion extends UpdateCompanion<StaticObject> {
  final Value<String> objectId;
  final Value<String> category;
  final Value<String?> subtype;
  final Value<String?> name;
  final Value<String> geometryGeojson;
  final Value<String?> countryId;
  final Value<String?> regionId;
  final Value<String?> cityId;
  final Value<String?> cityCenterId;
  final Value<bool?> drivable;
  final Value<bool?> walkable;
  final Value<bool?> cycleway;
  final Value<double?> lengthM;
  final Value<String> countrySlug;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const StaticObjectsCompanion({
    this.objectId = const Value.absent(),
    this.category = const Value.absent(),
    this.subtype = const Value.absent(),
    this.name = const Value.absent(),
    this.geometryGeojson = const Value.absent(),
    this.countryId = const Value.absent(),
    this.regionId = const Value.absent(),
    this.cityId = const Value.absent(),
    this.cityCenterId = const Value.absent(),
    this.drivable = const Value.absent(),
    this.walkable = const Value.absent(),
    this.cycleway = const Value.absent(),
    this.lengthM = const Value.absent(),
    this.countrySlug = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StaticObjectsCompanion.insert({
    required String objectId,
    required String category,
    this.subtype = const Value.absent(),
    this.name = const Value.absent(),
    required String geometryGeojson,
    this.countryId = const Value.absent(),
    this.regionId = const Value.absent(),
    this.cityId = const Value.absent(),
    this.cityCenterId = const Value.absent(),
    this.drivable = const Value.absent(),
    this.walkable = const Value.absent(),
    this.cycleway = const Value.absent(),
    this.lengthM = const Value.absent(),
    required String countrySlug,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : objectId = Value(objectId),
       category = Value(category),
       geometryGeojson = Value(geometryGeojson),
       countrySlug = Value(countrySlug),
       updatedAt = Value(updatedAt);
  static Insertable<StaticObject> custom({
    Expression<String>? objectId,
    Expression<String>? category,
    Expression<String>? subtype,
    Expression<String>? name,
    Expression<String>? geometryGeojson,
    Expression<String>? countryId,
    Expression<String>? regionId,
    Expression<String>? cityId,
    Expression<String>? cityCenterId,
    Expression<bool>? drivable,
    Expression<bool>? walkable,
    Expression<bool>? cycleway,
    Expression<double>? lengthM,
    Expression<String>? countrySlug,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (objectId != null) 'object_id': objectId,
      if (category != null) 'category': category,
      if (subtype != null) 'subtype': subtype,
      if (name != null) 'name': name,
      if (geometryGeojson != null) 'geometry_geojson': geometryGeojson,
      if (countryId != null) 'country_id': countryId,
      if (regionId != null) 'region_id': regionId,
      if (cityId != null) 'city_id': cityId,
      if (cityCenterId != null) 'city_center_id': cityCenterId,
      if (drivable != null) 'drivable': drivable,
      if (walkable != null) 'walkable': walkable,
      if (cycleway != null) 'cycleway': cycleway,
      if (lengthM != null) 'length_m': lengthM,
      if (countrySlug != null) 'country_slug': countrySlug,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StaticObjectsCompanion copyWith({
    Value<String>? objectId,
    Value<String>? category,
    Value<String?>? subtype,
    Value<String?>? name,
    Value<String>? geometryGeojson,
    Value<String?>? countryId,
    Value<String?>? regionId,
    Value<String?>? cityId,
    Value<String?>? cityCenterId,
    Value<bool?>? drivable,
    Value<bool?>? walkable,
    Value<bool?>? cycleway,
    Value<double?>? lengthM,
    Value<String>? countrySlug,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return StaticObjectsCompanion(
      objectId: objectId ?? this.objectId,
      category: category ?? this.category,
      subtype: subtype ?? this.subtype,
      name: name ?? this.name,
      geometryGeojson: geometryGeojson ?? this.geometryGeojson,
      countryId: countryId ?? this.countryId,
      regionId: regionId ?? this.regionId,
      cityId: cityId ?? this.cityId,
      cityCenterId: cityCenterId ?? this.cityCenterId,
      drivable: drivable ?? this.drivable,
      walkable: walkable ?? this.walkable,
      cycleway: cycleway ?? this.cycleway,
      lengthM: lengthM ?? this.lengthM,
      countrySlug: countrySlug ?? this.countrySlug,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (objectId.present) {
      map['object_id'] = Variable<String>(objectId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (subtype.present) {
      map['subtype'] = Variable<String>(subtype.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (geometryGeojson.present) {
      map['geometry_geojson'] = Variable<String>(geometryGeojson.value);
    }
    if (countryId.present) {
      map['country_id'] = Variable<String>(countryId.value);
    }
    if (regionId.present) {
      map['region_id'] = Variable<String>(regionId.value);
    }
    if (cityId.present) {
      map['city_id'] = Variable<String>(cityId.value);
    }
    if (cityCenterId.present) {
      map['city_center_id'] = Variable<String>(cityCenterId.value);
    }
    if (drivable.present) {
      map['drivable'] = Variable<bool>(drivable.value);
    }
    if (walkable.present) {
      map['walkable'] = Variable<bool>(walkable.value);
    }
    if (cycleway.present) {
      map['cycleway'] = Variable<bool>(cycleway.value);
    }
    if (lengthM.present) {
      map['length_m'] = Variable<double>(lengthM.value);
    }
    if (countrySlug.present) {
      map['country_slug'] = Variable<String>(countrySlug.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StaticObjectsCompanion(')
          ..write('objectId: $objectId, ')
          ..write('category: $category, ')
          ..write('subtype: $subtype, ')
          ..write('name: $name, ')
          ..write('geometryGeojson: $geometryGeojson, ')
          ..write('countryId: $countryId, ')
          ..write('regionId: $regionId, ')
          ..write('cityId: $cityId, ')
          ..write('cityCenterId: $cityCenterId, ')
          ..write('drivable: $drivable, ')
          ..write('walkable: $walkable, ')
          ..write('cycleway: $cycleway, ')
          ..write('lengthM: $lengthM, ')
          ..write('countrySlug: $countrySlug, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StaticEntityTotalsTable extends StaticEntityTotals
    with TableInfo<$StaticEntityTotalsTable, StaticEntityTotal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StaticEntityTotalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _peaksCountMeta = const VerificationMeta(
    'peaksCount',
  );
  @override
  late final GeneratedColumn<int> peaksCount = GeneratedColumn<int>(
    'peaks_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hutsCountMeta = const VerificationMeta(
    'hutsCount',
  );
  @override
  late final GeneratedColumn<int> hutsCount = GeneratedColumn<int>(
    'huts_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _monumentsCountMeta = const VerificationMeta(
    'monumentsCount',
  );
  @override
  late final GeneratedColumn<int> monumentsCount = GeneratedColumn<int>(
    'monuments_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _roadsDrivableLengthMMeta =
      const VerificationMeta('roadsDrivableLengthM');
  @override
  late final GeneratedColumn<double> roadsDrivableLengthM =
      GeneratedColumn<double>(
        'roads_drivable_length_m',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _roadsWalkableLengthMMeta =
      const VerificationMeta('roadsWalkableLengthM');
  @override
  late final GeneratedColumn<double> roadsWalkableLengthM =
      GeneratedColumn<double>(
        'roads_walkable_length_m',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _roadsCyclewayLengthMMeta =
      const VerificationMeta('roadsCyclewayLengthM');
  @override
  late final GeneratedColumn<double> roadsCyclewayLengthM =
      GeneratedColumn<double>(
        'roads_cycleway_length_m',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    entityId,
    peaksCount,
    hutsCount,
    monumentsCount,
    roadsDrivableLengthM,
    roadsWalkableLengthM,
    roadsCyclewayLengthM,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'static_entity_totals';
  @override
  VerificationContext validateIntegrity(
    Insertable<StaticEntityTotal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('peaks_count')) {
      context.handle(
        _peaksCountMeta,
        peaksCount.isAcceptableOrUnknown(data['peaks_count']!, _peaksCountMeta),
      );
    }
    if (data.containsKey('huts_count')) {
      context.handle(
        _hutsCountMeta,
        hutsCount.isAcceptableOrUnknown(data['huts_count']!, _hutsCountMeta),
      );
    }
    if (data.containsKey('monuments_count')) {
      context.handle(
        _monumentsCountMeta,
        monumentsCount.isAcceptableOrUnknown(
          data['monuments_count']!,
          _monumentsCountMeta,
        ),
      );
    }
    if (data.containsKey('roads_drivable_length_m')) {
      context.handle(
        _roadsDrivableLengthMMeta,
        roadsDrivableLengthM.isAcceptableOrUnknown(
          data['roads_drivable_length_m']!,
          _roadsDrivableLengthMMeta,
        ),
      );
    }
    if (data.containsKey('roads_walkable_length_m')) {
      context.handle(
        _roadsWalkableLengthMMeta,
        roadsWalkableLengthM.isAcceptableOrUnknown(
          data['roads_walkable_length_m']!,
          _roadsWalkableLengthMMeta,
        ),
      );
    }
    if (data.containsKey('roads_cycleway_length_m')) {
      context.handle(
        _roadsCyclewayLengthMMeta,
        roadsCyclewayLengthM.isAcceptableOrUnknown(
          data['roads_cycleway_length_m']!,
          _roadsCyclewayLengthMMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityId};
  @override
  StaticEntityTotal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StaticEntityTotal(
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      peaksCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}peaks_count'],
      )!,
      hutsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}huts_count'],
      )!,
      monumentsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monuments_count'],
      )!,
      roadsDrivableLengthM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}roads_drivable_length_m'],
      )!,
      roadsWalkableLengthM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}roads_walkable_length_m'],
      )!,
      roadsCyclewayLengthM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}roads_cycleway_length_m'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $StaticEntityTotalsTable createAlias(String alias) {
    return $StaticEntityTotalsTable(attachedDatabase, alias);
  }
}

class StaticEntityTotal extends DataClass
    implements Insertable<StaticEntityTotal> {
  final String entityId;
  final int peaksCount;
  final int hutsCount;
  final int monumentsCount;
  final double roadsDrivableLengthM;
  final double roadsWalkableLengthM;
  final double roadsCyclewayLengthM;
  final int updatedAt;
  const StaticEntityTotal({
    required this.entityId,
    required this.peaksCount,
    required this.hutsCount,
    required this.monumentsCount,
    required this.roadsDrivableLengthM,
    required this.roadsWalkableLengthM,
    required this.roadsCyclewayLengthM,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_id'] = Variable<String>(entityId);
    map['peaks_count'] = Variable<int>(peaksCount);
    map['huts_count'] = Variable<int>(hutsCount);
    map['monuments_count'] = Variable<int>(monumentsCount);
    map['roads_drivable_length_m'] = Variable<double>(roadsDrivableLengthM);
    map['roads_walkable_length_m'] = Variable<double>(roadsWalkableLengthM);
    map['roads_cycleway_length_m'] = Variable<double>(roadsCyclewayLengthM);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  StaticEntityTotalsCompanion toCompanion(bool nullToAbsent) {
    return StaticEntityTotalsCompanion(
      entityId: Value(entityId),
      peaksCount: Value(peaksCount),
      hutsCount: Value(hutsCount),
      monumentsCount: Value(monumentsCount),
      roadsDrivableLengthM: Value(roadsDrivableLengthM),
      roadsWalkableLengthM: Value(roadsWalkableLengthM),
      roadsCyclewayLengthM: Value(roadsCyclewayLengthM),
      updatedAt: Value(updatedAt),
    );
  }

  factory StaticEntityTotal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StaticEntityTotal(
      entityId: serializer.fromJson<String>(json['entityId']),
      peaksCount: serializer.fromJson<int>(json['peaksCount']),
      hutsCount: serializer.fromJson<int>(json['hutsCount']),
      monumentsCount: serializer.fromJson<int>(json['monumentsCount']),
      roadsDrivableLengthM: serializer.fromJson<double>(
        json['roadsDrivableLengthM'],
      ),
      roadsWalkableLengthM: serializer.fromJson<double>(
        json['roadsWalkableLengthM'],
      ),
      roadsCyclewayLengthM: serializer.fromJson<double>(
        json['roadsCyclewayLengthM'],
      ),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityId': serializer.toJson<String>(entityId),
      'peaksCount': serializer.toJson<int>(peaksCount),
      'hutsCount': serializer.toJson<int>(hutsCount),
      'monumentsCount': serializer.toJson<int>(monumentsCount),
      'roadsDrivableLengthM': serializer.toJson<double>(roadsDrivableLengthM),
      'roadsWalkableLengthM': serializer.toJson<double>(roadsWalkableLengthM),
      'roadsCyclewayLengthM': serializer.toJson<double>(roadsCyclewayLengthM),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  StaticEntityTotal copyWith({
    String? entityId,
    int? peaksCount,
    int? hutsCount,
    int? monumentsCount,
    double? roadsDrivableLengthM,
    double? roadsWalkableLengthM,
    double? roadsCyclewayLengthM,
    int? updatedAt,
  }) => StaticEntityTotal(
    entityId: entityId ?? this.entityId,
    peaksCount: peaksCount ?? this.peaksCount,
    hutsCount: hutsCount ?? this.hutsCount,
    monumentsCount: monumentsCount ?? this.monumentsCount,
    roadsDrivableLengthM: roadsDrivableLengthM ?? this.roadsDrivableLengthM,
    roadsWalkableLengthM: roadsWalkableLengthM ?? this.roadsWalkableLengthM,
    roadsCyclewayLengthM: roadsCyclewayLengthM ?? this.roadsCyclewayLengthM,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  StaticEntityTotal copyWithCompanion(StaticEntityTotalsCompanion data) {
    return StaticEntityTotal(
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      peaksCount: data.peaksCount.present
          ? data.peaksCount.value
          : this.peaksCount,
      hutsCount: data.hutsCount.present ? data.hutsCount.value : this.hutsCount,
      monumentsCount: data.monumentsCount.present
          ? data.monumentsCount.value
          : this.monumentsCount,
      roadsDrivableLengthM: data.roadsDrivableLengthM.present
          ? data.roadsDrivableLengthM.value
          : this.roadsDrivableLengthM,
      roadsWalkableLengthM: data.roadsWalkableLengthM.present
          ? data.roadsWalkableLengthM.value
          : this.roadsWalkableLengthM,
      roadsCyclewayLengthM: data.roadsCyclewayLengthM.present
          ? data.roadsCyclewayLengthM.value
          : this.roadsCyclewayLengthM,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StaticEntityTotal(')
          ..write('entityId: $entityId, ')
          ..write('peaksCount: $peaksCount, ')
          ..write('hutsCount: $hutsCount, ')
          ..write('monumentsCount: $monumentsCount, ')
          ..write('roadsDrivableLengthM: $roadsDrivableLengthM, ')
          ..write('roadsWalkableLengthM: $roadsWalkableLengthM, ')
          ..write('roadsCyclewayLengthM: $roadsCyclewayLengthM, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    entityId,
    peaksCount,
    hutsCount,
    monumentsCount,
    roadsDrivableLengthM,
    roadsWalkableLengthM,
    roadsCyclewayLengthM,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StaticEntityTotal &&
          other.entityId == this.entityId &&
          other.peaksCount == this.peaksCount &&
          other.hutsCount == this.hutsCount &&
          other.monumentsCount == this.monumentsCount &&
          other.roadsDrivableLengthM == this.roadsDrivableLengthM &&
          other.roadsWalkableLengthM == this.roadsWalkableLengthM &&
          other.roadsCyclewayLengthM == this.roadsCyclewayLengthM &&
          other.updatedAt == this.updatedAt);
}

class StaticEntityTotalsCompanion extends UpdateCompanion<StaticEntityTotal> {
  final Value<String> entityId;
  final Value<int> peaksCount;
  final Value<int> hutsCount;
  final Value<int> monumentsCount;
  final Value<double> roadsDrivableLengthM;
  final Value<double> roadsWalkableLengthM;
  final Value<double> roadsCyclewayLengthM;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const StaticEntityTotalsCompanion({
    this.entityId = const Value.absent(),
    this.peaksCount = const Value.absent(),
    this.hutsCount = const Value.absent(),
    this.monumentsCount = const Value.absent(),
    this.roadsDrivableLengthM = const Value.absent(),
    this.roadsWalkableLengthM = const Value.absent(),
    this.roadsCyclewayLengthM = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StaticEntityTotalsCompanion.insert({
    required String entityId,
    this.peaksCount = const Value.absent(),
    this.hutsCount = const Value.absent(),
    this.monumentsCount = const Value.absent(),
    this.roadsDrivableLengthM = const Value.absent(),
    this.roadsWalkableLengthM = const Value.absent(),
    this.roadsCyclewayLengthM = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : entityId = Value(entityId),
       updatedAt = Value(updatedAt);
  static Insertable<StaticEntityTotal> custom({
    Expression<String>? entityId,
    Expression<int>? peaksCount,
    Expression<int>? hutsCount,
    Expression<int>? monumentsCount,
    Expression<double>? roadsDrivableLengthM,
    Expression<double>? roadsWalkableLengthM,
    Expression<double>? roadsCyclewayLengthM,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityId != null) 'entity_id': entityId,
      if (peaksCount != null) 'peaks_count': peaksCount,
      if (hutsCount != null) 'huts_count': hutsCount,
      if (monumentsCount != null) 'monuments_count': monumentsCount,
      if (roadsDrivableLengthM != null)
        'roads_drivable_length_m': roadsDrivableLengthM,
      if (roadsWalkableLengthM != null)
        'roads_walkable_length_m': roadsWalkableLengthM,
      if (roadsCyclewayLengthM != null)
        'roads_cycleway_length_m': roadsCyclewayLengthM,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StaticEntityTotalsCompanion copyWith({
    Value<String>? entityId,
    Value<int>? peaksCount,
    Value<int>? hutsCount,
    Value<int>? monumentsCount,
    Value<double>? roadsDrivableLengthM,
    Value<double>? roadsWalkableLengthM,
    Value<double>? roadsCyclewayLengthM,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return StaticEntityTotalsCompanion(
      entityId: entityId ?? this.entityId,
      peaksCount: peaksCount ?? this.peaksCount,
      hutsCount: hutsCount ?? this.hutsCount,
      monumentsCount: monumentsCount ?? this.monumentsCount,
      roadsDrivableLengthM: roadsDrivableLengthM ?? this.roadsDrivableLengthM,
      roadsWalkableLengthM: roadsWalkableLengthM ?? this.roadsWalkableLengthM,
      roadsCyclewayLengthM: roadsCyclewayLengthM ?? this.roadsCyclewayLengthM,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (peaksCount.present) {
      map['peaks_count'] = Variable<int>(peaksCount.value);
    }
    if (hutsCount.present) {
      map['huts_count'] = Variable<int>(hutsCount.value);
    }
    if (monumentsCount.present) {
      map['monuments_count'] = Variable<int>(monumentsCount.value);
    }
    if (roadsDrivableLengthM.present) {
      map['roads_drivable_length_m'] = Variable<double>(
        roadsDrivableLengthM.value,
      );
    }
    if (roadsWalkableLengthM.present) {
      map['roads_walkable_length_m'] = Variable<double>(
        roadsWalkableLengthM.value,
      );
    }
    if (roadsCyclewayLengthM.present) {
      map['roads_cycleway_length_m'] = Variable<double>(
        roadsCyclewayLengthM.value,
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StaticEntityTotalsCompanion(')
          ..write('entityId: $entityId, ')
          ..write('peaksCount: $peaksCount, ')
          ..write('hutsCount: $hutsCount, ')
          ..write('monumentsCount: $monumentsCount, ')
          ..write('roadsDrivableLengthM: $roadsDrivableLengthM, ')
          ..write('roadsWalkableLengthM: $roadsWalkableLengthM, ')
          ..write('roadsCyclewayLengthM: $roadsCyclewayLengthM, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SelectedEntityStateTable extends SelectedEntityState
    with TableInfo<$SelectedEntityStateTable, SelectedEntityStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SelectedEntityStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _scopeKeyMeta = const VerificationMeta(
    'scopeKey',
  );
  @override
  late final GeneratedColumn<String> scopeKey = GeneratedColumn<String>(
    'scope_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [scopeKey, entityId, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'selected_entity_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SelectedEntityStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('scope_key')) {
      context.handle(
        _scopeKeyMeta,
        scopeKey.isAcceptableOrUnknown(data['scope_key']!, _scopeKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeKeyMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {scopeKey};
  @override
  SelectedEntityStateData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SelectedEntityStateData(
      scopeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_key'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SelectedEntityStateTable createAlias(String alias) {
    return $SelectedEntityStateTable(attachedDatabase, alias);
  }
}

class SelectedEntityStateData extends DataClass
    implements Insertable<SelectedEntityStateData> {
  final String scopeKey;
  final String entityId;
  final int updatedAt;
  const SelectedEntityStateData({
    required this.scopeKey,
    required this.entityId,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['scope_key'] = Variable<String>(scopeKey);
    map['entity_id'] = Variable<String>(entityId);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  SelectedEntityStateCompanion toCompanion(bool nullToAbsent) {
    return SelectedEntityStateCompanion(
      scopeKey: Value(scopeKey),
      entityId: Value(entityId),
      updatedAt: Value(updatedAt),
    );
  }

  factory SelectedEntityStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SelectedEntityStateData(
      scopeKey: serializer.fromJson<String>(json['scopeKey']),
      entityId: serializer.fromJson<String>(json['entityId']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'scopeKey': serializer.toJson<String>(scopeKey),
      'entityId': serializer.toJson<String>(entityId),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  SelectedEntityStateData copyWith({
    String? scopeKey,
    String? entityId,
    int? updatedAt,
  }) => SelectedEntityStateData(
    scopeKey: scopeKey ?? this.scopeKey,
    entityId: entityId ?? this.entityId,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SelectedEntityStateData copyWithCompanion(SelectedEntityStateCompanion data) {
    return SelectedEntityStateData(
      scopeKey: data.scopeKey.present ? data.scopeKey.value : this.scopeKey,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SelectedEntityStateData(')
          ..write('scopeKey: $scopeKey, ')
          ..write('entityId: $entityId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(scopeKey, entityId, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SelectedEntityStateData &&
          other.scopeKey == this.scopeKey &&
          other.entityId == this.entityId &&
          other.updatedAt == this.updatedAt);
}

class SelectedEntityStateCompanion
    extends UpdateCompanion<SelectedEntityStateData> {
  final Value<String> scopeKey;
  final Value<String> entityId;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const SelectedEntityStateCompanion({
    this.scopeKey = const Value.absent(),
    this.entityId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SelectedEntityStateCompanion.insert({
    required String scopeKey,
    required String entityId,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : scopeKey = Value(scopeKey),
       entityId = Value(entityId),
       updatedAt = Value(updatedAt);
  static Insertable<SelectedEntityStateData> custom({
    Expression<String>? scopeKey,
    Expression<String>? entityId,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (scopeKey != null) 'scope_key': scopeKey,
      if (entityId != null) 'entity_id': entityId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SelectedEntityStateCompanion copyWith({
    Value<String>? scopeKey,
    Value<String>? entityId,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return SelectedEntityStateCompanion(
      scopeKey: scopeKey ?? this.scopeKey,
      entityId: entityId ?? this.entityId,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (scopeKey.present) {
      map['scope_key'] = Variable<String>(scopeKey.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SelectedEntityStateCompanion(')
          ..write('scopeKey: $scopeKey, ')
          ..write('entityId: $entityId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserObjectProgressTable extends UserObjectProgress
    with TableInfo<$UserObjectProgressTable, UserObjectProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserObjectProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _objectIdMeta = const VerificationMeta(
    'objectId',
  );
  @override
  late final GeneratedColumn<String> objectId = GeneratedColumn<String>(
    'object_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exploredMeta = const VerificationMeta(
    'explored',
  );
  @override
  late final GeneratedColumn<bool> explored = GeneratedColumn<bool>(
    'explored',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("explored" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _firstExploredAtMeta = const VerificationMeta(
    'firstExploredAt',
  );
  @override
  late final GeneratedColumn<int> firstExploredAt = GeneratedColumn<int>(
    'first_explored_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bestDistanceMMeta = const VerificationMeta(
    'bestDistanceM',
  );
  @override
  late final GeneratedColumn<double> bestDistanceM = GeneratedColumn<double>(
    'best_distance_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sampleCountUsedMeta = const VerificationMeta(
    'sampleCountUsed',
  );
  @override
  late final GeneratedColumn<int> sampleCountUsed = GeneratedColumn<int>(
    'sample_count_used',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<int> lastSeenAt = GeneratedColumn<int>(
    'last_seen_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    objectId,
    category,
    explored,
    firstExploredAt,
    bestDistanceM,
    confidence,
    sourceType,
    sampleCountUsed,
    lastSeenAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_object_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserObjectProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('object_id')) {
      context.handle(
        _objectIdMeta,
        objectId.isAcceptableOrUnknown(data['object_id']!, _objectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_objectIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('explored')) {
      context.handle(
        _exploredMeta,
        explored.isAcceptableOrUnknown(data['explored']!, _exploredMeta),
      );
    }
    if (data.containsKey('first_explored_at')) {
      context.handle(
        _firstExploredAtMeta,
        firstExploredAt.isAcceptableOrUnknown(
          data['first_explored_at']!,
          _firstExploredAtMeta,
        ),
      );
    }
    if (data.containsKey('best_distance_m')) {
      context.handle(
        _bestDistanceMMeta,
        bestDistanceM.isAcceptableOrUnknown(
          data['best_distance_m']!,
          _bestDistanceMMeta,
        ),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    }
    if (data.containsKey('sample_count_used')) {
      context.handle(
        _sampleCountUsedMeta,
        sampleCountUsed.isAcceptableOrUnknown(
          data['sample_count_used']!,
          _sampleCountUsedMeta,
        ),
      );
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, objectId};
  @override
  UserObjectProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserObjectProgressData(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      objectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}object_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      explored: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}explored'],
      )!,
      firstExploredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_explored_at'],
      ),
      bestDistanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}best_distance_m'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      ),
      sampleCountUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sample_count_used'],
      ),
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seen_at'],
      ),
    );
  }

  @override
  $UserObjectProgressTable createAlias(String alias) {
    return $UserObjectProgressTable(attachedDatabase, alias);
  }
}

class UserObjectProgressData extends DataClass
    implements Insertable<UserObjectProgressData> {
  final String userId;
  final String objectId;
  final String category;
  final bool explored;
  final int? firstExploredAt;
  final double? bestDistanceM;
  final double? confidence;
  final String? sourceType;
  final int? sampleCountUsed;
  final int? lastSeenAt;
  const UserObjectProgressData({
    required this.userId,
    required this.objectId,
    required this.category,
    required this.explored,
    this.firstExploredAt,
    this.bestDistanceM,
    this.confidence,
    this.sourceType,
    this.sampleCountUsed,
    this.lastSeenAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['object_id'] = Variable<String>(objectId);
    map['category'] = Variable<String>(category);
    map['explored'] = Variable<bool>(explored);
    if (!nullToAbsent || firstExploredAt != null) {
      map['first_explored_at'] = Variable<int>(firstExploredAt);
    }
    if (!nullToAbsent || bestDistanceM != null) {
      map['best_distance_m'] = Variable<double>(bestDistanceM);
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    if (!nullToAbsent || sourceType != null) {
      map['source_type'] = Variable<String>(sourceType);
    }
    if (!nullToAbsent || sampleCountUsed != null) {
      map['sample_count_used'] = Variable<int>(sampleCountUsed);
    }
    if (!nullToAbsent || lastSeenAt != null) {
      map['last_seen_at'] = Variable<int>(lastSeenAt);
    }
    return map;
  }

  UserObjectProgressCompanion toCompanion(bool nullToAbsent) {
    return UserObjectProgressCompanion(
      userId: Value(userId),
      objectId: Value(objectId),
      category: Value(category),
      explored: Value(explored),
      firstExploredAt: firstExploredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(firstExploredAt),
      bestDistanceM: bestDistanceM == null && nullToAbsent
          ? const Value.absent()
          : Value(bestDistanceM),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      sourceType: sourceType == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceType),
      sampleCountUsed: sampleCountUsed == null && nullToAbsent
          ? const Value.absent()
          : Value(sampleCountUsed),
      lastSeenAt: lastSeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenAt),
    );
  }

  factory UserObjectProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserObjectProgressData(
      userId: serializer.fromJson<String>(json['userId']),
      objectId: serializer.fromJson<String>(json['objectId']),
      category: serializer.fromJson<String>(json['category']),
      explored: serializer.fromJson<bool>(json['explored']),
      firstExploredAt: serializer.fromJson<int?>(json['firstExploredAt']),
      bestDistanceM: serializer.fromJson<double?>(json['bestDistanceM']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      sourceType: serializer.fromJson<String?>(json['sourceType']),
      sampleCountUsed: serializer.fromJson<int?>(json['sampleCountUsed']),
      lastSeenAt: serializer.fromJson<int?>(json['lastSeenAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'objectId': serializer.toJson<String>(objectId),
      'category': serializer.toJson<String>(category),
      'explored': serializer.toJson<bool>(explored),
      'firstExploredAt': serializer.toJson<int?>(firstExploredAt),
      'bestDistanceM': serializer.toJson<double?>(bestDistanceM),
      'confidence': serializer.toJson<double?>(confidence),
      'sourceType': serializer.toJson<String?>(sourceType),
      'sampleCountUsed': serializer.toJson<int?>(sampleCountUsed),
      'lastSeenAt': serializer.toJson<int?>(lastSeenAt),
    };
  }

  UserObjectProgressData copyWith({
    String? userId,
    String? objectId,
    String? category,
    bool? explored,
    Value<int?> firstExploredAt = const Value.absent(),
    Value<double?> bestDistanceM = const Value.absent(),
    Value<double?> confidence = const Value.absent(),
    Value<String?> sourceType = const Value.absent(),
    Value<int?> sampleCountUsed = const Value.absent(),
    Value<int?> lastSeenAt = const Value.absent(),
  }) => UserObjectProgressData(
    userId: userId ?? this.userId,
    objectId: objectId ?? this.objectId,
    category: category ?? this.category,
    explored: explored ?? this.explored,
    firstExploredAt: firstExploredAt.present
        ? firstExploredAt.value
        : this.firstExploredAt,
    bestDistanceM: bestDistanceM.present
        ? bestDistanceM.value
        : this.bestDistanceM,
    confidence: confidence.present ? confidence.value : this.confidence,
    sourceType: sourceType.present ? sourceType.value : this.sourceType,
    sampleCountUsed: sampleCountUsed.present
        ? sampleCountUsed.value
        : this.sampleCountUsed,
    lastSeenAt: lastSeenAt.present ? lastSeenAt.value : this.lastSeenAt,
  );
  UserObjectProgressData copyWithCompanion(UserObjectProgressCompanion data) {
    return UserObjectProgressData(
      userId: data.userId.present ? data.userId.value : this.userId,
      objectId: data.objectId.present ? data.objectId.value : this.objectId,
      category: data.category.present ? data.category.value : this.category,
      explored: data.explored.present ? data.explored.value : this.explored,
      firstExploredAt: data.firstExploredAt.present
          ? data.firstExploredAt.value
          : this.firstExploredAt,
      bestDistanceM: data.bestDistanceM.present
          ? data.bestDistanceM.value
          : this.bestDistanceM,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      sampleCountUsed: data.sampleCountUsed.present
          ? data.sampleCountUsed.value
          : this.sampleCountUsed,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserObjectProgressData(')
          ..write('userId: $userId, ')
          ..write('objectId: $objectId, ')
          ..write('category: $category, ')
          ..write('explored: $explored, ')
          ..write('firstExploredAt: $firstExploredAt, ')
          ..write('bestDistanceM: $bestDistanceM, ')
          ..write('confidence: $confidence, ')
          ..write('sourceType: $sourceType, ')
          ..write('sampleCountUsed: $sampleCountUsed, ')
          ..write('lastSeenAt: $lastSeenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    objectId,
    category,
    explored,
    firstExploredAt,
    bestDistanceM,
    confidence,
    sourceType,
    sampleCountUsed,
    lastSeenAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserObjectProgressData &&
          other.userId == this.userId &&
          other.objectId == this.objectId &&
          other.category == this.category &&
          other.explored == this.explored &&
          other.firstExploredAt == this.firstExploredAt &&
          other.bestDistanceM == this.bestDistanceM &&
          other.confidence == this.confidence &&
          other.sourceType == this.sourceType &&
          other.sampleCountUsed == this.sampleCountUsed &&
          other.lastSeenAt == this.lastSeenAt);
}

class UserObjectProgressCompanion
    extends UpdateCompanion<UserObjectProgressData> {
  final Value<String> userId;
  final Value<String> objectId;
  final Value<String> category;
  final Value<bool> explored;
  final Value<int?> firstExploredAt;
  final Value<double?> bestDistanceM;
  final Value<double?> confidence;
  final Value<String?> sourceType;
  final Value<int?> sampleCountUsed;
  final Value<int?> lastSeenAt;
  final Value<int> rowid;
  const UserObjectProgressCompanion({
    this.userId = const Value.absent(),
    this.objectId = const Value.absent(),
    this.category = const Value.absent(),
    this.explored = const Value.absent(),
    this.firstExploredAt = const Value.absent(),
    this.bestDistanceM = const Value.absent(),
    this.confidence = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sampleCountUsed = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserObjectProgressCompanion.insert({
    required String userId,
    required String objectId,
    required String category,
    this.explored = const Value.absent(),
    this.firstExploredAt = const Value.absent(),
    this.bestDistanceM = const Value.absent(),
    this.confidence = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sampleCountUsed = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       objectId = Value(objectId),
       category = Value(category);
  static Insertable<UserObjectProgressData> custom({
    Expression<String>? userId,
    Expression<String>? objectId,
    Expression<String>? category,
    Expression<bool>? explored,
    Expression<int>? firstExploredAt,
    Expression<double>? bestDistanceM,
    Expression<double>? confidence,
    Expression<String>? sourceType,
    Expression<int>? sampleCountUsed,
    Expression<int>? lastSeenAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (objectId != null) 'object_id': objectId,
      if (category != null) 'category': category,
      if (explored != null) 'explored': explored,
      if (firstExploredAt != null) 'first_explored_at': firstExploredAt,
      if (bestDistanceM != null) 'best_distance_m': bestDistanceM,
      if (confidence != null) 'confidence': confidence,
      if (sourceType != null) 'source_type': sourceType,
      if (sampleCountUsed != null) 'sample_count_used': sampleCountUsed,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserObjectProgressCompanion copyWith({
    Value<String>? userId,
    Value<String>? objectId,
    Value<String>? category,
    Value<bool>? explored,
    Value<int?>? firstExploredAt,
    Value<double?>? bestDistanceM,
    Value<double?>? confidence,
    Value<String?>? sourceType,
    Value<int?>? sampleCountUsed,
    Value<int?>? lastSeenAt,
    Value<int>? rowid,
  }) {
    return UserObjectProgressCompanion(
      userId: userId ?? this.userId,
      objectId: objectId ?? this.objectId,
      category: category ?? this.category,
      explored: explored ?? this.explored,
      firstExploredAt: firstExploredAt ?? this.firstExploredAt,
      bestDistanceM: bestDistanceM ?? this.bestDistanceM,
      confidence: confidence ?? this.confidence,
      sourceType: sourceType ?? this.sourceType,
      sampleCountUsed: sampleCountUsed ?? this.sampleCountUsed,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (objectId.present) {
      map['object_id'] = Variable<String>(objectId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (explored.present) {
      map['explored'] = Variable<bool>(explored.value);
    }
    if (firstExploredAt.present) {
      map['first_explored_at'] = Variable<int>(firstExploredAt.value);
    }
    if (bestDistanceM.present) {
      map['best_distance_m'] = Variable<double>(bestDistanceM.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (sampleCountUsed.present) {
      map['sample_count_used'] = Variable<int>(sampleCountUsed.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<int>(lastSeenAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserObjectProgressCompanion(')
          ..write('userId: $userId, ')
          ..write('objectId: $objectId, ')
          ..write('category: $category, ')
          ..write('explored: $explored, ')
          ..write('firstExploredAt: $firstExploredAt, ')
          ..write('bestDistanceM: $bestDistanceM, ')
          ..write('confidence: $confidence, ')
          ..write('sourceType: $sourceType, ')
          ..write('sampleCountUsed: $sampleCountUsed, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserRoadSegmentProgressTable extends UserRoadSegmentProgress
    with TableInfo<$UserRoadSegmentProgressTable, UserRoadSegmentProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserRoadSegmentProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roadSegmentIdMeta = const VerificationMeta(
    'roadSegmentId',
  );
  @override
  late final GeneratedColumn<String> roadSegmentId = GeneratedColumn<String>(
    'road_segment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coveredLengthMMeta = const VerificationMeta(
    'coveredLengthM',
  );
  @override
  late final GeneratedColumn<double> coveredLengthM = GeneratedColumn<double>(
    'covered_length_m',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _coverageRatioMeta = const VerificationMeta(
    'coverageRatio',
  );
  @override
  late final GeneratedColumn<double> coverageRatio = GeneratedColumn<double>(
    'coverage_ratio',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _coveredIntervalsJsonMeta =
      const VerificationMeta('coveredIntervalsJson');
  @override
  late final GeneratedColumn<String> coveredIntervalsJson =
      GeneratedColumn<String>(
        'covered_intervals_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _firstCoveredAtMeta = const VerificationMeta(
    'firstCoveredAt',
  );
  @override
  late final GeneratedColumn<int> firstCoveredAt = GeneratedColumn<int>(
    'first_covered_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastCoveredAtMeta = const VerificationMeta(
    'lastCoveredAt',
  );
  @override
  late final GeneratedColumn<int> lastCoveredAt = GeneratedColumn<int>(
    'last_covered_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sampleCountUsedMeta = const VerificationMeta(
    'sampleCountUsed',
  );
  @override
  late final GeneratedColumn<int> sampleCountUsed = GeneratedColumn<int>(
    'sample_count_used',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    roadSegmentId,
    coveredLengthM,
    coverageRatio,
    coveredIntervalsJson,
    firstCoveredAt,
    lastCoveredAt,
    sampleCountUsed,
    sourceType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_road_segment_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserRoadSegmentProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('road_segment_id')) {
      context.handle(
        _roadSegmentIdMeta,
        roadSegmentId.isAcceptableOrUnknown(
          data['road_segment_id']!,
          _roadSegmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_roadSegmentIdMeta);
    }
    if (data.containsKey('covered_length_m')) {
      context.handle(
        _coveredLengthMMeta,
        coveredLengthM.isAcceptableOrUnknown(
          data['covered_length_m']!,
          _coveredLengthMMeta,
        ),
      );
    }
    if (data.containsKey('coverage_ratio')) {
      context.handle(
        _coverageRatioMeta,
        coverageRatio.isAcceptableOrUnknown(
          data['coverage_ratio']!,
          _coverageRatioMeta,
        ),
      );
    }
    if (data.containsKey('covered_intervals_json')) {
      context.handle(
        _coveredIntervalsJsonMeta,
        coveredIntervalsJson.isAcceptableOrUnknown(
          data['covered_intervals_json']!,
          _coveredIntervalsJsonMeta,
        ),
      );
    }
    if (data.containsKey('first_covered_at')) {
      context.handle(
        _firstCoveredAtMeta,
        firstCoveredAt.isAcceptableOrUnknown(
          data['first_covered_at']!,
          _firstCoveredAtMeta,
        ),
      );
    }
    if (data.containsKey('last_covered_at')) {
      context.handle(
        _lastCoveredAtMeta,
        lastCoveredAt.isAcceptableOrUnknown(
          data['last_covered_at']!,
          _lastCoveredAtMeta,
        ),
      );
    }
    if (data.containsKey('sample_count_used')) {
      context.handle(
        _sampleCountUsedMeta,
        sampleCountUsed.isAcceptableOrUnknown(
          data['sample_count_used']!,
          _sampleCountUsedMeta,
        ),
      );
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, roadSegmentId};
  @override
  UserRoadSegmentProgressData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRoadSegmentProgressData(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      roadSegmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}road_segment_id'],
      )!,
      coveredLengthM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}covered_length_m'],
      )!,
      coverageRatio: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}coverage_ratio'],
      )!,
      coveredIntervalsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}covered_intervals_json'],
      )!,
      firstCoveredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_covered_at'],
      ),
      lastCoveredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_covered_at'],
      ),
      sampleCountUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sample_count_used'],
      ),
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      ),
    );
  }

  @override
  $UserRoadSegmentProgressTable createAlias(String alias) {
    return $UserRoadSegmentProgressTable(attachedDatabase, alias);
  }
}

class UserRoadSegmentProgressData extends DataClass
    implements Insertable<UserRoadSegmentProgressData> {
  final String userId;
  final String roadSegmentId;
  final double coveredLengthM;
  final double coverageRatio;
  final String coveredIntervalsJson;
  final int? firstCoveredAt;
  final int? lastCoveredAt;
  final int? sampleCountUsed;
  final String? sourceType;
  const UserRoadSegmentProgressData({
    required this.userId,
    required this.roadSegmentId,
    required this.coveredLengthM,
    required this.coverageRatio,
    required this.coveredIntervalsJson,
    this.firstCoveredAt,
    this.lastCoveredAt,
    this.sampleCountUsed,
    this.sourceType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['road_segment_id'] = Variable<String>(roadSegmentId);
    map['covered_length_m'] = Variable<double>(coveredLengthM);
    map['coverage_ratio'] = Variable<double>(coverageRatio);
    map['covered_intervals_json'] = Variable<String>(coveredIntervalsJson);
    if (!nullToAbsent || firstCoveredAt != null) {
      map['first_covered_at'] = Variable<int>(firstCoveredAt);
    }
    if (!nullToAbsent || lastCoveredAt != null) {
      map['last_covered_at'] = Variable<int>(lastCoveredAt);
    }
    if (!nullToAbsent || sampleCountUsed != null) {
      map['sample_count_used'] = Variable<int>(sampleCountUsed);
    }
    if (!nullToAbsent || sourceType != null) {
      map['source_type'] = Variable<String>(sourceType);
    }
    return map;
  }

  UserRoadSegmentProgressCompanion toCompanion(bool nullToAbsent) {
    return UserRoadSegmentProgressCompanion(
      userId: Value(userId),
      roadSegmentId: Value(roadSegmentId),
      coveredLengthM: Value(coveredLengthM),
      coverageRatio: Value(coverageRatio),
      coveredIntervalsJson: Value(coveredIntervalsJson),
      firstCoveredAt: firstCoveredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(firstCoveredAt),
      lastCoveredAt: lastCoveredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCoveredAt),
      sampleCountUsed: sampleCountUsed == null && nullToAbsent
          ? const Value.absent()
          : Value(sampleCountUsed),
      sourceType: sourceType == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceType),
    );
  }

  factory UserRoadSegmentProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRoadSegmentProgressData(
      userId: serializer.fromJson<String>(json['userId']),
      roadSegmentId: serializer.fromJson<String>(json['roadSegmentId']),
      coveredLengthM: serializer.fromJson<double>(json['coveredLengthM']),
      coverageRatio: serializer.fromJson<double>(json['coverageRatio']),
      coveredIntervalsJson: serializer.fromJson<String>(
        json['coveredIntervalsJson'],
      ),
      firstCoveredAt: serializer.fromJson<int?>(json['firstCoveredAt']),
      lastCoveredAt: serializer.fromJson<int?>(json['lastCoveredAt']),
      sampleCountUsed: serializer.fromJson<int?>(json['sampleCountUsed']),
      sourceType: serializer.fromJson<String?>(json['sourceType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'roadSegmentId': serializer.toJson<String>(roadSegmentId),
      'coveredLengthM': serializer.toJson<double>(coveredLengthM),
      'coverageRatio': serializer.toJson<double>(coverageRatio),
      'coveredIntervalsJson': serializer.toJson<String>(coveredIntervalsJson),
      'firstCoveredAt': serializer.toJson<int?>(firstCoveredAt),
      'lastCoveredAt': serializer.toJson<int?>(lastCoveredAt),
      'sampleCountUsed': serializer.toJson<int?>(sampleCountUsed),
      'sourceType': serializer.toJson<String?>(sourceType),
    };
  }

  UserRoadSegmentProgressData copyWith({
    String? userId,
    String? roadSegmentId,
    double? coveredLengthM,
    double? coverageRatio,
    String? coveredIntervalsJson,
    Value<int?> firstCoveredAt = const Value.absent(),
    Value<int?> lastCoveredAt = const Value.absent(),
    Value<int?> sampleCountUsed = const Value.absent(),
    Value<String?> sourceType = const Value.absent(),
  }) => UserRoadSegmentProgressData(
    userId: userId ?? this.userId,
    roadSegmentId: roadSegmentId ?? this.roadSegmentId,
    coveredLengthM: coveredLengthM ?? this.coveredLengthM,
    coverageRatio: coverageRatio ?? this.coverageRatio,
    coveredIntervalsJson: coveredIntervalsJson ?? this.coveredIntervalsJson,
    firstCoveredAt: firstCoveredAt.present
        ? firstCoveredAt.value
        : this.firstCoveredAt,
    lastCoveredAt: lastCoveredAt.present
        ? lastCoveredAt.value
        : this.lastCoveredAt,
    sampleCountUsed: sampleCountUsed.present
        ? sampleCountUsed.value
        : this.sampleCountUsed,
    sourceType: sourceType.present ? sourceType.value : this.sourceType,
  );
  UserRoadSegmentProgressData copyWithCompanion(
    UserRoadSegmentProgressCompanion data,
  ) {
    return UserRoadSegmentProgressData(
      userId: data.userId.present ? data.userId.value : this.userId,
      roadSegmentId: data.roadSegmentId.present
          ? data.roadSegmentId.value
          : this.roadSegmentId,
      coveredLengthM: data.coveredLengthM.present
          ? data.coveredLengthM.value
          : this.coveredLengthM,
      coverageRatio: data.coverageRatio.present
          ? data.coverageRatio.value
          : this.coverageRatio,
      coveredIntervalsJson: data.coveredIntervalsJson.present
          ? data.coveredIntervalsJson.value
          : this.coveredIntervalsJson,
      firstCoveredAt: data.firstCoveredAt.present
          ? data.firstCoveredAt.value
          : this.firstCoveredAt,
      lastCoveredAt: data.lastCoveredAt.present
          ? data.lastCoveredAt.value
          : this.lastCoveredAt,
      sampleCountUsed: data.sampleCountUsed.present
          ? data.sampleCountUsed.value
          : this.sampleCountUsed,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserRoadSegmentProgressData(')
          ..write('userId: $userId, ')
          ..write('roadSegmentId: $roadSegmentId, ')
          ..write('coveredLengthM: $coveredLengthM, ')
          ..write('coverageRatio: $coverageRatio, ')
          ..write('coveredIntervalsJson: $coveredIntervalsJson, ')
          ..write('firstCoveredAt: $firstCoveredAt, ')
          ..write('lastCoveredAt: $lastCoveredAt, ')
          ..write('sampleCountUsed: $sampleCountUsed, ')
          ..write('sourceType: $sourceType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    roadSegmentId,
    coveredLengthM,
    coverageRatio,
    coveredIntervalsJson,
    firstCoveredAt,
    lastCoveredAt,
    sampleCountUsed,
    sourceType,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRoadSegmentProgressData &&
          other.userId == this.userId &&
          other.roadSegmentId == this.roadSegmentId &&
          other.coveredLengthM == this.coveredLengthM &&
          other.coverageRatio == this.coverageRatio &&
          other.coveredIntervalsJson == this.coveredIntervalsJson &&
          other.firstCoveredAt == this.firstCoveredAt &&
          other.lastCoveredAt == this.lastCoveredAt &&
          other.sampleCountUsed == this.sampleCountUsed &&
          other.sourceType == this.sourceType);
}

class UserRoadSegmentProgressCompanion
    extends UpdateCompanion<UserRoadSegmentProgressData> {
  final Value<String> userId;
  final Value<String> roadSegmentId;
  final Value<double> coveredLengthM;
  final Value<double> coverageRatio;
  final Value<String> coveredIntervalsJson;
  final Value<int?> firstCoveredAt;
  final Value<int?> lastCoveredAt;
  final Value<int?> sampleCountUsed;
  final Value<String?> sourceType;
  final Value<int> rowid;
  const UserRoadSegmentProgressCompanion({
    this.userId = const Value.absent(),
    this.roadSegmentId = const Value.absent(),
    this.coveredLengthM = const Value.absent(),
    this.coverageRatio = const Value.absent(),
    this.coveredIntervalsJson = const Value.absent(),
    this.firstCoveredAt = const Value.absent(),
    this.lastCoveredAt = const Value.absent(),
    this.sampleCountUsed = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserRoadSegmentProgressCompanion.insert({
    required String userId,
    required String roadSegmentId,
    this.coveredLengthM = const Value.absent(),
    this.coverageRatio = const Value.absent(),
    this.coveredIntervalsJson = const Value.absent(),
    this.firstCoveredAt = const Value.absent(),
    this.lastCoveredAt = const Value.absent(),
    this.sampleCountUsed = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       roadSegmentId = Value(roadSegmentId);
  static Insertable<UserRoadSegmentProgressData> custom({
    Expression<String>? userId,
    Expression<String>? roadSegmentId,
    Expression<double>? coveredLengthM,
    Expression<double>? coverageRatio,
    Expression<String>? coveredIntervalsJson,
    Expression<int>? firstCoveredAt,
    Expression<int>? lastCoveredAt,
    Expression<int>? sampleCountUsed,
    Expression<String>? sourceType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (roadSegmentId != null) 'road_segment_id': roadSegmentId,
      if (coveredLengthM != null) 'covered_length_m': coveredLengthM,
      if (coverageRatio != null) 'coverage_ratio': coverageRatio,
      if (coveredIntervalsJson != null)
        'covered_intervals_json': coveredIntervalsJson,
      if (firstCoveredAt != null) 'first_covered_at': firstCoveredAt,
      if (lastCoveredAt != null) 'last_covered_at': lastCoveredAt,
      if (sampleCountUsed != null) 'sample_count_used': sampleCountUsed,
      if (sourceType != null) 'source_type': sourceType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserRoadSegmentProgressCompanion copyWith({
    Value<String>? userId,
    Value<String>? roadSegmentId,
    Value<double>? coveredLengthM,
    Value<double>? coverageRatio,
    Value<String>? coveredIntervalsJson,
    Value<int?>? firstCoveredAt,
    Value<int?>? lastCoveredAt,
    Value<int?>? sampleCountUsed,
    Value<String?>? sourceType,
    Value<int>? rowid,
  }) {
    return UserRoadSegmentProgressCompanion(
      userId: userId ?? this.userId,
      roadSegmentId: roadSegmentId ?? this.roadSegmentId,
      coveredLengthM: coveredLengthM ?? this.coveredLengthM,
      coverageRatio: coverageRatio ?? this.coverageRatio,
      coveredIntervalsJson: coveredIntervalsJson ?? this.coveredIntervalsJson,
      firstCoveredAt: firstCoveredAt ?? this.firstCoveredAt,
      lastCoveredAt: lastCoveredAt ?? this.lastCoveredAt,
      sampleCountUsed: sampleCountUsed ?? this.sampleCountUsed,
      sourceType: sourceType ?? this.sourceType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (roadSegmentId.present) {
      map['road_segment_id'] = Variable<String>(roadSegmentId.value);
    }
    if (coveredLengthM.present) {
      map['covered_length_m'] = Variable<double>(coveredLengthM.value);
    }
    if (coverageRatio.present) {
      map['coverage_ratio'] = Variable<double>(coverageRatio.value);
    }
    if (coveredIntervalsJson.present) {
      map['covered_intervals_json'] = Variable<String>(
        coveredIntervalsJson.value,
      );
    }
    if (firstCoveredAt.present) {
      map['first_covered_at'] = Variable<int>(firstCoveredAt.value);
    }
    if (lastCoveredAt.present) {
      map['last_covered_at'] = Variable<int>(lastCoveredAt.value);
    }
    if (sampleCountUsed.present) {
      map['sample_count_used'] = Variable<int>(sampleCountUsed.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserRoadSegmentProgressCompanion(')
          ..write('userId: $userId, ')
          ..write('roadSegmentId: $roadSegmentId, ')
          ..write('coveredLengthM: $coveredLengthM, ')
          ..write('coverageRatio: $coverageRatio, ')
          ..write('coveredIntervalsJson: $coveredIntervalsJson, ')
          ..write('firstCoveredAt: $firstCoveredAt, ')
          ..write('lastCoveredAt: $lastCoveredAt, ')
          ..write('sampleCountUsed: $sampleCountUsed, ')
          ..write('sourceType: $sourceType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserEntityProgressCacheTable extends UserEntityProgressCache
    with TableInfo<$UserEntityProgressCacheTable, UserEntityProgressCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserEntityProgressCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exploredPeaksCountMeta =
      const VerificationMeta('exploredPeaksCount');
  @override
  late final GeneratedColumn<int> exploredPeaksCount = GeneratedColumn<int>(
    'explored_peaks_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _exploredHutsCountMeta = const VerificationMeta(
    'exploredHutsCount',
  );
  @override
  late final GeneratedColumn<int> exploredHutsCount = GeneratedColumn<int>(
    'explored_huts_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _exploredMonumentsCountMeta =
      const VerificationMeta('exploredMonumentsCount');
  @override
  late final GeneratedColumn<int> exploredMonumentsCount = GeneratedColumn<int>(
    'explored_monuments_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _exploredDrivableLengthMMeta =
      const VerificationMeta('exploredDrivableLengthM');
  @override
  late final GeneratedColumn<double> exploredDrivableLengthM =
      GeneratedColumn<double>(
        'explored_drivable_length_m',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _exploredWalkableLengthMMeta =
      const VerificationMeta('exploredWalkableLengthM');
  @override
  late final GeneratedColumn<double> exploredWalkableLengthM =
      GeneratedColumn<double>(
        'explored_walkable_length_m',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _exploredCyclewayLengthMMeta =
      const VerificationMeta('exploredCyclewayLengthM');
  @override
  late final GeneratedColumn<double> exploredCyclewayLengthM =
      GeneratedColumn<double>(
        'explored_cycleway_length_m',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    entityId,
    exploredPeaksCount,
    exploredHutsCount,
    exploredMonumentsCount,
    exploredDrivableLengthM,
    exploredWalkableLengthM,
    exploredCyclewayLengthM,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_entity_progress_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserEntityProgressCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('explored_peaks_count')) {
      context.handle(
        _exploredPeaksCountMeta,
        exploredPeaksCount.isAcceptableOrUnknown(
          data['explored_peaks_count']!,
          _exploredPeaksCountMeta,
        ),
      );
    }
    if (data.containsKey('explored_huts_count')) {
      context.handle(
        _exploredHutsCountMeta,
        exploredHutsCount.isAcceptableOrUnknown(
          data['explored_huts_count']!,
          _exploredHutsCountMeta,
        ),
      );
    }
    if (data.containsKey('explored_monuments_count')) {
      context.handle(
        _exploredMonumentsCountMeta,
        exploredMonumentsCount.isAcceptableOrUnknown(
          data['explored_monuments_count']!,
          _exploredMonumentsCountMeta,
        ),
      );
    }
    if (data.containsKey('explored_drivable_length_m')) {
      context.handle(
        _exploredDrivableLengthMMeta,
        exploredDrivableLengthM.isAcceptableOrUnknown(
          data['explored_drivable_length_m']!,
          _exploredDrivableLengthMMeta,
        ),
      );
    }
    if (data.containsKey('explored_walkable_length_m')) {
      context.handle(
        _exploredWalkableLengthMMeta,
        exploredWalkableLengthM.isAcceptableOrUnknown(
          data['explored_walkable_length_m']!,
          _exploredWalkableLengthMMeta,
        ),
      );
    }
    if (data.containsKey('explored_cycleway_length_m')) {
      context.handle(
        _exploredCyclewayLengthMMeta,
        exploredCyclewayLengthM.isAcceptableOrUnknown(
          data['explored_cycleway_length_m']!,
          _exploredCyclewayLengthMMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, entityId};
  @override
  UserEntityProgressCacheData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserEntityProgressCacheData(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      exploredPeaksCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}explored_peaks_count'],
      )!,
      exploredHutsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}explored_huts_count'],
      )!,
      exploredMonumentsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}explored_monuments_count'],
      )!,
      exploredDrivableLengthM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}explored_drivable_length_m'],
      )!,
      exploredWalkableLengthM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}explored_walkable_length_m'],
      )!,
      exploredCyclewayLengthM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}explored_cycleway_length_m'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserEntityProgressCacheTable createAlias(String alias) {
    return $UserEntityProgressCacheTable(attachedDatabase, alias);
  }
}

class UserEntityProgressCacheData extends DataClass
    implements Insertable<UserEntityProgressCacheData> {
  final String userId;
  final String entityId;
  final int exploredPeaksCount;
  final int exploredHutsCount;
  final int exploredMonumentsCount;
  final double exploredDrivableLengthM;
  final double exploredWalkableLengthM;
  final double exploredCyclewayLengthM;
  final int updatedAt;
  const UserEntityProgressCacheData({
    required this.userId,
    required this.entityId,
    required this.exploredPeaksCount,
    required this.exploredHutsCount,
    required this.exploredMonumentsCount,
    required this.exploredDrivableLengthM,
    required this.exploredWalkableLengthM,
    required this.exploredCyclewayLengthM,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['entity_id'] = Variable<String>(entityId);
    map['explored_peaks_count'] = Variable<int>(exploredPeaksCount);
    map['explored_huts_count'] = Variable<int>(exploredHutsCount);
    map['explored_monuments_count'] = Variable<int>(exploredMonumentsCount);
    map['explored_drivable_length_m'] = Variable<double>(
      exploredDrivableLengthM,
    );
    map['explored_walkable_length_m'] = Variable<double>(
      exploredWalkableLengthM,
    );
    map['explored_cycleway_length_m'] = Variable<double>(
      exploredCyclewayLengthM,
    );
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  UserEntityProgressCacheCompanion toCompanion(bool nullToAbsent) {
    return UserEntityProgressCacheCompanion(
      userId: Value(userId),
      entityId: Value(entityId),
      exploredPeaksCount: Value(exploredPeaksCount),
      exploredHutsCount: Value(exploredHutsCount),
      exploredMonumentsCount: Value(exploredMonumentsCount),
      exploredDrivableLengthM: Value(exploredDrivableLengthM),
      exploredWalkableLengthM: Value(exploredWalkableLengthM),
      exploredCyclewayLengthM: Value(exploredCyclewayLengthM),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserEntityProgressCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserEntityProgressCacheData(
      userId: serializer.fromJson<String>(json['userId']),
      entityId: serializer.fromJson<String>(json['entityId']),
      exploredPeaksCount: serializer.fromJson<int>(json['exploredPeaksCount']),
      exploredHutsCount: serializer.fromJson<int>(json['exploredHutsCount']),
      exploredMonumentsCount: serializer.fromJson<int>(
        json['exploredMonumentsCount'],
      ),
      exploredDrivableLengthM: serializer.fromJson<double>(
        json['exploredDrivableLengthM'],
      ),
      exploredWalkableLengthM: serializer.fromJson<double>(
        json['exploredWalkableLengthM'],
      ),
      exploredCyclewayLengthM: serializer.fromJson<double>(
        json['exploredCyclewayLengthM'],
      ),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'entityId': serializer.toJson<String>(entityId),
      'exploredPeaksCount': serializer.toJson<int>(exploredPeaksCount),
      'exploredHutsCount': serializer.toJson<int>(exploredHutsCount),
      'exploredMonumentsCount': serializer.toJson<int>(exploredMonumentsCount),
      'exploredDrivableLengthM': serializer.toJson<double>(
        exploredDrivableLengthM,
      ),
      'exploredWalkableLengthM': serializer.toJson<double>(
        exploredWalkableLengthM,
      ),
      'exploredCyclewayLengthM': serializer.toJson<double>(
        exploredCyclewayLengthM,
      ),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  UserEntityProgressCacheData copyWith({
    String? userId,
    String? entityId,
    int? exploredPeaksCount,
    int? exploredHutsCount,
    int? exploredMonumentsCount,
    double? exploredDrivableLengthM,
    double? exploredWalkableLengthM,
    double? exploredCyclewayLengthM,
    int? updatedAt,
  }) => UserEntityProgressCacheData(
    userId: userId ?? this.userId,
    entityId: entityId ?? this.entityId,
    exploredPeaksCount: exploredPeaksCount ?? this.exploredPeaksCount,
    exploredHutsCount: exploredHutsCount ?? this.exploredHutsCount,
    exploredMonumentsCount:
        exploredMonumentsCount ?? this.exploredMonumentsCount,
    exploredDrivableLengthM:
        exploredDrivableLengthM ?? this.exploredDrivableLengthM,
    exploredWalkableLengthM:
        exploredWalkableLengthM ?? this.exploredWalkableLengthM,
    exploredCyclewayLengthM:
        exploredCyclewayLengthM ?? this.exploredCyclewayLengthM,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserEntityProgressCacheData copyWithCompanion(
    UserEntityProgressCacheCompanion data,
  ) {
    return UserEntityProgressCacheData(
      userId: data.userId.present ? data.userId.value : this.userId,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      exploredPeaksCount: data.exploredPeaksCount.present
          ? data.exploredPeaksCount.value
          : this.exploredPeaksCount,
      exploredHutsCount: data.exploredHutsCount.present
          ? data.exploredHutsCount.value
          : this.exploredHutsCount,
      exploredMonumentsCount: data.exploredMonumentsCount.present
          ? data.exploredMonumentsCount.value
          : this.exploredMonumentsCount,
      exploredDrivableLengthM: data.exploredDrivableLengthM.present
          ? data.exploredDrivableLengthM.value
          : this.exploredDrivableLengthM,
      exploredWalkableLengthM: data.exploredWalkableLengthM.present
          ? data.exploredWalkableLengthM.value
          : this.exploredWalkableLengthM,
      exploredCyclewayLengthM: data.exploredCyclewayLengthM.present
          ? data.exploredCyclewayLengthM.value
          : this.exploredCyclewayLengthM,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserEntityProgressCacheData(')
          ..write('userId: $userId, ')
          ..write('entityId: $entityId, ')
          ..write('exploredPeaksCount: $exploredPeaksCount, ')
          ..write('exploredHutsCount: $exploredHutsCount, ')
          ..write('exploredMonumentsCount: $exploredMonumentsCount, ')
          ..write('exploredDrivableLengthM: $exploredDrivableLengthM, ')
          ..write('exploredWalkableLengthM: $exploredWalkableLengthM, ')
          ..write('exploredCyclewayLengthM: $exploredCyclewayLengthM, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    entityId,
    exploredPeaksCount,
    exploredHutsCount,
    exploredMonumentsCount,
    exploredDrivableLengthM,
    exploredWalkableLengthM,
    exploredCyclewayLengthM,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserEntityProgressCacheData &&
          other.userId == this.userId &&
          other.entityId == this.entityId &&
          other.exploredPeaksCount == this.exploredPeaksCount &&
          other.exploredHutsCount == this.exploredHutsCount &&
          other.exploredMonumentsCount == this.exploredMonumentsCount &&
          other.exploredDrivableLengthM == this.exploredDrivableLengthM &&
          other.exploredWalkableLengthM == this.exploredWalkableLengthM &&
          other.exploredCyclewayLengthM == this.exploredCyclewayLengthM &&
          other.updatedAt == this.updatedAt);
}

class UserEntityProgressCacheCompanion
    extends UpdateCompanion<UserEntityProgressCacheData> {
  final Value<String> userId;
  final Value<String> entityId;
  final Value<int> exploredPeaksCount;
  final Value<int> exploredHutsCount;
  final Value<int> exploredMonumentsCount;
  final Value<double> exploredDrivableLengthM;
  final Value<double> exploredWalkableLengthM;
  final Value<double> exploredCyclewayLengthM;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const UserEntityProgressCacheCompanion({
    this.userId = const Value.absent(),
    this.entityId = const Value.absent(),
    this.exploredPeaksCount = const Value.absent(),
    this.exploredHutsCount = const Value.absent(),
    this.exploredMonumentsCount = const Value.absent(),
    this.exploredDrivableLengthM = const Value.absent(),
    this.exploredWalkableLengthM = const Value.absent(),
    this.exploredCyclewayLengthM = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserEntityProgressCacheCompanion.insert({
    required String userId,
    required String entityId,
    this.exploredPeaksCount = const Value.absent(),
    this.exploredHutsCount = const Value.absent(),
    this.exploredMonumentsCount = const Value.absent(),
    this.exploredDrivableLengthM = const Value.absent(),
    this.exploredWalkableLengthM = const Value.absent(),
    this.exploredCyclewayLengthM = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       entityId = Value(entityId),
       updatedAt = Value(updatedAt);
  static Insertable<UserEntityProgressCacheData> custom({
    Expression<String>? userId,
    Expression<String>? entityId,
    Expression<int>? exploredPeaksCount,
    Expression<int>? exploredHutsCount,
    Expression<int>? exploredMonumentsCount,
    Expression<double>? exploredDrivableLengthM,
    Expression<double>? exploredWalkableLengthM,
    Expression<double>? exploredCyclewayLengthM,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (entityId != null) 'entity_id': entityId,
      if (exploredPeaksCount != null)
        'explored_peaks_count': exploredPeaksCount,
      if (exploredHutsCount != null) 'explored_huts_count': exploredHutsCount,
      if (exploredMonumentsCount != null)
        'explored_monuments_count': exploredMonumentsCount,
      if (exploredDrivableLengthM != null)
        'explored_drivable_length_m': exploredDrivableLengthM,
      if (exploredWalkableLengthM != null)
        'explored_walkable_length_m': exploredWalkableLengthM,
      if (exploredCyclewayLengthM != null)
        'explored_cycleway_length_m': exploredCyclewayLengthM,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserEntityProgressCacheCompanion copyWith({
    Value<String>? userId,
    Value<String>? entityId,
    Value<int>? exploredPeaksCount,
    Value<int>? exploredHutsCount,
    Value<int>? exploredMonumentsCount,
    Value<double>? exploredDrivableLengthM,
    Value<double>? exploredWalkableLengthM,
    Value<double>? exploredCyclewayLengthM,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserEntityProgressCacheCompanion(
      userId: userId ?? this.userId,
      entityId: entityId ?? this.entityId,
      exploredPeaksCount: exploredPeaksCount ?? this.exploredPeaksCount,
      exploredHutsCount: exploredHutsCount ?? this.exploredHutsCount,
      exploredMonumentsCount:
          exploredMonumentsCount ?? this.exploredMonumentsCount,
      exploredDrivableLengthM:
          exploredDrivableLengthM ?? this.exploredDrivableLengthM,
      exploredWalkableLengthM:
          exploredWalkableLengthM ?? this.exploredWalkableLengthM,
      exploredCyclewayLengthM:
          exploredCyclewayLengthM ?? this.exploredCyclewayLengthM,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (exploredPeaksCount.present) {
      map['explored_peaks_count'] = Variable<int>(exploredPeaksCount.value);
    }
    if (exploredHutsCount.present) {
      map['explored_huts_count'] = Variable<int>(exploredHutsCount.value);
    }
    if (exploredMonumentsCount.present) {
      map['explored_monuments_count'] = Variable<int>(
        exploredMonumentsCount.value,
      );
    }
    if (exploredDrivableLengthM.present) {
      map['explored_drivable_length_m'] = Variable<double>(
        exploredDrivableLengthM.value,
      );
    }
    if (exploredWalkableLengthM.present) {
      map['explored_walkable_length_m'] = Variable<double>(
        exploredWalkableLengthM.value,
      );
    }
    if (exploredCyclewayLengthM.present) {
      map['explored_cycleway_length_m'] = Variable<double>(
        exploredCyclewayLengthM.value,
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserEntityProgressCacheCompanion(')
          ..write('userId: $userId, ')
          ..write('entityId: $entityId, ')
          ..write('exploredPeaksCount: $exploredPeaksCount, ')
          ..write('exploredHutsCount: $exploredHutsCount, ')
          ..write('exploredMonumentsCount: $exploredMonumentsCount, ')
          ..write('exploredDrivableLengthM: $exploredDrivableLengthM, ')
          ..write('exploredWalkableLengthM: $exploredWalkableLengthM, ')
          ..write('exploredCyclewayLengthM: $exploredCyclewayLengthM, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CountryPackStatusTable extends CountryPackStatus
    with TableInfo<$CountryPackStatusTable, CountryPackStatusData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CountryPackStatusTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _countrySlugMeta = const VerificationMeta(
    'countrySlug',
  );
  @override
  late final GeneratedColumn<String> countrySlug = GeneratedColumn<String>(
    'country_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _downloadedMeta = const VerificationMeta(
    'downloaded',
  );
  @override
  late final GeneratedColumn<bool> downloaded = GeneratedColumn<bool>(
    'downloaded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("downloaded" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _importedMeta = const VerificationMeta(
    'imported',
  );
  @override
  late final GeneratedColumn<bool> imported = GeneratedColumn<bool>(
    'imported',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("imported" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _manifestJsonMeta = const VerificationMeta(
    'manifestJson',
  );
  @override
  late final GeneratedColumn<String> manifestJson = GeneratedColumn<String>(
    'manifest_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<int> importedAt = GeneratedColumn<int>(
    'imported_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    countrySlug,
    downloaded,
    imported,
    manifestJson,
    importedAt,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'country_pack_status';
  @override
  VerificationContext validateIntegrity(
    Insertable<CountryPackStatusData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('country_slug')) {
      context.handle(
        _countrySlugMeta,
        countrySlug.isAcceptableOrUnknown(
          data['country_slug']!,
          _countrySlugMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_countrySlugMeta);
    }
    if (data.containsKey('downloaded')) {
      context.handle(
        _downloadedMeta,
        downloaded.isAcceptableOrUnknown(data['downloaded']!, _downloadedMeta),
      );
    }
    if (data.containsKey('imported')) {
      context.handle(
        _importedMeta,
        imported.isAcceptableOrUnknown(data['imported']!, _importedMeta),
      );
    }
    if (data.containsKey('manifest_json')) {
      context.handle(
        _manifestJsonMeta,
        manifestJson.isAcceptableOrUnknown(
          data['manifest_json']!,
          _manifestJsonMeta,
        ),
      );
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {countrySlug};
  @override
  CountryPackStatusData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CountryPackStatusData(
      countrySlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country_slug'],
      )!,
      downloaded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}downloaded'],
      )!,
      imported: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}imported'],
      )!,
      manifestJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manifest_json'],
      ),
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}imported_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      ),
    );
  }

  @override
  $CountryPackStatusTable createAlias(String alias) {
    return $CountryPackStatusTable(attachedDatabase, alias);
  }
}

class CountryPackStatusData extends DataClass
    implements Insertable<CountryPackStatusData> {
  final String countrySlug;
  final bool downloaded;
  final bool imported;
  final String? manifestJson;
  final int? importedAt;
  final String? version;
  const CountryPackStatusData({
    required this.countrySlug,
    required this.downloaded,
    required this.imported,
    this.manifestJson,
    this.importedAt,
    this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['country_slug'] = Variable<String>(countrySlug);
    map['downloaded'] = Variable<bool>(downloaded);
    map['imported'] = Variable<bool>(imported);
    if (!nullToAbsent || manifestJson != null) {
      map['manifest_json'] = Variable<String>(manifestJson);
    }
    if (!nullToAbsent || importedAt != null) {
      map['imported_at'] = Variable<int>(importedAt);
    }
    if (!nullToAbsent || version != null) {
      map['version'] = Variable<String>(version);
    }
    return map;
  }

  CountryPackStatusCompanion toCompanion(bool nullToAbsent) {
    return CountryPackStatusCompanion(
      countrySlug: Value(countrySlug),
      downloaded: Value(downloaded),
      imported: Value(imported),
      manifestJson: manifestJson == null && nullToAbsent
          ? const Value.absent()
          : Value(manifestJson),
      importedAt: importedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(importedAt),
      version: version == null && nullToAbsent
          ? const Value.absent()
          : Value(version),
    );
  }

  factory CountryPackStatusData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CountryPackStatusData(
      countrySlug: serializer.fromJson<String>(json['countrySlug']),
      downloaded: serializer.fromJson<bool>(json['downloaded']),
      imported: serializer.fromJson<bool>(json['imported']),
      manifestJson: serializer.fromJson<String?>(json['manifestJson']),
      importedAt: serializer.fromJson<int?>(json['importedAt']),
      version: serializer.fromJson<String?>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'countrySlug': serializer.toJson<String>(countrySlug),
      'downloaded': serializer.toJson<bool>(downloaded),
      'imported': serializer.toJson<bool>(imported),
      'manifestJson': serializer.toJson<String?>(manifestJson),
      'importedAt': serializer.toJson<int?>(importedAt),
      'version': serializer.toJson<String?>(version),
    };
  }

  CountryPackStatusData copyWith({
    String? countrySlug,
    bool? downloaded,
    bool? imported,
    Value<String?> manifestJson = const Value.absent(),
    Value<int?> importedAt = const Value.absent(),
    Value<String?> version = const Value.absent(),
  }) => CountryPackStatusData(
    countrySlug: countrySlug ?? this.countrySlug,
    downloaded: downloaded ?? this.downloaded,
    imported: imported ?? this.imported,
    manifestJson: manifestJson.present ? manifestJson.value : this.manifestJson,
    importedAt: importedAt.present ? importedAt.value : this.importedAt,
    version: version.present ? version.value : this.version,
  );
  CountryPackStatusData copyWithCompanion(CountryPackStatusCompanion data) {
    return CountryPackStatusData(
      countrySlug: data.countrySlug.present
          ? data.countrySlug.value
          : this.countrySlug,
      downloaded: data.downloaded.present
          ? data.downloaded.value
          : this.downloaded,
      imported: data.imported.present ? data.imported.value : this.imported,
      manifestJson: data.manifestJson.present
          ? data.manifestJson.value
          : this.manifestJson,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CountryPackStatusData(')
          ..write('countrySlug: $countrySlug, ')
          ..write('downloaded: $downloaded, ')
          ..write('imported: $imported, ')
          ..write('manifestJson: $manifestJson, ')
          ..write('importedAt: $importedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    countrySlug,
    downloaded,
    imported,
    manifestJson,
    importedAt,
    version,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CountryPackStatusData &&
          other.countrySlug == this.countrySlug &&
          other.downloaded == this.downloaded &&
          other.imported == this.imported &&
          other.manifestJson == this.manifestJson &&
          other.importedAt == this.importedAt &&
          other.version == this.version);
}

class CountryPackStatusCompanion
    extends UpdateCompanion<CountryPackStatusData> {
  final Value<String> countrySlug;
  final Value<bool> downloaded;
  final Value<bool> imported;
  final Value<String?> manifestJson;
  final Value<int?> importedAt;
  final Value<String?> version;
  final Value<int> rowid;
  const CountryPackStatusCompanion({
    this.countrySlug = const Value.absent(),
    this.downloaded = const Value.absent(),
    this.imported = const Value.absent(),
    this.manifestJson = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CountryPackStatusCompanion.insert({
    required String countrySlug,
    this.downloaded = const Value.absent(),
    this.imported = const Value.absent(),
    this.manifestJson = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : countrySlug = Value(countrySlug);
  static Insertable<CountryPackStatusData> custom({
    Expression<String>? countrySlug,
    Expression<bool>? downloaded,
    Expression<bool>? imported,
    Expression<String>? manifestJson,
    Expression<int>? importedAt,
    Expression<String>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (countrySlug != null) 'country_slug': countrySlug,
      if (downloaded != null) 'downloaded': downloaded,
      if (imported != null) 'imported': imported,
      if (manifestJson != null) 'manifest_json': manifestJson,
      if (importedAt != null) 'imported_at': importedAt,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CountryPackStatusCompanion copyWith({
    Value<String>? countrySlug,
    Value<bool>? downloaded,
    Value<bool>? imported,
    Value<String?>? manifestJson,
    Value<int?>? importedAt,
    Value<String?>? version,
    Value<int>? rowid,
  }) {
    return CountryPackStatusCompanion(
      countrySlug: countrySlug ?? this.countrySlug,
      downloaded: downloaded ?? this.downloaded,
      imported: imported ?? this.imported,
      manifestJson: manifestJson ?? this.manifestJson,
      importedAt: importedAt ?? this.importedAt,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (countrySlug.present) {
      map['country_slug'] = Variable<String>(countrySlug.value);
    }
    if (downloaded.present) {
      map['downloaded'] = Variable<bool>(downloaded.value);
    }
    if (imported.present) {
      map['imported'] = Variable<bool>(imported.value);
    }
    if (manifestJson.present) {
      map['manifest_json'] = Variable<String>(manifestJson.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<int>(importedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CountryPackStatusCompanion(')
          ..write('countrySlug: $countrySlug, ')
          ..write('downloaded: $downloaded, ')
          ..write('imported: $imported, ')
          ..write('manifestJson: $manifestJson, ')
          ..write('importedAt: $importedAt, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ExplorationDatabase extends GeneratedDatabase {
  _$ExplorationDatabase(QueryExecutor e) : super(e);
  $ExplorationDatabaseManager get managers => $ExplorationDatabaseManager(this);
  late final $StaticEntitiesTable staticEntities = $StaticEntitiesTable(this);
  late final $StaticObjectsTable staticObjects = $StaticObjectsTable(this);
  late final $StaticEntityTotalsTable staticEntityTotals =
      $StaticEntityTotalsTable(this);
  late final $SelectedEntityStateTable selectedEntityState =
      $SelectedEntityStateTable(this);
  late final $UserObjectProgressTable userObjectProgress =
      $UserObjectProgressTable(this);
  late final $UserRoadSegmentProgressTable userRoadSegmentProgress =
      $UserRoadSegmentProgressTable(this);
  late final $UserEntityProgressCacheTable userEntityProgressCache =
      $UserEntityProgressCacheTable(this);
  late final $CountryPackStatusTable countryPackStatus =
      $CountryPackStatusTable(this);
  late final Index idxStaticEntitiesType = Index(
    'idx_static_entities_type',
    'CREATE INDEX idx_static_entities_type ON static_entities (type)',
  );
  late final Index idxStaticEntitiesCountryId = Index(
    'idx_static_entities_country_id',
    'CREATE INDEX idx_static_entities_country_id ON static_entities (country_id)',
  );
  late final Index idxStaticEntitiesRegionId = Index(
    'idx_static_entities_region_id',
    'CREATE INDEX idx_static_entities_region_id ON static_entities (region_id)',
  );
  late final Index idxStaticEntitiesCityId = Index(
    'idx_static_entities_city_id',
    'CREATE INDEX idx_static_entities_city_id ON static_entities (city_id)',
  );
  late final Index idxStaticEntitiesName = Index(
    'idx_static_entities_name',
    'CREATE INDEX idx_static_entities_name ON static_entities (name)',
  );
  late final Index idxStaticObjectsCategory = Index(
    'idx_static_objects_category',
    'CREATE INDEX idx_static_objects_category ON static_objects (category)',
  );
  late final Index idxStaticObjectsCountryId = Index(
    'idx_static_objects_country_id',
    'CREATE INDEX idx_static_objects_country_id ON static_objects (country_id)',
  );
  late final Index idxStaticObjectsRegionId = Index(
    'idx_static_objects_region_id',
    'CREATE INDEX idx_static_objects_region_id ON static_objects (region_id)',
  );
  late final Index idxStaticObjectsCityId = Index(
    'idx_static_objects_city_id',
    'CREATE INDEX idx_static_objects_city_id ON static_objects (city_id)',
  );
  late final Index idxStaticObjectsCityCenterId = Index(
    'idx_static_objects_city_center_id',
    'CREATE INDEX idx_static_objects_city_center_id ON static_objects (city_center_id)',
  );
  late final ExplorationDao explorationDao = ExplorationDao(
    this as ExplorationDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    staticEntities,
    staticObjects,
    staticEntityTotals,
    selectedEntityState,
    userObjectProgress,
    userRoadSegmentProgress,
    userEntityProgressCache,
    countryPackStatus,
    idxStaticEntitiesType,
    idxStaticEntitiesCountryId,
    idxStaticEntitiesRegionId,
    idxStaticEntitiesCityId,
    idxStaticEntitiesName,
    idxStaticObjectsCategory,
    idxStaticObjectsCountryId,
    idxStaticObjectsRegionId,
    idxStaticObjectsCityId,
    idxStaticObjectsCityCenterId,
  ];
}

typedef $$StaticEntitiesTableCreateCompanionBuilder =
    StaticEntitiesCompanion Function({
      required String entityId,
      required String type,
      Value<String?> osmType,
      Value<int?> osmId,
      Value<String?> areaId,
      required String name,
      Value<int?> adminLevel,
      required String bboxJson,
      required String centroidJson,
      Value<String?> countryId,
      Value<String?> regionId,
      Value<String?> cityId,
      required String geometryGeojson,
      required String countrySlug,
      Value<String?> packVersion,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$StaticEntitiesTableUpdateCompanionBuilder =
    StaticEntitiesCompanion Function({
      Value<String> entityId,
      Value<String> type,
      Value<String?> osmType,
      Value<int?> osmId,
      Value<String?> areaId,
      Value<String> name,
      Value<int?> adminLevel,
      Value<String> bboxJson,
      Value<String> centroidJson,
      Value<String?> countryId,
      Value<String?> regionId,
      Value<String?> cityId,
      Value<String> geometryGeojson,
      Value<String> countrySlug,
      Value<String?> packVersion,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$StaticEntitiesTableFilterComposer
    extends Composer<_$ExplorationDatabase, $StaticEntitiesTable> {
  $$StaticEntitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get osmType => $composableBuilder(
    column: $table.osmType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get osmId => $composableBuilder(
    column: $table.osmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get areaId => $composableBuilder(
    column: $table.areaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get adminLevel => $composableBuilder(
    column: $table.adminLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bboxJson => $composableBuilder(
    column: $table.bboxJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get centroidJson => $composableBuilder(
    column: $table.centroidJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get countryId => $composableBuilder(
    column: $table.countryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get regionId => $composableBuilder(
    column: $table.regionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cityId => $composableBuilder(
    column: $table.cityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get geometryGeojson => $composableBuilder(
    column: $table.geometryGeojson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get countrySlug => $composableBuilder(
    column: $table.countrySlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packVersion => $composableBuilder(
    column: $table.packVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StaticEntitiesTableOrderingComposer
    extends Composer<_$ExplorationDatabase, $StaticEntitiesTable> {
  $$StaticEntitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get osmType => $composableBuilder(
    column: $table.osmType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get osmId => $composableBuilder(
    column: $table.osmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get areaId => $composableBuilder(
    column: $table.areaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get adminLevel => $composableBuilder(
    column: $table.adminLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bboxJson => $composableBuilder(
    column: $table.bboxJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get centroidJson => $composableBuilder(
    column: $table.centroidJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get countryId => $composableBuilder(
    column: $table.countryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get regionId => $composableBuilder(
    column: $table.regionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cityId => $composableBuilder(
    column: $table.cityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get geometryGeojson => $composableBuilder(
    column: $table.geometryGeojson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get countrySlug => $composableBuilder(
    column: $table.countrySlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packVersion => $composableBuilder(
    column: $table.packVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StaticEntitiesTableAnnotationComposer
    extends Composer<_$ExplorationDatabase, $StaticEntitiesTable> {
  $$StaticEntitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get osmType =>
      $composableBuilder(column: $table.osmType, builder: (column) => column);

  GeneratedColumn<int> get osmId =>
      $composableBuilder(column: $table.osmId, builder: (column) => column);

  GeneratedColumn<String> get areaId =>
      $composableBuilder(column: $table.areaId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get adminLevel => $composableBuilder(
    column: $table.adminLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bboxJson =>
      $composableBuilder(column: $table.bboxJson, builder: (column) => column);

  GeneratedColumn<String> get centroidJson => $composableBuilder(
    column: $table.centroidJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get countryId =>
      $composableBuilder(column: $table.countryId, builder: (column) => column);

  GeneratedColumn<String> get regionId =>
      $composableBuilder(column: $table.regionId, builder: (column) => column);

  GeneratedColumn<String> get cityId =>
      $composableBuilder(column: $table.cityId, builder: (column) => column);

  GeneratedColumn<String> get geometryGeojson => $composableBuilder(
    column: $table.geometryGeojson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get countrySlug => $composableBuilder(
    column: $table.countrySlug,
    builder: (column) => column,
  );

  GeneratedColumn<String> get packVersion => $composableBuilder(
    column: $table.packVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$StaticEntitiesTableTableManager
    extends
        RootTableManager<
          _$ExplorationDatabase,
          $StaticEntitiesTable,
          StaticEntity,
          $$StaticEntitiesTableFilterComposer,
          $$StaticEntitiesTableOrderingComposer,
          $$StaticEntitiesTableAnnotationComposer,
          $$StaticEntitiesTableCreateCompanionBuilder,
          $$StaticEntitiesTableUpdateCompanionBuilder,
          (
            StaticEntity,
            BaseReferences<
              _$ExplorationDatabase,
              $StaticEntitiesTable,
              StaticEntity
            >,
          ),
          StaticEntity,
          PrefetchHooks Function()
        > {
  $$StaticEntitiesTableTableManager(
    _$ExplorationDatabase db,
    $StaticEntitiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StaticEntitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StaticEntitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StaticEntitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entityId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> osmType = const Value.absent(),
                Value<int?> osmId = const Value.absent(),
                Value<String?> areaId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> adminLevel = const Value.absent(),
                Value<String> bboxJson = const Value.absent(),
                Value<String> centroidJson = const Value.absent(),
                Value<String?> countryId = const Value.absent(),
                Value<String?> regionId = const Value.absent(),
                Value<String?> cityId = const Value.absent(),
                Value<String> geometryGeojson = const Value.absent(),
                Value<String> countrySlug = const Value.absent(),
                Value<String?> packVersion = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StaticEntitiesCompanion(
                entityId: entityId,
                type: type,
                osmType: osmType,
                osmId: osmId,
                areaId: areaId,
                name: name,
                adminLevel: adminLevel,
                bboxJson: bboxJson,
                centroidJson: centroidJson,
                countryId: countryId,
                regionId: regionId,
                cityId: cityId,
                geometryGeojson: geometryGeojson,
                countrySlug: countrySlug,
                packVersion: packVersion,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entityId,
                required String type,
                Value<String?> osmType = const Value.absent(),
                Value<int?> osmId = const Value.absent(),
                Value<String?> areaId = const Value.absent(),
                required String name,
                Value<int?> adminLevel = const Value.absent(),
                required String bboxJson,
                required String centroidJson,
                Value<String?> countryId = const Value.absent(),
                Value<String?> regionId = const Value.absent(),
                Value<String?> cityId = const Value.absent(),
                required String geometryGeojson,
                required String countrySlug,
                Value<String?> packVersion = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => StaticEntitiesCompanion.insert(
                entityId: entityId,
                type: type,
                osmType: osmType,
                osmId: osmId,
                areaId: areaId,
                name: name,
                adminLevel: adminLevel,
                bboxJson: bboxJson,
                centroidJson: centroidJson,
                countryId: countryId,
                regionId: regionId,
                cityId: cityId,
                geometryGeojson: geometryGeojson,
                countrySlug: countrySlug,
                packVersion: packVersion,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StaticEntitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$ExplorationDatabase,
      $StaticEntitiesTable,
      StaticEntity,
      $$StaticEntitiesTableFilterComposer,
      $$StaticEntitiesTableOrderingComposer,
      $$StaticEntitiesTableAnnotationComposer,
      $$StaticEntitiesTableCreateCompanionBuilder,
      $$StaticEntitiesTableUpdateCompanionBuilder,
      (
        StaticEntity,
        BaseReferences<
          _$ExplorationDatabase,
          $StaticEntitiesTable,
          StaticEntity
        >,
      ),
      StaticEntity,
      PrefetchHooks Function()
    >;
typedef $$StaticObjectsTableCreateCompanionBuilder =
    StaticObjectsCompanion Function({
      required String objectId,
      required String category,
      Value<String?> subtype,
      Value<String?> name,
      required String geometryGeojson,
      Value<String?> countryId,
      Value<String?> regionId,
      Value<String?> cityId,
      Value<String?> cityCenterId,
      Value<bool?> drivable,
      Value<bool?> walkable,
      Value<bool?> cycleway,
      Value<double?> lengthM,
      required String countrySlug,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$StaticObjectsTableUpdateCompanionBuilder =
    StaticObjectsCompanion Function({
      Value<String> objectId,
      Value<String> category,
      Value<String?> subtype,
      Value<String?> name,
      Value<String> geometryGeojson,
      Value<String?> countryId,
      Value<String?> regionId,
      Value<String?> cityId,
      Value<String?> cityCenterId,
      Value<bool?> drivable,
      Value<bool?> walkable,
      Value<bool?> cycleway,
      Value<double?> lengthM,
      Value<String> countrySlug,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$StaticObjectsTableFilterComposer
    extends Composer<_$ExplorationDatabase, $StaticObjectsTable> {
  $$StaticObjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get objectId => $composableBuilder(
    column: $table.objectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtype => $composableBuilder(
    column: $table.subtype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get geometryGeojson => $composableBuilder(
    column: $table.geometryGeojson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get countryId => $composableBuilder(
    column: $table.countryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get regionId => $composableBuilder(
    column: $table.regionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cityId => $composableBuilder(
    column: $table.cityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cityCenterId => $composableBuilder(
    column: $table.cityCenterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get drivable => $composableBuilder(
    column: $table.drivable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get walkable => $composableBuilder(
    column: $table.walkable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get cycleway => $composableBuilder(
    column: $table.cycleway,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lengthM => $composableBuilder(
    column: $table.lengthM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get countrySlug => $composableBuilder(
    column: $table.countrySlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StaticObjectsTableOrderingComposer
    extends Composer<_$ExplorationDatabase, $StaticObjectsTable> {
  $$StaticObjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get objectId => $composableBuilder(
    column: $table.objectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtype => $composableBuilder(
    column: $table.subtype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get geometryGeojson => $composableBuilder(
    column: $table.geometryGeojson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get countryId => $composableBuilder(
    column: $table.countryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get regionId => $composableBuilder(
    column: $table.regionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cityId => $composableBuilder(
    column: $table.cityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cityCenterId => $composableBuilder(
    column: $table.cityCenterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get drivable => $composableBuilder(
    column: $table.drivable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get walkable => $composableBuilder(
    column: $table.walkable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get cycleway => $composableBuilder(
    column: $table.cycleway,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lengthM => $composableBuilder(
    column: $table.lengthM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get countrySlug => $composableBuilder(
    column: $table.countrySlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StaticObjectsTableAnnotationComposer
    extends Composer<_$ExplorationDatabase, $StaticObjectsTable> {
  $$StaticObjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get objectId =>
      $composableBuilder(column: $table.objectId, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get subtype =>
      $composableBuilder(column: $table.subtype, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get geometryGeojson => $composableBuilder(
    column: $table.geometryGeojson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get countryId =>
      $composableBuilder(column: $table.countryId, builder: (column) => column);

  GeneratedColumn<String> get regionId =>
      $composableBuilder(column: $table.regionId, builder: (column) => column);

  GeneratedColumn<String> get cityId =>
      $composableBuilder(column: $table.cityId, builder: (column) => column);

  GeneratedColumn<String> get cityCenterId => $composableBuilder(
    column: $table.cityCenterId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get drivable =>
      $composableBuilder(column: $table.drivable, builder: (column) => column);

  GeneratedColumn<bool> get walkable =>
      $composableBuilder(column: $table.walkable, builder: (column) => column);

  GeneratedColumn<bool> get cycleway =>
      $composableBuilder(column: $table.cycleway, builder: (column) => column);

  GeneratedColumn<double> get lengthM =>
      $composableBuilder(column: $table.lengthM, builder: (column) => column);

  GeneratedColumn<String> get countrySlug => $composableBuilder(
    column: $table.countrySlug,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$StaticObjectsTableTableManager
    extends
        RootTableManager<
          _$ExplorationDatabase,
          $StaticObjectsTable,
          StaticObject,
          $$StaticObjectsTableFilterComposer,
          $$StaticObjectsTableOrderingComposer,
          $$StaticObjectsTableAnnotationComposer,
          $$StaticObjectsTableCreateCompanionBuilder,
          $$StaticObjectsTableUpdateCompanionBuilder,
          (
            StaticObject,
            BaseReferences<
              _$ExplorationDatabase,
              $StaticObjectsTable,
              StaticObject
            >,
          ),
          StaticObject,
          PrefetchHooks Function()
        > {
  $$StaticObjectsTableTableManager(
    _$ExplorationDatabase db,
    $StaticObjectsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StaticObjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StaticObjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StaticObjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> objectId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> subtype = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String> geometryGeojson = const Value.absent(),
                Value<String?> countryId = const Value.absent(),
                Value<String?> regionId = const Value.absent(),
                Value<String?> cityId = const Value.absent(),
                Value<String?> cityCenterId = const Value.absent(),
                Value<bool?> drivable = const Value.absent(),
                Value<bool?> walkable = const Value.absent(),
                Value<bool?> cycleway = const Value.absent(),
                Value<double?> lengthM = const Value.absent(),
                Value<String> countrySlug = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StaticObjectsCompanion(
                objectId: objectId,
                category: category,
                subtype: subtype,
                name: name,
                geometryGeojson: geometryGeojson,
                countryId: countryId,
                regionId: regionId,
                cityId: cityId,
                cityCenterId: cityCenterId,
                drivable: drivable,
                walkable: walkable,
                cycleway: cycleway,
                lengthM: lengthM,
                countrySlug: countrySlug,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String objectId,
                required String category,
                Value<String?> subtype = const Value.absent(),
                Value<String?> name = const Value.absent(),
                required String geometryGeojson,
                Value<String?> countryId = const Value.absent(),
                Value<String?> regionId = const Value.absent(),
                Value<String?> cityId = const Value.absent(),
                Value<String?> cityCenterId = const Value.absent(),
                Value<bool?> drivable = const Value.absent(),
                Value<bool?> walkable = const Value.absent(),
                Value<bool?> cycleway = const Value.absent(),
                Value<double?> lengthM = const Value.absent(),
                required String countrySlug,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => StaticObjectsCompanion.insert(
                objectId: objectId,
                category: category,
                subtype: subtype,
                name: name,
                geometryGeojson: geometryGeojson,
                countryId: countryId,
                regionId: regionId,
                cityId: cityId,
                cityCenterId: cityCenterId,
                drivable: drivable,
                walkable: walkable,
                cycleway: cycleway,
                lengthM: lengthM,
                countrySlug: countrySlug,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StaticObjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$ExplorationDatabase,
      $StaticObjectsTable,
      StaticObject,
      $$StaticObjectsTableFilterComposer,
      $$StaticObjectsTableOrderingComposer,
      $$StaticObjectsTableAnnotationComposer,
      $$StaticObjectsTableCreateCompanionBuilder,
      $$StaticObjectsTableUpdateCompanionBuilder,
      (
        StaticObject,
        BaseReferences<
          _$ExplorationDatabase,
          $StaticObjectsTable,
          StaticObject
        >,
      ),
      StaticObject,
      PrefetchHooks Function()
    >;
typedef $$StaticEntityTotalsTableCreateCompanionBuilder =
    StaticEntityTotalsCompanion Function({
      required String entityId,
      Value<int> peaksCount,
      Value<int> hutsCount,
      Value<int> monumentsCount,
      Value<double> roadsDrivableLengthM,
      Value<double> roadsWalkableLengthM,
      Value<double> roadsCyclewayLengthM,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$StaticEntityTotalsTableUpdateCompanionBuilder =
    StaticEntityTotalsCompanion Function({
      Value<String> entityId,
      Value<int> peaksCount,
      Value<int> hutsCount,
      Value<int> monumentsCount,
      Value<double> roadsDrivableLengthM,
      Value<double> roadsWalkableLengthM,
      Value<double> roadsCyclewayLengthM,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$StaticEntityTotalsTableFilterComposer
    extends Composer<_$ExplorationDatabase, $StaticEntityTotalsTable> {
  $$StaticEntityTotalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get peaksCount => $composableBuilder(
    column: $table.peaksCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hutsCount => $composableBuilder(
    column: $table.hutsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monumentsCount => $composableBuilder(
    column: $table.monumentsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get roadsDrivableLengthM => $composableBuilder(
    column: $table.roadsDrivableLengthM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get roadsWalkableLengthM => $composableBuilder(
    column: $table.roadsWalkableLengthM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get roadsCyclewayLengthM => $composableBuilder(
    column: $table.roadsCyclewayLengthM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StaticEntityTotalsTableOrderingComposer
    extends Composer<_$ExplorationDatabase, $StaticEntityTotalsTable> {
  $$StaticEntityTotalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get peaksCount => $composableBuilder(
    column: $table.peaksCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hutsCount => $composableBuilder(
    column: $table.hutsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monumentsCount => $composableBuilder(
    column: $table.monumentsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get roadsDrivableLengthM => $composableBuilder(
    column: $table.roadsDrivableLengthM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get roadsWalkableLengthM => $composableBuilder(
    column: $table.roadsWalkableLengthM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get roadsCyclewayLengthM => $composableBuilder(
    column: $table.roadsCyclewayLengthM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StaticEntityTotalsTableAnnotationComposer
    extends Composer<_$ExplorationDatabase, $StaticEntityTotalsTable> {
  $$StaticEntityTotalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<int> get peaksCount => $composableBuilder(
    column: $table.peaksCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hutsCount =>
      $composableBuilder(column: $table.hutsCount, builder: (column) => column);

  GeneratedColumn<int> get monumentsCount => $composableBuilder(
    column: $table.monumentsCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get roadsDrivableLengthM => $composableBuilder(
    column: $table.roadsDrivableLengthM,
    builder: (column) => column,
  );

  GeneratedColumn<double> get roadsWalkableLengthM => $composableBuilder(
    column: $table.roadsWalkableLengthM,
    builder: (column) => column,
  );

  GeneratedColumn<double> get roadsCyclewayLengthM => $composableBuilder(
    column: $table.roadsCyclewayLengthM,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$StaticEntityTotalsTableTableManager
    extends
        RootTableManager<
          _$ExplorationDatabase,
          $StaticEntityTotalsTable,
          StaticEntityTotal,
          $$StaticEntityTotalsTableFilterComposer,
          $$StaticEntityTotalsTableOrderingComposer,
          $$StaticEntityTotalsTableAnnotationComposer,
          $$StaticEntityTotalsTableCreateCompanionBuilder,
          $$StaticEntityTotalsTableUpdateCompanionBuilder,
          (
            StaticEntityTotal,
            BaseReferences<
              _$ExplorationDatabase,
              $StaticEntityTotalsTable,
              StaticEntityTotal
            >,
          ),
          StaticEntityTotal,
          PrefetchHooks Function()
        > {
  $$StaticEntityTotalsTableTableManager(
    _$ExplorationDatabase db,
    $StaticEntityTotalsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StaticEntityTotalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StaticEntityTotalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StaticEntityTotalsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> entityId = const Value.absent(),
                Value<int> peaksCount = const Value.absent(),
                Value<int> hutsCount = const Value.absent(),
                Value<int> monumentsCount = const Value.absent(),
                Value<double> roadsDrivableLengthM = const Value.absent(),
                Value<double> roadsWalkableLengthM = const Value.absent(),
                Value<double> roadsCyclewayLengthM = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StaticEntityTotalsCompanion(
                entityId: entityId,
                peaksCount: peaksCount,
                hutsCount: hutsCount,
                monumentsCount: monumentsCount,
                roadsDrivableLengthM: roadsDrivableLengthM,
                roadsWalkableLengthM: roadsWalkableLengthM,
                roadsCyclewayLengthM: roadsCyclewayLengthM,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entityId,
                Value<int> peaksCount = const Value.absent(),
                Value<int> hutsCount = const Value.absent(),
                Value<int> monumentsCount = const Value.absent(),
                Value<double> roadsDrivableLengthM = const Value.absent(),
                Value<double> roadsWalkableLengthM = const Value.absent(),
                Value<double> roadsCyclewayLengthM = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => StaticEntityTotalsCompanion.insert(
                entityId: entityId,
                peaksCount: peaksCount,
                hutsCount: hutsCount,
                monumentsCount: monumentsCount,
                roadsDrivableLengthM: roadsDrivableLengthM,
                roadsWalkableLengthM: roadsWalkableLengthM,
                roadsCyclewayLengthM: roadsCyclewayLengthM,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StaticEntityTotalsTableProcessedTableManager =
    ProcessedTableManager<
      _$ExplorationDatabase,
      $StaticEntityTotalsTable,
      StaticEntityTotal,
      $$StaticEntityTotalsTableFilterComposer,
      $$StaticEntityTotalsTableOrderingComposer,
      $$StaticEntityTotalsTableAnnotationComposer,
      $$StaticEntityTotalsTableCreateCompanionBuilder,
      $$StaticEntityTotalsTableUpdateCompanionBuilder,
      (
        StaticEntityTotal,
        BaseReferences<
          _$ExplorationDatabase,
          $StaticEntityTotalsTable,
          StaticEntityTotal
        >,
      ),
      StaticEntityTotal,
      PrefetchHooks Function()
    >;
typedef $$SelectedEntityStateTableCreateCompanionBuilder =
    SelectedEntityStateCompanion Function({
      required String scopeKey,
      required String entityId,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$SelectedEntityStateTableUpdateCompanionBuilder =
    SelectedEntityStateCompanion Function({
      Value<String> scopeKey,
      Value<String> entityId,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$SelectedEntityStateTableFilterComposer
    extends Composer<_$ExplorationDatabase, $SelectedEntityStateTable> {
  $$SelectedEntityStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get scopeKey => $composableBuilder(
    column: $table.scopeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SelectedEntityStateTableOrderingComposer
    extends Composer<_$ExplorationDatabase, $SelectedEntityStateTable> {
  $$SelectedEntityStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get scopeKey => $composableBuilder(
    column: $table.scopeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SelectedEntityStateTableAnnotationComposer
    extends Composer<_$ExplorationDatabase, $SelectedEntityStateTable> {
  $$SelectedEntityStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get scopeKey =>
      $composableBuilder(column: $table.scopeKey, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SelectedEntityStateTableTableManager
    extends
        RootTableManager<
          _$ExplorationDatabase,
          $SelectedEntityStateTable,
          SelectedEntityStateData,
          $$SelectedEntityStateTableFilterComposer,
          $$SelectedEntityStateTableOrderingComposer,
          $$SelectedEntityStateTableAnnotationComposer,
          $$SelectedEntityStateTableCreateCompanionBuilder,
          $$SelectedEntityStateTableUpdateCompanionBuilder,
          (
            SelectedEntityStateData,
            BaseReferences<
              _$ExplorationDatabase,
              $SelectedEntityStateTable,
              SelectedEntityStateData
            >,
          ),
          SelectedEntityStateData,
          PrefetchHooks Function()
        > {
  $$SelectedEntityStateTableTableManager(
    _$ExplorationDatabase db,
    $SelectedEntityStateTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SelectedEntityStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SelectedEntityStateTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SelectedEntityStateTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> scopeKey = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SelectedEntityStateCompanion(
                scopeKey: scopeKey,
                entityId: entityId,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String scopeKey,
                required String entityId,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SelectedEntityStateCompanion.insert(
                scopeKey: scopeKey,
                entityId: entityId,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SelectedEntityStateTableProcessedTableManager =
    ProcessedTableManager<
      _$ExplorationDatabase,
      $SelectedEntityStateTable,
      SelectedEntityStateData,
      $$SelectedEntityStateTableFilterComposer,
      $$SelectedEntityStateTableOrderingComposer,
      $$SelectedEntityStateTableAnnotationComposer,
      $$SelectedEntityStateTableCreateCompanionBuilder,
      $$SelectedEntityStateTableUpdateCompanionBuilder,
      (
        SelectedEntityStateData,
        BaseReferences<
          _$ExplorationDatabase,
          $SelectedEntityStateTable,
          SelectedEntityStateData
        >,
      ),
      SelectedEntityStateData,
      PrefetchHooks Function()
    >;
typedef $$UserObjectProgressTableCreateCompanionBuilder =
    UserObjectProgressCompanion Function({
      required String userId,
      required String objectId,
      required String category,
      Value<bool> explored,
      Value<int?> firstExploredAt,
      Value<double?> bestDistanceM,
      Value<double?> confidence,
      Value<String?> sourceType,
      Value<int?> sampleCountUsed,
      Value<int?> lastSeenAt,
      Value<int> rowid,
    });
typedef $$UserObjectProgressTableUpdateCompanionBuilder =
    UserObjectProgressCompanion Function({
      Value<String> userId,
      Value<String> objectId,
      Value<String> category,
      Value<bool> explored,
      Value<int?> firstExploredAt,
      Value<double?> bestDistanceM,
      Value<double?> confidence,
      Value<String?> sourceType,
      Value<int?> sampleCountUsed,
      Value<int?> lastSeenAt,
      Value<int> rowid,
    });

class $$UserObjectProgressTableFilterComposer
    extends Composer<_$ExplorationDatabase, $UserObjectProgressTable> {
  $$UserObjectProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get objectId => $composableBuilder(
    column: $table.objectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get explored => $composableBuilder(
    column: $table.explored,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstExploredAt => $composableBuilder(
    column: $table.firstExploredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bestDistanceM => $composableBuilder(
    column: $table.bestDistanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sampleCountUsed => $composableBuilder(
    column: $table.sampleCountUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserObjectProgressTableOrderingComposer
    extends Composer<_$ExplorationDatabase, $UserObjectProgressTable> {
  $$UserObjectProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get objectId => $composableBuilder(
    column: $table.objectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get explored => $composableBuilder(
    column: $table.explored,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstExploredAt => $composableBuilder(
    column: $table.firstExploredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bestDistanceM => $composableBuilder(
    column: $table.bestDistanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sampleCountUsed => $composableBuilder(
    column: $table.sampleCountUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserObjectProgressTableAnnotationComposer
    extends Composer<_$ExplorationDatabase, $UserObjectProgressTable> {
  $$UserObjectProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get objectId =>
      $composableBuilder(column: $table.objectId, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<bool> get explored =>
      $composableBuilder(column: $table.explored, builder: (column) => column);

  GeneratedColumn<int> get firstExploredAt => $composableBuilder(
    column: $table.firstExploredAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get bestDistanceM => $composableBuilder(
    column: $table.bestDistanceM,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sampleCountUsed => $composableBuilder(
    column: $table.sampleCountUsed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );
}

class $$UserObjectProgressTableTableManager
    extends
        RootTableManager<
          _$ExplorationDatabase,
          $UserObjectProgressTable,
          UserObjectProgressData,
          $$UserObjectProgressTableFilterComposer,
          $$UserObjectProgressTableOrderingComposer,
          $$UserObjectProgressTableAnnotationComposer,
          $$UserObjectProgressTableCreateCompanionBuilder,
          $$UserObjectProgressTableUpdateCompanionBuilder,
          (
            UserObjectProgressData,
            BaseReferences<
              _$ExplorationDatabase,
              $UserObjectProgressTable,
              UserObjectProgressData
            >,
          ),
          UserObjectProgressData,
          PrefetchHooks Function()
        > {
  $$UserObjectProgressTableTableManager(
    _$ExplorationDatabase db,
    $UserObjectProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserObjectProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserObjectProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserObjectProgressTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> objectId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<bool> explored = const Value.absent(),
                Value<int?> firstExploredAt = const Value.absent(),
                Value<double?> bestDistanceM = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<String?> sourceType = const Value.absent(),
                Value<int?> sampleCountUsed = const Value.absent(),
                Value<int?> lastSeenAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserObjectProgressCompanion(
                userId: userId,
                objectId: objectId,
                category: category,
                explored: explored,
                firstExploredAt: firstExploredAt,
                bestDistanceM: bestDistanceM,
                confidence: confidence,
                sourceType: sourceType,
                sampleCountUsed: sampleCountUsed,
                lastSeenAt: lastSeenAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String objectId,
                required String category,
                Value<bool> explored = const Value.absent(),
                Value<int?> firstExploredAt = const Value.absent(),
                Value<double?> bestDistanceM = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<String?> sourceType = const Value.absent(),
                Value<int?> sampleCountUsed = const Value.absent(),
                Value<int?> lastSeenAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserObjectProgressCompanion.insert(
                userId: userId,
                objectId: objectId,
                category: category,
                explored: explored,
                firstExploredAt: firstExploredAt,
                bestDistanceM: bestDistanceM,
                confidence: confidence,
                sourceType: sourceType,
                sampleCountUsed: sampleCountUsed,
                lastSeenAt: lastSeenAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserObjectProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$ExplorationDatabase,
      $UserObjectProgressTable,
      UserObjectProgressData,
      $$UserObjectProgressTableFilterComposer,
      $$UserObjectProgressTableOrderingComposer,
      $$UserObjectProgressTableAnnotationComposer,
      $$UserObjectProgressTableCreateCompanionBuilder,
      $$UserObjectProgressTableUpdateCompanionBuilder,
      (
        UserObjectProgressData,
        BaseReferences<
          _$ExplorationDatabase,
          $UserObjectProgressTable,
          UserObjectProgressData
        >,
      ),
      UserObjectProgressData,
      PrefetchHooks Function()
    >;
typedef $$UserRoadSegmentProgressTableCreateCompanionBuilder =
    UserRoadSegmentProgressCompanion Function({
      required String userId,
      required String roadSegmentId,
      Value<double> coveredLengthM,
      Value<double> coverageRatio,
      Value<String> coveredIntervalsJson,
      Value<int?> firstCoveredAt,
      Value<int?> lastCoveredAt,
      Value<int?> sampleCountUsed,
      Value<String?> sourceType,
      Value<int> rowid,
    });
typedef $$UserRoadSegmentProgressTableUpdateCompanionBuilder =
    UserRoadSegmentProgressCompanion Function({
      Value<String> userId,
      Value<String> roadSegmentId,
      Value<double> coveredLengthM,
      Value<double> coverageRatio,
      Value<String> coveredIntervalsJson,
      Value<int?> firstCoveredAt,
      Value<int?> lastCoveredAt,
      Value<int?> sampleCountUsed,
      Value<String?> sourceType,
      Value<int> rowid,
    });

class $$UserRoadSegmentProgressTableFilterComposer
    extends Composer<_$ExplorationDatabase, $UserRoadSegmentProgressTable> {
  $$UserRoadSegmentProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roadSegmentId => $composableBuilder(
    column: $table.roadSegmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get coveredLengthM => $composableBuilder(
    column: $table.coveredLengthM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get coverageRatio => $composableBuilder(
    column: $table.coverageRatio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coveredIntervalsJson => $composableBuilder(
    column: $table.coveredIntervalsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstCoveredAt => $composableBuilder(
    column: $table.firstCoveredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastCoveredAt => $composableBuilder(
    column: $table.lastCoveredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sampleCountUsed => $composableBuilder(
    column: $table.sampleCountUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserRoadSegmentProgressTableOrderingComposer
    extends Composer<_$ExplorationDatabase, $UserRoadSegmentProgressTable> {
  $$UserRoadSegmentProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roadSegmentId => $composableBuilder(
    column: $table.roadSegmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get coveredLengthM => $composableBuilder(
    column: $table.coveredLengthM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get coverageRatio => $composableBuilder(
    column: $table.coverageRatio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coveredIntervalsJson => $composableBuilder(
    column: $table.coveredIntervalsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstCoveredAt => $composableBuilder(
    column: $table.firstCoveredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastCoveredAt => $composableBuilder(
    column: $table.lastCoveredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sampleCountUsed => $composableBuilder(
    column: $table.sampleCountUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserRoadSegmentProgressTableAnnotationComposer
    extends Composer<_$ExplorationDatabase, $UserRoadSegmentProgressTable> {
  $$UserRoadSegmentProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get roadSegmentId => $composableBuilder(
    column: $table.roadSegmentId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get coveredLengthM => $composableBuilder(
    column: $table.coveredLengthM,
    builder: (column) => column,
  );

  GeneratedColumn<double> get coverageRatio => $composableBuilder(
    column: $table.coverageRatio,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coveredIntervalsJson => $composableBuilder(
    column: $table.coveredIntervalsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get firstCoveredAt => $composableBuilder(
    column: $table.firstCoveredAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastCoveredAt => $composableBuilder(
    column: $table.lastCoveredAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sampleCountUsed => $composableBuilder(
    column: $table.sampleCountUsed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );
}

class $$UserRoadSegmentProgressTableTableManager
    extends
        RootTableManager<
          _$ExplorationDatabase,
          $UserRoadSegmentProgressTable,
          UserRoadSegmentProgressData,
          $$UserRoadSegmentProgressTableFilterComposer,
          $$UserRoadSegmentProgressTableOrderingComposer,
          $$UserRoadSegmentProgressTableAnnotationComposer,
          $$UserRoadSegmentProgressTableCreateCompanionBuilder,
          $$UserRoadSegmentProgressTableUpdateCompanionBuilder,
          (
            UserRoadSegmentProgressData,
            BaseReferences<
              _$ExplorationDatabase,
              $UserRoadSegmentProgressTable,
              UserRoadSegmentProgressData
            >,
          ),
          UserRoadSegmentProgressData,
          PrefetchHooks Function()
        > {
  $$UserRoadSegmentProgressTableTableManager(
    _$ExplorationDatabase db,
    $UserRoadSegmentProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserRoadSegmentProgressTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$UserRoadSegmentProgressTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UserRoadSegmentProgressTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> roadSegmentId = const Value.absent(),
                Value<double> coveredLengthM = const Value.absent(),
                Value<double> coverageRatio = const Value.absent(),
                Value<String> coveredIntervalsJson = const Value.absent(),
                Value<int?> firstCoveredAt = const Value.absent(),
                Value<int?> lastCoveredAt = const Value.absent(),
                Value<int?> sampleCountUsed = const Value.absent(),
                Value<String?> sourceType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserRoadSegmentProgressCompanion(
                userId: userId,
                roadSegmentId: roadSegmentId,
                coveredLengthM: coveredLengthM,
                coverageRatio: coverageRatio,
                coveredIntervalsJson: coveredIntervalsJson,
                firstCoveredAt: firstCoveredAt,
                lastCoveredAt: lastCoveredAt,
                sampleCountUsed: sampleCountUsed,
                sourceType: sourceType,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String roadSegmentId,
                Value<double> coveredLengthM = const Value.absent(),
                Value<double> coverageRatio = const Value.absent(),
                Value<String> coveredIntervalsJson = const Value.absent(),
                Value<int?> firstCoveredAt = const Value.absent(),
                Value<int?> lastCoveredAt = const Value.absent(),
                Value<int?> sampleCountUsed = const Value.absent(),
                Value<String?> sourceType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserRoadSegmentProgressCompanion.insert(
                userId: userId,
                roadSegmentId: roadSegmentId,
                coveredLengthM: coveredLengthM,
                coverageRatio: coverageRatio,
                coveredIntervalsJson: coveredIntervalsJson,
                firstCoveredAt: firstCoveredAt,
                lastCoveredAt: lastCoveredAt,
                sampleCountUsed: sampleCountUsed,
                sourceType: sourceType,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserRoadSegmentProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$ExplorationDatabase,
      $UserRoadSegmentProgressTable,
      UserRoadSegmentProgressData,
      $$UserRoadSegmentProgressTableFilterComposer,
      $$UserRoadSegmentProgressTableOrderingComposer,
      $$UserRoadSegmentProgressTableAnnotationComposer,
      $$UserRoadSegmentProgressTableCreateCompanionBuilder,
      $$UserRoadSegmentProgressTableUpdateCompanionBuilder,
      (
        UserRoadSegmentProgressData,
        BaseReferences<
          _$ExplorationDatabase,
          $UserRoadSegmentProgressTable,
          UserRoadSegmentProgressData
        >,
      ),
      UserRoadSegmentProgressData,
      PrefetchHooks Function()
    >;
typedef $$UserEntityProgressCacheTableCreateCompanionBuilder =
    UserEntityProgressCacheCompanion Function({
      required String userId,
      required String entityId,
      Value<int> exploredPeaksCount,
      Value<int> exploredHutsCount,
      Value<int> exploredMonumentsCount,
      Value<double> exploredDrivableLengthM,
      Value<double> exploredWalkableLengthM,
      Value<double> exploredCyclewayLengthM,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$UserEntityProgressCacheTableUpdateCompanionBuilder =
    UserEntityProgressCacheCompanion Function({
      Value<String> userId,
      Value<String> entityId,
      Value<int> exploredPeaksCount,
      Value<int> exploredHutsCount,
      Value<int> exploredMonumentsCount,
      Value<double> exploredDrivableLengthM,
      Value<double> exploredWalkableLengthM,
      Value<double> exploredCyclewayLengthM,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$UserEntityProgressCacheTableFilterComposer
    extends Composer<_$ExplorationDatabase, $UserEntityProgressCacheTable> {
  $$UserEntityProgressCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get exploredPeaksCount => $composableBuilder(
    column: $table.exploredPeaksCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get exploredHutsCount => $composableBuilder(
    column: $table.exploredHutsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get exploredMonumentsCount => $composableBuilder(
    column: $table.exploredMonumentsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get exploredDrivableLengthM => $composableBuilder(
    column: $table.exploredDrivableLengthM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get exploredWalkableLengthM => $composableBuilder(
    column: $table.exploredWalkableLengthM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get exploredCyclewayLengthM => $composableBuilder(
    column: $table.exploredCyclewayLengthM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserEntityProgressCacheTableOrderingComposer
    extends Composer<_$ExplorationDatabase, $UserEntityProgressCacheTable> {
  $$UserEntityProgressCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get exploredPeaksCount => $composableBuilder(
    column: $table.exploredPeaksCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get exploredHutsCount => $composableBuilder(
    column: $table.exploredHutsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get exploredMonumentsCount => $composableBuilder(
    column: $table.exploredMonumentsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get exploredDrivableLengthM => $composableBuilder(
    column: $table.exploredDrivableLengthM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get exploredWalkableLengthM => $composableBuilder(
    column: $table.exploredWalkableLengthM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get exploredCyclewayLengthM => $composableBuilder(
    column: $table.exploredCyclewayLengthM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserEntityProgressCacheTableAnnotationComposer
    extends Composer<_$ExplorationDatabase, $UserEntityProgressCacheTable> {
  $$UserEntityProgressCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<int> get exploredPeaksCount => $composableBuilder(
    column: $table.exploredPeaksCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get exploredHutsCount => $composableBuilder(
    column: $table.exploredHutsCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get exploredMonumentsCount => $composableBuilder(
    column: $table.exploredMonumentsCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get exploredDrivableLengthM => $composableBuilder(
    column: $table.exploredDrivableLengthM,
    builder: (column) => column,
  );

  GeneratedColumn<double> get exploredWalkableLengthM => $composableBuilder(
    column: $table.exploredWalkableLengthM,
    builder: (column) => column,
  );

  GeneratedColumn<double> get exploredCyclewayLengthM => $composableBuilder(
    column: $table.exploredCyclewayLengthM,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserEntityProgressCacheTableTableManager
    extends
        RootTableManager<
          _$ExplorationDatabase,
          $UserEntityProgressCacheTable,
          UserEntityProgressCacheData,
          $$UserEntityProgressCacheTableFilterComposer,
          $$UserEntityProgressCacheTableOrderingComposer,
          $$UserEntityProgressCacheTableAnnotationComposer,
          $$UserEntityProgressCacheTableCreateCompanionBuilder,
          $$UserEntityProgressCacheTableUpdateCompanionBuilder,
          (
            UserEntityProgressCacheData,
            BaseReferences<
              _$ExplorationDatabase,
              $UserEntityProgressCacheTable,
              UserEntityProgressCacheData
            >,
          ),
          UserEntityProgressCacheData,
          PrefetchHooks Function()
        > {
  $$UserEntityProgressCacheTableTableManager(
    _$ExplorationDatabase db,
    $UserEntityProgressCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserEntityProgressCacheTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$UserEntityProgressCacheTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UserEntityProgressCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<int> exploredPeaksCount = const Value.absent(),
                Value<int> exploredHutsCount = const Value.absent(),
                Value<int> exploredMonumentsCount = const Value.absent(),
                Value<double> exploredDrivableLengthM = const Value.absent(),
                Value<double> exploredWalkableLengthM = const Value.absent(),
                Value<double> exploredCyclewayLengthM = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserEntityProgressCacheCompanion(
                userId: userId,
                entityId: entityId,
                exploredPeaksCount: exploredPeaksCount,
                exploredHutsCount: exploredHutsCount,
                exploredMonumentsCount: exploredMonumentsCount,
                exploredDrivableLengthM: exploredDrivableLengthM,
                exploredWalkableLengthM: exploredWalkableLengthM,
                exploredCyclewayLengthM: exploredCyclewayLengthM,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String entityId,
                Value<int> exploredPeaksCount = const Value.absent(),
                Value<int> exploredHutsCount = const Value.absent(),
                Value<int> exploredMonumentsCount = const Value.absent(),
                Value<double> exploredDrivableLengthM = const Value.absent(),
                Value<double> exploredWalkableLengthM = const Value.absent(),
                Value<double> exploredCyclewayLengthM = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UserEntityProgressCacheCompanion.insert(
                userId: userId,
                entityId: entityId,
                exploredPeaksCount: exploredPeaksCount,
                exploredHutsCount: exploredHutsCount,
                exploredMonumentsCount: exploredMonumentsCount,
                exploredDrivableLengthM: exploredDrivableLengthM,
                exploredWalkableLengthM: exploredWalkableLengthM,
                exploredCyclewayLengthM: exploredCyclewayLengthM,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserEntityProgressCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$ExplorationDatabase,
      $UserEntityProgressCacheTable,
      UserEntityProgressCacheData,
      $$UserEntityProgressCacheTableFilterComposer,
      $$UserEntityProgressCacheTableOrderingComposer,
      $$UserEntityProgressCacheTableAnnotationComposer,
      $$UserEntityProgressCacheTableCreateCompanionBuilder,
      $$UserEntityProgressCacheTableUpdateCompanionBuilder,
      (
        UserEntityProgressCacheData,
        BaseReferences<
          _$ExplorationDatabase,
          $UserEntityProgressCacheTable,
          UserEntityProgressCacheData
        >,
      ),
      UserEntityProgressCacheData,
      PrefetchHooks Function()
    >;
typedef $$CountryPackStatusTableCreateCompanionBuilder =
    CountryPackStatusCompanion Function({
      required String countrySlug,
      Value<bool> downloaded,
      Value<bool> imported,
      Value<String?> manifestJson,
      Value<int?> importedAt,
      Value<String?> version,
      Value<int> rowid,
    });
typedef $$CountryPackStatusTableUpdateCompanionBuilder =
    CountryPackStatusCompanion Function({
      Value<String> countrySlug,
      Value<bool> downloaded,
      Value<bool> imported,
      Value<String?> manifestJson,
      Value<int?> importedAt,
      Value<String?> version,
      Value<int> rowid,
    });

class $$CountryPackStatusTableFilterComposer
    extends Composer<_$ExplorationDatabase, $CountryPackStatusTable> {
  $$CountryPackStatusTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get countrySlug => $composableBuilder(
    column: $table.countrySlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get downloaded => $composableBuilder(
    column: $table.downloaded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get imported => $composableBuilder(
    column: $table.imported,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manifestJson => $composableBuilder(
    column: $table.manifestJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CountryPackStatusTableOrderingComposer
    extends Composer<_$ExplorationDatabase, $CountryPackStatusTable> {
  $$CountryPackStatusTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get countrySlug => $composableBuilder(
    column: $table.countrySlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get downloaded => $composableBuilder(
    column: $table.downloaded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get imported => $composableBuilder(
    column: $table.imported,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manifestJson => $composableBuilder(
    column: $table.manifestJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CountryPackStatusTableAnnotationComposer
    extends Composer<_$ExplorationDatabase, $CountryPackStatusTable> {
  $$CountryPackStatusTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get countrySlug => $composableBuilder(
    column: $table.countrySlug,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get downloaded => $composableBuilder(
    column: $table.downloaded,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get imported =>
      $composableBuilder(column: $table.imported, builder: (column) => column);

  GeneratedColumn<String> get manifestJson => $composableBuilder(
    column: $table.manifestJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$CountryPackStatusTableTableManager
    extends
        RootTableManager<
          _$ExplorationDatabase,
          $CountryPackStatusTable,
          CountryPackStatusData,
          $$CountryPackStatusTableFilterComposer,
          $$CountryPackStatusTableOrderingComposer,
          $$CountryPackStatusTableAnnotationComposer,
          $$CountryPackStatusTableCreateCompanionBuilder,
          $$CountryPackStatusTableUpdateCompanionBuilder,
          (
            CountryPackStatusData,
            BaseReferences<
              _$ExplorationDatabase,
              $CountryPackStatusTable,
              CountryPackStatusData
            >,
          ),
          CountryPackStatusData,
          PrefetchHooks Function()
        > {
  $$CountryPackStatusTableTableManager(
    _$ExplorationDatabase db,
    $CountryPackStatusTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CountryPackStatusTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CountryPackStatusTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CountryPackStatusTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> countrySlug = const Value.absent(),
                Value<bool> downloaded = const Value.absent(),
                Value<bool> imported = const Value.absent(),
                Value<String?> manifestJson = const Value.absent(),
                Value<int?> importedAt = const Value.absent(),
                Value<String?> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CountryPackStatusCompanion(
                countrySlug: countrySlug,
                downloaded: downloaded,
                imported: imported,
                manifestJson: manifestJson,
                importedAt: importedAt,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String countrySlug,
                Value<bool> downloaded = const Value.absent(),
                Value<bool> imported = const Value.absent(),
                Value<String?> manifestJson = const Value.absent(),
                Value<int?> importedAt = const Value.absent(),
                Value<String?> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CountryPackStatusCompanion.insert(
                countrySlug: countrySlug,
                downloaded: downloaded,
                imported: imported,
                manifestJson: manifestJson,
                importedAt: importedAt,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CountryPackStatusTableProcessedTableManager =
    ProcessedTableManager<
      _$ExplorationDatabase,
      $CountryPackStatusTable,
      CountryPackStatusData,
      $$CountryPackStatusTableFilterComposer,
      $$CountryPackStatusTableOrderingComposer,
      $$CountryPackStatusTableAnnotationComposer,
      $$CountryPackStatusTableCreateCompanionBuilder,
      $$CountryPackStatusTableUpdateCompanionBuilder,
      (
        CountryPackStatusData,
        BaseReferences<
          _$ExplorationDatabase,
          $CountryPackStatusTable,
          CountryPackStatusData
        >,
      ),
      CountryPackStatusData,
      PrefetchHooks Function()
    >;

class $ExplorationDatabaseManager {
  final _$ExplorationDatabase _db;
  $ExplorationDatabaseManager(this._db);
  $$StaticEntitiesTableTableManager get staticEntities =>
      $$StaticEntitiesTableTableManager(_db, _db.staticEntities);
  $$StaticObjectsTableTableManager get staticObjects =>
      $$StaticObjectsTableTableManager(_db, _db.staticObjects);
  $$StaticEntityTotalsTableTableManager get staticEntityTotals =>
      $$StaticEntityTotalsTableTableManager(_db, _db.staticEntityTotals);
  $$SelectedEntityStateTableTableManager get selectedEntityState =>
      $$SelectedEntityStateTableTableManager(_db, _db.selectedEntityState);
  $$UserObjectProgressTableTableManager get userObjectProgress =>
      $$UserObjectProgressTableTableManager(_db, _db.userObjectProgress);
  $$UserRoadSegmentProgressTableTableManager get userRoadSegmentProgress =>
      $$UserRoadSegmentProgressTableTableManager(
        _db,
        _db.userRoadSegmentProgress,
      );
  $$UserEntityProgressCacheTableTableManager get userEntityProgressCache =>
      $$UserEntityProgressCacheTableTableManager(
        _db,
        _db.userEntityProgressCache,
      );
  $$CountryPackStatusTableTableManager get countryPackStatus =>
      $$CountryPackStatusTableTableManager(_db, _db.countryPackStatus);
}

mixin _$ExplorationDaoMixin on DatabaseAccessor<ExplorationDatabase> {
  $StaticEntitiesTable get staticEntities => attachedDatabase.staticEntities;
  $StaticObjectsTable get staticObjects => attachedDatabase.staticObjects;
  $StaticEntityTotalsTable get staticEntityTotals =>
      attachedDatabase.staticEntityTotals;
  $SelectedEntityStateTable get selectedEntityState =>
      attachedDatabase.selectedEntityState;
  $UserObjectProgressTable get userObjectProgress =>
      attachedDatabase.userObjectProgress;
  $UserRoadSegmentProgressTable get userRoadSegmentProgress =>
      attachedDatabase.userRoadSegmentProgress;
  $UserEntityProgressCacheTable get userEntityProgressCache =>
      attachedDatabase.userEntityProgressCache;
  $CountryPackStatusTable get countryPackStatus =>
      attachedDatabase.countryPackStatus;
  ExplorationDaoManager get managers => ExplorationDaoManager(this);
}

class ExplorationDaoManager {
  final _$ExplorationDaoMixin _db;
  ExplorationDaoManager(this._db);
  $$StaticEntitiesTableTableManager get staticEntities =>
      $$StaticEntitiesTableTableManager(
        _db.attachedDatabase,
        _db.staticEntities,
      );
  $$StaticObjectsTableTableManager get staticObjects =>
      $$StaticObjectsTableTableManager(_db.attachedDatabase, _db.staticObjects);
  $$StaticEntityTotalsTableTableManager get staticEntityTotals =>
      $$StaticEntityTotalsTableTableManager(
        _db.attachedDatabase,
        _db.staticEntityTotals,
      );
  $$SelectedEntityStateTableTableManager get selectedEntityState =>
      $$SelectedEntityStateTableTableManager(
        _db.attachedDatabase,
        _db.selectedEntityState,
      );
  $$UserObjectProgressTableTableManager get userObjectProgress =>
      $$UserObjectProgressTableTableManager(
        _db.attachedDatabase,
        _db.userObjectProgress,
      );
  $$UserRoadSegmentProgressTableTableManager get userRoadSegmentProgress =>
      $$UserRoadSegmentProgressTableTableManager(
        _db.attachedDatabase,
        _db.userRoadSegmentProgress,
      );
  $$UserEntityProgressCacheTableTableManager get userEntityProgressCache =>
      $$UserEntityProgressCacheTableTableManager(
        _db.attachedDatabase,
        _db.userEntityProgressCache,
      );
  $$CountryPackStatusTableTableManager get countryPackStatus =>
      $$CountryPackStatusTableTableManager(
        _db.attachedDatabase,
        _db.countryPackStatus,
      );
}
