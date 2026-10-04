// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MetaEntriesTable extends MetaEntries
    with TableInfo<$MetaEntriesTable, MetaEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetaEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meta_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetaEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  MetaEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetaEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $MetaEntriesTable createAlias(String alias) {
    return $MetaEntriesTable(attachedDatabase, alias);
  }
}

class MetaEntry extends DataClass implements Insertable<MetaEntry> {
  final String key;
  final String value;
  const MetaEntry({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  MetaEntriesCompanion toCompanion(bool nullToAbsent) {
    return MetaEntriesCompanion(key: Value(key), value: Value(value));
  }

  factory MetaEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetaEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  MetaEntry copyWith({String? key, String? value}) =>
      MetaEntry(key: key ?? this.key, value: value ?? this.value);
  MetaEntry copyWithCompanion(MetaEntriesCompanion data) {
    return MetaEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetaEntry(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetaEntry &&
          other.key == this.key &&
          other.value == this.value);
}

class MetaEntriesCompanion extends UpdateCompanion<MetaEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const MetaEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetaEntriesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<MetaEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetaEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return MetaEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetaEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxEntriesTable extends OutboxEntries
    with TableInfo<$OutboxEntriesTable, OutboxEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientUuidMeta = const VerificationMeta(
    'clientUuid',
  );
  @override
  late final GeneratedColumn<String> clientUuid = GeneratedColumn<String>(
    'client_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    opId,
    entity,
    action,
    clientUuid,
    payload,
    status,
    error,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    } else if (isInserting) {
      context.missing(_opIdMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('client_uuid')) {
      context.handle(
        _clientUuidMeta,
        clientUuid.isAcceptableOrUnknown(data['client_uuid']!, _clientUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_clientUuidMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      clientUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_uuid'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OutboxEntriesTable createAlias(String alias) {
    return $OutboxEntriesTable(attachedDatabase, alias);
  }
}

class OutboxEntry extends DataClass implements Insertable<OutboxEntry> {
  final int id;
  final String opId;
  final String entity;
  final String action;
  final String clientUuid;
  final String payload;
  final String status;
  final String? error;
  final DateTime createdAt;
  const OutboxEntry({
    required this.id,
    required this.opId,
    required this.entity,
    required this.action,
    required this.clientUuid,
    required this.payload,
    required this.status,
    this.error,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['op_id'] = Variable<String>(opId);
    map['entity'] = Variable<String>(entity);
    map['action'] = Variable<String>(action);
    map['client_uuid'] = Variable<String>(clientUuid);
    map['payload'] = Variable<String>(payload);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OutboxEntriesCompanion toCompanion(bool nullToAbsent) {
    return OutboxEntriesCompanion(
      id: Value(id),
      opId: Value(opId),
      entity: Value(entity),
      action: Value(action),
      clientUuid: Value(clientUuid),
      payload: Value(payload),
      status: Value(status),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxEntry(
      id: serializer.fromJson<int>(json['id']),
      opId: serializer.fromJson<String>(json['opId']),
      entity: serializer.fromJson<String>(json['entity']),
      action: serializer.fromJson<String>(json['action']),
      clientUuid: serializer.fromJson<String>(json['clientUuid']),
      payload: serializer.fromJson<String>(json['payload']),
      status: serializer.fromJson<String>(json['status']),
      error: serializer.fromJson<String?>(json['error']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'opId': serializer.toJson<String>(opId),
      'entity': serializer.toJson<String>(entity),
      'action': serializer.toJson<String>(action),
      'clientUuid': serializer.toJson<String>(clientUuid),
      'payload': serializer.toJson<String>(payload),
      'status': serializer.toJson<String>(status),
      'error': serializer.toJson<String?>(error),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OutboxEntry copyWith({
    int? id,
    String? opId,
    String? entity,
    String? action,
    String? clientUuid,
    String? payload,
    String? status,
    Value<String?> error = const Value.absent(),
    DateTime? createdAt,
  }) => OutboxEntry(
    id: id ?? this.id,
    opId: opId ?? this.opId,
    entity: entity ?? this.entity,
    action: action ?? this.action,
    clientUuid: clientUuid ?? this.clientUuid,
    payload: payload ?? this.payload,
    status: status ?? this.status,
    error: error.present ? error.value : this.error,
    createdAt: createdAt ?? this.createdAt,
  );
  OutboxEntry copyWithCompanion(OutboxEntriesCompanion data) {
    return OutboxEntry(
      id: data.id.present ? data.id.value : this.id,
      opId: data.opId.present ? data.opId.value : this.opId,
      entity: data.entity.present ? data.entity.value : this.entity,
      action: data.action.present ? data.action.value : this.action,
      clientUuid: data.clientUuid.present
          ? data.clientUuid.value
          : this.clientUuid,
      payload: data.payload.present ? data.payload.value : this.payload,
      status: data.status.present ? data.status.value : this.status,
      error: data.error.present ? data.error.value : this.error,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntry(')
          ..write('id: $id, ')
          ..write('opId: $opId, ')
          ..write('entity: $entity, ')
          ..write('action: $action, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('error: $error, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    opId,
    entity,
    action,
    clientUuid,
    payload,
    status,
    error,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxEntry &&
          other.id == this.id &&
          other.opId == this.opId &&
          other.entity == this.entity &&
          other.action == this.action &&
          other.clientUuid == this.clientUuid &&
          other.payload == this.payload &&
          other.status == this.status &&
          other.error == this.error &&
          other.createdAt == this.createdAt);
}

class OutboxEntriesCompanion extends UpdateCompanion<OutboxEntry> {
  final Value<int> id;
  final Value<String> opId;
  final Value<String> entity;
  final Value<String> action;
  final Value<String> clientUuid;
  final Value<String> payload;
  final Value<String> status;
  final Value<String?> error;
  final Value<DateTime> createdAt;
  const OutboxEntriesCompanion({
    this.id = const Value.absent(),
    this.opId = const Value.absent(),
    this.entity = const Value.absent(),
    this.action = const Value.absent(),
    this.clientUuid = const Value.absent(),
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
    this.error = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OutboxEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String opId,
    required String entity,
    required String action,
    required String clientUuid,
    required String payload,
    this.status = const Value.absent(),
    this.error = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : opId = Value(opId),
       entity = Value(entity),
       action = Value(action),
       clientUuid = Value(clientUuid),
       payload = Value(payload);
  static Insertable<OutboxEntry> custom({
    Expression<int>? id,
    Expression<String>? opId,
    Expression<String>? entity,
    Expression<String>? action,
    Expression<String>? clientUuid,
    Expression<String>? payload,
    Expression<String>? status,
    Expression<String>? error,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (opId != null) 'op_id': opId,
      if (entity != null) 'entity': entity,
      if (action != null) 'action': action,
      if (clientUuid != null) 'client_uuid': clientUuid,
      if (payload != null) 'payload': payload,
      if (status != null) 'status': status,
      if (error != null) 'error': error,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OutboxEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? opId,
    Value<String>? entity,
    Value<String>? action,
    Value<String>? clientUuid,
    Value<String>? payload,
    Value<String>? status,
    Value<String?>? error,
    Value<DateTime>? createdAt,
  }) {
    return OutboxEntriesCompanion(
      id: id ?? this.id,
      opId: opId ?? this.opId,
      entity: entity ?? this.entity,
      action: action ?? this.action,
      clientUuid: clientUuid ?? this.clientUuid,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      error: error ?? this.error,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (clientUuid.present) {
      map['client_uuid'] = Variable<String>(clientUuid.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntriesCompanion(')
          ..write('id: $id, ')
          ..write('opId: $opId, ')
          ..write('entity: $entity, ')
          ..write('action: $action, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('error: $error, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $UnitRowsTable extends UnitRows with TableInfo<$UnitRowsTable, UnitRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnitRowsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _clientUuidMeta = const VerificationMeta(
    'clientUuid',
  );
  @override
  late final GeneratedColumn<String> clientUuid = GeneratedColumn<String>(
    'client_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameUrMeta = const VerificationMeta('nameUr');
  @override
  late final GeneratedColumn<String> nameUr = GeneratedColumn<String>(
    'name_ur',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _shortNameMeta = const VerificationMeta(
    'shortName',
  );
  @override
  late final GeneratedColumn<String> shortName = GeneratedColumn<String>(
    'short_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serverId,
    clientUuid,
    nameEn,
    nameUr,
    shortName,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'unit_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<UnitRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('client_uuid')) {
      context.handle(
        _clientUuidMeta,
        clientUuid.isAcceptableOrUnknown(data['client_uuid']!, _clientUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_clientUuidMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(
        _nameEnMeta,
        nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta),
      );
    } else if (isInserting) {
      context.missing(_nameEnMeta);
    }
    if (data.containsKey('name_ur')) {
      context.handle(
        _nameUrMeta,
        nameUr.isAcceptableOrUnknown(data['name_ur']!, _nameUrMeta),
      );
    }
    if (data.containsKey('short_name')) {
      context.handle(
        _shortNameMeta,
        shortName.isAcceptableOrUnknown(data['short_name']!, _shortNameMeta),
      );
    } else if (isInserting) {
      context.missing(_shortNameMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UnitRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UnitRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      clientUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_uuid'],
      )!,
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      )!,
      nameUr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_ur'],
      )!,
      shortName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}short_name'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $UnitRowsTable createAlias(String alias) {
    return $UnitRowsTable(attachedDatabase, alias);
  }
}

class UnitRow extends DataClass implements Insertable<UnitRow> {
  final int id;
  final int? serverId;
  final String clientUuid;
  final String nameEn;
  final String nameUr;
  final String shortName;
  final String? updatedAt;
  const UnitRow({
    required this.id,
    this.serverId,
    required this.clientUuid,
    required this.nameEn,
    required this.nameUr,
    required this.shortName,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['client_uuid'] = Variable<String>(clientUuid);
    map['name_en'] = Variable<String>(nameEn);
    map['name_ur'] = Variable<String>(nameUr);
    map['short_name'] = Variable<String>(shortName);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  UnitRowsCompanion toCompanion(bool nullToAbsent) {
    return UnitRowsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      clientUuid: Value(clientUuid),
      nameEn: Value(nameEn),
      nameUr: Value(nameUr),
      shortName: Value(shortName),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory UnitRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UnitRow(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      clientUuid: serializer.fromJson<String>(json['clientUuid']),
      nameEn: serializer.fromJson<String>(json['nameEn']),
      nameUr: serializer.fromJson<String>(json['nameUr']),
      shortName: serializer.fromJson<String>(json['shortName']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<int?>(serverId),
      'clientUuid': serializer.toJson<String>(clientUuid),
      'nameEn': serializer.toJson<String>(nameEn),
      'nameUr': serializer.toJson<String>(nameUr),
      'shortName': serializer.toJson<String>(shortName),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  UnitRow copyWith({
    int? id,
    Value<int?> serverId = const Value.absent(),
    String? clientUuid,
    String? nameEn,
    String? nameUr,
    String? shortName,
    Value<String?> updatedAt = const Value.absent(),
  }) => UnitRow(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    clientUuid: clientUuid ?? this.clientUuid,
    nameEn: nameEn ?? this.nameEn,
    nameUr: nameUr ?? this.nameUr,
    shortName: shortName ?? this.shortName,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  UnitRow copyWithCompanion(UnitRowsCompanion data) {
    return UnitRow(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      clientUuid: data.clientUuid.present
          ? data.clientUuid.value
          : this.clientUuid,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      nameUr: data.nameUr.present ? data.nameUr.value : this.nameUr,
      shortName: data.shortName.present ? data.shortName.value : this.shortName,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UnitRow(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameUr: $nameUr, ')
          ..write('shortName: $shortName, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    clientUuid,
    nameEn,
    nameUr,
    shortName,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnitRow &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.clientUuid == this.clientUuid &&
          other.nameEn == this.nameEn &&
          other.nameUr == this.nameUr &&
          other.shortName == this.shortName &&
          other.updatedAt == this.updatedAt);
}

class UnitRowsCompanion extends UpdateCompanion<UnitRow> {
  final Value<int> id;
  final Value<int?> serverId;
  final Value<String> clientUuid;
  final Value<String> nameEn;
  final Value<String> nameUr;
  final Value<String> shortName;
  final Value<String?> updatedAt;
  const UnitRowsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientUuid = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.nameUr = const Value.absent(),
    this.shortName = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UnitRowsCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    required String clientUuid,
    required String nameEn,
    this.nameUr = const Value.absent(),
    required String shortName,
    this.updatedAt = const Value.absent(),
  }) : clientUuid = Value(clientUuid),
       nameEn = Value(nameEn),
       shortName = Value(shortName);
  static Insertable<UnitRow> custom({
    Expression<int>? id,
    Expression<int>? serverId,
    Expression<String>? clientUuid,
    Expression<String>? nameEn,
    Expression<String>? nameUr,
    Expression<String>? shortName,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (clientUuid != null) 'client_uuid': clientUuid,
      if (nameEn != null) 'name_en': nameEn,
      if (nameUr != null) 'name_ur': nameUr,
      if (shortName != null) 'short_name': shortName,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UnitRowsCompanion copyWith({
    Value<int>? id,
    Value<int?>? serverId,
    Value<String>? clientUuid,
    Value<String>? nameEn,
    Value<String>? nameUr,
    Value<String>? shortName,
    Value<String?>? updatedAt,
  }) {
    return UnitRowsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      clientUuid: clientUuid ?? this.clientUuid,
      nameEn: nameEn ?? this.nameEn,
      nameUr: nameUr ?? this.nameUr,
      shortName: shortName ?? this.shortName,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (clientUuid.present) {
      map['client_uuid'] = Variable<String>(clientUuid.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (nameUr.present) {
      map['name_ur'] = Variable<String>(nameUr.value);
    }
    if (shortName.present) {
      map['short_name'] = Variable<String>(shortName.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnitRowsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameUr: $nameUr, ')
          ..write('shortName: $shortName, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CategoryRowsTable extends CategoryRows
    with TableInfo<$CategoryRowsTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryRowsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _clientUuidMeta = const VerificationMeta(
    'clientUuid',
  );
  @override
  late final GeneratedColumn<String> clientUuid = GeneratedColumn<String>(
    'client_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _parentServerIdMeta = const VerificationMeta(
    'parentServerId',
  );
  @override
  late final GeneratedColumn<int> parentServerId = GeneratedColumn<int>(
    'parent_server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentClientUuidMeta = const VerificationMeta(
    'parentClientUuid',
  );
  @override
  late final GeneratedColumn<String> parentClientUuid = GeneratedColumn<String>(
    'parent_client_uuid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameUrMeta = const VerificationMeta('nameUr');
  @override
  late final GeneratedColumn<String> nameUr = GeneratedColumn<String>(
    'name_ur',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serverId,
    clientUuid,
    parentServerId,
    parentClientUuid,
    nameEn,
    nameUr,
    code,
    isActive,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('client_uuid')) {
      context.handle(
        _clientUuidMeta,
        clientUuid.isAcceptableOrUnknown(data['client_uuid']!, _clientUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_clientUuidMeta);
    }
    if (data.containsKey('parent_server_id')) {
      context.handle(
        _parentServerIdMeta,
        parentServerId.isAcceptableOrUnknown(
          data['parent_server_id']!,
          _parentServerIdMeta,
        ),
      );
    }
    if (data.containsKey('parent_client_uuid')) {
      context.handle(
        _parentClientUuidMeta,
        parentClientUuid.isAcceptableOrUnknown(
          data['parent_client_uuid']!,
          _parentClientUuidMeta,
        ),
      );
    }
    if (data.containsKey('name_en')) {
      context.handle(
        _nameEnMeta,
        nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta),
      );
    } else if (isInserting) {
      context.missing(_nameEnMeta);
    }
    if (data.containsKey('name_ur')) {
      context.handle(
        _nameUrMeta,
        nameUr.isAcceptableOrUnknown(data['name_ur']!, _nameUrMeta),
      );
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      clientUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_uuid'],
      )!,
      parentServerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_server_id'],
      ),
      parentClientUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_client_uuid'],
      ),
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      )!,
      nameUr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_ur'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $CategoryRowsTable createAlias(String alias) {
    return $CategoryRowsTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final int id;
  final int? serverId;
  final String clientUuid;
  final int? parentServerId;
  final String? parentClientUuid;
  final String nameEn;
  final String nameUr;
  final String? code;
  final bool isActive;
  final String? updatedAt;
  const CategoryRow({
    required this.id,
    this.serverId,
    required this.clientUuid,
    this.parentServerId,
    this.parentClientUuid,
    required this.nameEn,
    required this.nameUr,
    this.code,
    required this.isActive,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['client_uuid'] = Variable<String>(clientUuid);
    if (!nullToAbsent || parentServerId != null) {
      map['parent_server_id'] = Variable<int>(parentServerId);
    }
    if (!nullToAbsent || parentClientUuid != null) {
      map['parent_client_uuid'] = Variable<String>(parentClientUuid);
    }
    map['name_en'] = Variable<String>(nameEn);
    map['name_ur'] = Variable<String>(nameUr);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  CategoryRowsCompanion toCompanion(bool nullToAbsent) {
    return CategoryRowsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      clientUuid: Value(clientUuid),
      parentServerId: parentServerId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentServerId),
      parentClientUuid: parentClientUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(parentClientUuid),
      nameEn: Value(nameEn),
      nameUr: Value(nameUr),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      isActive: Value(isActive),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      clientUuid: serializer.fromJson<String>(json['clientUuid']),
      parentServerId: serializer.fromJson<int?>(json['parentServerId']),
      parentClientUuid: serializer.fromJson<String?>(json['parentClientUuid']),
      nameEn: serializer.fromJson<String>(json['nameEn']),
      nameUr: serializer.fromJson<String>(json['nameUr']),
      code: serializer.fromJson<String?>(json['code']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<int?>(serverId),
      'clientUuid': serializer.toJson<String>(clientUuid),
      'parentServerId': serializer.toJson<int?>(parentServerId),
      'parentClientUuid': serializer.toJson<String?>(parentClientUuid),
      'nameEn': serializer.toJson<String>(nameEn),
      'nameUr': serializer.toJson<String>(nameUr),
      'code': serializer.toJson<String?>(code),
      'isActive': serializer.toJson<bool>(isActive),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  CategoryRow copyWith({
    int? id,
    Value<int?> serverId = const Value.absent(),
    String? clientUuid,
    Value<int?> parentServerId = const Value.absent(),
    Value<String?> parentClientUuid = const Value.absent(),
    String? nameEn,
    String? nameUr,
    Value<String?> code = const Value.absent(),
    bool? isActive,
    Value<String?> updatedAt = const Value.absent(),
  }) => CategoryRow(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    clientUuid: clientUuid ?? this.clientUuid,
    parentServerId: parentServerId.present
        ? parentServerId.value
        : this.parentServerId,
    parentClientUuid: parentClientUuid.present
        ? parentClientUuid.value
        : this.parentClientUuid,
    nameEn: nameEn ?? this.nameEn,
    nameUr: nameUr ?? this.nameUr,
    code: code.present ? code.value : this.code,
    isActive: isActive ?? this.isActive,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  CategoryRow copyWithCompanion(CategoryRowsCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      clientUuid: data.clientUuid.present
          ? data.clientUuid.value
          : this.clientUuid,
      parentServerId: data.parentServerId.present
          ? data.parentServerId.value
          : this.parentServerId,
      parentClientUuid: data.parentClientUuid.present
          ? data.parentClientUuid.value
          : this.parentClientUuid,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      nameUr: data.nameUr.present ? data.nameUr.value : this.nameUr,
      code: data.code.present ? data.code.value : this.code,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('parentServerId: $parentServerId, ')
          ..write('parentClientUuid: $parentClientUuid, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameUr: $nameUr, ')
          ..write('code: $code, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    clientUuid,
    parentServerId,
    parentClientUuid,
    nameEn,
    nameUr,
    code,
    isActive,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.clientUuid == this.clientUuid &&
          other.parentServerId == this.parentServerId &&
          other.parentClientUuid == this.parentClientUuid &&
          other.nameEn == this.nameEn &&
          other.nameUr == this.nameUr &&
          other.code == this.code &&
          other.isActive == this.isActive &&
          other.updatedAt == this.updatedAt);
}

class CategoryRowsCompanion extends UpdateCompanion<CategoryRow> {
  final Value<int> id;
  final Value<int?> serverId;
  final Value<String> clientUuid;
  final Value<int?> parentServerId;
  final Value<String?> parentClientUuid;
  final Value<String> nameEn;
  final Value<String> nameUr;
  final Value<String?> code;
  final Value<bool> isActive;
  final Value<String?> updatedAt;
  const CategoryRowsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientUuid = const Value.absent(),
    this.parentServerId = const Value.absent(),
    this.parentClientUuid = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.nameUr = const Value.absent(),
    this.code = const Value.absent(),
    this.isActive = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CategoryRowsCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    required String clientUuid,
    this.parentServerId = const Value.absent(),
    this.parentClientUuid = const Value.absent(),
    required String nameEn,
    this.nameUr = const Value.absent(),
    this.code = const Value.absent(),
    this.isActive = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : clientUuid = Value(clientUuid),
       nameEn = Value(nameEn);
  static Insertable<CategoryRow> custom({
    Expression<int>? id,
    Expression<int>? serverId,
    Expression<String>? clientUuid,
    Expression<int>? parentServerId,
    Expression<String>? parentClientUuid,
    Expression<String>? nameEn,
    Expression<String>? nameUr,
    Expression<String>? code,
    Expression<bool>? isActive,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (clientUuid != null) 'client_uuid': clientUuid,
      if (parentServerId != null) 'parent_server_id': parentServerId,
      if (parentClientUuid != null) 'parent_client_uuid': parentClientUuid,
      if (nameEn != null) 'name_en': nameEn,
      if (nameUr != null) 'name_ur': nameUr,
      if (code != null) 'code': code,
      if (isActive != null) 'is_active': isActive,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CategoryRowsCompanion copyWith({
    Value<int>? id,
    Value<int?>? serverId,
    Value<String>? clientUuid,
    Value<int?>? parentServerId,
    Value<String?>? parentClientUuid,
    Value<String>? nameEn,
    Value<String>? nameUr,
    Value<String?>? code,
    Value<bool>? isActive,
    Value<String?>? updatedAt,
  }) {
    return CategoryRowsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      clientUuid: clientUuid ?? this.clientUuid,
      parentServerId: parentServerId ?? this.parentServerId,
      parentClientUuid: parentClientUuid ?? this.parentClientUuid,
      nameEn: nameEn ?? this.nameEn,
      nameUr: nameUr ?? this.nameUr,
      code: code ?? this.code,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (clientUuid.present) {
      map['client_uuid'] = Variable<String>(clientUuid.value);
    }
    if (parentServerId.present) {
      map['parent_server_id'] = Variable<int>(parentServerId.value);
    }
    if (parentClientUuid.present) {
      map['parent_client_uuid'] = Variable<String>(parentClientUuid.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (nameUr.present) {
      map['name_ur'] = Variable<String>(nameUr.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRowsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('parentServerId: $parentServerId, ')
          ..write('parentClientUuid: $parentClientUuid, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameUr: $nameUr, ')
          ..write('code: $code, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $BrandRowsTable extends BrandRows
    with TableInfo<$BrandRowsTable, BrandRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BrandRowsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _clientUuidMeta = const VerificationMeta(
    'clientUuid',
  );
  @override
  late final GeneratedColumn<String> clientUuid = GeneratedColumn<String>(
    'client_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameUrMeta = const VerificationMeta('nameUr');
  @override
  late final GeneratedColumn<String> nameUr = GeneratedColumn<String>(
    'name_ur',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serverId,
    clientUuid,
    nameEn,
    nameUr,
    code,
    isActive,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'brand_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<BrandRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('client_uuid')) {
      context.handle(
        _clientUuidMeta,
        clientUuid.isAcceptableOrUnknown(data['client_uuid']!, _clientUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_clientUuidMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(
        _nameEnMeta,
        nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta),
      );
    } else if (isInserting) {
      context.missing(_nameEnMeta);
    }
    if (data.containsKey('name_ur')) {
      context.handle(
        _nameUrMeta,
        nameUr.isAcceptableOrUnknown(data['name_ur']!, _nameUrMeta),
      );
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BrandRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BrandRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      clientUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_uuid'],
      )!,
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      )!,
      nameUr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_ur'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $BrandRowsTable createAlias(String alias) {
    return $BrandRowsTable(attachedDatabase, alias);
  }
}

class BrandRow extends DataClass implements Insertable<BrandRow> {
  final int id;
  final int? serverId;
  final String clientUuid;
  final String nameEn;
  final String nameUr;
  final String? code;
  final bool isActive;
  final String? updatedAt;
  const BrandRow({
    required this.id,
    this.serverId,
    required this.clientUuid,
    required this.nameEn,
    required this.nameUr,
    this.code,
    required this.isActive,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['client_uuid'] = Variable<String>(clientUuid);
    map['name_en'] = Variable<String>(nameEn);
    map['name_ur'] = Variable<String>(nameUr);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  BrandRowsCompanion toCompanion(bool nullToAbsent) {
    return BrandRowsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      clientUuid: Value(clientUuid),
      nameEn: Value(nameEn),
      nameUr: Value(nameUr),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      isActive: Value(isActive),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory BrandRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BrandRow(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      clientUuid: serializer.fromJson<String>(json['clientUuid']),
      nameEn: serializer.fromJson<String>(json['nameEn']),
      nameUr: serializer.fromJson<String>(json['nameUr']),
      code: serializer.fromJson<String?>(json['code']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<int?>(serverId),
      'clientUuid': serializer.toJson<String>(clientUuid),
      'nameEn': serializer.toJson<String>(nameEn),
      'nameUr': serializer.toJson<String>(nameUr),
      'code': serializer.toJson<String?>(code),
      'isActive': serializer.toJson<bool>(isActive),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  BrandRow copyWith({
    int? id,
    Value<int?> serverId = const Value.absent(),
    String? clientUuid,
    String? nameEn,
    String? nameUr,
    Value<String?> code = const Value.absent(),
    bool? isActive,
    Value<String?> updatedAt = const Value.absent(),
  }) => BrandRow(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    clientUuid: clientUuid ?? this.clientUuid,
    nameEn: nameEn ?? this.nameEn,
    nameUr: nameUr ?? this.nameUr,
    code: code.present ? code.value : this.code,
    isActive: isActive ?? this.isActive,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  BrandRow copyWithCompanion(BrandRowsCompanion data) {
    return BrandRow(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      clientUuid: data.clientUuid.present
          ? data.clientUuid.value
          : this.clientUuid,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      nameUr: data.nameUr.present ? data.nameUr.value : this.nameUr,
      code: data.code.present ? data.code.value : this.code,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BrandRow(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameUr: $nameUr, ')
          ..write('code: $code, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    clientUuid,
    nameEn,
    nameUr,
    code,
    isActive,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BrandRow &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.clientUuid == this.clientUuid &&
          other.nameEn == this.nameEn &&
          other.nameUr == this.nameUr &&
          other.code == this.code &&
          other.isActive == this.isActive &&
          other.updatedAt == this.updatedAt);
}

class BrandRowsCompanion extends UpdateCompanion<BrandRow> {
  final Value<int> id;
  final Value<int?> serverId;
  final Value<String> clientUuid;
  final Value<String> nameEn;
  final Value<String> nameUr;
  final Value<String?> code;
  final Value<bool> isActive;
  final Value<String?> updatedAt;
  const BrandRowsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientUuid = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.nameUr = const Value.absent(),
    this.code = const Value.absent(),
    this.isActive = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BrandRowsCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    required String clientUuid,
    required String nameEn,
    this.nameUr = const Value.absent(),
    this.code = const Value.absent(),
    this.isActive = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : clientUuid = Value(clientUuid),
       nameEn = Value(nameEn);
  static Insertable<BrandRow> custom({
    Expression<int>? id,
    Expression<int>? serverId,
    Expression<String>? clientUuid,
    Expression<String>? nameEn,
    Expression<String>? nameUr,
    Expression<String>? code,
    Expression<bool>? isActive,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (clientUuid != null) 'client_uuid': clientUuid,
      if (nameEn != null) 'name_en': nameEn,
      if (nameUr != null) 'name_ur': nameUr,
      if (code != null) 'code': code,
      if (isActive != null) 'is_active': isActive,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BrandRowsCompanion copyWith({
    Value<int>? id,
    Value<int?>? serverId,
    Value<String>? clientUuid,
    Value<String>? nameEn,
    Value<String>? nameUr,
    Value<String?>? code,
    Value<bool>? isActive,
    Value<String?>? updatedAt,
  }) {
    return BrandRowsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      clientUuid: clientUuid ?? this.clientUuid,
      nameEn: nameEn ?? this.nameEn,
      nameUr: nameUr ?? this.nameUr,
      code: code ?? this.code,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (clientUuid.present) {
      map['client_uuid'] = Variable<String>(clientUuid.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (nameUr.present) {
      map['name_ur'] = Variable<String>(nameUr.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BrandRowsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameUr: $nameUr, ')
          ..write('code: $code, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ProductRowsTable extends ProductRows
    with TableInfo<$ProductRowsTable, ProductRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductRowsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _clientUuidMeta = const VerificationMeta(
    'clientUuid',
  );
  @override
  late final GeneratedColumn<String> clientUuid = GeneratedColumn<String>(
    'client_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameUrMeta = const VerificationMeta('nameUr');
  @override
  late final GeneratedColumn<String> nameUr = GeneratedColumn<String>(
    'name_ur',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _categoryServerIdMeta = const VerificationMeta(
    'categoryServerId',
  );
  @override
  late final GeneratedColumn<int> categoryServerId = GeneratedColumn<int>(
    'category_server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryClientUuidMeta =
      const VerificationMeta('categoryClientUuid');
  @override
  late final GeneratedColumn<String> categoryClientUuid =
      GeneratedColumn<String>(
        'category_client_uuid',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _brandServerIdMeta = const VerificationMeta(
    'brandServerId',
  );
  @override
  late final GeneratedColumn<int> brandServerId = GeneratedColumn<int>(
    'brand_server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _brandClientUuidMeta = const VerificationMeta(
    'brandClientUuid',
  );
  @override
  late final GeneratedColumn<String> brandClientUuid = GeneratedColumn<String>(
    'brand_client_uuid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitServerIdMeta = const VerificationMeta(
    'unitServerId',
  );
  @override
  late final GeneratedColumn<int> unitServerId = GeneratedColumn<int>(
    'unit_server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitClientUuidMeta = const VerificationMeta(
    'unitClientUuid',
  );
  @override
  late final GeneratedColumn<String> unitClientUuid = GeneratedColumn<String>(
    'unit_client_uuid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitShortNameMeta = const VerificationMeta(
    'unitShortName',
  );
  @override
  late final GeneratedColumn<String> unitShortName = GeneratedColumn<String>(
    'unit_short_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _purchasePriceMeta = const VerificationMeta(
    'purchasePrice',
  );
  @override
  late final GeneratedColumn<String> purchasePrice = GeneratedColumn<String>(
    'purchase_price',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0.00'),
  );
  static const VerificationMeta _salePriceMeta = const VerificationMeta(
    'salePrice',
  );
  @override
  late final GeneratedColumn<String> salePrice = GeneratedColumn<String>(
    'sale_price',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0.00'),
  );
  static const VerificationMeta _wholesalePriceMeta = const VerificationMeta(
    'wholesalePrice',
  );
  @override
  late final GeneratedColumn<String> wholesalePrice = GeneratedColumn<String>(
    'wholesale_price',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0.00'),
  );
  static const VerificationMeta _alertQtyMeta = const VerificationMeta(
    'alertQty',
  );
  @override
  late final GeneratedColumn<String> alertQty = GeneratedColumn<String>(
    'alert_qty',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0.000'),
  );
  static const VerificationMeta _trackStockMeta = const VerificationMeta(
    'trackStock',
  );
  @override
  late final GeneratedColumn<bool> trackStock = GeneratedColumn<bool>(
    'track_stock',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("track_stock" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serverId,
    clientUuid,
    code,
    barcode,
    nameEn,
    nameUr,
    categoryServerId,
    categoryClientUuid,
    brandServerId,
    brandClientUuid,
    unitServerId,
    unitClientUuid,
    unitShortName,
    purchasePrice,
    salePrice,
    wholesalePrice,
    alertQty,
    trackStock,
    isActive,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('client_uuid')) {
      context.handle(
        _clientUuidMeta,
        clientUuid.isAcceptableOrUnknown(data['client_uuid']!, _clientUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_clientUuidMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('name_en')) {
      context.handle(
        _nameEnMeta,
        nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta),
      );
    } else if (isInserting) {
      context.missing(_nameEnMeta);
    }
    if (data.containsKey('name_ur')) {
      context.handle(
        _nameUrMeta,
        nameUr.isAcceptableOrUnknown(data['name_ur']!, _nameUrMeta),
      );
    }
    if (data.containsKey('category_server_id')) {
      context.handle(
        _categoryServerIdMeta,
        categoryServerId.isAcceptableOrUnknown(
          data['category_server_id']!,
          _categoryServerIdMeta,
        ),
      );
    }
    if (data.containsKey('category_client_uuid')) {
      context.handle(
        _categoryClientUuidMeta,
        categoryClientUuid.isAcceptableOrUnknown(
          data['category_client_uuid']!,
          _categoryClientUuidMeta,
        ),
      );
    }
    if (data.containsKey('brand_server_id')) {
      context.handle(
        _brandServerIdMeta,
        brandServerId.isAcceptableOrUnknown(
          data['brand_server_id']!,
          _brandServerIdMeta,
        ),
      );
    }
    if (data.containsKey('brand_client_uuid')) {
      context.handle(
        _brandClientUuidMeta,
        brandClientUuid.isAcceptableOrUnknown(
          data['brand_client_uuid']!,
          _brandClientUuidMeta,
        ),
      );
    }
    if (data.containsKey('unit_server_id')) {
      context.handle(
        _unitServerIdMeta,
        unitServerId.isAcceptableOrUnknown(
          data['unit_server_id']!,
          _unitServerIdMeta,
        ),
      );
    }
    if (data.containsKey('unit_client_uuid')) {
      context.handle(
        _unitClientUuidMeta,
        unitClientUuid.isAcceptableOrUnknown(
          data['unit_client_uuid']!,
          _unitClientUuidMeta,
        ),
      );
    }
    if (data.containsKey('unit_short_name')) {
      context.handle(
        _unitShortNameMeta,
        unitShortName.isAcceptableOrUnknown(
          data['unit_short_name']!,
          _unitShortNameMeta,
        ),
      );
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
        _purchasePriceMeta,
        purchasePrice.isAcceptableOrUnknown(
          data['purchase_price']!,
          _purchasePriceMeta,
        ),
      );
    }
    if (data.containsKey('sale_price')) {
      context.handle(
        _salePriceMeta,
        salePrice.isAcceptableOrUnknown(data['sale_price']!, _salePriceMeta),
      );
    }
    if (data.containsKey('wholesale_price')) {
      context.handle(
        _wholesalePriceMeta,
        wholesalePrice.isAcceptableOrUnknown(
          data['wholesale_price']!,
          _wholesalePriceMeta,
        ),
      );
    }
    if (data.containsKey('alert_qty')) {
      context.handle(
        _alertQtyMeta,
        alertQty.isAcceptableOrUnknown(data['alert_qty']!, _alertQtyMeta),
      );
    }
    if (data.containsKey('track_stock')) {
      context.handle(
        _trackStockMeta,
        trackStock.isAcceptableOrUnknown(data['track_stock']!, _trackStockMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      clientUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_uuid'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      )!,
      nameUr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_ur'],
      )!,
      categoryServerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_server_id'],
      ),
      categoryClientUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_client_uuid'],
      ),
      brandServerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}brand_server_id'],
      ),
      brandClientUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand_client_uuid'],
      ),
      unitServerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_server_id'],
      ),
      unitClientUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_client_uuid'],
      ),
      unitShortName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_short_name'],
      )!,
      purchasePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_price'],
      )!,
      salePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_price'],
      )!,
      wholesalePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wholesale_price'],
      )!,
      alertQty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alert_qty'],
      )!,
      trackStock: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}track_stock'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $ProductRowsTable createAlias(String alias) {
    return $ProductRowsTable(attachedDatabase, alias);
  }
}

class ProductRow extends DataClass implements Insertable<ProductRow> {
  final int id;
  final int? serverId;
  final String clientUuid;
  final String code;
  final String? barcode;
  final String nameEn;
  final String nameUr;
  final int? categoryServerId;
  final String? categoryClientUuid;
  final int? brandServerId;
  final String? brandClientUuid;
  final int? unitServerId;
  final String? unitClientUuid;
  final String unitShortName;
  final String purchasePrice;
  final String salePrice;
  final String wholesalePrice;
  final String alertQty;
  final bool trackStock;
  final bool isActive;
  final String? updatedAt;
  const ProductRow({
    required this.id,
    this.serverId,
    required this.clientUuid,
    required this.code,
    this.barcode,
    required this.nameEn,
    required this.nameUr,
    this.categoryServerId,
    this.categoryClientUuid,
    this.brandServerId,
    this.brandClientUuid,
    this.unitServerId,
    this.unitClientUuid,
    required this.unitShortName,
    required this.purchasePrice,
    required this.salePrice,
    required this.wholesalePrice,
    required this.alertQty,
    required this.trackStock,
    required this.isActive,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['client_uuid'] = Variable<String>(clientUuid);
    map['code'] = Variable<String>(code);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['name_en'] = Variable<String>(nameEn);
    map['name_ur'] = Variable<String>(nameUr);
    if (!nullToAbsent || categoryServerId != null) {
      map['category_server_id'] = Variable<int>(categoryServerId);
    }
    if (!nullToAbsent || categoryClientUuid != null) {
      map['category_client_uuid'] = Variable<String>(categoryClientUuid);
    }
    if (!nullToAbsent || brandServerId != null) {
      map['brand_server_id'] = Variable<int>(brandServerId);
    }
    if (!nullToAbsent || brandClientUuid != null) {
      map['brand_client_uuid'] = Variable<String>(brandClientUuid);
    }
    if (!nullToAbsent || unitServerId != null) {
      map['unit_server_id'] = Variable<int>(unitServerId);
    }
    if (!nullToAbsent || unitClientUuid != null) {
      map['unit_client_uuid'] = Variable<String>(unitClientUuid);
    }
    map['unit_short_name'] = Variable<String>(unitShortName);
    map['purchase_price'] = Variable<String>(purchasePrice);
    map['sale_price'] = Variable<String>(salePrice);
    map['wholesale_price'] = Variable<String>(wholesalePrice);
    map['alert_qty'] = Variable<String>(alertQty);
    map['track_stock'] = Variable<bool>(trackStock);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  ProductRowsCompanion toCompanion(bool nullToAbsent) {
    return ProductRowsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      clientUuid: Value(clientUuid),
      code: Value(code),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      nameEn: Value(nameEn),
      nameUr: Value(nameUr),
      categoryServerId: categoryServerId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryServerId),
      categoryClientUuid: categoryClientUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryClientUuid),
      brandServerId: brandServerId == null && nullToAbsent
          ? const Value.absent()
          : Value(brandServerId),
      brandClientUuid: brandClientUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(brandClientUuid),
      unitServerId: unitServerId == null && nullToAbsent
          ? const Value.absent()
          : Value(unitServerId),
      unitClientUuid: unitClientUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(unitClientUuid),
      unitShortName: Value(unitShortName),
      purchasePrice: Value(purchasePrice),
      salePrice: Value(salePrice),
      wholesalePrice: Value(wholesalePrice),
      alertQty: Value(alertQty),
      trackStock: Value(trackStock),
      isActive: Value(isActive),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory ProductRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductRow(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      clientUuid: serializer.fromJson<String>(json['clientUuid']),
      code: serializer.fromJson<String>(json['code']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      nameEn: serializer.fromJson<String>(json['nameEn']),
      nameUr: serializer.fromJson<String>(json['nameUr']),
      categoryServerId: serializer.fromJson<int?>(json['categoryServerId']),
      categoryClientUuid: serializer.fromJson<String?>(
        json['categoryClientUuid'],
      ),
      brandServerId: serializer.fromJson<int?>(json['brandServerId']),
      brandClientUuid: serializer.fromJson<String?>(json['brandClientUuid']),
      unitServerId: serializer.fromJson<int?>(json['unitServerId']),
      unitClientUuid: serializer.fromJson<String?>(json['unitClientUuid']),
      unitShortName: serializer.fromJson<String>(json['unitShortName']),
      purchasePrice: serializer.fromJson<String>(json['purchasePrice']),
      salePrice: serializer.fromJson<String>(json['salePrice']),
      wholesalePrice: serializer.fromJson<String>(json['wholesalePrice']),
      alertQty: serializer.fromJson<String>(json['alertQty']),
      trackStock: serializer.fromJson<bool>(json['trackStock']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<int?>(serverId),
      'clientUuid': serializer.toJson<String>(clientUuid),
      'code': serializer.toJson<String>(code),
      'barcode': serializer.toJson<String?>(barcode),
      'nameEn': serializer.toJson<String>(nameEn),
      'nameUr': serializer.toJson<String>(nameUr),
      'categoryServerId': serializer.toJson<int?>(categoryServerId),
      'categoryClientUuid': serializer.toJson<String?>(categoryClientUuid),
      'brandServerId': serializer.toJson<int?>(brandServerId),
      'brandClientUuid': serializer.toJson<String?>(brandClientUuid),
      'unitServerId': serializer.toJson<int?>(unitServerId),
      'unitClientUuid': serializer.toJson<String?>(unitClientUuid),
      'unitShortName': serializer.toJson<String>(unitShortName),
      'purchasePrice': serializer.toJson<String>(purchasePrice),
      'salePrice': serializer.toJson<String>(salePrice),
      'wholesalePrice': serializer.toJson<String>(wholesalePrice),
      'alertQty': serializer.toJson<String>(alertQty),
      'trackStock': serializer.toJson<bool>(trackStock),
      'isActive': serializer.toJson<bool>(isActive),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  ProductRow copyWith({
    int? id,
    Value<int?> serverId = const Value.absent(),
    String? clientUuid,
    String? code,
    Value<String?> barcode = const Value.absent(),
    String? nameEn,
    String? nameUr,
    Value<int?> categoryServerId = const Value.absent(),
    Value<String?> categoryClientUuid = const Value.absent(),
    Value<int?> brandServerId = const Value.absent(),
    Value<String?> brandClientUuid = const Value.absent(),
    Value<int?> unitServerId = const Value.absent(),
    Value<String?> unitClientUuid = const Value.absent(),
    String? unitShortName,
    String? purchasePrice,
    String? salePrice,
    String? wholesalePrice,
    String? alertQty,
    bool? trackStock,
    bool? isActive,
    Value<String?> updatedAt = const Value.absent(),
  }) => ProductRow(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    clientUuid: clientUuid ?? this.clientUuid,
    code: code ?? this.code,
    barcode: barcode.present ? barcode.value : this.barcode,
    nameEn: nameEn ?? this.nameEn,
    nameUr: nameUr ?? this.nameUr,
    categoryServerId: categoryServerId.present
        ? categoryServerId.value
        : this.categoryServerId,
    categoryClientUuid: categoryClientUuid.present
        ? categoryClientUuid.value
        : this.categoryClientUuid,
    brandServerId: brandServerId.present
        ? brandServerId.value
        : this.brandServerId,
    brandClientUuid: brandClientUuid.present
        ? brandClientUuid.value
        : this.brandClientUuid,
    unitServerId: unitServerId.present ? unitServerId.value : this.unitServerId,
    unitClientUuid: unitClientUuid.present
        ? unitClientUuid.value
        : this.unitClientUuid,
    unitShortName: unitShortName ?? this.unitShortName,
    purchasePrice: purchasePrice ?? this.purchasePrice,
    salePrice: salePrice ?? this.salePrice,
    wholesalePrice: wholesalePrice ?? this.wholesalePrice,
    alertQty: alertQty ?? this.alertQty,
    trackStock: trackStock ?? this.trackStock,
    isActive: isActive ?? this.isActive,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  ProductRow copyWithCompanion(ProductRowsCompanion data) {
    return ProductRow(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      clientUuid: data.clientUuid.present
          ? data.clientUuid.value
          : this.clientUuid,
      code: data.code.present ? data.code.value : this.code,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      nameUr: data.nameUr.present ? data.nameUr.value : this.nameUr,
      categoryServerId: data.categoryServerId.present
          ? data.categoryServerId.value
          : this.categoryServerId,
      categoryClientUuid: data.categoryClientUuid.present
          ? data.categoryClientUuid.value
          : this.categoryClientUuid,
      brandServerId: data.brandServerId.present
          ? data.brandServerId.value
          : this.brandServerId,
      brandClientUuid: data.brandClientUuid.present
          ? data.brandClientUuid.value
          : this.brandClientUuid,
      unitServerId: data.unitServerId.present
          ? data.unitServerId.value
          : this.unitServerId,
      unitClientUuid: data.unitClientUuid.present
          ? data.unitClientUuid.value
          : this.unitClientUuid,
      unitShortName: data.unitShortName.present
          ? data.unitShortName.value
          : this.unitShortName,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      salePrice: data.salePrice.present ? data.salePrice.value : this.salePrice,
      wholesalePrice: data.wholesalePrice.present
          ? data.wholesalePrice.value
          : this.wholesalePrice,
      alertQty: data.alertQty.present ? data.alertQty.value : this.alertQty,
      trackStock: data.trackStock.present
          ? data.trackStock.value
          : this.trackStock,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductRow(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('code: $code, ')
          ..write('barcode: $barcode, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameUr: $nameUr, ')
          ..write('categoryServerId: $categoryServerId, ')
          ..write('categoryClientUuid: $categoryClientUuid, ')
          ..write('brandServerId: $brandServerId, ')
          ..write('brandClientUuid: $brandClientUuid, ')
          ..write('unitServerId: $unitServerId, ')
          ..write('unitClientUuid: $unitClientUuid, ')
          ..write('unitShortName: $unitShortName, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('salePrice: $salePrice, ')
          ..write('wholesalePrice: $wholesalePrice, ')
          ..write('alertQty: $alertQty, ')
          ..write('trackStock: $trackStock, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    serverId,
    clientUuid,
    code,
    barcode,
    nameEn,
    nameUr,
    categoryServerId,
    categoryClientUuid,
    brandServerId,
    brandClientUuid,
    unitServerId,
    unitClientUuid,
    unitShortName,
    purchasePrice,
    salePrice,
    wholesalePrice,
    alertQty,
    trackStock,
    isActive,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductRow &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.clientUuid == this.clientUuid &&
          other.code == this.code &&
          other.barcode == this.barcode &&
          other.nameEn == this.nameEn &&
          other.nameUr == this.nameUr &&
          other.categoryServerId == this.categoryServerId &&
          other.categoryClientUuid == this.categoryClientUuid &&
          other.brandServerId == this.brandServerId &&
          other.brandClientUuid == this.brandClientUuid &&
          other.unitServerId == this.unitServerId &&
          other.unitClientUuid == this.unitClientUuid &&
          other.unitShortName == this.unitShortName &&
          other.purchasePrice == this.purchasePrice &&
          other.salePrice == this.salePrice &&
          other.wholesalePrice == this.wholesalePrice &&
          other.alertQty == this.alertQty &&
          other.trackStock == this.trackStock &&
          other.isActive == this.isActive &&
          other.updatedAt == this.updatedAt);
}

class ProductRowsCompanion extends UpdateCompanion<ProductRow> {
  final Value<int> id;
  final Value<int?> serverId;
  final Value<String> clientUuid;
  final Value<String> code;
  final Value<String?> barcode;
  final Value<String> nameEn;
  final Value<String> nameUr;
  final Value<int?> categoryServerId;
  final Value<String?> categoryClientUuid;
  final Value<int?> brandServerId;
  final Value<String?> brandClientUuid;
  final Value<int?> unitServerId;
  final Value<String?> unitClientUuid;
  final Value<String> unitShortName;
  final Value<String> purchasePrice;
  final Value<String> salePrice;
  final Value<String> wholesalePrice;
  final Value<String> alertQty;
  final Value<bool> trackStock;
  final Value<bool> isActive;
  final Value<String?> updatedAt;
  const ProductRowsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientUuid = const Value.absent(),
    this.code = const Value.absent(),
    this.barcode = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.nameUr = const Value.absent(),
    this.categoryServerId = const Value.absent(),
    this.categoryClientUuid = const Value.absent(),
    this.brandServerId = const Value.absent(),
    this.brandClientUuid = const Value.absent(),
    this.unitServerId = const Value.absent(),
    this.unitClientUuid = const Value.absent(),
    this.unitShortName = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.salePrice = const Value.absent(),
    this.wholesalePrice = const Value.absent(),
    this.alertQty = const Value.absent(),
    this.trackStock = const Value.absent(),
    this.isActive = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ProductRowsCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    required String clientUuid,
    this.code = const Value.absent(),
    this.barcode = const Value.absent(),
    required String nameEn,
    this.nameUr = const Value.absent(),
    this.categoryServerId = const Value.absent(),
    this.categoryClientUuid = const Value.absent(),
    this.brandServerId = const Value.absent(),
    this.brandClientUuid = const Value.absent(),
    this.unitServerId = const Value.absent(),
    this.unitClientUuid = const Value.absent(),
    this.unitShortName = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.salePrice = const Value.absent(),
    this.wholesalePrice = const Value.absent(),
    this.alertQty = const Value.absent(),
    this.trackStock = const Value.absent(),
    this.isActive = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : clientUuid = Value(clientUuid),
       nameEn = Value(nameEn);
  static Insertable<ProductRow> custom({
    Expression<int>? id,
    Expression<int>? serverId,
    Expression<String>? clientUuid,
    Expression<String>? code,
    Expression<String>? barcode,
    Expression<String>? nameEn,
    Expression<String>? nameUr,
    Expression<int>? categoryServerId,
    Expression<String>? categoryClientUuid,
    Expression<int>? brandServerId,
    Expression<String>? brandClientUuid,
    Expression<int>? unitServerId,
    Expression<String>? unitClientUuid,
    Expression<String>? unitShortName,
    Expression<String>? purchasePrice,
    Expression<String>? salePrice,
    Expression<String>? wholesalePrice,
    Expression<String>? alertQty,
    Expression<bool>? trackStock,
    Expression<bool>? isActive,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (clientUuid != null) 'client_uuid': clientUuid,
      if (code != null) 'code': code,
      if (barcode != null) 'barcode': barcode,
      if (nameEn != null) 'name_en': nameEn,
      if (nameUr != null) 'name_ur': nameUr,
      if (categoryServerId != null) 'category_server_id': categoryServerId,
      if (categoryClientUuid != null)
        'category_client_uuid': categoryClientUuid,
      if (brandServerId != null) 'brand_server_id': brandServerId,
      if (brandClientUuid != null) 'brand_client_uuid': brandClientUuid,
      if (unitServerId != null) 'unit_server_id': unitServerId,
      if (unitClientUuid != null) 'unit_client_uuid': unitClientUuid,
      if (unitShortName != null) 'unit_short_name': unitShortName,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (salePrice != null) 'sale_price': salePrice,
      if (wholesalePrice != null) 'wholesale_price': wholesalePrice,
      if (alertQty != null) 'alert_qty': alertQty,
      if (trackStock != null) 'track_stock': trackStock,
      if (isActive != null) 'is_active': isActive,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ProductRowsCompanion copyWith({
    Value<int>? id,
    Value<int?>? serverId,
    Value<String>? clientUuid,
    Value<String>? code,
    Value<String?>? barcode,
    Value<String>? nameEn,
    Value<String>? nameUr,
    Value<int?>? categoryServerId,
    Value<String?>? categoryClientUuid,
    Value<int?>? brandServerId,
    Value<String?>? brandClientUuid,
    Value<int?>? unitServerId,
    Value<String?>? unitClientUuid,
    Value<String>? unitShortName,
    Value<String>? purchasePrice,
    Value<String>? salePrice,
    Value<String>? wholesalePrice,
    Value<String>? alertQty,
    Value<bool>? trackStock,
    Value<bool>? isActive,
    Value<String?>? updatedAt,
  }) {
    return ProductRowsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      clientUuid: clientUuid ?? this.clientUuid,
      code: code ?? this.code,
      barcode: barcode ?? this.barcode,
      nameEn: nameEn ?? this.nameEn,
      nameUr: nameUr ?? this.nameUr,
      categoryServerId: categoryServerId ?? this.categoryServerId,
      categoryClientUuid: categoryClientUuid ?? this.categoryClientUuid,
      brandServerId: brandServerId ?? this.brandServerId,
      brandClientUuid: brandClientUuid ?? this.brandClientUuid,
      unitServerId: unitServerId ?? this.unitServerId,
      unitClientUuid: unitClientUuid ?? this.unitClientUuid,
      unitShortName: unitShortName ?? this.unitShortName,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      alertQty: alertQty ?? this.alertQty,
      trackStock: trackStock ?? this.trackStock,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (clientUuid.present) {
      map['client_uuid'] = Variable<String>(clientUuid.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (nameUr.present) {
      map['name_ur'] = Variable<String>(nameUr.value);
    }
    if (categoryServerId.present) {
      map['category_server_id'] = Variable<int>(categoryServerId.value);
    }
    if (categoryClientUuid.present) {
      map['category_client_uuid'] = Variable<String>(categoryClientUuid.value);
    }
    if (brandServerId.present) {
      map['brand_server_id'] = Variable<int>(brandServerId.value);
    }
    if (brandClientUuid.present) {
      map['brand_client_uuid'] = Variable<String>(brandClientUuid.value);
    }
    if (unitServerId.present) {
      map['unit_server_id'] = Variable<int>(unitServerId.value);
    }
    if (unitClientUuid.present) {
      map['unit_client_uuid'] = Variable<String>(unitClientUuid.value);
    }
    if (unitShortName.present) {
      map['unit_short_name'] = Variable<String>(unitShortName.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<String>(purchasePrice.value);
    }
    if (salePrice.present) {
      map['sale_price'] = Variable<String>(salePrice.value);
    }
    if (wholesalePrice.present) {
      map['wholesale_price'] = Variable<String>(wholesalePrice.value);
    }
    if (alertQty.present) {
      map['alert_qty'] = Variable<String>(alertQty.value);
    }
    if (trackStock.present) {
      map['track_stock'] = Variable<bool>(trackStock.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductRowsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('code: $code, ')
          ..write('barcode: $barcode, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameUr: $nameUr, ')
          ..write('categoryServerId: $categoryServerId, ')
          ..write('categoryClientUuid: $categoryClientUuid, ')
          ..write('brandServerId: $brandServerId, ')
          ..write('brandClientUuid: $brandClientUuid, ')
          ..write('unitServerId: $unitServerId, ')
          ..write('unitClientUuid: $unitClientUuid, ')
          ..write('unitShortName: $unitShortName, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('salePrice: $salePrice, ')
          ..write('wholesalePrice: $wholesalePrice, ')
          ..write('alertQty: $alertQty, ')
          ..write('trackStock: $trackStock, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $BranchRowsTable extends BranchRows
    with TableInfo<$BranchRowsTable, BranchRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BranchRowsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _clientUuidMeta = const VerificationMeta(
    'clientUuid',
  );
  @override
  late final GeneratedColumn<String> clientUuid = GeneratedColumn<String>(
    'client_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isMainMeta = const VerificationMeta('isMain');
  @override
  late final GeneratedColumn<bool> isMain = GeneratedColumn<bool>(
    'is_main',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_main" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serverId,
    clientUuid,
    name,
    code,
    isMain,
    isActive,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'branch_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<BranchRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('client_uuid')) {
      context.handle(
        _clientUuidMeta,
        clientUuid.isAcceptableOrUnknown(data['client_uuid']!, _clientUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_clientUuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('is_main')) {
      context.handle(
        _isMainMeta,
        isMain.isAcceptableOrUnknown(data['is_main']!, _isMainMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BranchRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BranchRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      clientUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_uuid'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      isMain: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_main'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $BranchRowsTable createAlias(String alias) {
    return $BranchRowsTable(attachedDatabase, alias);
  }
}

class BranchRow extends DataClass implements Insertable<BranchRow> {
  final int id;
  final int? serverId;
  final String clientUuid;
  final String name;
  final String? code;
  final bool isMain;
  final bool isActive;
  final String? updatedAt;
  const BranchRow({
    required this.id,
    this.serverId,
    required this.clientUuid,
    required this.name,
    this.code,
    required this.isMain,
    required this.isActive,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['client_uuid'] = Variable<String>(clientUuid);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    map['is_main'] = Variable<bool>(isMain);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  BranchRowsCompanion toCompanion(bool nullToAbsent) {
    return BranchRowsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      clientUuid: Value(clientUuid),
      name: Value(name),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      isMain: Value(isMain),
      isActive: Value(isActive),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory BranchRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BranchRow(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      clientUuid: serializer.fromJson<String>(json['clientUuid']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String?>(json['code']),
      isMain: serializer.fromJson<bool>(json['isMain']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<int?>(serverId),
      'clientUuid': serializer.toJson<String>(clientUuid),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String?>(code),
      'isMain': serializer.toJson<bool>(isMain),
      'isActive': serializer.toJson<bool>(isActive),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  BranchRow copyWith({
    int? id,
    Value<int?> serverId = const Value.absent(),
    String? clientUuid,
    String? name,
    Value<String?> code = const Value.absent(),
    bool? isMain,
    bool? isActive,
    Value<String?> updatedAt = const Value.absent(),
  }) => BranchRow(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    clientUuid: clientUuid ?? this.clientUuid,
    name: name ?? this.name,
    code: code.present ? code.value : this.code,
    isMain: isMain ?? this.isMain,
    isActive: isActive ?? this.isActive,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  BranchRow copyWithCompanion(BranchRowsCompanion data) {
    return BranchRow(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      clientUuid: data.clientUuid.present
          ? data.clientUuid.value
          : this.clientUuid,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
      isMain: data.isMain.present ? data.isMain.value : this.isMain,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BranchRow(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('isMain: $isMain, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    clientUuid,
    name,
    code,
    isMain,
    isActive,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BranchRow &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.clientUuid == this.clientUuid &&
          other.name == this.name &&
          other.code == this.code &&
          other.isMain == this.isMain &&
          other.isActive == this.isActive &&
          other.updatedAt == this.updatedAt);
}

class BranchRowsCompanion extends UpdateCompanion<BranchRow> {
  final Value<int> id;
  final Value<int?> serverId;
  final Value<String> clientUuid;
  final Value<String> name;
  final Value<String?> code;
  final Value<bool> isMain;
  final Value<bool> isActive;
  final Value<String?> updatedAt;
  const BranchRowsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientUuid = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
    this.isMain = const Value.absent(),
    this.isActive = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BranchRowsCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    required String clientUuid,
    required String name,
    this.code = const Value.absent(),
    this.isMain = const Value.absent(),
    this.isActive = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : clientUuid = Value(clientUuid),
       name = Value(name);
  static Insertable<BranchRow> custom({
    Expression<int>? id,
    Expression<int>? serverId,
    Expression<String>? clientUuid,
    Expression<String>? name,
    Expression<String>? code,
    Expression<bool>? isMain,
    Expression<bool>? isActive,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (clientUuid != null) 'client_uuid': clientUuid,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (isMain != null) 'is_main': isMain,
      if (isActive != null) 'is_active': isActive,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BranchRowsCompanion copyWith({
    Value<int>? id,
    Value<int?>? serverId,
    Value<String>? clientUuid,
    Value<String>? name,
    Value<String?>? code,
    Value<bool>? isMain,
    Value<bool>? isActive,
    Value<String?>? updatedAt,
  }) {
    return BranchRowsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      clientUuid: clientUuid ?? this.clientUuid,
      name: name ?? this.name,
      code: code ?? this.code,
      isMain: isMain ?? this.isMain,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (clientUuid.present) {
      map['client_uuid'] = Variable<String>(clientUuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (isMain.present) {
      map['is_main'] = Variable<bool>(isMain.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BranchRowsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('isMain: $isMain, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $LocationRowsTable extends LocationRows
    with TableInfo<$LocationRowsTable, LocationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationRowsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _clientUuidMeta = const VerificationMeta(
    'clientUuid',
  );
  @override
  late final GeneratedColumn<String> clientUuid = GeneratedColumn<String>(
    'client_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _branchServerIdMeta = const VerificationMeta(
    'branchServerId',
  );
  @override
  late final GeneratedColumn<int> branchServerId = GeneratedColumn<int>(
    'branch_server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _branchClientUuidMeta = const VerificationMeta(
    'branchClientUuid',
  );
  @override
  late final GeneratedColumn<String> branchClientUuid = GeneratedColumn<String>(
    'branch_client_uuid',
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
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serverId,
    clientUuid,
    branchServerId,
    branchClientUuid,
    name,
    isDefault,
    isActive,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'location_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('client_uuid')) {
      context.handle(
        _clientUuidMeta,
        clientUuid.isAcceptableOrUnknown(data['client_uuid']!, _clientUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_clientUuidMeta);
    }
    if (data.containsKey('branch_server_id')) {
      context.handle(
        _branchServerIdMeta,
        branchServerId.isAcceptableOrUnknown(
          data['branch_server_id']!,
          _branchServerIdMeta,
        ),
      );
    }
    if (data.containsKey('branch_client_uuid')) {
      context.handle(
        _branchClientUuidMeta,
        branchClientUuid.isAcceptableOrUnknown(
          data['branch_client_uuid']!,
          _branchClientUuidMeta,
        ),
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
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      clientUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_uuid'],
      )!,
      branchServerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}branch_server_id'],
      ),
      branchClientUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch_client_uuid'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $LocationRowsTable createAlias(String alias) {
    return $LocationRowsTable(attachedDatabase, alias);
  }
}

class LocationRow extends DataClass implements Insertable<LocationRow> {
  final int id;
  final int? serverId;
  final String clientUuid;
  final int? branchServerId;
  final String? branchClientUuid;
  final String name;
  final bool isDefault;
  final bool isActive;
  final String? updatedAt;
  const LocationRow({
    required this.id,
    this.serverId,
    required this.clientUuid,
    this.branchServerId,
    this.branchClientUuid,
    required this.name,
    required this.isDefault,
    required this.isActive,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['client_uuid'] = Variable<String>(clientUuid);
    if (!nullToAbsent || branchServerId != null) {
      map['branch_server_id'] = Variable<int>(branchServerId);
    }
    if (!nullToAbsent || branchClientUuid != null) {
      map['branch_client_uuid'] = Variable<String>(branchClientUuid);
    }
    map['name'] = Variable<String>(name);
    map['is_default'] = Variable<bool>(isDefault);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  LocationRowsCompanion toCompanion(bool nullToAbsent) {
    return LocationRowsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      clientUuid: Value(clientUuid),
      branchServerId: branchServerId == null && nullToAbsent
          ? const Value.absent()
          : Value(branchServerId),
      branchClientUuid: branchClientUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(branchClientUuid),
      name: Value(name),
      isDefault: Value(isDefault),
      isActive: Value(isActive),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory LocationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocationRow(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      clientUuid: serializer.fromJson<String>(json['clientUuid']),
      branchServerId: serializer.fromJson<int?>(json['branchServerId']),
      branchClientUuid: serializer.fromJson<String?>(json['branchClientUuid']),
      name: serializer.fromJson<String>(json['name']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<int?>(serverId),
      'clientUuid': serializer.toJson<String>(clientUuid),
      'branchServerId': serializer.toJson<int?>(branchServerId),
      'branchClientUuid': serializer.toJson<String?>(branchClientUuid),
      'name': serializer.toJson<String>(name),
      'isDefault': serializer.toJson<bool>(isDefault),
      'isActive': serializer.toJson<bool>(isActive),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  LocationRow copyWith({
    int? id,
    Value<int?> serverId = const Value.absent(),
    String? clientUuid,
    Value<int?> branchServerId = const Value.absent(),
    Value<String?> branchClientUuid = const Value.absent(),
    String? name,
    bool? isDefault,
    bool? isActive,
    Value<String?> updatedAt = const Value.absent(),
  }) => LocationRow(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    clientUuid: clientUuid ?? this.clientUuid,
    branchServerId: branchServerId.present
        ? branchServerId.value
        : this.branchServerId,
    branchClientUuid: branchClientUuid.present
        ? branchClientUuid.value
        : this.branchClientUuid,
    name: name ?? this.name,
    isDefault: isDefault ?? this.isDefault,
    isActive: isActive ?? this.isActive,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  LocationRow copyWithCompanion(LocationRowsCompanion data) {
    return LocationRow(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      clientUuid: data.clientUuid.present
          ? data.clientUuid.value
          : this.clientUuid,
      branchServerId: data.branchServerId.present
          ? data.branchServerId.value
          : this.branchServerId,
      branchClientUuid: data.branchClientUuid.present
          ? data.branchClientUuid.value
          : this.branchClientUuid,
      name: data.name.present ? data.name.value : this.name,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocationRow(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('branchServerId: $branchServerId, ')
          ..write('branchClientUuid: $branchClientUuid, ')
          ..write('name: $name, ')
          ..write('isDefault: $isDefault, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    clientUuid,
    branchServerId,
    branchClientUuid,
    name,
    isDefault,
    isActive,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocationRow &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.clientUuid == this.clientUuid &&
          other.branchServerId == this.branchServerId &&
          other.branchClientUuid == this.branchClientUuid &&
          other.name == this.name &&
          other.isDefault == this.isDefault &&
          other.isActive == this.isActive &&
          other.updatedAt == this.updatedAt);
}

class LocationRowsCompanion extends UpdateCompanion<LocationRow> {
  final Value<int> id;
  final Value<int?> serverId;
  final Value<String> clientUuid;
  final Value<int?> branchServerId;
  final Value<String?> branchClientUuid;
  final Value<String> name;
  final Value<bool> isDefault;
  final Value<bool> isActive;
  final Value<String?> updatedAt;
  const LocationRowsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientUuid = const Value.absent(),
    this.branchServerId = const Value.absent(),
    this.branchClientUuid = const Value.absent(),
    this.name = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isActive = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LocationRowsCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    required String clientUuid,
    this.branchServerId = const Value.absent(),
    this.branchClientUuid = const Value.absent(),
    required String name,
    this.isDefault = const Value.absent(),
    this.isActive = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : clientUuid = Value(clientUuid),
       name = Value(name);
  static Insertable<LocationRow> custom({
    Expression<int>? id,
    Expression<int>? serverId,
    Expression<String>? clientUuid,
    Expression<int>? branchServerId,
    Expression<String>? branchClientUuid,
    Expression<String>? name,
    Expression<bool>? isDefault,
    Expression<bool>? isActive,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (clientUuid != null) 'client_uuid': clientUuid,
      if (branchServerId != null) 'branch_server_id': branchServerId,
      if (branchClientUuid != null) 'branch_client_uuid': branchClientUuid,
      if (name != null) 'name': name,
      if (isDefault != null) 'is_default': isDefault,
      if (isActive != null) 'is_active': isActive,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LocationRowsCompanion copyWith({
    Value<int>? id,
    Value<int?>? serverId,
    Value<String>? clientUuid,
    Value<int?>? branchServerId,
    Value<String?>? branchClientUuid,
    Value<String>? name,
    Value<bool>? isDefault,
    Value<bool>? isActive,
    Value<String?>? updatedAt,
  }) {
    return LocationRowsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      clientUuid: clientUuid ?? this.clientUuid,
      branchServerId: branchServerId ?? this.branchServerId,
      branchClientUuid: branchClientUuid ?? this.branchClientUuid,
      name: name ?? this.name,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (clientUuid.present) {
      map['client_uuid'] = Variable<String>(clientUuid.value);
    }
    if (branchServerId.present) {
      map['branch_server_id'] = Variable<int>(branchServerId.value);
    }
    if (branchClientUuid.present) {
      map['branch_client_uuid'] = Variable<String>(branchClientUuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationRowsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('branchServerId: $branchServerId, ')
          ..write('branchClientUuid: $branchClientUuid, ')
          ..write('name: $name, ')
          ..write('isDefault: $isDefault, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $DocumentRowsTable extends DocumentRows
    with TableInfo<$DocumentRowsTable, DocumentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentRowsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientUuidMeta = const VerificationMeta(
    'clientUuid',
  );
  @override
  late final GeneratedColumn<String> clientUuid = GeneratedColumn<String>(
    'client_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pendingMeta = const VerificationMeta(
    'pending',
  );
  @override
  late final GeneratedColumn<bool> pending = GeneratedColumn<bool>(
    'pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serverId,
    entity,
    clientUuid,
    payload,
    pending,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'document_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('client_uuid')) {
      context.handle(
        _clientUuidMeta,
        clientUuid.isAcceptableOrUnknown(data['client_uuid']!, _clientUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_clientUuidMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('pending')) {
      context.handle(
        _pendingMeta,
        pending.isAcceptableOrUnknown(data['pending']!, _pendingMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {entity, clientUuid},
  ];
  @override
  DocumentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      clientUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_uuid'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      pending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $DocumentRowsTable createAlias(String alias) {
    return $DocumentRowsTable(attachedDatabase, alias);
  }
}

class DocumentRow extends DataClass implements Insertable<DocumentRow> {
  final int id;
  final int? serverId;
  final String entity;
  final String clientUuid;
  final String payload;
  final bool pending;
  final String? updatedAt;
  const DocumentRow({
    required this.id,
    this.serverId,
    required this.entity,
    required this.clientUuid,
    required this.payload,
    required this.pending,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['entity'] = Variable<String>(entity);
    map['client_uuid'] = Variable<String>(clientUuid);
    map['payload'] = Variable<String>(payload);
    map['pending'] = Variable<bool>(pending);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  DocumentRowsCompanion toCompanion(bool nullToAbsent) {
    return DocumentRowsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      entity: Value(entity),
      clientUuid: Value(clientUuid),
      payload: Value(payload),
      pending: Value(pending),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory DocumentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentRow(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      entity: serializer.fromJson<String>(json['entity']),
      clientUuid: serializer.fromJson<String>(json['clientUuid']),
      payload: serializer.fromJson<String>(json['payload']),
      pending: serializer.fromJson<bool>(json['pending']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<int?>(serverId),
      'entity': serializer.toJson<String>(entity),
      'clientUuid': serializer.toJson<String>(clientUuid),
      'payload': serializer.toJson<String>(payload),
      'pending': serializer.toJson<bool>(pending),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  DocumentRow copyWith({
    int? id,
    Value<int?> serverId = const Value.absent(),
    String? entity,
    String? clientUuid,
    String? payload,
    bool? pending,
    Value<String?> updatedAt = const Value.absent(),
  }) => DocumentRow(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    entity: entity ?? this.entity,
    clientUuid: clientUuid ?? this.clientUuid,
    payload: payload ?? this.payload,
    pending: pending ?? this.pending,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  DocumentRow copyWithCompanion(DocumentRowsCompanion data) {
    return DocumentRow(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      entity: data.entity.present ? data.entity.value : this.entity,
      clientUuid: data.clientUuid.present
          ? data.clientUuid.value
          : this.clientUuid,
      payload: data.payload.present ? data.payload.value : this.payload,
      pending: data.pending.present ? data.pending.value : this.pending,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentRow(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('entity: $entity, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('payload: $payload, ')
          ..write('pending: $pending, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    entity,
    clientUuid,
    payload,
    pending,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentRow &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.entity == this.entity &&
          other.clientUuid == this.clientUuid &&
          other.payload == this.payload &&
          other.pending == this.pending &&
          other.updatedAt == this.updatedAt);
}

class DocumentRowsCompanion extends UpdateCompanion<DocumentRow> {
  final Value<int> id;
  final Value<int?> serverId;
  final Value<String> entity;
  final Value<String> clientUuid;
  final Value<String> payload;
  final Value<bool> pending;
  final Value<String?> updatedAt;
  const DocumentRowsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.entity = const Value.absent(),
    this.clientUuid = const Value.absent(),
    this.payload = const Value.absent(),
    this.pending = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DocumentRowsCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    required String entity,
    required String clientUuid,
    required String payload,
    this.pending = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : entity = Value(entity),
       clientUuid = Value(clientUuid),
       payload = Value(payload);
  static Insertable<DocumentRow> custom({
    Expression<int>? id,
    Expression<int>? serverId,
    Expression<String>? entity,
    Expression<String>? clientUuid,
    Expression<String>? payload,
    Expression<bool>? pending,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (entity != null) 'entity': entity,
      if (clientUuid != null) 'client_uuid': clientUuid,
      if (payload != null) 'payload': payload,
      if (pending != null) 'pending': pending,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DocumentRowsCompanion copyWith({
    Value<int>? id,
    Value<int?>? serverId,
    Value<String>? entity,
    Value<String>? clientUuid,
    Value<String>? payload,
    Value<bool>? pending,
    Value<String?>? updatedAt,
  }) {
    return DocumentRowsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      entity: entity ?? this.entity,
      clientUuid: clientUuid ?? this.clientUuid,
      payload: payload ?? this.payload,
      pending: pending ?? this.pending,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (clientUuid.present) {
      map['client_uuid'] = Variable<String>(clientUuid.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (pending.present) {
      map['pending'] = Variable<bool>(pending.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentRowsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('entity: $entity, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('payload: $payload, ')
          ..write('pending: $pending, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $EventRowsTable extends EventRows
    with TableInfo<$EventRowsTable, EventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventRowsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clientUuidMeta = const VerificationMeta(
    'clientUuid',
  );
  @override
  late final GeneratedColumn<String> clientUuid = GeneratedColumn<String>(
    'client_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _branchServerIdMeta = const VerificationMeta(
    'branchServerId',
  );
  @override
  late final GeneratedColumn<int> branchServerId = GeneratedColumn<int>(
    'branch_server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _branchClientUuidMeta = const VerificationMeta(
    'branchClientUuid',
  );
  @override
  late final GeneratedColumn<String> branchClientUuid = GeneratedColumn<String>(
    'branch_client_uuid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _branchNameMeta = const VerificationMeta(
    'branchName',
  );
  @override
  late final GeneratedColumn<String> branchName = GeneratedColumn<String>(
    'branch_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _productServerIdMeta = const VerificationMeta(
    'productServerId',
  );
  @override
  late final GeneratedColumn<int> productServerId = GeneratedColumn<int>(
    'product_server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productClientUuidMeta = const VerificationMeta(
    'productClientUuid',
  );
  @override
  late final GeneratedColumn<String> productClientUuid =
      GeneratedColumn<String>(
        'product_client_uuid',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _productCodeMeta = const VerificationMeta(
    'productCode',
  );
  @override
  late final GeneratedColumn<String> productCode = GeneratedColumn<String>(
    'product_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<String> qty = GeneratedColumn<String>(
    'qty',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitCostMeta = const VerificationMeta(
    'unitCost',
  );
  @override
  late final GeneratedColumn<String> unitCost = GeneratedColumn<String>(
    'unit_cost',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0.0000'),
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0.00'),
  );
  static const VerificationMeta _runningBalanceMeta = const VerificationMeta(
    'runningBalance',
  );
  @override
  late final GeneratedColumn<String> runningBalance = GeneratedColumn<String>(
    'running_balance',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0.000'),
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
  static const VerificationMeta _sourceUuidMeta = const VerificationMeta(
    'sourceUuid',
  );
  @override
  late final GeneratedColumn<String> sourceUuid = GeneratedColumn<String>(
    'source_uuid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _operatorNameMeta = const VerificationMeta(
    'operatorName',
  );
  @override
  late final GeneratedColumn<String> operatorName = GeneratedColumn<String>(
    'operator_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<String> occurredAt = GeneratedColumn<String>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _locationServerIdMeta = const VerificationMeta(
    'locationServerId',
  );
  @override
  late final GeneratedColumn<int> locationServerId = GeneratedColumn<int>(
    'location_server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationNameMeta = const VerificationMeta(
    'locationName',
  );
  @override
  late final GeneratedColumn<String> locationName = GeneratedColumn<String>(
    'location_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fromLocationNameMeta = const VerificationMeta(
    'fromLocationName',
  );
  @override
  late final GeneratedColumn<String> fromLocationName = GeneratedColumn<String>(
    'from_location_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toLocationNameMeta = const VerificationMeta(
    'toLocationName',
  );
  @override
  late final GeneratedColumn<String> toLocationName = GeneratedColumn<String>(
    'to_location_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serverId,
    clientUuid,
    branchServerId,
    branchClientUuid,
    branchName,
    productServerId,
    productClientUuid,
    productName,
    productCode,
    eventType,
    qty,
    unitCost,
    value,
    runningBalance,
    sourceType,
    sourceUuid,
    reason,
    operatorName,
    occurredAt,
    syncStatus,
    locationServerId,
    locationName,
    fromLocationName,
    toLocationName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'event_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('client_uuid')) {
      context.handle(
        _clientUuidMeta,
        clientUuid.isAcceptableOrUnknown(data['client_uuid']!, _clientUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_clientUuidMeta);
    }
    if (data.containsKey('branch_server_id')) {
      context.handle(
        _branchServerIdMeta,
        branchServerId.isAcceptableOrUnknown(
          data['branch_server_id']!,
          _branchServerIdMeta,
        ),
      );
    }
    if (data.containsKey('branch_client_uuid')) {
      context.handle(
        _branchClientUuidMeta,
        branchClientUuid.isAcceptableOrUnknown(
          data['branch_client_uuid']!,
          _branchClientUuidMeta,
        ),
      );
    }
    if (data.containsKey('branch_name')) {
      context.handle(
        _branchNameMeta,
        branchName.isAcceptableOrUnknown(data['branch_name']!, _branchNameMeta),
      );
    }
    if (data.containsKey('product_server_id')) {
      context.handle(
        _productServerIdMeta,
        productServerId.isAcceptableOrUnknown(
          data['product_server_id']!,
          _productServerIdMeta,
        ),
      );
    }
    if (data.containsKey('product_client_uuid')) {
      context.handle(
        _productClientUuidMeta,
        productClientUuid.isAcceptableOrUnknown(
          data['product_client_uuid']!,
          _productClientUuidMeta,
        ),
      );
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    }
    if (data.containsKey('product_code')) {
      context.handle(
        _productCodeMeta,
        productCode.isAcceptableOrUnknown(
          data['product_code']!,
          _productCodeMeta,
        ),
      );
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('qty')) {
      context.handle(
        _qtyMeta,
        qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyMeta);
    }
    if (data.containsKey('unit_cost')) {
      context.handle(
        _unitCostMeta,
        unitCost.isAcceptableOrUnknown(data['unit_cost']!, _unitCostMeta),
      );
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    if (data.containsKey('running_balance')) {
      context.handle(
        _runningBalanceMeta,
        runningBalance.isAcceptableOrUnknown(
          data['running_balance']!,
          _runningBalanceMeta,
        ),
      );
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    }
    if (data.containsKey('source_uuid')) {
      context.handle(
        _sourceUuidMeta,
        sourceUuid.isAcceptableOrUnknown(data['source_uuid']!, _sourceUuidMeta),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('operator_name')) {
      context.handle(
        _operatorNameMeta,
        operatorName.isAcceptableOrUnknown(
          data['operator_name']!,
          _operatorNameMeta,
        ),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('location_server_id')) {
      context.handle(
        _locationServerIdMeta,
        locationServerId.isAcceptableOrUnknown(
          data['location_server_id']!,
          _locationServerIdMeta,
        ),
      );
    }
    if (data.containsKey('location_name')) {
      context.handle(
        _locationNameMeta,
        locationName.isAcceptableOrUnknown(
          data['location_name']!,
          _locationNameMeta,
        ),
      );
    }
    if (data.containsKey('from_location_name')) {
      context.handle(
        _fromLocationNameMeta,
        fromLocationName.isAcceptableOrUnknown(
          data['from_location_name']!,
          _fromLocationNameMeta,
        ),
      );
    }
    if (data.containsKey('to_location_name')) {
      context.handle(
        _toLocationNameMeta,
        toLocationName.isAcceptableOrUnknown(
          data['to_location_name']!,
          _toLocationNameMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      clientUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_uuid'],
      )!,
      branchServerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}branch_server_id'],
      ),
      branchClientUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch_client_uuid'],
      ),
      branchName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch_name'],
      )!,
      productServerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_server_id'],
      ),
      productClientUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_client_uuid'],
      ),
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      productCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_code'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      qty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}qty'],
      )!,
      unitCost: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_cost'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      runningBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}running_balance'],
      )!,
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      ),
      sourceUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_uuid'],
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      operatorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operator_name'],
      ),
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occurred_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      locationServerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}location_server_id'],
      ),
      locationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_name'],
      ),
      fromLocationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_location_name'],
      ),
      toLocationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_location_name'],
      ),
    );
  }

  @override
  $EventRowsTable createAlias(String alias) {
    return $EventRowsTable(attachedDatabase, alias);
  }
}

class EventRow extends DataClass implements Insertable<EventRow> {
  final int id;
  final int? serverId;
  final String clientUuid;
  final int? branchServerId;
  final String? branchClientUuid;
  final String branchName;
  final int? productServerId;
  final String? productClientUuid;
  final String productName;
  final String productCode;
  final String eventType;
  final String qty;
  final String unitCost;
  final String value;
  final String runningBalance;
  final String? sourceType;
  final String? sourceUuid;
  final String? reason;
  final String? operatorName;
  final String occurredAt;
  final String syncStatus;
  final int? locationServerId;
  final String? locationName;
  final String? fromLocationName;
  final String? toLocationName;
  const EventRow({
    required this.id,
    this.serverId,
    required this.clientUuid,
    this.branchServerId,
    this.branchClientUuid,
    required this.branchName,
    this.productServerId,
    this.productClientUuid,
    required this.productName,
    required this.productCode,
    required this.eventType,
    required this.qty,
    required this.unitCost,
    required this.value,
    required this.runningBalance,
    this.sourceType,
    this.sourceUuid,
    this.reason,
    this.operatorName,
    required this.occurredAt,
    required this.syncStatus,
    this.locationServerId,
    this.locationName,
    this.fromLocationName,
    this.toLocationName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['client_uuid'] = Variable<String>(clientUuid);
    if (!nullToAbsent || branchServerId != null) {
      map['branch_server_id'] = Variable<int>(branchServerId);
    }
    if (!nullToAbsent || branchClientUuid != null) {
      map['branch_client_uuid'] = Variable<String>(branchClientUuid);
    }
    map['branch_name'] = Variable<String>(branchName);
    if (!nullToAbsent || productServerId != null) {
      map['product_server_id'] = Variable<int>(productServerId);
    }
    if (!nullToAbsent || productClientUuid != null) {
      map['product_client_uuid'] = Variable<String>(productClientUuid);
    }
    map['product_name'] = Variable<String>(productName);
    map['product_code'] = Variable<String>(productCode);
    map['event_type'] = Variable<String>(eventType);
    map['qty'] = Variable<String>(qty);
    map['unit_cost'] = Variable<String>(unitCost);
    map['value'] = Variable<String>(value);
    map['running_balance'] = Variable<String>(runningBalance);
    if (!nullToAbsent || sourceType != null) {
      map['source_type'] = Variable<String>(sourceType);
    }
    if (!nullToAbsent || sourceUuid != null) {
      map['source_uuid'] = Variable<String>(sourceUuid);
    }
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    if (!nullToAbsent || operatorName != null) {
      map['operator_name'] = Variable<String>(operatorName);
    }
    map['occurred_at'] = Variable<String>(occurredAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || locationServerId != null) {
      map['location_server_id'] = Variable<int>(locationServerId);
    }
    if (!nullToAbsent || locationName != null) {
      map['location_name'] = Variable<String>(locationName);
    }
    if (!nullToAbsent || fromLocationName != null) {
      map['from_location_name'] = Variable<String>(fromLocationName);
    }
    if (!nullToAbsent || toLocationName != null) {
      map['to_location_name'] = Variable<String>(toLocationName);
    }
    return map;
  }

  EventRowsCompanion toCompanion(bool nullToAbsent) {
    return EventRowsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      clientUuid: Value(clientUuid),
      branchServerId: branchServerId == null && nullToAbsent
          ? const Value.absent()
          : Value(branchServerId),
      branchClientUuid: branchClientUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(branchClientUuid),
      branchName: Value(branchName),
      productServerId: productServerId == null && nullToAbsent
          ? const Value.absent()
          : Value(productServerId),
      productClientUuid: productClientUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(productClientUuid),
      productName: Value(productName),
      productCode: Value(productCode),
      eventType: Value(eventType),
      qty: Value(qty),
      unitCost: Value(unitCost),
      value: Value(value),
      runningBalance: Value(runningBalance),
      sourceType: sourceType == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceType),
      sourceUuid: sourceUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUuid),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      operatorName: operatorName == null && nullToAbsent
          ? const Value.absent()
          : Value(operatorName),
      occurredAt: Value(occurredAt),
      syncStatus: Value(syncStatus),
      locationServerId: locationServerId == null && nullToAbsent
          ? const Value.absent()
          : Value(locationServerId),
      locationName: locationName == null && nullToAbsent
          ? const Value.absent()
          : Value(locationName),
      fromLocationName: fromLocationName == null && nullToAbsent
          ? const Value.absent()
          : Value(fromLocationName),
      toLocationName: toLocationName == null && nullToAbsent
          ? const Value.absent()
          : Value(toLocationName),
    );
  }

  factory EventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventRow(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      clientUuid: serializer.fromJson<String>(json['clientUuid']),
      branchServerId: serializer.fromJson<int?>(json['branchServerId']),
      branchClientUuid: serializer.fromJson<String?>(json['branchClientUuid']),
      branchName: serializer.fromJson<String>(json['branchName']),
      productServerId: serializer.fromJson<int?>(json['productServerId']),
      productClientUuid: serializer.fromJson<String?>(
        json['productClientUuid'],
      ),
      productName: serializer.fromJson<String>(json['productName']),
      productCode: serializer.fromJson<String>(json['productCode']),
      eventType: serializer.fromJson<String>(json['eventType']),
      qty: serializer.fromJson<String>(json['qty']),
      unitCost: serializer.fromJson<String>(json['unitCost']),
      value: serializer.fromJson<String>(json['value']),
      runningBalance: serializer.fromJson<String>(json['runningBalance']),
      sourceType: serializer.fromJson<String?>(json['sourceType']),
      sourceUuid: serializer.fromJson<String?>(json['sourceUuid']),
      reason: serializer.fromJson<String?>(json['reason']),
      operatorName: serializer.fromJson<String?>(json['operatorName']),
      occurredAt: serializer.fromJson<String>(json['occurredAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      locationServerId: serializer.fromJson<int?>(json['locationServerId']),
      locationName: serializer.fromJson<String?>(json['locationName']),
      fromLocationName: serializer.fromJson<String?>(json['fromLocationName']),
      toLocationName: serializer.fromJson<String?>(json['toLocationName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<int?>(serverId),
      'clientUuid': serializer.toJson<String>(clientUuid),
      'branchServerId': serializer.toJson<int?>(branchServerId),
      'branchClientUuid': serializer.toJson<String?>(branchClientUuid),
      'branchName': serializer.toJson<String>(branchName),
      'productServerId': serializer.toJson<int?>(productServerId),
      'productClientUuid': serializer.toJson<String?>(productClientUuid),
      'productName': serializer.toJson<String>(productName),
      'productCode': serializer.toJson<String>(productCode),
      'eventType': serializer.toJson<String>(eventType),
      'qty': serializer.toJson<String>(qty),
      'unitCost': serializer.toJson<String>(unitCost),
      'value': serializer.toJson<String>(value),
      'runningBalance': serializer.toJson<String>(runningBalance),
      'sourceType': serializer.toJson<String?>(sourceType),
      'sourceUuid': serializer.toJson<String?>(sourceUuid),
      'reason': serializer.toJson<String?>(reason),
      'operatorName': serializer.toJson<String?>(operatorName),
      'occurredAt': serializer.toJson<String>(occurredAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'locationServerId': serializer.toJson<int?>(locationServerId),
      'locationName': serializer.toJson<String?>(locationName),
      'fromLocationName': serializer.toJson<String?>(fromLocationName),
      'toLocationName': serializer.toJson<String?>(toLocationName),
    };
  }

  EventRow copyWith({
    int? id,
    Value<int?> serverId = const Value.absent(),
    String? clientUuid,
    Value<int?> branchServerId = const Value.absent(),
    Value<String?> branchClientUuid = const Value.absent(),
    String? branchName,
    Value<int?> productServerId = const Value.absent(),
    Value<String?> productClientUuid = const Value.absent(),
    String? productName,
    String? productCode,
    String? eventType,
    String? qty,
    String? unitCost,
    String? value,
    String? runningBalance,
    Value<String?> sourceType = const Value.absent(),
    Value<String?> sourceUuid = const Value.absent(),
    Value<String?> reason = const Value.absent(),
    Value<String?> operatorName = const Value.absent(),
    String? occurredAt,
    String? syncStatus,
    Value<int?> locationServerId = const Value.absent(),
    Value<String?> locationName = const Value.absent(),
    Value<String?> fromLocationName = const Value.absent(),
    Value<String?> toLocationName = const Value.absent(),
  }) => EventRow(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    clientUuid: clientUuid ?? this.clientUuid,
    branchServerId: branchServerId.present
        ? branchServerId.value
        : this.branchServerId,
    branchClientUuid: branchClientUuid.present
        ? branchClientUuid.value
        : this.branchClientUuid,
    branchName: branchName ?? this.branchName,
    productServerId: productServerId.present
        ? productServerId.value
        : this.productServerId,
    productClientUuid: productClientUuid.present
        ? productClientUuid.value
        : this.productClientUuid,
    productName: productName ?? this.productName,
    productCode: productCode ?? this.productCode,
    eventType: eventType ?? this.eventType,
    qty: qty ?? this.qty,
    unitCost: unitCost ?? this.unitCost,
    value: value ?? this.value,
    runningBalance: runningBalance ?? this.runningBalance,
    sourceType: sourceType.present ? sourceType.value : this.sourceType,
    sourceUuid: sourceUuid.present ? sourceUuid.value : this.sourceUuid,
    reason: reason.present ? reason.value : this.reason,
    operatorName: operatorName.present ? operatorName.value : this.operatorName,
    occurredAt: occurredAt ?? this.occurredAt,
    syncStatus: syncStatus ?? this.syncStatus,
    locationServerId: locationServerId.present
        ? locationServerId.value
        : this.locationServerId,
    locationName: locationName.present ? locationName.value : this.locationName,
    fromLocationName: fromLocationName.present
        ? fromLocationName.value
        : this.fromLocationName,
    toLocationName: toLocationName.present
        ? toLocationName.value
        : this.toLocationName,
  );
  EventRow copyWithCompanion(EventRowsCompanion data) {
    return EventRow(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      clientUuid: data.clientUuid.present
          ? data.clientUuid.value
          : this.clientUuid,
      branchServerId: data.branchServerId.present
          ? data.branchServerId.value
          : this.branchServerId,
      branchClientUuid: data.branchClientUuid.present
          ? data.branchClientUuid.value
          : this.branchClientUuid,
      branchName: data.branchName.present
          ? data.branchName.value
          : this.branchName,
      productServerId: data.productServerId.present
          ? data.productServerId.value
          : this.productServerId,
      productClientUuid: data.productClientUuid.present
          ? data.productClientUuid.value
          : this.productClientUuid,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      productCode: data.productCode.present
          ? data.productCode.value
          : this.productCode,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      qty: data.qty.present ? data.qty.value : this.qty,
      unitCost: data.unitCost.present ? data.unitCost.value : this.unitCost,
      value: data.value.present ? data.value.value : this.value,
      runningBalance: data.runningBalance.present
          ? data.runningBalance.value
          : this.runningBalance,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      sourceUuid: data.sourceUuid.present
          ? data.sourceUuid.value
          : this.sourceUuid,
      reason: data.reason.present ? data.reason.value : this.reason,
      operatorName: data.operatorName.present
          ? data.operatorName.value
          : this.operatorName,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      locationServerId: data.locationServerId.present
          ? data.locationServerId.value
          : this.locationServerId,
      locationName: data.locationName.present
          ? data.locationName.value
          : this.locationName,
      fromLocationName: data.fromLocationName.present
          ? data.fromLocationName.value
          : this.fromLocationName,
      toLocationName: data.toLocationName.present
          ? data.toLocationName.value
          : this.toLocationName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventRow(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('branchServerId: $branchServerId, ')
          ..write('branchClientUuid: $branchClientUuid, ')
          ..write('branchName: $branchName, ')
          ..write('productServerId: $productServerId, ')
          ..write('productClientUuid: $productClientUuid, ')
          ..write('productName: $productName, ')
          ..write('productCode: $productCode, ')
          ..write('eventType: $eventType, ')
          ..write('qty: $qty, ')
          ..write('unitCost: $unitCost, ')
          ..write('value: $value, ')
          ..write('runningBalance: $runningBalance, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceUuid: $sourceUuid, ')
          ..write('reason: $reason, ')
          ..write('operatorName: $operatorName, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('locationServerId: $locationServerId, ')
          ..write('locationName: $locationName, ')
          ..write('fromLocationName: $fromLocationName, ')
          ..write('toLocationName: $toLocationName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    serverId,
    clientUuid,
    branchServerId,
    branchClientUuid,
    branchName,
    productServerId,
    productClientUuid,
    productName,
    productCode,
    eventType,
    qty,
    unitCost,
    value,
    runningBalance,
    sourceType,
    sourceUuid,
    reason,
    operatorName,
    occurredAt,
    syncStatus,
    locationServerId,
    locationName,
    fromLocationName,
    toLocationName,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventRow &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.clientUuid == this.clientUuid &&
          other.branchServerId == this.branchServerId &&
          other.branchClientUuid == this.branchClientUuid &&
          other.branchName == this.branchName &&
          other.productServerId == this.productServerId &&
          other.productClientUuid == this.productClientUuid &&
          other.productName == this.productName &&
          other.productCode == this.productCode &&
          other.eventType == this.eventType &&
          other.qty == this.qty &&
          other.unitCost == this.unitCost &&
          other.value == this.value &&
          other.runningBalance == this.runningBalance &&
          other.sourceType == this.sourceType &&
          other.sourceUuid == this.sourceUuid &&
          other.reason == this.reason &&
          other.operatorName == this.operatorName &&
          other.occurredAt == this.occurredAt &&
          other.syncStatus == this.syncStatus &&
          other.locationServerId == this.locationServerId &&
          other.locationName == this.locationName &&
          other.fromLocationName == this.fromLocationName &&
          other.toLocationName == this.toLocationName);
}

class EventRowsCompanion extends UpdateCompanion<EventRow> {
  final Value<int> id;
  final Value<int?> serverId;
  final Value<String> clientUuid;
  final Value<int?> branchServerId;
  final Value<String?> branchClientUuid;
  final Value<String> branchName;
  final Value<int?> productServerId;
  final Value<String?> productClientUuid;
  final Value<String> productName;
  final Value<String> productCode;
  final Value<String> eventType;
  final Value<String> qty;
  final Value<String> unitCost;
  final Value<String> value;
  final Value<String> runningBalance;
  final Value<String?> sourceType;
  final Value<String?> sourceUuid;
  final Value<String?> reason;
  final Value<String?> operatorName;
  final Value<String> occurredAt;
  final Value<String> syncStatus;
  final Value<int?> locationServerId;
  final Value<String?> locationName;
  final Value<String?> fromLocationName;
  final Value<String?> toLocationName;
  const EventRowsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientUuid = const Value.absent(),
    this.branchServerId = const Value.absent(),
    this.branchClientUuid = const Value.absent(),
    this.branchName = const Value.absent(),
    this.productServerId = const Value.absent(),
    this.productClientUuid = const Value.absent(),
    this.productName = const Value.absent(),
    this.productCode = const Value.absent(),
    this.eventType = const Value.absent(),
    this.qty = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.value = const Value.absent(),
    this.runningBalance = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceUuid = const Value.absent(),
    this.reason = const Value.absent(),
    this.operatorName = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.locationServerId = const Value.absent(),
    this.locationName = const Value.absent(),
    this.fromLocationName = const Value.absent(),
    this.toLocationName = const Value.absent(),
  });
  EventRowsCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    required String clientUuid,
    this.branchServerId = const Value.absent(),
    this.branchClientUuid = const Value.absent(),
    this.branchName = const Value.absent(),
    this.productServerId = const Value.absent(),
    this.productClientUuid = const Value.absent(),
    this.productName = const Value.absent(),
    this.productCode = const Value.absent(),
    required String eventType,
    required String qty,
    this.unitCost = const Value.absent(),
    this.value = const Value.absent(),
    this.runningBalance = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceUuid = const Value.absent(),
    this.reason = const Value.absent(),
    this.operatorName = const Value.absent(),
    required String occurredAt,
    this.syncStatus = const Value.absent(),
    this.locationServerId = const Value.absent(),
    this.locationName = const Value.absent(),
    this.fromLocationName = const Value.absent(),
    this.toLocationName = const Value.absent(),
  }) : clientUuid = Value(clientUuid),
       eventType = Value(eventType),
       qty = Value(qty),
       occurredAt = Value(occurredAt);
  static Insertable<EventRow> custom({
    Expression<int>? id,
    Expression<int>? serverId,
    Expression<String>? clientUuid,
    Expression<int>? branchServerId,
    Expression<String>? branchClientUuid,
    Expression<String>? branchName,
    Expression<int>? productServerId,
    Expression<String>? productClientUuid,
    Expression<String>? productName,
    Expression<String>? productCode,
    Expression<String>? eventType,
    Expression<String>? qty,
    Expression<String>? unitCost,
    Expression<String>? value,
    Expression<String>? runningBalance,
    Expression<String>? sourceType,
    Expression<String>? sourceUuid,
    Expression<String>? reason,
    Expression<String>? operatorName,
    Expression<String>? occurredAt,
    Expression<String>? syncStatus,
    Expression<int>? locationServerId,
    Expression<String>? locationName,
    Expression<String>? fromLocationName,
    Expression<String>? toLocationName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (clientUuid != null) 'client_uuid': clientUuid,
      if (branchServerId != null) 'branch_server_id': branchServerId,
      if (branchClientUuid != null) 'branch_client_uuid': branchClientUuid,
      if (branchName != null) 'branch_name': branchName,
      if (productServerId != null) 'product_server_id': productServerId,
      if (productClientUuid != null) 'product_client_uuid': productClientUuid,
      if (productName != null) 'product_name': productName,
      if (productCode != null) 'product_code': productCode,
      if (eventType != null) 'event_type': eventType,
      if (qty != null) 'qty': qty,
      if (unitCost != null) 'unit_cost': unitCost,
      if (value != null) 'value': value,
      if (runningBalance != null) 'running_balance': runningBalance,
      if (sourceType != null) 'source_type': sourceType,
      if (sourceUuid != null) 'source_uuid': sourceUuid,
      if (reason != null) 'reason': reason,
      if (operatorName != null) 'operator_name': operatorName,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (locationServerId != null) 'location_server_id': locationServerId,
      if (locationName != null) 'location_name': locationName,
      if (fromLocationName != null) 'from_location_name': fromLocationName,
      if (toLocationName != null) 'to_location_name': toLocationName,
    });
  }

  EventRowsCompanion copyWith({
    Value<int>? id,
    Value<int?>? serverId,
    Value<String>? clientUuid,
    Value<int?>? branchServerId,
    Value<String?>? branchClientUuid,
    Value<String>? branchName,
    Value<int?>? productServerId,
    Value<String?>? productClientUuid,
    Value<String>? productName,
    Value<String>? productCode,
    Value<String>? eventType,
    Value<String>? qty,
    Value<String>? unitCost,
    Value<String>? value,
    Value<String>? runningBalance,
    Value<String?>? sourceType,
    Value<String?>? sourceUuid,
    Value<String?>? reason,
    Value<String?>? operatorName,
    Value<String>? occurredAt,
    Value<String>? syncStatus,
    Value<int?>? locationServerId,
    Value<String?>? locationName,
    Value<String?>? fromLocationName,
    Value<String?>? toLocationName,
  }) {
    return EventRowsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      clientUuid: clientUuid ?? this.clientUuid,
      branchServerId: branchServerId ?? this.branchServerId,
      branchClientUuid: branchClientUuid ?? this.branchClientUuid,
      branchName: branchName ?? this.branchName,
      productServerId: productServerId ?? this.productServerId,
      productClientUuid: productClientUuid ?? this.productClientUuid,
      productName: productName ?? this.productName,
      productCode: productCode ?? this.productCode,
      eventType: eventType ?? this.eventType,
      qty: qty ?? this.qty,
      unitCost: unitCost ?? this.unitCost,
      value: value ?? this.value,
      runningBalance: runningBalance ?? this.runningBalance,
      sourceType: sourceType ?? this.sourceType,
      sourceUuid: sourceUuid ?? this.sourceUuid,
      reason: reason ?? this.reason,
      operatorName: operatorName ?? this.operatorName,
      occurredAt: occurredAt ?? this.occurredAt,
      syncStatus: syncStatus ?? this.syncStatus,
      locationServerId: locationServerId ?? this.locationServerId,
      locationName: locationName ?? this.locationName,
      fromLocationName: fromLocationName ?? this.fromLocationName,
      toLocationName: toLocationName ?? this.toLocationName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (clientUuid.present) {
      map['client_uuid'] = Variable<String>(clientUuid.value);
    }
    if (branchServerId.present) {
      map['branch_server_id'] = Variable<int>(branchServerId.value);
    }
    if (branchClientUuid.present) {
      map['branch_client_uuid'] = Variable<String>(branchClientUuid.value);
    }
    if (branchName.present) {
      map['branch_name'] = Variable<String>(branchName.value);
    }
    if (productServerId.present) {
      map['product_server_id'] = Variable<int>(productServerId.value);
    }
    if (productClientUuid.present) {
      map['product_client_uuid'] = Variable<String>(productClientUuid.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (productCode.present) {
      map['product_code'] = Variable<String>(productCode.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (qty.present) {
      map['qty'] = Variable<String>(qty.value);
    }
    if (unitCost.present) {
      map['unit_cost'] = Variable<String>(unitCost.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (runningBalance.present) {
      map['running_balance'] = Variable<String>(runningBalance.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (sourceUuid.present) {
      map['source_uuid'] = Variable<String>(sourceUuid.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (operatorName.present) {
      map['operator_name'] = Variable<String>(operatorName.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<String>(occurredAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (locationServerId.present) {
      map['location_server_id'] = Variable<int>(locationServerId.value);
    }
    if (locationName.present) {
      map['location_name'] = Variable<String>(locationName.value);
    }
    if (fromLocationName.present) {
      map['from_location_name'] = Variable<String>(fromLocationName.value);
    }
    if (toLocationName.present) {
      map['to_location_name'] = Variable<String>(toLocationName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventRowsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('branchServerId: $branchServerId, ')
          ..write('branchClientUuid: $branchClientUuid, ')
          ..write('branchName: $branchName, ')
          ..write('productServerId: $productServerId, ')
          ..write('productClientUuid: $productClientUuid, ')
          ..write('productName: $productName, ')
          ..write('productCode: $productCode, ')
          ..write('eventType: $eventType, ')
          ..write('qty: $qty, ')
          ..write('unitCost: $unitCost, ')
          ..write('value: $value, ')
          ..write('runningBalance: $runningBalance, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceUuid: $sourceUuid, ')
          ..write('reason: $reason, ')
          ..write('operatorName: $operatorName, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('locationServerId: $locationServerId, ')
          ..write('locationName: $locationName, ')
          ..write('fromLocationName: $fromLocationName, ')
          ..write('toLocationName: $toLocationName')
          ..write(')'))
        .toString();
  }
}

class $LayerRowsTable extends LayerRows
    with TableInfo<$LayerRowsTable, LayerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LayerRowsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _branchClientUuidMeta = const VerificationMeta(
    'branchClientUuid',
  );
  @override
  late final GeneratedColumn<String> branchClientUuid = GeneratedColumn<String>(
    'branch_client_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productClientUuidMeta = const VerificationMeta(
    'productClientUuid',
  );
  @override
  late final GeneratedColumn<String> productClientUuid =
      GeneratedColumn<String>(
        'product_client_uuid',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _qtyRemainingMeta = const VerificationMeta(
    'qtyRemaining',
  );
  @override
  late final GeneratedColumn<String> qtyRemaining = GeneratedColumn<String>(
    'qty_remaining',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitCostMeta = const VerificationMeta(
    'unitCost',
  );
  @override
  late final GeneratedColumn<String> unitCost = GeneratedColumn<String>(
    'unit_cost',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<String> receivedAt = GeneratedColumn<String>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serverId,
    branchClientUuid,
    productClientUuid,
    qtyRemaining,
    unitCost,
    receivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'layer_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<LayerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('branch_client_uuid')) {
      context.handle(
        _branchClientUuidMeta,
        branchClientUuid.isAcceptableOrUnknown(
          data['branch_client_uuid']!,
          _branchClientUuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_branchClientUuidMeta);
    }
    if (data.containsKey('product_client_uuid')) {
      context.handle(
        _productClientUuidMeta,
        productClientUuid.isAcceptableOrUnknown(
          data['product_client_uuid']!,
          _productClientUuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productClientUuidMeta);
    }
    if (data.containsKey('qty_remaining')) {
      context.handle(
        _qtyRemainingMeta,
        qtyRemaining.isAcceptableOrUnknown(
          data['qty_remaining']!,
          _qtyRemainingMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_qtyRemainingMeta);
    }
    if (data.containsKey('unit_cost')) {
      context.handle(
        _unitCostMeta,
        unitCost.isAcceptableOrUnknown(data['unit_cost']!, _unitCostMeta),
      );
    } else if (isInserting) {
      context.missing(_unitCostMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LayerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LayerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      branchClientUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch_client_uuid'],
      )!,
      productClientUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_client_uuid'],
      )!,
      qtyRemaining: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}qty_remaining'],
      )!,
      unitCost: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_cost'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}received_at'],
      )!,
    );
  }

  @override
  $LayerRowsTable createAlias(String alias) {
    return $LayerRowsTable(attachedDatabase, alias);
  }
}

class LayerRow extends DataClass implements Insertable<LayerRow> {
  final int id;
  final int? serverId;
  final String branchClientUuid;
  final String productClientUuid;
  final String qtyRemaining;
  final String unitCost;
  final String receivedAt;
  const LayerRow({
    required this.id,
    this.serverId,
    required this.branchClientUuid,
    required this.productClientUuid,
    required this.qtyRemaining,
    required this.unitCost,
    required this.receivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['branch_client_uuid'] = Variable<String>(branchClientUuid);
    map['product_client_uuid'] = Variable<String>(productClientUuid);
    map['qty_remaining'] = Variable<String>(qtyRemaining);
    map['unit_cost'] = Variable<String>(unitCost);
    map['received_at'] = Variable<String>(receivedAt);
    return map;
  }

  LayerRowsCompanion toCompanion(bool nullToAbsent) {
    return LayerRowsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      branchClientUuid: Value(branchClientUuid),
      productClientUuid: Value(productClientUuid),
      qtyRemaining: Value(qtyRemaining),
      unitCost: Value(unitCost),
      receivedAt: Value(receivedAt),
    );
  }

  factory LayerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LayerRow(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      branchClientUuid: serializer.fromJson<String>(json['branchClientUuid']),
      productClientUuid: serializer.fromJson<String>(json['productClientUuid']),
      qtyRemaining: serializer.fromJson<String>(json['qtyRemaining']),
      unitCost: serializer.fromJson<String>(json['unitCost']),
      receivedAt: serializer.fromJson<String>(json['receivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<int?>(serverId),
      'branchClientUuid': serializer.toJson<String>(branchClientUuid),
      'productClientUuid': serializer.toJson<String>(productClientUuid),
      'qtyRemaining': serializer.toJson<String>(qtyRemaining),
      'unitCost': serializer.toJson<String>(unitCost),
      'receivedAt': serializer.toJson<String>(receivedAt),
    };
  }

  LayerRow copyWith({
    int? id,
    Value<int?> serverId = const Value.absent(),
    String? branchClientUuid,
    String? productClientUuid,
    String? qtyRemaining,
    String? unitCost,
    String? receivedAt,
  }) => LayerRow(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    branchClientUuid: branchClientUuid ?? this.branchClientUuid,
    productClientUuid: productClientUuid ?? this.productClientUuid,
    qtyRemaining: qtyRemaining ?? this.qtyRemaining,
    unitCost: unitCost ?? this.unitCost,
    receivedAt: receivedAt ?? this.receivedAt,
  );
  LayerRow copyWithCompanion(LayerRowsCompanion data) {
    return LayerRow(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      branchClientUuid: data.branchClientUuid.present
          ? data.branchClientUuid.value
          : this.branchClientUuid,
      productClientUuid: data.productClientUuid.present
          ? data.productClientUuid.value
          : this.productClientUuid,
      qtyRemaining: data.qtyRemaining.present
          ? data.qtyRemaining.value
          : this.qtyRemaining,
      unitCost: data.unitCost.present ? data.unitCost.value : this.unitCost,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LayerRow(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('branchClientUuid: $branchClientUuid, ')
          ..write('productClientUuid: $productClientUuid, ')
          ..write('qtyRemaining: $qtyRemaining, ')
          ..write('unitCost: $unitCost, ')
          ..write('receivedAt: $receivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    branchClientUuid,
    productClientUuid,
    qtyRemaining,
    unitCost,
    receivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LayerRow &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.branchClientUuid == this.branchClientUuid &&
          other.productClientUuid == this.productClientUuid &&
          other.qtyRemaining == this.qtyRemaining &&
          other.unitCost == this.unitCost &&
          other.receivedAt == this.receivedAt);
}

class LayerRowsCompanion extends UpdateCompanion<LayerRow> {
  final Value<int> id;
  final Value<int?> serverId;
  final Value<String> branchClientUuid;
  final Value<String> productClientUuid;
  final Value<String> qtyRemaining;
  final Value<String> unitCost;
  final Value<String> receivedAt;
  const LayerRowsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.branchClientUuid = const Value.absent(),
    this.productClientUuid = const Value.absent(),
    this.qtyRemaining = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.receivedAt = const Value.absent(),
  });
  LayerRowsCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    required String branchClientUuid,
    required String productClientUuid,
    required String qtyRemaining,
    required String unitCost,
    required String receivedAt,
  }) : branchClientUuid = Value(branchClientUuid),
       productClientUuid = Value(productClientUuid),
       qtyRemaining = Value(qtyRemaining),
       unitCost = Value(unitCost),
       receivedAt = Value(receivedAt);
  static Insertable<LayerRow> custom({
    Expression<int>? id,
    Expression<int>? serverId,
    Expression<String>? branchClientUuid,
    Expression<String>? productClientUuid,
    Expression<String>? qtyRemaining,
    Expression<String>? unitCost,
    Expression<String>? receivedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (branchClientUuid != null) 'branch_client_uuid': branchClientUuid,
      if (productClientUuid != null) 'product_client_uuid': productClientUuid,
      if (qtyRemaining != null) 'qty_remaining': qtyRemaining,
      if (unitCost != null) 'unit_cost': unitCost,
      if (receivedAt != null) 'received_at': receivedAt,
    });
  }

  LayerRowsCompanion copyWith({
    Value<int>? id,
    Value<int?>? serverId,
    Value<String>? branchClientUuid,
    Value<String>? productClientUuid,
    Value<String>? qtyRemaining,
    Value<String>? unitCost,
    Value<String>? receivedAt,
  }) {
    return LayerRowsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      branchClientUuid: branchClientUuid ?? this.branchClientUuid,
      productClientUuid: productClientUuid ?? this.productClientUuid,
      qtyRemaining: qtyRemaining ?? this.qtyRemaining,
      unitCost: unitCost ?? this.unitCost,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (branchClientUuid.present) {
      map['branch_client_uuid'] = Variable<String>(branchClientUuid.value);
    }
    if (productClientUuid.present) {
      map['product_client_uuid'] = Variable<String>(productClientUuid.value);
    }
    if (qtyRemaining.present) {
      map['qty_remaining'] = Variable<String>(qtyRemaining.value);
    }
    if (unitCost.present) {
      map['unit_cost'] = Variable<String>(unitCost.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<String>(receivedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LayerRowsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('branchClientUuid: $branchClientUuid, ')
          ..write('productClientUuid: $productClientUuid, ')
          ..write('qtyRemaining: $qtyRemaining, ')
          ..write('unitCost: $unitCost, ')
          ..write('receivedAt: $receivedAt')
          ..write(')'))
        .toString();
  }
}

class $BalanceRowsTable extends BalanceRows
    with TableInfo<$BalanceRowsTable, BalanceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BalanceRowsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _branchClientUuidMeta = const VerificationMeta(
    'branchClientUuid',
  );
  @override
  late final GeneratedColumn<String> branchClientUuid = GeneratedColumn<String>(
    'branch_client_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productClientUuidMeta = const VerificationMeta(
    'productClientUuid',
  );
  @override
  late final GeneratedColumn<String> productClientUuid =
      GeneratedColumn<String>(
        'product_client_uuid',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _qtyOnHandMeta = const VerificationMeta(
    'qtyOnHand',
  );
  @override
  late final GeneratedColumn<String> qtyOnHand = GeneratedColumn<String>(
    'qty_on_hand',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockValueMeta = const VerificationMeta(
    'stockValue',
  );
  @override
  late final GeneratedColumn<String> stockValue = GeneratedColumn<String>(
    'stock_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    branchClientUuid,
    productClientUuid,
    qtyOnHand,
    stockValue,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'balance_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<BalanceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('branch_client_uuid')) {
      context.handle(
        _branchClientUuidMeta,
        branchClientUuid.isAcceptableOrUnknown(
          data['branch_client_uuid']!,
          _branchClientUuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_branchClientUuidMeta);
    }
    if (data.containsKey('product_client_uuid')) {
      context.handle(
        _productClientUuidMeta,
        productClientUuid.isAcceptableOrUnknown(
          data['product_client_uuid']!,
          _productClientUuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productClientUuidMeta);
    }
    if (data.containsKey('qty_on_hand')) {
      context.handle(
        _qtyOnHandMeta,
        qtyOnHand.isAcceptableOrUnknown(data['qty_on_hand']!, _qtyOnHandMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyOnHandMeta);
    }
    if (data.containsKey('stock_value')) {
      context.handle(
        _stockValueMeta,
        stockValue.isAcceptableOrUnknown(data['stock_value']!, _stockValueMeta),
      );
    } else if (isInserting) {
      context.missing(_stockValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {branchClientUuid, productClientUuid},
  ];
  @override
  BalanceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BalanceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      branchClientUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch_client_uuid'],
      )!,
      productClientUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_client_uuid'],
      )!,
      qtyOnHand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}qty_on_hand'],
      )!,
      stockValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stock_value'],
      )!,
    );
  }

  @override
  $BalanceRowsTable createAlias(String alias) {
    return $BalanceRowsTable(attachedDatabase, alias);
  }
}

class BalanceRow extends DataClass implements Insertable<BalanceRow> {
  final int id;
  final String branchClientUuid;
  final String productClientUuid;
  final String qtyOnHand;
  final String stockValue;
  const BalanceRow({
    required this.id,
    required this.branchClientUuid,
    required this.productClientUuid,
    required this.qtyOnHand,
    required this.stockValue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['branch_client_uuid'] = Variable<String>(branchClientUuid);
    map['product_client_uuid'] = Variable<String>(productClientUuid);
    map['qty_on_hand'] = Variable<String>(qtyOnHand);
    map['stock_value'] = Variable<String>(stockValue);
    return map;
  }

  BalanceRowsCompanion toCompanion(bool nullToAbsent) {
    return BalanceRowsCompanion(
      id: Value(id),
      branchClientUuid: Value(branchClientUuid),
      productClientUuid: Value(productClientUuid),
      qtyOnHand: Value(qtyOnHand),
      stockValue: Value(stockValue),
    );
  }

  factory BalanceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BalanceRow(
      id: serializer.fromJson<int>(json['id']),
      branchClientUuid: serializer.fromJson<String>(json['branchClientUuid']),
      productClientUuid: serializer.fromJson<String>(json['productClientUuid']),
      qtyOnHand: serializer.fromJson<String>(json['qtyOnHand']),
      stockValue: serializer.fromJson<String>(json['stockValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'branchClientUuid': serializer.toJson<String>(branchClientUuid),
      'productClientUuid': serializer.toJson<String>(productClientUuid),
      'qtyOnHand': serializer.toJson<String>(qtyOnHand),
      'stockValue': serializer.toJson<String>(stockValue),
    };
  }

  BalanceRow copyWith({
    int? id,
    String? branchClientUuid,
    String? productClientUuid,
    String? qtyOnHand,
    String? stockValue,
  }) => BalanceRow(
    id: id ?? this.id,
    branchClientUuid: branchClientUuid ?? this.branchClientUuid,
    productClientUuid: productClientUuid ?? this.productClientUuid,
    qtyOnHand: qtyOnHand ?? this.qtyOnHand,
    stockValue: stockValue ?? this.stockValue,
  );
  BalanceRow copyWithCompanion(BalanceRowsCompanion data) {
    return BalanceRow(
      id: data.id.present ? data.id.value : this.id,
      branchClientUuid: data.branchClientUuid.present
          ? data.branchClientUuid.value
          : this.branchClientUuid,
      productClientUuid: data.productClientUuid.present
          ? data.productClientUuid.value
          : this.productClientUuid,
      qtyOnHand: data.qtyOnHand.present ? data.qtyOnHand.value : this.qtyOnHand,
      stockValue: data.stockValue.present
          ? data.stockValue.value
          : this.stockValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BalanceRow(')
          ..write('id: $id, ')
          ..write('branchClientUuid: $branchClientUuid, ')
          ..write('productClientUuid: $productClientUuid, ')
          ..write('qtyOnHand: $qtyOnHand, ')
          ..write('stockValue: $stockValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    branchClientUuid,
    productClientUuid,
    qtyOnHand,
    stockValue,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BalanceRow &&
          other.id == this.id &&
          other.branchClientUuid == this.branchClientUuid &&
          other.productClientUuid == this.productClientUuid &&
          other.qtyOnHand == this.qtyOnHand &&
          other.stockValue == this.stockValue);
}

class BalanceRowsCompanion extends UpdateCompanion<BalanceRow> {
  final Value<int> id;
  final Value<String> branchClientUuid;
  final Value<String> productClientUuid;
  final Value<String> qtyOnHand;
  final Value<String> stockValue;
  const BalanceRowsCompanion({
    this.id = const Value.absent(),
    this.branchClientUuid = const Value.absent(),
    this.productClientUuid = const Value.absent(),
    this.qtyOnHand = const Value.absent(),
    this.stockValue = const Value.absent(),
  });
  BalanceRowsCompanion.insert({
    this.id = const Value.absent(),
    required String branchClientUuid,
    required String productClientUuid,
    required String qtyOnHand,
    required String stockValue,
  }) : branchClientUuid = Value(branchClientUuid),
       productClientUuid = Value(productClientUuid),
       qtyOnHand = Value(qtyOnHand),
       stockValue = Value(stockValue);
  static Insertable<BalanceRow> custom({
    Expression<int>? id,
    Expression<String>? branchClientUuid,
    Expression<String>? productClientUuid,
    Expression<String>? qtyOnHand,
    Expression<String>? stockValue,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (branchClientUuid != null) 'branch_client_uuid': branchClientUuid,
      if (productClientUuid != null) 'product_client_uuid': productClientUuid,
      if (qtyOnHand != null) 'qty_on_hand': qtyOnHand,
      if (stockValue != null) 'stock_value': stockValue,
    });
  }

  BalanceRowsCompanion copyWith({
    Value<int>? id,
    Value<String>? branchClientUuid,
    Value<String>? productClientUuid,
    Value<String>? qtyOnHand,
    Value<String>? stockValue,
  }) {
    return BalanceRowsCompanion(
      id: id ?? this.id,
      branchClientUuid: branchClientUuid ?? this.branchClientUuid,
      productClientUuid: productClientUuid ?? this.productClientUuid,
      qtyOnHand: qtyOnHand ?? this.qtyOnHand,
      stockValue: stockValue ?? this.stockValue,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (branchClientUuid.present) {
      map['branch_client_uuid'] = Variable<String>(branchClientUuid.value);
    }
    if (productClientUuid.present) {
      map['product_client_uuid'] = Variable<String>(productClientUuid.value);
    }
    if (qtyOnHand.present) {
      map['qty_on_hand'] = Variable<String>(qtyOnHand.value);
    }
    if (stockValue.present) {
      map['stock_value'] = Variable<String>(stockValue.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BalanceRowsCompanion(')
          ..write('id: $id, ')
          ..write('branchClientUuid: $branchClientUuid, ')
          ..write('productClientUuid: $productClientUuid, ')
          ..write('qtyOnHand: $qtyOnHand, ')
          ..write('stockValue: $stockValue')
          ..write(')'))
        .toString();
  }
}

class $BinRowsTable extends BinRows with TableInfo<$BinRowsTable, BinRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BinRowsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _locationClientUuidMeta =
      const VerificationMeta('locationClientUuid');
  @override
  late final GeneratedColumn<String> locationClientUuid =
      GeneratedColumn<String>(
        'location_client_uuid',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _productClientUuidMeta = const VerificationMeta(
    'productClientUuid',
  );
  @override
  late final GeneratedColumn<String> productClientUuid =
      GeneratedColumn<String>(
        'product_client_uuid',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _qtyOnHandMeta = const VerificationMeta(
    'qtyOnHand',
  );
  @override
  late final GeneratedColumn<String> qtyOnHand = GeneratedColumn<String>(
    'qty_on_hand',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    locationClientUuid,
    productClientUuid,
    qtyOnHand,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bin_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<BinRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('location_client_uuid')) {
      context.handle(
        _locationClientUuidMeta,
        locationClientUuid.isAcceptableOrUnknown(
          data['location_client_uuid']!,
          _locationClientUuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_locationClientUuidMeta);
    }
    if (data.containsKey('product_client_uuid')) {
      context.handle(
        _productClientUuidMeta,
        productClientUuid.isAcceptableOrUnknown(
          data['product_client_uuid']!,
          _productClientUuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productClientUuidMeta);
    }
    if (data.containsKey('qty_on_hand')) {
      context.handle(
        _qtyOnHandMeta,
        qtyOnHand.isAcceptableOrUnknown(data['qty_on_hand']!, _qtyOnHandMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyOnHandMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {locationClientUuid, productClientUuid},
  ];
  @override
  BinRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BinRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      locationClientUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_client_uuid'],
      )!,
      productClientUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_client_uuid'],
      )!,
      qtyOnHand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}qty_on_hand'],
      )!,
    );
  }

  @override
  $BinRowsTable createAlias(String alias) {
    return $BinRowsTable(attachedDatabase, alias);
  }
}

class BinRow extends DataClass implements Insertable<BinRow> {
  final int id;
  final String locationClientUuid;
  final String productClientUuid;
  final String qtyOnHand;
  const BinRow({
    required this.id,
    required this.locationClientUuid,
    required this.productClientUuid,
    required this.qtyOnHand,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['location_client_uuid'] = Variable<String>(locationClientUuid);
    map['product_client_uuid'] = Variable<String>(productClientUuid);
    map['qty_on_hand'] = Variable<String>(qtyOnHand);
    return map;
  }

  BinRowsCompanion toCompanion(bool nullToAbsent) {
    return BinRowsCompanion(
      id: Value(id),
      locationClientUuid: Value(locationClientUuid),
      productClientUuid: Value(productClientUuid),
      qtyOnHand: Value(qtyOnHand),
    );
  }

  factory BinRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BinRow(
      id: serializer.fromJson<int>(json['id']),
      locationClientUuid: serializer.fromJson<String>(
        json['locationClientUuid'],
      ),
      productClientUuid: serializer.fromJson<String>(json['productClientUuid']),
      qtyOnHand: serializer.fromJson<String>(json['qtyOnHand']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'locationClientUuid': serializer.toJson<String>(locationClientUuid),
      'productClientUuid': serializer.toJson<String>(productClientUuid),
      'qtyOnHand': serializer.toJson<String>(qtyOnHand),
    };
  }

  BinRow copyWith({
    int? id,
    String? locationClientUuid,
    String? productClientUuid,
    String? qtyOnHand,
  }) => BinRow(
    id: id ?? this.id,
    locationClientUuid: locationClientUuid ?? this.locationClientUuid,
    productClientUuid: productClientUuid ?? this.productClientUuid,
    qtyOnHand: qtyOnHand ?? this.qtyOnHand,
  );
  BinRow copyWithCompanion(BinRowsCompanion data) {
    return BinRow(
      id: data.id.present ? data.id.value : this.id,
      locationClientUuid: data.locationClientUuid.present
          ? data.locationClientUuid.value
          : this.locationClientUuid,
      productClientUuid: data.productClientUuid.present
          ? data.productClientUuid.value
          : this.productClientUuid,
      qtyOnHand: data.qtyOnHand.present ? data.qtyOnHand.value : this.qtyOnHand,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BinRow(')
          ..write('id: $id, ')
          ..write('locationClientUuid: $locationClientUuid, ')
          ..write('productClientUuid: $productClientUuid, ')
          ..write('qtyOnHand: $qtyOnHand')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, locationClientUuid, productClientUuid, qtyOnHand);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BinRow &&
          other.id == this.id &&
          other.locationClientUuid == this.locationClientUuid &&
          other.productClientUuid == this.productClientUuid &&
          other.qtyOnHand == this.qtyOnHand);
}

class BinRowsCompanion extends UpdateCompanion<BinRow> {
  final Value<int> id;
  final Value<String> locationClientUuid;
  final Value<String> productClientUuid;
  final Value<String> qtyOnHand;
  const BinRowsCompanion({
    this.id = const Value.absent(),
    this.locationClientUuid = const Value.absent(),
    this.productClientUuid = const Value.absent(),
    this.qtyOnHand = const Value.absent(),
  });
  BinRowsCompanion.insert({
    this.id = const Value.absent(),
    required String locationClientUuid,
    required String productClientUuid,
    required String qtyOnHand,
  }) : locationClientUuid = Value(locationClientUuid),
       productClientUuid = Value(productClientUuid),
       qtyOnHand = Value(qtyOnHand);
  static Insertable<BinRow> custom({
    Expression<int>? id,
    Expression<String>? locationClientUuid,
    Expression<String>? productClientUuid,
    Expression<String>? qtyOnHand,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (locationClientUuid != null)
        'location_client_uuid': locationClientUuid,
      if (productClientUuid != null) 'product_client_uuid': productClientUuid,
      if (qtyOnHand != null) 'qty_on_hand': qtyOnHand,
    });
  }

  BinRowsCompanion copyWith({
    Value<int>? id,
    Value<String>? locationClientUuid,
    Value<String>? productClientUuid,
    Value<String>? qtyOnHand,
  }) {
    return BinRowsCompanion(
      id: id ?? this.id,
      locationClientUuid: locationClientUuid ?? this.locationClientUuid,
      productClientUuid: productClientUuid ?? this.productClientUuid,
      qtyOnHand: qtyOnHand ?? this.qtyOnHand,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (locationClientUuid.present) {
      map['location_client_uuid'] = Variable<String>(locationClientUuid.value);
    }
    if (productClientUuid.present) {
      map['product_client_uuid'] = Variable<String>(productClientUuid.value);
    }
    if (qtyOnHand.present) {
      map['qty_on_hand'] = Variable<String>(qtyOnHand.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BinRowsCompanion(')
          ..write('id: $id, ')
          ..write('locationClientUuid: $locationClientUuid, ')
          ..write('productClientUuid: $productClientUuid, ')
          ..write('qtyOnHand: $qtyOnHand')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MetaEntriesTable metaEntries = $MetaEntriesTable(this);
  late final $OutboxEntriesTable outboxEntries = $OutboxEntriesTable(this);
  late final $UnitRowsTable unitRows = $UnitRowsTable(this);
  late final $CategoryRowsTable categoryRows = $CategoryRowsTable(this);
  late final $BrandRowsTable brandRows = $BrandRowsTable(this);
  late final $ProductRowsTable productRows = $ProductRowsTable(this);
  late final $BranchRowsTable branchRows = $BranchRowsTable(this);
  late final $LocationRowsTable locationRows = $LocationRowsTable(this);
  late final $DocumentRowsTable documentRows = $DocumentRowsTable(this);
  late final $EventRowsTable eventRows = $EventRowsTable(this);
  late final $LayerRowsTable layerRows = $LayerRowsTable(this);
  late final $BalanceRowsTable balanceRows = $BalanceRowsTable(this);
  late final $BinRowsTable binRows = $BinRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    metaEntries,
    outboxEntries,
    unitRows,
    categoryRows,
    brandRows,
    productRows,
    branchRows,
    locationRows,
    documentRows,
    eventRows,
    layerRows,
    balanceRows,
    binRows,
  ];
}

typedef $$MetaEntriesTableCreateCompanionBuilder =
    MetaEntriesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$MetaEntriesTableUpdateCompanionBuilder =
    MetaEntriesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$MetaEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $MetaEntriesTable> {
  $$MetaEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetaEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MetaEntriesTable> {
  $$MetaEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetaEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetaEntriesTable> {
  $$MetaEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$MetaEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MetaEntriesTable,
          MetaEntry,
          $$MetaEntriesTableFilterComposer,
          $$MetaEntriesTableOrderingComposer,
          $$MetaEntriesTableAnnotationComposer,
          $$MetaEntriesTableCreateCompanionBuilder,
          $$MetaEntriesTableUpdateCompanionBuilder,
          (
            MetaEntry,
            BaseReferences<_$AppDatabase, $MetaEntriesTable, MetaEntry>,
          ),
          MetaEntry,
          PrefetchHooks Function()
        > {
  $$MetaEntriesTableTableManager(_$AppDatabase db, $MetaEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetaEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetaEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetaEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => MetaEntriesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => MetaEntriesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MetaEntriesTable, MetaEntry>(table),
                  BaseReferences<_$AppDatabase, $MetaEntriesTable, MetaEntry>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetaEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MetaEntriesTable,
      MetaEntry,
      $$MetaEntriesTableFilterComposer,
      $$MetaEntriesTableOrderingComposer,
      $$MetaEntriesTableAnnotationComposer,
      $$MetaEntriesTableCreateCompanionBuilder,
      $$MetaEntriesTableUpdateCompanionBuilder,
      (MetaEntry, BaseReferences<_$AppDatabase, $MetaEntriesTable, MetaEntry>),
      MetaEntry,
      PrefetchHooks Function()
    >;
typedef $$OutboxEntriesTableCreateCompanionBuilder =
    OutboxEntriesCompanion Function({
      Value<int> id,
      required String opId,
      required String entity,
      required String action,
      required String clientUuid,
      required String payload,
      Value<String> status,
      Value<String?> error,
      Value<DateTime> createdAt,
    });
typedef $$OutboxEntriesTableUpdateCompanionBuilder =
    OutboxEntriesCompanion Function({
      Value<int> id,
      Value<String> opId,
      Value<String> entity,
      Value<String> action,
      Value<String> clientUuid,
      Value<String> payload,
      Value<String> status,
      Value<String?> error,
      Value<DateTime> createdAt,
    });

class $$OutboxEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableFilterComposer({
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

  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OutboxEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxEntriesTable,
          OutboxEntry,
          $$OutboxEntriesTableFilterComposer,
          $$OutboxEntriesTableOrderingComposer,
          $$OutboxEntriesTableAnnotationComposer,
          $$OutboxEntriesTableCreateCompanionBuilder,
          $$OutboxEntriesTableUpdateCompanionBuilder,
          (
            OutboxEntry,
            BaseReferences<_$AppDatabase, $OutboxEntriesTable, OutboxEntry>,
          ),
          OutboxEntry,
          PrefetchHooks Function()
        > {
  $$OutboxEntriesTableTableManager(_$AppDatabase db, $OutboxEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> opId = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> clientUuid = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => OutboxEntriesCompanion(
                id: id,
                opId: opId,
                entity: entity,
                action: action,
                clientUuid: clientUuid,
                payload: payload,
                status: status,
                error: error,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String opId,
                required String entity,
                required String action,
                required String clientUuid,
                required String payload,
                Value<String> status = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => OutboxEntriesCompanion.insert(
                id: id,
                opId: opId,
                entity: entity,
                action: action,
                clientUuid: clientUuid,
                payload: payload,
                status: status,
                error: error,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutboxEntriesTable, OutboxEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $OutboxEntriesTable,
                    OutboxEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxEntriesTable,
      OutboxEntry,
      $$OutboxEntriesTableFilterComposer,
      $$OutboxEntriesTableOrderingComposer,
      $$OutboxEntriesTableAnnotationComposer,
      $$OutboxEntriesTableCreateCompanionBuilder,
      $$OutboxEntriesTableUpdateCompanionBuilder,
      (
        OutboxEntry,
        BaseReferences<_$AppDatabase, $OutboxEntriesTable, OutboxEntry>,
      ),
      OutboxEntry,
      PrefetchHooks Function()
    >;
typedef $$UnitRowsTableCreateCompanionBuilder = UnitRowsCompanion Function({
  Value<int> id,
  Value<int?> serverId,
  required String clientUuid,
  required String nameEn,
  Value<String> nameUr,
  required String shortName,
  Value<String?> updatedAt,
});
typedef $$UnitRowsTableUpdateCompanionBuilder = UnitRowsCompanion Function({
  Value<int> id,
  Value<int?> serverId,
  Value<String> clientUuid,
  Value<String> nameEn,
  Value<String> nameUr,
  Value<String> shortName,
  Value<String?> updatedAt,
});

class $$UnitRowsTableFilterComposer
    extends Composer<_$AppDatabase, $UnitRowsTable> {
  $$UnitRowsTableFilterComposer({
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

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameUr => $composableBuilder(
    column: $table.nameUr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shortName => $composableBuilder(
    column: $table.shortName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UnitRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $UnitRowsTable> {
  $$UnitRowsTableOrderingComposer({
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

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameUr => $composableBuilder(
    column: $table.nameUr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shortName => $composableBuilder(
    column: $table.shortName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UnitRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnitRowsTable> {
  $$UnitRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<String> get nameUr =>
      $composableBuilder(column: $table.nameUr, builder: (column) => column);

  GeneratedColumn<String> get shortName =>
      $composableBuilder(column: $table.shortName, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UnitRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UnitRowsTable,
          UnitRow,
          $$UnitRowsTableFilterComposer,
          $$UnitRowsTableOrderingComposer,
          $$UnitRowsTableAnnotationComposer,
          $$UnitRowsTableCreateCompanionBuilder,
          $$UnitRowsTableUpdateCompanionBuilder,
          (UnitRow, BaseReferences<_$AppDatabase, $UnitRowsTable, UnitRow>),
          UnitRow,
          PrefetchHooks Function()
        > {
  $$UnitRowsTableTableManager(_$AppDatabase db, $UnitRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnitRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnitRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UnitRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<String> clientUuid = const Value.absent(),
                Value<String> nameEn = const Value.absent(),
                Value<String> nameUr = const Value.absent(),
                Value<String> shortName = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => UnitRowsCompanion(
                id: id,
                serverId: serverId,
                clientUuid: clientUuid,
                nameEn: nameEn,
                nameUr: nameUr,
                shortName: shortName,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                required String clientUuid,
                required String nameEn,
                Value<String> nameUr = const Value.absent(),
                required String shortName,
                Value<String?> updatedAt = const Value.absent(),
              }) => UnitRowsCompanion.insert(
                id: id,
                serverId: serverId,
                clientUuid: clientUuid,
                nameEn: nameEn,
                nameUr: nameUr,
                shortName: shortName,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UnitRowsTable, UnitRow>(table),
                  BaseReferences<_$AppDatabase, $UnitRowsTable, UnitRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UnitRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UnitRowsTable,
      UnitRow,
      $$UnitRowsTableFilterComposer,
      $$UnitRowsTableOrderingComposer,
      $$UnitRowsTableAnnotationComposer,
      $$UnitRowsTableCreateCompanionBuilder,
      $$UnitRowsTableUpdateCompanionBuilder,
      (UnitRow, BaseReferences<_$AppDatabase, $UnitRowsTable, UnitRow>),
      UnitRow,
      PrefetchHooks Function()
    >;
typedef $$CategoryRowsTableCreateCompanionBuilder =
    CategoryRowsCompanion Function({
      Value<int> id,
      Value<int?> serverId,
      required String clientUuid,
      Value<int?> parentServerId,
      Value<String?> parentClientUuid,
      required String nameEn,
      Value<String> nameUr,
      Value<String?> code,
      Value<bool> isActive,
      Value<String?> updatedAt,
    });
typedef $$CategoryRowsTableUpdateCompanionBuilder =
    CategoryRowsCompanion Function({
      Value<int> id,
      Value<int?> serverId,
      Value<String> clientUuid,
      Value<int?> parentServerId,
      Value<String?> parentClientUuid,
      Value<String> nameEn,
      Value<String> nameUr,
      Value<String?> code,
      Value<bool> isActive,
      Value<String?> updatedAt,
    });

class $$CategoryRowsTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryRowsTable> {
  $$CategoryRowsTableFilterComposer({
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

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parentServerId => $composableBuilder(
    column: $table.parentServerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentClientUuid => $composableBuilder(
    column: $table.parentClientUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameUr => $composableBuilder(
    column: $table.nameUr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoryRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryRowsTable> {
  $$CategoryRowsTableOrderingComposer({
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

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parentServerId => $composableBuilder(
    column: $table.parentServerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentClientUuid => $composableBuilder(
    column: $table.parentClientUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameUr => $composableBuilder(
    column: $table.nameUr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoryRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryRowsTable> {
  $$CategoryRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => column,
  );

  GeneratedColumn<int> get parentServerId => $composableBuilder(
    column: $table.parentServerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentClientUuid => $composableBuilder(
    column: $table.parentClientUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<String> get nameUr =>
      $composableBuilder(column: $table.nameUr, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CategoryRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoryRowsTable,
          CategoryRow,
          $$CategoryRowsTableFilterComposer,
          $$CategoryRowsTableOrderingComposer,
          $$CategoryRowsTableAnnotationComposer,
          $$CategoryRowsTableCreateCompanionBuilder,
          $$CategoryRowsTableUpdateCompanionBuilder,
          (
            CategoryRow,
            BaseReferences<_$AppDatabase, $CategoryRowsTable, CategoryRow>,
          ),
          CategoryRow,
          PrefetchHooks Function()
        > {
  $$CategoryRowsTableTableManager(_$AppDatabase db, $CategoryRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<String> clientUuid = const Value.absent(),
                Value<int?> parentServerId = const Value.absent(),
                Value<String?> parentClientUuid = const Value.absent(),
                Value<String> nameEn = const Value.absent(),
                Value<String> nameUr = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => CategoryRowsCompanion(
                id: id,
                serverId: serverId,
                clientUuid: clientUuid,
                parentServerId: parentServerId,
                parentClientUuid: parentClientUuid,
                nameEn: nameEn,
                nameUr: nameUr,
                code: code,
                isActive: isActive,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                required String clientUuid,
                Value<int?> parentServerId = const Value.absent(),
                Value<String?> parentClientUuid = const Value.absent(),
                required String nameEn,
                Value<String> nameUr = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => CategoryRowsCompanion.insert(
                id: id,
                serverId: serverId,
                clientUuid: clientUuid,
                parentServerId: parentServerId,
                parentClientUuid: parentClientUuid,
                nameEn: nameEn,
                nameUr: nameUr,
                code: code,
                isActive: isActive,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoryRowsTable, CategoryRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CategoryRowsTable,
                    CategoryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoryRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoryRowsTable,
      CategoryRow,
      $$CategoryRowsTableFilterComposer,
      $$CategoryRowsTableOrderingComposer,
      $$CategoryRowsTableAnnotationComposer,
      $$CategoryRowsTableCreateCompanionBuilder,
      $$CategoryRowsTableUpdateCompanionBuilder,
      (
        CategoryRow,
        BaseReferences<_$AppDatabase, $CategoryRowsTable, CategoryRow>,
      ),
      CategoryRow,
      PrefetchHooks Function()
    >;
typedef $$BrandRowsTableCreateCompanionBuilder = BrandRowsCompanion Function({
  Value<int> id,
  Value<int?> serverId,
  required String clientUuid,
  required String nameEn,
  Value<String> nameUr,
  Value<String?> code,
  Value<bool> isActive,
  Value<String?> updatedAt,
});
typedef $$BrandRowsTableUpdateCompanionBuilder = BrandRowsCompanion Function({
  Value<int> id,
  Value<int?> serverId,
  Value<String> clientUuid,
  Value<String> nameEn,
  Value<String> nameUr,
  Value<String?> code,
  Value<bool> isActive,
  Value<String?> updatedAt,
});

class $$BrandRowsTableFilterComposer
    extends Composer<_$AppDatabase, $BrandRowsTable> {
  $$BrandRowsTableFilterComposer({
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

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameUr => $composableBuilder(
    column: $table.nameUr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BrandRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $BrandRowsTable> {
  $$BrandRowsTableOrderingComposer({
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

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameUr => $composableBuilder(
    column: $table.nameUr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BrandRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BrandRowsTable> {
  $$BrandRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<String> get nameUr =>
      $composableBuilder(column: $table.nameUr, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BrandRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BrandRowsTable,
          BrandRow,
          $$BrandRowsTableFilterComposer,
          $$BrandRowsTableOrderingComposer,
          $$BrandRowsTableAnnotationComposer,
          $$BrandRowsTableCreateCompanionBuilder,
          $$BrandRowsTableUpdateCompanionBuilder,
          (BrandRow, BaseReferences<_$AppDatabase, $BrandRowsTable, BrandRow>),
          BrandRow,
          PrefetchHooks Function()
        > {
  $$BrandRowsTableTableManager(_$AppDatabase db, $BrandRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BrandRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BrandRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BrandRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<String> clientUuid = const Value.absent(),
                Value<String> nameEn = const Value.absent(),
                Value<String> nameUr = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => BrandRowsCompanion(
                id: id,
                serverId: serverId,
                clientUuid: clientUuid,
                nameEn: nameEn,
                nameUr: nameUr,
                code: code,
                isActive: isActive,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                required String clientUuid,
                required String nameEn,
                Value<String> nameUr = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => BrandRowsCompanion.insert(
                id: id,
                serverId: serverId,
                clientUuid: clientUuid,
                nameEn: nameEn,
                nameUr: nameUr,
                code: code,
                isActive: isActive,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BrandRowsTable, BrandRow>(table),
                  BaseReferences<_$AppDatabase, $BrandRowsTable, BrandRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BrandRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BrandRowsTable,
      BrandRow,
      $$BrandRowsTableFilterComposer,
      $$BrandRowsTableOrderingComposer,
      $$BrandRowsTableAnnotationComposer,
      $$BrandRowsTableCreateCompanionBuilder,
      $$BrandRowsTableUpdateCompanionBuilder,
      (BrandRow, BaseReferences<_$AppDatabase, $BrandRowsTable, BrandRow>),
      BrandRow,
      PrefetchHooks Function()
    >;
typedef $$ProductRowsTableCreateCompanionBuilder =
    ProductRowsCompanion Function({
      Value<int> id,
      Value<int?> serverId,
      required String clientUuid,
      Value<String> code,
      Value<String?> barcode,
      required String nameEn,
      Value<String> nameUr,
      Value<int?> categoryServerId,
      Value<String?> categoryClientUuid,
      Value<int?> brandServerId,
      Value<String?> brandClientUuid,
      Value<int?> unitServerId,
      Value<String?> unitClientUuid,
      Value<String> unitShortName,
      Value<String> purchasePrice,
      Value<String> salePrice,
      Value<String> wholesalePrice,
      Value<String> alertQty,
      Value<bool> trackStock,
      Value<bool> isActive,
      Value<String?> updatedAt,
    });
typedef $$ProductRowsTableUpdateCompanionBuilder =
    ProductRowsCompanion Function({
      Value<int> id,
      Value<int?> serverId,
      Value<String> clientUuid,
      Value<String> code,
      Value<String?> barcode,
      Value<String> nameEn,
      Value<String> nameUr,
      Value<int?> categoryServerId,
      Value<String?> categoryClientUuid,
      Value<int?> brandServerId,
      Value<String?> brandClientUuid,
      Value<int?> unitServerId,
      Value<String?> unitClientUuid,
      Value<String> unitShortName,
      Value<String> purchasePrice,
      Value<String> salePrice,
      Value<String> wholesalePrice,
      Value<String> alertQty,
      Value<bool> trackStock,
      Value<bool> isActive,
      Value<String?> updatedAt,
    });

class $$ProductRowsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductRowsTable> {
  $$ProductRowsTableFilterComposer({
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

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameUr => $composableBuilder(
    column: $table.nameUr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryServerId => $composableBuilder(
    column: $table.categoryServerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryClientUuid => $composableBuilder(
    column: $table.categoryClientUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get brandServerId => $composableBuilder(
    column: $table.brandServerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brandClientUuid => $composableBuilder(
    column: $table.brandClientUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitServerId => $composableBuilder(
    column: $table.unitServerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitClientUuid => $composableBuilder(
    column: $table.unitClientUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitShortName => $composableBuilder(
    column: $table.unitShortName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get salePrice => $composableBuilder(
    column: $table.salePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wholesalePrice => $composableBuilder(
    column: $table.wholesalePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alertQty => $composableBuilder(
    column: $table.alertQty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get trackStock => $composableBuilder(
    column: $table.trackStock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductRowsTable> {
  $$ProductRowsTableOrderingComposer({
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

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameUr => $composableBuilder(
    column: $table.nameUr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryServerId => $composableBuilder(
    column: $table.categoryServerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryClientUuid => $composableBuilder(
    column: $table.categoryClientUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get brandServerId => $composableBuilder(
    column: $table.brandServerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brandClientUuid => $composableBuilder(
    column: $table.brandClientUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitServerId => $composableBuilder(
    column: $table.unitServerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitClientUuid => $composableBuilder(
    column: $table.unitClientUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitShortName => $composableBuilder(
    column: $table.unitShortName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get salePrice => $composableBuilder(
    column: $table.salePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wholesalePrice => $composableBuilder(
    column: $table.wholesalePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alertQty => $composableBuilder(
    column: $table.alertQty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get trackStock => $composableBuilder(
    column: $table.trackStock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductRowsTable> {
  $$ProductRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<String> get nameUr =>
      $composableBuilder(column: $table.nameUr, builder: (column) => column);

  GeneratedColumn<int> get categoryServerId => $composableBuilder(
    column: $table.categoryServerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryClientUuid => $composableBuilder(
    column: $table.categoryClientUuid,
    builder: (column) => column,
  );

  GeneratedColumn<int> get brandServerId => $composableBuilder(
    column: $table.brandServerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brandClientUuid => $composableBuilder(
    column: $table.brandClientUuid,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unitServerId => $composableBuilder(
    column: $table.unitServerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitClientUuid => $composableBuilder(
    column: $table.unitClientUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitShortName => $composableBuilder(
    column: $table.unitShortName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get salePrice =>
      $composableBuilder(column: $table.salePrice, builder: (column) => column);

  GeneratedColumn<String> get wholesalePrice => $composableBuilder(
    column: $table.wholesalePrice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get alertQty =>
      $composableBuilder(column: $table.alertQty, builder: (column) => column);

  GeneratedColumn<bool> get trackStock => $composableBuilder(
    column: $table.trackStock,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProductRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductRowsTable,
          ProductRow,
          $$ProductRowsTableFilterComposer,
          $$ProductRowsTableOrderingComposer,
          $$ProductRowsTableAnnotationComposer,
          $$ProductRowsTableCreateCompanionBuilder,
          $$ProductRowsTableUpdateCompanionBuilder,
          (
            ProductRow,
            BaseReferences<_$AppDatabase, $ProductRowsTable, ProductRow>,
          ),
          ProductRow,
          PrefetchHooks Function()
        > {
  $$ProductRowsTableTableManager(_$AppDatabase db, $ProductRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<String> clientUuid = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String> nameEn = const Value.absent(),
                Value<String> nameUr = const Value.absent(),
                Value<int?> categoryServerId = const Value.absent(),
                Value<String?> categoryClientUuid = const Value.absent(),
                Value<int?> brandServerId = const Value.absent(),
                Value<String?> brandClientUuid = const Value.absent(),
                Value<int?> unitServerId = const Value.absent(),
                Value<String?> unitClientUuid = const Value.absent(),
                Value<String> unitShortName = const Value.absent(),
                Value<String> purchasePrice = const Value.absent(),
                Value<String> salePrice = const Value.absent(),
                Value<String> wholesalePrice = const Value.absent(),
                Value<String> alertQty = const Value.absent(),
                Value<bool> trackStock = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => ProductRowsCompanion(
                id: id,
                serverId: serverId,
                clientUuid: clientUuid,
                code: code,
                barcode: barcode,
                nameEn: nameEn,
                nameUr: nameUr,
                categoryServerId: categoryServerId,
                categoryClientUuid: categoryClientUuid,
                brandServerId: brandServerId,
                brandClientUuid: brandClientUuid,
                unitServerId: unitServerId,
                unitClientUuid: unitClientUuid,
                unitShortName: unitShortName,
                purchasePrice: purchasePrice,
                salePrice: salePrice,
                wholesalePrice: wholesalePrice,
                alertQty: alertQty,
                trackStock: trackStock,
                isActive: isActive,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                required String clientUuid,
                Value<String> code = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                required String nameEn,
                Value<String> nameUr = const Value.absent(),
                Value<int?> categoryServerId = const Value.absent(),
                Value<String?> categoryClientUuid = const Value.absent(),
                Value<int?> brandServerId = const Value.absent(),
                Value<String?> brandClientUuid = const Value.absent(),
                Value<int?> unitServerId = const Value.absent(),
                Value<String?> unitClientUuid = const Value.absent(),
                Value<String> unitShortName = const Value.absent(),
                Value<String> purchasePrice = const Value.absent(),
                Value<String> salePrice = const Value.absent(),
                Value<String> wholesalePrice = const Value.absent(),
                Value<String> alertQty = const Value.absent(),
                Value<bool> trackStock = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => ProductRowsCompanion.insert(
                id: id,
                serverId: serverId,
                clientUuid: clientUuid,
                code: code,
                barcode: barcode,
                nameEn: nameEn,
                nameUr: nameUr,
                categoryServerId: categoryServerId,
                categoryClientUuid: categoryClientUuid,
                brandServerId: brandServerId,
                brandClientUuid: brandClientUuid,
                unitServerId: unitServerId,
                unitClientUuid: unitClientUuid,
                unitShortName: unitShortName,
                purchasePrice: purchasePrice,
                salePrice: salePrice,
                wholesalePrice: wholesalePrice,
                alertQty: alertQty,
                trackStock: trackStock,
                isActive: isActive,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProductRowsTable, ProductRow>(table),
                  BaseReferences<_$AppDatabase, $ProductRowsTable, ProductRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductRowsTable,
      ProductRow,
      $$ProductRowsTableFilterComposer,
      $$ProductRowsTableOrderingComposer,
      $$ProductRowsTableAnnotationComposer,
      $$ProductRowsTableCreateCompanionBuilder,
      $$ProductRowsTableUpdateCompanionBuilder,
      (
        ProductRow,
        BaseReferences<_$AppDatabase, $ProductRowsTable, ProductRow>,
      ),
      ProductRow,
      PrefetchHooks Function()
    >;
typedef $$BranchRowsTableCreateCompanionBuilder = BranchRowsCompanion Function({
  Value<int> id,
  Value<int?> serverId,
  required String clientUuid,
  required String name,
  Value<String?> code,
  Value<bool> isMain,
  Value<bool> isActive,
  Value<String?> updatedAt,
});
typedef $$BranchRowsTableUpdateCompanionBuilder = BranchRowsCompanion Function({
  Value<int> id,
  Value<int?> serverId,
  Value<String> clientUuid,
  Value<String> name,
  Value<String?> code,
  Value<bool> isMain,
  Value<bool> isActive,
  Value<String?> updatedAt,
});

class $$BranchRowsTableFilterComposer
    extends Composer<_$AppDatabase, $BranchRowsTable> {
  $$BranchRowsTableFilterComposer({
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

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMain => $composableBuilder(
    column: $table.isMain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BranchRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $BranchRowsTable> {
  $$BranchRowsTableOrderingComposer({
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

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMain => $composableBuilder(
    column: $table.isMain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BranchRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BranchRowsTable> {
  $$BranchRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<bool> get isMain =>
      $composableBuilder(column: $table.isMain, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BranchRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BranchRowsTable,
          BranchRow,
          $$BranchRowsTableFilterComposer,
          $$BranchRowsTableOrderingComposer,
          $$BranchRowsTableAnnotationComposer,
          $$BranchRowsTableCreateCompanionBuilder,
          $$BranchRowsTableUpdateCompanionBuilder,
          (
            BranchRow,
            BaseReferences<_$AppDatabase, $BranchRowsTable, BranchRow>,
          ),
          BranchRow,
          PrefetchHooks Function()
        > {
  $$BranchRowsTableTableManager(_$AppDatabase db, $BranchRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BranchRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BranchRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BranchRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<String> clientUuid = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<bool> isMain = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => BranchRowsCompanion(
                id: id,
                serverId: serverId,
                clientUuid: clientUuid,
                name: name,
                code: code,
                isMain: isMain,
                isActive: isActive,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                required String clientUuid,
                required String name,
                Value<String?> code = const Value.absent(),
                Value<bool> isMain = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => BranchRowsCompanion.insert(
                id: id,
                serverId: serverId,
                clientUuid: clientUuid,
                name: name,
                code: code,
                isMain: isMain,
                isActive: isActive,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BranchRowsTable, BranchRow>(table),
                  BaseReferences<_$AppDatabase, $BranchRowsTable, BranchRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BranchRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BranchRowsTable,
      BranchRow,
      $$BranchRowsTableFilterComposer,
      $$BranchRowsTableOrderingComposer,
      $$BranchRowsTableAnnotationComposer,
      $$BranchRowsTableCreateCompanionBuilder,
      $$BranchRowsTableUpdateCompanionBuilder,
      (BranchRow, BaseReferences<_$AppDatabase, $BranchRowsTable, BranchRow>),
      BranchRow,
      PrefetchHooks Function()
    >;
typedef $$LocationRowsTableCreateCompanionBuilder =
    LocationRowsCompanion Function({
      Value<int> id,
      Value<int?> serverId,
      required String clientUuid,
      Value<int?> branchServerId,
      Value<String?> branchClientUuid,
      required String name,
      Value<bool> isDefault,
      Value<bool> isActive,
      Value<String?> updatedAt,
    });
typedef $$LocationRowsTableUpdateCompanionBuilder =
    LocationRowsCompanion Function({
      Value<int> id,
      Value<int?> serverId,
      Value<String> clientUuid,
      Value<int?> branchServerId,
      Value<String?> branchClientUuid,
      Value<String> name,
      Value<bool> isDefault,
      Value<bool> isActive,
      Value<String?> updatedAt,
    });

class $$LocationRowsTableFilterComposer
    extends Composer<_$AppDatabase, $LocationRowsTable> {
  $$LocationRowsTableFilterComposer({
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

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get branchServerId => $composableBuilder(
    column: $table.branchServerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branchClientUuid => $composableBuilder(
    column: $table.branchClientUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocationRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocationRowsTable> {
  $$LocationRowsTableOrderingComposer({
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

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get branchServerId => $composableBuilder(
    column: $table.branchServerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branchClientUuid => $composableBuilder(
    column: $table.branchClientUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocationRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocationRowsTable> {
  $$LocationRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => column,
  );

  GeneratedColumn<int> get branchServerId => $composableBuilder(
    column: $table.branchServerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get branchClientUuid => $composableBuilder(
    column: $table.branchClientUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocationRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocationRowsTable,
          LocationRow,
          $$LocationRowsTableFilterComposer,
          $$LocationRowsTableOrderingComposer,
          $$LocationRowsTableAnnotationComposer,
          $$LocationRowsTableCreateCompanionBuilder,
          $$LocationRowsTableUpdateCompanionBuilder,
          (
            LocationRow,
            BaseReferences<_$AppDatabase, $LocationRowsTable, LocationRow>,
          ),
          LocationRow,
          PrefetchHooks Function()
        > {
  $$LocationRowsTableTableManager(_$AppDatabase db, $LocationRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocationRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<String> clientUuid = const Value.absent(),
                Value<int?> branchServerId = const Value.absent(),
                Value<String?> branchClientUuid = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => LocationRowsCompanion(
                id: id,
                serverId: serverId,
                clientUuid: clientUuid,
                branchServerId: branchServerId,
                branchClientUuid: branchClientUuid,
                name: name,
                isDefault: isDefault,
                isActive: isActive,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                required String clientUuid,
                Value<int?> branchServerId = const Value.absent(),
                Value<String?> branchClientUuid = const Value.absent(),
                required String name,
                Value<bool> isDefault = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => LocationRowsCompanion.insert(
                id: id,
                serverId: serverId,
                clientUuid: clientUuid,
                branchServerId: branchServerId,
                branchClientUuid: branchClientUuid,
                name: name,
                isDefault: isDefault,
                isActive: isActive,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocationRowsTable, LocationRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocationRowsTable,
                    LocationRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocationRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocationRowsTable,
      LocationRow,
      $$LocationRowsTableFilterComposer,
      $$LocationRowsTableOrderingComposer,
      $$LocationRowsTableAnnotationComposer,
      $$LocationRowsTableCreateCompanionBuilder,
      $$LocationRowsTableUpdateCompanionBuilder,
      (
        LocationRow,
        BaseReferences<_$AppDatabase, $LocationRowsTable, LocationRow>,
      ),
      LocationRow,
      PrefetchHooks Function()
    >;
typedef $$DocumentRowsTableCreateCompanionBuilder =
    DocumentRowsCompanion Function({
      Value<int> id,
      Value<int?> serverId,
      required String entity,
      required String clientUuid,
      required String payload,
      Value<bool> pending,
      Value<String?> updatedAt,
    });
typedef $$DocumentRowsTableUpdateCompanionBuilder =
    DocumentRowsCompanion Function({
      Value<int> id,
      Value<int?> serverId,
      Value<String> entity,
      Value<String> clientUuid,
      Value<String> payload,
      Value<bool> pending,
      Value<String?> updatedAt,
    });

class $$DocumentRowsTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentRowsTable> {
  $$DocumentRowsTableFilterComposer({
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

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DocumentRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentRowsTable> {
  $$DocumentRowsTableOrderingComposer({
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

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DocumentRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentRowsTable> {
  $$DocumentRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<bool> get pending =>
      $composableBuilder(column: $table.pending, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DocumentRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DocumentRowsTable,
          DocumentRow,
          $$DocumentRowsTableFilterComposer,
          $$DocumentRowsTableOrderingComposer,
          $$DocumentRowsTableAnnotationComposer,
          $$DocumentRowsTableCreateCompanionBuilder,
          $$DocumentRowsTableUpdateCompanionBuilder,
          (
            DocumentRow,
            BaseReferences<_$AppDatabase, $DocumentRowsTable, DocumentRow>,
          ),
          DocumentRow,
          PrefetchHooks Function()
        > {
  $$DocumentRowsTableTableManager(_$AppDatabase db, $DocumentRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> clientUuid = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => DocumentRowsCompanion(
                id: id,
                serverId: serverId,
                entity: entity,
                clientUuid: clientUuid,
                payload: payload,
                pending: pending,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                required String entity,
                required String clientUuid,
                required String payload,
                Value<bool> pending = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => DocumentRowsCompanion.insert(
                id: id,
                serverId: serverId,
                entity: entity,
                clientUuid: clientUuid,
                payload: payload,
                pending: pending,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DocumentRowsTable, DocumentRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DocumentRowsTable,
                    DocumentRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DocumentRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DocumentRowsTable,
      DocumentRow,
      $$DocumentRowsTableFilterComposer,
      $$DocumentRowsTableOrderingComposer,
      $$DocumentRowsTableAnnotationComposer,
      $$DocumentRowsTableCreateCompanionBuilder,
      $$DocumentRowsTableUpdateCompanionBuilder,
      (
        DocumentRow,
        BaseReferences<_$AppDatabase, $DocumentRowsTable, DocumentRow>,
      ),
      DocumentRow,
      PrefetchHooks Function()
    >;
typedef $$EventRowsTableCreateCompanionBuilder = EventRowsCompanion Function({
  Value<int> id,
  Value<int?> serverId,
  required String clientUuid,
  Value<int?> branchServerId,
  Value<String?> branchClientUuid,
  Value<String> branchName,
  Value<int?> productServerId,
  Value<String?> productClientUuid,
  Value<String> productName,
  Value<String> productCode,
  required String eventType,
  required String qty,
  Value<String> unitCost,
  Value<String> value,
  Value<String> runningBalance,
  Value<String?> sourceType,
  Value<String?> sourceUuid,
  Value<String?> reason,
  Value<String?> operatorName,
  required String occurredAt,
  Value<String> syncStatus,
  Value<int?> locationServerId,
  Value<String?> locationName,
  Value<String?> fromLocationName,
  Value<String?> toLocationName,
});
typedef $$EventRowsTableUpdateCompanionBuilder = EventRowsCompanion Function({
  Value<int> id,
  Value<int?> serverId,
  Value<String> clientUuid,
  Value<int?> branchServerId,
  Value<String?> branchClientUuid,
  Value<String> branchName,
  Value<int?> productServerId,
  Value<String?> productClientUuid,
  Value<String> productName,
  Value<String> productCode,
  Value<String> eventType,
  Value<String> qty,
  Value<String> unitCost,
  Value<String> value,
  Value<String> runningBalance,
  Value<String?> sourceType,
  Value<String?> sourceUuid,
  Value<String?> reason,
  Value<String?> operatorName,
  Value<String> occurredAt,
  Value<String> syncStatus,
  Value<int?> locationServerId,
  Value<String?> locationName,
  Value<String?> fromLocationName,
  Value<String?> toLocationName,
});

class $$EventRowsTableFilterComposer
    extends Composer<_$AppDatabase, $EventRowsTable> {
  $$EventRowsTableFilterComposer({
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

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get branchServerId => $composableBuilder(
    column: $table.branchServerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branchClientUuid => $composableBuilder(
    column: $table.branchClientUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branchName => $composableBuilder(
    column: $table.branchName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get productServerId => $composableBuilder(
    column: $table.productServerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productClientUuid => $composableBuilder(
    column: $table.productClientUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productCode => $composableBuilder(
    column: $table.productCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitCost => $composableBuilder(
    column: $table.unitCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get runningBalance => $composableBuilder(
    column: $table.runningBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUuid => $composableBuilder(
    column: $table.sourceUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operatorName => $composableBuilder(
    column: $table.operatorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get locationServerId => $composableBuilder(
    column: $table.locationServerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromLocationName => $composableBuilder(
    column: $table.fromLocationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toLocationName => $composableBuilder(
    column: $table.toLocationName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EventRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventRowsTable> {
  $$EventRowsTableOrderingComposer({
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

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get branchServerId => $composableBuilder(
    column: $table.branchServerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branchClientUuid => $composableBuilder(
    column: $table.branchClientUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branchName => $composableBuilder(
    column: $table.branchName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productServerId => $composableBuilder(
    column: $table.productServerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productClientUuid => $composableBuilder(
    column: $table.productClientUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productCode => $composableBuilder(
    column: $table.productCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitCost => $composableBuilder(
    column: $table.unitCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get runningBalance => $composableBuilder(
    column: $table.runningBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUuid => $composableBuilder(
    column: $table.sourceUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operatorName => $composableBuilder(
    column: $table.operatorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get locationServerId => $composableBuilder(
    column: $table.locationServerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromLocationName => $composableBuilder(
    column: $table.fromLocationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toLocationName => $composableBuilder(
    column: $table.toLocationName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventRowsTable> {
  $$EventRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get clientUuid => $composableBuilder(
    column: $table.clientUuid,
    builder: (column) => column,
  );

  GeneratedColumn<int> get branchServerId => $composableBuilder(
    column: $table.branchServerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get branchClientUuid => $composableBuilder(
    column: $table.branchClientUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get branchName => $composableBuilder(
    column: $table.branchName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get productServerId => $composableBuilder(
    column: $table.productServerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productClientUuid => $composableBuilder(
    column: $table.productClientUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productCode => $composableBuilder(
    column: $table.productCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<String> get unitCost =>
      $composableBuilder(column: $table.unitCost, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get runningBalance => $composableBuilder(
    column: $table.runningBalance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceUuid => $composableBuilder(
    column: $table.sourceUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get operatorName => $composableBuilder(
    column: $table.operatorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get locationServerId => $composableBuilder(
    column: $table.locationServerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fromLocationName => $composableBuilder(
    column: $table.fromLocationName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toLocationName => $composableBuilder(
    column: $table.toLocationName,
    builder: (column) => column,
  );
}

class $$EventRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventRowsTable,
          EventRow,
          $$EventRowsTableFilterComposer,
          $$EventRowsTableOrderingComposer,
          $$EventRowsTableAnnotationComposer,
          $$EventRowsTableCreateCompanionBuilder,
          $$EventRowsTableUpdateCompanionBuilder,
          (EventRow, BaseReferences<_$AppDatabase, $EventRowsTable, EventRow>),
          EventRow,
          PrefetchHooks Function()
        > {
  $$EventRowsTableTableManager(_$AppDatabase db, $EventRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<String> clientUuid = const Value.absent(),
                Value<int?> branchServerId = const Value.absent(),
                Value<String?> branchClientUuid = const Value.absent(),
                Value<String> branchName = const Value.absent(),
                Value<int?> productServerId = const Value.absent(),
                Value<String?> productClientUuid = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<String> productCode = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String> qty = const Value.absent(),
                Value<String> unitCost = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<String> runningBalance = const Value.absent(),
                Value<String?> sourceType = const Value.absent(),
                Value<String?> sourceUuid = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String?> operatorName = const Value.absent(),
                Value<String> occurredAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int?> locationServerId = const Value.absent(),
                Value<String?> locationName = const Value.absent(),
                Value<String?> fromLocationName = const Value.absent(),
                Value<String?> toLocationName = const Value.absent(),
              }) => EventRowsCompanion(
                id: id,
                serverId: serverId,
                clientUuid: clientUuid,
                branchServerId: branchServerId,
                branchClientUuid: branchClientUuid,
                branchName: branchName,
                productServerId: productServerId,
                productClientUuid: productClientUuid,
                productName: productName,
                productCode: productCode,
                eventType: eventType,
                qty: qty,
                unitCost: unitCost,
                value: value,
                runningBalance: runningBalance,
                sourceType: sourceType,
                sourceUuid: sourceUuid,
                reason: reason,
                operatorName: operatorName,
                occurredAt: occurredAt,
                syncStatus: syncStatus,
                locationServerId: locationServerId,
                locationName: locationName,
                fromLocationName: fromLocationName,
                toLocationName: toLocationName,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                required String clientUuid,
                Value<int?> branchServerId = const Value.absent(),
                Value<String?> branchClientUuid = const Value.absent(),
                Value<String> branchName = const Value.absent(),
                Value<int?> productServerId = const Value.absent(),
                Value<String?> productClientUuid = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<String> productCode = const Value.absent(),
                required String eventType,
                required String qty,
                Value<String> unitCost = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<String> runningBalance = const Value.absent(),
                Value<String?> sourceType = const Value.absent(),
                Value<String?> sourceUuid = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String?> operatorName = const Value.absent(),
                required String occurredAt,
                Value<String> syncStatus = const Value.absent(),
                Value<int?> locationServerId = const Value.absent(),
                Value<String?> locationName = const Value.absent(),
                Value<String?> fromLocationName = const Value.absent(),
                Value<String?> toLocationName = const Value.absent(),
              }) => EventRowsCompanion.insert(
                id: id,
                serverId: serverId,
                clientUuid: clientUuid,
                branchServerId: branchServerId,
                branchClientUuid: branchClientUuid,
                branchName: branchName,
                productServerId: productServerId,
                productClientUuid: productClientUuid,
                productName: productName,
                productCode: productCode,
                eventType: eventType,
                qty: qty,
                unitCost: unitCost,
                value: value,
                runningBalance: runningBalance,
                sourceType: sourceType,
                sourceUuid: sourceUuid,
                reason: reason,
                operatorName: operatorName,
                occurredAt: occurredAt,
                syncStatus: syncStatus,
                locationServerId: locationServerId,
                locationName: locationName,
                fromLocationName: fromLocationName,
                toLocationName: toLocationName,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EventRowsTable, EventRow>(table),
                  BaseReferences<_$AppDatabase, $EventRowsTable, EventRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EventRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventRowsTable,
      EventRow,
      $$EventRowsTableFilterComposer,
      $$EventRowsTableOrderingComposer,
      $$EventRowsTableAnnotationComposer,
      $$EventRowsTableCreateCompanionBuilder,
      $$EventRowsTableUpdateCompanionBuilder,
      (EventRow, BaseReferences<_$AppDatabase, $EventRowsTable, EventRow>),
      EventRow,
      PrefetchHooks Function()
    >;
typedef $$LayerRowsTableCreateCompanionBuilder = LayerRowsCompanion Function({
  Value<int> id,
  Value<int?> serverId,
  required String branchClientUuid,
  required String productClientUuid,
  required String qtyRemaining,
  required String unitCost,
  required String receivedAt,
});
typedef $$LayerRowsTableUpdateCompanionBuilder = LayerRowsCompanion Function({
  Value<int> id,
  Value<int?> serverId,
  Value<String> branchClientUuid,
  Value<String> productClientUuid,
  Value<String> qtyRemaining,
  Value<String> unitCost,
  Value<String> receivedAt,
});

class $$LayerRowsTableFilterComposer
    extends Composer<_$AppDatabase, $LayerRowsTable> {
  $$LayerRowsTableFilterComposer({
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

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branchClientUuid => $composableBuilder(
    column: $table.branchClientUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productClientUuid => $composableBuilder(
    column: $table.productClientUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qtyRemaining => $composableBuilder(
    column: $table.qtyRemaining,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitCost => $composableBuilder(
    column: $table.unitCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LayerRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $LayerRowsTable> {
  $$LayerRowsTableOrderingComposer({
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

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branchClientUuid => $composableBuilder(
    column: $table.branchClientUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productClientUuid => $composableBuilder(
    column: $table.productClientUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qtyRemaining => $composableBuilder(
    column: $table.qtyRemaining,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitCost => $composableBuilder(
    column: $table.unitCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LayerRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LayerRowsTable> {
  $$LayerRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get branchClientUuid => $composableBuilder(
    column: $table.branchClientUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productClientUuid => $composableBuilder(
    column: $table.productClientUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get qtyRemaining => $composableBuilder(
    column: $table.qtyRemaining,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitCost =>
      $composableBuilder(column: $table.unitCost, builder: (column) => column);

  GeneratedColumn<String> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );
}

class $$LayerRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LayerRowsTable,
          LayerRow,
          $$LayerRowsTableFilterComposer,
          $$LayerRowsTableOrderingComposer,
          $$LayerRowsTableAnnotationComposer,
          $$LayerRowsTableCreateCompanionBuilder,
          $$LayerRowsTableUpdateCompanionBuilder,
          (LayerRow, BaseReferences<_$AppDatabase, $LayerRowsTable, LayerRow>),
          LayerRow,
          PrefetchHooks Function()
        > {
  $$LayerRowsTableTableManager(_$AppDatabase db, $LayerRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LayerRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LayerRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LayerRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<String> branchClientUuid = const Value.absent(),
                Value<String> productClientUuid = const Value.absent(),
                Value<String> qtyRemaining = const Value.absent(),
                Value<String> unitCost = const Value.absent(),
                Value<String> receivedAt = const Value.absent(),
              }) => LayerRowsCompanion(
                id: id,
                serverId: serverId,
                branchClientUuid: branchClientUuid,
                productClientUuid: productClientUuid,
                qtyRemaining: qtyRemaining,
                unitCost: unitCost,
                receivedAt: receivedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                required String branchClientUuid,
                required String productClientUuid,
                required String qtyRemaining,
                required String unitCost,
                required String receivedAt,
              }) => LayerRowsCompanion.insert(
                id: id,
                serverId: serverId,
                branchClientUuid: branchClientUuid,
                productClientUuid: productClientUuid,
                qtyRemaining: qtyRemaining,
                unitCost: unitCost,
                receivedAt: receivedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LayerRowsTable, LayerRow>(table),
                  BaseReferences<_$AppDatabase, $LayerRowsTable, LayerRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LayerRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LayerRowsTable,
      LayerRow,
      $$LayerRowsTableFilterComposer,
      $$LayerRowsTableOrderingComposer,
      $$LayerRowsTableAnnotationComposer,
      $$LayerRowsTableCreateCompanionBuilder,
      $$LayerRowsTableUpdateCompanionBuilder,
      (LayerRow, BaseReferences<_$AppDatabase, $LayerRowsTable, LayerRow>),
      LayerRow,
      PrefetchHooks Function()
    >;
typedef $$BalanceRowsTableCreateCompanionBuilder =
    BalanceRowsCompanion Function({
      Value<int> id,
      required String branchClientUuid,
      required String productClientUuid,
      required String qtyOnHand,
      required String stockValue,
    });
typedef $$BalanceRowsTableUpdateCompanionBuilder =
    BalanceRowsCompanion Function({
      Value<int> id,
      Value<String> branchClientUuid,
      Value<String> productClientUuid,
      Value<String> qtyOnHand,
      Value<String> stockValue,
    });

class $$BalanceRowsTableFilterComposer
    extends Composer<_$AppDatabase, $BalanceRowsTable> {
  $$BalanceRowsTableFilterComposer({
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

  ColumnFilters<String> get branchClientUuid => $composableBuilder(
    column: $table.branchClientUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productClientUuid => $composableBuilder(
    column: $table.productClientUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qtyOnHand => $composableBuilder(
    column: $table.qtyOnHand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stockValue => $composableBuilder(
    column: $table.stockValue,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BalanceRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $BalanceRowsTable> {
  $$BalanceRowsTableOrderingComposer({
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

  ColumnOrderings<String> get branchClientUuid => $composableBuilder(
    column: $table.branchClientUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productClientUuid => $composableBuilder(
    column: $table.productClientUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qtyOnHand => $composableBuilder(
    column: $table.qtyOnHand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stockValue => $composableBuilder(
    column: $table.stockValue,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BalanceRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BalanceRowsTable> {
  $$BalanceRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get branchClientUuid => $composableBuilder(
    column: $table.branchClientUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productClientUuid => $composableBuilder(
    column: $table.productClientUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get qtyOnHand =>
      $composableBuilder(column: $table.qtyOnHand, builder: (column) => column);

  GeneratedColumn<String> get stockValue => $composableBuilder(
    column: $table.stockValue,
    builder: (column) => column,
  );
}

class $$BalanceRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BalanceRowsTable,
          BalanceRow,
          $$BalanceRowsTableFilterComposer,
          $$BalanceRowsTableOrderingComposer,
          $$BalanceRowsTableAnnotationComposer,
          $$BalanceRowsTableCreateCompanionBuilder,
          $$BalanceRowsTableUpdateCompanionBuilder,
          (
            BalanceRow,
            BaseReferences<_$AppDatabase, $BalanceRowsTable, BalanceRow>,
          ),
          BalanceRow,
          PrefetchHooks Function()
        > {
  $$BalanceRowsTableTableManager(_$AppDatabase db, $BalanceRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BalanceRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BalanceRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BalanceRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> branchClientUuid = const Value.absent(),
                Value<String> productClientUuid = const Value.absent(),
                Value<String> qtyOnHand = const Value.absent(),
                Value<String> stockValue = const Value.absent(),
              }) => BalanceRowsCompanion(
                id: id,
                branchClientUuid: branchClientUuid,
                productClientUuid: productClientUuid,
                qtyOnHand: qtyOnHand,
                stockValue: stockValue,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String branchClientUuid,
                required String productClientUuid,
                required String qtyOnHand,
                required String stockValue,
              }) => BalanceRowsCompanion.insert(
                id: id,
                branchClientUuid: branchClientUuid,
                productClientUuid: productClientUuid,
                qtyOnHand: qtyOnHand,
                stockValue: stockValue,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BalanceRowsTable, BalanceRow>(table),
                  BaseReferences<_$AppDatabase, $BalanceRowsTable, BalanceRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BalanceRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BalanceRowsTable,
      BalanceRow,
      $$BalanceRowsTableFilterComposer,
      $$BalanceRowsTableOrderingComposer,
      $$BalanceRowsTableAnnotationComposer,
      $$BalanceRowsTableCreateCompanionBuilder,
      $$BalanceRowsTableUpdateCompanionBuilder,
      (
        BalanceRow,
        BaseReferences<_$AppDatabase, $BalanceRowsTable, BalanceRow>,
      ),
      BalanceRow,
      PrefetchHooks Function()
    >;
typedef $$BinRowsTableCreateCompanionBuilder = BinRowsCompanion Function({
  Value<int> id,
  required String locationClientUuid,
  required String productClientUuid,
  required String qtyOnHand,
});
typedef $$BinRowsTableUpdateCompanionBuilder = BinRowsCompanion Function({
  Value<int> id,
  Value<String> locationClientUuid,
  Value<String> productClientUuid,
  Value<String> qtyOnHand,
});

class $$BinRowsTableFilterComposer
    extends Composer<_$AppDatabase, $BinRowsTable> {
  $$BinRowsTableFilterComposer({
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

  ColumnFilters<String> get locationClientUuid => $composableBuilder(
    column: $table.locationClientUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productClientUuid => $composableBuilder(
    column: $table.productClientUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qtyOnHand => $composableBuilder(
    column: $table.qtyOnHand,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BinRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $BinRowsTable> {
  $$BinRowsTableOrderingComposer({
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

  ColumnOrderings<String> get locationClientUuid => $composableBuilder(
    column: $table.locationClientUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productClientUuid => $composableBuilder(
    column: $table.productClientUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qtyOnHand => $composableBuilder(
    column: $table.qtyOnHand,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BinRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BinRowsTable> {
  $$BinRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get locationClientUuid => $composableBuilder(
    column: $table.locationClientUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productClientUuid => $composableBuilder(
    column: $table.productClientUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get qtyOnHand =>
      $composableBuilder(column: $table.qtyOnHand, builder: (column) => column);
}

class $$BinRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BinRowsTable,
          BinRow,
          $$BinRowsTableFilterComposer,
          $$BinRowsTableOrderingComposer,
          $$BinRowsTableAnnotationComposer,
          $$BinRowsTableCreateCompanionBuilder,
          $$BinRowsTableUpdateCompanionBuilder,
          (BinRow, BaseReferences<_$AppDatabase, $BinRowsTable, BinRow>),
          BinRow,
          PrefetchHooks Function()
        > {
  $$BinRowsTableTableManager(_$AppDatabase db, $BinRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BinRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BinRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BinRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> locationClientUuid = const Value.absent(),
                Value<String> productClientUuid = const Value.absent(),
                Value<String> qtyOnHand = const Value.absent(),
              }) => BinRowsCompanion(
                id: id,
                locationClientUuid: locationClientUuid,
                productClientUuid: productClientUuid,
                qtyOnHand: qtyOnHand,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String locationClientUuid,
                required String productClientUuid,
                required String qtyOnHand,
              }) => BinRowsCompanion.insert(
                id: id,
                locationClientUuid: locationClientUuid,
                productClientUuid: productClientUuid,
                qtyOnHand: qtyOnHand,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BinRowsTable, BinRow>(table),
                  BaseReferences<_$AppDatabase, $BinRowsTable, BinRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BinRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BinRowsTable,
      BinRow,
      $$BinRowsTableFilterComposer,
      $$BinRowsTableOrderingComposer,
      $$BinRowsTableAnnotationComposer,
      $$BinRowsTableCreateCompanionBuilder,
      $$BinRowsTableUpdateCompanionBuilder,
      (BinRow, BaseReferences<_$AppDatabase, $BinRowsTable, BinRow>),
      BinRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MetaEntriesTableTableManager get metaEntries =>
      $$MetaEntriesTableTableManager(_db, _db.metaEntries);
  $$OutboxEntriesTableTableManager get outboxEntries =>
      $$OutboxEntriesTableTableManager(_db, _db.outboxEntries);
  $$UnitRowsTableTableManager get unitRows =>
      $$UnitRowsTableTableManager(_db, _db.unitRows);
  $$CategoryRowsTableTableManager get categoryRows =>
      $$CategoryRowsTableTableManager(_db, _db.categoryRows);
  $$BrandRowsTableTableManager get brandRows =>
      $$BrandRowsTableTableManager(_db, _db.brandRows);
  $$ProductRowsTableTableManager get productRows =>
      $$ProductRowsTableTableManager(_db, _db.productRows);
  $$BranchRowsTableTableManager get branchRows =>
      $$BranchRowsTableTableManager(_db, _db.branchRows);
  $$LocationRowsTableTableManager get locationRows =>
      $$LocationRowsTableTableManager(_db, _db.locationRows);
  $$DocumentRowsTableTableManager get documentRows =>
      $$DocumentRowsTableTableManager(_db, _db.documentRows);
  $$EventRowsTableTableManager get eventRows =>
      $$EventRowsTableTableManager(_db, _db.eventRows);
  $$LayerRowsTableTableManager get layerRows =>
      $$LayerRowsTableTableManager(_db, _db.layerRows);
  $$BalanceRowsTableTableManager get balanceRows =>
      $$BalanceRowsTableTableManager(_db, _db.balanceRows);
  $$BinRowsTableTableManager get binRows =>
      $$BinRowsTableTableManager(_db, _db.binRows);
}
