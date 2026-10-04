part of 'pages.dart';

const _settingsUuid = '10000000-0000-4000-8000-000000009001';

const _currencies = <(String, String, String)>[
  ('PKR', 'Rs', 'Pakistani Rupee (Rs)'),
  ('USD', '\$', 'US Dollar (\$)'),
  ('EUR', '€', 'Euro (€)'),
  ('GBP', '£', 'British Pound (£)'),
  ('AED', 'AED', 'UAE Dirham (AED)'),
  ('SAR', 'SAR', 'Saudi Riyal (SAR)'),
  ('QAR', 'QAR', 'Qatari Riyal (QAR)'),
  ('KWD', 'KD', 'Kuwaiti Dinar (KD)'),
  ('OMR', 'OMR', 'Omani Rial (OMR)'),
  ('INR', '₹', 'Indian Rupee (₹)'),
  ('BDT', '৳', 'Bangladeshi Taka (৳)'),
  ('LKR', 'LKR', 'Sri Lankan Rupee (LKR)'),
  ('CNY', '¥', 'Chinese Yuan (¥)'),
  ('JPY', '¥', 'Japanese Yen (¥)'),
  ('CAD', 'C\$', 'Canadian Dollar (C\$)'),
  ('AUD', 'A\$', 'Australian Dollar (A\$)'),
  ('SGD', 'S\$', 'Singapore Dollar (S\$)'),
  ('MYR', 'RM', 'Malaysian Ringgit (RM)'),
  ('TRY', '₺', 'Turkish Lira (₺)'),
  ('ZAR', 'R', 'South African Rand (R)'),
  ('NGN', '₦', 'Nigerian Naira (₦)'),
  ('EGP', 'E£', 'Egyptian Pound (E£)'),
  ('CHF', 'CHF', 'Swiss Franc (CHF)'),
];

final moneySymbolProvider = Provider<String>((ref) {
  final rows = ref.watch(_docSettings).value;
  if (rows != null && rows.isNotEmpty) {
    final symbol = _payload(rows.first)['currency_symbol']?.toString().trim() ?? '';
    if (symbol.isNotEmpty) return symbol;
  }
  return ref.watch(sessionProvider).value?.symbol ?? 'Rs';
});

final _docSettings = StreamProvider<List<DocumentRow>>((ref) => ref.watch(storeProvider).watchDocuments('shop_settings'));
final _docPayments = StreamProvider<List<DocumentRow>>((ref) => ref.watch(storeProvider).watchDocuments('payment_method'));

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _prefix = TextEditingController(text: 'INV-');
  final _tax = TextEditingController(text: '0');
  final _footer = TextEditingController();
  final _ntn = TextEditingController();
  final _strn = TextEditingController();
  final _posId = TextEditingController();
  final _endpoint = TextEditingController();
  final _token = TextEditingController();
  String _currencyCode = 'PKR';
  String _tab = 'shop';
  String _uuid = _settingsUuid;
  String _timezone = 'Asia/Karachi';
  String _receiptFormat = 'thermal';
  String _paper = '80';
  String _textSize = 'normal';
  String _wholesalePaper = 'a5';
  String _defaultPay = 'cash';
  String _valuation = 'manual';
  String _theme = 'classic';
  String _cartUnit = 'name';
  String _receiptLanguage = 'en';
  bool _loaded = false;
  bool _busy = false;
  bool _hydrateQueued = false;
  final Map<String, bool> _flag = {
    'showBalance': false,
    'ownerEditsKhata': true,
    'soldBy': false,
    'salesChannel': false,
    'belowCost': false,
    'outOfStock': false,
    'deductOnSale': true,
    'sellShort': false,
    'shipping': false,
    'saleNotes': false,
    'showCost': true,
    'godown': true,
    'webcam': false,
    'shortcuts': true,
    'labelShop': true,
    'labelProduct': true,
    'labelSerial': true,
    'labelPrice': true,
    'labelBarcode': true,
    'labelRack': false,
    'labelExpiry': true,
    'labelBatch': true,
    'voice': false,
    'urduReceipt': true,
    'fbr': false,
    'fbrLive': false,
  };

  @override
  void dispose() {
    for (final controller in [_name, _phone, _address, _prefix, _tax, _footer, _ntn, _strn, _posId, _endpoint, _token]) {
      controller.dispose();
    }
    super.dispose();
  }

  String get _symbol => _currencies.firstWhere((row) => row.$1 == _currencyCode, orElse: () => _currencies.first).$2;

  String _matchCurrency(String? code, String? symbol) {
    if (_currencies.any((row) => row.$1 == code)) return code!;
    final bySymbol = _currencies.where((row) => row.$2 == symbol);
    return bySymbol.isEmpty ? 'PKR' : bySymbol.first.$1;
  }

  void _hydrate(Map<String, dynamic>? row, String shopName) {
    if (_loaded) return;
    _loaded = true;
    _uuid = row?['client_uuid']?.toString() ?? _settingsUuid;
    _name.text = row?['shop_name']?.toString() ?? shopName;
    _phone.text = row?['phone']?.toString() ?? '';
    _address.text = row?['address']?.toString() ?? '';
    _currencyCode = _matchCurrency(row?['currency_code']?.toString(), row?['currency_symbol']?.toString());
    _prefix.text = row?['invoice_prefix']?.toString() ?? 'INV-';
    _tax.text = row?['tax_rate']?.toString() ?? '0';
    _footer.text = row?['receipt_footer']?.toString() ?? '';
    _ntn.text = row?['fbr_ntn']?.toString() ?? '';
    _strn.text = row?['fbr_strn']?.toString() ?? '';
    _posId.text = row?['fbr_pos_id']?.toString() ?? '';
    _endpoint.text = row?['fbr_endpoint']?.toString() ?? '';
    _token.text = row?['fbr_token']?.toString() ?? '';
    _timezone = row?['timezone']?.toString() ?? _timezone;
    _receiptFormat = row?['receipt_format']?.toString() ?? _receiptFormat;
    _paper = row?['paper_size']?.toString() ?? _paper;
    _textSize = row?['text_size']?.toString() ?? _textSize;
    _wholesalePaper = row?['wholesale_paper']?.toString() ?? _wholesalePaper;
    _defaultPay = row?['default_payment']?.toString() ?? _defaultPay;
    _valuation = row?['valuation']?.toString() ?? _valuation;
    _theme = row?['pos_theme']?.toString() ?? _theme;
    _cartUnit = row?['cart_unit']?.toString() ?? _cartUnit;
    _receiptLanguage = row?['receipt_language']?.toString() ?? _receiptLanguage;
    final flags = row?['flags'];
    if (flags is Map) {
      for (final key in _flag.keys) {
        if (flags.containsKey(key)) _flag[key] = flags[key] == true;
      }
    }
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    await ref.read(storeProvider).saveMoney('shop_settings', {
      'client_uuid': _uuid,
      'shop_name': _name.text.trim(),
      'phone': _phone.text.trim(),
      'address': _address.text.trim(),
      'currency_code': _currencyCode,
      'currency_symbol': _symbol,
      'invoice_prefix': _prefix.text.trim(),
      'tax_rate': Fixed.n(_tax.text),
      'timezone': _timezone,
      'receipt_format': _receiptFormat,
      'paper_size': _paper,
      'text_size': _textSize,
      'wholesale_paper': _wholesalePaper,
      'receipt_footer': _footer.text.trim(),
      'default_payment': _defaultPay,
      'valuation': _valuation,
      'pos_theme': _theme,
      'cart_unit': _cartUnit,
      'receipt_language': _receiptLanguage,
      'fbr_ntn': _ntn.text.trim(),
      'fbr_strn': _strn.text.trim(),
      'fbr_pos_id': _posId.text.trim(),
      'fbr_endpoint': _endpoint.text.trim(),
      'fbr_token': _token.text.trim(),
      'flags': _flag,
    });
    await ref.read(sessionProvider.notifier).setCurrency(_currencyCode, _symbol);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final session = ref.watch(sessionProvider).value;
    final settings = ref.watch(_docSettings);
    if (!_loaded && !_hydrateQueued && settings.hasValue) {
      _hydrateQueued = true;
      final rows = settings.value ?? <DocumentRow>[];
      final shopName = session?.company['name']?.toString() ?? '';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _loaded) return;
        setState(() => _hydrate(rows.isEmpty ? null : _payload(rows.first), shopName));
      });
    }
    const tabs = [
      ('shop', FontAwesomeIcons.store, 'shop'),
      ('receipt', FontAwesomeIcons.receipt, 'receipt'),
      ('permissions', FontAwesomeIcons.userShield, 'permissions'),
      ('languages', FontAwesomeIcons.language, 'languages'),
      ('theme', FontAwesomeIcons.palette, 'themePos'),
      ('labels', FontAwesomeIcons.print, 'labelPrinting'),
      ('voice', FontAwesomeIcons.volumeHigh, 'voiceUrdu'),
      ('fbr', FontAwesomeIcons.landmark, 'fbr'),
    ];
    return _page(
      context,
      l10n.t('settings'),
      Card(
        margin: EdgeInsets.zero,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(10)),
                child: Text(l10n.t('settingsHelp'), style: const TextStyle(color: Color(0xFF047857))),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final tab in tabs)
                      InkWell(
                        onTap: () => setState(() => _tab = tab.$1),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: _tab == tab.$1 ? const Color(0xFF0F766E) : Colors.transparent, width: 2)),
                          ),
                          child: Row(
                            children: [
                              FaIcon(tab.$2, size: 14, color: _tab == tab.$1 ? const Color(0xFF0F766E) : const Color(0xFF64748B)),
                              const SizedBox(width: 8),
                              Text(l10n.t(tab.$3), style: TextStyle(color: _tab == tab.$1 ? const Color(0xFF0F766E) : const Color(0xFF334155), fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              const SizedBox(height: 16),
              _body(l10n),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.t('save'))),
              ),
            ],
          ),
        ),
      ),
      back: '/dashboard',
    );
  }

  Widget _body(L10n l10n) {
    return switch (_tab) {
      'receipt' => _receipt(l10n),
      'permissions' => _permissions(l10n),
      'languages' => _languages(l10n),
      'theme' => _themeTab(l10n),
      'labels' => _labels(l10n),
      'voice' => _voice(l10n),
      'fbr' => _fbr(l10n),
      _ => _shop(l10n),
    };
  }

  Widget _shop(L10n l10n) {
    return fieldGrid([
      labeledField(l10n.t('shopName'), _name),
      labeledField(l10n.t('phone'), _phone, hint: '0300-1234567'),
      labeledField(l10n.t('address'), _address),
      labeledSelect<String>(
        label: l10n.t('currency'),
        value: _currencyCode,
        items: [for (final row in _currencies) DropdownMenuItem(value: row.$1, child: Text(row.$3))],
        onChanged: (value) => setState(() => _currencyCode = value ?? 'PKR'),
      ),
      labeledField(l10n.t('invoicePrefix'), _prefix),
      labeledField(l10n.t('taxRate'), _tax, keyboard: TextInputType.number),
      labeledSelect<String>(
        label: l10n.t('timezone'),
        value: _timezone,
        items: const [
          DropdownMenuItem(value: 'Asia/Karachi', child: Text('Pakistan (PKT, UTC+5)')),
          DropdownMenuItem(value: 'Asia/Dubai', child: Text('Dubai (UTC+4)')),
          DropdownMenuItem(value: 'UTC', child: Text('UTC')),
        ],
        onChanged: (value) => setState(() => _timezone = value ?? 'Asia/Karachi'),
      ),
    ]);
  }

  Widget _receipt(L10n l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        fieldGrid([
          labeledSelect<String>(
            label: 'Receipt format',
            value: _receiptFormat,
            items: const [
              DropdownMenuItem(value: 'thermal', child: Text('Thermal: current retail layout')),
              DropdownMenuItem(value: 'a4', child: Text('A4 invoice')),
            ],
            onChanged: (value) => setState(() => _receiptFormat = value ?? 'thermal'),
          ),
          labeledSelect<String>(
            label: 'Thermal paper size',
            value: _paper,
            items: const [
              DropdownMenuItem(value: '58', child: Text('58mm roll')),
              DropdownMenuItem(value: '80', child: Text('80mm roll')),
            ],
            onChanged: (value) => setState(() => _paper = value ?? '80'),
          ),
          labeledSelect<String>(
            label: 'Receipt text size',
            value: _textSize,
            items: const [
              DropdownMenuItem(value: 'small', child: Text('Small')),
              DropdownMenuItem(value: 'normal', child: Text('Normal')),
              DropdownMenuItem(value: 'large', child: Text('Large')),
            ],
            onChanged: (value) => setState(() => _textSize = value ?? 'normal'),
          ),
          labeledSelect<String>(
            label: 'Wholesale paper size',
            value: _wholesalePaper,
            items: const [
              DropdownMenuItem(value: 'a5', child: Text('A5')),
              DropdownMenuItem(value: 'a4', child: Text('A4')),
            ],
            onChanged: (value) => setState(() => _wholesalePaper = value ?? 'a5'),
          ),
          labeledField('Receipt notes / footer', _footer),
        ]),
      ],
    );
  }

  Widget _permissions(L10n l10n) {
    return Column(
      children: [
        labeledSelect<String>(
          label: 'Default POS payment method',
          value: _defaultPay,
          items: const [
            DropdownMenuItem(value: 'cash', child: Text('Cash')),
            DropdownMenuItem(value: 'bank', child: Text('Bank')),
            DropdownMenuItem(value: 'credit', child: Text('Credit')),
          ],
          onChanged: (value) => setState(() => _defaultPay = value ?? 'cash'),
        ),
        const SizedBox(height: 8),
        _check('Show customer balance / udhaar on invoice', 'showBalance'),
        _check('Allow owner to edit or delete khata payments', 'ownerEditsKhata'),
        _check('Show "Sold by" picker on the POS', 'soldBy'),
        _check('Show sales channel on POS', 'salesChannel'),
        _check('Allow selling below the purchase price', 'belowCost'),
        _check('Show out-of-stock products on POS', 'outOfStock'),
        const SizedBox(height: 8),
        _radio('Deduct materials when sold', 'deductOnSale', true),
        _radio('Deduct materials when making a batch', 'deductOnSale', false),
        _check('Sell manufacturing products when materials are short', 'sellShort'),
        _check('Show shipping / carriage on POS checkout', 'shipping'),
        _check('Show sale notes on POS checkout', 'saleNotes'),
        _check('Show cost price on the POS product list', 'showCost'),
        labeledSelect<String>(
          label: 'Stock valuation',
          value: _valuation,
          items: const [
            DropdownMenuItem(value: 'manual', child: Text('Manual (I set the cost)')),
            DropdownMenuItem(value: 'fifo', child: Text('FIFO')),
          ],
          onChanged: (value) => setState(() => _valuation = value ?? 'manual'),
        ),
        _check('Godown / counter stock tracking', 'godown'),
      ],
    );
  }

  Widget _languages(L10n l10n) {
    final locale = ref.watch(localeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.t('language'), style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final language in appLanguages)
              ChoiceChip(
                label: Text(language.native, style: TextStyle(color: locale == language.code ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.w600)),
                selected: locale == language.code,
                selectedColor: const Color(0xFF0F766E),
                onSelected: (_) => ref.read(localeProvider.notifier).set(language.code),
              ),
          ],
        ),
        const SizedBox(height: 16),
        labeledSelect<String>(
          label: 'Receipt language',
          value: _receiptLanguage,
          items: const [
            DropdownMenuItem(value: 'en', child: Text('English')),
            DropdownMenuItem(value: 'ur', child: Text('اردو')),
            DropdownMenuItem(value: 'both', child: Text('English + Urdu')),
          ],
          onChanged: (value) => setState(() => _receiptLanguage = value ?? 'en'),
        ),
      ],
    );
  }

  Widget _themeTab(L10n l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('POS screen theme', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _option('Classic', 'Product tiles on the left, cart on the right.', _theme == 'classic', () => setState(() => _theme = 'classic')),
            _option('Mart', 'Scan-first table with side actions.', _theme == 'mart', () => setState(() => _theme = 'mart')),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Cart & invoice unit', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _option('On the item name', 'Qty stays a number. No extra unit column.', _cartUnit == 'name', () => setState(() => _cartUnit = 'name')),
            _option('Own unit column', 'A separate unit column on the cart.', _cartUnit == 'column', () => setState(() => _cartUnit = 'column')),
          ],
        ),
        _check('Show webcam barcode scan on desktop POS', 'webcam'),
        _check('POS keyboard shortcuts', 'shortcuts'),
        if (_flag['shortcuts'] ?? false)
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 4),
            child: Text(
              'F1  Product search\nF2  Customer search\nF3  Payment method\nF4  Amount received\nF5  Hold cart\nF6  Clear cart\nF8  Return\nF9 / F12  Checkout\n+ / -  Change qty\nEsc  Clear search\nCtrl+Z  Undo',
              style: TextStyle(height: 1.6, color: Color(0xFF475569)),
            ),
          ),
      ],
    );
  }

  Widget _labels(L10n l10n) {
    final shop = _name.text.trim().isEmpty ? 'POS360tech' : _name.text.trim();
    return LayoutBuilder(
      builder: (context, constraints) {
        final checks = Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            _check('Shop name', 'labelShop'),
            _check('Product name', 'labelProduct'),
            _check('Serial / product code', 'labelSerial'),
            _check('Sale price', 'labelPrice'),
            _check('Barcode graphic', 'labelBarcode'),
            _check('Rack / shelf location', 'labelRack'),
            _check('Expiry date', 'labelExpiry'),
            _check('Batch number', 'labelBatch'),
          ],
        );
        final preview = Container(
          width: 260,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              const Text('Live preview', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Container(
                width: 160,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid)),
                child: Column(
                  children: [
                    if (_flag['labelShop'] ?? false) Text(shop, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    if (_flag['labelProduct'] ?? false) const Text('Sample Product', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    if (_flag['labelSerial'] ?? false) const Text('S/N: PRD-000001', style: TextStyle(fontSize: 11)),
                    if (_flag['labelPrice'] ?? false) Text('$_symbol 1,250', style: const TextStyle(fontWeight: FontWeight.w800)),
                    if (_flag['labelBarcode'] ?? false) const Text('||||| ||| |||| |||', style: TextStyle(letterSpacing: 1, fontSize: 12)),
                    if (_flag['labelRack'] ?? false) const Text('Rack A-12', style: TextStyle(fontSize: 11)),
                    if (_flag['labelExpiry'] ?? false) const Text('Exp 12/2027', style: TextStyle(fontSize: 11)),
                    if (_flag['labelBatch'] ?? false) const Text('Batch B-04', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        );
        if (constraints.maxWidth < 760) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [checks, const SizedBox(height: 16), preview]);
        }
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: checks), preview]);
      },
    );
  }

  Widget _voice(L10n l10n) {
    return Column(
      children: [
        _check('Speak the item name and total at checkout', 'voice'),
        _check('Print Urdu names on receipts when a Urdu name exists', 'urduReceipt'),
      ],
    );
  }

  Widget _fbr(L10n l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('FBR: Pakistan tax', style: TextStyle(fontWeight: FontWeight.w700)),
        _check('Enable FBR tax', 'fbr'),
        _check('Push invoices live to the FBR API', 'fbrLive'),
        fieldGrid([
          labeledField('FBR NTN', _ntn),
          labeledField('STRN', _strn),
          labeledField('FBR POS ID', _posId),
          labeledField('FBR endpoint URL', _endpoint),
          labeledField('FBR bearer token', _token),
        ]),
      ],
    );
  }

  Widget _check(String label, String key) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      value: _flag[key] ?? false,
      title: Text(label),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (value) => setState(() => _flag[key] = value ?? false),
    );
  }

  Widget _radio(String label, String key, bool value) {
    final selected = (_flag[key] ?? false) == value;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? const Color(0xFF0F766E) : const Color(0xFF94A3B8)),
      title: Text(label),
      onTap: () => setState(() => _flag[key] = value),
    );
  }

  Widget _option(String title, String help, bool selected, VoidCallback onTap) {
    return SizedBox(
      width: 280,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? const Color(0xFF0F766E) : const Color(0xFFE2E8F0), width: selected ? 1.6 : 1),
            color: selected ? const Color(0xFFF0FDFA) : Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(help, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentMethodsPage extends ConsumerStatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  ConsumerState<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends ConsumerState<PaymentMethodsPage> {
  final _name = TextEditingController();
  String _goes = 'cash';
  String? _bank;
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_seed);
  }

  Future<void> _seed() async {
    if (_seeded) return;
    _seeded = true;
    final existing = await ref.read(storeProvider).watchDocuments('payment_method').first;
    if (existing.isNotEmpty) return;
    const rows = [
      ['10000000-0000-4000-8000-000000000101', 'Cash', 'cash'],
      ['10000000-0000-4000-8000-000000000102', 'Udhaar (credit)', 'udhaar'],
      ['10000000-0000-4000-8000-000000000103', 'Card', 'cash'],
      ['10000000-0000-4000-8000-000000000104', 'Bank transfer', 'bank'],
      ['10000000-0000-4000-8000-000000000105', 'Cheque', 'bank'],
      ['10000000-0000-4000-8000-000000000106', 'JazzCash', 'cash'],
      ['10000000-0000-4000-8000-000000000107', 'Easypaisa', 'cash'],
    ];
    for (final row in rows) {
      await ref.read(storeProvider).saveMoney('payment_method', {
        'client_uuid': row[0],
        'name': row[1],
        'goes_to': row[2],
        'is_active': true,
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (_name.text.trim().isEmpty) return;
    await ref.read(storeProvider).saveMoney('payment_method', {
      'name': _name.text.trim(),
      'goes_to': _goes,
      'bank_client_uuid': _bank ?? '',
      'is_active': true,
    });
    _name.clear();
  }

  Future<void> _toggle(Map<String, dynamic> row, bool active) async {
    await ref.read(storeProvider).saveMoney('payment_method', {
      ...row,
      'is_active': active,
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final rows = (ref.watch(_docPayments).value ?? <DocumentRow>[]).map(_payload).toList();
    final banks = (ref.watch(_docBanks).value ?? <DocumentRow>[]).map(_payload).toList();
    return _page(
      context,
      l10n.t('paymentMethods'),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Which ways your shop takes money. Add your own, or hide what you do not use.', style: TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  SizedBox(width: 240, child: labeledField(l10n.t('itemName'), _name, hint: 'UPI, Vodafone Cash...')),
                  SizedBox(
                    width: 200,
                    child: labeledSelect<String>(
                      label: 'Money goes to',
                      value: _goes,
                      items: const [
                        DropdownMenuItem(value: 'cash', child: Text('Cash in hand')),
                        DropdownMenuItem(value: 'bank', child: Text('Bank account')),
                        DropdownMenuItem(value: 'udhaar', child: Text('Udhaar (credit)')),
                      ],
                      onChanged: (value) => setState(() => _goes = value ?? 'cash'),
                    ),
                  ),
                  if (_goes == 'bank')
                    SizedBox(
                      width: 200,
                      child: labeledSelect<String>(
                        label: 'Which bank?',
                        value: _bank,
                        items: [for (final bank in banks) DropdownMenuItem(value: bank['client_uuid']?.toString(), child: Text(bank['name']?.toString() ?? ''))],
                        onChanged: (value) => setState(() => _bank = value),
                      ),
                    ),
                  FilledButton(onPressed: _add, child: Text(l10n.t('add'))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            color: Colors.white,
            child: rows.isEmpty
                ? Padding(padding: const EdgeInsets.all(24), child: Text(l10n.t('noRecords'), style: const TextStyle(color: Color(0xFF64748B))))
                : Column(
                    children: [
                      for (var index = 0; index < rows.length; index++) ...[
                        ListTile(
                          title: Text(rows[index]['name']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(rows[index]['goes_to']?.toString() ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(rows[index]['is_active'] == false ? l10n.t('inactive') : l10n.t('active'), style: const TextStyle(color: Color(0xFF64748B))),
                              Switch(
                                value: rows[index]['is_active'] != false,
                                onChanged: (value) => _toggle(rows[index], value),
                              ),
                            ],
                          ),
                        ),
                        if (index != rows.length - 1) const Divider(height: 1),
                      ],
                    ],
                  ),
          ),
        ],
      ),
      back: '/settings',
    );
  }
}

final _paperDocs = StreamProvider.family<List<DocumentRow>, String>((ref, entity) => ref.watch(storeProvider).watchDocuments(entity));

class PaperDocsPage extends ConsumerStatefulWidget {
  const PaperDocsPage({super.key, required this.entity, required this.titleKey});

  final String entity;
  final String titleKey;

  @override
  ConsumerState<PaperDocsPage> createState() => _PaperDocsPageState();
}

class _PaperDocsPageState extends ConsumerState<PaperDocsPage> {
  final _customer = TextEditingController();
  final _date = TextEditingController(text: _isoDay());
  final _note = TextEditingController();
  final _amount = TextEditingController();

  @override
  void dispose() {
    _customer.dispose();
    _date.dispose();
    _note.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_customer.text.trim().isEmpty) return;
    await ref.read(storeProvider).saveMoney(widget.entity, {
      'customer_name': _customer.text.trim(),
      'occurred_on': _parseDay(_date.text) == null ? _isoDay() : _isoDay(_parseDay(_date.text)),
      'note': _note.text.trim(),
      'amount': Fixed.n(_amount.text),
    });
    _customer.clear();
    _note.clear();
    _amount.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    final rows = (ref.watch(_paperDocs(widget.entity)).value ?? <DocumentRow>[]).map(_payload).toList();
    return _page(
      context,
      l10n.t(widget.titleKey),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            margin: EdgeInsets.zero,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  fieldGrid([
                    labeledField(l10n.t('customerName'), _customer),
                    labeledField(l10n.t('date'), _date, hint: 'dd/mm/yyyy'),
                    labeledField(l10n.t('amount'), _amount, keyboard: TextInputType.number, prefix: symbol),
                    labeledField(l10n.t('note'), _note),
                  ]),
                  Align(alignment: Alignment.centerRight, child: FilledButton(onPressed: _save, child: Text(l10n.t('save')))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _table(
            context,
            [l10n.t('date'), l10n.t('customerName'), l10n.t('note'), l10n.t('amount')],
            rows.map((row) => [row['occurred_on']?.toString() ?? '', row['customer_name']?.toString() ?? '', row['note']?.toString() ?? '', Fixed.rs(row['amount'], symbol)]).toList(),
            rows.isEmpty ? l10n.t('noRecords') : null,
          ),
        ],
      ),
      back: '/sales',
    );
  }
}
