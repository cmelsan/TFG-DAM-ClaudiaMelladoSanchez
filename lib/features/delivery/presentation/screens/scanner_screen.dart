import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/core/widgets/status_badge.dart';
import 'package:sabor_de_casa/features/kitchen/data/repositories/employee_orders_repository.dart';
import 'package:sabor_de_casa/features/kitchen/presentation/providers/employee_orders_provider.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();

  // Estado del escaneo
  String? _scannedOrderId;
  bool _isLookingUp = false;
  String? _lookupError;
  Order? _foundOrder;

  // Para evitar procesar el mismo QR dos veces seguidas
  String? _lastProcessed;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw == _lastProcessed) return;

    _lastProcessed = raw;
    setState(() {
      _scannedOrderId = raw;
      _isLookingUp = true;
      _lookupError = null;
      _foundOrder = null;
    });

    try {
      final repo = ref.read(employeeOrdersRepositoryProvider);
      final order = await repo.getOrderForPickup(raw);
      if (!mounted) return;
      setState(() {
        _isLookingUp = false;
        _foundOrder = order;
        if (order == null) {
          _lookupError = 'Pedido no encontrado para el QR escaneado.';
        } else if (order.orderType != 'recogida' && order.orderType != 'encargo') {
          _lookupError =
              'Este QR corresponde a un pedido de tipo "${order.orderType}", '
              'no de recogida.';
          _foundOrder = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLookingUp = false;
        _lookupError = 'Error al buscar el pedido: $e';
      });
    }
  }

  void _reset() {
    setState(() {
      _scannedOrderId = null;
      _isLookingUp = false;
      _lookupError = null;
      _foundOrder = null;
      _lastProcessed = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR de pedido'),
        centerTitle: true,
        actions: [
          if (_scannedOrderId != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Escanear otro',
              onPressed: _reset,
            ),
        ],
      ),
      body: _foundOrder != null
          ? _OrderFoundPanel(
              order: _foundOrder!,
              onReset: _reset,
              onDelivered: () {
                _reset();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pedido marcado como entregado ✓'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            )
          : _ScanPanel(
              controller: _controller,
              isLookingUp: _isLookingUp,
              error: _lookupError,
              onDetect: _onDetect,
              onManualEntry: _showManualEntry,
              onReset: _scannedOrderId != null ? _reset : null,
            ),
    );
  }

  void _showManualEntry() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Introducir ID de pedido'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'UUID del pedido…',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final id = controller.text.trim();
              Navigator.pop(ctx);
              if (id.isNotEmpty) {
                _onDetect(
                  BarcodeCapture(
                    barcodes: [Barcode(rawValue: id)],
                  ),
                );
              }
            },
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Panel de escaneado con cámara
// ─────────────────────────────────────────────────────────────────────────────

class _ScanPanel extends StatelessWidget {
  const _ScanPanel({
    required this.controller,
    required this.isLookingUp,
    required this.error,
    required this.onDetect,
    required this.onManualEntry,
    this.onReset,
  });

  final MobileScannerController controller;
  final bool isLookingUp;
  final String? error;
  final void Function(BarcodeCapture) onDetect;
  final VoidCallback onManualEntry;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    if (isLookingUp) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingIndicator(),
            SizedBox(height: 12),
            Text('Buscando pedido…'),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Cámara — ocupa toda la pantalla en móvil, recuadro centrado en web
        if (!kIsWeb)
          MobileScanner(controller: controller, onDetect: onDetect)
        else
          Center(
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                border: Border.all(color: AppTokens.brandPrimary, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.hardEdge,
              child: MobileScanner(controller: controller, onDetect: onDetect),
            ),
          ),

        // Marco de escaneo en móvil
        if (!kIsWeb) _ScanOverlay(),

        // Panel inferior con instrucciones y botón manual
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black87, Colors.transparent],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            error!,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                        if (onReset != null)
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 18),
                            onPressed: onReset,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else
                  const Text(
                    'Apunta la cámara al QR del pedido',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: onManualEntry,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                  ),
                  icon: const Icon(Icons.keyboard_rounded, size: 16),
                  label: const Text('Introducir ID manualmente'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const side = 260.0;
    final left = (size.width - side) / 2;
    final top = (size.height - side) / 2 - 40;

    return Stack(
      children: [
        // Overlay oscuro con recorte
        ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Colors.black54,
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
              ),
              Positioned(
                left: left,
                top: top,
                child: Container(
                  width: side,
                  height: side,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Esquinas del marco
        Positioned(
          left: left,
          top: top,
          child: const _Corner(alignment: Alignment.topLeft),
        ),
        Positioned(
          left: left + side - 28,
          top: top,
          child: const _Corner(alignment: Alignment.topRight),
        ),
        Positioned(
          left: left,
          top: top + side - 28,
          child: const _Corner(alignment: Alignment.bottomLeft),
        ),
        Positioned(
          left: left + side - 28,
          top: top + side - 28,
          child: const _Corner(alignment: Alignment.bottomRight),
        ),
      ],
    );
  }
}

class _Corner extends StatelessWidget {
  const _Corner({required this.alignment});
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final isLeft = alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;
    final isTop = alignment == Alignment.topLeft || alignment == Alignment.topRight;
    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(
        painter: _CornerPainter(isLeft: isLeft, isTop: isTop),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  _CornerPainter({required this.isLeft, required this.isTop});
  final bool isLeft;
  final bool isTop;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTokens.brandPrimary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final x = isLeft ? 0.0 : size.width;
    final y = isTop ? 0.0 : size.height;
    final dx = isLeft ? size.width : -size.width;
    final dy = isTop ? size.height : -size.height;

    canvas
      ..drawLine(Offset(x, y), Offset(x + dx, y), paint)
      ..drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Panel cuando se encuentra el pedido
// ─────────────────────────────────────────────────────────────────────────────

class _OrderFoundPanel extends ConsumerWidget {
  const _OrderFoundPanel({
    required this.order,
    required this.onReset,
    required this.onDelivered,
  });

  final Order order;
  final VoidCallback onReset;
  final VoidCallback onDelivered;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPendingPayment = order.paymentStatus == 'pending';
    final actionState = ref.watch(employeeOrderActionProvider);
    final isLoading = actionState.isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono + título
          Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.qr_code_2_rounded,
                    color: Colors.green,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'QR verificado',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Tarjeta del pedido
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '#${order.id.substring(0, 8).toUpperCase()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Text(
                      Formatters.price(order.total),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.dateTime(order.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    OrderTypeBadge.fromString(order.orderType),
                    StatusBadge.fromString(order.status),
                    if (isPendingPayment)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          (order.paymentMethod == 'cash')
                              ? 'Efectivo pendiente'
                              : 'TPV pendiente',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                  ],
                ),
                if (order.notes != null && order.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E5E3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Nota: ${order.notes}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Botones de acción
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isLoading
                  ? null
                  : () async {
                      await ref
                          .read(employeeOrderActionProvider.notifier)
                          .markDeliveredAndPaid(order.id);
                      onDelivered();
                    },
              style: FilledButton.styleFrom(
                backgroundColor:
                    isPendingPayment ? Colors.teal : AppTokens.brandPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.done_all_rounded),
              label: Text(
                isPendingPayment ? 'Entregar y cobrar' : 'Marcar como entregado',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('Escanear otro QR'),
            ),
          ),
        ],
      ),
    );
  }
}
