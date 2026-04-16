import 'package:flutter/material.dart';
import 'package:sabor_de_casa/features/menu/domain/models/category.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onSelected,
    super.key,
  });

  final Category category;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(category.name),
      selected: isSelected,
      onSelected: onSelected,
      showCheckmark: false,
    );
  }
}
