import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../core/database.dart';
import '../core/languages.dart';
import 'company_logo.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final session = ref.watch(sessionProvider).value;
    final online = ref.watch(onlineProvider).value ?? true;
    final pending = ref.watch(storeProvider).watchPending();
    final branches = ref.watch(storeProvider).watchBranches();
    final selected = ref.watch(branchProvider);
    final location = GoRouterState.of(context).uri.path;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1100;
        final phone = constraints.maxWidth < 720;
        final compact = phone;
        final sidebar = _Sidebar(location: location, l10n: l10n, iconsOnly: !wide && !phone);
        return CallbackShortcuts(
          bindings: {
            for (final (key, path) in const [
              (LogicalKeyboardKey.digit1, '/dashboard'),
              (LogicalKeyboardKey.digit2, '/pos'),
              (LogicalKeyboardKey.digit3, '/sales'),
              (LogicalKeyboardKey.digit4, '/products'),
              (LogicalKeyboardKey.digit5, '/stock'),
              (LogicalKeyboardKey.digit6, '/parties'),
            ])
              SingleActivator(key, alt: true): () => context.go(path),
          },
          child: Focus(
            autofocus: true,
            child: Scaffold(
              drawer: phone ? Drawer(width: 248, child: sidebar) : null,
              body: Row(
                children: [
                  if (wide) SizedBox(width: 248, child: sidebar),
                  if (!wide && !phone) SizedBox(width: 72, child: sidebar),
                  Expanded(
                    child: Column(
                      children: [
                        Material(
                          color: const Color(0xFF14181F),
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                if (phone)
                                  Builder(
                                    builder: (inner) => IconButton(
                                      tooltip: 'Menu',
                                      onPressed: () => Scaffold.of(inner).openDrawer(),
                                      icon: const Icon(Icons.menu, color: Colors.white),
                                    ),
                                  ),
                                Container(
                                  width: 32,
                                  height: 32,
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const CompanyLogo(size: 26),
                                ),
                                if (!compact) ...[
                                  const SizedBox(width: 8),
                                  const Text(
                                    'POS360',
                                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(width: 16),
                                  Flexible(
                                    child: Text(
                                      wide ? _date() : _shortDate(),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Color(0xFFC5CAD3), fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                StreamBuilder<int>(
                                  stream: pending,
                                  builder: (context, snapshot) {
                                    final count = snapshot.data ?? 0;
                                    final label = !online
                                        ? l10n.t('offline')
                                        : count == 0
                                        ? l10n.t('synced')
                                        : '${l10n.t('pendingSync')} ($count)';
                                    final icon = Icon(online ? Icons.cloud_done_outlined : Icons.cloud_off_outlined, size: 18, color: online ? const Color(0xFF0F766E) : const Color(0xFFB45309));
                                    if (compact) {
                                      return IconButton(
                                        tooltip: label,
                                        onPressed: () => ref.read(storeProvider).flush(),
                                        icon: count == 0 ? icon : Badge(label: Text('$count'), child: icon),
                                      );
                                    }
                                    return ActionChip(
                                      visualDensity: VisualDensity.compact,
                                      backgroundColor: const Color(0xFF1E242E),
                                      side: const BorderSide(color: Color(0xFF2A3140)),
                                      labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                      avatar: icon,
                                      label: Text(label),
                                      onPressed: () => ref.read(storeProvider).flush(),
                                    );
                                  },
                                ),
                                const Spacer(),
                                StreamBuilder<List<BranchRow>>(
                                  stream: branches,
                                  builder: (context, snapshot) {
                                    final rows = snapshot.data ?? [];
                                    final current = rows.any((row) => row.clientUuid == selected) ? selected! : '';
                                    return _BarMenu<String>(
                                      value: current,
                                      onInk: true,
                                      menuWidth: 220,
                                      items: [
                                        DropdownItem(value: '', child: Text(l10n.t('allBranches'))),
                                        for (final row in rows) DropdownItem(value: row.clientUuid, child: Text(row.name)),
                                      ],
                                      onChanged: (value) => ref.read(branchProvider.notifier).select(value == null || value.isEmpty ? null : value),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                _BarMenu<String>(
                                  value: languageByCode(l10n.code)?.code ?? 'en',
                                  onInk: true,
                                  menuWidth: 180,
                                  items: [
                                    for (final language in appLanguages) DropdownItem(value: language.code, child: Text(language.native)),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) ref.read(localeProvider.notifier).set(value);
                                  },
                                ),
                                if ((session?.name ?? '').isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: const Color(0xFF0F766E),
                                    child: Text(
                                      session!.name.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  if (!compact) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      session.name,
                                      style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                                    ),
                                  ],
                                ],
                                const SizedBox(width: 4),
                                IconButton(
                                  tooltip: l10n.t('logout'),
                                  onPressed: () async {
                                    await ref.read(sessionProvider.notifier).logout();
                                    if (context.mounted) context.go('/login');
                                  },
                                  icon: const Icon(Icons.logout, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(child: _pageFade(location, child)),
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
  }

  Widget _pageFade(String location, Widget child) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (current, previous) {
        return Stack(
          fit: StackFit.expand,
          children: [
            for (final outgoing in previous) IgnorePointer(child: outgoing),
            ?current,
          ],
        );
      },
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(begin: const Offset(0, 0.012), end: Offset.zero).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: KeyedSubtree(key: ValueKey(location), child: child),
    );
  }

  String _date() {
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  String _shortDate() {
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${now.day} ${months[now.month - 1]}';
  }
}

class _NavItem {
  const _NavItem(this.icon, this.keyName, this.path, [this.children = const []]);

  final FaIconData icon;
  final String keyName;
  final String path;
  final List<(String, String)> children;

  bool contains(String location) {
    if (location == path || location.startsWith('$path/')) return true;
    return children.any((child) => location == child.$2 || location.startsWith('${child.$2}/'));
  }
}

class _Sidebar extends ConsumerStatefulWidget {
  const _Sidebar({required this.location, required this.l10n, this.iconsOnly = false});

  final String location;
  final dynamic l10n;
  final bool iconsOnly;

  @override
  ConsumerState<_Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<_Sidebar> {
  final Set<String> _open = {};

  @override
  void initState() {
    super.initState();
    _syncOpen();
  }

  @override
  void didUpdateWidget(covariant _Sidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncOpen();
  }

  void _syncOpen() {
    for (final section in _sections) {
      for (final item in section.$2) {
        if (item.children.isNotEmpty && item.contains(widget.location)) _open.add(item.path);
      }
    }
  }

  List<(String?, List<_NavItem>)> get _sections => [
    (null, [const _NavItem(FontAwesomeIcons.gauge, 'dashboard', '/dashboard')]),
    (
      'selling',
      [
        const _NavItem(FontAwesomeIcons.cashRegister, 'pos', '/pos'),
        const _NavItem(FontAwesomeIcons.fileInvoiceDollar, 'sales', '/sales', [
          ('recentSales', '/sales'),
          ('estimates', '/sales/estimates'),
          ('saleOrders', '/sales/orders'),
          ('deliveryNotes', '/sales/deliveries'),
        ]),
        const _NavItem(FontAwesomeIcons.users, 'customers', '/parties', [
          ('customers', '/parties'),
          ('creditRecovery', '/parties/recovery'),
          ('areas', '/parties/areas'),
          ('partyReport', '/reports/party'),
        ]),
      ],
    ),
    (
      'stockPurchases',
      [
        const _NavItem(FontAwesomeIcons.boxOpen, 'products', '/products', [('products', '/products'), ('categories', '/categories'), ('brands', '/brands'), ('units', '/units')]),
        const _NavItem(FontAwesomeIcons.industry, 'manufacturing', '/manufacturing'),
        const _NavItem(FontAwesomeIcons.warehouse, 'stock', '/stock', [
          ('stock', '/stock'),
          ('ledger', '/stock/ledger'),
          ('returnsRegister', '/stock/returns'),
          ('transfers', '/stock/transfer'),
          ('adjustment', '/stock/adjustment'),
          ('writeOff', '/stock/write-off'),
          ('locationMove', '/stock/move'),
        ]),
        const _NavItem(FontAwesomeIcons.truck, 'purchases', '/purchases', [
          ('purchases', '/purchases'),
          ('receivePurchase', '/purchases/receive'),
          ('purchaseOrders', '/purchases/orders'),
          ('returnsRegister', '/purchases/returns'),
        ]),
      ],
    ),
    (
      'money',
      [
        const _NavItem(FontAwesomeIcons.wallet, 'accounts', '/accounts', [('accounts', '/accounts'), ('bankAccounts', '/bank-accounts')]),
        const _NavItem(FontAwesomeIcons.moneyBillWave, 'expenses', '/expenses'),
        const _NavItem(FontAwesomeIcons.bookOpen, 'roznamcha', '/roznamcha', [('roznamcha', '/roznamcha'), ('dailyBook', '/roznamcha/daily-book'), ('dayClose', '/roznamcha/day-close')]),
        const _NavItem(FontAwesomeIcons.piggyBank, 'investment', '/investment'),
        const _NavItem(FontAwesomeIcons.moneyCheck, 'cheques', '/cheques'),
        const _NavItem(FontAwesomeIcons.chartColumn, 'reports', '/reports'),
      ],
    ),
    (
      'team',
      [
        const _NavItem(FontAwesomeIcons.userTie, 'hr', '/hr', [('employees', '/hr/employees'), ('attendance', '/hr/attendance'), ('salaries', '/hr/salaries')]),
        const _NavItem(FontAwesomeIcons.gear, 'settings', '/settings', [('settings', '/settings'), ('paymentMethods', '/settings/payments'), ('branches', '/branches')]),
        const _NavItem(FontAwesomeIcons.userGear, 'users', '/users'),
      ],
    ),
  ];

  bool _selected(String path) {
    final location = widget.location;
    if (location == path) return true;
    if (location.startsWith('$path/new') || location.startsWith('$path/edit')) return true;
    if (path == '/purchases' && location == '/purchases/quick-pay') return true;
    if (path == '/reports' && location.startsWith('/reports/') && !location.startsWith('/reports/party')) return true;
    return false;
  }

  void _go(BuildContext context, String path) {
    context.go(path);
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold?.isDrawerOpen ?? false) Navigator.pop(context);
  }

  static const _accent = Color(0xFF0F766E);
  static const _ink = Color(0xFF1A1D26);
  static const _muted = Color(0xFF6B7280);
  static const _line = Color(0xFFE6E8EE);
  static const _tint = Color(0x140F766E);

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: _line)),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            for (final section in _sections) ...[
              if (section.$1 != null && !widget.iconsOnly)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 16, 4),
                  child: Text(
                    l10n.t(section.$1!).toUpperCase(),
                    style: const TextStyle(color: _muted, fontSize: 11, letterSpacing: 0.8, fontWeight: FontWeight.w700),
                  ),
                ),
              for (final item in section.$2) _entry(context, l10n, item),
            ],
          ],
        ),
      ),
    );
  }

  Widget _entry(BuildContext context, dynamic l10n, _NavItem item) {
    if (widget.iconsOnly) return _iconEntry(context, l10n, item);
    if (item.children.isEmpty) return _link(context, l10n, item.icon, item.keyName, item.path, indent: false);
    final open = _open.contains(item.path);
    final active = item.contains(widget.location);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      child: Column(
        children: [
          ListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: -2),
            minTileHeight: 36,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            hoverColor: _tint,
            splashColor: const Color(0x330F766E),
            tileColor: active ? _tint : null,
            leading: FaIcon(item.icon, size: 15, color: active ? _accent : _muted),
            title: Text(
              l10n.t(item.keyName),
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: active ? _accent : _ink),
            ),
            trailing: Icon(open ? Icons.expand_less : Icons.expand_more, size: 18, color: _muted),
            onTap: () => setState(() => open ? _open.remove(item.path) : _open.add(item.path)),
          ),
          if (open)
            Padding(
              padding: const EdgeInsets.only(left: 22, bottom: 4),
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: Color(0xFFCCFBF1), width: 2)),
                ),
                child: Column(children: [for (final child in item.children) _link(context, l10n, item.icon, child.$1, child.$2, indent: true, showIcon: false)]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _iconEntry(BuildContext context, dynamic l10n, _NavItem item) {
    final active = item.contains(widget.location);
    final icon = FaIcon(item.icon, size: 16, color: active ? _accent : _muted);
    if (item.children.isEmpty) {
      return Tooltip(
        message: l10n.t(item.keyName),
        child: IconButton(onPressed: () => _go(context, item.path), icon: icon),
      );
    }
    return PopupMenuButton<String>(
      tooltip: l10n.t(item.keyName),
      onSelected: (path) => _go(context, path),
      itemBuilder: (_) => [
        for (final child in item.children) PopupMenuItem(value: child.$2, child: Text(l10n.t(child.$1))),
      ],
      child: Padding(padding: const EdgeInsets.all(12), child: icon),
    );
  }

  Widget _link(BuildContext context, dynamic l10n, FaIconData icon, String key, String path, {required bool indent, bool showIcon = true}) {
    final selected = _selected(path);
    return Padding(
      padding: EdgeInsets.fromLTRB(indent ? 8 : 10, 1, 10, 1),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border(left: BorderSide(color: selected ? _accent : Colors.transparent, width: 3)),
        ),
        child: ListTile(
          dense: true,
          visualDensity: const VisualDensity(vertical: -2),
          minTileHeight: 36,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          hoverColor: _tint,
          splashColor: const Color(0x330F766E),
          selected: selected,
          selectedTileColor: _tint,
          selectedColor: _accent,
          leading: showIcon
              ? FaIcon(icon, size: 15, color: selected ? _accent : _muted)
              : Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Icon(Icons.circle, size: 6, color: selected ? _accent : const Color(0xFF94A3B8)),
                ),
          title: Text(
            l10n.t(key),
            style: TextStyle(fontWeight: selected ? FontWeight.w700 : FontWeight.w600, color: selected ? _accent : _ink, fontSize: 13),
          ),
          onTap: () => _go(context, path),
        ),
      ),
    );
  }
}

class _BarMenu<T> extends StatefulWidget {
  const _BarMenu({required this.value, required this.items, required this.onChanged, this.menuWidth, this.onInk = false});

  final T? value;
  final List<DropdownItem<T>> items;
  final ValueChanged<T?> onChanged;
  final double? menuWidth;
  final bool onInk;

  @override
  State<_BarMenu<T>> createState() => _BarMenuState<T>();
}

class _BarMenuState<T> extends State<_BarMenu<T>> {
  late final ValueNotifier<T?> _value = ValueNotifier(widget.value);

  @override
  void didUpdateWidget(covariant _BarMenu<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _value.value = widget.value;
  }

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ink = widget.onInk ? Colors.white : const Color(0xFF1E293B);
    final line = widget.onInk ? const Color(0xFF2A3140) : const Color(0xFFE6E8EE);
    final fill = widget.onInk ? const Color(0xFF1E242E) : Colors.white;
    return DropdownButton2<T>(
      isExpanded: false,
      valueListenable: _value,
      items: widget.items,
      onChanged: widget.onChanged,
      underline: const SizedBox.shrink(),
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ink),
      buttonStyleData: ButtonStyleData(
        height: 36,
        padding: const EdgeInsets.only(left: 12, right: 6),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: line),
        ),
      ),
      iconStyleData: IconStyleData(
        icon: Icon(Icons.keyboard_arrow_down, size: 18, color: ink),
        openMenuIcon: Icon(Icons.keyboard_arrow_up, size: 18, color: ink),
        iconSize: 18,
      ),
      dropdownStyleData: DropdownStyleData(
        width: widget.menuWidth,
        maxHeight: 360,
        elevation: 8,
        offset: const Offset(0, 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE6EBEF)),
        ),
      ),
      menuItemStyleData: MenuItemStyleData(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        selectedMenuItemBuilder: (context, child) {
          return ColoredBox(
            color: const Color(0xFFF0FDFA),
            child: DefaultTextStyle.merge(
              style: const TextStyle(color: Color(0xFF0F766E), fontWeight: FontWeight.w700),
              child: child,
            ),
          );
        },
      ),
    );
  }
}
