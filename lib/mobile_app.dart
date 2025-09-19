import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'pages/orders_page.dart';
import 'cubit/order_cubit.dart';
import 'cubit/order_state.dart';

/// Fixly – Mobile Dashboard (Clean, logical, and responsive)
///
/// ✅ Clear information hierarchy
/// ✅ Sticky filters (statuses) + pull‑to‑refresh
/// ✅ Animated KPIs with safe fallbacks (skeletons)
/// ✅ Solid empty/error states (no surprises)
/// ✅ Pure Flutter responsiveness (no 3rd‑party UI pkgs)
///
class MobileApp extends StatelessWidget {
  const MobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderCubit()..fetchOrdersByStatus(null),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Fixly Mobile - الطلبات',
        theme: _buildTheme(),
        builder: (context, child) {
          final m = MediaQuery.of(context);
          return MediaQuery(
            data:
                m.copyWith(textScaleFactor: m.textScaleFactor.clamp(0.92, 1.2)),
            child: child!,
          );
        },
        home: const MobileHomePage(),
      ),
    );
  }

  ThemeData _buildTheme() {
    const seed = Color(0xFF6366F1);
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
      primary: seed,
      secondary: const Color(0xFF8B5CF6),
      tertiary: const Color(0xFF06B6D4),
      surface: const Color(0xFFFAFAFA),
      background: const Color(0xFFF8FAFC),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.background,
      fontFamily: 'Arial',
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: seed,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
    );
  }
}

class MobileHomePage extends StatelessWidget {
  const MobileHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: RefreshIndicator.adaptive(
        onRefresh: () async =>
            context.read<OrderCubit>().fetchOrdersByStatus(null),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              stretch: true,
              expandedHeight: 140,
              backgroundColor: cs.primary,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.blurBackground,
                  StretchMode.fadeTitle
                ],
                titlePadding:
                    const EdgeInsetsDirectional.only(start: 16, bottom: 14),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.dashboard_rounded,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    const Text('لوحة التحكم',
                        style: TextStyle(letterSpacing: .2)),
                  ],
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [cs.primary, cs.secondary.withOpacity(.9)],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  tooltip: 'تحديث',
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  onPressed: () =>
                      context.read<OrderCubit>().fetchOrdersByStatus(null),
                ),
              ],
            ),

            // KPIs
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: const _KpiRow(),
              ),
            ),

            // Sticky segmented filter
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyHeaderDelegate(
                minExtent: 66,
                maxExtent: 66,
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: _StatusSegmented(
                    onChanged: (status) =>
                        context.read<OrderCubit>().fetchOrdersByStatus(status),
                  ),
                ),
              ),
            ),

            // Optional: quick actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: const _QuickActionsRow(),
              ),
            ),

            // Orders body + resilient states
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: const _OrdersContainer(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.read<OrderCubit>().fetchOrdersByStatus(null),
        icon: const Icon(Icons.refresh_rounded, size: 20),
        label: const Text('تحديث البيانات',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ───────────────────────── KPI Section ─────────────────────────
class _KpiRow extends StatelessWidget {
  const _KpiRow();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 700;

    return BlocBuilder<OrderCubit, OrderState>(
      buildWhen: (p, n) => p.runtimeType != n.runtimeType || n is OrdersLoaded,
      builder: (context, state) {
        if (state is OrdersLoaded) {
          final total = state.orders.length;
          final done = state.orders.where((o) => o.status == 'مكتمل').length;
          final inProgress =
              state.orders.where((o) => o.status == 'قيد التنفيذ').length;
          final canceled = state.orders.where((o) => o.status == 'ملغي').length;

          return Row(
            children: [
              Expanded(
                  child: _KpiCard(
                      title: 'إجمالي',
                      value: total,
                      icon: Icons.receipt_long,
                      color: Colors.indigo,
                      isTablet: isTablet)),
              const SizedBox(width: 10),
              Expanded(
                  child: _KpiCard(
                      title: 'مكتملة',
                      value: done,
                      icon: Icons.check_circle,
                      color: Colors.green,
                      isTablet: isTablet)),
              const SizedBox(width: 10),
              Expanded(
                  child: _KpiCard(
                      title: 'قيد التنفيذ',
                      value: inProgress,
                      icon: Icons.pending_rounded,
                      color: Colors.orange,
                      isTablet: isTablet)),
              const SizedBox(width: 10),
              Expanded(
                  child: _KpiCard(
                      title: 'ملغي',
                      value: canceled,
                      icon: Icons.cancel_rounded,
                      color: Colors.redAccent,
                      isTablet: isTablet)),
            ],
          );
        }

        // Skeletons while loading/initial
        return Row(
          children: const [
            Expanded(child: _KpiSkeleton()),
            SizedBox(width: 10),
            Expanded(child: _KpiSkeleton()),
            SizedBox(width: 10),
            Expanded(child: _KpiSkeleton()),
            SizedBox(width: 10),
            Expanded(child: _KpiSkeleton()),
          ],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;
  final bool isTablet;
  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      borderColor: color.withOpacity(.18),
      tint: color.withOpacity(.05),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 12 : 10),
              decoration: BoxDecoration(
                  color: color.withOpacity(.12),
                  borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: isTablet ? 24 : 22),
            ),
            SizedBox(height: isTablet ? 10 : 8),
            _AnimatedCounter(
              value: value,
              textStyle: TextStyle(
                  fontSize: isTablet ? 21 : 19,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: .3),
            ),
            SizedBox(height: isTablet ? 4 : 2),
            Text(title,
                style: TextStyle(
                    fontSize: isTablet ? 12.5 : 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }
}

class _KpiSkeleton extends StatelessWidget {
  const _KpiSkeleton();
  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      borderColor: Colors.black.withOpacity(.06),
      tint: Colors.black.withOpacity(.03),
      child: const SizedBox(height: 88),
    );
  }
}

class _AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle textStyle;
  const _AnimatedCounter({required this.value, required this.textStyle});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text(v.toInt().toString(), style: textStyle),
    );
  }
}

// ───────────────────────── Sticky Filter ─────────────────────────
class _StatusSegmented extends StatefulWidget {
  final ValueChanged<String?> onChanged;
  const _StatusSegmented({required this.onChanged});
  @override
  State<_StatusSegmented> createState() => _StatusSegmentedState();
}

class _StatusSegmentedState extends State<_StatusSegmented> {
  int selected = 0; // 0: all, 1: done, 2: in progress, 3: canceled
  final items = const [
    ('الكل', null),
    ('مكتمل', 'مكتمل'),
    ('قيد التنفيذ', 'قيد التنفيذ'),
    ('ملغي', 'ملغي'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _GlassCard(
      borderColor: cs.primary.withOpacity(.12),
      tint: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: List.generate(items.length, (i) {
            final (label, value) = items[i];
            final active = selected == i;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color:
                      active ? cs.primary.withOpacity(.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: active ? cs.primary : cs.primary.withOpacity(.16),
                      width: 1.4),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() => selected = i);
                    widget.onChanged(value);
                  },
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                        color: active ? cs.primary : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minExtent;
  final double maxExtent;
  final Widget child;
  _StickyHeaderDelegate(
      {required this.minExtent, required this.maxExtent, required this.child});
  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      child;
  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) => false;
}

// ───────────────────────── Quick Actions ─────────────────────────
class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final actions = const [
      (Icons.add_shopping_cart_rounded, 'طلب جديد'),
      (Icons.qr_code, 'مسح طاولة'),
      (Icons.people_rounded, 'فنيين'),
      (Icons.notifications_active_rounded, 'تنبيهات'),
    ];

    return Row(
      children: actions.map((a) {
        final (icon, label) = a;
        return Expanded(
          child: _GlassCard(
            borderColor: cs.primary.withOpacity(.08),
            tint: Colors.white,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {},
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Column(
                  children: [
                    Icon(icon, color: cs.primary),
                    const SizedBox(height: 6),
                    Text(label,
                        style: const TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        );
      }).expand((w) sync* {
        yield w;
        yield const SizedBox(width: 10);
      }).toList()
        ..removeLast(),
    );
  }
}

// ───────────────────────── Orders Container ─────────────────────────
class _OrdersContainer extends StatelessWidget {
  const _OrdersContainer();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) {
          return _EmptyState(
            title: 'جاري تحميل الطلبات...',
            description: 'من فضلك انتظر حتى يكتمل التحميل',
            icon: Icons.downloading_rounded,
          );
        }
        if (state is OrderError) {
          return _EmptyState(
            title: 'حدث خطأ',
            description: state.message ?? 'تعذر جلب البيانات. حاول مرة أخرى.',
            icon: Icons.error_outline_rounded,
            action: () => context.read<OrderCubit>().fetchOrdersByStatus(null),
            actionLabel: 'إعادة المحاولة',
          );
        }
        if (state is OrdersLoaded && state.orders.isEmpty) {
          return _EmptyState(
            title: 'لا توجد طلبات',
            description: 'ابدأ بإضافة طلب جديد أو حدّث البيانات.',
            icon: Icons.inbox_rounded,
            action: () => context.read<OrderCubit>().fetchOrdersByStatus(null),
            actionLabel: 'تحديث',
          );
        }
        // When data exists: use your existing OrdersPage
        return const OrdersPage();
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? action;
  final String? actionLabel;
  const _EmptyState({
    required this.title,
    required this.description,
    required this.icon,
    this.action,
    this.actionLabel,
  });
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _GlassCard(
      borderColor: cs.primary.withOpacity(.08),
      tint: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        child: Column(
          children: [
            Icon(icon, size: 40, color: cs.primary),
            const SizedBox(height: 10),
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            if (action != null) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                  onPressed: action, child: Text(actionLabel ?? 'حسنًا')),
            ],
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Shared Glass Card ─────────────────────────
class _GlassCard extends StatelessWidget {
  final Widget child;
  final Color tint;
  final Color borderColor;
  const _GlassCard(
      {required this.child, required this.tint, required this.borderColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 12,
              offset: const Offset(0, 5))
        ],
      ),
      child: child,
    );
  }
}
