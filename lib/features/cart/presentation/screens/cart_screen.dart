import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/features/cart/domain/models/cart_item.dart';
import 'package:sabor_de_casa/features/cart/presentation/providers/cart_provider.dart';

// ─── Breakpoint ───────────────────────────────────────────────────────────────
const _kWebBreakpoint = 880.0;
const _kMaxContent = 1160.0;

String _normalizeImageUrl(String url) {
  final parsed = Uri.tryParse(url);
  if (parsed == null || !parsed.hasAuthority) return url;

  final query = Map<String, String>.from(parsed.queryParameters);
  if (query['fm']?.toLowerCase() == 'avif') {
    query['fm'] = 'jpg';
  }

  if (parsed.host.toLowerCase().contains('images.unsplash.com')) {
    query.remove('auto');
    query['fm'] = 'jpg';
    query.putIfAbsent('fit', () => 'crop');
  }

  return parsed.replace(queryParameters: query).toString();
}

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  void initState() {
    super.initState();
    // En web: si el usuario volvió atrás desde Stripe sin pagar,
    // el carrito estará vacío (la app se reinicia). Restauramos los
    // artículos que guardamos antes de redirigir a Stripe.
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final cartState = ref.read(cartNotifierProvider);
        final isEmpty = cartState.maybeWhen(empty: () => true, orElse: () => false);
        if (isEmpty) {
          ref.read(cartNotifierProvider.notifier).restoreFromPendingOrder();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartNotifierProvider);

    return Scaffold(
      body: Column(
        children: [
          // ── Navbar web ──────────────────────────────────────────────────────
          _CartNavBar(
            hasItems: cartState.maybeWhen(
              active: (items, _) => items.isNotEmpty,
              checkout: (_, __, ___) => true,
              orElse: () => false,
            ),
            onClear: () =>
                ref.read(cartNotifierProvider.notifier).clearCart(),
            onBack: () => context.canPop()
                ? context.pop()
                : context.goNamed(RouteNames.menu),
          ),

          // ── Body ────────────────────────────────────────────────────────────
          Expanded(
            child: cartState.when(
              empty: () => _EmptyCart(
                onGoToMenu: () => context.goNamed(RouteNames.menu),
              ),
              active: (items, total) => _CartBody(
                items: items,
                total: total,
                onIncrement: (id) =>
                    ref.read(cartNotifierProvider.notifier).incrementItem(id),
                onDecrement: (id) =>
                    ref.read(cartNotifierProvider.notifier).decrementItem(id),
                onRemove: (id) =>
                    ref.read(cartNotifierProvider.notifier).removeItem(id),
                onCheckout: () => context.pushNamed(RouteNames.checkout),
              ),
              checkout: (items, total, orderType) => _CartBody(
                items: items,
                total: total,
                orderType: orderType,
                onCheckout: () => context.pushNamed(RouteNames.checkout),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Navbar ───────────────────────────────────────────────────────────────────

class _CartNavBar extends StatelessWidget {
  const _CartNavBar({
    required this.hasItems,
    required this.onClear,
    required this.onBack,
  });

  final bool hasItems;
  final VoidCallback onClear;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kMaxContent),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                InkWell(
                  onTap: onBack,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 15,
                          color: Color(0xFF444444),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Seguir comprando',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF444444),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Mi Carrito',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111111),
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                if (hasItems)
                  TextButton.icon(
                    onPressed: onClear,
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: Text(
                      'Vaciar',
                      style: GoogleFonts.inter(fontSize: 13),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black38,
                    ),
                  )
                else
                  const SizedBox(width: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onGoToMenu});

  final VoidCallback onGoToMenu;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppTokens.brandLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 44,
                color: AppTokens.brandPrimary,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Tu carrito está vacío',
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111111),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Añade platos deliciosos del menú para preparar tu pedido.',
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.black45,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onGoToMenu,
              icon: const Icon(Icons.restaurant_menu_outlined, size: 18),
              label: const Text('Ver el menú'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTokens.brandPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Main body (web / mobile adaptive) ───────────────────────────────────────

class _CartBody extends StatelessWidget {
  const _CartBody({
    required this.items,
    required this.total,
    required this.onCheckout,
    this.orderType,
    this.onIncrement,
    this.onDecrement,
    this.onRemove,
  });

  final List<CartItem> items;
  final double total;
  final String? orderType;
  final VoidCallback onCheckout;
  final ValueChanged<String>? onIncrement;
  final ValueChanged<String>? onDecrement;
  final ValueChanged<String>? onRemove;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _kWebBreakpoint) {
          return _WebCartLayout(
            items: items,
            total: total,
            orderType: orderType,
            onIncrement: onIncrement,
            onDecrement: onDecrement,
            onRemove: onRemove,
            onCheckout: onCheckout,
          );
        }
        return _MobileCartLayout(
          items: items,
          total: total,
          orderType: orderType,
          onIncrement: onIncrement,
          onDecrement: onDecrement,
          onRemove: onRemove,
          onCheckout: onCheckout,
        );
      },
    );
  }
}

// ─── Web: two-column layout ───────────────────────────────────────────────────

class _WebCartLayout extends StatelessWidget {
  const _WebCartLayout({
    required this.items,
    required this.total,
    required this.onCheckout,
    this.orderType,
    this.onIncrement,
    this.onDecrement,
    this.onRemove,
  });

  final List<CartItem> items;
  final double total;
  final String? orderType;
  final VoidCallback onCheckout;
  final ValueChanged<String>? onIncrement;
  final ValueChanged<String>? onDecrement;
  final ValueChanged<String>? onRemove;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kMaxContent),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Lista de productos ───────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Tu pedido',
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111111),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTokens.brandLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${items.length} ${items.length == 1 ? 'plato' : 'platos'}',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTokens.brandDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (orderType != null) ...[
                        const SizedBox(height: 12),
                        _OrderTypeBadge(orderType: orderType!),
                      ],
                      const SizedBox(height: 24),
                      ...items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _CartItemCard(
                            item: item,
                            isWeb: true,
                            onIncrement: onIncrement != null
                                ? () => onIncrement!(item.dishId)
                                : null,
                            onDecrement: onDecrement != null
                                ? () => onDecrement!(item.dishId)
                                : null,
                            onRemove: onRemove != null
                                ? () => onRemove!(item.dishId)
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 32),

                // ── Panel resumen ────────────────────────────────────────────
                SizedBox(
                  width: 360,
                  child: _OrderSummaryPanel(
                    items: items,
                    total: total,
                    onCheckout: onCheckout,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Mobile: single column ────────────────────────────────────────────────────

class _MobileCartLayout extends StatelessWidget {
  const _MobileCartLayout({
    required this.items,
    required this.total,
    required this.onCheckout,
    this.orderType,
    this.onIncrement,
    this.onDecrement,
    this.onRemove,
  });

  final List<CartItem> items;
  final double total;
  final String? orderType;
  final VoidCallback onCheckout;
  final ValueChanged<String>? onIncrement;
  final ValueChanged<String>? onDecrement;
  final ValueChanged<String>? onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (orderType != null) ...[
                _OrderTypeBadge(orderType: orderType!),
                const SizedBox(height: 16),
              ],
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CartItemCard(
                    item: item,
                    isWeb: false,
                    onIncrement: onIncrement != null
                        ? () => onIncrement!(item.dishId)
                        : null,
                    onDecrement: onDecrement != null
                        ? () => onDecrement!(item.dishId)
                        : null,
                    onRemove: onRemove != null
                        ? () => onRemove!(item.dishId)
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        _MobileBottomBar(total: total, onCheckout: onCheckout),
      ],
    );
  }
}

// ─── Order type badge ─────────────────────────────────────────────────────────

class _OrderTypeBadge extends StatelessWidget {
  const _OrderTypeBadge({required this.orderType});

  final String orderType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppTokens.brandLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTokens.brandPrimary.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.shopping_cart_checkout,
            size: 15,
            color: AppTokens.brandDark,
          ),
          const SizedBox(width: 8),
          Text(
            'Tipo de pedido: ${orderType.toUpperCase()}',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTokens.brandDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Order summary panel (web right column) ───────────────────────────────────

class _OrderSummaryPanel extends StatelessWidget {
  const _OrderSummaryPanel({
    required this.items,
    required this.total,
    required this.onCheckout,
  });

  final List<CartItem> items;
  final double total;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final itemCount = items.fold<int>(0, (s, i) => s + i.quantity);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Resumen del pedido',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111111),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 24),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTokens.brandLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${item.quantity}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTokens.brandDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF333333),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    Formatters.price(item.unitPrice * item.quantity),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111111),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFF0F0F0)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal ($itemCount ${itemCount == 1 ? 'artículo' : 'artículos'})',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
              ),
              Text(
                Formatters.price(total),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111111),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gastos de envío',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
              ),
              Text(
                'Gratis',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTokens.brandPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF0F0F0)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111111),
                ),
              ),
              Text(
                Formatters.price(total),
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppTokens.brandPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onCheckout,
            style: FilledButton.styleFrom(
              backgroundColor: AppTokens.brandPrimary,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            child: const Text('Tramitar pedido'),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 13, color: Colors.black38),
              const SizedBox(width: 5),
              Text(
                'Pago 100% seguro',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.black38),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Mobile bottom bar ────────────────────────────────────────────────────────

class _MobileBottomBar extends StatelessWidget {
  const _MobileBottomBar({
    required this.total,
    required this.onCheckout,
  });

  final double total;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  Formatters.price(total),
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppTokens.brandPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: onCheckout,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTokens.brandPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                child: const Text('Tramitar pedido'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Cart item card ───────────────────────────────────────────────────────────

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.isWeb,
    this.onIncrement,
    this.onDecrement,
    this.onRemove,
  });

  final CartItem item;
  final bool isWeb;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final imgSize = isWeb ? 110.0 : 86.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(isWeb ? 20 : 14),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: imgSize,
              height: imgSize,
              child: item.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: _normalizeImageUrl(item.imageUrl!),
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const ColoredBox(
                        color: AppTokens.brandLight,
                        child: Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => const ColoredBox(
                        color: AppTokens.brandLight,
                        child: Center(
                          child: Icon(
                            Icons.restaurant,
                            color: AppTokens.brandPrimary,
                            size: 32,
                          ),
                        ),
                      ),
                    )
                  : const ColoredBox(
                      color: AppTokens.brandLight,
                      child: Center(
                        child: Icon(
                          Icons.restaurant,
                          color: AppTokens.brandPrimary,
                          size: 32,
                        ),
                      ),
                    ),
            ),
          ),

          SizedBox(width: isWeb ? 20 : 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.inter(
                    fontSize: isWeb ? 16 : 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111111),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.price(item.unitPrice),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.black45,
                  ),
                ),
                SizedBox(height: isWeb ? 16 : 12),
                Row(
                  children: [
                    if (onIncrement != null || onDecrement != null)
                      _QuantityStepper(
                        quantity: item.quantity,
                        onIncrement: onIncrement,
                        onDecrement: item.quantity > 1 ? onDecrement : null,
                      )
                    else
                      Text(
                        '× ${item.quantity}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    const Spacer(),
                    Text(
                      Formatters.price(item.unitPrice * item.quantity),
                      style: GoogleFonts.inter(
                        fontSize: isWeb ? 17 : 15,
                        fontWeight: FontWeight.w800,
                        color: AppTokens.brandPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Remove button
          if (onRemove != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded, size: 18),
                color: Colors.black26,
                tooltip: 'Eliminar',
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF5F5F5),
                  minimumSize: const Size(34, 34),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Quantity stepper ─────────────────────────────────────────────────────────

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    this.onIncrement,
    this.onDecrement,
  });

  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(icon: Icons.remove, onTap: onDecrement),
          Container(
            width: 36,
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111111),
              ),
            ),
          ),
          _StepButton(icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 16,
          color: onTap != null ? const Color(0xFF333333) : Colors.black26,
        ),
      ),
    );
  }
}
