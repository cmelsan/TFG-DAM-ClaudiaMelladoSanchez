import 'package:flutter/material.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────

/// Opción de filtro de estado (texto simple).
class FilterOption {
  const FilterOption({required this.label, required this.value});
  final String label;
  final String value;
}

/// Opción de filtro de tipo (con icono).
class TypeChipOption {
  const TypeChipOption({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;
}

// ─────────────────────────────────────────────────────────────────────────────
// FILTER CHIP ROW — estado del pedido
// ─────────────────────────────────────────────────────────────────────────────

/// Fila horizontal de chips de estado.
///
/// Chip activo: fondo [AppTokens.surfaceDark] + texto blanco.
/// Chip inactivo: borde 1.5 px gris + fondo blanco.
///
/// ```dart
/// FilterChipRow(
///   options: statusOptions,
///   selected: 'all',
///   onSelected: (v) => setState(() => _status = v),
/// )
/// ```
class FilterChipRow extends StatelessWidget {
  const FilterChipRow({
    required this.options,
    required this.selected,
    required this.onSelected,
    super.key,
    this.padding,
  });

  final List<FilterOption> options;
  final String selected;
  final ValueChanged<String> onSelected;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final opt = options[i];
          final isActive = opt.value == selected;
          return _FilterChipItem(
            label: opt.label,
            isActive: isActive,
            onTap: () => onSelected(opt.value),
          );
        },
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  const _FilterChipItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppTokens.brandPrimary : cs.surface,
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
          border: Border.all(
            color: isActive ? AppTokens.brandPrimary : cs.outlineVariant,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TYPE CHIP ROW — tipo de pedido con icono
// ─────────────────────────────────────────────────────────────────────────────

/// Fila horizontal de chips de tipo con icono.
///
/// Chip activo: fondo [AppTokens.brandLight] + borde [AppTokens.brandPrimary]
/// + texto [AppTokens.brandDark].
///
/// ```dart
/// TypeChipRow(
///   options: typeOptions,
///   selected: 'all',
///   onSelected: (v) => setState(() => _type = v),
/// )
/// ```
class TypeChipRow extends StatelessWidget {
  const TypeChipRow({
    required this.options,
    required this.selected,
    required this.onSelected,
    super.key,
    this.padding,
  });

  final List<TypeChipOption> options;
  final String selected;
  final ValueChanged<String> onSelected;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final opt = options[i];
          final isActive = opt.value == selected;
          return _TypeChipItem(
            label: opt.label,
            icon: opt.icon,
            isActive: isActive,
            onTap: () => onSelected(opt.value),
          );
        },
      ),
    );
  }
}

class _TypeChipItem extends StatelessWidget {
  const _TypeChipItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppTokens.brandPrimary : cs.surface,
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
          border: Border.all(
            color: isActive ? AppTokens.brandPrimary : cs.outlineVariant,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isActive ? Colors.white : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
