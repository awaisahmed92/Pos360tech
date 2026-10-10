part of 'pages.dart';

const _line = Color(0xFFE6E8EE);
const _green = Color(0xFF15803D);
const _amber = Color(0xFFB45309);
const _red = Color(0xFFB91C1C);

DateTime? _saleTime(Map<String, dynamic> row) {
  final raw = (row['occurred_at'] ?? row['occurred_on'] ?? '').toString();
  return DateTime.tryParse(raw)?.toLocal();
}

bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

class _DayStats {
  _DayStats(List<Map<String, dynamic>> sales)
    : total = sales.fold(0.0, (sum, row) => sum + Fixed.n(row['total'])),
      count = sales.length,
      customers = {
        for (final row in sales)
          (row['party_client_uuid']?.toString().isNotEmpty ?? false)
              ? row['party_client_uuid'].toString()
              : (row['party_name']?.toString().trim().isNotEmpty ?? false)
              ? row['party_name'].toString().trim().toLowerCase()
              : 'walk-in:${row['client_uuid'] ?? row['invoice_no']}',
      }.length;

  final double total;
  final int count;
  final int customers;

  double get average => count == 0 ? 0 : total / count;
}

(String, Color) _saleStatus(L10n l10n, Map<String, dynamic> row) {
  final total = Fixed.n(row['total']);
  final paid = Fixed.n(row['paid']);
  if (total < 0) return (l10n.t('refund'), const Color(0xFF6D28D9));
  if (paid + 0.009 >= total) return (l10n.t('paid'), _green);
  if (paid > 0) return (l10n.t('partPaid'), _amber);
  return (l10n.t('onCredit'), _red);
}

String _compactMoney(double value) {
  final abs = value.abs();
  if (abs >= 10000000) return '${(value / 10000000).toStringAsFixed(1)}Cr';
  if (abs >= 100000) return '${(value / 100000).toStringAsFixed(1)}L';
  if (abs >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
  return value.toStringAsFixed(0);
}

String _ago(DateTime? time) {
  if (time == null) return '';
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} h ago';
  if (diff.inDays < 7) return '${diff.inDays} d ago';
  return _isoDay(time);
}

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final session = ref.watch(sessionProvider).value;
    final symbol = ref.watch(moneySymbolProvider);
    final branch = ref.watch(branchProvider);
    final products = ref.watch(_products).value ?? <ProductRow>[];
    final balances = ref.watch(_balances).value ?? <BalanceRow>[];
    final sales = (ref.watch(_docSales).value ?? <DocumentRow>[]).map(_payload).where((row) => branch == null || (row['branch_client_uuid']?.toString() ?? branch) == branch).toList()
      ..sort((a, b) => (_saleTime(b) ?? DateTime(0)).compareTo(_saleTime(a) ?? DateTime(0)));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    List<Map<String, dynamic>> on(DateTime day) => sales.where((row) {
      final time = _saleTime(row);
      return time != null && _sameDay(time, day);
    }).toList();
    final todayStats = _DayStats(on(today));
    final yesterdayStats = _DayStats(on(today.subtract(const Duration(days: 1))));
    final week = [for (var i = 6; i >= 0; i--) today.subtract(Duration(days: i))];
    final weekTotals = [for (final day in week) _DayStats(on(day)).total];
    final weekSales = sales.where((row) => !(_saleTime(row) ?? DateTime(0)).isBefore(week.first)).toList();

    final style = ref.watch(dashboardStyleProvider);
    final modules = style == 'modules';
    return LayoutBuilder(
      builder: (context, constraints) {
        final showPanel = !modules && constraints.maxWidth >= 1100;
        final main = SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _dashboardHeader(context, ref, l10n, session?.name ?? '', style, showPos: !showPanel),
              const SizedBox(height: 16),
              if (modules) ...[
                _moduleGrid(context, l10n),
              ] else ...[
              LayoutBuilder(
                builder: (context, box) => _fillRow(box.maxWidth, box.maxWidth >= 720 ? 4 : (box.maxWidth >= 360 ? 2 : 1), 1, 14, [
                  _statCard(l10n.t('todaySales'), Fixed.rs(todayStats.total, symbol), FontAwesomeIcons.sackDollar, _teal, todayStats.total, yesterdayStats.total, l10n, onTap: () => context.go('/sales')),
                  _statCard(l10n.t('transactions'), '${todayStats.count}', FontAwesomeIcons.receipt, const Color(0xFF1D4ED8), todayStats.count.toDouble(), yesterdayStats.count.toDouble(), l10n, onTap: () => context.go('/sales')),
                  _statCard(
                    l10n.t('customersToday'),
                    '${todayStats.customers}',
                    FontAwesomeIcons.users,
                    const Color(0xFF7C3AED),
                    todayStats.customers.toDouble(),
                    yesterdayStats.customers.toDouble(),
                    l10n,
                    onTap: () => context.go('/parties'),
                  ),
                  _statCard(l10n.t('avgSale'), Fixed.rs(todayStats.average, symbol), FontAwesomeIcons.chartLine, const Color(0xFFC2410C), todayStats.average, yesterdayStats.average, l10n, onTap: () => context.go('/reports')),
                ]),
              ),
              const SizedBox(height: 14),
              _split(
                wideBreak: 760,
                height: 330,
                stackedRightHeight: 120 + 54.0 * math.max(1, math.min(6, _TopProducts.rank(weekSales, products).length)),
                left: _dashPanel(
                  title: l10n.t('weeklySales'),
                  subtitle: l10n.t('last7Days'),
                  child: _WeeklyChart(days: week, totals: weekTotals, symbol: symbol),
                ),
                right: _dashPanel(
                  title: l10n.t('topProducts'),
                  subtitle: l10n.t('last7Days'),
                  child: _TopProducts(sales: weekSales, products: products, symbol: symbol),
                ),
              ),
              const SizedBox(height: 14),
              _split(
                wideBreak: 760,
                height: 380,
                stackedRightHeight: 130 + 62.0 * math.max(1, math.min(4, _InventoryAlerts.collect(products, balances, branch).length)),
                left: _dashPanel(
                  title: l10n.t('recentTransactions'),
                  action: TextButton(onPressed: () => context.go('/sales'), child: Text(l10n.t('sales'))),
                  child: _RecentTransactions(sales: sales.take(8).toList(), symbol: symbol),
                ),
                right: _dashPanel(
                  title: l10n.t('inventoryAlerts'),
                  action: TextButton(onPressed: () => context.go('/stock'), child: Text(l10n.t('stock'))),
                  child: _InventoryAlerts(products: products, balances: balances, branch: branch),
                ),
              ),
              ],
            ],
          ),
        );
        if (!showPanel) return main;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: main),
            const SizedBox(
              width: 340,
              child: Padding(padding: EdgeInsets.fromLTRB(0, 16, 16, 16), child: _QuickSalePanel()),
            ),
          ],
        );
      },
    );
  }
}

Widget _dashboardHeader(BuildContext context, WidgetRef ref, L10n l10n, String name, String style, {required bool showPos}) {
  final title = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(l10n.t('dashboard'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1D26))),
      const SizedBox(height: 2),
      Text('$name · ${l10n.t('dashboardHello')}', style: const TextStyle(color: Color(0xFF6B7280))),
    ],
  );
  final actions = Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _styleSwitch(ref, l10n, style),
      if (showPos) ...[
        const SizedBox(width: 10),
        FilledButton.icon(
          onPressed: () => context.go('/pos'),
          icon: const Icon(Icons.point_of_sale, size: 18),
          label: Text(l10n.t('openPos')),
        ),
      ],
    ],
  );
  return LayoutBuilder(
    builder: (context, box) {
      if (box.maxWidth < 620) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [title, const SizedBox(height: 12), actions]);
      }
      return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Expanded(child: title), actions]);
    },
  );
}

Widget _styleSwitch(WidgetRef ref, L10n l10n, String style) {
  Widget choice(String value, String label) {
    final selected = style == value;
    return Material(
      color: selected ? _teal : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: selected ? null : () => ref.read(dashboardStyleProvider.notifier).set(value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(color: selected ? Colors.white : _ink, fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
      ),
    );
  }

  return Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFD0D5DD)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        choice('overview', l10n.t('dashboardOverview')),
        choice('modules', l10n.t('dashboardModules')),
      ],
    ),
  );
}

Widget _moduleGrid(BuildContext context, L10n l10n) {
  final main = [
    _Launch(l10n.t('pos'), FontAwesomeIcons.cashRegister, const Color(0xFF14804A), '/pos'),
    _Launch(l10n.t('products'), FontAwesomeIcons.box, const Color(0xFFF97316), '/products'),
    _Launch(l10n.t('manufacturing'), FontAwesomeIcons.industry, const Color(0xFF0F766E), '/manufacturing'),
    _Launch(l10n.t('stock'), FontAwesomeIcons.warehouse, const Color(0xFF2563EB), '/stock'),
    _Launch(l10n.t('purchases'), FontAwesomeIcons.fileInvoice, const Color(0xFF0D9488), '/purchases'),
    _Launch(l10n.t('recentSales'), FontAwesomeIcons.receipt, const Color(0xFF1D4ED8), '/sales'),
    _Launch(l10n.t('estimates'), FontAwesomeIcons.clipboardList, const Color(0xFF0F766E), '/sales/estimates'),
    _Launch(l10n.t('saleOrders'), FontAwesomeIcons.fileLines, const Color(0xFF16A34A), '/sales/orders'),
    _Launch(l10n.t('reports'), FontAwesomeIcons.chartColumn, const Color(0xFF7C3AED), '/reports'),
    _Launch(l10n.t('customers'), FontAwesomeIcons.userGroup, const Color(0xFFBE185D), '/parties'),
    _Launch(l10n.t('expenses'), FontAwesomeIcons.moneyBillWave, const Color(0xFFC2410C), '/expenses'),
    _Launch(l10n.t('investment'), FontAwesomeIcons.buildingColumns, const Color(0xFF0F766E), '/investment'),
    _Launch(l10n.t('roznamcha'), FontAwesomeIcons.book, const Color(0xFFB45309), '/roznamcha'),
    _Launch(l10n.t('cheques'), FontAwesomeIcons.moneyCheck, const Color(0xFF0D9488), '/cheques'),
    _Launch(l10n.t('hr'), FontAwesomeIcons.userTie, const Color(0xFF7C3AED), '/hr/employees'),
    _Launch(l10n.t('settings'), FontAwesomeIcons.gear, const Color(0xFF1E293B), '/settings'),
  ];
  final management = [
    _Launch(l10n.t('employees'), FontAwesomeIcons.users, const Color(0xFF6D28D9), '/hr/employees'),
    _Launch(l10n.t('branches'), FontAwesomeIcons.store, const Color(0xFFC2410C), '/branches'),
    _Launch(l10n.t('attendance'), FontAwesomeIcons.calendarCheck, const Color(0xFF0F766E), '/hr/attendance'),
    _Launch(l10n.t('salaries'), FontAwesomeIcons.sackDollar, const Color(0xFF15803D), '/hr/salaries'),
  ];
  Widget grid(List<_Launch> tiles) {
    return LayoutBuilder(
      builder: (context, box) {
        final columns = box.maxWidth >= 1100 ? 4 : (box.maxWidth >= 720 ? 3 : 2);
        return _fillRow(box.maxWidth, columns, 160, 14, [for (var i = 0; i < tiles.length; i++) _LaunchTile(tile: tiles[i], index: i)]);
      },
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      grid(main),
      const SizedBox(height: 22),
      Text(l10n.t('management'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _ink)),
      const SizedBox(height: 12),
      grid(management),
    ],
  );
}

class _Launch {
  const _Launch(this.label, this.icon, this.color, this.path);

  final String label;
  final FaIconData icon;
  final Color color;
  final String path;
}

class _LaunchTile extends StatefulWidget {
  const _LaunchTile({required this.tile, required this.index});

  final _Launch tile;
  final int index;

  @override
  State<_LaunchTile> createState() => _LaunchTileState();
}

class _LaunchTileState extends State<_LaunchTile> with SingleTickerProviderStateMixin {
  bool _hover = false;
  bool _down = false;
  bool _focus = false;
  late final AnimationController _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(milliseconds: 35 * widget.index), () {
      if (mounted) _enter.forward();
    });
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tile = widget.tile;
    final lit = _hover || _focus;
    final fade = CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(fade),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: AnimatedScale(
            scale: _down ? 0.97 : 1,
            duration: const Duration(milliseconds: 90),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(0, lit ? -4 : 0, 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: tile.color.withValues(alpha: lit ? 0.36 : 0.16),
                    blurRadius: lit ? 22 : 12,
                    offset: Offset(0, lit ? 12 : 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.go(tile.path),
                  onHighlightChanged: (value) => setState(() => _down = value),
                  onFocusChange: (value) => setState(() => _focus = value),
                  splashColor: Colors.white.withValues(alpha: 0.22),
                  highlightColor: Colors.white.withValues(alpha: 0.08),
                  child: Ink(
                    height: 128,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.lerp(tile.color, Colors.white, lit ? 0.18 : 0.10)!,
                          tile.color,
                          Color.lerp(tile.color, Colors.black, 0.14)!,
                        ],
                      ),
                      border: Border.all(color: _focus ? Colors.white : Colors.white.withValues(alpha: 0.22), width: _focus ? 2 : 1),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          top: -24,
                          child: Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.10)),
                          ),
                        ),
                        Positioned.fill(
                          child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedScale(
                                scale: lit ? 1.08 : 1,
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOut,
                                child: Container(
                                  width: 52,
                                  height: 52,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.22),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.55), width: 1.4),
                                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 3))],
                                  ),
                                  child: FaIcon(tile.icon, color: Colors.white, size: 20),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                tile.label,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14, height: 1.15),
                              ),
                            ],
                          ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _split({required double wideBreak, required double height, required Widget left, required Widget right, double? stackedRightHeight}) {
  return LayoutBuilder(
    builder: (context, box) {
      if (box.maxWidth < wideBreak) {
        return Column(
          children: [
            SizedBox(height: height, child: left),
            const SizedBox(height: 14),
            SizedBox(height: stackedRightHeight ?? height, child: right),
          ],
        );
      }
      return SizedBox(
        height: height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 3, child: left),
            const SizedBox(width: 14),
            Expanded(flex: 2, child: right),
          ],
        ),
      );
    },
  );
}

Widget _statCard(String label, String value, FaIconData icon, Color color, double today, double yesterday, L10n l10n, {VoidCallback? onTap}) {
  final String trend;
  final Color trendColor;
  final IconData? arrow;
  if (yesterday == 0) {
    trend = today > 0 ? 'New today' : 'No sales yet';
    trendColor = today > 0 ? _green : _muted;
    arrow = today > 0 ? Icons.trending_up : null;
  } else {
    final change = (today - yesterday) / yesterday * 100;
    trend = '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%';
    trendColor = change >= 0 ? _green : _red;
    arrow = change >= 0 ? Icons.trending_up : Icons.trending_down;
  }
  return _HoverCard(
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(10)),
              child: FaIcon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _muted, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, maxLines: 1, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: _ink)),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            if (arrow != null) ...[Icon(arrow, size: 15, color: trendColor), const SizedBox(width: 4)],
            Flexible(
              child: Text.rich(
                TextSpan(
                  text: trend,
                  style: TextStyle(color: trendColor, fontWeight: FontWeight.w700),
                  children: [
                    if (yesterday != 0) TextSpan(text: ' ${l10n.t('vsYesterday')}', style: const TextStyle(color: _muted, fontWeight: FontWeight.w500)),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _dashPanel({required String title, String? subtitle, Widget? action, required Widget child}) {
  return _HoverCard(
    padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _ink),
                  ),
                  if (subtitle != null) Text(subtitle, style: const TextStyle(color: _muted, fontSize: 12)),
                ],
              ),
            ),
            ?action,
          ],
        ),
        const SizedBox(height: 10),
        Expanded(child: child),
      ],
    ),
  );
}

/// White card that lifts and gets a teal border on hover or keyboard focus.
class _HoverCard extends StatefulWidget {
  const _HoverCard({required this.child, this.onTap, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _hover = false;
  bool _focus = false;

  @override
  Widget build(BuildContext context) {
    final lit = _hover || _focus;
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: widget.padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _focus ? _teal : (_hover ? const Color(0xFF99F6E4) : _line), width: _focus ? 1.4 : 1),
        boxShadow: lit ? const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))] : const [],
      ),
      child: widget.child,
    );
    return FocusableActionDetector(
      onShowHoverHighlight: (value) => setState(() => _hover = value),
      onShowFocusHighlight: (value) => setState(() => _focus = value),
      enabled: widget.onTap != null,
      mouseCursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      actions: {if (widget.onTap != null) ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => widget.onTap!())},
      child: widget.onTap == null ? card : GestureDetector(onTap: widget.onTap, child: card),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.days, required this.totals, required this.symbol});

  final List<DateTime> days;
  final List<double> totals;
  final String symbol;

  static const _names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final top = totals.fold<double>(0, math.max);
    final maxY = top <= 0 ? 1000.0 : top * 1.25;
    final weekTotal = totals.fold<double>(0, (sum, value) => sum + value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Fixed.rs(weekTotal, symbol),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _teal),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: 6,
              minY: 0,
              maxY: maxY,
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: maxY / 4,
                getDrawingHorizontalLine: (value) => const FlLine(color: _line, strokeWidth: 1, dashArray: [4, 4]),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    interval: maxY / 4,
                    getTitlesWidget: (value, meta) => SideTitleWidget(
                      meta: meta,
                      child: Text(_compactMoney(value), style: const TextStyle(color: _muted, fontSize: 11)),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final index = value.round();
                      if (index < 0 || index >= days.length || value != index.toDouble()) return const SizedBox.shrink();
                      final isToday = index == days.length - 1;
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          isToday ? 'Today' : _names[days[index].weekday - 1],
                          style: TextStyle(color: isToday ? _teal : _muted, fontSize: 12, fontWeight: isToday ? FontWeight.w800 : FontWeight.w500),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                handleBuiltInTouches: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (spot) => _ink,
                  getTooltipItems: (spots) => [
                    for (final spot in spots) LineTooltipItem('${_isoDay(days[spot.x.round()])}\n${Fixed.rs(spot.y, symbol)}', const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [for (var i = 0; i < totals.length; i++) FlSpot(i.toDouble(), totals[i])],
                  isCurved: true,
                  preventCurveOverShooting: true,
                  color: _teal,
                  barWidth: 3,
                  dotData: FlDotData(
                    getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(radius: 4, color: Colors.white, strokeWidth: 2.5, strokeColor: _teal),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_teal.withValues(alpha: 0.28), _teal.withValues(alpha: 0.02)]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TopProducts extends ConsumerWidget {
  const _TopProducts({required this.sales, required this.products, required this.symbol});

  final List<Map<String, dynamic>> sales;
  final List<ProductRow> products;
  final String symbol;

  static List<(String, double, double)> rank(List<Map<String, dynamic>> sales, List<ProductRow> products) {
    final names = {for (final product in products) product.clientUuid: product.nameEn};
    final totals = <String, (String, double, double)>{};
    for (final sale in sales) {
      final lines = sale['lines'];
      if (lines is! List) continue;
      for (final raw in lines.whereType<Map>()) {
        final uuid = raw['product_client_uuid']?.toString() ?? '';
        final name = (raw['name']?.toString().isNotEmpty ?? false) ? raw['name'].toString() : (names[uuid] ?? 'Item');
        final key = uuid.isNotEmpty ? uuid : 'quick:${name.toLowerCase()}';
        final sign = raw['is_return'] == true ? -1 : 1;
        final qty = Fixed.n(raw['qty']) * sign;
        final revenue = (Fixed.n(raw['qty']) * Fixed.n(raw['unit_price']) - Fixed.n(raw['discount'])) * sign;
        final previous = totals[key];
        totals[key] = (name, (previous?.$2 ?? 0) + qty, (previous?.$3 ?? 0) + revenue);
      }
    }
    return totals.values.where((row) => row.$3 > 0).toList()..sort((a, b) => b.$3.compareTo(a.$3));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final ranked = rank(sales, products);
    if (ranked.isEmpty) {
      return Center(
        child: Text(l10n.t('noRecords'), style: const TextStyle(color: _muted)),
      );
    }
    final best = ranked.first.$3;
    return ListView.separated(
      itemCount: math.min(6, ranked.length),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final row = ranked[index];
        return Row(
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: index == 0 ? _teal : const Color(0xFFF0FDFA),
              child: Text(
                '${index + 1}',
                style: TextStyle(color: index == 0 ? Colors.white : _teal, fontWeight: FontWeight.w800, fontSize: 12),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          row.$1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700, color: _ink),
                        ),
                      ),
                      Text(
                        Fixed.rs(row.$3, symbol),
                        style: const TextStyle(fontWeight: FontWeight.w800, color: _ink),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('${_trimQty(row.$2)} ${l10n.t('unitsSold')}', style: const TextStyle(color: _muted, fontSize: 12)),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: row.$3 / best, minHeight: 6, color: _teal, backgroundColor: const Color(0xFFF0FDFA)),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

String _trimQty(double value) => value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(2);

class _RecentTransactions extends ConsumerWidget {
  const _RecentTransactions({required this.sales, required this.symbol});

  final List<Map<String, dynamic>> sales;
  final String symbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    if (sales.isEmpty) {
      return Center(
        child: Text(l10n.t('noRecords'), style: const TextStyle(color: _muted)),
      );
    }
    const head = TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w700);
    return LayoutBuilder(
      builder: (context, box) {
        final compact = box.maxWidth < 560;
        return Column(
          children: [
            if (!compact)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text(l10n.t('invoice'), style: head)),
                    Expanded(flex: 3, child: Text(l10n.t('customerName'), style: head)),
                    Expanded(flex: 2, child: Text(l10n.t('method'), style: head)),
                    Expanded(flex: 2, child: Text(l10n.t('status'), style: head)),
                    Expanded(
                      flex: 2,
                      child: Text(l10n.t('amount'), style: head, textAlign: TextAlign.right),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(l10n.t('time'), style: head, textAlign: TextAlign.right),
                    ),
                  ],
                ),
              ),
            const Divider(height: 1, color: _line),
            Expanded(
              child: ListView.separated(
                itemCount: sales.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: _line),
                itemBuilder: (context, index) {
                  final row = sales[index];
                  final status = _saleStatus(l10n, row);
                  final customer = (row['party_name']?.toString().isNotEmpty ?? false) ? row['party_name'].toString() : l10n.t('walkIn');
                  final method = l10n.t(row['payment_method']?.toString() ?? 'cash');
                  final badge = Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: status.$2.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      status.$1,
                      style: TextStyle(color: status.$2, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  );
                  final time = _ago(_saleTime(row));
                  return InkWell(
                    onTap: () => context.go('/sales'),
                    hoverColor: const Color(0xFFF0FDFA),
                    focusColor: const Color(0xFFCCFBF1),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      child: compact
                          ? Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        customer,
                                        style: const TextStyle(fontWeight: FontWeight.w700, color: _ink),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          badge,
                                          const SizedBox(width: 6),
                                          Text(method, style: const TextStyle(color: _muted, fontSize: 12)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      Fixed.rs(row['total'], symbol),
                                      style: const TextStyle(fontWeight: FontWeight.w800, color: _ink),
                                    ),
                                    Text(time, style: const TextStyle(color: _muted, fontSize: 12)),
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    row['invoice_no']?.toString() ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w600, color: _ink),
                                  ),
                                ),
                                Expanded(flex: 3, child: Text(customer, overflow: TextOverflow.ellipsis)),
                                Expanded(flex: 2, child: Text(method)),
                                Expanded(
                                  flex: 2,
                                  child: Align(alignment: Alignment.centerLeft, child: badge),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    Fixed.rs(row['total'], symbol),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(fontWeight: FontWeight.w800, color: _ink),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    time,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(color: _muted, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InventoryAlerts extends ConsumerWidget {
  const _InventoryAlerts({required this.products, required this.balances, required this.branch});

  final List<ProductRow> products;
  final List<BalanceRow> balances;
  final String? branch;

  static List<(ProductRow, double, double, int)> collect(List<ProductRow> products, List<BalanceRow> balances, String? branch) {
    final alerts = <(ProductRow, double, double, int)>[];
    for (final product in products.where((row) => row.trackStock && row.isActive)) {
      final qty = balances
          .where((row) => row.productClientUuid == product.clientUuid && (branch == null || row.branchClientUuid == branch))
          .fold<double>(0, (sum, row) => sum + Fixed.n(row.qtyOnHand));
      final alert = Fixed.n(product.alertQty);
      final level = qty <= 0
          ? 0
          : alert > 0 && qty <= alert / 2
          ? 1
          : alert > 0 && qty <= alert
          ? 2
          : 3;
      if (level < 3) alerts.add((product, qty, alert, level));
    }
    return alerts..sort((a, b) => a.$4 != b.$4 ? a.$4.compareTo(b.$4) : a.$2.compareTo(b.$2));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final alerts = collect(products, balances, branch);
    if (alerts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, color: _green, size: 34),
            SizedBox(height: 8),
            Text('All stock levels are healthy', style: TextStyle(color: _muted)),
          ],
        ),
      );
    }
    return ListView.separated(
      itemCount: alerts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final (product, qty, alert, level) = alerts[index];
        final (label, color, icon) = switch (level) {
          0 => (l10n.t('outOfStock'), _red, Icons.error_outline),
          1 => (l10n.t('critical'), const Color(0xFFC2410C), Icons.priority_high),
          _ => (l10n.t('lowStock'), _amber, Icons.warning_amber_rounded),
        };
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: color, width: 4)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.nameEn,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, color: _ink),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(value: alert > 0 ? (qty / alert).clamp(0.0, 1.0) : 0, minHeight: 5, color: color, backgroundColor: color.withValues(alpha: 0.15)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    label,
                    style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                  Text('${_trimQty(qty)}${alert > 0 ? ' / ${_trimQty(alert)}' : ''}', style: const TextStyle(color: _muted, fontSize: 12)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickSalePanel extends ConsumerStatefulWidget {
  const _QuickSalePanel();

  @override
  ConsumerState<_QuickSalePanel> createState() => _QuickSalePanelState();
}

class _QuickSalePanelState extends ConsumerState<_QuickSalePanel> {
  final _search = TextEditingController();
  final _cart = <String, double>{};
  String? _category;
  bool _busy = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _add(ProductRow product, [double by = 1]) {
    final next = (_cart[product.clientUuid] ?? 0) + by;
    setState(() {
      if (next <= 0) {
        _cart.remove(product.clientUuid);
      } else {
        _cart[product.clientUuid] = next;
      }
    });
  }

  Future<void> _checkout(List<ProductRow> products, double total) async {
    final l10n = ref.read(l10nProvider);
    final branch = _currentBranch(ref);
    if (_cart.isEmpty || _busy) return;
    if (branch == null) {
      _toast(context, l10n.t('noRecords'));
      return;
    }
    setState(() => _busy = true);
    final byId = {for (final product in products) product.clientUuid: product};
    await ref.read(storeProvider).postStock('sale', {
      'branch_client_uuid': branch,
      'party_name': '',
      'party_client_uuid': '',
      'invoice_no': 'S-${DateTime.now().millisecondsSinceEpoch}',
      'payment_method': 'cash',
      'paid': total,
      'order_discount': 0,
      'tax': 0,
      'total': total,
      'lines': [
        for (final entry in _cart.entries)
          if (byId[entry.key] != null)
            {
              'name': byId[entry.key]!.nameEn,
              'product_client_uuid': entry.key,
              'qty': entry.value,
              'unit_price': Fixed.n(byId[entry.key]!.salePrice),
              'discount': 0,
              'is_return': false,
              'unit_cost': Fixed.n(byId[entry.key]!.purchasePrice),
            },
      ],
    }, operatorName: ref.read(sessionProvider).value?.name);
    if (!mounted) return;
    setState(() {
      _cart.clear();
      _busy = false;
    });
    _toast(context, '${l10n.t('saleSaved')} · ${Fixed.rs(total, ref.read(moneySymbolProvider))}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final symbol = ref.watch(moneySymbolProvider);
    final products = (ref.watch(_products).value ?? <ProductRow>[]).where((row) => row.isActive).toList();
    final categories = ref.watch(_categories).value ?? <CategoryRow>[];
    final query = _search.text.trim().toLowerCase();
    final visible = products.where((row) {
      if (_category != null && row.categoryClientUuid != _category) return false;
      if (query.isEmpty) return true;
      return row.nameEn.toLowerCase().contains(query) || row.nameUr.toLowerCase().contains(query) || row.code.toLowerCase().contains(query) || (row.barcode ?? '').toLowerCase().contains(query);
    }).toList();
    final byId = {for (final product in products) product.clientUuid: product};
    final lines = _cart.entries.where((entry) => byId.containsKey(entry.key)).toList();
    final total = lines.fold<double>(0, (sum, entry) => sum + entry.value * Fixed.n(byId[entry.key]!.salePrice));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const FaIcon(FontAwesomeIcons.bolt, size: 16, color: _teal),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.t('quickSale'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _ink),
                ),
              ),
              TextButton(onPressed: () => context.go('/pos'), child: Text(l10n.t('openPos'))),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _search,
            decoration: InputDecoration(hintText: '${l10n.t('search')} / Barcode...', prefixIcon: const Icon(Icons.search), isDense: true),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) {
              if (visible.isNotEmpty) _add(visible.first);
              _search.clear();
              setState(() {});
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(label: Text(l10n.t('allCategories')), selected: _category == null, selectedColor: const Color(0xFFCCFBF1), onSelected: (_) => setState(() => _category = null)),
                ),
                for (final category in categories)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(category.nameEn),
                      selected: _category == category.clientUuid,
                      selectedColor: const Color(0xFFCCFBF1),
                      onSelected: (_) => setState(() => _category = _category == category.clientUuid ? null : category.clientUuid),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            flex: 5,
            child: visible.isEmpty
                ? Center(
                    child: Text(l10n.t('noRecords'), style: const TextStyle(color: _muted)),
                  )
                : ListView.builder(
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final product = visible[index];
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        hoverColor: const Color(0xFFF0FDFA),
                        focusColor: const Color(0xFFCCFBF1),
                        title: Text(
                          product.nameEn,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(product.code, style: const TextStyle(color: _muted, fontSize: 12)),
                        trailing: Text(
                          Fixed.rs(product.salePrice, symbol),
                          style: const TextStyle(fontWeight: FontWeight.w700, color: _teal),
                        ),
                        onTap: () => _add(product),
                      );
                    },
                  ),
          ),
          const Divider(height: 16, color: _line),
          Row(
            children: [
              Text(
                '${l10n.t('cart')} (${lines.length})',
                style: const TextStyle(fontWeight: FontWeight.w800, color: _ink),
              ),
              const Spacer(),
              if (lines.isNotEmpty)
                TextButton(
                  onPressed: () => setState(_cart.clear),
                  child: Text(l10n.t('clearCart'), style: const TextStyle(color: _red)),
                ),
            ],
          ),
          Expanded(
            flex: 4,
            child: lines.isEmpty
                ? const Center(
                    child: Text('Tap a product to add it', style: TextStyle(color: _muted)),
                  )
                : ListView.builder(
                    itemCount: lines.length,
                    itemBuilder: (context, index) {
                      final product = byId[lines[index].key]!;
                      final qty = lines[index].value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.nameEn,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Less',
                              visualDensity: VisualDensity.compact,
                              onPressed: () => _add(product, -1),
                              icon: const Icon(Icons.remove_circle_outline, size: 20, color: _teal),
                            ),
                            Text(_trimQty(qty), style: const TextStyle(fontWeight: FontWeight.w800)),
                            IconButton(
                              tooltip: 'More',
                              visualDensity: VisualDensity.compact,
                              onPressed: () => _add(product),
                              icon: const Icon(Icons.add_circle_outline, size: 20, color: _teal),
                            ),
                            SizedBox(
                              width: 78,
                              child: Text(
                                Fixed.rs(qty * Fixed.n(product.salePrice), symbol),
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontWeight: FontWeight.w700, color: _ink),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(46), backgroundColor: _teal),
            onPressed: lines.isEmpty || _busy ? null : () => _checkout(products, total),
            child: Text('${l10n.t('checkout')}  ${Fixed.rs(total, symbol)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Walk-in, paid in cash. Use Open POS for credit, returns or discounts.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
