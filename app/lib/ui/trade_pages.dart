part of 'pages.dart';

final _docAccounts = StreamProvider<List<DocumentRow>>((ref) => ref.watch(storeProvider).watchDocuments('ledger_account'));
final _docBanks = StreamProvider<List<DocumentRow>>((ref) => ref.watch(storeProvider).watchDocuments('bank_account'));
final _docSuppliers = StreamProvider<List<DocumentRow>>((ref) => ref.watch(storeProvider).watchDocuments('supplier'));
final _docPurchases = StreamProvider<List<DocumentRow>>((ref) => ref.watch(storeProvider).watchDocuments('purchase'));
final _docPurchaseOrders = StreamProvider<List<DocumentRow>>((ref) => ref.watch(storeProvider).watchDocuments('purchase_order'));
final _docPurchaseReturns = StreamProvider<List<DocumentRow>>((ref) => ref.watch(storeProvider).watchDocuments('purchase_return'));
final _docPurchasePayments = StreamProvider<List<DocumentRow>>((ref) => ref.watch(storeProvider).watchDocuments('purchase_payment'));

Widget _moneySwitch(BuildContext context, L10n l10n, String current) {
  Widget chip(String label, String path) {
    final on = current == path;
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: on ? _teal : Colors.white,
        foregroundColor: on ? Colors.white : const Color(0xFF1E293B),
        elevation: 0,
        side: const BorderSide(color: Color(0xFFD7DEE3)),
      ),
      onPressed: () => context.go(path),
      child: Text(label),
    );
  }

  return Align(
    alignment: Alignment.centerRight,
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        chip(l10n.t('roznamcha'), '/roznamcha'),
        chip(l10n.t('accounts'), '/accounts'),
        chip(l10n.t('bankAccounts'), '/bank-accounts'),
      ],
    ),
  );
}

String _accountType(L10n l10n, String? type) {
  return switch (type) {
    'asset' => l10n.t('asset'),
    'liability' => l10n.t('liability'),
    'equity' => l10n.t('equity'),
    'income' => l10n.t('income'),
    'expense' => l10n.t('expense'),
    _ => type ?? '',
  };
}

class AccountsPage extends ConsumerStatefulWidget {
  const AccountsPage({super.key});

  @override
  ConsumerState<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends ConsumerState<AccountsPage> {
  final _search = TextEditingController();
  String _type = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(storeProvider).ensureChart());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final query = _search.text.trim().toLowerCase();
    final rows = (ref.watch(_docAccounts).value ?? <DocumentRow>[])
        .map(_payload)
        .where((row) {
          if (_type != 'all' && row['type']?.toString() != _type) return false;
          if (query.isEmpty) return true;
          final hay = '${row['code']} ${row['name_en']} ${row['name_ur']}'.toLowerCase();
          return hay.contains(query);
        })
        .toList()
      ..sort((a, b) => (a['code']?.toString() ?? '').compareTo(b['code']?.toString() ?? ''));
    return _page(
      context,
      l10n.t('chartOfAccounts'),
      back: '/dashboard',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _moneySwitch(context, l10n, '/accounts'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 160,
                child: labeledSelect<String>(
                  label: l10n.t('type'),
                  value: _type,
                  items: [
                    DropdownMenuItem(value: 'all', child: Text(l10n.t('all'))),
                    DropdownMenuItem(value: 'asset', child: Text(l10n.t('asset'))),
                    DropdownMenuItem(value: 'liability', child: Text(l10n.t('liability'))),
                    DropdownMenuItem(value: 'equity', child: Text(l10n.t('equity'))),
                    DropdownMenuItem(value: 'income', child: Text(l10n.t('income'))),
                    DropdownMenuItem(value: 'expense', child: Text(l10n.t('expense'))),
                  ],
                  onChanged: (value) => setState(() => _type = value ?? 'all'),
                ),
              ),
              SizedBox(width: 240, child: labeledField(l10n.t('search'), _search, onChanged: (_) => setState(() {}))),
              FilledButton.icon(
                onPressed: () => context.go('/accounts/new'),
                icon: const Icon(Icons.add),
                label: Text(l10n.t('addAccount')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _table(
            context,
            [l10n.t('code'), l10n.t('itemName'), l10n.t('type'), l10n.t('status')],
            rows
                .map((row) => [
                      row['code']?.toString() ?? '',
                      _bilingual(row['name_en']?.toString() ?? '', row['name_ur']?.toString() ?? ''),
                      _accountType(l10n, row['type']?.toString()),
                      row['is_system'] == true ? l10n.t('system') : (row['is_active'] == false ? l10n.t('inactive') : l10n.t('active')),
                    ])
                .toList(),
            rows.isEmpty ? l10n.t('noRecords') : null,
            onEdit: (index) => context.go('/accounts/edit/${rows[index]['client_uuid']}'),
          ),
        ],
      ),
    );
  }
}

class AccountFormPage extends ConsumerStatefulWidget {
  const AccountFormPage({super.key, this.clientUuid});

  final String? clientUuid;

  @override
  ConsumerState<AccountFormPage> createState() => _AccountFormPageState();
}

class _AccountFormPageState extends ConsumerState<AccountFormPage> {
  final _code = TextEditingController();
  final _nameEn = TextEditingController();
  final _opening = TextEditingController(text: '0');
  final _description = TextEditingController();
  String _type = 'asset';
  String? _parent;
  bool _active = true;
  bool _system = false;
  bool _loaded = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    _nameEn.dispose();
    _opening.dispose();
    _description.dispose();
    super.dispose();
  }

  void _load(List<DocumentRow> rows) {
    if (_loaded || widget.clientUuid == null) return;
    final match = rows.where((row) => row.clientUuid == widget.clientUuid);
    if (match.isEmpty) return;
    final payload = _payload(match.first);
    _code.text = payload['code']?.toString() ?? '';
    final english = payload['name_en']?.toString() ?? '';
    _nameEn.text = english.trim().isNotEmpty ? english : (payload['name_ur']?.toString() ?? '');
    _opening.text = payload['opening_balance']?.toString() ?? '0';
    _description.text = payload['description']?.toString() ?? '';
    _type = payload['type']?.toString() ?? 'asset';
    _parent = payload['parent_client_uuid']?.toString();
    _active = payload['is_active'] != false;
    _system = payload['is_system'] == true;
    _loaded = true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    final rows = ref.watch(_docAccounts).value ?? <DocumentRow>[];
    _load(rows);
    final parents = rows.map(_payload).where((row) => row['client_uuid'] != widget.clientUuid).toList();
    return _page(
      context,
      l10n.t('add'),
      back: '/accounts',
      Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              fieldGrid([
                labeledField(l10n.t('code'), _code, enabled: !_system),
                labeledField(l10n.t('itemName'), _nameEn),
                labeledSelect<String>(
                  label: l10n.t('type'),
                  value: _type,
                  items: [
                    DropdownMenuItem(value: 'asset', child: Text(l10n.t('asset'))),
                    DropdownMenuItem(value: 'liability', child: Text(l10n.t('liability'))),
                    DropdownMenuItem(value: 'equity', child: Text(l10n.t('equity'))),
                    DropdownMenuItem(value: 'income', child: Text(l10n.t('income'))),
                    DropdownMenuItem(value: 'expense', child: Text(l10n.t('expense'))),
                  ],
                  onChanged: _system ? null : (value) => setState(() => _type = value ?? 'asset'),
                ),
                labeledSelect<String?>(
                  label: l10n.t('parentAccount'),
                  value: _parent,
                  items: [
                    DropdownMenuItem(value: null, child: Text(l10n.t('none'))),
                    for (final parent in parents)
                      DropdownMenuItem(
                        value: parent['client_uuid']?.toString(),
                        child: Text('${parent['code']}  ${parent['name_en']}'),
                      ),
                  ],
                  onChanged: (value) => setState(() => _parent = value),
                ),
                labeledField(l10n.t('openingBalance'), _opening, keyboard: TextInputType.number, prefix: symbol),
                labeledField(l10n.t('description'), _description),
              ]),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _active,
                onChanged: (value) => setState(() => _active = value ?? true),
                title: Text(l10n.t('active')),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              if (_error != null) Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C))),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(onPressed: () => context.go('/accounts'), child: Text(l10n.t('cancel'))),
                  const SizedBox(width: 12),
                  FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.t('save'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_code.text.trim().isEmpty || _nameEn.text.trim().isEmpty) {
      setState(() => _error = ref.read(l10nProvider).t('code'));
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(storeProvider).saveMoney('ledger_account', {
        if (widget.clientUuid != null) 'client_uuid': widget.clientUuid,
        'code': _code.text.trim(),
        'name_en': _nameEn.text.trim(),
        'name_ur': _nameEn.text.trim(),
        'type': _type,
        if (_parent != null) 'parent_client_uuid': _parent,
        'opening_balance': double.tryParse(_opening.text.trim()) ?? 0,
        'description': _description.text.trim(),
        'is_active': _active,
        'is_system': _system,
      });
      if (mounted) context.go('/accounts');
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class BankAccountsPage extends ConsumerWidget {
  const BankAccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    final rows = (ref.watch(_docBanks).value ?? <DocumentRow>[]).map(_payload).toList();
    return _page(
      context,
      l10n.t('bankAccounts'),
      back: '/dashboard',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _moneySwitch(context, l10n, '/bank-accounts'),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(onPressed: () => context.go('/bank-accounts/new'), icon: const Icon(Icons.add), label: Text(l10n.t('add'))),
          ),
          const SizedBox(height: 12),
          _table(
            context,
            [l10n.t('itemName'), l10n.t('accountTitle'), l10n.t('accountNumber'), l10n.t('openingBalance'), l10n.t('status')],
            rows
                .map((row) => [
                      row['name']?.toString() ?? '',
                      row['account_title']?.toString() ?? '',
                      row['account_number']?.toString() ?? '',
                      Fixed.rs(row['opening_balance'], symbol),
                      row['is_active'] == false ? l10n.t('inactive') : l10n.t('active'),
                    ])
                .toList(),
            rows.isEmpty ? l10n.t('noRecords') : null,
            onEdit: (index) => context.go('/bank-accounts/edit/${rows[index]['client_uuid']}'),
          ),
          const SizedBox(height: 8),
          Text(l10n.t('bankHint'), style: const TextStyle(color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}

class BankAccountFormPage extends ConsumerStatefulWidget {
  const BankAccountFormPage({super.key, this.clientUuid});

  final String? clientUuid;

  @override
  ConsumerState<BankAccountFormPage> createState() => _BankAccountFormPageState();
}

class _BankAccountFormPageState extends ConsumerState<BankAccountFormPage> {
  final _name = TextEditingController();
  final _title = TextEditingController();
  final _number = TextEditingController();
  final _opening = TextEditingController(text: '0');
  bool _active = true;
  bool _loaded = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _title.dispose();
    _number.dispose();
    _opening.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    final rows = ref.watch(_docBanks).value ?? <DocumentRow>[];
    if (!_loaded && widget.clientUuid != null) {
      final match = rows.where((row) => row.clientUuid == widget.clientUuid);
      if (match.isNotEmpty) {
        final payload = _payload(match.first);
        _name.text = payload['name']?.toString() ?? '';
        _title.text = payload['account_title']?.toString() ?? '';
        _number.text = payload['account_number']?.toString() ?? '';
        _opening.text = payload['opening_balance']?.toString() ?? '0';
        _active = payload['is_active'] != false;
        _loaded = true;
      }
    }
    return _page(
      context,
      l10n.t('add'),
      back: '/bank-accounts',
      Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              fieldGrid([
                labeledField(l10n.t('itemName'), _name),
                labeledField(l10n.t('accountTitle'), _title),
                labeledField(l10n.t('accountNumber'), _number),
                labeledField(l10n.t('openingBalance'), _opening, keyboard: TextInputType.number, prefix: symbol),
              ]),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _active,
                onChanged: (value) => setState(() => _active = value ?? true),
                title: Text(l10n.t('active')),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              if (_error != null) Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C))),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(onPressed: () => context.go('/bank-accounts'), child: Text(l10n.t('cancel'))),
                  const SizedBox(width: 12),
                  FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.t('save'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = ref.read(l10nProvider).t('itemName'));
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(storeProvider).saveMoney('bank_account', {
        if (widget.clientUuid != null) 'client_uuid': widget.clientUuid,
        'name': _name.text.trim(),
        'account_title': _title.text.trim(),
        'account_number': _number.text.trim(),
        'opening_balance': double.tryParse(_opening.text.trim()) ?? 0,
        'is_active': _active,
      });
      if (mounted) context.go('/bank-accounts');
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class PurchasesPage extends ConsumerStatefulWidget {
  const PurchasesPage({super.key});

  @override
  ConsumerState<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends ConsumerState<PurchasesPage> {
  final _from = TextEditingController();
  final _to = TextEditingController();
  final _search = TextEditingController();

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    final payments = (ref.watch(_docPurchasePayments).value ?? <DocumentRow>[]).map(_payload).toList();
    final query = _search.text.trim().toLowerCase();
    final from = _isoDate(_from.text);
    final to = _isoDate(_to.text);
    final rows = (ref.watch(_docPurchases).value ?? <DocumentRow>[]).map(_payload).where((row) {
      final rawDay = (row['occurred_on'] ?? row['occurred_at'] ?? '').toString();
      final day = rawDay.length >= 10 ? rawDay.substring(0, 10) : rawDay;
      if (from != null && day.compareTo(from) < 0) return false;
      if (to != null && day.compareTo(to) > 0) return false;
      if (query.isEmpty) return true;
      return '${row['invoice_no']} ${row['supplier_name']}'.toLowerCase().contains(query);
    }).toList();
    return _page(
      context,
      l10n.t('purchases'),
      back: '/dashboard',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(onPressed: () => _csv(rows, payments, symbol), child: Text(l10n.t('exportCsv'))),
              OutlinedButton(onPressed: () => context.go('/purchases/quick-pay'), child: Text(l10n.t('quickPay'))),
              OutlinedButton(onPressed: () => context.go('/purchases/returns'), child: Text(l10n.t('purchaseReturns'))),
              OutlinedButton(onPressed: () => context.go('/purchases/orders'), child: Text(l10n.t('purchaseOrders'))),
              FilledButton.icon(onPressed: () => context.go('/purchases/receive'), icon: const Icon(Icons.add), label: Text(l10n.t('receivePurchase'))),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(width: 160, child: labeledField(l10n.t('from'), _from, hint: 'dd/mm/yyyy')),
              SizedBox(width: 160, child: labeledField(l10n.t('to'), _to, hint: 'dd/mm/yyyy')),
              SizedBox(width: 220, child: labeledField(l10n.t('search'), _search)),
              FilledButton(onPressed: () => setState(() {}), child: Text(l10n.t('search'))),
            ],
          ),
          const SizedBox(height: 16),
          _table(
            context,
            [l10n.t('date'), l10n.t('invoice'), l10n.t('supplier'), l10n.t('items'), l10n.t('total'), l10n.t('paid'), l10n.t('due')],
            rows.map((row) {
              final paid = _paid(row, payments);
              final total = Fixed.n(row['total']);
              final lines = row['lines'];
              final count = row['item_count'] ?? (lines is List ? lines.length : 0);
              return [
                _showDate(row['occurred_on'] ?? row['occurred_at']),
                row['invoice_no']?.toString() ?? '',
                row['supplier_name']?.toString().isNotEmpty == true ? row['supplier_name'].toString() : l10n.t('cash'),
                '$count',
                Fixed.rs(total, symbol),
                Fixed.rs(paid, symbol),
                Fixed.rs(total - paid, symbol),
              ];
            }).toList(),
            rows.isEmpty ? l10n.t('noRecords') : null,
          ),
        ],
      ),
    );
  }

  Future<void> _csv(List<Map<String, dynamic>> rows, List<Map<String, dynamic>> payments, String symbol) async {
    final buffer = StringBuffer('Date,Invoice,Supplier,Total,Paid,Due\n');
    for (final row in rows) {
      final paid = _paid(row, payments);
      final total = Fixed.n(row['total']);
      buffer.writeln('${row['occurred_on'] ?? ''},${row['invoice_no'] ?? ''},"${row['supplier_name'] ?? ''}",$total,$paid,${total - paid}');
    }
    final path = await saveBytes(utf8.encode(buffer.toString()), 'purchases.csv', 'text/csv');
    if (mounted) _toast(context, path);
  }
}

double _paid(Map<String, dynamic> row, List<Map<String, dynamic>> payments) {
  final extra = payments.where((payment) => payment['purchase_client_uuid'] == row['client_uuid']).fold<double>(0, (sum, payment) => sum + Fixed.n(payment['amount']));
  return Fixed.n(row['paid']) + extra;
}

class ReceivePurchasePage extends ConsumerStatefulWidget {
  const ReceivePurchasePage({super.key});

  @override
  ConsumerState<ReceivePurchasePage> createState() => _ReceivePurchasePageState();
}

class _ReceivePurchasePageState extends ConsumerState<ReceivePurchasePage> {
  final _invoice = TextEditingController();
  final _date = TextEditingController(text: _showDate(DateTime.now().toIso8601String()));
  final _barcode = TextEditingController();
  final _note = TextEditingController();
  final _paid = TextEditingController(text: '0');
  final _lines = <_BuyLine>[_BuyLine()];
  String? _supplier;
  String? _branch;
  String _method = 'cash';
  bool _updateCost = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _invoice.dispose();
    _date.dispose();
    _barcode.dispose();
    _note.dispose();
    _paid.dispose();
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
    final suppliers = (ref.watch(_docSuppliers).value ?? <DocumentRow>[]).map(_payload).toList();
    _branch ??= ref.watch(branchProvider) ?? (branches.isEmpty ? null : branches.first.clientUuid);
    var subtotal = 0.0;
    var tax = 0.0;
    for (final line in _lines) {
      final qty = double.tryParse(line.qty.text) ?? 0;
      final cost = double.tryParse(line.cost.text) ?? 0;
      final percent = double.tryParse(line.tax.text) ?? 0;
      final net = qty * cost;
      subtotal += net;
      tax += net * percent / 100;
    }
    final total = subtotal + tax;
    return _page(
      context,
      l10n.t('receivePurchase'),
      back: '/purchases',
      Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              fieldGrid([
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: labeledSelect<String?>(
                        label: l10n.t('supplier'),
                        value: _supplier,
                        items: [
                          DropdownMenuItem(value: null, child: Text(l10n.t('cash'))),
                          for (final supplier in suppliers)
                            DropdownMenuItem(value: supplier['client_uuid']?.toString(), child: Text(supplier['name']?.toString() ?? '')),
                        ],
                        onChanged: (value) => setState(() => _supplier = value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(onPressed: () => _addSupplier(suppliers), icon: const Icon(Icons.add)),
                  ],
                ),
                labeledField(l10n.t('supplierInvoice'), _invoice),
                labeledField(l10n.t('date'), _date, hint: 'dd/mm/yyyy'),
                labeledSelect<String?>(
                  label: l10n.t('branch'),
                  value: _branch,
                  items: [for (final branch in branches) DropdownMenuItem(value: branch.clientUuid, child: Text(branch.name))],
                  onChanged: (value) => setState(() => _branch = value),
                ),
              ]),
              const SizedBox(height: 8),
              labeledField(l10n.t('barcode'), _barcode, hint: l10n.t('scanBarcode'), onSubmitted: (_) => _scan(products)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(l10n.t('lines'), style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  FilledButton.icon(onPressed: () => setState(() => _lines.add(_BuyLine())), icon: const Icon(Icons.add), label: Text(l10n.t('addProductLine'))),
                ],
              ),
              const SizedBox(height: 8),
              for (var i = 0; i < _lines.length; i++) _lineCard(l10n, products, i, symbol),
              const SizedBox(height: 12),
              fieldGrid([
                labeledSelect<String>(
                  label: l10n.t('paymentMethod'),
                  value: _method,
                  items: [
                    DropdownMenuItem(value: 'cash', child: Text(l10n.t('cash'))),
                    DropdownMenuItem(value: 'bank', child: Text(l10n.t('bank'))),
                    DropdownMenuItem(value: 'credit', child: Text(l10n.t('onCredit'))),
                  ],
                  onChanged: (value) => setState(() => _method = value ?? 'cash'),
                ),
                if (_method == 'credit') labeledField(l10n.t('paid'), _paid, keyboard: TextInputType.number, prefix: symbol),
                labeledField(l10n.t('note'), _note),
              ]),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _updateCost,
                onChanged: (value) => setState(() => _updateCost = value ?? true),
                title: Text(l10n.t('updateCost')),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 8),
              _review(l10n, symbol, subtotal, tax, total),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C))),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(onPressed: () => context.go('/purchases'), child: Text(l10n.t('cancel'))),
                  const SizedBox(width: 12),
                  FilledButton(onPressed: _busy ? null : () => _save(total), child: Text(l10n.t('confirmReceive'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _lineCard(L10n l10n, List<ProductRow> products, int index, String symbol) {
    final line = _lines[index];
    final qty = double.tryParse(line.qty.text) ?? 0;
    final cost = double.tryParse(line.cost.text) ?? 0;
    final percent = double.tryParse(line.tax.text) ?? 0;
    final lineTotal = qty * cost * (1 + percent / 100);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFFF8FAFC),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            fieldGrid([
              labeledSelect<String?>(
                label: l10n.t('products'),
                value: line.productUuid,
                items: [
                  for (final product in products)
                    DropdownMenuItem(value: product.clientUuid, child: Text(product.nameEn)),
                ],
                onChanged: (value) => setState(() {
                  line.productUuid = value;
                  final product = products.cast<ProductRow?>().firstWhere((row) => row?.clientUuid == value, orElse: () => null);
                  if (product != null && line.cost.text.trim().isEmpty) line.cost.text = product.purchasePrice;
                }),
              ),
              labeledField(l10n.t('qty'), line.qty, keyboard: TextInputType.number, onChanged: (_) => setState(() {})),
              labeledField(l10n.t('unitCost'), line.cost, keyboard: TextInputType.number, prefix: symbol, onChanged: (_) => setState(() {})),
              labeledField(l10n.t('taxPercent'), line.tax, keyboard: TextInputType.number, onChanged: (_) => setState(() {})),
            ]),
            const SizedBox(height: 8),
            fieldGrid([
              labeledField(l10n.t('salePrice'), line.sale, keyboard: TextInputType.number, prefix: symbol),
              labeledField(l10n.t('wholesale'), line.wholesale, keyboard: TextInputType.number, prefix: symbol),
              labeledField(l10n.t('code'), line.batch),
              labeledField(l10n.t('date'), line.expiry, hint: 'dd/mm/yyyy'),
            ]),
            Row(
              children: [
                Text('${l10n.t('lineTotal')}  ${Fixed.rs(lineTotal, symbol)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                if (_lines.length > 1)
                  IconButton(onPressed: () => setState(() => _lines.removeAt(index).dispose()), icon: const Icon(Icons.delete_outline)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _review(L10n l10n, String symbol, double subtotal, double tax, double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _reviewRow(l10n.t('subtotal'), Fixed.rs(subtotal, symbol)),
          _reviewRow(l10n.t('tax'), Fixed.rs(tax, symbol)),
          const Divider(color: Color(0xFF334155)),
          _reviewRow(l10n.t('total'), Fixed.rs(total, symbol), strong: true),
        ],
      ),
    );
  }

  Widget _reviewRow(String label, String value, {bool strong = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: Colors.white70, fontWeight: strong ? FontWeight.w700 : FontWeight.w500)),
          const Spacer(),
          Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: strong ? 18 : 14)),
        ],
      ),
    );
  }

  void _scan(List<ProductRow> products) {
    final code = _barcode.text.trim().toLowerCase();
    if (code.isEmpty) return;
    final product = products.cast<ProductRow?>().firstWhere(
          (row) => row != null && (row.code.toLowerCase() == code || (row.barcode ?? '').toLowerCase() == code),
          orElse: () => null,
        );
    if (product == null) {
      setState(() => _error = ref.read(l10nProvider).t('products'));
      return;
    }
    setState(() {
      final empty = _lines.cast<_BuyLine?>().firstWhere((line) => line!.productUuid == null, orElse: () => null);
      final line = empty ?? _BuyLine();
      if (empty == null) _lines.add(line);
      line.productUuid = product.clientUuid;
      if (line.cost.text.trim().isEmpty) line.cost.text = product.purchasePrice;
      _barcode.clear();
      _error = null;
    });
  }

  Future<void> _addSupplier(List<Map<String, dynamic>> suppliers) async {
    final created = await showDialog<String>(
      context: context,
      builder: (context) => const _SupplierDialog(),
    );
    if (created != null && mounted) setState(() => _supplier = created);
  }

  Future<void> _save(double total) async {
    final l10n = ref.read(l10nProvider);
    final branch = _branch;
    final lines = <Map<String, dynamic>>[];
    for (final line in _lines) {
      final qty = double.tryParse(line.qty.text.trim()) ?? 0;
      final cost = double.tryParse(line.cost.text.trim()) ?? 0;
      if (line.productUuid == null || qty <= 0) continue;
      lines.add({
        'product_client_uuid': line.productUuid,
        'qty': qty,
        'unit_cost': cost,
        'tax_percent': double.tryParse(line.tax.text.trim()) ?? 0,
        'new_sale_price': line.sale.text.trim(),
        'new_wholesale': line.wholesale.text.trim(),
        'batch_no': line.batch.text.trim(),
        'expiry': _isoDate(line.expiry.text),
      });
    }
    if (branch == null || lines.isEmpty) {
      setState(() => _error = l10n.t('lines'));
      return;
    }
    setState(() => _busy = true);
    try {
      final suppliers = (ref.read(_docSuppliers).value ?? <DocumentRow>[]).map(_payload).toList();
      final supplier = suppliers.cast<Map<String, dynamic>?>().firstWhere((row) => row?['client_uuid'] == _supplier, orElse: () => null);
      final paid = _method == 'credit' ? (double.tryParse(_paid.text.trim()) ?? 0) : total;
      await ref.read(storeProvider).postStock('purchase', {
        'branch_client_uuid': branch,
        if (_supplier != null) 'supplier_client_uuid': _supplier,
        'supplier_name': supplier?['name'] ?? '',
        'invoice_no': _invoice.text.trim(),
        'occurred_at': '${_isoDate(_date.text) ?? DateTime.now().toIso8601String().substring(0, 10)}T00:00:00Z',
        'payment_method': _method,
        'paid': paid,
        'note': _note.text.trim(),
        'update_cost': _updateCost,
        'subtotal': total - (lines.fold<double>(0, (sum, line) => sum + (line['qty'] as double) * (line['unit_cost'] as double) * ((line['tax_percent'] as double) / 100))),
        'tax': lines.fold<double>(0, (sum, line) => sum + (line['qty'] as double) * (line['unit_cost'] as double) * ((line['tax_percent'] as double) / 100)),
        'total': total,
        'lines': lines,
      });
      if (mounted) context.go('/purchases');
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _BuyLine {
  String? productUuid;
  final qty = TextEditingController(text: '1');
  final cost = TextEditingController();
  final tax = TextEditingController(text: '0');
  final sale = TextEditingController();
  final wholesale = TextEditingController();
  final batch = TextEditingController();
  final expiry = TextEditingController();

  void dispose() {
    qty.dispose();
    cost.dispose();
    tax.dispose();
    sale.dispose();
    wholesale.dispose();
    batch.dispose();
    expiry.dispose();
  }
}

class _SupplierDialog extends ConsumerStatefulWidget {
  const _SupplierDialog();

  @override
  ConsumerState<_SupplierDialog> createState() => _SupplierDialogState();
}

class _SupplierDialogState extends ConsumerState<_SupplierDialog> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    return AlertDialog(
      title: Text(l10n.t('addSupplier')),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            labeledField(l10n.t('itemName'), _name),
            const SizedBox(height: 12),
            labeledField(l10n.t('phone'), _phone),
            const SizedBox(height: 12),
            labeledField(l10n.t('address'), _address),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C))),
            ],
          ],
        ),
      ),
      actions: [
        OutlinedButton(onPressed: () => Navigator.pop(context), child: Text(l10n.t('cancel'))),
        FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.t('save'))),
      ],
    );
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = ref.read(l10nProvider).t('itemName'));
      return;
    }
    setState(() => _busy = true);
    final uuid = const Uuid().v4();
    try {
      await ref.read(storeProvider).saveMoney('supplier', {
        'client_uuid': uuid,
        'name': _name.text.trim(),
        'phone': _phone.text.trim(),
        'address': _address.text.trim(),
      });
      if (mounted) Navigator.pop(context, uuid);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class PurchaseOrdersPage extends ConsumerWidget {
  const PurchaseOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final rows = (ref.watch(_docPurchaseOrders).value ?? <DocumentRow>[]).map(_payload).toList();
    return _page(
      context,
      l10n.t('purchaseOrders'),
      back: '/purchases',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(onPressed: () => context.go('/purchases/orders/new'), icon: const Icon(Icons.add), label: Text(l10n.t('add'))),
          ),
          const SizedBox(height: 12),
          _table(
            context,
            [l10n.t('date'), l10n.t('supplier'), l10n.t('items'), l10n.t('status')],
            rows.map((row) {
              final lines = row['lines'];
              return [
                _showDate(row['occurred_on']),
                row['supplier_name']?.toString() ?? '',
                '${lines is List ? lines.length : 0}',
                row['status']?.toString() ?? 'open',
              ];
            }).toList(),
            rows.isEmpty ? l10n.t('noRecords') : null,
          ),
        ],
      ),
      action: null,
    );
  }
}

class PurchaseOrderFormPage extends ConsumerStatefulWidget {
  const PurchaseOrderFormPage({super.key});

  @override
  ConsumerState<PurchaseOrderFormPage> createState() => _PurchaseOrderFormPageState();
}

class _PurchaseOrderFormPageState extends ConsumerState<PurchaseOrderFormPage> {
  final _date = TextEditingController(text: _showDate(DateTime.now().toIso8601String()));
  final _note = TextEditingController();
  final _lines = <_BuyLine>[];
  String? _supplier;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _date.dispose();
    _note.dispose();
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
    final suppliers = (ref.watch(_docSuppliers).value ?? <DocumentRow>[]).map(_payload).toList();
    var total = 0.0;
    for (final line in _lines) {
      total += (double.tryParse(line.qty.text) ?? 0) * (double.tryParse(line.cost.text) ?? 0);
    }
    return _page(
      context,
      l10n.t('newPurchaseOrder'),
      back: '/purchases/orders',
      Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(10)),
                child: Text(l10n.t('orderHelp')),
              ),
              const SizedBox(height: 12),
              if (_lines.isEmpty) Text(l10n.t('cartEmpty'), style: const TextStyle(color: Color(0xFF64748B))),
              fieldGrid([
                labeledSelect<String?>(
                  label: l10n.t('supplier'),
                  value: _supplier,
                  items: [
                    for (final supplier in suppliers)
                      DropdownMenuItem(value: supplier['client_uuid']?.toString(), child: Text(supplier['name']?.toString() ?? '')),
                  ],
                  onChanged: (value) => setState(() => _supplier = value),
                ),
                labeledField(l10n.t('expectedDate'), _date, hint: 'dd/mm/yyyy'),
                labeledField(l10n.t('note'), _note),
              ]),
              const SizedBox(height: 12),
              for (var i = 0; i < _lines.length; i++)
                fieldGrid([
                  labeledSelect<String?>(
                    label: l10n.t('products'),
                    value: _lines[i].productUuid,
                    items: [for (final product in products) DropdownMenuItem(value: product.clientUuid, child: Text(product.nameEn))],
                    onChanged: (value) => setState(() => _lines[i].productUuid = value),
                  ),
                  labeledField(l10n.t('qty'), _lines[i].qty, keyboard: TextInputType.number),
                  labeledField(l10n.t('unitCost'), _lines[i].cost, keyboard: TextInputType.number, prefix: symbol),
                ]),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(onPressed: () => setState(() => _lines.add(_BuyLine())), icon: const Icon(Icons.add), label: Text(l10n.t('addProductLine'))),
              ),
              Text('${l10n.t('total')}  ${Fixed.rs(total, symbol)}', style: const TextStyle(fontWeight: FontWeight.w700)),
              if (_error != null) Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C))),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(onPressed: () => context.go('/purchases/orders'), child: Text(l10n.t('cancel'))),
                  const SizedBox(width: 12),
                  FilledButton(onPressed: _busy ? null : () => _save(suppliers), child: Text(l10n.t('save'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save(List<Map<String, dynamic>> suppliers) async {
    final lines = <Map<String, dynamic>>[];
    for (final line in _lines) {
      final qty = double.tryParse(line.qty.text.trim()) ?? 0;
      if (line.productUuid == null || qty <= 0) continue;
      lines.add({
        'product_client_uuid': line.productUuid,
        'qty': qty,
        'unit_cost': double.tryParse(line.cost.text.trim()) ?? 0,
      });
    }
    if (_supplier == null || lines.isEmpty) {
      setState(() => _error = ref.read(l10nProvider).t('supplier'));
      return;
    }
    setState(() => _busy = true);
    try {
      final supplier = suppliers.cast<Map<String, dynamic>?>().firstWhere((row) => row?['client_uuid'] == _supplier, orElse: () => null);
      await ref.read(storeProvider).saveMoney('purchase_order', {
        'supplier_name': supplier?['name'] ?? '',
        'occurred_on': _isoDate(_date.text) ?? DateTime.now().toIso8601String().substring(0, 10),
        'note': _note.text.trim(),
        'lines': lines,
      });
      if (mounted) context.go('/purchases/orders');
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class PurchaseReturnsPage extends ConsumerWidget {
  const PurchaseReturnsPage({super.key, this.back = '/purchases'});

  final String back;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    final rows = (ref.watch(_docPurchaseReturns).value ?? <DocumentRow>[]).map(_payload).toList();
    return _page(
      context,
      l10n.t('returnsRegister'),
      back: back,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stockSwitch(context, l10n, '/stock/returns'),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(onPressed: () => context.go('/purchases/returns/new'), icon: const Icon(Icons.add), label: Text(l10n.t('purchaseReturns'))),
          ),
          const SizedBox(height: 12),
          _table(
            context,
            [l10n.t('date'), l10n.t('type'), l10n.t('supplier'), l10n.t('branch'), l10n.t('status'), l10n.t('total')],
            rows
                .map((row) => [
                      _showDate(row['occurred_on'] ?? row['occurred_at']),
                      l10n.t('purchaseReturns'),
                      row['supplier_name']?.toString() ?? '',
                      row['branch_client_uuid']?.toString() ?? '',
                      l10n.t('posted'),
                      Fixed.rs(row['total'], symbol),
                    ])
                .toList(),
            rows.isEmpty ? l10n.t('noRecords') : null,
          ),
        ],
      ),
    );
  }
}

class PurchaseReturnFormPage extends ConsumerStatefulWidget {
  const PurchaseReturnFormPage({super.key});

  @override
  ConsumerState<PurchaseReturnFormPage> createState() => _PurchaseReturnFormPageState();
}

class _PurchaseReturnFormPageState extends ConsumerState<PurchaseReturnFormPage> {
  final _date = TextEditingController(text: _showDate(DateTime.now().toIso8601String()));
  final _note = TextEditingController();
  final _lines = <_BuyLine>[_BuyLine()];
  String? _supplier;
  String? _branch;
  String? _source;
  String _refund = 'payable';
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _date.dispose();
    _note.dispose();
    for (final line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final products = ref.watch(_products).value ?? <ProductRow>[];
    final branches = ref.watch(_branches).value ?? <BranchRow>[];
    final suppliers = (ref.watch(_docSuppliers).value ?? <DocumentRow>[]).map(_payload).toList();
    final purchases = (ref.watch(_docPurchases).value ?? <DocumentRow>[]).map(_payload).toList();
    _branch ??= ref.watch(branchProvider) ?? (branches.isEmpty ? null : branches.first.clientUuid);
    return _page(
      context,
      l10n.t('purchaseReturns'),
      back: '/stock/returns',
      Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(10)),
                child: Text(l10n.t('returnHelp')),
              ),
              const SizedBox(height: 12),
              fieldGrid([
                labeledSelect<String?>(
                  label: l10n.t('supplier'),
                  value: _supplier,
                  items: [for (final supplier in suppliers) DropdownMenuItem(value: supplier['client_uuid']?.toString(), child: Text(supplier['name']?.toString() ?? ''))],
                  onChanged: (value) => setState(() => _supplier = value),
                ),
                labeledSelect<String>(
                  label: l10n.t('refundMethod'),
                  value: _refund,
                  items: [
                    DropdownMenuItem(value: 'payable', child: Text(l10n.t('reducePayable'))),
                    DropdownMenuItem(value: 'cash', child: Text(l10n.t('cashRefund'))),
                  ],
                  onChanged: (value) => setState(() => _refund = value ?? 'payable'),
                ),
                labeledSelect<String?>(
                  label: l10n.t('originalPurchase'),
                  value: _source,
                  items: [
                    for (final purchase in purchases)
                      DropdownMenuItem(
                        value: purchase['client_uuid']?.toString(),
                        child: Text('${purchase['invoice_no'] ?? ''} ${purchase['supplier_name'] ?? ''}'),
                      ),
                  ],
                  onChanged: (value) => setState(() => _source = value),
                ),
                labeledField(l10n.t('date'), _date, hint: 'dd/mm/yyyy'),
                labeledSelect<String?>(
                  label: l10n.t('branch'),
                  value: _branch,
                  items: [for (final branch in branches) DropdownMenuItem(value: branch.clientUuid, child: Text(branch.name))],
                  onChanged: (value) => setState(() => _branch = value),
                ),
                labeledField(l10n.t('note'), _note),
              ]),
              const SizedBox(height: 12),
              for (var i = 0; i < _lines.length; i++)
                fieldGrid([
                  labeledSelect<String?>(
                    label: l10n.t('products'),
                    value: _lines[i].productUuid,
                    items: [for (final product in products) DropdownMenuItem(value: product.clientUuid, child: Text(product.nameEn))],
                    onChanged: (value) => setState(() => _lines[i].productUuid = value),
                  ),
                  labeledField(l10n.t('qty'), _lines[i].qty, keyboard: TextInputType.number),
                ]),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(onPressed: () => setState(() => _lines.add(_BuyLine())), icon: const Icon(Icons.add), label: Text(l10n.t('addProductLine'))),
              ),
              if (_error != null) Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C))),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(onPressed: () => context.go('/stock/returns'), child: Text(l10n.t('cancel'))),
                  const SizedBox(width: 12),
                  FilledButton(onPressed: _busy ? null : () => _save(suppliers), child: Text(l10n.t('returnToSupplier'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save(List<Map<String, dynamic>> suppliers) async {
    final lines = <Map<String, dynamic>>[];
    for (final line in _lines) {
      final qty = double.tryParse(line.qty.text.trim()) ?? 0;
      if (line.productUuid == null || qty <= 0) continue;
      lines.add({'product_client_uuid': line.productUuid, 'qty': qty});
    }
    if (_branch == null || lines.isEmpty) {
      setState(() => _error = ref.read(l10nProvider).t('lines'));
      return;
    }
    setState(() => _busy = true);
    try {
      final supplier = suppliers.cast<Map<String, dynamic>?>().firstWhere((row) => row?['client_uuid'] == _supplier, orElse: () => null);
      await ref.read(storeProvider).postStock('purchase_return', {
        'branch_client_uuid': _branch,
        'supplier_name': supplier?['name'] ?? '',
        'refund_method': _refund,
        if (_source != null) 'source_client_uuid': _source,
        'note': _note.text.trim(),
        'occurred_at': '${_isoDate(_date.text) ?? DateTime.now().toIso8601String().substring(0, 10)}T00:00:00Z',
        'lines': lines,
      });
      if (mounted) context.go('/stock/returns');
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class QuickPayPage extends ConsumerStatefulWidget {
  const QuickPayPage({super.key});

  @override
  ConsumerState<QuickPayPage> createState() => _QuickPayPageState();
}

class _QuickPayPageState extends ConsumerState<QuickPayPage> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  final _date = TextEditingController(text: _showDate(DateTime.now().toIso8601String()));
  String? _purchase;
  String _method = 'cash';
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    _date.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    final payments = (ref.watch(_docPurchasePayments).value ?? <DocumentRow>[]).map(_payload).toList();
    final purchases = (ref.watch(_docPurchases).value ?? <DocumentRow>[]).map(_payload).toList();
    return _page(
      context,
      l10n.t('quickPay'),
      back: '/purchases',
      Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              fieldGrid([
                labeledSelect<String?>(
                  label: l10n.t('purchases'),
                  value: _purchase,
                  items: [
                    for (final row in purchases)
                      DropdownMenuItem(
                        value: row['client_uuid']?.toString(),
                        child: Text('${row['invoice_no'] ?? row['supplier_name'] ?? ''}  ${Fixed.rs(Fixed.n(row['total']) - _paid(row, payments), symbol)}'),
                      ),
                  ],
                  onChanged: (value) => setState(() => _purchase = value),
                ),
                labeledField(l10n.t('amount'), _amount, keyboard: TextInputType.number, prefix: symbol),
                labeledSelect<String>(
                  label: l10n.t('paymentMethod'),
                  value: _method,
                  items: [
                    DropdownMenuItem(value: 'cash', child: Text(l10n.t('cash'))),
                    DropdownMenuItem(value: 'bank', child: Text(l10n.t('bank'))),
                  ],
                  onChanged: (value) => setState(() => _method = value ?? 'cash'),
                ),
                labeledField(l10n.t('date'), _date, hint: 'dd/mm/yyyy'),
                labeledField(l10n.t('note'), _note),
              ]),
              if (_error != null) Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C))),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(onPressed: () => context.go('/purchases'), child: Text(l10n.t('cancel'))),
                  const SizedBox(width: 12),
                  FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.t('save'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amount.text.trim()) ?? 0;
    if (_purchase == null || amount <= 0) {
      setState(() => _error = ref.read(l10nProvider).t('amount'));
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(storeProvider).saveMoney('purchase_payment', {
        'purchase_client_uuid': _purchase,
        'amount': amount,
        'method': _method,
        'occurred_on': _isoDate(_date.text) ?? DateTime.now().toIso8601String().substring(0, 10),
        'note': _note.text.trim(),
      });
      if (mounted) context.go('/purchases');
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
