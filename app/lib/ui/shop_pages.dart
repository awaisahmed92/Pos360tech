part of 'pages.dart';

final _docParties = StreamProvider<List<DocumentRow>>((ref) => ref.watch(storeProvider).watchDocuments('party'));
final _docAreas = StreamProvider<List<DocumentRow>>((ref) => ref.watch(storeProvider).watchDocuments('area'));
final _docRecoveries = StreamProvider<List<DocumentRow>>((ref) => ref.watch(storeProvider).watchDocuments('credit_recovery'));
final _docRecipes = StreamProvider<List<DocumentRow>>((ref) => ref.watch(storeProvider).watchDocuments('manufacturing_product'));

Widget _stockSwitch(BuildContext context, L10n l10n, String current) {
  final items = [
    (l10n.t('purchases'), '/purchases'),
    (l10n.t('ledger'), '/stock/ledger'),
    (l10n.t('purchaseOrders'), '/purchases/orders'),
    (l10n.t('returnsRegister'), '/stock/returns'),
    (l10n.t('transfers'), '/stock/transfer'),
    (l10n.t('manufacturing'), '/manufacturing'),
    (l10n.t('adjustment'), '/stock/adjustment'),
    (l10n.t('writeOff'), '/stock/write-off'),
  ];
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: item.$2 == current
                ? FilledButton(onPressed: () {}, child: Text(item.$1))
                : OutlinedButton(onPressed: () => context.go(item.$2), child: Text(item.$1)),
          ),
      ],
    ),
  );
}

double _partyBalance(Map<String, dynamic> party, List<Map<String, dynamic>> recoveries) {
  final opening = Fixed.n(party['opening_balance']);
  final signed = party['balance_side'] == 'we_owe' ? -opening : opening;
  final paid = recoveries.where((row) => row['party_client_uuid'] == party['client_uuid']).fold<double>(0, (sum, row) => sum + Fixed.n(row['amount']));
  return signed - paid;
}

class PartiesPage extends ConsumerStatefulWidget {
  const PartiesPage({super.key});

  @override
  ConsumerState<PartiesPage> createState() => _PartiesPageState();
}

class _PartiesPageState extends ConsumerState<PartiesPage> {
  final _search = TextEditingController();
  String _type = 'all';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    final recoveries = (ref.watch(_docRecoveries).value ?? <DocumentRow>[]).map(_payload).toList();
    final query = _search.text.trim().toLowerCase();
    final rows = (ref.watch(_docParties).value ?? <DocumentRow>[]).map(_payload).where((row) {
      if (_type != 'all' && row['type'] != _type) return false;
      if (query.isEmpty) return true;
      return '${row['name']} ${row['phone']}'.toLowerCase().contains(query);
    }).toList();
    final customers = rows.where((row) => row['type'] != 'supplier').toList();
    final suppliers = rows.where((row) => row['type'] == 'supplier').toList();
    double sumWhere(List<Map<String, dynamic>> list, bool positive) {
      return list.fold<double>(0, (sum, row) {
        final balance = _partyBalance(row, recoveries);
        if (positive && balance > 0) return sum + balance;
        if (!positive && balance < 0) return sum + balance.abs();
        return sum;
      });
    }

    return _page(
      context,
      l10n.t('customers'),
      back: '/dashboard',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(onPressed: () => context.go('/parties/recovery'), child: Text(l10n.t('creditRecovery'))),
              OutlinedButton(onPressed: () => context.go('/parties/areas'), child: Text(l10n.t('areas'))),
              FilledButton.icon(onPressed: () => context.go('/parties/new'), icon: const Icon(Icons.add), label: Text(l10n.t('add'))),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _stat(l10n.t('customerCount'), '${customers.length}', const Color(0xFF1D4ED8), fill: const Color(0xFFEFF6FF)),
              _stat(l10n.t('udhaarAccounts'), '${customers.where((row) => _partyBalance(row, recoveries) > 0).length}', const Color(0xFFB45309), fill: const Color(0xFFFFF7ED)),
              _stat(l10n.t('customerCredit'), Fixed.rs(sumWhere(customers, true), symbol), const Color(0xFFB91C1C), fill: const Color(0xFFFEF2F2)),
              _stat(l10n.t('suppliers'), '${suppliers.length}', const Color(0xFF0F766E), fill: const Color(0xFFF0FDFA)),
              _stat(l10n.t('payableAccounts'), '${suppliers.where((row) => _partyBalance(row, recoveries) < 0).length}', const Color(0xFFB45309), fill: const Color(0xFFFFFBEB)),
              _stat(l10n.t('supplierCredit'), Fixed.rs(sumWhere(suppliers, false), symbol), const Color(0xFF9A3412), fill: const Color(0xFFFFF7ED)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 160,
                child: labeledSelect<String>(
                  label: l10n.t('type'),
                  value: _type,
                  items: [
                    DropdownMenuItem(value: 'all', child: Text(l10n.t('all'))),
                    DropdownMenuItem(value: 'customer', child: Text(l10n.t('customers'))),
                    DropdownMenuItem(value: 'supplier', child: Text(l10n.t('suppliers'))),
                  ],
                  onChanged: (value) => setState(() => _type = value ?? 'all'),
                ),
              ),
              SizedBox(width: 240, child: labeledField(l10n.t('search'), _search, onChanged: (_) => setState(() {}))),
            ],
          ),
          const SizedBox(height: 12),
          _table(
            context,
            [l10n.t('itemName'), l10n.t('type'), l10n.t('phone'), l10n.t('balanceWord')],
            rows
                .map((row) => [
                      _bilingual(row['name']?.toString() ?? '', row['name_ur']?.toString() ?? ''),
                      row['type'] == 'supplier' ? l10n.t('suppliers') : l10n.t('customers'),
                      row['phone']?.toString() ?? '',
                      Fixed.rs(_partyBalance(row, recoveries), symbol),
                    ])
                .toList(),
            rows.isEmpty ? l10n.t('noRecords') : null,
            onEdit: (index) => context.go('/parties/edit/${rows[index]['client_uuid']}'),
          ),
        ],
      ),
    );
  }
}

class PartyFormPage extends ConsumerStatefulWidget {
  const PartyFormPage({super.key, this.clientUuid});

  final String? clientUuid;

  @override
  ConsumerState<PartyFormPage> createState() => _PartyFormPageState();
}

class _PartyFormPageState extends ConsumerState<PartyFormPage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _cnic = TextEditingController();
  final _ntn = TextEditingController();
  final _strn = TextEditingController();
  final _opening = TextEditingController(text: '0');
  final _address = TextEditingController();
  String _type = 'customer';
  String _route = '';
  String? _area;
  String _side = 'they_owe';
  String _price = 'ask';
  bool _loaded = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final controller in [_name, _phone, _email, _cnic, _ntn, _strn, _opening, _address]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    final rows = ref.watch(_docParties).value ?? <DocumentRow>[];
    final areas = (ref.watch(_docAreas).value ?? <DocumentRow>[]).map(_payload).toList();
    if (!_loaded && widget.clientUuid != null) {
      final match = rows.where((row) => row.clientUuid == widget.clientUuid);
      if (match.isNotEmpty) {
        final payload = _payload(match.first);
        final name = payload['name']?.toString() ?? '';
        _name.text = name.trim().isNotEmpty ? name : (payload['name_ur']?.toString() ?? '');
        _phone.text = payload['phone']?.toString() ?? '';
        _email.text = payload['email']?.toString() ?? '';
        _cnic.text = payload['cnic']?.toString() ?? '';
        _ntn.text = payload['ntn']?.toString() ?? '';
        _strn.text = payload['strn']?.toString() ?? '';
        _opening.text = payload['opening_balance']?.toString() ?? '0';
        _address.text = payload['address']?.toString() ?? '';
        _type = payload['type']?.toString() ?? 'customer';
        _route = payload['route_day']?.toString() ?? '';
        _area = payload['area_client_uuid']?.toString();
        _side = payload['balance_side']?.toString() ?? 'they_owe';
        _price = payload['price_mode']?.toString() ?? 'ask';
        _loaded = true;
      }
    }
    return _page(
      context,
      l10n.t('addParty'),
      back: '/parties',
      Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              fieldGrid([
                labeledSelect<String>(
                  label: l10n.t('type'),
                  value: _type,
                  items: [
                    DropdownMenuItem(value: 'customer', child: Text(l10n.t('customers'))),
                    DropdownMenuItem(value: 'supplier', child: Text(l10n.t('suppliers'))),
                  ],
                  onChanged: (value) => setState(() => _type = value ?? 'customer'),
                ),
                labeledField('${l10n.t('itemName')} *', _name),
                labeledField(l10n.t('phone'), _phone),
                labeledSelect<String>(
                  label: l10n.t('routeDay'),
                  value: _route,
                  items: [
                    DropdownMenuItem(value: '', child: Text(l10n.t('none'))),
                    for (final day in ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'])
                      DropdownMenuItem(value: day, child: Text(day)),
                  ],
                  onChanged: (value) => setState(() => _route = value ?? ''),
                ),
                labeledSelect<String?>(
                  label: l10n.t('areas'),
                  value: _area,
                  items: [
                    DropdownMenuItem(value: null, child: Text(l10n.t('none'))),
                    for (final area in areas) DropdownMenuItem(value: area['client_uuid']?.toString(), child: Text(area['name']?.toString() ?? '')),
                  ],
                  onChanged: (value) => setState(() => _area = value),
                ),
                labeledField(l10n.t('email'), _email),
                labeledField('CNIC', _cnic),
                labeledField('NTN', _ntn),
                labeledField('STRN', _strn),
                labeledField(l10n.t('openingBalance'), _opening, keyboard: TextInputType.number, prefix: symbol),
              ]),
              const SizedBox(height: 8),
              Text(l10n.t('openingBalance'), style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(label: Text(l10n.t('theyOwe')), selected: _side == 'they_owe', onSelected: (_) => setState(() => _side = 'they_owe')),
                  ChoiceChip(label: Text(l10n.t('weOwe')), selected: _side == 'we_owe', onSelected: (_) => setState(() => _side = 'we_owe')),
                ],
              ),
              labeledSelect<String>(
                label: l10n.t('defaultPrice'),
                value: _price,
                items: [
                  DropdownMenuItem(value: 'ask', child: Text(l10n.t('askPrice'))),
                  DropdownMenuItem(value: 'retail', child: Text(l10n.t('salePrice'))),
                  DropdownMenuItem(value: 'wholesale', child: Text(l10n.t('wholesale'))),
                ],
                onChanged: (value) => setState(() => _price = value ?? 'ask'),
              ),
              const SizedBox(height: 12),
              labeledField(l10n.t('address'), _address),
              if (_error != null) Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C))),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(onPressed: () => context.go('/parties'), child: Text(l10n.t('cancel'))),
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
      await ref.read(storeProvider).saveMoney('party', {
        if (widget.clientUuid != null) 'client_uuid': widget.clientUuid,
        'type': _type,
        'name': _name.text.trim(),
        'name_ur': _name.text.trim(),
        'phone': _phone.text.trim(),
        'route_day': _route,
        if (_area != null) 'area_client_uuid': _area,
        'email': _email.text.trim(),
        'cnic': _cnic.text.trim(),
        'ntn': _ntn.text.trim(),
        'strn': _strn.text.trim(),
        'opening_balance': double.tryParse(_opening.text.trim()) ?? 0,
        'balance_side': _side,
        'price_mode': _price,
        'address': _address.text.trim(),
      });
      if (mounted) context.go('/parties');
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class AreasPage extends ConsumerStatefulWidget {
  const AreasPage({super.key});

  @override
  ConsumerState<AreasPage> createState() => _AreasPageState();
}

class _AreasPageState extends ConsumerState<AreasPage> {
  final _name = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final rows = (ref.watch(_docAreas).value ?? <DocumentRow>[]).map(_payload).toList();
    return _page(
      context,
      l10n.t('areas'),
      back: '/parties',
      Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: labeledField(l10n.t('areaHint'), _name)),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.t('newArea'))),
                ],
              ),
              const SizedBox(height: 8),
              Text(l10n.t('areaHelp'), style: const TextStyle(color: Color(0xFF64748B))),
              const SizedBox(height: 12),
              _table(
                context,
                [l10n.t('itemName')],
                rows.map((row) => [row['name']?.toString() ?? '']).toList(),
                rows.isEmpty ? l10n.t('noRecords') : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      await ref.read(storeProvider).saveMoney('area', {'name': _name.text.trim()});
      _name.clear();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class CreditRecoveryPage extends ConsumerStatefulWidget {
  const CreditRecoveryPage({super.key});

  @override
  ConsumerState<CreditRecoveryPage> createState() => _CreditRecoveryPageState();
}

class _CreditRecoveryPageState extends ConsumerState<CreditRecoveryPage> {
  final _from = TextEditingController(text: _showDate(DateTime.now().toIso8601String()));
  final _to = TextEditingController(text: _showDate(DateTime.now().toIso8601String()));
  final _amount = TextEditingController();
  final _note = TextEditingController();
  String _side = 'customer';
  String? _party;
  String _method = 'cash';
  bool _busy = false;

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    final parties = (ref.watch(_docParties).value ?? <DocumentRow>[]).map(_payload).where((row) => row['type'] == (_side == 'supplier' ? 'supplier' : 'customer')).toList();
    final from = _isoDate(_from.text);
    final to = _isoDate(_to.text);
    final rows = (ref.watch(_docRecoveries).value ?? <DocumentRow>[]).map(_payload).where((row) {
      final party = (ref.watch(_docParties).value ?? <DocumentRow>[]).map(_payload).cast<Map<String, dynamic>?>().firstWhere((item) => item?['client_uuid'] == row['party_client_uuid'], orElse: () => null);
      if (_side == 'supplier' && party?['type'] != 'supplier') return false;
      if (_side == 'customer' && party?['type'] == 'supplier') return false;
      final day = row['occurred_on']?.toString() ?? '';
      if (from != null && day.compareTo(from) < 0) return false;
      if (to != null && day.compareTo(to) > 0) return false;
      return true;
    }).toList();
    final total = rows.fold<double>(0, (sum, row) => sum + Fixed.n(row['amount']));
    return _page(
      context,
      l10n.t('creditRecovery'),
      back: '/parties',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.t('recoveryHelp'), style: const TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(width: 150, child: labeledField(l10n.t('from'), _from, hint: 'dd/mm/yyyy')),
              SizedBox(width: 150, child: labeledField(l10n.t('to'), _to, hint: 'dd/mm/yyyy')),
              FilledButton(onPressed: () => setState(() {}), child: Text(l10n.t('run'))),
              OutlinedButton(onPressed: () => _csv(rows), child: Text(l10n.t('exportCsv'))),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(label: Text(l10n.t('customers')), selected: _side == 'customer', onSelected: (_) => setState(() => _side = 'customer')),
              ChoiceChip(label: Text(l10n.t('suppliers')), selected: _side == 'supplier', onSelected: (_) => setState(() => _side = 'supplier')),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              _stat(l10n.t('recoveryTotal'), Fixed.rs(total, symbol), const Color(0xFF15803D), fill: const Color(0xFFDCFCE7)),
              _stat(l10n.t('entries'), '${rows.length}', const Color(0xFF1E293B), fill: const Color(0xFFE2E8F0)),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: fieldGrid([
                labeledSelect<String?>(
                  label: _side == 'supplier' ? l10n.t('supplier') : l10n.t('customers'),
                  value: _party,
                  items: [for (final party in parties) DropdownMenuItem(value: party['client_uuid']?.toString(), child: Text(party['name']?.toString() ?? ''))],
                  onChanged: (value) => setState(() => _party = value),
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
                labeledField(l10n.t('note'), _note),
              ]),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.t('save'))),
          ),
          const SizedBox(height: 12),
          _table(
            context,
            [l10n.t('date'), l10n.t('customers'), l10n.t('phone'), l10n.t('paymentMethod'), l10n.t('note'), l10n.t('amount')],
            rows.map((row) {
              final party = (ref.watch(_docParties).value ?? <DocumentRow>[]).map(_payload).cast<Map<String, dynamic>?>().firstWhere((item) => item?['client_uuid'] == row['party_client_uuid'], orElse: () => null);
              return [
                _showDate(row['occurred_on']),
                party?['name']?.toString() ?? '',
                party?['phone']?.toString() ?? '',
                row['method']?.toString() ?? '',
                row['note']?.toString() ?? '',
                Fixed.rs(row['amount'], symbol),
              ];
            }).toList(),
            rows.isEmpty ? l10n.t('noRecords') : null,
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amount.text.trim()) ?? 0;
    if (_party == null || amount <= 0) return;
    setState(() => _busy = true);
    try {
      await ref.read(storeProvider).saveMoney('credit_recovery', {
        'party_client_uuid': _party,
        'occurred_on': _isoDate(_to.text) ?? DateTime.now().toIso8601String().substring(0, 10),
        'amount': amount,
        'method': _method,
        'note': _note.text.trim(),
      });
      _amount.clear();
      _note.clear();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _csv(List<Map<String, dynamic>> rows) async {
    final buffer = StringBuffer('Date,Party,Amount,Method,Note\n');
    for (final row in rows) {
      buffer.writeln('${row['occurred_on']},${row['party_client_uuid']},${row['amount']},${row['method']},"${row['note'] ?? ''}"');
    }
    final path = await saveBytes(utf8.encode(buffer.toString()), 'credit-recovery.csv', 'text/csv');
    if (mounted) _toast(context, path);
  }
}

class PartyReportPage extends ConsumerStatefulWidget {
  const PartyReportPage({super.key});

  @override
  ConsumerState<PartyReportPage> createState() => _PartyReportPageState();
}

class _PartyReportPageState extends ConsumerState<PartyReportPage> {
  final _search = TextEditingController();
  String _type = 'customer';
  String _route = '';
  bool _onlyOwe = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    final recoveries = (ref.watch(_docRecoveries).value ?? <DocumentRow>[]).map(_payload).toList();
    final query = _search.text.trim().toLowerCase();
    final rows = (ref.watch(_docParties).value ?? <DocumentRow>[]).map(_payload).where((row) {
      if (row['type'] != _type) return false;
      if (_route.isNotEmpty && row['route_day']?.toString() != _route) return false;
      if (query.isNotEmpty && !'${row['name']} ${row['phone']}'.toLowerCase().contains(query)) return false;
      if (_onlyOwe && _partyBalance(row, recoveries) <= 0) return false;
      return true;
    }).toList();
    return _page(
      context,
      l10n.t('partyReport'),
      back: '/reports',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  labeledField(l10n.t('search'), _search, onChanged: (_) => setState(() {})),
                  const SizedBox(height: 8),
                  fieldGrid([
                    labeledSelect<String>(
                      label: l10n.t('type'),
                      value: _type,
                      items: [
                        DropdownMenuItem(value: 'customer', child: Text(l10n.t('customers'))),
                        DropdownMenuItem(value: 'supplier', child: Text(l10n.t('suppliers'))),
                      ],
                      onChanged: (value) => setState(() => _type = value ?? 'customer'),
                    ),
                    labeledSelect<String>(
                      label: l10n.t('routeDay'),
                      value: _route,
                      items: [
                        DropdownMenuItem(value: '', child: Text(l10n.t('all'))),
                        for (final day in ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'])
                          DropdownMenuItem(value: day, child: Text(day)),
                      ],
                      onChanged: (value) => setState(() => _route = value ?? ''),
                    ),
                  ]),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _onlyOwe,
                    onChanged: (value) => setState(() => _onlyOwe = value ?? false),
                    title: Text(l10n.t('onlyOwe')),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton(onPressed: () => setState(() {}), child: Text(l10n.t('apply'))),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _table(
            context,
            [l10n.t('partyName'), l10n.t('routeDay'), l10n.t('phone'), l10n.t('receivable')],
            rows
                .map((row) => [
                      row['name']?.toString() ?? '',
                      row['route_day']?.toString() ?? '',
                      row['phone']?.toString() ?? '',
                      Fixed.rs(_partyBalance(row, recoveries), symbol),
                    ])
                .toList(),
            rows.isEmpty ? l10n.t('noRecords') : null,
          ),
        ],
      ),
    );
  }
}

class ManufacturingPage extends ConsumerWidget {
  const ManufacturingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    final rows = (ref.watch(_docRecipes).value ?? <DocumentRow>[]).map(_payload).toList();
    return _page(
      context,
      l10n.t('manufacturing'),
      back: '/dashboard',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stockSwitch(context, l10n, '/manufacturing'),
          const SizedBox(height: 8),
          Text(l10n.t('manufacturingHelp'), style: const TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(onPressed: () => context.go('/manufacturing/new'), icon: const Icon(Icons.add), label: Text(l10n.t('newManufacturing'))),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _stat(l10n.t('madeProducts'), '${rows.length}', const Color(0xFF1D4ED8)),
              _stat(l10n.t('batchesMonth'), '0', const Color(0xFF0F766E)),
              _stat(l10n.t('productionCost'), Fixed.rs(0, symbol), const Color(0xFFB45309)),
            ],
          ),
          const SizedBox(height: 16),
          if (rows.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(l10n.t('makeFirst'), style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(l10n.t('manufacturingSteps'), textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF64748B))),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: () => context.go('/manufacturing/new'), child: Text(l10n.t('newManufacturing'))),
                  ],
                ),
              ),
            )
          else
            _table(
              context,
              [l10n.t('itemName'), l10n.t('code'), l10n.t('salePrice'), l10n.t('wholesale')],
              rows
                  .map((row) => [
                        row['name']?.toString() ?? '',
                        row['code']?.toString() ?? '',
                        Fixed.rs(row['sale_price'], symbol),
                        Fixed.rs(row['wholesale_price'], symbol),
                      ])
                  .toList(),
              null,
            ),
        ],
      ),
    );
  }
}

class ManufacturingFormPage extends ConsumerStatefulWidget {
  const ManufacturingFormPage({super.key});

  @override
  ConsumerState<ManufacturingFormPage> createState() => _ManufacturingFormPageState();
}

class _MaterialLine {
  String? productUuid;
  final qty = TextEditingController(text: '1');
  void dispose() => qty.dispose();
}

class _ManufacturingFormPageState extends ConsumerState<ManufacturingFormPage> {
  final _code = TextEditingController();
  final _barcode = TextEditingController();
  final _name = TextEditingController();
  final _qty = TextEditingController(text: '1');
  final _sale = TextEditingController(text: '0');
  final _wholesale = TextEditingController(text: '0');
  final _packName = TextEditingController();
  final _packPieces = TextEditingController(text: '1');
  final _packSale = TextEditingController(text: '0');
  final _packWholesale = TextEditingController(text: '0');
  final _packBarcode = TextEditingController();
  final _description = TextEditingController();
  final _materials = <_MaterialLine>[_MaterialLine()];
  String? _unit;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final controller in [_code, _barcode, _name, _qty, _sale, _wholesale, _packName, _packPieces, _packSale, _packWholesale, _packBarcode, _description]) {
      controller.dispose();
    }
    for (final line in _materials) {
      line.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    final products = ref.watch(_products).value ?? <ProductRow>[];
    final units = ref.watch(_units).value ?? <UnitRow>[];
    var materialCost = 0.0;
    for (final line in _materials) {
      final product = products.cast<ProductRow?>().firstWhere((row) => row?.clientUuid == line.productUuid, orElse: () => null);
      materialCost += (double.tryParse(line.qty.text) ?? 0) * Fixed.n(product?.purchasePrice);
    }
    final madeQty = double.tryParse(_qty.text) ?? 1;
    final each = madeQty <= 0 ? materialCost : materialCost / madeQty;
    return _page(
      context,
      l10n.t('newManufacturing'),
      back: '/manufacturing',
      Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              fieldGrid([
                labeledField(l10n.t('code'), _code),
                labeledField(l10n.t('barcode'), _barcode),
                labeledField('${l10n.t('itemName')} *', _name),
                labeledField(l10n.t('qty'), _qty, keyboard: TextInputType.number, onChanged: (_) => setState(() {})),
                labeledSelect<String?>(
                  label: l10n.t('unit'),
                  value: _unit,
                  items: [for (final unit in units) DropdownMenuItem(value: unit.clientUuid, child: Text(unit.nameEn))],
                  onChanged: (value) => setState(() => _unit = value),
                ),
                labeledField(l10n.t('salePrice'), _sale, keyboard: TextInputType.number, prefix: symbol),
                labeledField(l10n.t('wholesale'), _wholesale, keyboard: TextInputType.number, prefix: symbol),
              ]),
              const SizedBox(height: 16),
              Text(l10n.t('packaging'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              fieldGrid([
                labeledField(l10n.t('itemName'), _packName),
                labeledField(l10n.t('piecesInside'), _packPieces, keyboard: TextInputType.number),
                labeledField(l10n.t('salePrice'), _packSale, keyboard: TextInputType.number, prefix: symbol),
                labeledField(l10n.t('wholesale'), _packWholesale, keyboard: TextInputType.number, prefix: symbol),
                labeledField(l10n.t('barcode'), _packBarcode),
              ]),
              const SizedBox(height: 16),
              Text(l10n.t('rawMaterials'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              for (var i = 0; i < _materials.length; i++)
                fieldGrid([
                  labeledSelect<String?>(
                    label: l10n.t('products'),
                    value: _materials[i].productUuid,
                    items: [for (final product in products) DropdownMenuItem(value: product.clientUuid, child: Text(product.nameEn))],
                    onChanged: (value) => setState(() => _materials[i].productUuid = value),
                  ),
                  labeledField(l10n.t('qty'), _materials[i].qty, keyboard: TextInputType.number, onChanged: (_) => setState(() {})),
                ]),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(onPressed: () => setState(() => _materials.add(_MaterialLine())), icon: const Icon(Icons.add), label: Text(l10n.t('addMaterial'))),
              ),
              Text('${l10n.t('materialsCost')} ${Fixed.rs(materialCost, symbol)}    ${l10n.t('costEach')} ${Fixed.rs(each, symbol)}', style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(l10n.t('manufacturingNote'), style: const TextStyle(color: Color(0xFF64748B))),
              const SizedBox(height: 12),
              labeledField(l10n.t('description'), _description),
              if (_error != null) Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C))),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(onPressed: () => context.go('/manufacturing'), child: Text(l10n.t('cancel'))),
                  const SizedBox(width: 12),
                  FilledButton(onPressed: _busy ? null : () => _save(each), child: Text(l10n.t('saveManufacturing'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save(double each) async {
    final materials = <Map<String, dynamic>>[];
    for (final line in _materials) {
      final qty = double.tryParse(line.qty.text.trim()) ?? 0;
      if (line.productUuid == null || qty <= 0) continue;
      materials.add({'product_client_uuid': line.productUuid, 'qty': qty});
    }
    if (_name.text.trim().isEmpty || _unit == null || materials.isEmpty) {
      setState(() => _error = ref.read(l10nProvider).t('rawMaterials'));
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(storeProvider).saveProduct(
            nameEn: _name.text.trim(),
            nameUr: '',
            code: _code.text.trim(),
            barcode: _barcode.text.trim(),
            unitUuid: _unit!,
            purchasePrice: each.toString(),
            salePrice: _sale.text.trim().isEmpty ? '0' : _sale.text.trim(),
            wholesalePrice: _wholesale.text.trim().isEmpty ? '0' : _wholesale.text.trim(),
            alertQty: '0',
          );
      await ref.read(storeProvider).saveMoney('manufacturing_product', {
        'code': _code.text.trim(),
        'barcode': _barcode.text.trim(),
        'name': _name.text.trim(),
        'unit_client_uuid': _unit,
        'qty': double.tryParse(_qty.text.trim()) ?? 1,
        'sale_price': double.tryParse(_sale.text.trim()) ?? 0,
        'wholesale_price': double.tryParse(_wholesale.text.trim()) ?? 0,
        'description': _description.text.trim(),
        'packaging': {
          'name': _packName.text.trim(),
          'pieces': double.tryParse(_packPieces.text.trim()) ?? 1,
          'sale_price': double.tryParse(_packSale.text.trim()) ?? 0,
          'wholesale_price': double.tryParse(_packWholesale.text.trim()) ?? 0,
          'barcode': _packBarcode.text.trim(),
        },
        'materials': materials,
      });
      if (mounted) context.go('/manufacturing');
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
