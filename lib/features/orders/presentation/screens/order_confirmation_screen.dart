import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order.dart';
import 'package:sabor_de_casa/features/orders/presentation/providers/orders_provider.dart';

const _lottieSuccessUrl =
    'https://assets2.lottiefiles.com/packages/lf20_jfe6woim.json';

/// Pantalla de confirmación de pedido que se muestra después de realizar un
/// pedido con éxito (tanto web como móvil). Cubre todos los tipos de pedido:
/// domicilio, recogida, encargo y mostrador.
class OrderConfirmationScreen extends ConsumerWidget {
  const OrderConfirmationScreen({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: AppTokens.pageBg,
      body: orderAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => Scaffold(
          backgroundColor: AppTokens.pageBg,
          appBar: AppBar(title: const Text('Pedido confirmado')),
          body: ErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(orderDetailProvider(orderId)),
          ),
        ),
        data: (order) => _ConfirmationBody(order: order),
      ),
    );
  }
}

// â”€â”€â”€ Cuerpo principal â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ConfirmationBody extends StatefulWidget {
  const _ConfirmationBody({required this.order});
  final Order order;

  @override
  State<_ConfirmationBody> createState() => _ConfirmationBodyState();
}

class _ConfirmationBodyState extends State<_ConfirmationBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieCtrl;

  @override
  void initState() {
    super.initState();
    _lottieCtrl = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _lottieCtrl.dispose();
    super.dispose();
  }

  // â”€â”€ Helpers según tipo de pedido â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  bool get _showQr =>
      (widget.order.orderType == 'recogida' ||
          widget.order.orderType == 'encargo') &&
      widget.order.status != 'cancelled';

  String get _orderTypeLabel {
    return switch (widget.order.orderType) {
      'domicilio' => 'Pedido a domicilio',
      'recogida' => 'Recogida en local',
      'encargo' => 'Encargo programado',
      'mostrador' => 'Pedido en mostrador',
      _ => 'Pedido',
    };
  }

  IconData get _orderTypeIcon {
    return switch (widget.order.orderType) {
      'domicilio' => Icons.delivery_dining_rounded,
      'recogida' => Icons.store_rounded,
      'encargo' => Icons.schedule_rounded,
      'mostrador' => Icons.point_of_sale_rounded,
      _ => Icons.shopping_bag_rounded,
    };
  }

  String get _mainMessage {
    return switch (widget.order.orderType) {
      'domicilio' =>
        '¡Tu pedido ha sido recibido!\nEstamos preparando tu comida y la llevaremos a tu domicilio.',
      'recogida' =>
        '¡Tu pedido ha sido recibido!\nCuando esté listo, muestra el QR en caja para recogerlo.',
      'encargo' =>
        '¡Tu encargo ha sido registrado!\nTe lo tendremos listo para la fecha indicada. Presenta el QR al recoger.',
      'mostrador' => '¡Pedido registrado!\nEn breve te lo tendremos preparado.',
      _ => '¡Pedido realizado con éxito!',
    };
  }

  String get _estimatedTime {
    return switch (widget.order.orderType) {
      'domicilio' => '~30-45 minutos',
      'recogida' => '~20-30 minutos',
      'encargo' =>
        widget.order.scheduledAt != null
            ? '${Formatters.date(widget.order.scheduledAt!)} a las ${Formatters.time(widget.order.scheduledAt!)}'
            : 'Según lo acordado',
      'mostrador' => 'En breve',
      _ => '',
    };
  }

  /// Mensaje de aviso de notificación, adaptado a plataforma y tipo de pedido.
  String get _notificationMessage {
    if (widget.order.orderType == 'mostrador') return '';
    const via = kIsWeb ? 'un correo electrónico' : 'una notificación';
    return switch (widget.order.orderType) {
      'domicilio' => 'Te enviaremos $via cuando tu pedido esté en camino.',
      'recogida' =>
        'Te enviaremos $via cuando tu pedido esté listo para recoger.',
      'encargo' => 'Te enviaremos $via cuando tu encargo sea confirmado.',
      _ => 'Te enviaremos $via con novedades sobre tu pedido.',
    };
  }

  Color get _notifBgColor =>
      kIsWeb ? Colors.blue.shade50 : Colors.orange.shade50;
  Color get _notifBorderColor =>
      kIsWeb ? Colors.blue.shade200 : Colors.orange.shade200;
  Color get _notifIconColor =>
      kIsWeb ? Colors.blue.shade600 : Colors.orange.shade600;
  Color get _notifTextColor =>
      kIsWeb ? Colors.blue.shade700 : Colors.orange.shade700;
  IconData get _notifIcon =>
      kIsWeb ? Icons.email_outlined : Icons.notifications_outlined;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final shortId = order.id.length >= 8
        ? order.id.substring(0, 8).toUpperCase()
        : order.id.toUpperCase();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // â”€â”€ Animación Lottie â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            SizedBox(
              height: 180,
              child: Lottie.network(
                _lottieSuccessUrl,
                controller: _lottieCtrl,
                onLoaded: (comp) {
                  _lottieCtrl
                    ..duration = comp.duration
                    ..forward();
                },
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.check_circle_rounded,
                  size: 120,
                  color: AppTokens.brandPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // â”€â”€ Título â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Text(
              '¡Pedido Confirmado!',
              style: GoogleFonts.bebasNeue(
                fontSize: 38,
                letterSpacing: 1.5,
                color: const Color(0xFF111111),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Ref. $shortId',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // â”€â”€ Badge tipo de pedido â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTokens.brandPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: AppTokens.brandPrimary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_orderTypeIcon, color: AppTokens.brandPrimary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _orderTypeLabel,
                    style: const TextStyle(
                      color: AppTokens.brandPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // â”€â”€ Mensaje + detalles del pedido â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E5E3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _mainMessage,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Color(0xFF111111),
                    ),
                  ),
                  if (_estimatedTime.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          order.orderType == 'encargo'
                              ? Icons.calendar_today_rounded
                              : Icons.access_time_rounded,
                          size: 18,
                          color: AppTokens.brandPrimary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            order.orderType == 'encargo'
                                ? 'Fecha recogida: $_estimatedTime'
                                : 'Tiempo estimado: $_estimatedTime',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111111),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFE5E5E3)),
                  const SizedBox(height: 16),
                  // Pago
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order.paymentStatus == 'paid'
                            ? 'Total pagado'
                            : 'Total a pagar',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
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
                  if (order.paymentStatus == 'pending') ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          order.paymentMethod == 'cash'
                              ? 'Pago en efectivo al recibir el pedido'
                              : 'Pago pendiente de confirmar',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // â”€â”€ QR para recogida y encargo â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            if (_showQr) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E5E3)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Tu código QR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.orderType == 'encargo'
                          ? 'Presenta este código al recoger tu encargo'
                          : 'Muéstralo en caja para recoger tu pedido',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // Fondo blanco explícito para que el QR se vea bien en
                    // pantallas con modo oscuro o cualquier tema.
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E5E3)),
                      ),
                      child: QrImageView(
                        data: order.id,
                        size: 200,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xFF111111),
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ID: $shortId',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        letterSpacing: 2,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // â”€â”€ Aviso de notificación â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            if (_notificationMessage.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _notifBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _notifBorderColor),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(_notifIcon, color: _notifIconColor, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _notificationMessage,
                        style: TextStyle(
                          fontSize: 13,
                          color: _notifTextColor,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // â”€â”€ Botones de acción â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.goNamed(
                  RouteNames.orderDetail,
                  pathParameters: {'orderId': order.id},
                ),
                icon: const Icon(Icons.receipt_long_rounded),
                label: const Text('Ver detalle del pedido'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTokens.brandPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.goNamed(RouteNames.home),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Volver al menú'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTokens.brandPrimary,
                  side: const BorderSide(color: AppTokens.brandPrimary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Acceso rápido a todos mis pedidos
            TextButton(
              onPressed: () => context.goNamed(RouteNames.orders),
              child: const Text(
                'Ver todos mis pedidos',
                style: TextStyle(color: AppTokens.brandPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
