import 'package:flutter/material.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';

/// Los 14 alérgenos oficiales de la UE según el Reglamento 1169/2011.
class AllergenInfo {
  const AllergenInfo({required this.id, required this.label});
  final String id;
  final String label;
}

const List<AllergenInfo> kEuAllergens = [
  AllergenInfo(id: 'gluten', label: 'Gluten'),
  AllergenInfo(id: 'crustaceos', label: 'Crustáceos'),
  AllergenInfo(id: 'huevos', label: 'Huevos'),
  AllergenInfo(id: 'pescado', label: 'Pescado'),
  AllergenInfo(id: 'cacahuetes', label: 'Cacahuetes'),
  AllergenInfo(id: 'soja', label: 'Soja'),
  AllergenInfo(id: 'lacteos', label: 'Lácteos'),
  AllergenInfo(id: 'frutos_cascara', label: 'Frutos cáscara'),
  AllergenInfo(id: 'apio', label: 'Apio'),
  AllergenInfo(id: 'mostaza', label: 'Mostaza'),
  AllergenInfo(id: 'sesamo', label: 'Sésamo'),
  AllergenInfo(id: 'sulfitos', label: 'Sulfitos'),
  AllergenInfo(id: 'altramuces', label: 'Altramuces'),
  AllergenInfo(id: 'moluscos', label: 'Moluscos'),
];

/// Widget de chips de alérgenos seleccionables (modo edición) o solo lectura.
class AllergenChips extends StatelessWidget {
  const AllergenChips({
    required this.selected,
    required this.onToggle,
    super.key,
    this.readOnly = false,
  });

  final List<String> selected;

  /// Solo se llama en modo edición. Recibe el id del alérgeno.
  final void Function(String id, {required bool isSelected}) onToggle;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final allergens = readOnly
        ? kEuAllergens.where((a) => selected.contains(a.id)).toList()
        : kEuAllergens;

    if (readOnly && allergens.isEmpty) {
      return const Text(
        'Sin alérgenos',
        style: TextStyle(color: Colors.grey, fontSize: 12),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: allergens.map((a) {
        final isSelected = selected.contains(a.id);
        if (readOnly) {
          return _AllergenBadge(allergen: a);
        }
        return FilterChip(
          label: Text(a.label),
          selected: isSelected,
          onSelected: (v) => onToggle(a.id, isSelected: v),
          selectedColor: AppTokens.brandPrimary.withValues(alpha: 0.2),
          checkmarkColor: AppTokens.brandPrimary,
          labelStyle: TextStyle(
            fontSize: 12,
            color: isSelected
                ? AppTokens.brandPrimary
                : const Color(0xFF111111),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected ? AppTokens.brandPrimary : Colors.grey.shade300,
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
        );
      }).toList(),
    );
  }
}

class _AllergenBadge extends StatelessWidget {
  const _AllergenBadge({required this.allergen});
  final AllergenInfo allergen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTokens.brandPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTokens.brandPrimary.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        allergen.label,
        style: const TextStyle(fontSize: 11, color: Color(0xFF111111)),
      ),
    );
  }
}
