part of 'pages.dart';

final _docSales = StreamProvider<List<DocumentRow>>((ref) => ref.watch(storeProvider).watchDocuments('sale'));
final _docExpenses = StreamProvider<List<DocumentRow>>((ref) => ref.watch(storeProvider).watchDocuments('expense'));
final _docEmployees = StreamProvider<List<DocumentRow>>((ref) => ref.watch(storeProvider).watchDocuments('employee'));
final _docAttendance = StreamProvider<List<DocumentRow>>((ref) => ref.watch(storeProvider).watchDocuments('attendance'));
final _docSalaries = StreamProvider<List<DocumentRow>>((ref) => ref.watch(storeProvider).watchDocuments('salary_payment'));

String _isoDay([DateTime? day]) {
  final value = day ?? DateTime.now();
  return '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}

DateTime? _parseDay(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return null;
  final iso = DateTime.tryParse(text);
  if (iso != null) return DateTime(iso.year, iso.month, iso.day);
  final parts = text.split('/');
  if (parts.length != 3) return null;
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;
  return DateTime(year, month, day);
}

String? _currentBranch(WidgetRef ref) {
  final selected = ref.watch(branchProvider);
  if (selected != null && selected.isNotEmpty) return selected;
  final branches = ref.watch(_branches).value ?? <BranchRow>[];
  return branches.isEmpty ? null : branches.first.clientUuid;
}

Widget _hrSwitch(BuildContext context, L10n l10n, String current) {
  const items = [('employees', '/hr/employees'), ('attendance', '/hr/attendance'), ('salaries', '/hr/salaries')];
  return Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final item in items)
        ChoiceChip(
          label: Text(l10n.t(item.$1), style: TextStyle(color: current == item.$2 ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.w600)),
          selected: current == item.$2,
          selectedColor: const Color(0xFF0F766E),
          backgroundColor: Colors.white,
          onSelected: (_) => context.go(item.$2),
        ),
    ],
  );
}

class SalesPage extends ConsumerWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    final rows = (ref.watch(_docSales).value ?? <DocumentRow>[]).map(_payload).toList();
    return _page(
      context,
      l10n.t('sales'),
      _table(
        context,
        [l10n.t('invoice'), l10n.t('date'), l10n.t('customerName'), l10n.t('method'), l10n.t('amount')],
        rows.map((row) => [
          row['invoice_no']?.toString() ?? '',
          (row['occurred_on'] ?? row['occurred_at'] ?? '').toString().split('T').first,
          (row['party_name']?.toString().isNotEmpty ?? false) ? row['party_name'].toString() : l10n.t('walkIn'),
          row['payment_method']?.toString() ?? '',
          Fixed.rs(row['total'], symbol),
        ]).toList(),
        rows.isEmpty ? l10n.t('noRecords') : null,
      ),
      action: FilledButton(onPressed: () => context.go('/sales/new'), child: Text(l10n.t('newSale'))),
    );
  }
}

class ExpensesPage extends ConsumerStatefulWidget {
  const ExpensesPage({super.key});

  @override
  ConsumerState<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends ConsumerState<ExpensesPage> {
  final _from = TextEditingController();
  final _to = TextEditingController();
  final _search = TextEditingController();
  String _period = 'all';
  String? _account;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(storeProvider).ensureChart());
  }

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    _search.dispose();
    super.dispose();
  }

  bool _inPeriod(String raw) {
    final day = _parseDay(raw) ?? DateTime.tryParse(raw);
    if (day == null) return _period == 'all';
    final today = DateTime.now();
    final date = DateTime(day.year, day.month, day.day);
    final startToday = DateTime(today.year, today.month, today.day);
    return switch (_period) {
      'today' => date == startToday,
      'yesterday' => date == startToday.subtract(const Duration(days: 1)),
      'last7' => !date.isBefore(startToday.subtract(const Duration(days: 6))) && !date.isAfter(startToday),
      'month' => date.year == today.year && date.month == today.month,
      _ => true,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    final accounts = (ref.watch(_docAccounts).value ?? <DocumentRow>[]).map(_payload).where((row) => row['type'] == 'expense').toList();
    final query = _search.text.trim().toLowerCase();
    final from = _parseDay(_from.text);
    final to = _parseDay(_to.text);
    final rows = (ref.watch(_docExpenses).value ?? <DocumentRow>[]).map(_payload).where((row) {
      final day = _parseDay(row['occurred_on']?.toString() ?? '') ?? DateTime.tryParse(row['occurred_on']?.toString() ?? '');
      if (from != null && day != null && day.isBefore(from)) return false;
      if (to != null && day != null && day.isAfter(DateTime(to.year, to.month, to.day, 23, 59))) return false;
      if (!_inPeriod(row['occurred_on']?.toString() ?? '')) return false;
      if (_account != null && row['account_client_uuid'] != _account) return false;
      if (query.isEmpty) return true;
      final haystack = '${row['invoice_no'] ?? ''} ${row['narration'] ?? ''} ${row['account_name'] ?? ''}'.toLowerCase();
      return haystack.contains(query);
    }).toList();
    final total = rows.fold<double>(0, (sum, row) => sum + Fixed.n(row['amount']));
    return _page(
      context,
      l10n.t('expenses'),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in [('all', 'allTime'), ('today', 'today'), ('yesterday', 'yesterday'), ('last7', 'last7'), ('month', 'thisMonth')])
                ChoiceChip(
                  label: Text(l10n.t(item.$2), style: TextStyle(color: _period == item.$1 ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.w600)),
                  selected: _period == item.$1,
                  selectedColor: const Color(0xFFEA580C),
                  backgroundColor: Colors.white,
                  onSelected: (_) => setState(() => _period = item.$1),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(width: 160, child: labeledField(l10n.t('from'), _from, hint: 'dd/mm/yyyy', onChanged: (_) => setState(() {}))),
              SizedBox(width: 160, child: labeledField(l10n.t('to'), _to, hint: 'dd/mm/yyyy', onChanged: (_) => setState(() {}))),
              SizedBox(
                width: 220,
                child: labeledSelect<String>(
                  label: l10n.t('expenseAccount'),
                  value: _account,
                  items: [
                    DropdownMenuItem(value: null, child: Text(l10n.t('allTime'))),
                    for (final account in accounts) DropdownMenuItem(value: account['client_uuid']?.toString(), child: Text(account['name_en']?.toString() ?? '')),
                  ],
                  onChanged: (value) => setState(() => _account = value),
                ),
              ),
              SizedBox(width: 220, child: labeledField(l10n.t('search'), _search, onChanged: (_) => setState(() {}))),
              OutlinedButton(
                onPressed: () async {
                  final buffer = StringBuffer('Date,Invoice,Account,Narration,Amount\n');
                  for (final row in rows) {
                    buffer.writeln('${row['occurred_on'] ?? ''},${row['invoice_no'] ?? ''},${row['account_name'] ?? ''},${row['narration'] ?? ''},${row['amount'] ?? ''}');
                  }
                  await saveBytes(utf8.encode(buffer.toString()), 'expenses.csv', 'text/csv');
                },
                child: Text(l10n.t('exportCsv')),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(child: Text('${l10n.t('totalExpenses')}: ${Fixed.rs(total, symbol)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18))),
                  Text('${rows.length}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _table(
            context,
            [l10n.t('invoice'), l10n.t('date'), l10n.t('expenseAccount'), l10n.t('narration'), l10n.t('amount')],
            rows.map((row) => [
              row['invoice_no']?.toString() ?? '',
              row['occurred_on']?.toString() ?? '',
              row['account_name']?.toString() ?? '',
              row['narration']?.toString() ?? '',
              Fixed.rs(row['amount'], symbol),
            ]).toList(),
            rows.isEmpty ? l10n.t('noRecords') : null,
          ),
        ],
      ),
      action: FilledButton(onPressed: () => context.go('/expenses/new'), child: Text(l10n.t('addExpense'))),
    );
  }
}

class ExpenseFormPage extends ConsumerStatefulWidget {
  const ExpenseFormPage({super.key});

  @override
  ConsumerState<ExpenseFormPage> createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends ConsumerState<ExpenseFormPage> {
  final _invoice = TextEditingController();
  final _date = TextEditingController(text: _isoDay());
  final _narration = TextEditingController();
  final _amount = TextEditingController();
  String? _account;
  String _method = 'cash';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(storeProvider).ensureChart());
  }

  @override
  void dispose() {
    _invoice.dispose();
    _date.dispose();
    _narration.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final accounts = (ref.read(_docAccounts).value ?? <DocumentRow>[]).map(_payload).toList();
    final account = accounts.cast<Map<String, dynamic>?>().firstWhere((row) => row?['client_uuid'] == _account, orElse: () => null);
    if (account == null || Fixed.n(_amount.text) <= 0) return;
    setState(() => _busy = true);
    await ref.read(storeProvider).saveMoney('expense', {
      'occurred_on': _parseDay(_date.text) == null ? _isoDay() : _isoDay(_parseDay(_date.text)),
      'invoice_no': _invoice.text.trim(),
      'account_client_uuid': account['client_uuid'],
      'account_name': account['name_en'],
      'narration': _narration.text.trim(),
      'amount': Fixed.n(_amount.text),
      'method': _method,
    });
    if (!mounted) return;
    context.go('/expenses');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    final accounts = (ref.watch(_docAccounts).value ?? <DocumentRow>[]).map(_payload).where((row) => row['type'] == 'expense').toList();
    return _page(
      context,
      l10n.t('addExpense'),
      Card(
        margin: EdgeInsets.zero,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              fieldGrid([
                labeledField(l10n.t('invoice'), _invoice),
                labeledField(l10n.t('date'), _date, hint: 'dd/mm/yyyy'),
                labeledSelect<String>(
                  label: l10n.t('expenseAccount'),
                  value: _account,
                  items: [
                    for (final account in accounts) DropdownMenuItem(value: account['client_uuid']?.toString(), child: Text('${account['code'] ?? ''} ${account['name_en'] ?? ''}')),
                  ],
                  onChanged: (value) => setState(() => _account = value),
                ),
                labeledField(l10n.t('amount'), _amount, keyboard: TextInputType.number, prefix: symbol),
                labeledField(l10n.t('narration'), _narration),
              ]),
              Wrap(
                spacing: 8,
                children: [
                  for (final method in ['cash', 'bank'])
                    ChoiceChip(
                      label: Text(l10n.t(method), style: TextStyle(color: _method == method ? Colors.white : const Color(0xFF1E293B))),
                      selected: _method == method,
                      selectedColor: const Color(0xFF0F766E),
                      onSelected: (_) => setState(() => _method = method),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.t('save'))),
              ),
            ],
          ),
        ),
      ),
      back: '/expenses',
    );
  }
}

class EmployeesPage extends ConsumerWidget {
  const EmployeesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    final rows = (ref.watch(_docEmployees).value ?? <DocumentRow>[]).map(_payload).toList();
    return _page(
      context,
      l10n.t('employees'),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _hrSwitch(context, l10n, '/hr/employees'),
          const SizedBox(height: 12),
          _table(
            context,
            [l10n.t('itemName'), l10n.t('phone'), l10n.t('designation'), l10n.t('monthlySalary'), l10n.t('status')],
            rows.map((row) => [
              _bilingual(row['name']?.toString() ?? '', row['name_ur']?.toString() ?? ''),
              row['phone']?.toString() ?? '',
              row['designation']?.toString() ?? '',
              Fixed.rs(row['monthly_salary'], symbol),
              row['status']?.toString() ?? '',
            ]).toList(),
            rows.isEmpty ? l10n.t('noEmployees') : null,
            onEdit: (index) => context.go('/hr/employees/edit/${rows[index]['client_uuid']}'),
          ),
        ],
      ),
      action: FilledButton(onPressed: () => context.go('/hr/employees/new'), child: Text(l10n.t('addEmployee'))),
    );
  }
}

class EmployeeFormPage extends ConsumerStatefulWidget {
  const EmployeeFormPage({super.key, this.clientUuid});

  final String? clientUuid;

  @override
  ConsumerState<EmployeeFormPage> createState() => _EmployeeFormPageState();
}

class _EmployeeFormPageState extends ConsumerState<EmployeeFormPage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _cnic = TextEditingController();
  final _designation = TextEditingController();
  final _salary = TextEditingController(text: '0');
  final _joined = TextEditingController();
  final _rate = TextEditingController();
  final _notes = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String _type = 'full_time';
  String _commission = 'none';
  String _status = 'active';
  bool _login = false;
  bool _loaded = false;
  bool _busy = false;

  @override
  void dispose() {
    for (final controller in [_name, _phone, _cnic, _designation, _salary, _joined, _rate, _notes, _email, _password]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _fill(Map<String, dynamic> row) {
    if (_loaded) return;
    _loaded = true;
    final name = row['name']?.toString() ?? '';
    _name.text = name.trim().isNotEmpty ? name : (row['name_ur']?.toString() ?? '');
    _phone.text = row['phone']?.toString() ?? '';
    _cnic.text = row['cnic']?.toString() ?? '';
    _designation.text = row['designation']?.toString() ?? '';
    _salary.text = row['monthly_salary']?.toString() ?? '0';
    _joined.text = row['joined_on']?.toString() ?? '';
    _rate.text = row['commission_rate']?.toString() ?? '';
    _notes.text = row['notes']?.toString() ?? '';
    _email.text = row['email']?.toString() ?? '';
    _type = row['employment_type']?.toString() ?? 'full_time';
    _commission = row['commission_on']?.toString() ?? 'none';
    _status = row['status']?.toString() ?? 'active';
    _login = row['allow_login'] == true;
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    setState(() => _busy = true);
    final joined = _parseDay(_joined.text);
    await ref.read(storeProvider).saveMoney('employee', {
      if (widget.clientUuid != null) 'client_uuid': widget.clientUuid,
      'name': _name.text.trim(),
      'name_ur': _name.text.trim(),
      'phone': _phone.text.trim(),
      'cnic': _cnic.text.trim(),
      'designation': _designation.text.trim(),
      'employment_type': _type,
      'monthly_salary': Fixed.n(_salary.text),
      'joined_on': joined == null ? '' : _isoDay(joined),
      'commission_rate': Fixed.n(_rate.text),
      'commission_on': _commission,
      'status': _status,
      'notes': _notes.text.trim(),
      'allow_login': _login,
      'email': _email.text.trim(),
    });
    if (_login && _email.text.trim().isNotEmpty && _password.text.isNotEmpty) {
      try {
        await ref.read(storeProvider).saveUser(_name.text.trim(), _email.text.trim(), _password.text, 'cashier');
      } catch (_) {
        if (mounted) _toast(context, ref.read(l10nProvider).t('allowLogin'));
      }
    }
    if (!mounted) return;
    context.go('/hr/employees');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    if (widget.clientUuid != null) {
      final existing = (ref.watch(_docEmployees).value ?? <DocumentRow>[]).map(_payload).cast<Map<String, dynamic>?>().firstWhere((row) => row?['client_uuid'] == widget.clientUuid, orElse: () => null);
      if (existing != null) _fill(existing);
    }
    return _page(
      context,
      l10n.t('addEmployee'),
      Card(
        margin: EdgeInsets.zero,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              fieldGrid([
                labeledField(l10n.t('itemName'), _name),
                labeledField(l10n.t('phone'), _phone),
                labeledField('CNIC', _cnic),
                labeledField(l10n.t('designation'), _designation),
                labeledSelect<String>(
                  label: l10n.t('employmentType'),
                  value: _type,
                  items: [
                    DropdownMenuItem(value: 'full_time', child: Text(l10n.t('fullTime'))),
                    DropdownMenuItem(value: 'part_time', child: Text(l10n.t('partTime'))),
                  ],
                  onChanged: (value) => setState(() => _type = value ?? 'full_time'),
                ),
                labeledField(l10n.t('monthlySalary'), _salary, keyboard: TextInputType.number, prefix: symbol),
                labeledField(l10n.t('joinedOn'), _joined, hint: 'dd/mm/yyyy'),
                labeledField(l10n.t('commissionRate'), _rate, keyboard: TextInputType.number),
                labeledSelect<String>(
                  label: l10n.t('commissionOn'),
                  value: _commission,
                  items: [
                    DropdownMenuItem(value: 'none', child: Text(l10n.t('noCommission'))),
                    DropdownMenuItem(value: 'sales', child: Text(l10n.t('sales'))),
                    DropdownMenuItem(value: 'profit', child: Text(l10n.t('reports'))),
                  ],
                  onChanged: (value) => setState(() => _commission = value ?? 'none'),
                ),
                labeledSelect<String>(
                  label: l10n.t('status'),
                  value: _status,
                  items: [
                    DropdownMenuItem(value: 'active', child: Text(l10n.t('active'))),
                    DropdownMenuItem(value: 'inactive', child: Text(l10n.t('inactive'))),
                  ],
                  onChanged: (value) => setState(() => _status = value ?? 'active'),
                ),
                labeledField(l10n.t('notes'), _notes),
              ]),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _login,
                title: Text(l10n.t('allowLogin')),
                onChanged: (value) => setState(() => _login = value ?? false),
              ),
              if (_login)
                fieldGrid([
                  labeledField(l10n.t('email'), _email),
                  labeledField(l10n.t('password'), _password, obscure: true),
                ]),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.t('save'))),
              ),
            ],
          ),
        ),
      ),
      back: '/hr/employees',
    );
  }
}

class AttendancePage extends ConsumerStatefulWidget {
  const AttendancePage({super.key});

  @override
  ConsumerState<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends ConsumerState<AttendancePage> {
  final _date = TextEditingController(text: _isoDay());
  final _status = <String, String>{};
  final _in = <String, TextEditingController>{};
  final _out = <String, TextEditingController>{};
  bool _busy = false;

  @override
  void dispose() {
    _date.dispose();
    for (final controller in [..._in.values, ..._out.values]) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _box(Map<String, TextEditingController> map, String key, String value) {
    return map.putIfAbsent(key, () => TextEditingController(text: value));
  }

  Future<void> _save(List<Map<String, dynamic>> employees, List<Map<String, dynamic>> marks, String day) async {
    setState(() => _busy = true);
    final store = ref.read(storeProvider);
    for (final employee in employees.where((row) => row['status'] != 'inactive')) {
      final uuid = employee['client_uuid'].toString();
      final existing = marks.cast<Map<String, dynamic>?>().firstWhere((row) => row?['employee_client_uuid'] == uuid && row?['work_date'] == day, orElse: () => null);
      await store.saveMoney('attendance', {
        if (existing != null) 'client_uuid': existing['client_uuid'],
        'employee_client_uuid': uuid,
        'work_date': day,
        'status': _status[uuid] ?? existing?['status'] ?? 'present',
        'check_in': _in[uuid]?.text.trim() ?? '',
        'check_out': _out[uuid]?.text.trim() ?? '',
      });
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final day = _parseDay(_date.text) == null ? _isoDay() : _isoDay(_parseDay(_date.text));
    final employees = (ref.watch(_docEmployees).value ?? <DocumentRow>[]).map(_payload).where((row) => row['status'] != 'inactive').toList();
    final marks = (ref.watch(_docAttendance).value ?? <DocumentRow>[]).map(_payload).toList();
    return _page(
      context,
      l10n.t('attendance'),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _hrSwitch(context, l10n, '/hr/attendance'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(width: 180, child: labeledField(l10n.t('date'), _date, hint: 'dd/mm/yyyy')),
              FilledButton(onPressed: () => setState(() {}), child: Text(l10n.t('show'))),
              FilledButton(onPressed: _busy || employees.isEmpty ? null : () => _save(employees, marks, day), child: Text(l10n.t('save'))),
            ],
          ),
          const SizedBox(height: 12),
          if (employees.isEmpty)
            Text(l10n.t('noEmployees'))
          else
            _table(
              context,
              [l10n.t('itemName'), l10n.t('status'), l10n.t('checkIn'), l10n.t('checkOut')],
              [
                for (final employee in employees)
                  () {
                    final uuid = employee['client_uuid'].toString();
                    final mark = marks.cast<Map<String, dynamic>?>().firstWhere((row) => row?['employee_client_uuid'] == uuid && row?['work_date'] == day, orElse: () => null);
                    final status = _status[uuid] ?? mark?['status']?.toString() ?? 'present';
                    return [
                      employee['name']?.toString() ?? '',
                      status,
                      _box(_in, uuid, mark?['check_in']?.toString() ?? '').text,
                      _box(_out, uuid, mark?['check_out']?.toString() ?? '').text,
                    ];
                  }(),
              ],
              null,
            ),
          const SizedBox(height: 12),
          for (final employee in employees)
            () {
              final uuid = employee['client_uuid'].toString();
              final mark = marks.cast<Map<String, dynamic>?>().firstWhere((row) => row?['employee_client_uuid'] == uuid && row?['work_date'] == day, orElse: () => null);
              final status = _status[uuid] ?? mark?['status']?.toString() ?? 'present';
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(width: 180, child: Text(employee['name']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w700))),
                      for (final item in [('present', 'present'), ('absent', 'absent'), ('leave', 'onLeave'), ('half', 'halfDay')])
                        ChoiceChip(
                          label: Text(l10n.t(item.$2), style: TextStyle(color: status == item.$1 ? Colors.white : const Color(0xFF1E293B))),
                          selected: status == item.$1,
                          selectedColor: const Color(0xFF0F766E),
                          onSelected: (_) => setState(() => _status[uuid] = item.$1),
                        ),
                      SizedBox(width: 120, child: labeledField(l10n.t('checkIn'), _box(_in, uuid, mark?['check_in']?.toString() ?? ''))),
                      SizedBox(width: 120, child: labeledField(l10n.t('checkOut'), _box(_out, uuid, mark?['check_out']?.toString() ?? ''))),
                    ],
                  ),
                ),
              );
            }(),
        ],
      ),
      back: '/dashboard',
    );
  }
}

class SalariesPage extends ConsumerStatefulWidget {
  const SalariesPage({super.key});

  @override
  ConsumerState<SalariesPage> createState() => _SalariesPageState();
}

class _SalariesPageState extends ConsumerState<SalariesPage> {
  final _period = TextEditingController(text: _isoDay().substring(0, 7));
  final _amount = TextEditingController();
  final _note = TextEditingController();
  String? _employee;
  String _kind = 'advance';
  String _method = 'cash';
  bool _busy = false;

  @override
  void dispose() {
    _period.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (_employee == null || Fixed.n(_amount.text) <= 0) return;
    setState(() => _busy = true);
    await ref.read(storeProvider).saveMoney('salary_payment', {
      'employee_client_uuid': _employee,
      'period': _period.text.trim(),
      'kind': _kind,
      'amount': Fixed.n(_amount.text),
      'method': _method,
      'paid_on': _isoDay(),
      'note': _note.text.trim(),
    });
    if (!mounted) return;
    _amount.clear();
    _note.clear();
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    final period = _period.text.trim();
    final employees = (ref.watch(_docEmployees).value ?? <DocumentRow>[]).map(_payload).where((row) => row['status'] != 'inactive').toList();
    final payments = (ref.watch(_docSalaries).value ?? <DocumentRow>[]).map(_payload).where((row) => row['period'] == period).toList();
    final salaryPaid = payments.where((row) => row['kind'] == 'salary').fold<double>(0, (sum, row) => sum + Fixed.n(row['amount']));
    final advances = payments.where((row) => row['kind'] != 'salary').toList();
    final advanceTotal = advances.fold<double>(0, (sum, row) => sum + Fixed.n(row['amount']));
    final payroll = employees.fold<double>(0, (sum, row) => sum + Fixed.n(row['monthly_salary']));
    final pending = math.max(0, payroll - salaryPaid).toDouble();
    return _page(
      context,
      l10n.t('salaries'),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _hrSwitch(context, l10n, '/hr/salaries'),
          const SizedBox(height: 12),
          SizedBox(width: 180, child: labeledField(l10n.t('date'), _period, hint: 'yyyy-mm', onChanged: (_) => setState(() {}))),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _stat(l10n.t('employees'), '${employees.length}', const Color(0xFF1F2937)),
              _stat(l10n.t('pendingPay'), Fixed.rs(pending, symbol), const Color(0xFFB45309)),
              _stat(l10n.t('paidWord'), Fixed.rs(salaryPaid, symbol), const Color(0xFF15803D)),
              _stat(l10n.t('amount'), Fixed.rs(payroll, symbol), const Color(0xFF0F766E)),
            ],
          ),
          const SizedBox(height: 12),
          _table(
            context,
            [l10n.t('itemName'), l10n.t('baseSalary'), l10n.t('paidWord'), l10n.t('pendingPay'), l10n.t('netPay')],
            employees.map((row) {
              final paid = payments.where((item) => item['employee_client_uuid'] == row['client_uuid'] && item['kind'] == 'salary').fold<double>(0, (sum, item) => sum + Fixed.n(item['amount']));
              final base = Fixed.n(row['monthly_salary']);
              final due = math.max(0, base - paid).toDouble();
              return [row['name']?.toString() ?? '', Fixed.rs(base, symbol), Fixed.rs(paid, symbol), Fixed.rs(due, symbol), Fixed.rs(due, symbol)];
            }).toList(),
            employees.isEmpty ? l10n.t('noEmployees') : null,
          ),
          const SizedBox(height: 16),
          Text(l10n.t('advances'), style: Theme.of(context).textTheme.titleMedium),
          Text('${l10n.t('amount')}: ${Fixed.rs(advanceTotal, symbol)}', style: const TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.t('giveAdvance'), style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  fieldGrid([
                    labeledSelect<String>(
                      label: l10n.t('employees'),
                      value: _employee,
                      items: [for (final row in employees) DropdownMenuItem(value: row['client_uuid']?.toString(), child: Text(row['name']?.toString() ?? ''))],
                      onChanged: (value) => setState(() => _employee = value),
                    ),
                    labeledField(l10n.t('amount'), _amount, keyboard: TextInputType.number, prefix: symbol),
                    labeledField(l10n.t('note'), _note),
                  ]),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final kind in [('advance', 'giveAdvance'), ('part', 'pendingPay'), ('salary', 'salaries')])
                        ChoiceChip(
                          label: Text(l10n.t(kind.$2), style: TextStyle(color: _kind == kind.$1 ? Colors.white : const Color(0xFF1E293B))),
                          selected: _kind == kind.$1,
                          selectedColor: const Color(0xFFEA580C),
                          onSelected: (_) => setState(() => _kind = kind.$1),
                        ),
                      for (final method in ['cash', 'bank'])
                        ChoiceChip(
                          label: Text(l10n.t(method), style: TextStyle(color: _method == method ? Colors.white : const Color(0xFF1E293B))),
                          selected: _method == method,
                          selectedColor: const Color(0xFF0F766E),
                          onSelected: (_) => setState(() => _method = method),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(alignment: Alignment.centerRight, child: FilledButton(onPressed: _busy ? null : _pay, child: Text(l10n.t('save')))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _table(
            context,
            [l10n.t('date'), l10n.t('itemName'), l10n.t('method'), l10n.t('amount')],
            advances.map((row) {
              final name = employees.cast<Map<String, dynamic>?>().firstWhere((item) => item?['client_uuid'] == row['employee_client_uuid'], orElse: () => null)?['name'] ?? '';
              return [row['paid_on']?.toString() ?? '', name.toString(), row['kind']?.toString() ?? '', Fixed.rs(row['amount'], symbol)];
            }).toList(),
            advances.isEmpty ? l10n.t('noRecords') : null,
          ),
        ],
      ),
      back: '/dashboard',
    );
  }
}

