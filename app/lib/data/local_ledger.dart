import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../core/database.dart';
import '../core/money.dart';

class LocalLedger {
  LocalLedger(this.db);

  final AppDatabase db;
  final Uuid _uuid = const Uuid();

  Future<void> project(String entity, Map<String, dynamic> payload, {String? operatorName}) async {
    switch (entity) {
      case 'stock_adjustment':
        await _adjustment(payload, operatorName);
      case 'stock_write_off':
        await _writeOff(payload, operatorName);
      case 'stock_transfer':
        await _transfer(payload, operatorName);
      case 'location_move':
        await _move(payload, operatorName);
      case 'purchase':
        await _purchase(payload, operatorName);
      case 'purchase_return':
        await _purchaseReturn(payload, operatorName);
      case 'sale':
        await _sale(payload, operatorName);
      default:
        throw StateError('Unknown stock document.');
    }
  }

  Future<void> _adjustment(Map<String, dynamic> payload, String? operatorName) async {
    final kind = payload['kind'] as String;
    final inbound = kind == 'opening' || kind == 'increase';
    final type = switch (kind) {
      'opening' => 'opening',
      'increase' => 'adjustment_in',
      _ => 'adjustment_out',
    };
    final branch = payload['branch_client_uuid'] as String;
    final location = await _locationOrDefault(branch, payload['location_client_uuid'] as String?);
    for (final line in _lines(payload)) {
      if (inbound) {
        await _receive(
          branch: branch,
          location: location,
          productUuid: line['product_client_uuid'] as String,
          qty: Fixed.n(line['qty']),
          unitCost: Fixed.n(line['unit_cost']),
          type: type,
          sourceUuid: payload['client_uuid'] as String,
          reason: payload['reason'] as String?,
          occurredAt: payload['occurred_at'] as String,
          operatorName: operatorName,
        );
      } else {
        await _issue(
          branch: branch,
          location: location,
          productUuid: line['product_client_uuid'] as String,
          qty: Fixed.n(line['qty']),
          type: type,
          sourceUuid: payload['client_uuid'] as String,
          reason: payload['reason'] as String?,
          occurredAt: payload['occurred_at'] as String,
          operatorName: operatorName,
        );
      }
    }
  }

  Future<void> _purchase(Map<String, dynamic> payload, String? operatorName) async {
    final branch = payload['branch_client_uuid'] as String;
    final location = await _locationOrDefault(branch, payload['location_client_uuid'] as String?);
    final updateCost = payload['update_cost'] != false;
    for (final line in _lines(payload)) {
      final productUuid = line['product_client_uuid'] as String;
      final qty = Fixed.n(line['qty']);
      final unitCost = Fixed.n(line['unit_cost']);
      await _receive(
        branch: branch,
        location: location,
        productUuid: productUuid,
        qty: qty,
        unitCost: unitCost,
        type: 'purchase',
        sourceUuid: payload['client_uuid'] as String,
        reason: payload['invoice_no'] as String?,
        occurredAt: payload['occurred_at'] as String,
        operatorName: operatorName,
      );
      final sale = line['new_sale_price'];
      final wholesale = line['new_wholesale'];
      await (db.update(db.productRows)..where((t) => t.clientUuid.equals(productUuid))).write(ProductRowsCompanion(
            purchasePrice: updateCost ? Value(Fixed.money(unitCost)) : const Value.absent(),
            salePrice: sale == null || sale.toString().trim().isEmpty ? const Value.absent() : Value(Fixed.money(sale)),
            wholesalePrice: wholesale == null || wholesale.toString().trim().isEmpty ? const Value.absent() : Value(Fixed.money(wholesale)),
          ));
    }
  }

  Future<void> _purchaseReturn(Map<String, dynamic> payload, String? operatorName) async {
    final branch = payload['branch_client_uuid'] as String;
    final location = await _locationOrDefault(branch, payload['location_client_uuid'] as String?);
    for (final line in _lines(payload)) {
      await _issue(
        branch: branch,
        location: location,
        productUuid: line['product_client_uuid'] as String,
        qty: Fixed.n(line['qty']),
        type: 'purchase_return',
        sourceUuid: payload['client_uuid'] as String,
        reason: payload['note'] as String?,
        occurredAt: payload['occurred_at'] as String,
        operatorName: operatorName,
      );
    }
  }

  Future<void> _sale(Map<String, dynamic> payload, String? operatorName) async {
    final branch = payload['branch_client_uuid'] as String;
    final location = await _locationOrDefault(branch, payload['location_client_uuid'] as String?);
    for (final line in _lines(payload)) {
      final productUuid = line['product_client_uuid']?.toString() ?? '';
      if (productUuid.isEmpty) continue;
      final product = await (db.select(db.productRows)..where((t) => t.clientUuid.equals(productUuid))).getSingleOrNull();
      if (product != null && !product.trackStock) continue;
      if (line['is_return'] == true) {
        await _receive(
          branch: branch,
          location: location,
          productUuid: productUuid,
          qty: Fixed.n(line['qty']),
          unitCost: Fixed.n(line['unit_cost'] ?? product?.purchasePrice),
          type: 'sale_return',
          sourceUuid: payload['client_uuid'] as String,
          reason: payload['invoice_no'] as String?,
          occurredAt: payload['occurred_at'] as String,
          operatorName: operatorName,
        );
        continue;
      }
      await _issue(
        branch: branch,
        location: location,
        productUuid: productUuid,
        qty: Fixed.n(line['qty']),
        type: 'sale',
        sourceUuid: payload['client_uuid'] as String,
        reason: payload['invoice_no'] as String?,
        occurredAt: payload['occurred_at'] as String,
        operatorName: operatorName,
      );
    }
  }

  Future<void> _writeOff(Map<String, dynamic> payload, String? operatorName) async {
    final branch = payload['branch_client_uuid'] as String;
    final location = await _locationOrDefault(branch, payload['location_client_uuid'] as String?);
    for (final line in _lines(payload)) {
      await _issue(
        branch: branch,
        location: location,
        productUuid: line['product_client_uuid'] as String,
        qty: Fixed.n(line['qty']),
        type: 'write_off',
        sourceUuid: payload['client_uuid'] as String,
        reason: payload['reason'] as String?,
        occurredAt: payload['occurred_at'] as String,
        operatorName: operatorName,
      );
    }
  }

  Future<void> _transfer(Map<String, dynamic> payload, String? operatorName) async {
    final from = payload['from_branch_client_uuid'] as String;
    final to = payload['to_branch_client_uuid'] as String;
    final fromLocation = await _locationOrDefault(from, payload['from_location_client_uuid'] as String?);
    final toLocation = await _locationOrDefault(to, payload['to_location_client_uuid'] as String?);
    for (final line in _lines(payload)) {
      final slices = await _issue(
        branch: from,
        location: fromLocation,
        productUuid: line['product_client_uuid'] as String,
        qty: Fixed.n(line['qty']),
        type: 'transfer_out',
        sourceUuid: payload['client_uuid'] as String,
        reason: payload['reason'] as String?,
        occurredAt: payload['occurred_at'] as String,
        operatorName: operatorName,
      );
      var qty = 0.0;
      var value = 0.0;
      for (final slice in slices) {
        qty += slice.$1;
        value += slice.$1 * slice.$2;
      }
      await _receiveSlices(
        branch: to,
        location: toLocation,
        productUuid: line['product_client_uuid'] as String,
        slices: slices,
        totalQty: qty,
        totalValue: value,
        type: 'transfer_in',
        sourceUuid: payload['client_uuid'] as String,
        reason: payload['reason'] as String?,
        occurredAt: payload['occurred_at'] as String,
        operatorName: operatorName,
      );
    }
  }

  Future<void> _move(Map<String, dynamic> payload, String? operatorName) async {
    final branch = payload['branch_client_uuid'] as String;
    final from = payload['from_location_client_uuid'] as String;
    final to = payload['to_location_client_uuid'] as String;
    for (final line in _lines(payload)) {
      final productUuid = line['product_client_uuid'] as String;
      final qty = Fixed.n(line['qty']);
      final balance = await _balance(branch, productUuid);
      await _addBin(from, productUuid, -qty);
      await _addBin(to, productUuid, qty);
      final product = await _product(productUuid);
      final branchRow = await _branch(branch);
      final fromRow = await _location(from);
      final toRow = await _location(to);
      await db.into(db.eventRows).insert(EventRowsCompanion.insert(
            clientUuid: _uuid.v4(),
            branchServerId: Value(branchRow?.serverId),
            branchClientUuid: Value(branch),
            branchName: Value(branchRow?.name ?? ''),
            productServerId: Value(product?.serverId),
            productClientUuid: Value(productUuid),
            productName: Value(product?.nameEn ?? ''),
            productCode: Value(product?.code ?? ''),
            eventType: 'location_move',
            qty: Fixed.qty(qty),
            unitCost: const Value('0.0000'),
            value: const Value('0.00'),
            runningBalance: Value(Fixed.qty(balance)),
            sourceType: const Value('location_move'),
            sourceUuid: Value(payload['client_uuid'] as String),
            reason: Value(payload['reason'] as String?),
            operatorName: Value(operatorName),
            occurredAt: payload['occurred_at'] as String,
            syncStatus: const Value('pending'),
            locationName: Value(fromRow?.name),
            fromLocationName: Value(fromRow?.name),
            toLocationName: Value(toRow?.name),
          ));
    }
  }

  Future<List<(double, double)>> _issue({
    required String branch,
    required String? location,
    required String productUuid,
    required double qty,
    required String type,
    required String sourceUuid,
    required String? reason,
    required String occurredAt,
    required String? operatorName,
  }) async {
    if (qty <= 0) throw StateError('Quantity must be greater than zero.');
    final product = await _product(productUuid);
    final layers = await _layers(branch, productUuid);
    var need = qty;
    var value = 0.0;
    final slices = <(double, double)>[];
    for (final layer in layers.where((row) => Fixed.n(row.qtyRemaining) > 0)) {
      if (need <= 0) break;
      final have = Fixed.n(layer.qtyRemaining);
      final take = have < need ? have : need;
      final left = have - take;
      if (left <= 0.0000001) {
        await (db.delete(db.layerRows)..where((t) => t.id.equals(layer.id))).go();
      } else {
        await (db.update(db.layerRows)..where((t) => t.id.equals(layer.id))).write(
          LayerRowsCompanion(qtyRemaining: Value(Fixed.qty(left))),
        );
      }
      value += take * Fixed.n(layer.unitCost);
      slices.add((take, Fixed.n(layer.unitCost)));
      need -= take;
    }
    if (need > 0.0000001) {
      final fallback = Fixed.n(product?.purchasePrice);
      value += need * fallback;
      slices.add((need, fallback));
      await db.into(db.layerRows).insert(LayerRowsCompanion.insert(
            branchClientUuid: branch,
            productClientUuid: productUuid,
            qtyRemaining: Fixed.qty(-need),
            unitCost: Fixed.cost(fallback),
            receivedAt: occurredAt,
          ));
    }
    final before = await _balance(branch, productUuid);
    final after = before - qty;
    await _setBalance(branch, productUuid, after);
    if (location != null) await _addBin(location, productUuid, -qty);
    await _event(
      branch: branch,
      product: product,
      productUuid: productUuid,
      type: type,
      qty: -qty,
      unitCost: qty == 0 ? 0 : value / qty,
      value: -value,
      balance: after,
      sourceUuid: sourceUuid,
      reason: reason,
      occurredAt: occurredAt,
      operatorName: operatorName,
    );
    return slices;
  }

  Future<void> _receive({
    required String branch,
    required String? location,
    required String productUuid,
    required double qty,
    required double unitCost,
    required String type,
    required String sourceUuid,
    required String? reason,
    required String occurredAt,
    required String? operatorName,
  }) {
    return _receiveSlices(
      branch: branch,
      location: location,
      productUuid: productUuid,
      slices: [(qty, unitCost)],
      totalQty: qty,
      totalValue: qty * unitCost,
      type: type,
      sourceUuid: sourceUuid,
      reason: reason,
      occurredAt: occurredAt,
      operatorName: operatorName,
    );
  }

  Future<void> _receiveSlices({
    required String branch,
    required String? location,
    required String productUuid,
    required List<(double, double)> slices,
    required double totalQty,
    required double totalValue,
    required String type,
    required String sourceUuid,
    required String? reason,
    required String occurredAt,
    required String? operatorName,
  }) async {
    if (totalQty <= 0) throw StateError('Quantity must be greater than zero.');
    final product = await _product(productUuid);
    final layers = await _layers(branch, productUuid);
    var skip = 0.0;
    for (final layer in layers.where((row) => Fixed.n(row.qtyRemaining) < 0)) {
      final hole = Fixed.n(layer.qtyRemaining).abs();
      final fill = hole < (totalQty - skip) ? hole : (totalQty - skip);
      final next = Fixed.n(layer.qtyRemaining) + fill;
      if (next.abs() <= 0.0000001) {
        await (db.delete(db.layerRows)..where((t) => t.id.equals(layer.id))).go();
      } else {
        await (db.update(db.layerRows)..where((t) => t.id.equals(layer.id))).write(
          LayerRowsCompanion(qtyRemaining: Value(Fixed.qty(next))),
        );
      }
      skip += fill;
      if (skip >= totalQty) break;
    }
    var remainingSkip = skip;
    for (final slice in slices) {
      var sliceQty = slice.$1;
      if (remainingSkip > 0) {
        if (sliceQty <= remainingSkip) {
          remainingSkip -= sliceQty;
          continue;
        }
        sliceQty -= remainingSkip;
        remainingSkip = 0;
      }
      if (sliceQty > 0) {
        await db.into(db.layerRows).insert(LayerRowsCompanion.insert(
              branchClientUuid: branch,
              productClientUuid: productUuid,
              qtyRemaining: Fixed.qty(sliceQty),
              unitCost: Fixed.cost(slice.$2),
              receivedAt: occurredAt,
            ));
      }
    }
    final before = await _balance(branch, productUuid);
    final after = before + totalQty;
    await _setBalance(branch, productUuid, after);
    if (location != null) await _addBin(location, productUuid, totalQty);
    await _event(
      branch: branch,
      product: product,
      productUuid: productUuid,
      type: type,
      qty: totalQty,
      unitCost: totalValue / totalQty,
      value: totalValue,
      balance: after,
      sourceUuid: sourceUuid,
      reason: reason,
      occurredAt: occurredAt,
      operatorName: operatorName,
    );
  }

  Future<void> _event({
    required String branch,
    required ProductRow? product,
    required String productUuid,
    required String type,
    required double qty,
    required double unitCost,
    required double value,
    required double balance,
    required String sourceUuid,
    required String? reason,
    required String occurredAt,
    required String? operatorName,
  }) async {
    final branchRow = await _branch(branch);
    await db.into(db.eventRows).insert(EventRowsCompanion.insert(
          clientUuid: _uuid.v4(),
          branchServerId: Value(branchRow?.serverId),
          branchClientUuid: Value(branch),
          branchName: Value(branchRow?.name ?? ''),
          productServerId: Value(product?.serverId),
          productClientUuid: Value(productUuid),
          productName: Value(product?.nameEn ?? ''),
          productCode: Value(product?.code ?? ''),
          eventType: type,
          qty: Fixed.qty(qty),
          unitCost: Value(Fixed.cost(unitCost)),
          value: Value(Fixed.money(value)),
          runningBalance: Value(Fixed.qty(balance)),
          sourceType: Value(type == 'transfer_in' || type == 'transfer_out' ? 'stock_transfer' : type == 'write_off' ? 'stock_write_off' : type == 'location_move' ? 'location_move' : 'stock_adjustment'),
          sourceUuid: Value(sourceUuid),
          reason: Value(reason),
          operatorName: Value(operatorName),
          occurredAt: occurredAt,
          syncStatus: const Value('pending'),
        ));
    await _refreshValue(branch, productUuid);
  }

  Future<void> _refreshValue(String branch, String product) async {
    final layers = await _layers(branch, product);
    var value = 0.0;
    for (final layer in layers) {
      value += Fixed.n(layer.qtyRemaining) * Fixed.n(layer.unitCost);
    }
    final existing = await _balanceRow(branch, product);
    if (existing == null) return;
    await (db.update(db.balanceRows)..where((t) => t.id.equals(existing.id))).write(
      BalanceRowsCompanion(stockValue: Value(Fixed.money(value))),
    );
  }

  Future<double> _balance(String branch, String product) async {
    return Fixed.n((await _balanceRow(branch, product))?.qtyOnHand);
  }

  Future<BalanceRow?> _balanceRow(String branch, String product) {
    return (db.select(db.balanceRows)
          ..where((t) => t.branchClientUuid.equals(branch) & t.productClientUuid.equals(product)))
        .getSingleOrNull();
  }

  Future<void> _setBalance(String branch, String product, double qty) async {
    final existing = await _balanceRow(branch, product);
    if (existing == null) {
      await db.into(db.balanceRows).insert(BalanceRowsCompanion.insert(
            branchClientUuid: branch,
            productClientUuid: product,
            qtyOnHand: Fixed.qty(qty),
            stockValue: '0.00',
          ));
    } else {
      await (db.update(db.balanceRows)..where((t) => t.id.equals(existing.id))).write(
        BalanceRowsCompanion(qtyOnHand: Value(Fixed.qty(qty))),
      );
    }
  }

  Future<void> _addBin(String location, String product, double delta) async {
    final existing = await (db.select(db.binRows)
          ..where((t) => t.locationClientUuid.equals(location) & t.productClientUuid.equals(product)))
        .getSingleOrNull();
    final next = Fixed.n(existing?.qtyOnHand) + delta;
    if (existing == null) {
      await db.into(db.binRows).insert(BinRowsCompanion.insert(
            locationClientUuid: location,
            productClientUuid: product,
            qtyOnHand: Fixed.qty(next),
          ));
    } else {
      await (db.update(db.binRows)..where((t) => t.id.equals(existing.id))).write(
        BinRowsCompanion(qtyOnHand: Value(Fixed.qty(next))),
      );
    }
  }

  Future<List<LayerRow>> _layers(String branch, String product) async {
    final rows = await (db.select(db.layerRows)
          ..where((t) => t.branchClientUuid.equals(branch) & t.productClientUuid.equals(product)))
        .get();
    rows.sort((a, b) => a.receivedAt.compareTo(b.receivedAt));
    return rows;
  }

  Future<ProductRow?> _product(String uuid) {
    return (db.select(db.productRows)..where((t) => t.clientUuid.equals(uuid))).getSingleOrNull();
  }

  Future<BranchRow?> _branch(String uuid) {
    return (db.select(db.branchRows)..where((t) => t.clientUuid.equals(uuid))).getSingleOrNull();
  }

  Future<LocationRow?> _location(String uuid) {
    return (db.select(db.locationRows)..where((t) => t.clientUuid.equals(uuid))).getSingleOrNull();
  }

  Future<String?> _locationOrDefault(String branch, String? preferred) async {
    if (preferred != null && preferred.isNotEmpty) return preferred;
    final rows = await (db.select(db.locationRows)..where((t) => t.branchClientUuid.equals(branch))).get();
    for (final row in rows) {
      if (row.isDefault) return row.clientUuid;
    }
    return rows.isEmpty ? null : rows.first.clientUuid;
  }

  List<Map<String, dynamic>> _lines(Map<String, dynamic> payload) {
    final lines = payload['lines'];
    if (lines is! List || lines.isEmpty) {
      throw StateError('Add at least one product line.');
    }
    return lines.cast<Map<String, dynamic>>();
  }
}
