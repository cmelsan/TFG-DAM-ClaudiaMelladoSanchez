import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/widgets/app_surface.dart';
import 'package:sabor_de_casa/core/widgets/status_badge.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────────────────────────────────────────

/// Cabecera de sección en MAYÚSCULAS con lettering sutil.
///
/// ```dart
/// SectionHeader('HISTORIAL')
/// SectionHeader('Platos más pedidos')
/// ```
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.padding});

  final String title;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(0, 0, 0, 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// METRIC CARD
// ─────────────────────────────────────────────────────────────────────────────

/// Card de métrica individual para el dashboard y resúmenes.
///
/// ```dart
/// MetricCard(label: 'Ventas hoy', value: '347 €', valueColor: AppTokens.brandPrimary)
/// ```
class MetricCard extends StatelessWidget {
  const MetricCard({
    required this.label,
    required this.value,
    super.key,
    this.valueColor,
    this.icon,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.grey.shade400),
            const SizedBox(height: 8),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// METRIC ITEM (para DarkSummaryBar)
// ─────────────────────────────────────────────────────────────────────────────

/// Item de métrica para [DarkSummaryBar].
class MetricItem {
  const MetricItem({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;
}

// ─────────────────────────────────────────────────────────────────────────────
// DARK SUMMARY BAR
// ─────────────────────────────────────────────────────────────────────────────

/// Barra de resumen con fondo oscuro y 3 métricas.
///
/// ```dart
/// DarkSummaryBar(items: [
///   MetricItem(label: 'Total gastado', value: '86,50 €'),
///   MetricItem(label: 'Pedidos', value: '6'),
///   MetricItem(label: 'Ticket medio', value: '14,42 €'),
/// ])
/// ```
class DarkSummaryBar extends StatelessWidget {
  const DarkSummaryBar({required this.items, super.key});

  final List<MetricItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTokens.surfaceDark,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0)
                Container(
                  width: 0.5,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              Expanded(child: _MetricItemWidget(items[i])),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricItemWidget extends StatelessWidget {
  const _MetricItemWidget(this.item);
  final MetricItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFFAAAAAA),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          item.value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: item.valueColor ?? Colors.white,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ORDER CARD
// ─────────────────────────────────────────────────────────────────────────────

/// Card reutilizable para mostrar un pedido en listados.
///
/// ```dart
/// OrderCard(
///   orderId: order.id,
///   status: order.status,
///   orderType: order.orderType,
///   price: '28,00 €',
///   relativeTime: 'Hace 5 min',
///   onTap: () => context.push('/orders/${order.id}'),
/// )
/// ```
class OrderCard extends StatelessWidget {
  const OrderCard({
    required this.orderId,
    required this.status,
    required this.orderType,
    required this.price,
    super.key,
    this.relativeTime,
    this.time,
    this.onTap,
  });

  final String orderId;
  final String status;
  final String orderType;
  final String price;
  final String? relativeTime;
  final String? time;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dotColor = StatusBadge.colorFor(status);

    return AppSurface(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            children: [
              // Dot de estado
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              // Centro: ID + type + hora
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${orderId.substring(0, 8).toUpperCase()}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : AppTokens.surfaceDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        OrderTypeBadge.fromString(orderType),
                        if (time != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            time!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Derecha: precio + tiempo relativo
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : AppTokens.surfaceDark,
                    ),
                  ),
                  if (relativeTime != null)
                    Text(
                      relativeTime!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
