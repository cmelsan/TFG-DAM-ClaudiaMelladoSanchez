import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/orders/data/repositories/orders_repository.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order_item.dart';
import 'package:sabor_de_casa/features/orders/presentation/providers/orders_provider.dart';

// â”€â”€â”€ Lottie animation URLs (LottieFiles CDN, free) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
const _lottiePreparing =
    'https://assets4.lottiefiles.com/packages/lf20_zyquagfl.json';
const _lottieReady =
    'https://assets5.lottiefiles.com/packages/lf20_jbrw3hcz.json';
const _lottieDelivering =
    'https://assets10.lottiefiles.com/packages/lf20_bd9hbd1y.json';
const _lottieDelivered =
    'https://assets9.lottiefiles.com/packages/lf20_puciaact.json';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));
    final itemsAsync = ref.watch(orderItemsProvider(orderId));

    if (orderAsync.isLoading || itemsAsync.isLoading) {
      return const Scaffold(
        backgroundColor: AppTokens.pageBg,
        body: LoadingIndicator(),
      );
    }

    if (orderAsync.hasError) {
      return Scaffold(
        backgroundColor: AppTokens.pageBg,
        appBar: AppBar(
          title: const Text('Detalle del pedido'),
          centerTitle: true,
        ),
        body: ErrorView(
          message: orderAsync.error.toString(),
          onRetry: () => ref.invalidate(orderDetailProvider(orderId)),
        ),
      );
    }

    if (itemsAsync.hasError) {
      return Scaffold(
        backgroundColor: AppTokens.pageBg,
        appBar: AppBar(
          title: const Text('Detalle del pedido'),
          centerTitle: true,
        ),
        body: ErrorView(
          message: itemsAsync.error.toString(),
          onRetry: () => ref.invalidate(orderItemsProvider(orderId)),
        ),
      );
    }

    final order = orderAsync.value!;
    final items = itemsAsync.value!;

    return Scaffold(
      backgroundColor: AppTokens.pageBg,
      appBar: AppBar(
        title: Text('Pedido #${order.id.substring(0, 6).toUpperCase()}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Descargar ticket',
            onPressed: () => _downloadPdf(context, order, items),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // â”€â”€ Estado con Lottie â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          _StatusCard(order: order),
          const SizedBox(height: 16),

          // â”€â”€ QR de recogida â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          if (_showQr(order)) ...[
            _QrSection(orderId: order.id),
            const SizedBox(height: 16),
          ],

          // â”€â”€ Info del pedido â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          _OrderInfoCard(order: order),
          const SizedBox(height: 24),

          const Text(
            'Tu pedido',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 12),

          // â”€â”€ Lista de productos â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          if (items.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E5E3)),
              ),
              child: const Text('No hay productos asociados a este pedido.'),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E5E3)),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    _OrderItemTile(items[i]),
                    if (i < items.length - 1)
                      const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: Color(0xFFE5E5E3),
                      ),
                  ],
                ],
              ),
            ),

          const SizedBox(height: 16),

          // â”€â”€ Desglose de costes â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E5E3)),
            ),
            child: Column(
              children: [
                _CostRow(
                  label: 'Subtotal',
                  amount: Formatters.price(order.subtotal),
                ),
                const SizedBox(height: 8),
                _CostRow(
                  label: 'Gastos de envío',
                  amount: Formatters.price(order.deliveryFee),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFE5E5E3)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      Formatters.price(order.total),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppTokens.brandPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // â”€â”€ Valoración â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          if (order.status == 'delivered') ...[
            _RatingSection(orderId: order.id),
            const SizedBox(height: 16),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  bool _showQr(Order order) =>
      (order.orderType == 'recogida' || order.orderType == 'encargo') &&
      order.status != 'cancelled' &&
      order.status != 'delivered';

  Future<void> _downloadPdf(
    BuildContext context,
    Order order,
    List<OrderItem> items,
  ) async {
    final pdf = pw.Document()
      ..addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a5,
          margin: const pw.EdgeInsets.all(24),
          build: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'Sabor de Casa',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Ticket del pedido',
                  style: const pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 8),
              _pdfRow('Pedido', '#${order.id.substring(0, 6).toUpperCase()}'),
              _pdfRow('Tipo', _orderTypeLabel(order.orderType)),
              _pdfRow(
                'Fecha',
                '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
              ),
              _pdfRow('Estado', _statusLabel(order.status)),
              pw.SizedBox(height: 12),
              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 8),
              for (final item in items) ...[
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      '${item.quantity}x ${item.dishName ?? "Plato"}',
                      style: const pw.TextStyle(fontSize: 13),
                    ),
                    pw.Text(
                      Formatters.price(item.subtotal),
                      style: const pw.TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
              ],
              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 8),
              _pdfRow('Subtotal', Formatters.price(order.subtotal)),
              _pdfRow('Envío', Formatters.price(order.deliveryFee)),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    Formatters.price(order.total),
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  '¡Gracias por tu pedido!',
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'ticket_${order.id.substring(0, 6).toUpperCase()}.pdf',
    );
  }

  pw.Widget _pdfRow(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 13),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
      ],
    ),
  );
}

// â”€â”€â”€ _StatusCard â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(order.status);
    final lottieUrl = _lottieUrl(order.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E3)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 8),
            child: lottieUrl != null
                ? Lottie.network(
                    lottieUrl,
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                    repeat: true,
                    errorBuilder: (_, __, ___) =>
                        Icon(_statusIcon(order.status), size: 72, color: color),
                  )
                : Icon(_statusIcon(order.status), size: 72, color: color),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(15),
              ),
            ),
            child: Column(
              children: [
                Text(
                  _statusLabel(order.status),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Actualizado: ${_timeString(order.updatedAt)}',
                  style: TextStyle(
                    color: color.withValues(alpha: 0.75),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€ _QrSection â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _QrSection extends StatelessWidget {
  const _QrSection({required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E3)),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_rounded,
                color: AppTokens.brandPrimary,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'Código QR de recogida',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF111111),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          QrImageView(data: orderId, size: 180),
          const SizedBox(height: 12),
          const Text(
            'Muestra este QR al recoger tu pedido',
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€ _OrderInfoCard â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _OrderInfoCard extends StatelessWidget {
  const _OrderInfoCard({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E3)),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Fecha',
            value:
                '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: order.orderType == 'domicilio'
                ? Icons.delivery_dining
                : Icons.store_outlined,
            label: 'Tipo',
            value: _orderTypeLabel(order.orderType),
          ),
          if (order.scheduledAt != null) ...[
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.access_time,
              label: 'Programado para',
              value: _timeString(order.scheduledAt!),
            ),
          ],
          if (order.notes != null && order.notes!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTokens.pageBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notas:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(order.notes!, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// â”€â”€â”€ _RatingSection â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _RatingSection extends ConsumerStatefulWidget {
  const _RatingSection({required this.orderId});
  final String orderId;

  @override
  ConsumerState<_RatingSection> createState() => _RatingSectionState();
}

class _RatingSectionState extends ConsumerState<_RatingSection> {
  @override
  Widget build(BuildContext context) {
    final ratingAsync = ref.watch(orderRatingProvider(widget.orderId));

    return ratingAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (existing) {
        if (existing != null) {
          final stars = existing['rating'] as int? ?? 0;
          final comment = existing['comment'] as String?;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E5E3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: AppTokens.brandPrimary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Tu valoración',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < stars
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: Colors.amber.shade600,
                      size: 28,
                    ),
                  ),
                ),
                if (comment != null && comment.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '"$comment"',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        // No valorado — mostrar CTA
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTokens.brandPrimary.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: AppTokens.brandPrimary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '¿Cómo fue tu pedido?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Tu opinión nos ayuda a mejorar',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _showRatingSheet(context, widget.orderId),
                icon: const Icon(Icons.rate_review_outlined),
                label: const Text('Valorar pedido'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showRatingSheet(BuildContext context, String orderId) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _RatingBottomSheet(orderId: orderId),
    );
    ref.invalidate(orderRatingProvider(orderId));
  }
}

// â”€â”€â”€ _RatingBottomSheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _RatingBottomSheet extends ConsumerStatefulWidget {
  const _RatingBottomSheet({required this.orderId});
  final String orderId;

  @override
  ConsumerState<_RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends ConsumerState<_RatingBottomSheet> {
  int _stars = 0;
  final _commentCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_stars == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos 1 estrella')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await ref
          .read(ordersRepositoryProvider)
          .rateOrder(
            orderId: widget.orderId,
            rating: _stars,
            comment: _commentCtrl.text.trim().isEmpty
                ? null
                : _commentCtrl.text.trim(),
          );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Gracias por tu valoración!'),
            backgroundColor: AppTokens.brandPrimary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5E3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Valora tu pedido',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Estrellas
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (i) => GestureDetector(
                  onTap: () => setState(() => _stars = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      i < _stars
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      size: 44,
                      color: i < _stars
                          ? Colors.amber.shade600
                          : const Color(0xFFE5E5E3),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Comentario
          TextField(
            controller: _commentCtrl,
            maxLines: 3,
            maxLength: 300,
            decoration: InputDecoration(
              hintText: 'Cuéntanos más (opcional)',
              filled: true,
              fillColor: AppTokens.pageBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading ? null : _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Enviar valoración',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// â”€â”€â”€ Small widgets â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 15),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ],
    );
  }
}

class _CostRow extends StatelessWidget {
  const _CostRow({required this.label, required this.amount});
  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black87, fontSize: 15),
        ),
        Text(amount, style: const TextStyle(fontSize: 15)),
      ],
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile(this.item);
  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5E3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${item.quantity}x',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTokens.brandPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.dishName ?? 'Plato',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          Text(
            Formatters.price(item.subtotal),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
String? _lottieUrl(String status) {
  switch (status) {
    case 'preparing':
      return _lottiePreparing;
    case 'ready':
      return _lottieReady;
    case 'delivering':
      return _lottieDelivering;
    case 'delivered':
      return _lottieDelivered;
    default:
      return null;
  }
}

String _timeString(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

String _orderTypeLabel(String value) {
  switch (value) {
    case 'mostrador':
      return 'Mostrador';
    case 'encargo':
      return 'Encargo';
    case 'domicilio':
      return 'A domicilio';
    case 'recogida':
      return 'Recogida en local';
    default:
      return value;
  }
}

String _statusLabel(String value) {
  switch (value) {
    case 'pending':
      return 'Pendiente de confirmación';
    case 'confirmed':
      return 'Pedido confirmado';
    case 'preparing':
      return 'Preparando en cocina...';
    case 'ready':
      return '¡Listo para recoger!';
    case 'delivering':
      return 'En camino a tu dirección';
    case 'delivered':
      return '¡Pedido entregado!';
    case 'cancelled':
      return 'Pedido cancelado';
    default:
      return 'Estado desconocido';
  }
}

IconData _statusIcon(String status) {
  switch (status) {
    case 'pending':
      return Icons.access_time;
    case 'confirmed':
      return Icons.check_circle_outline;
    case 'preparing':
      return Icons.soup_kitchen_outlined;
    case 'ready':
      return Icons.shopping_bag_outlined;
    case 'delivering':
      return Icons.motorcycle_outlined;
    case 'delivered':
      return Icons.where_to_vote_outlined;
    case 'cancelled':
      return Icons.cancel_outlined;
    default:
      return Icons.info_outline;
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'pending':
      return Colors.grey.shade700;
    case 'confirmed':
      return AppTokens.brandPrimary;
    case 'preparing':
      return Colors.orange.shade700;
    case 'ready':
      return Colors.teal;
    case 'delivering':
      return Colors.blue.shade700;
    case 'delivered':
      return AppTokens.brandPrimary;
    case 'cancelled':
      return Colors.red.shade600;
    default:
      return Colors.grey;
  }
}
