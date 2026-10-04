import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

class MetaEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class OutboxEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get opId => text().unique()();
  TextColumn get entity => text()();
  TextColumn get action => text()();
  TextColumn get clientUuid => text()();
  TextColumn get payload => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get error => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class UnitRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get serverId => integer().nullable().unique()();
  TextColumn get clientUuid => text().unique()();
  TextColumn get nameEn => text()();
  TextColumn get nameUr => text().withDefault(const Constant(''))();
  TextColumn get shortName => text()();
  TextColumn get updatedAt => text().nullable()();
}

class CategoryRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get serverId => integer().nullable().unique()();
  TextColumn get clientUuid => text().unique()();
  IntColumn get parentServerId => integer().nullable()();
  TextColumn get parentClientUuid => text().nullable()();
  TextColumn get nameEn => text()();
  TextColumn get nameUr => text().withDefault(const Constant(''))();
  TextColumn get code => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get updatedAt => text().nullable()();
}

class BrandRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get serverId => integer().nullable().unique()();
  TextColumn get clientUuid => text().unique()();
  TextColumn get nameEn => text()();
  TextColumn get nameUr => text().withDefault(const Constant(''))();
  TextColumn get code => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get updatedAt => text().nullable()();
}

class ProductRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get serverId => integer().nullable().unique()();
  TextColumn get clientUuid => text().unique()();
  TextColumn get code => text().withDefault(const Constant(''))();
  TextColumn get barcode => text().nullable()();
  TextColumn get nameEn => text()();
  TextColumn get nameUr => text().withDefault(const Constant(''))();
  IntColumn get categoryServerId => integer().nullable()();
  TextColumn get categoryClientUuid => text().nullable()();
  IntColumn get brandServerId => integer().nullable()();
  TextColumn get brandClientUuid => text().nullable()();
  IntColumn get unitServerId => integer().nullable()();
  TextColumn get unitClientUuid => text().nullable()();
  TextColumn get unitShortName => text().withDefault(const Constant(''))();
  TextColumn get purchasePrice => text().withDefault(const Constant('0.00'))();
  TextColumn get salePrice => text().withDefault(const Constant('0.00'))();
  TextColumn get wholesalePrice => text().withDefault(const Constant('0.00'))();
  TextColumn get alertQty => text().withDefault(const Constant('0.000'))();
  BoolColumn get trackStock => boolean().withDefault(const Constant(true))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get updatedAt => text().nullable()();
}

class BranchRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get serverId => integer().nullable().unique()();
  TextColumn get clientUuid => text().unique()();
  TextColumn get name => text()();
  TextColumn get code => text().nullable()();
  BoolColumn get isMain => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get updatedAt => text().nullable()();
}

class LocationRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get serverId => integer().nullable().unique()();
  TextColumn get clientUuid => text().unique()();
  IntColumn get branchServerId => integer().nullable()();
  TextColumn get branchClientUuid => text().nullable()();
  TextColumn get name => text()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get updatedAt => text().nullable()();
}

class DocumentRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get serverId => integer().nullable()();
  TextColumn get entity => text()();
  TextColumn get clientUuid => text()();
  TextColumn get payload => text()();
  BoolColumn get pending => boolean().withDefault(const Constant(true))();
  TextColumn get updatedAt => text().nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {entity, clientUuid},
      ];
}

class EventRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get serverId => integer().nullable()();
  TextColumn get clientUuid => text().unique()();
  IntColumn get branchServerId => integer().nullable()();
  TextColumn get branchClientUuid => text().nullable()();
  TextColumn get branchName => text().withDefault(const Constant(''))();
  IntColumn get productServerId => integer().nullable()();
  TextColumn get productClientUuid => text().nullable()();
  TextColumn get productName => text().withDefault(const Constant(''))();
  TextColumn get productCode => text().withDefault(const Constant(''))();
  TextColumn get eventType => text()();
  TextColumn get qty => text()();
  TextColumn get unitCost => text().withDefault(const Constant('0.0000'))();
  TextColumn get value => text().withDefault(const Constant('0.00'))();
  TextColumn get runningBalance => text().withDefault(const Constant('0.000'))();
  TextColumn get sourceType => text().nullable()();
  TextColumn get sourceUuid => text().nullable()();
  TextColumn get reason => text().nullable()();
  TextColumn get operatorName => text().nullable()();
  TextColumn get occurredAt => text()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  IntColumn get locationServerId => integer().nullable()();
  TextColumn get locationName => text().nullable()();
  TextColumn get fromLocationName => text().nullable()();
  TextColumn get toLocationName => text().nullable()();
}

class LayerRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get serverId => integer().nullable()();
  TextColumn get branchClientUuid => text()();
  TextColumn get productClientUuid => text()();
  TextColumn get qtyRemaining => text()();
  TextColumn get unitCost => text()();
  TextColumn get receivedAt => text()();
}

class BalanceRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get branchClientUuid => text()();
  TextColumn get productClientUuid => text()();
  TextColumn get qtyOnHand => text()();
  TextColumn get stockValue => text()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {branchClientUuid, productClientUuid},
      ];
}

class BinRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get locationClientUuid => text()();
  TextColumn get productClientUuid => text()();
  TextColumn get qtyOnHand => text()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {locationClientUuid, productClientUuid},
      ];
}

@DriftDatabase(tables: [
  MetaEntries,
  OutboxEntries,
  UnitRows,
  CategoryRows,
  BrandRows,
  ProductRows,
  BranchRows,
  LocationRows,
  DocumentRows,
  EventRows,
  LayerRows,
  BalanceRows,
  BinRows,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _open());

  static QueryExecutor _open() {
    return driftDatabase(
      name: 'pos360tech',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }

  @override
  int get schemaVersion => 1;
}
