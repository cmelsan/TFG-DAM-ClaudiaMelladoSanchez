import 'package:flutter/material.dart';

/// Mapa de alérgenos con nombre legible e icono.
const _allergenData = <String, ({String label, IconData icon})>{
  'gluten': (label: 'Gluten', icon: Icons.bakery_dining),
  'lactosa': (label: 'Lactosa', icon: Icons.water_drop),
  'huevo': (label: 'Huevo', icon: Icons.egg),
  'pescado': (label: 'Pescado', icon: Icons.set_meal),
  'marisco': (label: 'Marisco', icon: Icons.set_meal),
  'frutos_secos': (label: 'Frutos secos', icon: Icons.forest),
  'soja': (label: 'Soja', icon: Icons.grass),
  'apio': (label: 'Apio', icon: Icons.eco),
  'mostaza': (label: 'Mostaza', icon: Icons.local_florist),
  'sesamo': (label: 'Sésamo', icon: Icons.grain),
  'sulfitos': (label: 'Sulfitos', icon: Icons.science),
  'moluscos': (label: 'Moluscos', icon: Icons.water),
  'altramuces': (label: 'Altramuces', icon: Icons.spa),
  'cacahuete': (label: 'Cacahuete', icon: Icons.circle),
};

class AllergenBadge extends StatelessWidget {
  const AllergenBadge({required this.allergen, super.key});

  final String allergen;

  @override
  Widget build(BuildContext context) {
    final data = _allergenData[allergen.toLowerCase()];
    final label = data?.label ?? allergen;
    final icon = data?.icon ?? Icons.warning_amber;

    return Tooltip(
      message: label,
      child: Chip(
        avatar: Icon(icon, size: 16),
        label: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
