import 'package:flutter/material.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';

// ─────────────────────────────────────────────────────────────────────────────
// STATUS BADGE
// ─────────────────────────────────────────────────────────────────────────────

/// Badge pill para el estado de un pedido.
///
/// ```dart
/// StatusBadge.fromString('pending')   // → "Pendiente" naranja
/// StatusBadge.fromString('delivered') // → "Entregado" gris
/// ```
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.label,
    required this.fg,
    required this.bg,
    super.key,
  });

  factory StatusBadge.fromString(String status) {
    final (label, fg, bg) = _resolve(status);
    return StatusBadge(label: label, fg: fg, bg: bg);
  }

  final String label;
  final Color fg;
  final Color bg;

  static (String, Color, Color) _resolve(String status) {
    return switch (status.toLowerCase()) {
      'pending' => (
        'Pendiente',
        AppTokens.statusPendiente,
        AppTokens.statusPendienteBg,
      ),
      'confirmed' => (
        'Confirmado',
        AppTokens.statusConfirmado,
        AppTokens.statusConfirmadoBg,
      ),
      'preparing' => (
        'Preparando',
        AppTokens.statusPreparando,
        AppTokens.statusPreparandoBg,
      ),
      'ready' => ('Listo', AppTokens.statusListo, AppTokens.statusListoBg),
      'delivering' => (
        'En reparto',
        AppTokens.statusReparto,
        AppTokens.statusRepartoBg,
      ),
      'delivered' => (
        'Entregado',
        AppTokens.statusEntregado,
        AppTokens.statusEntregadoBg,
      ),
      'cancelled' => (
        'Cancelado',
        AppTokens.statusCancelado,
        AppTokens.statusCanceladoBg,
      ),
      _ => (status, AppTokens.statusEntregado, AppTokens.statusEntregadoBg),
    };
  }

  /// Devuelve solo el color foreground para el dot circular.
  static Color colorFor(String status) => _resolve(status).$2;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ORDER TYPE BADGE
// ─────────────────────────────────────────────────────────────────────────────

/// Badge pill para el tipo de pedido.
///
/// ```dart
/// OrderTypeBadge.fromString('domicilio')
/// OrderTypeBadge.fromString('recogida')
/// ```
class OrderTypeBadge extends StatelessWidget {
  const OrderTypeBadge({
    required this.label,
    required this.fg,
    required this.bg,
    super.key,
  });

  factory OrderTypeBadge.fromString(String type) {
    final (label, fg, bg) = _resolve(type);
    return OrderTypeBadge(label: label, fg: fg, bg: bg);
  }

  final String label;
  final Color fg;
  final Color bg;

  static (String, Color, Color) _resolve(String type) {
    return switch (type.toLowerCase()) {
      'recogida' => (
        'Recogida',
        AppTokens.badgeRecogidaFg,
        AppTokens.badgeRecogidaBg,
      ),
      'domicilio' => (
        'Domicilio',
        AppTokens.badgeDomicilioFg,
        AppTokens.badgeDomicilioBg,
      ),
      'encargo' => (
        'Encargo',
        AppTokens.badgeEncargoFg,
        AppTokens.badgeEncargoBg,
      ),
      'mostrador' => (
        'Mostrador',
        AppTokens.badgeMostradorFg,
        AppTokens.badgeMostradorBg,
      ),
      'delivery' => (
        'Domicilio',
        AppTokens.badgeDomicilioFg,
        AppTokens.badgeDomicilioBg,
      ),
      _ => (type, AppTokens.statusEntregado, AppTokens.statusEntregadoBg),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
