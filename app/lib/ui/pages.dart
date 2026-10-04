import 'dart:convert';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../core/database.dart';
import '../core/l10n.dart';
import '../core/money.dart';
import 'form_sheet.dart';
import 'save_file.dart';

part 'money_pages.dart';
part 'trade_pages.dart';
part 'shop_pages.dart';
part 'ops_pages.dart';
part 'pos_terminal.dart';
part 'settings_pages.dart';
part 'dashboard_page.dart';

class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final rows = ref.watch(_products).value ?? <ProductRow>[];
    final categories = ref.watch(_categories).value ?? <CategoryRow>[];
    final session = ref.watch(sessionProvider).value;
    final symbol = ref.watch(moneySymbolProvider);
    return _page(
      context,
      l10n.t('products'),
      _table(
        context,
        [l10n.t('code'), l10n.t('itemName'), l10n.t('category'), l10n.t('purchasePrice'), l10n.t('salePrice'), l10n.t('unit')],
        rows.map((row) {
          final category = categories.where((item) => item.clientUuid == row.categoryClientUuid).map((item) => item.nameEn).firstOrNull ?? '';
          return [row.code, _bilingual(row.nameEn, row.nameUr), category, Fixed.rs(row.purchasePrice, symbol), Fixed.rs(row.salePrice, symbol), row.unitShortName];
        }).toList(),
        rows.isEmpty ? l10n.t('noRecords') : null,
        onEdit: session?.canManage == true
            ? (index) => _productDialog(context, ref, existing: rows[index])
            : null,
        onDelete: session?.canManage == true ? (index) => ref.read(storeProvider).deleteProduct(rows[index]) : null,
      ),
      action: session?.canManage == true ? FilledButton(onPressed: () => _productDialog(context, ref), child: Text(l10n.t('add'))) : null,
    );
  }
}

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final rows = ref.watch(_categories).value ?? <CategoryRow>[];
    final session = ref.watch(sessionProvider).value;
    return _page(
      context,
      l10n.t('categories'),
      _table(
        context,
        [l10n.t('itemName'), l10n.t('code'), l10n.t('status')],
        rows.map((row) => [_bilingual(row.nameEn, row.nameUr), row.code ?? '', row.isActive ? l10n.t('active') : '']).toList(),
        rows.isEmpty ? l10n.t('noRecords') : null,
        onEdit: session?.canManage == true ? (index) => _categoryDialog(context, ref, existing: rows[index]) : null,
        onDelete: session?.canManage == true ? (index) => ref.read(storeProvider).deleteCategory(rows[index]) : null,
      ),
      action: session?.canManage == true ? FilledButton(onPressed: () => _categoryDialog(context, ref), child: Text(l10n.t('add'))) : null,
    );
  }
}

class BrandsPage extends ConsumerWidget {
  const BrandsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final rows = ref.watch(_brands).value ?? <BrandRow>[];
    final session = ref.watch(sessionProvider).value;
    return _page(
      context,
      l10n.t('brands'),
      _table(
        context,
        [l10n.t('itemName'), l10n.t('code'), l10n.t('status')],
        rows.map((row) => [_bilingual(row.nameEn, row.nameUr), row.code ?? '', row.isActive ? l10n.t('active') : '']).toList(),
        rows.isEmpty ? l10n.t('noRecords') : null,
        onEdit: session?.canManage == true ? (index) => _brandDialog(context, ref, existing: rows[index]) : null,
        onDelete: session?.canManage == true ? (index) => ref.read(storeProvider).deleteBrand(rows[index]) : null,
      ),
      action: session?.canManage == true ? FilledButton(onPressed: () => _brandDialog(context, ref), child: Text(l10n.t('add'))) : null,
    );
  }
}

class UnitsPage extends ConsumerWidget {
  const UnitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final rows = ref.watch(_units).value ?? <UnitRow>[];
    final session = ref.watch(sessionProvider).value;
    return _page(
      context,
      l10n.t('units'),
      _table(
        context,
        [l10n.t('itemName'), l10n.t('shortName')],
        rows.map((row) => [_bilingual(row.nameEn, row.nameUr), row.shortName]).toList(),
        rows.isEmpty ? l10n.t('noRecords') : null,
        onEdit: session?.canManage == true ? (index) => _unitDialog(context, ref, existing: rows[index]) : null,
        onDelete: session?.canManage == true ? (index) => ref.read(storeProvider).deleteUnit(rows[index]) : null,
      ),
      action: session?.canManage == true ? FilledButton(onPressed: () => _unitDialog(context, ref), child: Text(l10n.t('add'))) : null,
    );
  }
}

class StockPage extends ConsumerWidget {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    final branch = ref.watch(branchProvider);
    final products = ref.watch(_products).value ?? <ProductRow>[];
    final balances = ref.watch(_balances).value ?? <BalanceRow>[];
    final events = ref.watch(_events).value ?? <EventRow>[];
    final categories = ref.watch(_categories).value ?? <CategoryRow>[];
    final summary = _summary(products, balances, events, branch);
    final rows = <List<String>>[];
    for (final product in products) {
      final scoped = balances.where((row) => row.productClientUuid == product.clientUuid && (branch == null || row.branchClientUuid == branch));
      final qty = scoped.fold<double>(0, (sum, row) => sum + Fixed.n(row.qtyOnHand));
      final value = scoped.fold<double>(0, (sum, row) => sum + Fixed.n(row.stockValue));
      final category = categories.where((row) => row.clientUuid == product.categoryClientUuid).map((row) => row.nameEn).firstOrNull ?? '';
      rows.add([
        product.nameEn,
        product.code,
        category,
        Fixed.rs(product.purchasePrice, symbol),
        Fixed.qty(qty),
        Fixed.qty(product.alertQty),
        Fixed.rs(value, symbol),
        _alert(l10n, qty, Fixed.n(product.alertQty)),
      ]);
    }
    return _page(
      context,
      l10n.t('stock'),
      back: '/dashboard',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stockSwitch(context, l10n, '/stock'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _stat(l10n.t('productCount'), '${products.length}', const Color(0xFF1F2937), fill: const Color(0xFFF8FAFC)),
              _stat(l10n.t('inStock'), '${summary.$5}', const Color(0xFF15803D), fill: const Color(0xFFDCFCE7)),
              _stat(l10n.t('lowStock'), '${summary.$2}', const Color(0xFFB45309), fill: const Color(0xFFFEF3C7)),
              _stat(l10n.t('outOfStock'), '${summary.$3}', const Color(0xFFBE123C), fill: const Color(0xFFFFE4E6)),
              _stat(l10n.t('stockValue'), Fixed.rs(summary.$1, symbol), const Color(0xFF9A3412), fill: const Color(0xFFFFEDD5)),
              _stat(l10n.t('wastage'), Fixed.rs(summary.$4, symbol), const Color(0xFF0F766E), fill: const Color(0xFFCCFBF1)),
            ],
          ),
          const SizedBox(height: 12),
          _table(
            context,
            [l10n.t('itemName'), l10n.t('code'), l10n.t('category'), l10n.t('costPrice'), l10n.t('qty'), l10n.t('alertQty'), l10n.t('stockValue'), l10n.t('detail')],
            rows,
            rows.isEmpty ? l10n.t('noRecords') : null,
          ),
        ],
      ),
    );
  }
}

class LedgerPage extends ConsumerStatefulWidget {
  const LedgerPage({super.key});

  @override
  ConsumerState<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends ConsumerState<LedgerPage> {
  String? _product;
  String? _type;
  final _q = TextEditingController();

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final branch = ref.watch(branchProvider);
    final products = ref.watch(_products).value ?? <ProductRow>[];
    final events = (ref.watch(_events).value ?? <EventRow>[]).where((event) {
      if (branch != null && event.branchClientUuid != branch) return false;
      if (_product != null && event.productClientUuid != _product) return false;
      if (_type != null && event.eventType != _type) return false;
      final query = _q.text.trim().toLowerCase();
      if (query.isEmpty) return true;
      return (event.reason ?? '').toLowerCase().contains(query) ||
          (event.sourceType ?? '').toLowerCase().contains(query) ||
          (event.sourceUuid ?? '').toLowerCase().contains(query);
    }).toList();
    return _page(
      context,
      l10n.t('ledger'),
      back: '/stock',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.t('immutable')),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              DropdownButton<String?>(
                value: _product,
                hint: Text(l10n.t('products')),
                items: [
                  DropdownMenuItem(value: null, child: Text(l10n.t('products'))),
                  ...products.map((row) => DropdownMenuItem(value: row.clientUuid, child: Text(row.nameEn))),
                ],
                onChanged: (value) => setState(() => _product = value),
              ),
              DropdownButton<String?>(
                value: _type,
                hint: Text(l10n.t('type')),
                items: [
                  DropdownMenuItem(value: null, child: Text(l10n.t('type'))),
                  for (final type in ['opening', 'adjustment_in', 'adjustment_out', 'write_off', 'transfer_in', 'transfer_out', 'location_move'])
                    DropdownMenuItem(value: type, child: Text(type.replaceAll('_', ' '))),
                ],
                onChanged: (value) => setState(() => _type = value),
              ),
              SizedBox(width: 220, child: TextField(controller: _q, decoration: InputDecoration(labelText: l10n.t('source')), onChanged: (_) => setState(() {}))),
              OutlinedButton(onPressed: () => _export(events, false), child: Text(l10n.t('exportCsv'))),
              FilledButton(onPressed: () => _export(events, true), child: Text(l10n.t('exportPdf'))),
            ],
          ),
          const SizedBox(height: 12),
          _table(
            context,
            [l10n.t('date'), l10n.t('products'), l10n.t('branch'), l10n.t('type'), l10n.t('qty'), l10n.t('unitCost'), l10n.t('value'), l10n.t('balance'), l10n.t('source'), l10n.t('reason'), l10n.t('operator'), l10n.t('status')],
            events
                .map((event) => [
                      event.occurredAt,
                      event.productName,
                      event.branchName,
                      event.eventType.replaceAll('_', ' '),
                      event.qty,
                      event.unitCost,
                      event.value,
                      event.runningBalance,
                      event.sourceType ?? '',
                      event.reason ?? '',
                      event.operatorName ?? '',
                      event.syncStatus == 'pending' ? l10n.t('pendingSync') : l10n.t('synced'),
                    ])
                .toList(),
            events.isEmpty ? l10n.t('noRecords') : null,
          ),
        ],
      ),
    );
  }

  Future<void> _export(List<EventRow> events, bool pdf) async {
    final l10n = ref.read(l10nProvider);
    final store = ref.read(storeProvider);
    try {
      if (pdf) {
        final bytes = await store.pdf({
          if (ref.read(branchProvider) != null) 'branch_client_uuid': ref.read(branchProvider),
        });
        final path = await saveBytes(bytes, 'inventory-ledger.pdf', 'application/pdf');
        if (mounted) _toast(context, path);
      } else {
        final csv = await store.localCsv(events);
        final path = await saveBytes(utf8.encode(csv), 'inventory-ledger.csv', 'text/csv');
        if (mounted) _toast(context, path);
      }
    } catch (_) {
      if (mounted) _toast(context, l10n.t('pdfNeedsOnline'));
    }
  }
}

class StockDocPage extends ConsumerStatefulWidget {
  const StockDocPage({super.key, required this.mode});

  final String mode;

  @override
  ConsumerState<StockDocPage> createState() => _StockDocPageState();
}

class _StockDocPageState extends ConsumerState<StockDocPage> {
  String? _branch;
  String? _toBranch;
  String? _fromLocation;
  String? _toLocation;
  String _kind = 'opening';
  final _reason = TextEditingController();
  final List<_Line> _lines = [_Line()];
  String? _error;

  @override
  void dispose() {
    _reason.dispose();
    for (final line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    final products = ref.watch(_products).value ?? <ProductRow>[];
    final branches = ref.watch(_branches).value ?? <BranchRow>[];
    final locations = ref.watch(_locations).value ?? <LocationRow>[];
    final title = switch (widget.mode) {
      'transfer' => l10n.t('transfers'),
      'writeoff' => l10n.t('writeOff'),
      'move' => l10n.t('locationMove'),
      _ => l10n.t('adjustment'),
    };
    final needsCost = widget.mode == 'adjustment' && _kind != 'decrease';
    return _page(
      context,
      title,
      back: '/stock',
      Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              fieldGrid([
                if (widget.mode == 'adjustment')
                  labeledSelect<String>(
                    label: l10n.t('type'),
                    value: _kind,
                    items: [
                      DropdownMenuItem(value: 'opening', child: Text(l10n.t('opening'))),
                      DropdownMenuItem(value: 'increase', child: Text(l10n.t('increase'))),
                      DropdownMenuItem(value: 'decrease', child: Text(l10n.t('decrease'))),
                    ],
                    onChanged: (value) => setState(() => _kind = value ?? 'opening'),
                  ),
                labeledSelect<String?>(
                  label: widget.mode == 'transfer' ? l10n.t('fromBranch') : l10n.t('branch'),
                  value: _branch,
                  items: branches.map((row) => DropdownMenuItem(value: row.clientUuid, child: Text(row.name))).toList(),
                  onChanged: (value) => setState(() => _branch = value),
                ),
                if (widget.mode == 'transfer')
                  labeledSelect<String?>(
                    label: l10n.t('toBranch'),
                    value: _toBranch,
                    items: branches.map((row) => DropdownMenuItem(value: row.clientUuid, child: Text(row.name))).toList(),
                    onChanged: (value) => setState(() => _toBranch = value),
                  ),
                if (widget.mode == 'move') ...[
                  labeledSelect<String?>(
                    label: l10n.t('fromGodown'),
                    value: _fromLocation,
                    items: locations.map((row) => DropdownMenuItem(value: row.clientUuid, child: Text(row.name))).toList(),
                    onChanged: (value) => setState(() => _fromLocation = value),
                  ),
                  labeledSelect<String?>(
                    label: l10n.t('toGodown'),
                    value: _toLocation,
                    items: locations.map((row) => DropdownMenuItem(value: row.clientUuid, child: Text(row.name))).toList(),
                    onChanged: (value) => setState(() => _toLocation = value),
                  ),
                ],
                labeledField(l10n.t('reason'), _reason),
              ]),
              const Divider(height: 32),
              Text(l10n.t('lines'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              for (var i = 0; i < _lines.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: fieldGrid([
                    labeledSelect<String?>(
                      label: l10n.t('products'),
                      value: _lines[i].product,
                      items: products.map((row) => DropdownMenuItem(value: row.clientUuid, child: Text('${row.nameEn} (${row.code})'))).toList(),
                      onChanged: (value) => setState(() => _lines[i].product = value),
                    ),
                    labeledField(l10n.t('qty'), _lines[i].qty, keyboard: TextInputType.number),
                    if (needsCost) labeledField(l10n.t('unitCost'), _lines[i].cost, keyboard: TextInputType.number, prefix: symbol),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: TextButton.icon(
                        onPressed: _lines.length == 1 ? null : () => setState(() => _lines.removeAt(i).dispose()),
                        icon: const Icon(Icons.close),
                        label: Text(l10n.t('delete')),
                      ),
                    ),
                  ]),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _lines.add(_Line())),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.t('addLine')),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C))),
              ],
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(onPressed: () => _post(context), child: Text(l10n.t('post'))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _post(BuildContext context) async {
    final l10n = ref.read(l10nProvider);
    final session = ref.read(sessionProvider).value;
    if (_branch == null || _lines.any((line) => line.product == null || line.qty.text.trim().isEmpty)) {
      setState(() => _error = l10n.t('lines'));
      return;
    }
    if (widget.mode == 'transfer' && _toBranch == null) {
      setState(() => _error = l10n.t('toBranch'));
      return;
    }
    if (widget.mode == 'move' && (_fromLocation == null || _toLocation == null)) {
      setState(() => _error = l10n.t('godown'));
      return;
    }
    try {
      final lines = _lines
          .map((line) => {
                'product_client_uuid': line.product,
                'qty': line.qty.text,
                'unit_cost': line.cost.text,
              })
          .toList();
      final entity = switch (widget.mode) {
        'transfer' => 'stock_transfer',
        'writeoff' => 'stock_write_off',
        'move' => 'location_move',
        _ => 'stock_adjustment',
      };
      await ref.read(storeProvider).postStock(entity, {
        'kind': _kind,
        'branch_client_uuid': _branch,
        'from_branch_client_uuid': _branch,
        'to_branch_client_uuid': _toBranch,
        'from_location_client_uuid': _fromLocation,
        'to_location_client_uuid': _toLocation,
        'reason': _reason.text.trim(),
        'lines': lines,
      }, operatorName: session?.name);
      if (context.mounted) {
        _toast(context, l10n.t('savedLocal'));
        context.go('/stock/ledger');
      }
    } catch (error) {
      setState(() => _error = error.toString());
    }
  }
}

class BranchesPage extends ConsumerWidget {
  const BranchesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final rows = ref.watch(_branches).value ?? <BranchRow>[];
    final session = ref.watch(sessionProvider).value;
    return _page(
      context,
      l10n.t('branches'),
      _table(
        context,
        [l10n.t('itemName'), l10n.t('code'), l10n.t('status')],
        rows.map((row) => [row.name, row.code ?? '', row.isMain ? 'Main' : l10n.t('active')]).toList(),
        rows.isEmpty ? l10n.t('noRecords') : null,
      ),
      action: session?.canManage == true
          ? FilledButton(
              onPressed: () async {
                final name = TextEditingController();
                final code = TextEditingController();
                final ok = await showFormSheet(
                  context,
                  title: l10n.t('branches'),
                  fields: [
                    labeledField(l10n.t('itemName'), name),
                    labeledField(l10n.t('code'), code),
                  ],
                  saveLabel: l10n.t('save'),
                  cancelLabel: l10n.t('cancel'),
                );
                if (ok == true && name.text.trim().isNotEmpty) {
                  await ref.read(storeProvider).saveBranch(name.text.trim(), code.text.trim());
                }
                name.dispose();
                code.dispose();
              },
              child: Text(l10n.t('add')),
            )
          : null,
    );
  }
}

class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({super.key});

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  List<Map<String, dynamic>> _rows = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    try {
      final rows = await ref.read(storeProvider).users();
      if (mounted) setState(() => _rows = rows);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final session = ref.watch(sessionProvider).value;
    return _page(
      context,
      l10n.t('users'),
      _table(
        context,
        [l10n.t('name'), l10n.t('email'), l10n.t('role')],
        _rows.map((row) => [row['name']?.toString() ?? '', row['email']?.toString() ?? '', row['role']?.toString() ?? '']).toList(),
        _error ?? (_rows.isEmpty ? l10n.t('noRecords') : null),
      ),
      action: session?.isOwner == true
          ? FilledButton(
              onPressed: () async {
                final name = TextEditingController();
                final email = TextEditingController();
                final password = TextEditingController();
                var role = 'cashier';
                final ok = await showDialog<bool>(
                  context: context,
                  barrierColor: const Color(0x73101A1F),
                  builder: (dialogContext) => StatefulBuilder(
                    builder: (dialogContext, setLocal) => Dialog(
                      insetPadding: const EdgeInsets.all(14),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 980,
                          maxHeight: MediaQuery.sizeOf(dialogContext).height - 28,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 18, 12, 16),
                              child: Row(
                                children: [
                                  IconButton(tooltip: 'Back', onPressed: () => Navigator.pop(dialogContext, false), icon: const Icon(Icons.arrow_back)),
                                  Expanded(child: Text(l10n.t('users'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700))),
                                  IconButton(onPressed: () => Navigator.pop(dialogContext, false), icon: const Icon(Icons.close)),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: fieldGrid([
                                labeledField(l10n.t('name'), name),
                                labeledField(l10n.t('email'), email),
                                labeledField(l10n.t('password'), password, obscure: true),
                                labeledSelect<String>(
                                  label: l10n.t('role'),
                                  value: role,
                                  items: [
                                    DropdownMenuItem(value: 'manager', child: Text(l10n.t('manager'))),
                                    DropdownMenuItem(value: 'cashier', child: Text(l10n.t('cashier'))),
                                  ],
                                  onChanged: (value) => setLocal(() => role = value ?? 'cashier'),
                                ),
                              ]),
                            ),
                            const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.t('cancel'))),
                                  const SizedBox(width: 12),
                                  FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(l10n.t('save'))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
                if (ok == true) {
                  try {
                    await ref.read(storeProvider).saveUser(name.text.trim(), email.text.trim(), password.text, role);
                    await _load();
                  } catch (error) {
                    if (context.mounted) _toast(context, error.toString());
                  }
                }
                name.dispose();
                email.dispose();
                password.dispose();
              },
              child: Text(l10n.t('add')),
            )
          : null,
    );
  }
}

class PlaceholderPage extends ConsumerWidget {
  const PlaceholderPage({super.key, required this.moduleKey});

  final String moduleKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final note = switch (moduleKey) {
      'purchases' => l10n.t('phase2'),
      'pos' || 'sales' => l10n.t('phase3'),
      'accounts' || 'expenses' || 'roznamcha' || 'investment' || 'cheques' || 'reports' || 'customers' => l10n.t('phase4'),
      'manufacturing' => l10n.t('phase5'),
      'hr' || 'settings' => l10n.t('phase6'),
      _ => l10n.t('coming'),
    };
    return _page(
      context,
      l10n.t(moduleKey),
      back: '/dashboard',
      Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(note, style: Theme.of(context).textTheme.titleMedium),
        ),
      ),
    );
  }
}

class _Line {
  String? product;
  final qty = TextEditingController(text: '1');
  final cost = TextEditingController(text: '0');

  void dispose() {
    qty.dispose();
    cost.dispose();
  }
}

final _products = StreamProvider<List<ProductRow>>((ref) => ref.watch(storeProvider).watchProducts());
final _categories = StreamProvider<List<CategoryRow>>((ref) => ref.watch(storeProvider).watchCategories());
final _brands = StreamProvider<List<BrandRow>>((ref) => ref.watch(storeProvider).watchBrands());
final _units = StreamProvider<List<UnitRow>>((ref) => ref.watch(storeProvider).watchUnits());
final _branches = StreamProvider<List<BranchRow>>((ref) => ref.watch(storeProvider).watchBranches());
final _locations = StreamProvider<List<LocationRow>>((ref) => ref.watch(storeProvider).watchLocations());
final _balances = StreamProvider<List<BalanceRow>>((ref) => ref.watch(storeProvider).watchBalances());
final _events = StreamProvider<List<EventRow>>((ref) => ref.watch(storeProvider).watchEvents());

Widget _page(BuildContext context, String title, Widget child, {Widget? action, String? back}) {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (back != null) ...[
              IconButton(
                tooltip: 'Back',
                onPressed: () => context.go(back),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 4),
            ],
            Expanded(child: Text(title, style: Theme.of(context).textTheme.headlineSmall, overflow: TextOverflow.ellipsis)),
            ?action,
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth, minHeight: constraints.maxHeight),
                  child: child,
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

Widget _fillRow(double width, int maxColumns, double minTile, double gap, List<Widget> children) {
  final columns = math.max(1, math.min(maxColumns, width ~/ minTile));
  final tileWidth = (width - gap * (columns - 1)) / columns;
  return Wrap(
    spacing: gap,
    runSpacing: gap,
    children: [
      for (final child in children) SizedBox(width: tileWidth, child: child),
    ],
  );
}

Widget _stat(String label, String value, Color color, {Color? fill, double? width}) {
  return Container(
    width: width ?? 180,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: fill ?? Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8E6))),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF52615E))),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w700)),
      ],
    ),
  );
}

Widget _table(BuildContext context, List<String> headers, List<List<String>> rows, String? empty, {void Function(int index)? onEdit, void Function(int index)? onDelete}) {
  final actions = onEdit != null || onDelete != null;
  return LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth.isFinite ? constraints.maxWidth : 720.0;
      final minWidth = math.max(width, (headers.length + (actions ? 1 : 0)) * 140.0);
      return Card(
        margin: EdgeInsets.zero,
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: minWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFF8FAFC),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        for (final header in headers)
                          Expanded(
                            child: Text(header, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w700)),
                          ),
                        if (actions) const SizedBox(width: 88),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  if (rows.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
                      alignment: Alignment.centerLeft,
                      child: Text(empty ?? '', style: const TextStyle(color: Color(0xFF64748B))),
                    )
                  else
                    for (var index = 0; index < rows.length; index++) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Row(
                          children: [
                            for (final cell in rows[index]) Expanded(child: Text(cell)),
                            if (actions)
                              SizedBox(
                                width: 88,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (onEdit != null) IconButton(onPressed: () => onEdit(index), icon: const Icon(Icons.edit, size: 18)),
                                    if (onDelete != null) IconButton(onPressed: () => onDelete(index), icon: const Icon(Icons.delete, size: 18, color: Color(0xFFB91C1C))),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (index != rows.length - 1) const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    ],
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

(double, int, int, double, int) _summary(List<ProductRow> products, List<BalanceRow> balances, List<EventRow> events, String? branch) {
  var value = 0.0;
  var low = 0;
  var out = 0;
  var inStock = 0;
  final now = DateTime.now();
  for (final product in products.where((row) => row.trackStock && row.isActive)) {
    final scoped = balances.where((row) => row.productClientUuid == product.clientUuid && (branch == null || row.branchClientUuid == branch));
    final qty = scoped.fold<double>(0, (sum, row) => sum + Fixed.n(row.qtyOnHand));
    value += scoped.fold<double>(0, (sum, row) => sum + Fixed.n(row.stockValue));
    if (qty > 0) {
      inStock++;
      if (Fixed.n(product.alertQty) > 0 && qty <= Fixed.n(product.alertQty)) low++;
    } else {
      out++;
    }
  }
  var wastage = 0.0;
  for (final event in events.where((event) => event.eventType == 'write_off')) {
    if (branch != null && event.branchClientUuid != branch) continue;
    final occurred = DateTime.tryParse(event.occurredAt)?.toLocal();
    if (occurred != null && occurred.year == now.year && occurred.month == now.month) {
      wastage += Fixed.n(event.value).abs();
    }
  }
  return (value, low, out, wastage, inStock);
}

String _alert(L10n l10n, double qty, double alert) {
  if (qty <= 0) return l10n.t('outOfStock');
  if (alert > 0 && qty <= alert) return l10n.t('lowStock');
  return l10n.t('inStock');
}

String _bilingual(String en, String ur) => en.trim().isNotEmpty ? en : ur;

void _toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Future<void> _unitDialog(BuildContext context, WidgetRef ref, {UnitRow? existing}) async {
  final l10n = ref.read(l10nProvider);
  final en = TextEditingController(text: existing?.nameEn ?? '');
  final short = TextEditingController(text: existing?.shortName ?? '');
  final ok = await showFormSheet(
    context,
    title: l10n.t('units'),
    fields: [
      labeledField(l10n.t('itemName'), en),
      labeledField(l10n.t('shortName'), short),
    ],
    saveLabel: l10n.t('save'),
    cancelLabel: l10n.t('cancel'),
  );
  if (ok == true) {
    final name = en.text.trim();
    await ref.read(storeProvider).saveUnit(existing: existing, nameEn: name, nameUr: name, shortName: short.text.trim());
  }
  en.dispose();
  short.dispose();
}

Future<void> _categoryDialog(BuildContext context, WidgetRef ref, {CategoryRow? existing}) async {
  final l10n = ref.read(l10nProvider);
  final en = TextEditingController(text: existing?.nameEn ?? '');
  final code = TextEditingController(text: existing?.code ?? '');
  final ok = await showFormSheet(
    context,
    title: l10n.t('categories'),
    fields: [
      labeledField(l10n.t('itemName'), en),
      labeledField(l10n.t('code'), code),
    ],
    saveLabel: l10n.t('save'),
    cancelLabel: l10n.t('cancel'),
  );
  if (ok == true) {
    final name = en.text.trim();
    await ref.read(storeProvider).saveCategory(existing: existing, nameEn: name, nameUr: name, code: code.text.trim());
  }
  en.dispose();
  code.dispose();
}

Future<void> _brandDialog(BuildContext context, WidgetRef ref, {BrandRow? existing}) async {
  final l10n = ref.read(l10nProvider);
  final en = TextEditingController(text: existing?.nameEn ?? '');
  final code = TextEditingController(text: existing?.code ?? '');
  final ok = await showFormSheet(
    context,
    title: l10n.t('brands'),
    fields: [
      labeledField(l10n.t('itemName'), en),
      labeledField(l10n.t('code'), code),
    ],
    saveLabel: l10n.t('save'),
    cancelLabel: l10n.t('cancel'),
  );
  if (ok == true) {
    final name = en.text.trim();
    await ref.read(storeProvider).saveBrand(existing: existing, nameEn: name, nameUr: name, code: code.text.trim());
  }
  en.dispose();
  code.dispose();
}

Future<void> _productDialog(BuildContext context, WidgetRef ref, {ProductRow? existing}) async {
  final l10n = ref.read(l10nProvider);
  final store = ref.read(storeProvider);
  final units = await store.watchUnits().first;
  final categories = await store.watchCategories().first;
  final brands = await store.watchBrands().first;
  if (!context.mounted) return;
  final currentName = existing == null ? '' : (existing.nameEn.trim().isNotEmpty ? existing.nameEn : existing.nameUr);
  final name = TextEditingController(text: currentName);
  final symbol = ref.read(moneySymbolProvider);
  final code = TextEditingController(text: existing?.code ?? '');
  final barcode = TextEditingController(text: existing?.barcode ?? '');
  final purchase = TextEditingController(text: existing?.purchasePrice ?? '0');
  final sale = TextEditingController(text: existing?.salePrice ?? '0');
  final wholesale = TextEditingController(text: existing?.wholesalePrice ?? '0');
  final alert = TextEditingController(text: existing?.alertQty ?? '0');
  var unit = existing?.unitClientUuid ?? (units.isEmpty ? null : units.first.clientUuid);
  var category = existing?.categoryClientUuid;
  var brand = existing?.brandClientUuid;
  final ok = await showDialog<bool>(
    context: context,
    barrierColor: const Color(0x73101A1F),
    builder: (dialogContext) {
      final size = MediaQuery.sizeOf(dialogContext);
      return StatefulBuilder(
        builder: (dialogContext, setLocal) => Dialog(
          insetPadding: const EdgeInsets.all(14),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SizedBox(
            width: math.min(980, size.width - 28),
            height: math.min(760, size.height - 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 12, 16),
                  child: Row(
                    children: [
                      IconButton(tooltip: 'Back', onPressed: () => Navigator.pop(dialogContext, false), icon: const Icon(Icons.arrow_back)),
                      Expanded(child: Text(l10n.t('products'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)))),
                      IconButton(onPressed: () => Navigator.pop(dialogContext, false), icon: const Icon(Icons.close)),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                    child: fieldGrid([
                      labeledField(l10n.t('itemName'), name),
                      labeledField(l10n.t('code'), code),
                      labeledField(l10n.t('barcode'), barcode),
                      labeledSelect<String?>(
                        label: l10n.t('unit'),
                        value: unit,
                        items: units.map((row) => DropdownMenuItem(value: row.clientUuid, child: Text('${row.nameEn} (${row.shortName})'))).toList(),
                        onChanged: (value) => setLocal(() => unit = value),
                      ),
                      labeledSelect<String?>(
                        label: l10n.t('category'),
                        value: category,
                        items: [
                          DropdownMenuItem(value: null, child: Text(l10n.t('none'))),
                          ...categories.map((row) => DropdownMenuItem(value: row.clientUuid, child: Text(row.nameEn))),
                        ],
                        onChanged: (value) => setLocal(() => category = value),
                      ),
                      labeledSelect<String?>(
                        label: l10n.t('brand'),
                        value: brand,
                        items: [
                          DropdownMenuItem(value: null, child: Text(l10n.t('none'))),
                          ...brands.map((row) => DropdownMenuItem(value: row.clientUuid, child: Text(row.nameEn))),
                        ],
                        onChanged: (value) => setLocal(() => brand = value),
                      ),
                      labeledField(l10n.t('purchasePrice'), purchase, keyboard: TextInputType.number, prefix: symbol),
                      labeledField(l10n.t('salePrice'), sale, keyboard: TextInputType.number, prefix: symbol),
                      labeledField(l10n.t('wholesale'), wholesale, keyboard: TextInputType.number, prefix: symbol),
                      labeledField(l10n.t('alertQty'), alert, keyboard: TextInputType.number),
                    ]),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.t('cancel'))),
                      const SizedBox(width: 12),
                      FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(l10n.t('save'))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  if (ok == true && unit != null) {
    await ref.read(storeProvider).saveProduct(
          existing: existing,
          code: code.text.trim(),
          barcode: barcode.text.trim(),
          nameEn: name.text.trim(),
          nameUr: name.text.trim(),
          categoryUuid: category,
          brandUuid: brand,
          unitUuid: unit!,
          purchasePrice: purchase.text,
          salePrice: sale.text,
          wholesalePrice: wholesale.text,
          alertQty: alert.text,
        );
  }
  name.dispose();
  code.dispose();
  barcode.dispose();
  purchase.dispose();
  sale.dispose();
  wholesale.dispose();
  alert.dispose();
}
