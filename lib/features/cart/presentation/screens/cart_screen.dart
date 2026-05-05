import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/features/cart/domain/models/cart_item.dart';
import 'package:sabor_de_casa/features/cart/presentation/providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartNotifierProvider);

    return Scaffold(
      backgroundColor: AppTokens.pageBg,
      appBar: AppBar(
        title: const Text('Mi Carrito'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(cartNotifierProvider.notifier).clearCart();
            },
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Vaciar carrito',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: cartState.when(
        empty: () =>
            _EmptyCart(onGoToMenu: () => context.goNamed(RouteNames.menu)),
        active: (items, total) => _ActiveCart(
          items: items,
          total: total,
          onIncrement: (dishId) =>
              ref.read(cartNotifierProvider.notifier).incrementItem(dishId),
          onDecrement: (dishId) =>
              ref.read(cartNotifierProvider.notifier).decrementItem(dishId),
          onRemove: (dishId) =>
              ref.read(cartNotifierProvider.notifier).removeItem(dishId),
        ),
        checkout: (items, total, orderType) => _CheckoutPreview(
          items: items,
          total: total,
          orderType: orderType,
          onBack: () => ref.read(cartNotifierProvider.notifier).backToActive(),
        ),
      ),
      bottomNavigationBar: cartState.when(
        empty: () => const SizedBox.shrink(),
        active: (items, total) => _CartBottomBar(
          total: total,
          onGoCheckout: () => context.pushNamed(RouteNames.checkout),
        ),
        checkout: (items, total, orderType) => _CartBottomBar(
          total: total,
          ctaLabel: 'Confirmar pago',
          onGoCheckout: () => context.pushNamed(RouteNames.checkout),
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onGoToMenu});

  final VoidCallback onGoToMenu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5E3).withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'TU CARRITO ESTÁ VACÍO',
              style: GoogleFonts.bebasNeue(
                fontSize: 30,
                letterSpacing: 1.5,
                color: const Color(0xFF111111),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Añade platos deliciosos del menú para preparar tu pedido.',
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: onGoToMenu,
              child: const Text('Descubrir el menú'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveCart extends StatelessWidget {
  const _ActiveCart({
    required this.items,
    required this.total,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final List<CartItem> items;
  final double total;
  final ValueChanged<String> onIncrement;
  final ValueChanged<String> onDecrement;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _CartItemTile(
          item: item,
          onIncrement: () => onIncrement(item.dishId),
          onDecrement: () => onDecrement(item.dishId),
          onRemove: () => onRemove(item.dishId),
        );
      },
    );
  }
}

class _CheckoutPreview extends StatelessWidget {
  const _CheckoutPreview({
    required this.items,
    required this.total,
    required this.orderType,
    required this.onBack,
  });

  final List<CartItem> items;
  final double total;
  final String orderType;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5E3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shopping_cart_checkout,
                  size: 18,
                  color: Color(0xFF111111),
                ),
                const SizedBox(width: 8),
                Text(
                  'Tipo de pedido: ${orderType.toUpperCase()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111111),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Resumen del carrito',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, index) {
                final item = items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE5E5E3)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${item.quantity}x',
                          style: const TextStyle(
                            color: AppTokens.brandPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.name,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                      Text(
                        Formatters.price(item.unitPrice * item.quantity),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111111),
                ),
              ),
              Text(
                Formatters.price(total),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTokens.brandPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver a editar el carrito'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _CartBottomBar extends StatelessWidget {
  const _CartBottomBar({
    required this.total,
    required this.onGoCheckout,
    this.ctaLabel = 'Ir a pagar',
  });

  final double total;
  final VoidCallback onGoCheckout;
  final String ctaLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  Formatters.price(total),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    color: AppTokens.brandPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: onGoCheckout,
                child: Text(ctaLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E3)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5E3).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: item.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.fastfood, color: Colors.black38),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF111111),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.price(item.unitPrice),
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE5E5E3)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18),
                            onPressed: item.quantity > 1 ? onDecrement : null,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 18),
                            onPressed: onIncrement,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      Formatters.price(item.unitPrice * item.quantity),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTokens.brandPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.black38),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
