import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/features/cart/domain/models/cart_item.dart';
import 'package:sabor_de_casa/features/cart/presentation/providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(cartNotifierProvider.notifier).clearCart();
            },
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Vaciar carrito',
          ),
        ],
      ),
      body: cartState.when(
        empty: () => _EmptyCart(
          onGoToMenu: () => context.goNamed(RouteNames.menu),
        ),
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
        empty: () => null,
        active: (items, total) => _CartBottomBar(
          total: total,
          onGoCheckout: () {
            ref.read(cartNotifierProvider.notifier).startCheckout('domicilio');
            context.pushNamed(RouteNames.checkout);
          },
        ),
        checkout: (items, total, orderType) => _CartBottomBar(
          total: total,
          ctaLabel: 'Ir al checkout',
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 72,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Tu carrito está vacío',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Añade platos del menú para preparar tu pedido.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onGoToMenu,
              icon: const Icon(Icons.restaurant_menu),
              label: const Text('Ir al menú'),
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
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Chip(
            avatar: const Icon(Icons.shopping_cart_checkout, size: 18),
            label: Text('Tipo de pedido: $orderType'),
          ),
          const SizedBox(height: 12),
          Text(
            'Resumen del carrito',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('x${item.quantity}'),
                  trailing: Text(
                    Formatters.price(item.unitPrice * item.quantity),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total: ${Formatters.price(total)}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Volver al carrito'),
          ),
        ],
      ),
    );
  }
}

class _CartBottomBar extends StatelessWidget {
  const _CartBottomBar({
    required this.total,
    required this.onGoCheckout,
    this.ctaLabel = 'Continuar al checkout',
  });

  final double total;
  final VoidCallback onGoCheckout;
  final String ctaLabel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Total: ${Formatters.price(total)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          FilledButton.icon(
            onPressed: onGoCheckout,
            icon: const Icon(Icons.arrow_forward),
            label: Text(ctaLabel),
          ),
        ],
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
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 72,
                height: 72,
                child: item.imageUrl == null
                    ? ColoredBox(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.fastfood),
                      )
                    : CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => ColoredBox(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.fastfood),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.price(item.unitPrice),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: onDecrement,
                        icon: const Icon(Icons.remove_circle_outline),
                        visualDensity: VisualDensity.compact,
                      ),
                      Text('${item.quantity}'),
                      IconButton(
                        onPressed: onIncrement,
                        icon: const Icon(Icons.add_circle_outline),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Eliminar',
            ),
          ],
        ),
      ),
    );
  }
}
