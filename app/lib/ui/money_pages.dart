part of 'pages.dart';

const _teal = Color(0xFF0F766E);

class _ReportInfo {
  const _ReportInfo(this.key, this.title, this.subtitle, this.color, this.icon);
  final String key;
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
}

const _reports = <_ReportInfo>[
  _ReportInfo('sales', 'Sales', 'Sales by date range', Color(0xFF1D4ED8), Icons.receipt_long),
  _ReportInfo('purchases', 'Purchases', 'Purchase invoices by date range', Color(0xFF7C3AED), Icons.shopping_bag_outlined),
  _ReportInfo('supplier-discounts', 'Supplier discounts', 'List price and discount vs paid cost', Color(0xFFDC2626), Icons.local_offer_outlined),
  _ReportInfo('best-sellers', 'Best sellers', 'Most sold products by quantity and revenue', Color(0xFFB91C1C), Icons.local_fire_department_outlined),
  _ReportInfo('stock', 'Stock', 'Inventory valuation', Color(0xFF15803D), Icons.warehouse_outlined),
  _ReportInfo('profit-loss', 'Profit & loss', 'Revenue vs cost', Color(0xFF047857), Icons.trending_up),
  _ReportInfo('customer-profit', 'Customer profit', 'Profit earned from each customer', Color(0xFF0F766E), Icons.person_outline),
  _ReportInfo('product-profit', 'Product profit', 'Profit and margin for each product', Color(0xFF065F46), Icons.inventory_2_outlined),
  _ReportInfo('bill-profit', 'Bill-wise profit', 'Profit and margin for each invoice', Color(0xFF1D4ED8), Icons.receipt_outlined),
  _ReportInfo('category-profit', 'Category profit', 'Sale and profit grouped by category', Color(0xFF7C3AED), Icons.category_outlined),
  _ReportInfo('slow-stock', 'Slow & dead stock', 'Items sitting in stock with few or no sales', Color(0xFF2563EB), Icons.hourglass_bottom),
  _ReportInfo('staff', 'Staff performance', 'Sales, profit and commission per staff', Color(0xFFEA580C), Icons.emoji_events_outlined),
  _ReportInfo('fbr', 'FBR', 'Tax summary for FBR', Color(0xFF6D28D9), Icons.account_balance_outlined),
  _ReportInfo('expiry', 'Expiry', 'Near-expiry and expired stock', Color(0xFF7C3AED), Icons.event_busy_outlined),
  _ReportInfo('trial-balance', 'Trial balance', 'Every account debit and credit balance', Color(0xFFB45309), Icons.balance),
  _ReportInfo('balance-sheet', 'Balance sheet', 'Assets, liabilities and equity', Color(0xFF0F766E), Icons.account_balance),
  _ReportInfo('general-ledger', 'General ledger', 'One account, every entry, running balance', Color(0xFF6D28D9), Icons.menu_book_outlined),
  _ReportInfo('aging', 'Aging', 'Outstanding balances by 30 / 60 / 90 days', Color(0xFFBE123C), Icons.timelapse),
  _ReportInfo('party', 'Party report', 'Customers and suppliers with outstanding balance', Color(0xFF4338CA), Icons.groups_outlined),
  _ReportInfo('credit-recovery', 'Credit recovery', 'Who paid back today, with the day total', Color(0xFF15803D), Icons.payments_outlined),
];

final _docCheques = StreamProvider<List<DocumentRow>>((ref) => ref.watch(storeProvider).watchDocuments('cheque'));
final _docPartners = StreamProvider<List<DocumentRow>>((ref) => ref.watch(storeProvider).watchDocuments('investment_partner'));
final _docEntries = StreamProvider<List<DocumentRow>>((ref) => ref.watch(storeProvider).watchDocuments('investment_entry'));
final _docJournals = StreamProvider<List<DocumentRow>>((ref) => ref.watch(storeProvider).watchDocuments('journal_entry'));
final _docCloses = StreamProvider<List<DocumentRow>>((ref) => ref.watch(storeProvider).watchDocuments('day_close'));

Map<String, dynamic> _payload(DocumentRow row) {
  return Map<String, dynamic>.from(jsonDecode(row.payload) as Map);
}

String _showDate(Object? value) {
  final raw = value?.toString() ?? '';
  final date = DateTime.tryParse(raw);
  if (date == null) return raw;
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String? _isoDate(String text) {
  final raw = text.trim();
  if (raw.isEmpty) return null;
  final parts = raw.split('/');
  if (parts.length == 3 && parts[2].length == 4) {
    return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
  }
  return raw;
}

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    return _page(
      context,
      l10n.t('reports'),
      LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1100 ? 5 : constraints.maxWidth >= 760 ? 3 : 2;
          final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final report in _reports)
                SizedBox(
                  width: width,
                  height: 118,
                  child: Material(
                    color: report.color,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => context.go('/reports/${report.key}'),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(report.icon, color: Colors.white, size: 22),
                                const Spacer(),
                                const Icon(Icons.chevron_right, color: Colors.white70, size: 20),
                              ],
                            ),
                            const Spacer(),
                            Text(report.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(report.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.25)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class ReportDetailPage extends ConsumerWidget {
  const ReportDetailPage({super.key, required this.reportKey});

  final String reportKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbol = ref.watch(moneySymbolProvider);
    final report = _reports.where((item) => item.key == reportKey).firstOrNull ?? _reports.first;
    final products = ref.watch(_products).value ?? <ProductRow>[];
    final balances = ref.watch(_balances).value ?? <BalanceRow>[];
    final rows = <List<String>>[];
    late final List<String> headers;
    if (report.key == 'stock' || report.key == 'slow-stock') {
      headers = ['Product', 'Code', 'Quantity', 'Stock value'];
      for (final product in products.where((row) => row.trackStock)) {
        final scoped = balances.where((row) => row.productClientUuid == product.clientUuid);
        final qty = scoped.fold<double>(0, (sum, row) => sum + Fixed.n(row.qtyOnHand));
        final value = scoped.fold<double>(0, (sum, row) => sum + Fixed.n(row.stockValue));
        if (report.key == 'slow-stock' && qty <= 0) continue;
        rows.add([product.nameEn, product.code, Fixed.qty(qty), Fixed.rs(value, symbol)]);
      }
    } else if (report.key == 'profit-loss') {
      headers = ['Sales', 'Cost', 'Profit'];
      rows.add([Fixed.rs(0, symbol), Fixed.rs(0, symbol), Fixed.rs(0, symbol)]);
    } else {
      headers = ['Date', 'Reference', 'Party', 'Amount'];
    }
    return _page(
      context,
      report.title,
      back: '/reports',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(report.subtitle, style: const TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          _table(context, headers, rows, rows.isEmpty ? 'No records yet. This report fills in as ${report.title.toLowerCase()} is posted.' : null),
        ],
      ),
    );
  }
}

class ChequesPage extends ConsumerWidget {
  const ChequesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    final docs = ref.watch(_docCheques).value ?? <DocumentRow>[];
    final rows = docs.map((doc) {
      final data = _payload(doc);
      return [
        _showDate(data['issued_on']),
        data['cheque_no']?.toString() ?? '',
        data['direction'] == 'out' ? l10n.t('chequeOut') : l10n.t('chequeIn'),
        data['bank']?.toString() ?? '',
        data['party_name']?.toString() ?? '',
        Fixed.rs(data['amount'], symbol),
        l10n.t(data['status']?.toString() ?? 'pending'),
      ];
    }).toList();
    return _page(
      context,
      l10n.t('cheques'),
      _table(context, [l10n.t('date'), l10n.t('chequeNo'), l10n.t('direction'), l10n.t('bank'), l10n.t('party'), l10n.t('amount'), l10n.t('status')], rows, rows.isEmpty ? l10n.t('noRecords') : null),
      action: FilledButton.icon(onPressed: () => context.go('/cheques/new'), icon: const Icon(Icons.add), label: Text(l10n.t('add'))),
    );
  }
}

class ChequeFormPage extends ConsumerStatefulWidget {
  const ChequeFormPage({super.key});

  @override
  ConsumerState<ChequeFormPage> createState() => _ChequeFormPageState();
}

class _ChequeFormPageState extends ConsumerState<ChequeFormPage> {
  String _direction = 'in';
  String _status = 'pending';
  final _number = TextEditingController();
  final _bank = TextEditingController();
  final _party = TextEditingController();
  final _amount = TextEditingController();
  final _date = TextEditingController();
  final _cleared = TextEditingController();
  final _note = TextEditingController();
  String? _branch;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _number.dispose();
    _bank.dispose();
    _party.dispose();
    _amount.dispose();
    _date.dispose();
    _cleared.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    final branches = ref.watch(_branches).value ?? <BranchRow>[];
    return _page(
      context,
      l10n.t('cheques'),
      back: '/cheques',
      Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              fieldGrid([
                labeledSelect<String>(
                  label: l10n.t('direction'),
                  value: _direction,
                  items: [
                    DropdownMenuItem(value: 'in', child: Text(l10n.t('chequeIn'))),
                    DropdownMenuItem(value: 'out', child: Text(l10n.t('chequeOut'))),
                  ],
                  onChanged: (value) => setState(() => _direction = value ?? 'in'),
                ),
                labeledField(l10n.t('chequeNo'), _number),
                labeledField(l10n.t('bank'), _bank),
                labeledSelect<String?>(
                  label: l10n.t('branch'),
                  value: _branch,
                  items: branches.map((row) => DropdownMenuItem(value: row.clientUuid, child: Text(row.name))).toList(),
                  onChanged: (value) => setState(() => _branch = value),
                ),
                labeledField(l10n.t('party'), _party),
                labeledField(l10n.t('amount'), _amount, keyboard: TextInputType.number, prefix: symbol),
                labeledField(l10n.t('date'), _date, hint: 'dd/mm/yyyy'),
                labeledField(l10n.t('clearedDate'), _cleared, hint: 'dd/mm/yyyy'),
                labeledSelect<String>(
                  label: l10n.t('status'),
                  value: _status,
                  items: [
                    DropdownMenuItem(value: 'pending', child: Text(l10n.t('pending'))),
                    DropdownMenuItem(value: 'cleared', child: Text(l10n.t('cleared'))),
                    DropdownMenuItem(value: 'bounced', child: Text(l10n.t('bounced'))),
                  ],
                  onChanged: (value) => setState(() => _status = value ?? 'pending'),
                ),
                labeledField(l10n.t('note'), _note),
              ]),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C))),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(onPressed: () => context.go('/cheques'), child: Text(l10n.t('cancel'))),
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
    final l10n = ref.read(l10nProvider);
    final issued = _isoDate(_date.text);
    if (_number.text.trim().isEmpty || issued == null || (double.tryParse(_amount.text.trim()) ?? 0) <= 0) {
      setState(() => _error = l10n.t('chequeNo'));
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(storeProvider).saveMoney('cheque', {
        'direction': _direction,
        'cheque_no': _number.text.trim(),
        'bank': _bank.text.trim(),
        'party_name': _party.text.trim(),
        'branch_client_uuid': _branch,
        'amount': _amount.text.trim(),
        'issued_on': issued,
        'cleared_on': _isoDate(_cleared.text),
        'status': _status,
        'note': _note.text.trim(),
      });
      if (mounted) context.go('/cheques');
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class InvestmentPage extends ConsumerStatefulWidget {
  const InvestmentPage({super.key});

  @override
  ConsumerState<InvestmentPage> createState() => _InvestmentPageState();
}

class _InvestmentPageState extends ConsumerState<InvestmentPage> {
  String _tab = 'history';
  bool _seeded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    final session = ref.watch(sessionProvider).value;
    final partners = ref.watch(_docPartners).value ?? <DocumentRow>[];
    final entries = ref.watch(_docEntries).value ?? <DocumentRow>[];
    if (!_seeded && partners.isEmpty && session != null) {
      _seeded = true;
      Future.microtask(() => ref.read(storeProvider).saveMoney('investment_partner', {
            'name': session.name.isEmpty ? l10n.t('owner') : session.name,
            'is_owner': true,
            'profit_share': '100',
            'loss_share': '100',
            'shares_loss': true,
          }));
    }
    final partnerRows = partners.map(_payload).toList();
    final entryRows = entries.map(_payload).toList();
    var moneyIn = 0.0;
    var moneyOut = 0.0;
    for (final row in entryRows) {
      final amount = Fixed.n(row['amount']);
      if (row['kind'] == 'out') {
        moneyOut += amount;
      } else {
        moneyIn += amount;
      }
    }
    return _page(
      context,
      l10n.t('investment'),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _stat(l10n.t('moneyIn'), Fixed.rs(moneyIn, symbol), const Color(0xFF15803D)),
              _stat(l10n.t('moneyOut'), Fixed.rs(moneyOut, symbol), const Color(0xFFB91C1C)),
              _stat(l10n.t('profitPending'), Fixed.rs(0, symbol), const Color(0xFF0F766E)),
              _stat(l10n.t('owner'), '${partnerRows.length}', const Color(0xFF1E293B)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(label: Text(l10n.t('history')), selected: _tab == 'history', onSelected: (_) => setState(() => _tab = 'history')),
              ChoiceChip(label: Text(l10n.t('partnerShares')), selected: _tab == 'shares', onSelected: (_) => setState(() => _tab = 'shares')),
              ChoiceChip(label: Text('Profit sharing history'), selected: _tab == 'profit', onSelected: (_) => setState(() => _tab = 'profit')),
            ],
          ),
          const SizedBox(height: 16),
          if (_tab == 'history')
            _table(
              context,
              [l10n.t('date'), 'Voucher', l10n.t('type'), l10n.t('owner'), l10n.t('note'), l10n.t('amount')],
              entryRows.map((row) {
                final partner = partnerRows.where((item) => item['client_uuid'] == row['partner_client_uuid']).map((item) => item['name']?.toString() ?? '').firstOrNull ?? row['partner_name']?.toString() ?? '';
                return [
                  _showDate(row['occurred_on']),
                  row['client_uuid']?.toString().substring(0, 8) ?? '',
                  row['kind'] == 'out' ? l10n.t('takeOut') : l10n.t('putIn'),
                  partner,
                  row['note']?.toString() ?? '',
                  Fixed.rs(row['amount'], symbol),
                ];
              }).toList(),
              entryRows.isEmpty ? 'No investment recorded yet' : null,
            )
          else if (_tab == 'shares')
            _table(
              context,
              [l10n.t('owner'), l10n.t('moneyIn'), 'Profit received', 'Can take out now', 'Profit %', 'Loss %'],
              partnerRows.map((row) {
                final uuid = row['client_uuid']?.toString();
                var held = 0.0;
                for (final entry in entryRows.where((item) => item['partner_client_uuid'] == uuid)) {
                  final amount = Fixed.n(entry['amount']);
                  held += entry['kind'] == 'out' ? -amount : amount;
                }
                return [
                  row['name']?.toString() ?? '',
                  Fixed.rs(held, symbol),
                  Fixed.rs(0, symbol),
                  Fixed.rs(held < 0 ? 0 : held, symbol),
                  '${row['profit_share'] ?? 0}',
                  row['shares_loss'] == false ? '0' : '${row['loss_share'] ?? 0}',
                ];
              }).toList(),
              partnerRows.isEmpty ? l10n.t('noRecords') : null,
            )
          else
            _table(context, [l10n.t('date'), l10n.t('owner'), l10n.t('amount')], const [], 'No profit has been shared yet'),
        ],
      ),
      action: Wrap(
        spacing: 8,
        children: [
          OutlinedButton.icon(onPressed: () => _partnerDialog(context, ref), icon: const Icon(Icons.person_add_alt), label: Text(l10n.t('addPartner'))),
          FilledButton.icon(onPressed: partnerRows.isEmpty ? null : () => _paymentDialog(context, ref, partnerRows), icon: const Icon(Icons.add), label: Text(l10n.t('addPayment'))),
        ],
      ),
    );
  }

  Future<void> _partnerDialog(BuildContext context, WidgetRef ref) async {
    final l10n = ref.read(l10nProvider);
    final name = TextEditingController();
    final phone = TextEditingController();
    final cnic = TextEditingController();
    final joined = TextEditingController();
    final address = TextEditingController();
    final profit = TextEditingController(text: '0');
    final loss = TextEditingController(text: '0');
    final note = TextEditingController();
    var sharesLoss = true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setLocal) => _moneyDialog(
          dialogContext,
          title: l10n.t('addPartner'),
          icon: Icons.person,
          saveLabel: l10n.t('save'),
          cancelLabel: l10n.t('cancel'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PARTNER DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
              const SizedBox(height: 12),
              fieldGrid([
                labeledField(l10n.t('itemName'), name),
                labeledField(l10n.t('phone'), phone, hint: '03xx-xxxxxxx'),
                labeledField('ID card / CNIC', cnic),
                labeledField('Joined on', joined, hint: 'dd/mm/yyyy'),
                labeledField('Address', address),
              ]),
              const SizedBox(height: 8),
              const Text('PARTNER SHARES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
              const SizedBox(height: 12),
              fieldGrid([
                labeledField('Profit share %', profit, keyboard: TextInputType.number),
                labeledField('Loss share %', loss, keyboard: TextInputType.number),
              ]),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: sharesLoss,
                activeColor: _teal,
                title: const Text('Also shares the loss'),
                onChanged: (value) => setLocal(() => sharesLoss = value ?? true),
              ),
              labeledField(l10n.t('note'), note),
            ],
          ),
        ),
      ),
    );
    if (ok == true && name.text.trim().isNotEmpty) {
      await ref.read(storeProvider).saveMoney('investment_partner', {
        'name': name.text.trim(),
        'phone': phone.text.trim(),
        'cnic': cnic.text.trim(),
        'joined_on': _isoDate(joined.text),
        'address': address.text.trim(),
        'profit_share': profit.text.trim().isEmpty ? '0' : profit.text.trim(),
        'loss_share': loss.text.trim().isEmpty ? '0' : loss.text.trim(),
        'shares_loss': sharesLoss,
        'is_owner': false,
        'note': note.text.trim(),
      });
    }
    name.dispose();
    phone.dispose();
    cnic.dispose();
    joined.dispose();
    address.dispose();
    profit.dispose();
    loss.dispose();
    note.dispose();
  }

  Future<void> _paymentDialog(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> partners) async {
    final l10n = ref.read(l10nProvider);
    var kind = 'in';
    var method = 'cash';
    var partner = partners.first['client_uuid']?.toString();
    final amount = TextEditingController(text: '0');
    final date = TextEditingController(text: _showDate(DateTime.now().toIso8601String()));
    final note = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setLocal) => _moneyDialog(
          dialogContext,
          title: l10n.t('addPayment'),
          icon: Icons.account_balance,
          saveLabel: l10n.t('save'),
          cancelLabel: l10n.t('cancel'),
          child: fieldGrid([
            labeledSelect<String>(
              label: l10n.t('type'),
              value: kind,
              items: [
                DropdownMenuItem(value: 'in', child: Text(l10n.t('putIn'))),
                DropdownMenuItem(value: 'out', child: Text(l10n.t('takeOut'))),
              ],
              onChanged: (value) => setLocal(() => kind = value ?? 'in'),
            ),
            labeledField(l10n.t('amount'), amount, keyboard: TextInputType.number, prefix: ref.read(moneySymbolProvider)),
            labeledSelect<String?>(
              label: l10n.t('owner'),
              value: partner,
              items: partners.map((row) => DropdownMenuItem(value: row['client_uuid']?.toString(), child: Text(row['name']?.toString() ?? ''))).toList(),
              onChanged: (value) => setLocal(() => partner = value),
            ),
            labeledSelect<String>(
              label: 'Payment method',
              value: method,
              items: [
                DropdownMenuItem(value: 'cash', child: Text(l10n.t('cash'))),
                DropdownMenuItem(value: 'bank', child: Text(l10n.t('bank'))),
              ],
              onChanged: (value) => setLocal(() => method = value ?? 'cash'),
            ),
            labeledField(l10n.t('date'), date, hint: 'dd/mm/yyyy'),
            labeledField(l10n.t('note'), note),
          ]),
        ),
      ),
    );
    if (ok == true && partner != null) {
      await ref.read(storeProvider).saveMoney('investment_entry', {
        'partner_client_uuid': partner,
        'kind': kind,
        'method': method,
        'amount': amount.text.trim(),
        'occurred_on': _isoDate(date.text) ?? DateTime.now().toIso8601String().substring(0, 10),
        'note': note.text.trim(),
      });
    }
    amount.dispose();
    date.dispose();
    note.dispose();
  }
}

Widget _moneyDialog(
  BuildContext context, {
  required String title,
  required IconData icon,
  required String saveLabel,
  required String cancelLabel,
  required Widget child,
}) {
  final size = MediaQuery.sizeOf(context);
  return Dialog(
    insetPadding: const EdgeInsets.all(16),
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 720, maxHeight: size.height - 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: const BoxDecoration(color: _teal, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
            padding: const EdgeInsets.fromLTRB(18, 12, 8, 12),
            child: Row(
              children: [
                IconButton(tooltip: 'Back', onPressed: () => Navigator.pop(context, false), icon: const Icon(Icons.arrow_back, color: Colors.white)),
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700))),
                IconButton(onPressed: () => Navigator.pop(context, false), icon: const Icon(Icons.close, color: Colors.white)),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: child),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context, false), child: Text(cancelLabel))),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(saveLabel))),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class RoznamchaPage extends ConsumerWidget {
  const RoznamchaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    final rows = (ref.watch(_docJournals).value ?? <DocumentRow>[]).map(_payload).toList();
    return _page(
      context,
      l10n.t('roznamcha'),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _moneySwitch(context, l10n, '/roznamcha'),
          const SizedBox(height: 16),
          Text(l10n.t('journal'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _table(
            context,
            [l10n.t('invoice'), l10n.t('date'), l10n.t('narration'), l10n.t('debit'), l10n.t('credit')],
            rows
                .map((row) => [
                      row['invoice_no']?.toString() ?? '',
                      _showDate(row['occurred_on']),
                      row['narration']?.toString() ?? '',
                      Fixed.rs(row['debit'], symbol),
                      Fixed.rs(row['credit'], symbol),
                    ])
                .toList(),
            rows.isEmpty ? l10n.t('noRecords') : null,
          ),
        ],
      ),
      action: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton(onPressed: () => context.go('/roznamcha/day-close'), child: Text(l10n.t('dayClose'))),
          OutlinedButton(onPressed: () => context.go('/roznamcha/daily-book'), child: Text(l10n.t('dailyBook'))),
          FilledButton.icon(onPressed: () => context.go('/roznamcha/new'), icon: const Icon(Icons.add), label: Text(l10n.t('add'))),
        ],
      ),
    );
  }
}

class JournalFormPage extends ConsumerStatefulWidget {
  const JournalFormPage({super.key});

  @override
  ConsumerState<JournalFormPage> createState() => _JournalFormPageState();
}

class _JournalFormPageState extends ConsumerState<JournalFormPage> {
  final _invoice = TextEditingController();
  final _date = TextEditingController(text: _showDate(DateTime.now().toIso8601String()));
  final _narration = TextEditingController();
  final _category = TextEditingController();
  final _bank = TextEditingController();
  final _debit = TextEditingController(text: '0');
  final _credit = TextEditingController(text: '0');
  String _method = 'cash';
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _invoice.dispose();
    _date.dispose();
    _narration.dispose();
    _category.dispose();
    _bank.dispose();
    _debit.dispose();
    _credit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    return _page(
      context,
      l10n.t('add'),
      back: '/roznamcha',
      Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              fieldGrid([
                labeledField(l10n.t('invoice'), _invoice),
                labeledField(l10n.t('date'), _date, hint: 'dd/mm/yyyy'),
                labeledField(l10n.t('narration'), _narration),
                labeledField(l10n.t('category'), _category),
                labeledSelect<String>(
                  label: l10n.t('cash'),
                  value: _method,
                  items: [
                    DropdownMenuItem(value: 'cash', child: Text(l10n.t('cash'))),
                    DropdownMenuItem(value: 'bank', child: Text(l10n.t('bank'))),
                  ],
                  onChanged: (value) => setState(() => _method = value ?? 'cash'),
                ),
                if (_method == 'bank') labeledField(l10n.t('bank'), _bank),
                labeledField(l10n.t('debit'), _debit, keyboard: TextInputType.number, prefix: symbol),
                labeledField(l10n.t('credit'), _credit, keyboard: TextInputType.number, prefix: symbol),
              ]),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C))),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(onPressed: () => context.go('/roznamcha'), child: Text(l10n.t('cancel'))),
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
    final l10n = ref.read(l10nProvider);
    final debit = double.tryParse(_debit.text.trim()) ?? 0;
    final credit = double.tryParse(_credit.text.trim()) ?? 0;
    if (_narration.text.trim().isEmpty || (debit <= 0 && credit <= 0)) {
      setState(() => _error = l10n.t('narration'));
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(storeProvider).saveMoney('journal_entry', {
        'invoice_no': _invoice.text.trim(),
        'occurred_on': _isoDate(_date.text) ?? DateTime.now().toIso8601String().substring(0, 10),
        'narration': _narration.text.trim(),
        'category': _category.text.trim(),
        'method': _method,
        'bank_name': _bank.text.trim(),
        'debit': debit,
        'credit': credit,
      });
      if (mounted) context.go('/roznamcha');
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class DailyBookPage extends ConsumerStatefulWidget {
  const DailyBookPage({super.key});

  @override
  ConsumerState<DailyBookPage> createState() => _DailyBookPageState();
}

class _DailyBookPageState extends ConsumerState<DailyBookPage> {
  final _date = TextEditingController(text: _showDate(DateTime.now().toIso8601String()));

  @override
  void dispose() {
    _date.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    final journals = (ref.watch(_docJournals).value ?? <DocumentRow>[]).map(_payload).toList();
    final closes = (ref.watch(_docCloses).value ?? <DocumentRow>[]).map(_payload).toList();
    final day = _isoDate(_date.text) ?? DateTime.now().toIso8601String().substring(0, 10);
    final today = journals.where((row) => row['occurred_on']?.toString() == day).toList();
    var opening = 0.0;
    for (final close in closes) {
      final closed = close['closed_on']?.toString() ?? '';
      if (closed.compareTo(day) < 0) {
        final counted = Fixed.n(close['counted_cash']);
        if (counted >= opening || opening == 0) opening = counted;
      }
    }
    var moneyIn = 0.0;
    var moneyOut = 0.0;
    final banks = <String, double>{};
    final categories = <String, List<double>>{};
    for (final row in today) {
      final debit = Fixed.n(row['debit']);
      final credit = Fixed.n(row['credit']);
      moneyIn += debit;
      moneyOut += credit;
      if (row['method'] == 'bank') {
        final name = (row['bank_name']?.toString().trim().isNotEmpty ?? false) ? row['bank_name'].toString() : l10n.t('bank');
        banks[name] = (banks[name] ?? 0) + debit - credit;
      }
      final category = (row['category']?.toString().trim().isNotEmpty ?? false) ? row['category'].toString() : l10n.t('cash');
      categories.putIfAbsent(category, () => [0, 0]);
      categories[category]![0] += debit;
      categories[category]![1] += credit;
    }
    final closing = opening + moneyIn - moneyOut;
    return _page(
      context,
      l10n.t('dailyBook'),
      back: '/roznamcha',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(width: 180, child: labeledField(l10n.t('date'), _date, hint: 'dd/mm/yyyy')),
              FilledButton(onPressed: () => setState(() {}), child: Text(l10n.t('run'))),
              OutlinedButton(onPressed: () => _csv(today, opening, moneyIn, moneyOut, closing), child: Text(l10n.t('exportCsv'))),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _stat(l10n.t('openingCash'), Fixed.rs(opening, symbol), const Color(0xFF1E293B)),
              _stat('Money in', Fixed.rs(moneyIn, symbol), const Color(0xFF15803D)),
              _stat('Money out', Fixed.rs(moneyOut, symbol), const Color(0xFFB91C1C)),
              _stat('Closing cash & bank', Fixed.rs(closing, symbol), const Color(0xFF1D4ED8)),
            ],
          ),
          const SizedBox(height: 16),
          Text(l10n.t('bank'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _table(
            context,
            [l10n.t('bank'), l10n.t('balance')],
            banks.entries.map((row) => [row.key, Fixed.rs(row.value, symbol)]).toList(),
            banks.isEmpty ? l10n.t('noRecords') : null,
          ),
          const SizedBox(height: 16),
          Text('Money in / out', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _table(
            context,
            [l10n.t('category'), 'Money in', 'Money out'],
            categories.entries.map((row) => [row.key, Fixed.rs(row.value[0], symbol), Fixed.rs(row.value[1], symbol)]).toList(),
            categories.isEmpty ? l10n.t('noRecords') : null,
          ),
          const SizedBox(height: 8),
          Text('Net cash flow    ${Fixed.rs(moneyIn, symbol)} in    ${Fixed.rs(moneyOut, symbol)} out'),
          const SizedBox(height: 16),
          Text("Today's vouchers", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _table(
            context,
            [l10n.t('invoice'), l10n.t('narration'), 'Money in', 'Money out'],
            today.map((row) => [row['invoice_no']?.toString() ?? '', row['narration']?.toString() ?? '', Fixed.rs(row['debit'], symbol), Fixed.rs(row['credit'], symbol)]).toList(),
            today.isEmpty ? l10n.t('noRecords') : null,
          ),
        ],
      ),
    );
  }

  Future<void> _csv(List<Map<String, dynamic>> today, double opening, double moneyIn, double moneyOut, double closing) async {
    final buffer = StringBuffer('Invoice,Narration,Money in,Money out\n');
    buffer.writeln('Opening,,,${opening.toStringAsFixed(2)}');
    for (final row in today) {
      buffer.writeln('${row['invoice_no'] ?? ''},"${row['narration'] ?? ''}",${row['debit'] ?? 0},${row['credit'] ?? 0}');
    }
    buffer.writeln('Closing,${moneyIn.toStringAsFixed(2)},${moneyOut.toStringAsFixed(2)},${closing.toStringAsFixed(2)}');
    final path = await saveBytes(utf8.encode(buffer.toString()), 'daily-book.csv', 'text/csv');
    if (mounted) _toast(context, path);
  }
}

class DayClosePage extends ConsumerStatefulWidget {
  const DayClosePage({super.key});

  @override
  ConsumerState<DayClosePage> createState() => _DayClosePageState();
}

class _DayClosePageState extends ConsumerState<DayClosePage> {
  final _date = TextEditingController(text: _showDate(DateTime.now().toIso8601String()));
  final _opening = TextEditingController(text: '0');
  final _counted = TextEditingController(text: '0');
  final _note = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _date.dispose();
    _opening.dispose();
    _counted.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    final journals = (ref.watch(_docJournals).value ?? <DocumentRow>[]).map(_payload).toList();
    final day = _isoDate(_date.text) ?? DateTime.now().toIso8601String().substring(0, 10);
    var movement = 0.0;
    for (final row in journals.where((row) => row['occurred_on']?.toString() == day && row['method'] != 'bank')) {
      movement += Fixed.n(row['debit']) - Fixed.n(row['credit']);
    }
    final opening = double.tryParse(_opening.text.trim()) ?? 0;
    final expected = opening + movement;
    return _page(
      context,
      l10n.t('dayClose'),
      back: '/roznamcha',
      Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Drawer reconciliation', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              fieldGrid([
                labeledField(l10n.t('date'), _date, hint: 'dd/mm/yyyy'),
                labeledField(l10n.t('openingCash'), _opening, keyboard: TextInputType.number, prefix: symbol),
              ]),
              const Text("TODAY'S ACTIVITY", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
              const SizedBox(height: 8),
              _line(l10n.t('openingCash'), Fixed.rs(opening, symbol)),
              _line('Drawer movement today', Fixed.rs(movement, symbol)),
              _line('Expected in drawer', Fixed.rs(expected, symbol)),
              const SizedBox(height: 12),
              labeledField(l10n.t('countedCash'), _counted, keyboard: TextInputType.number, prefix: symbol),
              const SizedBox(height: 12),
              labeledField(l10n.t('note'), _note),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C))),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(onPressed: () => context.go('/roznamcha'), child: Text(l10n.t('cancel'))),
                  const SizedBox(width: 12),
                  FilledButton(onPressed: _busy ? null : () => _save(expected), child: Text(l10n.t('closeDay'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Future<void> _save(double expected) async {
    setState(() => _busy = true);
    try {
      await ref.read(storeProvider).saveMoney('day_close', {
        'closed_on': _isoDate(_date.text) ?? DateTime.now().toIso8601String().substring(0, 10),
        'opening_cash': _opening.text.trim().isEmpty ? '0' : _opening.text.trim(),
        'counted_cash': _counted.text.trim().isEmpty ? '0' : _counted.text.trim(),
        'expected_cash': expected,
        'note': _note.text.trim(),
      });
      if (mounted) context.go('/roznamcha');
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
