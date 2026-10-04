import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../core/api_client.dart';
import '../core/database.dart';
import '../core/money.dart';
import 'local_ledger.dart';

class Session {
  Session({required this.token, required this.user, required this.company});

  final String token;
  final Map<String, dynamic> user;
  final Map<String, dynamic> company;

  String get role => user['role']?.toString() ?? 'cashier';
  String get name => user['name']?.toString() ?? '';
  bool get canManage => role == 'owner' || role == 'manager';
  bool get isOwner => role == 'owner';
  String get symbol => company['currency_symbol']?.toString() ?? 'Rs';

  Map<String, dynamic> toJson() => {'token': token, 'user': user, 'company': company};

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      token: json['token'] as String,
      user: Map<String, dynamic>.from(json['user'] as Map),
      company: Map<String, dynamic>.from(json['company'] as Map),
    );
  }
}

class PosStore {
  PosStore(this.db, this.api) : ledger = LocalLedger(db);

  final AppDatabase db;
  final ApiClient api;
  final LocalLedger ledger;
  final Uuid _uuid = const Uuid();
  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  Future<String?> meta(String key) => _meta(key);

  Future<void> setMeta(String key, String value) => _setMeta(key, value);

  Future<String> deviceId() async {
    final existing = await _meta('device_id');
    if (existing != null && existing.isNotEmpty) {
      api.deviceId = existing;
      return existing;
    }
    final created = _uuid.v4();
    await _setMeta('device_id', created);
    api.deviceId = created;
    return created;
  }

  Future<Session?> restore() async {
    await deviceId();
    final raw = await _meta('session');
    if (raw == null || raw.isEmpty) return null;
    final session = Session.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    final token = await _readToken() ?? session.token;
    api.token = token;
    _cached = Session(token: token, user: session.user, company: session.company);
    return _cached;
  }

  Future<Session> register(Map<String, dynamic> body) async {
    body['device_id'] = await deviceId();
    body['device_name'] = 'POS360tech';
    final data = await api.post('/api/auth/register', body);
    return _acceptSession(data);
  }

  Future<Session> login({
    required String companyCode,
    required String username,
    required String password,
  }) async {
    final data = await api.post('/api/auth/login', {
      'company_code': companyCode,
      'username': username,
      'password': password,
      'device_id': await deviceId(),
      'device_name': 'POS360tech',
    });
    return _acceptSession(data);
  }

  Future<Map<String, dynamic>> codeAvailability(String code) {
    return api.get('/api/signup/availability', {'code': code});
  }

  Future<Map<String, dynamic>> signup(Map<String, dynamic> body) {
    return api.post('/api/signup', body);
  }

  Future<void> logout() async {
    try {
      await api.post('/api/auth/logout', {});
    } catch (_) {}
    api.token = null;
    _cached = null;
    await _writeToken(null);
    await _setMeta('session', '');
    await db.delete(db.metaEntries).go();
    await db.delete(db.outboxEntries).go();
    await db.delete(db.unitRows).go();
    await db.delete(db.categoryRows).go();
    await db.delete(db.brandRows).go();
    await db.delete(db.productRows).go();
    await db.delete(db.branchRows).go();
    await db.delete(db.locationRows).go();
    await db.delete(db.documentRows).go();
    await db.delete(db.eventRows).go();
    await db.delete(db.layerRows).go();
    await db.delete(db.balanceRows).go();
    await db.delete(db.binRows).go();
  }

  Future<Session> _acceptSession(Map<String, dynamic> data) async {
    final session = Session(
      token: data['token'] as String,
      user: Map<String, dynamic>.from(data['user'] as Map),
      company: Map<String, dynamic>.from(data['company'] as Map),
    );
    api.token = session.token;
    _cached = session;
    await _writeToken(session.token);
    await _setMeta('session', jsonEncode(session.toJson()));
    await _upsertBranches(data['branches'] as List? ?? []);
    await _upsertLocations(data['locations'] as List? ?? []);
    await pull();
    return session;
  }

  Future<void> replaceSession(Session session) async {
    api.token = session.token;
    _cached = session;
    await _setMeta('session', jsonEncode(session.toJson()));
  }

  Stream<int> watchPending() {
    return db
        .customSelect(
          "SELECT COUNT(*) AS c FROM outbox_entries WHERE status IN ('pending', 'error')",
          readsFrom: {db.outboxEntries},
        )
        .watch()
        .map((rows) => rows.first.read<int>('c'));
  }

  Stream<List<UnitRow>> watchUnits() => (db.select(db.unitRows)..orderBy([(t) => OrderingTerm.asc(t.nameEn)])).watch();
  Stream<List<CategoryRow>> watchCategories() => (db.select(db.categoryRows)..orderBy([(t) => OrderingTerm.asc(t.nameEn)])).watch();
  Stream<List<BrandRow>> watchBrands() => (db.select(db.brandRows)..orderBy([(t) => OrderingTerm.asc(t.nameEn)])).watch();
  Stream<List<ProductRow>> watchProducts() => (db.select(db.productRows)..orderBy([(t) => OrderingTerm.asc(t.nameEn)])).watch();
  Stream<List<BranchRow>> watchBranches() => (db.select(db.branchRows)..orderBy([(t) => OrderingTerm.desc(t.isMain)])).watch();
  Stream<List<LocationRow>> watchLocations() => (db.select(db.locationRows)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  Stream<List<BalanceRow>> watchBalances() => db.select(db.balanceRows).watch();
  Stream<List<EventRow>> watchEvents() => (db.select(db.eventRows)..orderBy([(t) => OrderingTerm.desc(t.occurredAt)])).watch();

  Future<void> saveUnit({UnitRow? existing, required String nameEn, required String nameUr, required String shortName}) async {
    final uuid = existing?.clientUuid ?? _uuid.v4();
    final payload = {
      'client_uuid': uuid,
      'name_en': nameEn,
      'name_ur': nameUr,
      'short_name': shortName,
      'base_updated_at': existing?.updatedAt,
    };
    await _saveMaster(
      existing: existing?.id,
      insert: () => db.into(db.unitRows).insert(UnitRowsCompanion.insert(clientUuid: uuid, nameEn: nameEn, nameUr: Value(nameUr), shortName: shortName)),
      update: (id) => (db.update(db.unitRows)..where((t) => t.id.equals(id))).write(UnitRowsCompanion(nameEn: Value(nameEn), nameUr: Value(nameUr), shortName: Value(shortName))),
      entity: 'unit',
      uuid: uuid,
      payload: payload,
    );
  }

  Future<void> deleteUnit(UnitRow row) => _deleteMaster('unit', row.clientUuid, row.updatedAt, () async {
        await (db.delete(db.unitRows)..where((t) => t.clientUuid.equals(row.clientUuid))).go();
      });

  Future<void> saveCategory({CategoryRow? existing, required String nameEn, required String nameUr, String? code, String? parentUuid, bool isActive = true}) async {
    final uuid = existing?.clientUuid ?? _uuid.v4();
    final payload = {
      'client_uuid': uuid,
      'name_en': nameEn,
      'name_ur': nameUr,
      'code': code,
      'parent_client_uuid': parentUuid,
      'is_active': isActive,
      'base_updated_at': existing?.updatedAt,
    };
    await _saveMaster(
      existing: existing?.id,
      insert: () => db.into(db.categoryRows).insert(CategoryRowsCompanion.insert(
            clientUuid: uuid,
            nameEn: nameEn,
            nameUr: Value(nameUr),
            code: Value(code),
            parentClientUuid: Value(parentUuid),
            isActive: Value(isActive),
          )),
      update: (id) => (db.update(db.categoryRows)..where((t) => t.id.equals(id))).write(CategoryRowsCompanion(
            nameEn: Value(nameEn),
            nameUr: Value(nameUr),
            code: Value(code),
            parentClientUuid: Value(parentUuid),
            isActive: Value(isActive),
          )),
      entity: 'category',
      uuid: uuid,
      payload: payload,
    );
  }

  Future<void> deleteCategory(CategoryRow row) => _deleteMaster('category', row.clientUuid, row.updatedAt, () async {
        await (db.delete(db.categoryRows)..where((t) => t.clientUuid.equals(row.clientUuid))).go();
      });

  Future<void> saveBrand({BrandRow? existing, required String nameEn, required String nameUr, String? code, bool isActive = true}) async {
    final uuid = existing?.clientUuid ?? _uuid.v4();
    final payload = {
      'client_uuid': uuid,
      'name_en': nameEn,
      'name_ur': nameUr,
      'code': code,
      'is_active': isActive,
      'base_updated_at': existing?.updatedAt,
    };
    await _saveMaster(
      existing: existing?.id,
      insert: () => db.into(db.brandRows).insert(BrandRowsCompanion.insert(clientUuid: uuid, nameEn: nameEn, nameUr: Value(nameUr), code: Value(code), isActive: Value(isActive))),
      update: (id) => (db.update(db.brandRows)..where((t) => t.id.equals(id))).write(BrandRowsCompanion(nameEn: Value(nameEn), nameUr: Value(nameUr), code: Value(code), isActive: Value(isActive))),
      entity: 'brand',
      uuid: uuid,
      payload: payload,
    );
  }

  Future<void> deleteBrand(BrandRow row) => _deleteMaster('brand', row.clientUuid, row.updatedAt, () async {
        await (db.delete(db.brandRows)..where((t) => t.clientUuid.equals(row.clientUuid))).go();
      });

  Future<void> saveProduct({
    ProductRow? existing,
    String? code,
    String? barcode,
    required String nameEn,
    required String nameUr,
    String? categoryUuid,
    String? brandUuid,
    required String unitUuid,
    required String purchasePrice,
    required String salePrice,
    required String wholesalePrice,
    required String alertQty,
    bool trackStock = true,
    bool isActive = true,
  }) async {
    final uuid = existing?.clientUuid ?? _uuid.v4();
    final unit = await (db.select(db.unitRows)..where((t) => t.clientUuid.equals(unitUuid))).getSingle();
    final payload = {
      'client_uuid': uuid,
      'code': code,
      'barcode': barcode,
      'name_en': nameEn,
      'name_ur': nameUr,
      'category_client_uuid': categoryUuid,
      'brand_client_uuid': brandUuid,
      'unit_client_uuid': unitUuid,
      'purchase_price': purchasePrice,
      'sale_price': salePrice,
      'wholesale_price': wholesalePrice,
      'alert_qty': alertQty,
      'track_stock': trackStock,
      'is_active': isActive,
      'base_updated_at': existing?.updatedAt,
    };
    final companion = ProductRowsCompanion(
      clientUuid: Value(uuid),
      code: Value(code ?? existing?.code ?? ''),
      barcode: Value(barcode),
      nameEn: Value(nameEn),
      nameUr: Value(nameUr),
      categoryClientUuid: Value(categoryUuid),
      brandClientUuid: Value(brandUuid),
      unitClientUuid: Value(unitUuid),
      unitShortName: Value(unit.shortName),
      purchasePrice: Value(Fixed.money(purchasePrice)),
      salePrice: Value(Fixed.money(salePrice)),
      wholesalePrice: Value(Fixed.money(wholesalePrice)),
      alertQty: Value(Fixed.qty(alertQty)),
      trackStock: Value(trackStock),
      isActive: Value(isActive),
    );
    await _saveMaster(
      existing: existing?.id,
      insert: () => db.into(db.productRows).insert(companion),
      update: (id) => (db.update(db.productRows)..where((t) => t.id.equals(id))).write(companion),
      entity: 'product',
      uuid: uuid,
      payload: payload,
    );
  }

  Future<void> deleteProduct(ProductRow row) => _deleteMaster('product', row.clientUuid, row.updatedAt, () async {
        await (db.delete(db.productRows)..where((t) => t.clientUuid.equals(row.clientUuid))).go();
      });

  Future<void> saveBranch(String name, String? code) async {
    final uuid = _uuid.v4();
    final locationUuid = _uuid.v4();
    await db.into(db.branchRows).insert(BranchRowsCompanion.insert(clientUuid: uuid, name: name, code: Value(code), isMain: const Value(false)));
    await db.into(db.locationRows).insert(LocationRowsCompanion.insert(
          clientUuid: locationUuid,
          branchClientUuid: Value(uuid),
          name: 'Main Godown',
          isDefault: const Value(true),
        ));
    await _enqueue('branch', 'create', uuid, {
      'client_uuid': uuid,
      'name': name,
      'code': code,
      'location_client_uuid': locationUuid,
    });
    await flush();
  }

  Future<void> saveLocation(String branchUuid, String name) async {
    final uuid = _uuid.v4();
    final branch = await (db.select(db.branchRows)..where((t) => t.clientUuid.equals(branchUuid))).getSingle();
    await db.into(db.locationRows).insert(LocationRowsCompanion.insert(
          clientUuid: uuid,
          branchServerId: Value(branch.serverId),
          branchClientUuid: Value(branchUuid),
          name: name,
        ));
    await _enqueue('location', 'create', uuid, {
      'client_uuid': uuid,
      'branch_id': branch.serverId,
      'branch_client_uuid': branchUuid,
      'name': name,
    });
    await flush();
  }

  Future<void> saveUser(String name, String email, String password, String role) async {
    await api.post('/api/users', {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    });
  }

  Future<List<Map<String, dynamic>>> users() async {
    final data = await api.get('/api/users');
    final rows = (data['data'] as List? ?? []).map((row) => Map<String, dynamic>.from(row as Map)).toList();
    await _setMeta('users', jsonEncode(rows));
    return rows;
  }

  Stream<List<DocumentRow>> watchDocuments(String entity) {
    return (db.select(db.documentRows)
          ..where((t) => t.entity.equals(entity))
          ..orderBy([(t) => OrderingTerm.desc(t.id)]))
        .watch();
  }

  /// Documents that live on this device only and are never pushed to the API.
  static const _localOnly = {'held_sale'};

  Future<void> saveMoney(String entity, Map<String, dynamic> payload) async {
    payload['client_uuid'] = payload['client_uuid'] ?? _uuid.v4();
    final uuid = payload['client_uuid'] as String;
    final local = _localOnly.contains(entity);
    final existing = await (db.select(db.documentRows)..where((t) => t.entity.equals(entity) & t.clientUuid.equals(uuid))).getSingleOrNull();
    if (existing == null) {
      await db.into(db.documentRows).insert(DocumentRowsCompanion.insert(
            entity: entity,
            clientUuid: uuid,
            payload: jsonEncode(payload),
            pending: Value(!local),
          ));
      if (!local) await _enqueue(entity, 'create', uuid, payload);
    } else {
      await (db.update(db.documentRows)..where((t) => t.id.equals(existing.id))).write(DocumentRowsCompanion(
            payload: Value(jsonEncode(payload)),
            pending: Value(!local),
          ));
      if (!local) await _enqueue(entity, 'update', uuid, payload);
    }
    if (!local) await flush();
  }

  Future<void> ensureChart() async {
    final existing = await (db.select(db.documentRows)..where((t) => t.entity.equals('ledger_account'))).get();
    if (existing.isNotEmpty) return;
    const rows = [
      ['1000', 'Cash', 'نقد', 'asset'],
      ['1100', 'Bank', 'بینک', 'asset'],
      ['1200', 'Accounts Receivable', 'وصول طلب', 'asset'],
      ['1300', 'Inventory', 'اسٹاک', 'asset'],
      ['1400', 'Staff Advances', 'عملے کا ایڈوانس', 'asset'],
      ['2000', 'Accounts Payable', 'قابل ادائیگی', 'liability'],
      ['2100', 'Sales Tax Payable', 'سیلز ٹیکس قابل ادائیگی', 'liability'],
      ['3000', 'Capital', 'سرمایہ', 'equity'],
      ['3100', "Owner's Drawings", 'مالک کے نکاسی', 'equity'],
      ['4000', 'Sales Revenue', 'فروخت', 'income'],
      ['4100', 'Other Income', 'دیگر آمدنی', 'income'],
      ['5000', 'Cost of Goods Sold', 'فروخت شدہ مال کی لاگت', 'expense'],
      ['5100', 'Salaries & Wages', 'تنخواہیں', 'expense'],
      ['5200', 'Rent', 'کرایہ', 'expense'],
    ];
    for (final row in rows) {
      final payload = <String, dynamic>{
        'client_uuid': _systemAccountUuid(row[0]),
        'code': row[0],
        'name_en': row[1],
        'name_ur': row[2],
        'type': row[3],
        'opening_balance': 0,
        'is_active': true,
        'is_system': true,
      };
      await db.into(db.documentRows).insert(DocumentRowsCompanion.insert(
            entity: 'ledger_account',
            clientUuid: payload['client_uuid'] as String,
            payload: jsonEncode(payload),
            pending: const Value(true),
          ));
      await _enqueue('ledger_account', 'create', payload['client_uuid'] as String, payload);
    }
    await flush();
  }

  Future<void> postStock(String entity, Map<String, dynamic> payload, {String? operatorName}) async {
    payload['client_uuid'] = payload['client_uuid'] ?? _uuid.v4();
    payload['occurred_at'] = payload['occurred_at'] ?? DateTime.now().toUtc().toIso8601String();
    await db.transaction(() async {
      await ledger.project(entity, payload, operatorName: operatorName);
      await db.into(db.documentRows).insert(DocumentRowsCompanion.insert(
            entity: entity,
            clientUuid: payload['client_uuid'] as String,
            payload: jsonEncode(payload),
            pending: const Value(true),
          ));
      await _enqueue(entity, 'create', payload['client_uuid'] as String, payload);
    });
    await flush();
  }

  Future<String> localCsv(List<EventRow> events) {
    final buffer = StringBuffer('Date,Product,Code,Branch,Type,Quantity,Unit cost,Value,Running balance,Source,Reason,Operator\n');
    for (final event in events) {
      buffer.writeln([
        event.occurredAt,
        event.productName,
        event.productCode,
        event.branchName,
        event.eventType,
        event.qty,
        event.unitCost,
        event.value,
        event.runningBalance,
        event.sourceUuid ?? '',
        event.reason ?? '',
        event.operatorName ?? '',
      ].map(_csv).join(','));
    }
    return Future.value(buffer.toString());
  }

  Future<List<int>> pdf(Map<String, dynamic> query) {
    return api.bytes('/api/stock/events/export.pdf', query);
  }

  Future<void> flush() async {
    if (api.token == null) return;
    await (db.delete(db.outboxEntries)..where((t) => t.entity.isIn(_localOnly.toList()))).go();
    final ops = await (db.select(db.outboxEntries)
          ..where((t) => t.status.isIn(['pending', 'error']))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    if (ops.isEmpty) {
      await pull();
      return;
    }
    Map<String, dynamic> response;
    try {
      response = await api.post('/api/sync/push', {
        'device_id': await deviceId(),
        'device_name': 'POS360tech',
        'operations': ops
            .map((op) => {
                  'op_id': op.opId,
                  'entity': op.entity,
                  'action': op.action,
                  'client_uuid': op.clientUuid,
                  'payload': jsonDecode(op.payload),
                })
            .toList(),
      });
    } catch (_) {
      return;
    }

    final results = (response['results'] as List? ?? []);
    for (var i = 0; i < results.length; i++) {
      final result = Map<String, dynamic>.from(results[i] as Map);
      final op = ops[i];
      final status = result['status']?.toString();
      if (status == 'synced') {
        await _applySynced(op, result);
        await (db.update(db.outboxEntries)..where((t) => t.id.equals(op.id))).write(const OutboxEntriesCompanion(status: Value('synced')));
      } else if (status == 'conflict') {
        await _applyRecord(op.entity, result['record']);
        await (db.delete(db.outboxEntries)..where((t) => t.id.equals(op.id))).go();
        break;
      } else {
        await (db.update(db.outboxEntries)..where((t) => t.id.equals(op.id))).write(OutboxEntriesCompanion(
              status: const Value('error'),
              error: Value(result['message']?.toString()),
            ));
        break;
      }
    }
    await pull();
  }

  Future<void> pull() async {
    if (api.token == null) return;
    final since = await _meta('cursor');
    Map<String, dynamic> data;
    try {
      data = await api.get('/api/sync/pull', {
        'device_id': await deviceId(),
        if (since != null && since.isNotEmpty) 'since': since,
      });
    } catch (_) {
      return;
    }
    final pendingStock = await (db.select(db.outboxEntries)
          ..where((t) => t.status.equals('pending') & t.entity.isIn(['stock_adjustment', 'stock_transfer', 'stock_write_off', 'location_move', 'purchase', 'purchase_return', 'sale'])))
        .get();
    await _upsertList('units', data['units'], _upsertUnit);
    await _upsertList('categories', data['categories'], _upsertCategory);
    await _upsertList('brands', data['brands'], _upsertBrand);
    await _upsertList('products', data['products'], _upsertProduct);
    await _upsertBranches(data['branches'] as List? ?? []);
    await _upsertLocations(data['locations'] as List? ?? []);
    await _upsertDocuments(data['adjustments'], 'stock_adjustment');
    await _upsertDocuments(data['transfers'], 'stock_transfer');
    await _upsertDocuments(data['write_offs'], 'stock_write_off');
    await _upsertDocuments(data['location_moves'], 'location_move');
    await _upsertDocuments(data['cheques'], 'cheque');
    await _upsertDocuments(data['partners'], 'investment_partner');
    await _upsertDocuments(data['investments'], 'investment_entry');
    await _upsertDocuments(data['journals'], 'journal_entry');
    await _upsertDocuments(data['day_closes'], 'day_close');
    await _upsertDocuments(data['ledger_accounts'], 'ledger_account');
    await _upsertDocuments(data['bank_accounts'], 'bank_account');
    await _upsertDocuments(data['suppliers'], 'supplier');
    await _upsertDocuments(data['purchases'], 'purchase');
    await _upsertDocuments(data['purchase_returns'], 'purchase_return');
    await _upsertDocuments(data['purchase_orders'], 'purchase_order');
    await _upsertDocuments(data['purchase_payments'], 'purchase_payment');
    await _upsertDocuments(data['parties'], 'party');
    await _upsertDocuments(data['areas'], 'area');
    await _upsertDocuments(data['credit_recoveries'], 'credit_recovery');
    await _upsertDocuments(data['manufacturing_products'], 'manufacturing_product');
    await _upsertDocuments(data['sales'], 'sale');
    await _upsertDocuments(data['expenses'], 'expense');
    await _upsertDocuments(data['employees'], 'employee');
    await _upsertDocuments(data['attendance_marks'], 'attendance');
    await _upsertDocuments(data['salary_payments'], 'salary_payment');
    await _upsertDocuments(data['shop_settings'], 'shop_settings');
    await _upsertDocuments(data['payment_methods'], 'payment_method');
    await _upsertDocuments(data['estimates'], 'estimate');
    await _upsertDocuments(data['sale_orders'], 'sale_order');
    await _upsertDocuments(data['delivery_notes'], 'delivery_note');
    if (pendingStock.isEmpty) {
      await _replaceProjection(data);
      await _upsertEvents(data['events'] as List? ?? []);
    }
    for (final tomb in (data['tombstones'] as List? ?? [])) {
      await _applyTombstone(Map<String, dynamic>.from(tomb as Map));
    }
    final serverTime = data['server_time']?.toString();
    if (serverTime != null) await _setMeta('cursor', serverTime);
  }

  Future<void> _replaceProjection(Map<String, dynamic> data) async {
    final branchById = await _serverBranchMap();
    final productById = await _serverProductMap();
    final locationById = await _serverLocationMap();
    await db.delete(db.balanceRows).go();
    await db.delete(db.layerRows).go();
    await db.delete(db.binRows).go();
    for (final raw in data['balances'] as List? ?? []) {
      final row = Map<String, dynamic>.from(raw as Map);
      final branch = branchById[_int(row['branch_id'])];
      final product = productById[_int(row['product_id'])];
      if (branch == null || product == null) continue;
      await db.into(db.balanceRows).insert(BalanceRowsCompanion.insert(
            branchClientUuid: branch,
            productClientUuid: product,
            qtyOnHand: Fixed.qty(row['qty_on_hand']),
            stockValue: Fixed.money(row['stock_value']),
          ));
    }
    for (final raw in data['layers'] as List? ?? []) {
      final row = Map<String, dynamic>.from(raw as Map);
      final branch = branchById[_int(row['branch_id'])];
      final product = productById[_int(row['product_id'])];
      if (branch == null || product == null) continue;
      await db.into(db.layerRows).insert(LayerRowsCompanion.insert(
            serverId: Value(_int(row['id'])),
            branchClientUuid: branch,
            productClientUuid: product,
            qtyRemaining: Fixed.qty(row['qty_remaining']),
            unitCost: Fixed.cost(row['unit_cost']),
            receivedAt: row['received_at']?.toString() ?? DateTime.now().toUtc().toIso8601String(),
          ));
    }
    for (final raw in data['location_stocks'] as List? ?? []) {
      final row = Map<String, dynamic>.from(raw as Map);
      final location = locationById[_int(row['location_id'])];
      final product = productById[_int(row['product_id'])];
      if (location == null || product == null) continue;
      await db.into(db.binRows).insert(BinRowsCompanion.insert(
            locationClientUuid: location,
            productClientUuid: product,
            qtyOnHand: Fixed.qty(row['qty_on_hand']),
          ));
    }
  }

  Future<void> _applySynced(OutboxEntry op, Map<String, dynamic> result) async {
    final record = result['record'];
    if (record is Map) {
      await _applyRecord(op.entity, record);
      final row = Map<String, dynamic>.from(record);
      await (db.update(db.documentRows)..where((t) => t.entity.equals(op.entity) & t.clientUuid.equals(op.clientUuid))).write(DocumentRowsCompanion(
            serverId: Value(_int(row['id'])),
            payload: Value(jsonEncode(row)),
            pending: const Value(false),
            updatedAt: Value(row['updated_at']?.toString()),
          ));
    }
    if (result['document'] is Map) {
      final doc = Map<String, dynamic>.from(result['document'] as Map);
      await (db.update(db.documentRows)..where((t) => t.entity.equals(op.entity) & t.clientUuid.equals(op.clientUuid))).write(DocumentRowsCompanion(
            serverId: Value(_int(doc['id'])),
            payload: Value(jsonEncode(doc)),
            pending: const Value(false),
            updatedAt: Value(doc['updated_at']?.toString()),
          ));
      await (db.delete(db.eventRows)..where((t) => t.sourceUuid.equals(op.clientUuid))).go();
      await _upsertEvents(result['events'] as List? ?? []);
      await _patchProjection(result);
      await _replayPending();
    }
  }

  Future<void> _patchProjection(Map<String, dynamic> result) async {
    final branchById = await _serverBranchMap();
    final productById = await _serverProductMap();
    final locationById = await _serverLocationMap();
    final touched = <String>{};
    for (final raw in result['balances'] as List? ?? []) {
      final row = Map<String, dynamic>.from(raw as Map);
      final branch = branchById[_int(row['branch_id'])];
      final product = productById[_int(row['product_id'])];
      if (branch == null || product == null) continue;
      touched.add('$branch|$product');
      await (db.delete(db.balanceRows)..where((t) => t.branchClientUuid.equals(branch) & t.productClientUuid.equals(product))).go();
      await db.into(db.balanceRows).insert(BalanceRowsCompanion.insert(
            branchClientUuid: branch,
            productClientUuid: product,
            qtyOnHand: Fixed.qty(row['qty_on_hand']),
            stockValue: Fixed.money(row['stock_value']),
          ));
      await (db.delete(db.layerRows)..where((t) => t.branchClientUuid.equals(branch) & t.productClientUuid.equals(product))).go();
    }
    for (final raw in result['layers'] as List? ?? []) {
      final row = Map<String, dynamic>.from(raw as Map);
      final branch = branchById[_int(row['branch_id'])];
      final product = productById[_int(row['product_id'])];
      if (branch == null || product == null) continue;
      await db.into(db.layerRows).insert(LayerRowsCompanion.insert(
            serverId: Value(_int(row['id'])),
            branchClientUuid: branch,
            productClientUuid: product,
            qtyRemaining: Fixed.qty(row['qty_remaining']),
            unitCost: Fixed.cost(row['unit_cost']),
            receivedAt: row['received_at']?.toString() ?? DateTime.now().toUtc().toIso8601String(),
          ));
    }
    for (final raw in result['location_stocks'] as List? ?? []) {
      final row = Map<String, dynamic>.from(raw as Map);
      final location = locationById[_int(row['location_id'])];
      final product = productById[_int(row['product_id'])];
      if (location == null || product == null) continue;
      await (db.delete(db.binRows)..where((t) => t.locationClientUuid.equals(location) & t.productClientUuid.equals(product))).go();
      await db.into(db.binRows).insert(BinRowsCompanion.insert(
            locationClientUuid: location,
            productClientUuid: product,
            qtyOnHand: Fixed.qty(row['qty_on_hand']),
          ));
    }
    await _setMeta('touched', jsonEncode(touched.toList()));
  }

  Future<void> _replayPending() async {
    final touched = ((jsonDecode(await _meta('touched') ?? '[]')) as List).cast<String>().toSet();
    final pending = await (db.select(db.documentRows)
          ..where((t) => t.pending.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    final session = await restoreSessionOnly();
    for (final doc in pending) {
      if (doc.entity != 'stock_adjustment' && doc.entity != 'stock_write_off' && doc.entity != 'stock_transfer' && doc.entity != 'location_move' && doc.entity != 'purchase' && doc.entity != 'purchase_return' && doc.entity != 'sale') {
        continue;
      }
      final payload = Map<String, dynamic>.from(jsonDecode(doc.payload) as Map);
      final products = _payloadProducts(payload);
      final branches = _payloadBranches(payload);
      final hits = products.expand((product) => branches.map((branch) => '$branch|$product')).any(touched.contains);
      if (!hits && touched.isNotEmpty) continue;
      await (db.delete(db.eventRows)..where((t) => t.sourceUuid.equals(doc.clientUuid))).go();
      await ledger.project(doc.entity, payload, operatorName: session?.name);
      for (final product in products) {
        for (final branch in branches) {
          touched.add('$branch|$product');
        }
      }
    }
  }

  Session? _cached;
  Future<Session?> restoreSessionOnly() async {
    if (_cached != null) return _cached;
    final raw = await _meta('session');
    if (raw == null || raw.isEmpty) return null;
    _cached = Session.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    return _cached;
  }

  List<String> _payloadProducts(Map<String, dynamic> payload) {
    final lines = payload['lines'];
    if (lines is! List) return [];
    return lines.map((line) => (line as Map)['product_client_uuid']?.toString()).whereType<String>().toList();
  }

  List<String> _payloadBranches(Map<String, dynamic> payload) {
    return [
      payload['branch_client_uuid'],
      payload['from_branch_client_uuid'],
      payload['to_branch_client_uuid'],
    ].whereType<String>().toList();
  }

  Future<void> _applyRecord(String entity, dynamic record) async {
    if (record is! Map) return;
    final row = Map<String, dynamic>.from(record);
    switch (entity) {
      case 'unit':
        await _upsertUnit(row);
      case 'category':
        await _upsertCategory(row);
      case 'brand':
        await _upsertBrand(row);
      case 'product':
        await _upsertProduct(row);
      case 'branch':
        await _upsertBranch(row);
      case 'location':
        await _upsertLocation(row);
    }
  }

  Future<void> _upsertList(String name, dynamic rows, Future<void> Function(Map<String, dynamic>) save) async {
    for (final raw in rows as List? ?? []) {
      await save(Map<String, dynamic>.from(raw as Map));
    }
  }

  Future<void> _upsertUnit(Map<String, dynamic> row) async {
    final uuid = row['client_uuid'] as String;
    final existing = await (db.select(db.unitRows)..where((t) => t.clientUuid.equals(uuid))).getSingleOrNull();
    final companion = UnitRowsCompanion(
      serverId: Value(_int(row['id'])),
      nameEn: Value(row['name_en']?.toString() ?? ''),
      nameUr: Value(row['name_ur']?.toString() ?? ''),
      shortName: Value(row['short_name']?.toString() ?? ''),
      updatedAt: Value(row['updated_at']?.toString()),
    );
    if (existing == null) {
      await db.into(db.unitRows).insert(UnitRowsCompanion.insert(
            serverId: Value(_int(row['id'])),
            clientUuid: uuid,
            nameEn: row['name_en']?.toString() ?? '',
            nameUr: Value(row['name_ur']?.toString() ?? ''),
            shortName: row['short_name']?.toString() ?? '',
            updatedAt: Value(row['updated_at']?.toString()),
          ));
    } else {
      await (db.update(db.unitRows)..where((t) => t.id.equals(existing.id))).write(companion);
    }
  }

  Future<void> _upsertCategory(Map<String, dynamic> row) async {
    final companion = CategoryRowsCompanion(
      serverId: Value(_int(row['id'])),
      nameEn: Value(row['name_en']?.toString() ?? ''),
      nameUr: Value(row['name_ur']?.toString() ?? ''),
      code: Value(row['code']?.toString()),
      parentServerId: Value(_int(row['parent_id'])),
      parentClientUuid: Value(row['parent_client_uuid']?.toString()),
      isActive: Value(row['is_active'] != false),
      updatedAt: Value(row['updated_at']?.toString()),
    );
    final uuid = row['client_uuid'] as String;
    final existing = await (db.select(db.categoryRows)..where((t) => t.clientUuid.equals(uuid))).getSingleOrNull();
    if (existing == null) {
      await db.into(db.categoryRows).insert(CategoryRowsCompanion.insert(
            serverId: Value(_int(row['id'])),
            clientUuid: uuid,
            nameEn: row['name_en']?.toString() ?? '',
            nameUr: Value(row['name_ur']?.toString() ?? ''),
            code: Value(row['code']?.toString()),
            parentServerId: Value(_int(row['parent_id'])),
            parentClientUuid: Value(row['parent_client_uuid']?.toString()),
            isActive: Value(row['is_active'] != false),
            updatedAt: Value(row['updated_at']?.toString()),
          ));
    } else {
      await (db.update(db.categoryRows)..where((t) => t.id.equals(existing.id))).write(companion);
    }
  }

  Future<void> _upsertBrand(Map<String, dynamic> row) async {
    final uuid = row['client_uuid'] as String;
    final existing = await (db.select(db.brandRows)..where((t) => t.clientUuid.equals(uuid))).getSingleOrNull();
    final companion = BrandRowsCompanion(
      serverId: Value(_int(row['id'])),
      nameEn: Value(row['name_en']?.toString() ?? ''),
      nameUr: Value(row['name_ur']?.toString() ?? ''),
      code: Value(row['code']?.toString()),
      isActive: Value(row['is_active'] != false),
      updatedAt: Value(row['updated_at']?.toString()),
    );
    if (existing == null) {
      await db.into(db.brandRows).insert(BrandRowsCompanion.insert(
            serverId: Value(_int(row['id'])),
            clientUuid: uuid,
            nameEn: row['name_en']?.toString() ?? '',
            nameUr: Value(row['name_ur']?.toString() ?? ''),
            code: Value(row['code']?.toString()),
            isActive: Value(row['is_active'] != false),
            updatedAt: Value(row['updated_at']?.toString()),
          ));
    } else {
      await (db.update(db.brandRows)..where((t) => t.id.equals(existing.id))).write(companion);
    }
  }

  Future<void> _upsertProduct(Map<String, dynamic> row) async {
    final uuid = row['client_uuid'] as String;
    final existing = await (db.select(db.productRows)..where((t) => t.clientUuid.equals(uuid))).getSingleOrNull();
    final companion = ProductRowsCompanion(
      serverId: Value(_int(row['id'])),
      code: Value(row['code']?.toString() ?? ''),
      barcode: Value(row['barcode']?.toString()),
      nameEn: Value(row['name_en']?.toString() ?? ''),
      nameUr: Value(row['name_ur']?.toString() ?? ''),
      categoryServerId: Value(_int(row['category_id'])),
      categoryClientUuid: Value(row['category_client_uuid']?.toString()),
      brandServerId: Value(_int(row['brand_id'])),
      brandClientUuid: Value(row['brand_client_uuid']?.toString()),
      unitServerId: Value(_int(row['unit_id'])),
      unitClientUuid: Value(row['unit_client_uuid']?.toString()),
      unitShortName: Value(row['unit_short_name']?.toString() ?? ''),
      purchasePrice: Value(Fixed.money(row['purchase_price'])),
      salePrice: Value(Fixed.money(row['sale_price'])),
      wholesalePrice: Value(Fixed.money(row['wholesale_price'])),
      alertQty: Value(Fixed.qty(row['alert_qty'])),
      trackStock: Value(row['track_stock'] != false),
      isActive: Value(row['is_active'] != false),
      updatedAt: Value(row['updated_at']?.toString()),
    );
    if (existing == null) {
      await db.into(db.productRows).insert(companion.copyWith(clientUuid: Value(uuid)));
    } else {
      await (db.update(db.productRows)..where((t) => t.id.equals(existing.id))).write(companion);
    }
  }

  Future<void> _upsertBranches(List rows) async {
    for (final raw in rows) {
      await _upsertBranch(Map<String, dynamic>.from(raw as Map));
    }
  }

  Future<void> _upsertBranch(Map<String, dynamic> row) async {
    final uuid = row['client_uuid'] as String;
    final existing = await (db.select(db.branchRows)..where((t) => t.clientUuid.equals(uuid))).getSingleOrNull();
    final companion = BranchRowsCompanion(
      serverId: Value(_int(row['id'])),
      name: Value(row['name']?.toString() ?? ''),
      code: Value(row['code']?.toString()),
      isMain: Value(row['is_main'] == true),
      isActive: Value(row['is_active'] != false),
      updatedAt: Value(row['updated_at']?.toString()),
    );
    if (existing == null) {
      await db.into(db.branchRows).insert(BranchRowsCompanion.insert(
            serverId: Value(_int(row['id'])),
            clientUuid: uuid,
            name: row['name']?.toString() ?? '',
            code: Value(row['code']?.toString()),
            isMain: Value(row['is_main'] == true),
            isActive: Value(row['is_active'] != false),
            updatedAt: Value(row['updated_at']?.toString()),
          ));
    } else {
      await (db.update(db.branchRows)..where((t) => t.id.equals(existing.id))).write(companion);
    }
  }

  Future<void> _upsertLocations(List rows) async {
    for (final raw in rows) {
      await _upsertLocation(Map<String, dynamic>.from(raw as Map));
    }
  }

  Future<void> _upsertLocation(Map<String, dynamic> row) async {
    final uuid = row['client_uuid'] as String;
    final existing = await (db.select(db.locationRows)..where((t) => t.clientUuid.equals(uuid))).getSingleOrNull();
    final companion = LocationRowsCompanion(
      serverId: Value(_int(row['id'])),
      branchServerId: Value(_int(row['branch_id'])),
      branchClientUuid: Value(row['branch_client_uuid']?.toString()),
      name: Value(row['name']?.toString() ?? ''),
      isDefault: Value(row['is_default'] == true),
      isActive: Value(row['is_active'] != false),
      updatedAt: Value(row['updated_at']?.toString()),
    );
    if (existing == null) {
      await db.into(db.locationRows).insert(LocationRowsCompanion.insert(
            serverId: Value(_int(row['id'])),
            clientUuid: uuid,
            branchServerId: Value(_int(row['branch_id'])),
            branchClientUuid: Value(row['branch_client_uuid']?.toString()),
            name: row['name']?.toString() ?? '',
            isDefault: Value(row['is_default'] == true),
            isActive: Value(row['is_active'] != false),
            updatedAt: Value(row['updated_at']?.toString()),
          ));
    } else {
      await (db.update(db.locationRows)..where((t) => t.id.equals(existing.id))).write(companion);
    }
  }

  Future<void> _upsertDocuments(dynamic rows, String entity) async {
    for (final raw in rows as List? ?? []) {
      final row = Map<String, dynamic>.from(raw as Map);
      final uuid = row['client_uuid']?.toString();
      if (uuid == null) continue;
      final existing = await (db.select(db.documentRows)..where((t) => t.entity.equals(entity) & t.clientUuid.equals(uuid))).getSingleOrNull();
      if (existing != null && existing.pending) continue;
      final companion = DocumentRowsCompanion(
        serverId: Value(_int(row['id'])),
        payload: Value(jsonEncode(row)),
        pending: const Value(false),
        updatedAt: Value(row['updated_at']?.toString()),
      );
      if (existing == null) {
        await db.into(db.documentRows).insert(DocumentRowsCompanion.insert(
              serverId: Value(_int(row['id'])),
              entity: entity,
              clientUuid: uuid,
              payload: jsonEncode(row),
              pending: const Value(false),
              updatedAt: Value(row['updated_at']?.toString()),
            ));
      } else {
        await (db.update(db.documentRows)..where((t) => t.id.equals(existing.id))).write(companion);
      }
    }
  }

  Future<void> _upsertEvents(List rows) async {
    for (final raw in rows) {
      final row = Map<String, dynamic>.from(raw as Map);
      final uuid = row['client_uuid']?.toString();
      if (uuid == null) continue;
      final branchUuid = await _branchUuid(_int(row['branch_id']));
      final productUuid = row['product_client_uuid']?.toString() ?? await _productUuid(_int(row['product_id']));
      final companion = EventRowsCompanion(
        serverId: Value(_int(row['id'])),
        branchServerId: Value(_int(row['branch_id'])),
        branchClientUuid: Value(branchUuid),
        branchName: Value(row['branch_name']?.toString() ?? ''),
        productServerId: Value(_int(row['product_id'])),
        productClientUuid: Value(productUuid),
        productName: Value(row['product_name']?.toString() ?? ''),
        productCode: Value(row['product_code']?.toString() ?? ''),
        eventType: Value(row['event_type']?.toString() ?? ''),
        qty: Value(Fixed.qty(row['qty'])),
        unitCost: Value(Fixed.cost(row['unit_cost'])),
        value: Value(Fixed.money(row['value'])),
        runningBalance: Value(Fixed.qty(row['running_balance'])),
        sourceType: Value(row['source_type']?.toString()),
        sourceUuid: Value(row['source_uuid']?.toString()),
        reason: Value(row['reason']?.toString()),
        operatorName: Value(row['operator_name']?.toString()),
        occurredAt: Value(row['occurred_at']?.toString() ?? ''),
        syncStatus: const Value('synced'),
        locationServerId: Value(_int(row['location_id'])),
        locationName: Value(row['location_name']?.toString()),
        fromLocationName: Value(row['from_location_name']?.toString()),
        toLocationName: Value(row['to_location_name']?.toString()),
      );
      final existing = await (db.select(db.eventRows)..where((t) => t.clientUuid.equals(uuid))).getSingleOrNull();
      if (existing == null) {
        await db.into(db.eventRows).insert(EventRowsCompanion.insert(
              serverId: Value(_int(row['id'])),
              clientUuid: uuid,
              branchServerId: Value(_int(row['branch_id'])),
              branchClientUuid: Value(branchUuid),
              branchName: Value(row['branch_name']?.toString() ?? ''),
              productServerId: Value(_int(row['product_id'])),
              productClientUuid: Value(productUuid),
              productName: Value(row['product_name']?.toString() ?? ''),
              productCode: Value(row['product_code']?.toString() ?? ''),
              eventType: row['event_type']?.toString() ?? '',
              qty: Fixed.qty(row['qty']),
              unitCost: Value(Fixed.cost(row['unit_cost'])),
              value: Value(Fixed.money(row['value'])),
              runningBalance: Value(Fixed.qty(row['running_balance'])),
              sourceType: Value(row['source_type']?.toString()),
              sourceUuid: Value(row['source_uuid']?.toString()),
              reason: Value(row['reason']?.toString()),
              operatorName: Value(row['operator_name']?.toString()),
              occurredAt: row['occurred_at']?.toString() ?? '',
              syncStatus: const Value('synced'),
              locationServerId: Value(_int(row['location_id'])),
              locationName: Value(row['location_name']?.toString()),
              fromLocationName: Value(row['from_location_name']?.toString()),
              toLocationName: Value(row['to_location_name']?.toString()),
            ));
      } else {
        await (db.update(db.eventRows)..where((t) => t.id.equals(existing.id))).write(companion);
      }
    }
  }

  Future<void> _applyTombstone(Map<String, dynamic> tomb) async {
    final uuid = tomb['client_uuid']?.toString();
    if (uuid == null) return;
    switch (tomb['entity']) {
      case 'unit':
        await (db.delete(db.unitRows)..where((t) => t.clientUuid.equals(uuid))).go();
      case 'category':
        await (db.delete(db.categoryRows)..where((t) => t.clientUuid.equals(uuid))).go();
      case 'brand':
        await (db.delete(db.brandRows)..where((t) => t.clientUuid.equals(uuid))).go();
      case 'product':
        await (db.delete(db.productRows)..where((t) => t.clientUuid.equals(uuid))).go();
      case 'location':
        await (db.delete(db.locationRows)..where((t) => t.clientUuid.equals(uuid))).go();
    }
  }

  Future<void> _saveMaster({
    required int? existing,
    required Future<int> Function() insert,
    required Future<int> Function(int id) update,
    required String entity,
    required String uuid,
    required Map<String, dynamic> payload,
  }) async {
    if (existing == null) {
      await insert();
      await _enqueue(entity, 'create', uuid, payload);
    } else {
      await update(existing);
      await _enqueue(entity, 'update', uuid, payload);
    }
    await flush();
  }

  Future<void> _deleteMaster(String entity, String uuid, String? updatedAt, Future<void> Function() remove) async {
    final queued = await (db.select(db.outboxEntries)
          ..where((t) => t.clientUuid.equals(uuid) & t.entity.equals(entity) & t.status.isIn(['pending', 'error'])))
        .get();
    final neverSynced = queued.any((op) => op.action == 'create');
    await remove();
    if (queued.isNotEmpty) {
      await (db.delete(db.outboxEntries)..where((t) => t.clientUuid.equals(uuid) & t.entity.equals(entity) & t.status.isIn(['pending', 'error']))).go();
    }
    if (neverSynced) return;
    await _enqueue(entity, 'delete', uuid, {'client_uuid': uuid, 'base_updated_at': updatedAt});
    await flush();
  }

  String _systemAccountUuid(String code) {
    final n = int.parse(code).toString().padLeft(12, '0');
    return '10000000-0000-4000-8000-$n';
  }

  Future<void> _enqueue(String entity, String action, String uuid, Map<String, dynamic> payload) async {
    if (action == 'update') {
      // A newer edit replaces an older unsent one, so a rejected edit cannot block the queue forever.
      await (db.delete(db.outboxEntries)
            ..where((t) => t.entity.equals(entity) & t.clientUuid.equals(uuid) & t.action.equals('update') & t.status.isIn(['pending', 'error'])))
          .go();
    }
    await db.into(db.outboxEntries).insert(OutboxEntriesCompanion.insert(
          opId: _uuid.v4(),
          entity: entity,
          action: action,
          clientUuid: uuid,
          payload: jsonEncode(payload),
        ));
  }

  Future<Map<int, String>> _serverBranchMap() async {
    final rows = await db.select(db.branchRows).get();
    return {for (final row in rows) if (row.serverId != null) row.serverId!: row.clientUuid};
  }

  Future<Map<int, String>> _serverProductMap() async {
    final rows = await db.select(db.productRows).get();
    return {for (final row in rows) if (row.serverId != null) row.serverId!: row.clientUuid};
  }

  Future<Map<int, String>> _serverLocationMap() async {
    final rows = await db.select(db.locationRows).get();
    return {for (final row in rows) if (row.serverId != null) row.serverId!: row.clientUuid};
  }

  Future<String?> _branchUuid(int? id) async {
    if (id == null) return null;
    final row = await (db.select(db.branchRows)..where((t) => t.serverId.equals(id))).getSingleOrNull();
    return row?.clientUuid;
  }

  Future<String?> _productUuid(int? id) async {
    if (id == null) return null;
    final row = await (db.select(db.productRows)..where((t) => t.serverId.equals(id))).getSingleOrNull();
    return row?.clientUuid;
  }

  Future<String?> _readToken() async {
    try {
      return await _secure.read(key: 'pos360tech_token');
    } catch (_) {
      return _meta('token');
    }
  }

  Future<void> _writeToken(String? token) async {
    try {
      if (token == null || token.isEmpty) {
        await _secure.delete(key: 'pos360tech_token');
      } else {
        await _secure.write(key: 'pos360tech_token', value: token);
      }
    } catch (_) {}
    await _setMeta('token', token ?? '');
  }

  Future<String?> _meta(String key) async {
    final row = await (db.select(db.metaEntries)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> _setMeta(String key, String value) async {
    await db.into(db.metaEntries).insertOnConflictUpdate(MetaEntriesCompanion.insert(key: key, value: value));
  }

  int? _int(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  String _csv(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }
}
