part of 'pages.dart';

const _ink = Color(0xFF134E4A);
const _muted = Color(0xFF64748B);

final _docHeld = StreamProvider<List<DocumentRow>>((ref) => ref.watch(storeProvider).watchDocuments('held_sale'));

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key, this.back});

  final String? back;

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _PosLine {
  _PosLine({
    required this.name,
    required String qty,
    required String price,
    this.product,
    this.isReturn = false,
    this.cost = 0,
    String discount = '0',
  })  : qty = TextEditingController(text: qty),
        price = TextEditingController(text: price),
        discount = TextEditingController(text: discount);

  final String name;
  final ProductRow? product;
  final TextEditingController qty;
  final TextEditingController price;
  final TextEditingController discount;
  bool isReturn;
  final double cost;

  double get net {
    final gross = Fixed.n(qty.text) * Fixed.n(price.text) - Fixed.n(discount.text);
    final safe = gross < 0 ? 0.0 : gross;
    return isReturn ? -safe : safe;
  }

  void dispose() {
    qty.dispose();
    price.dispose();
    discount.dispose();
  }

  Map<String, dynamic> toPayload() => {
        'name': name,
        if (product != null) 'product_client_uuid': product!.clientUuid,
        'qty': Fixed.n(qty.text),
        'unit_price': Fixed.n(price.text),
        'discount': Fixed.n(discount.text),
        'is_return': isReturn,
        'unit_cost': cost,
      };
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  final _customer = TextEditingController();
  final _received = TextEditingController();
  final _orderDiscount = TextEditingController(text: '0');
  final _saleDate = TextEditingController();
  final _lines = <_PosLine>[];
  String _browse = 'search';
  String _priceList = 'retail';
  String _method = 'cash';
  String? _party;
  String? _category;
  String? _brand;
  bool _returnMode = false;
  int _exchangeStep = 0;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _saleDate.text = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    _customer.dispose();
    _received.dispose();
    _orderDiscount.dispose();
    _saleDate.dispose();
    for (final line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  double get _subtotal => _lines.fold(0, (sum, line) => sum + line.net);

  double _taxRate() {
    final rows = ref.read(_docSettings).value ?? <DocumentRow>[];
    if (rows.isEmpty) return 0;
    return Fixed.n(_payload(rows.first)['tax_rate']);
  }

  double get _tax {
    final base = _subtotal - Fixed.n(_orderDiscount.text);
    if (base <= 0) return 0;
    return base * _taxRate() / 100;
  }

  double get _total => _subtotal - Fixed.n(_orderDiscount.text) + _tax;

  /// An empty received box means the customer handed over the full total.
  /// Credit still needs a typed amount, or the whole bill stays on the khata.
  double get _cashIn {
    final typed = _received.text.trim();
    if (typed.isEmpty) return _method == 'credit' ? 0 : (_total > 0 ? _total : 0);
    return Fixed.n(typed);
  }

  String _priceFor(ProductRow product) {
    if (_priceList == 'wholesale' && Fixed.n(product.wholesalePrice) > 0) return product.wholesalePrice;
    return product.salePrice;
  }

  void _addProduct(ProductRow product) {
    final asReturn = _exchangeStep == 1 || (_exchangeStep == 0 && _returnMode);
    final same = _lines.where((line) => line.product?.clientUuid == product.clientUuid && line.isReturn == asReturn);
    if (same.isNotEmpty) {
      final line = same.first;
      line.qty.text = (Fixed.n(line.qty.text) + 1).toString();
    } else {
      _lines.add(_PosLine(
        name: product.nameEn,
        product: product,
        qty: '1',
        price: _priceFor(product),
        isReturn: asReturn,
        cost: Fixed.n(product.purchasePrice),
      ));
    }
    if (_exchangeStep == 1) {
      _exchangeStep = 2;
    } else if (_exchangeStep == 2) {
      _exchangeStep = 0;
    }
    _search.clear();
    setState(() {});
  }

  void _addQuick(String name, String price, String qty, String cost) {
    _lines.add(_PosLine(
      name: name,
      qty: qty.trim().isEmpty ? '1' : qty.trim(),
      price: price,
      isReturn: _returnMode && _exchangeStep == 0,
      cost: Fixed.n(cost),
    ));
    setState(() {});
  }

  void _clear() {
    for (final line in _lines) {
      line.dispose();
    }
    _lines.clear();
    _received.clear();
    _orderDiscount.text = '0';
    _customer.clear();
    _party = null;
    _returnMode = false;
    _exchangeStep = 0;
    setState(() {});
  }

  Future<void> _hold() async {
    if (_lines.isEmpty) return;
    await ref.read(storeProvider).saveMoney('held_sale', {
      'status': 'open',
      'party_name': _customer.text.trim(),
      'party_client_uuid': _party ?? '',
      'lines': [for (final line in _lines) line.toPayload()],
    });
    _clear();
  }

  void _restore(Map<String, dynamic> row, List<ProductRow> products) {
    _clear();
    final lines = row['lines'];
    if (lines is List) {
      for (final raw in lines.whereType<Map>()) {
        final uuid = raw['product_client_uuid']?.toString();
        ProductRow? product;
        for (final item in products) {
          if (item.clientUuid == uuid) product = item;
        }
        _lines.add(_PosLine(
          name: raw['name']?.toString() ?? product?.nameEn ?? 'Item',
          product: product,
          qty: raw['qty']?.toString() ?? '1',
          price: raw['unit_price']?.toString() ?? '0',
          discount: raw['discount']?.toString() ?? '0',
          isReturn: raw['is_return'] == true,
          cost: Fixed.n(raw['unit_cost']),
        ));
      }
    }
    _customer.text = row['party_name']?.toString() ?? '';
    _party = (row['party_client_uuid']?.toString().isEmpty ?? true) ? null : row['party_client_uuid']?.toString();
    ref.read(storeProvider).saveMoney('held_sale', {...row, 'status': 'resumed'});
    setState(() {});
  }

  Future<void> _charge() async {
    final l10n = ref.read(l10nProvider);
    final branch = _currentBranch(ref);
    if (branch == null || _lines.isEmpty || _busy) {
      if (_lines.isEmpty && mounted) _toast(context, l10n.t('noRecords'));
      return;
    }
    final total = _total;
    final received = _cashIn;
    final named = _customer.text.trim();
    if (total > 0 && received + 0.009 < total && named.isEmpty && _party == null) {
      _toast(context, 'Enter the full amount, or pick a customer to put the rest on credit.');
      return;
    }
    final method = total > 0 && received + 0.009 < total ? 'credit' : _method;
    final day = _parseDay(_saleDate.text) ?? DateTime.now();
    final at = DateTime(day.year, day.month, day.day, DateTime.now().hour, DateTime.now().minute).toUtc().toIso8601String();
    setState(() => _busy = true);
    await ref.read(storeProvider).postStock('sale', {
      'branch_client_uuid': branch,
      'party_name': named,
      'party_client_uuid': _party ?? '',
      'invoice_no': 'S-${DateTime.now().millisecondsSinceEpoch}',
      'occurred_at': at,
      'payment_method': method,
      'paid': method == 'credit' ? received : total,
      'order_discount': Fixed.n(_orderDiscount.text),
      'tax': _tax,
      'total': total,
      'lines': [for (final line in _lines) line.toPayload()],
    }, operatorName: ref.read(sessionProvider).value?.name);
    if (!mounted) return;
    context.go(widget.back ?? '/sales');
  }

  Future<void> _quickItem() async {
    final added = await showDialog<({String name, String price, String qty, String cost})>(
      context: context,
      builder: (context) => const _QuickItemDialog(),
    );
    if (added == null) return;
    _addQuick(added.name, added.price, added.qty, added.cost);
  }

  Future<void> _receivePayment() async {
    final parties = (ref.read(_docParties).value ?? <DocumentRow>[]).map(_payload).where((row) => row['type'] != 'supplier').toList();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => _ReceivePaymentDialog(parties: parties),
    );
  }

  Future<void> _showHeld(List<Map<String, dynamic>> rows, List<ProductRow> products) async {
    final open = rows.where((row) => row['status'] != 'resumed').toList();
    if (!mounted) return;
    final picked = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ref.read(l10nProvider).t('heldBills')),
        content: SizedBox(
          width: 420,
          child: open.isEmpty
              ? Text(ref.read(l10nProvider).t('noRecords'))
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final row in open)
                      ListTile(
                        title: Text((row['party_name']?.toString().isNotEmpty ?? false) ? row['party_name'].toString() : ref.read(l10nProvider).t('walkIn')),
                        subtitle: Text('${(row['lines'] as List?)?.length ?? 0} items'),
                        onTap: () => Navigator.pop(context, row),
                      ),
                  ],
                ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(ref.read(l10nProvider).t('cancel')))],
      ),
    );
    if (picked != null) _restore(picked, products);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    final products = (ref.watch(_products).value ?? <ProductRow>[]).where((row) => row.isActive).toList();
    final categories = ref.watch(_categories).value ?? <CategoryRow>[];
    final brands = ref.watch(_brands).value ?? <BrandRow>[];
    final parties = (ref.watch(_docParties).value ?? <DocumentRow>[]).map(_payload).where((row) => row['type'] != 'supplier').toList();
    final held = (ref.watch(_docHeld).value ?? <DocumentRow>[]).map(_payload).where((row) => row['status'] != 'resumed').toList();
    final query = _search.text.trim().toLowerCase();
    final visible = products.where((row) {
      if (_browse == 'category' && _category != null && row.categoryClientUuid != _category) return false;
      if (_browse == 'brand' && _brand != null && row.brandClientUuid != _brand) return false;
      if (query.isEmpty) return true;
      return row.nameEn.toLowerCase().contains(query) || row.nameUr.toLowerCase().contains(query) || row.code.toLowerCase().contains(query) || (row.barcode ?? '').toLowerCase().contains(query);
    }).toList();
    final received = _cashIn;
    final change = received > _total ? received - _total : 0.0;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f1): () => _searchFocus.requestFocus(),
        const SingleActivator(LogicalKeyboardKey.f5): _hold,
        const SingleActivator(LogicalKeyboardKey.f6): _clear,
        const SingleActivator(LogicalKeyboardKey.f8): () => setState(() => _returnMode = !_returnMode),
        const SingleActivator(LogicalKeyboardKey.f9): _charge,
        const SingleActivator(LogicalKeyboardKey.f12): _charge,
      },
      child: Focus(
        autofocus: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(tooltip: 'Back', onPressed: () => context.go(widget.back ?? '/dashboard'), icon: const Icon(Icons.arrow_back)),
                  TextButton.icon(onPressed: () => context.go('/sales'), icon: const Icon(Icons.receipt_long, size: 18), label: Text(l10n.t('recentSales'))),
                  const SizedBox(width: 8),
                  Text(l10n.t('pos'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _ink)),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final sideBySide = constraints.maxWidth >= 860;
                    final catalog = _catalog(l10n, symbol, visible, categories, brands);
                    final cart = _cart(l10n, symbol, parties, held, products, change);
                    if (!sideBySide) {
                      return Column(children: [SizedBox(height: constraints.maxHeight * 0.34, child: catalog), const SizedBox(height: 8), Expanded(child: cart)]);
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 5, child: catalog),
                        const SizedBox(width: 12),
                        Expanded(flex: 6, child: cart),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _catalog(L10n l10n, String symbol, List<ProductRow> visible, List<CategoryRow> categories, List<BrandRow> brands) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              children: [
                _modeChip(l10n.t('search'), 'search', Icons.search),
                _modeChip(l10n.t('category'), 'category', Icons.category_outlined),
                _modeChip(l10n.t('brand'), 'brand', Icons.sell_outlined),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _search,
              focusNode: _searchFocus,
              decoration: InputDecoration(
                hintText: '${l10n.t('search')} / Barcode...',
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (value) {
                final hit = visible.where((row) => (row.barcode ?? '').toLowerCase() == value.trim().toLowerCase() || row.code.toLowerCase() == value.trim().toLowerCase());
                if (hit.length == 1) _addProduct(hit.first);
              },
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _priceChip(l10n.t('retail'), 'retail'),
                _priceChip(l10n.t('wholesale'), 'wholesale'),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: _ink),
                  onPressed: _quickItem,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.t('quickItem')),
                ),
              ],
            ),
            if (_browse == 'category') ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in categories)
                    ChoiceChip(
                      label: Text(category.nameEn),
                      selected: _category == category.clientUuid,
                      selectedColor: const Color(0xFFCCFBF1),
                      onSelected: (_) => setState(() => _category = _category == category.clientUuid ? null : category.clientUuid),
                    ),
                ],
              ),
            ],
            if (_browse == 'brand') ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final brand in brands)
                    ChoiceChip(
                      label: Text(brand.nameEn),
                      selected: _brand == brand.clientUuid,
                      selectedColor: const Color(0xFFCCFBF1),
                      onSelected: (_) => setState(() => _brand = _brand == brand.clientUuid ? null : brand.clientUuid),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Expanded(
              child: visible.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          '${l10n.t('noRecords')}\n\nUse Quick item to sell something that is not saved as a product.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: _muted, height: 1.4),
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: visible.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final product = visible[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(backgroundColor: Color(0xFFF0FDFA), child: Icon(Icons.inventory_2_outlined, color: _teal, size: 18)),
                          title: Text(product.nameEn, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(product.code, style: const TextStyle(color: _muted)),
                          trailing: Text(Fixed.rs(_priceFor(product), symbol), style: const TextStyle(fontWeight: FontWeight.w700, color: _teal)),
                          onTap: () => _addProduct(product),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cart(L10n l10n, String symbol, List<Map<String, dynamic>> parties, List<Map<String, dynamic>> held, List<ProductRow> products, double change) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.shopping_cart_outlined, color: _teal),
                const SizedBox(width: 8),
                Text('${l10n.t('cart')}  ${_lines.length}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const Spacer(),
                TextButton(onPressed: _lines.isEmpty ? null : _clear, child: Text(l10n.t('clearCart'), style: const TextStyle(color: Color(0xFFB91C1C)))),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _teal,
                minimumSize: const Size.fromHeight(40),
              ),
              onPressed: _receivePayment,
              icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
              label: Text(l10n.t('receivePayment')),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _cartAction(l10n.t('returnItem'), Icons.undo, _returnMode, () => setState(() {
                    _returnMode = !_returnMode;
                    _exchangeStep = 0;
                  })),
                  const SizedBox(width: 8),
                  _cartAction(l10n.t('exchange'), Icons.swap_horiz, _exchangeStep > 0, () => setState(() {
                    _exchangeStep = _exchangeStep == 0 ? 1 : 0;
                    _returnMode = false;
                  })),
                  const SizedBox(width: 8),
                  _cartAction(l10n.t('holdBill'), Icons.pause, false, _hold),
                  const SizedBox(width: 8),
                  _cartAction('${l10n.t('heldBills')} (${held.length})', Icons.inbox_outlined, false, () => _showHeld(held, products)),
                ],
              ),
            ),
            if (_returnMode)
              const Padding(padding: EdgeInsets.only(top: 8), child: Text('Return mode: the next item goes back to stock and comes off the bill.', style: TextStyle(color: _teal))),
            if (_exchangeStep == 1)
              const Padding(padding: EdgeInsets.only(top: 8), child: Text('Exchange: tap the item the customer is bringing back.', style: TextStyle(color: _teal))),
            if (_exchangeStep == 2)
              const Padding(padding: EdgeInsets.only(top: 8), child: Text('Exchange: tap the new item they are taking.', style: TextStyle(color: _teal))),
            const SizedBox(height: 8),
            Expanded(
              child: _lines.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Tap a product on the left, or Quick item.\nThen press Checkout to save the sale.', textAlign: TextAlign.center, style: TextStyle(color: _muted, height: 1.5)),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _lines.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) => _lineTile(l10n, symbol, index),
                    ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text('${l10n.t('subtotal')} ${Fixed.rs(_subtotal, symbol)}', style: const TextStyle(fontSize: 12, color: _muted)),
                const SizedBox(width: 12),
                Text('${l10n.t('tax')} ${Fixed.rs(_tax, symbol)}', style: const TextStyle(fontSize: 12, color: _muted)),
                const Spacer(),
                SizedBox(width: 140, child: TextField(controller: _orderDiscount, keyboardType: TextInputType.number, style: const TextStyle(fontSize: 13), decoration: InputDecoration(labelText: l10n.t('orderDiscount'), prefixText: '$symbol ', isDense: true), onChanged: (_) => setState(() {}))),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: _teal, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Text('TOTAL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text(Fixed.rs(_total, symbol), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: labeledSelect<String>(
                    label: l10n.t('customerName'),
                    value: _party,
                    items: [
                      DropdownMenuItem(value: null, child: Text(l10n.t('walkIn'))),
                      for (final party in parties) DropdownMenuItem(value: party['client_uuid']?.toString(), child: Text(party['name']?.toString() ?? '')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _party = value;
                        _customer.text = parties.cast<Map<String, dynamic>?>().firstWhere((row) => row?['client_uuid'] == value, orElse: () => null)?['name']?.toString() ?? '';
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: labeledField(l10n.t('saleDate'), _saleDate)),
                const SizedBox(width: 8),
                Expanded(child: labeledField(l10n.t('received'), _received, hint: l10n.t('receivedHint'), keyboard: TextInputType.number, prefix: symbol, onChanged: (_) => setState(() {}))),
                const SizedBox(width: 8),
                Expanded(
                  child: labeledSelect<String>(
                    label: l10n.t('paymentMethod'),
                    value: _method,
                    items: [
                      DropdownMenuItem(value: 'cash', child: Text(l10n.t('cash'))),
                      DropdownMenuItem(value: 'bank', child: Text(l10n.t('bank'))),
                      DropdownMenuItem(value: 'credit', child: Text(l10n.t('credit'))),
                    ],
                    onChanged: (value) => setState(() => _method = value ?? 'cash'),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text('${l10n.t('changeDue')}  ${Fixed.rs(_total < 0 ? _total.abs() : change, symbol)}', style: const TextStyle(color: _muted, fontSize: 12)),
                const Spacer(),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF115E59), visualDensity: VisualDensity.compact),
                  onPressed: _busy || _lines.isEmpty ? null : _charge,
                  child: Text('${l10n.t('checkout')}  ${Fixed.rs(_total, symbol)}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _lineTile(L10n l10n, String symbol, int index) {
    final line = _lines[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                if (line.isReturn) const Text('Return', style: TextStyle(color: _teal, fontSize: 12, fontWeight: FontWeight.w700)),
                Text(Fixed.rs(line.price.text, symbol), style: const TextStyle(color: _muted, fontSize: 12)),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: line.discount,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(hintText: 'Discount...', prefixText: '$symbol ', isDense: true),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ),
          _qtyButton(Icons.remove, () {
            final next = Fixed.n(line.qty.text) - 1;
            if (next <= 0) return;
            setState(() => line.qty.text = next == next.roundToDouble() ? next.toInt().toString() : next.toString());
          }),
          SizedBox(
            width: 56,
            child: TextField(
              controller: line.qty,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(isDense: true),
              onChanged: (_) => setState(() {}),
            ),
          ),
          _qtyButton(Icons.add, () => setState(() {
            final next = Fixed.n(line.qty.text) + 1;
            line.qty.text = next == next.roundToDouble() ? next.toInt().toString() : next.toString();
          })),
          SizedBox(width: 110, child: Text(Fixed.rs(line.net, symbol), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w800, color: _ink))),
          IconButton(
            onPressed: () => setState(() {
              _lines[index].dispose();
              _lines.removeAt(index);
            }),
            icon: const Icon(Icons.close, color: _muted),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: _teal, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _modeChip(String label, String value, IconData icon) {
    final selected = _browse == value;
    return ChoiceChip(
      avatar: Icon(icon, size: 16, color: selected ? Colors.white : _ink),
      label: Text(label, style: TextStyle(color: selected ? Colors.white : _ink, fontWeight: FontWeight.w600)),
      selected: selected,
      selectedColor: _ink,
      backgroundColor: Colors.white,
      onSelected: (_) => setState(() => _browse = value),
    );
  }

  Widget _priceChip(String label, String value) {
    final selected = _priceList == value;
    return ChoiceChip(
      label: Text(label, style: TextStyle(color: selected ? Colors.white : _ink, fontWeight: FontWeight.w600)),
      selected: selected,
      selectedColor: _teal,
      backgroundColor: Colors.white,
      onSelected: (_) => setState(() => _priceList = value),
    );
  }

  Widget _cartAction(String label, IconData icon, bool on, VoidCallback tap) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: on ? Colors.white : _ink,
        backgroundColor: on ? _teal : Colors.white,
        side: const BorderSide(color: _teal),
      ),
      onPressed: tap,
      icon: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}

class _QuickItemDialog extends ConsumerStatefulWidget {
  const _QuickItemDialog();

  @override
  ConsumerState<_QuickItemDialog> createState() => _QuickItemDialogState();
}

class _QuickItemDialogState extends ConsumerState<_QuickItemDialog> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _qty = TextEditingController(text: '1');
  final _cost = TextEditingController(text: '0');

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _qty.dispose();
    _cost.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final symbol = ref.watch(moneySymbolProvider);
    final missing = _name.text.trim().isEmpty || Fixed.n(_price.text) <= 0;
    return AlertDialog(
      title: const Text('Quick item'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('For products not in your catalog. Enter a name and price to add it to this sale only.', style: TextStyle(color: _muted)),
            const SizedBox(height: 12),
            labeledField('Name', _name, onChanged: (_) => setState(() {})),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: labeledField('Sale price', _price, keyboard: TextInputType.number, prefix: symbol, onChanged: (_) => setState(() {}))),
                const SizedBox(width: 12),
                Expanded(child: labeledField('Quantity', _qty, keyboard: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 12),
            labeledField('Cost price (optional)', _cost, keyboard: TextInputType.number, prefix: symbol),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFF0FDFA), borderRadius: BorderRadius.circular(8)),
              child: const Text('Cost is optional. If you leave it empty, profit reports treat this line as full profit.', style: TextStyle(color: _teal, fontSize: 13)),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: _teal),
          onPressed: missing
              ? null
              : () => Navigator.pop(context, (name: _name.text.trim(), price: _price.text.trim(), qty: _qty.text.trim(), cost: _cost.text.trim())),
          child: const Text('Add to cart'),
        ),
      ],
    );
  }
}

class _ReceivePaymentDialog extends ConsumerStatefulWidget {
  const _ReceivePaymentDialog({required this.parties});

  final List<Map<String, dynamic>> parties;

  @override
  ConsumerState<_ReceivePaymentDialog> createState() => _ReceivePaymentDialogState();
}

class _ReceivePaymentDialogState extends ConsumerState<_ReceivePaymentDialog> {
  final _amount = TextEditingController();
  final _discount = TextEditingController(text: '0');
  final _note = TextEditingController();
  String? _party;
  String _method = 'cash';
  bool _tried = false;
  bool _busy = false;

  @override
  void dispose() {
    _amount.dispose();
    _discount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _tried = true);
    final cash = Fixed.n(_amount.text);
    final discount = Fixed.n(_discount.text);
    if (_party == null || cash <= 0) return;
    setState(() => _busy = true);
    await ref.read(storeProvider).saveMoney('credit_recovery', {
      'party_client_uuid': _party,
      'occurred_on': _isoDay(),
      'amount': cash + discount,
      'method': _method,
      'note': _note.text.trim().isEmpty ? 'POS receive payment' : _note.text.trim(),
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    return AlertDialog(
      title: Text(l10n.t('receivePayment')),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('This collects money a customer already owes. It does not charge the cart.', style: TextStyle(color: _muted)),
            const SizedBox(height: 12),
            labeledSelect<String>(
              label: 'Customer',
              value: _party,
              items: [for (final party in widget.parties) DropdownMenuItem(value: party['client_uuid']?.toString(), child: Text(party['name']?.toString() ?? ''))],
              onChanged: (value) => setState(() => _party = value),
            ),
            if (_tried && _party == null) const Text('Choose the customer who is paying.', style: TextStyle(color: Color(0xFFB91C1C), fontSize: 12)),
            const SizedBox(height: 12),
            labeledField('Amount', _amount, keyboard: TextInputType.number, prefix: symbol, onChanged: (_) => setState(() {})),
            const SizedBox(height: 12),
            labeledField('Discount', _discount, keyboard: TextInputType.number, prefix: symbol),
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text('Optional. Cash received plus discount is what comes off their balance.', style: TextStyle(color: _muted, fontSize: 12)),
            ),
            const SizedBox(height: 12),
            labeledSelect<String>(
              label: l10n.t('paymentMethod'),
              value: _method,
              items: [
                DropdownMenuItem(value: 'cash', child: Text(l10n.t('cash'))),
                DropdownMenuItem(value: 'bank', child: Text(l10n.t('bank'))),
              ],
              onChanged: (value) => setState(() => _method = value ?? 'cash'),
            ),
            const SizedBox(height: 12),
            labeledField(l10n.t('note'), _note),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.t('cancel'))),
        FilledButton(style: FilledButton.styleFrom(backgroundColor: _teal), onPressed: _busy ? null : _save, child: Text(l10n.t('receivePayment'))),
      ],
    );
  }
}
