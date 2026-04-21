import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/features/cart/presentation/providers/cart_provider.dart';
import 'package:sabor_de_casa/features/cart/presentation/providers/checkout_provider.dart';
import 'package:sabor_de_casa/features/orders/presentation/providers/orders_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _notesCtrl = TextEditingController();
  String _orderType = 'domicilio';
  String _paymentMethod = 'cash';

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(cartItemsProvider);
    final submitState = ref.watch(checkoutSubmitProvider);
    final subtotal = items.fold<double>(
      0,
      (sum, item) => sum + (item.unitPrice * item.quantity),
    );
    final deliveryFee = _orderType == 'domicilio' ? 2.5 : 0.0;
    final total = subtotal + deliveryFee;

    ref.listen(checkoutSubmitProvider, (prev, next) {
      if ((prev?.isLoading ?? false) && next.hasValue) {
        ref.read(cartNotifierProvider.notifier).clearCart();
        ref.invalidate(ordersProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pedido ${next.value!} creado correctamente'),
          ),
        );
        context.goNamed(RouteNames.orders);
      }
      if ((prev?.isLoading ?? false) && next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      }
    });

    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(child: Text('No hay productos en el carrito')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Resumen',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(item.name),
              subtitle: Text('x${item.quantity}'),
              trailing: Text(
                Formatters.price(item.unitPrice * item.quantity),
              ),
            ),
          ),
          const Divider(height: 24),
          DropdownButtonFormField<String>(
            initialValue: _orderType,
            decoration: const InputDecoration(labelText: 'Tipo de pedido'),
            items: const [
              DropdownMenuItem(value: 'domicilio', child: Text('Domicilio')),
              DropdownMenuItem(value: 'recogida', child: Text('Recogida')),
              DropdownMenuItem(value: 'encargo', child: Text('Encargo')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _orderType = value);
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _paymentMethod,
            decoration: const InputDecoration(labelText: 'Método de pago'),
            items: const [
              DropdownMenuItem(value: 'cash', child: Text('Efectivo')),
              DropdownMenuItem(value: 'card', child: Text('Tarjeta')),
              DropdownMenuItem(value: 'online', child: Text('Online')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _paymentMethod = value);
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notas del pedido (opcional)',
            ),
          ),
          const SizedBox(height: 16),
          _AmountLine(label: 'Subtotal', value: Formatters.price(subtotal)),
          _AmountLine(label: 'Envío', value: Formatters.price(deliveryFee)),
          _AmountLine(
            label: 'Total',
            value: Formatters.price(total),
            emphasis: true,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: submitState.isLoading
                ? null
                : () => ref.read(checkoutSubmitProvider.notifier).submit(
                      items: items,
                      orderType: _orderType,
                      notes: _notesCtrl.text,
                      paymentMethod: _paymentMethod,
                    ),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Confirmar pedido'),
          ),
        ],
      ),
    );
  }
}

class _AmountLine extends StatelessWidget {
  const _AmountLine({
    required this.label,
    required this.value,
    this.emphasis = false,
  });

  final String label;
  final String value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final style = emphasis
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            )
        : Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
