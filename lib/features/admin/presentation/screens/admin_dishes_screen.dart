import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/widgets/allergen_chips.dart';
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';
import 'package:sabor_de_casa/features/admin/presentation/widgets/admin_shell.dart';
import 'package:sabor_de_casa/features/menu/domain/models/category.dart';
import 'package:sabor_de_casa/features/menu/domain/models/dish.dart';

class AdminDishesScreen extends ConsumerStatefulWidget {
  const AdminDishesScreen({super.key});

  @override
  ConsumerState<AdminDishesScreen> createState() => _AdminDishesScreenState();
}

class _AdminDishesScreenState extends ConsumerState<AdminDishesScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final dishesAsync = ref.watch(adminDishesProvider);
    final categoriesAsync = ref.watch(adminCategoriesProvider);

    return AdminShell(
      title: 'Gestión de Platos',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => categoriesAsync.whenData(
          (cats) => _openDishForm(context, null, cats),
        ),
        backgroundColor: AppTokens.brandPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo plato'),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar platos…',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFE5E5E3),
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: dishesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (dishes) {
                final filtered = _search.isEmpty
                    ? dishes
                    : dishes
                          .where((d) => d.name.toLowerCase().contains(_search))
                          .toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'No se encontraron platos',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) => _DishCard(
                    dish: filtered[i],
                    index: i,
                    onTap: () => categoriesAsync.whenData(
                      (cats) => _openDishForm(ctx, filtered[i], cats),
                    ),
                    onDelete: () => _confirmDelete(ctx, ref, filtered[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, WidgetRef ref, Dish dish) {
    showDialog<void>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar plato'),
        content: Text('¿Desactivar "${dish.name}"? No se mostrará al cliente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogCtx);
              ref.read(adminActionProvider.notifier).deleteDish(dish.id);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _DishCard extends ConsumerWidget {
  const _DishCard({
    required this.dish,
    required this.index,
    required this.onTap,
    required this.onDelete,
  });

  final Dish dish;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  Future<void> _quickToggleOffer(BuildContext context, WidgetRef ref) async {
    if (dish.isOffer) {
      // Quitar de oferta directamente
      await ref
          .read(adminActionProvider.notifier)
          .toggleDishOffer(dishId: dish.id, isOffer: false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${dish.name}" quitado de ofertas'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Pedir precio de oferta antes de activar
      final priceCtrl = TextEditingController(
        text: dish.offerPrice?.toString() ?? '',
      );
      final confirmed = await showDialog<double>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Poner en oferta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Precio original: ${dish.price.toStringAsFixed(2)} €',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceCtrl,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Precio de oferta (€)',
                  suffixText: '€',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final v = double.tryParse(priceCtrl.text.trim());
                Navigator.pop(ctx, v);
              },
              child: const Text('Activar oferta'),
            ),
          ],
        ),
      );
      if (confirmed == null || !context.mounted) return;
      await ref
          .read(adminActionProvider.notifier)
          .toggleDishOffer(
            dishId: dish.id,
            isOffer: true,
            offerPrice: confirmed,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '"${dish.name}" en oferta a ${confirmed.toStringAsFixed(2)} €',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: dish.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: dish.imageUrl!,
                            fit: BoxFit.cover,
                          )
                        : const ColoredBox(
                            color: Color(0xFFE5E5E3),
                            child: Center(
                              child: Icon(
                                Icons.restaurant,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                          ),
                  ),
                ),
                // Botón rápido de oferta
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => _quickToggleOffer(context, ref),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: dish.isOffer
                            ? Colors.orange
                            : Colors.white.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.local_offer,
                        size: 16,
                        color: dish.isOffer ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (dish.isOffer || dish.isSeasonal)
                    Wrap(
                      spacing: 4,
                      children: [
                        if (dish.isOffer)
                          const _Badge(
                            label: 'Oferta',
                            color: Colors.orange,
                          ),
                        if (dish.isSeasonal)
                          const _Badge(
                            label: 'Temporada',
                            color: Colors.green,
                          ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Text(
                    dish.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF111111),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${dish.price.toStringAsFixed(2)} €',
                        style: TextStyle(
                          fontSize: 13,
                          color: dish.isOffer
                              ? Colors.grey
                              : AppTokens.brandPrimary,
                          decoration: dish.isOffer
                              ? TextDecoration.lineThrough
                              : null,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (dish.isOffer && dish.offerPrice != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          '${dish.offerPrice!.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.orange,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        dish.isAvailable ? Icons.check_circle : Icons.cancel,
                        size: 14,
                        color: dish.isAvailable ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dish.isAvailable ? 'Disponible' : 'No disponible',
                        style: TextStyle(
                          fontSize: 11,
                          color: dish.isAvailable ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 300.ms, delay: (index * 40).ms)
          .slideY(
            begin: 0.1,
            end: 0,
            duration: 300.ms,
            delay: (index * 40).ms,
          ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

Future<void> _openDishForm(
  BuildContext context,
  Dish? existing,
  List<Category> categories,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _DishFormSheet(existing: existing, categories: categories),
  );
}

class _DishFormSheet extends ConsumerStatefulWidget {
  const _DishFormSheet({required this.existing, required this.categories});

  final Dish? existing;
  final List<Category> categories;

  @override
  ConsumerState<_DishFormSheet> createState() => _DishFormSheetState();
}

class _DishFormSheetState extends ConsumerState<_DishFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _offerPrice;
  late final TextEditingController _description;
  late final TextEditingController _prepTime;
  late String _categoryId;
  late List<String> _allergens;
  late bool _isAvailable;
  late bool _isOffer;
  late bool _isSeasonal;
  Uint8List? _pendingImageBytes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.existing;
    _name = TextEditingController(text: d?.name ?? '');
    _price = TextEditingController(text: d?.price.toString() ?? '');
    _offerPrice = TextEditingController(text: d?.offerPrice?.toString() ?? '');
    _description = TextEditingController(text: d?.description ?? '');
    _prepTime = TextEditingController(text: (d?.prepTimeMin ?? 15).toString());
    _categoryId =
        d?.categoryId ??
        (widget.categories.isNotEmpty ? widget.categories.first.id : '');
    _allergens = List<String>.from(d?.allergens ?? []);
    _isAvailable = d?.isAvailable ?? true;
    _isOffer = d?.isOffer ?? false;
    _isSeasonal = d?.isSeasonal ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _offerPrice.dispose();
    _description.dispose();
    _prepTime.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (xfile == null) return;
    final bytes = await xfile.readAsBytes();
    setState(() => _pendingImageBytes = bytes);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final dish = Dish(
        id: widget.existing?.id ?? '',
        categoryId: _categoryId,
        name: _name.text.trim(),
        price: double.parse(_price.text.trim()),
        offerPrice: _isOffer && _offerPrice.text.trim().isNotEmpty
            ? double.tryParse(_offerPrice.text.trim())
            : null,
        description: _description.text.trim(),
        prepTimeMin: int.tryParse(_prepTime.text.trim()) ?? 15,
        allergens: _allergens,
        isAvailable: _isAvailable,
        isOffer: _isOffer,
        isSeasonal: _isSeasonal,
      );

      final notifier = ref.read(adminActionProvider.notifier);
      String? dishId;

      if (widget.existing == null) {
        final created = await notifier.createDish(dish);
        dishId = created?.id;
      } else {
        await notifier.updateDish(dish);
        dishId = widget.existing!.id;
      }

      final actionState = ref.read(adminActionProvider);
      if (actionState is AsyncError) throw Exception(actionState.error);

      if (_pendingImageBytes != null && dishId != null && dishId.isNotEmpty) {
        await notifier.uploadDishImage(
          dishId: dishId,
          bytes: _pendingImageBytes!,
        );
        final uploadState = ref.read(adminActionProvider);
        if (uploadState is AsyncError) throw Exception(uploadState.error);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deactivateDish() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Desactivar plato'),
        content: Text(
          '"${widget.existing!.name}" dejará de mostrarse a los clientes. Puedes reactivarlo más tarde desde el formulario.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false) || !mounted) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(adminActionProvider.notifier)
          .updateDishAvailability(
            dishId: widget.existing!.id,
            isAvailable: false,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al desactivar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteDish() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar permanentemente'),
        content: Text(
          '¿Eliminar "${widget.existing!.name}" de la base de datos? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false) || !mounted) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(adminActionProvider.notifier)
          .deleteDish(widget.existing!.id);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            controller: scrollCtrl,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        isEdit ? 'Editar plato' : 'Nuevo plato',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _SectionLabel('Imagen'),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFFE5E5E3),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _pendingImageBytes != null
                            ? Image.memory(
                                _pendingImageBytes!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              )
                            : widget.existing?.imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: widget.existing!.imageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              )
                            : const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Toca para añadir imagen',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _SectionLabel('Nombre del plato *'),
                    _Pad(
                      TextFormField(
                        controller: _name,
                        decoration: _inputDeco('Ej. Paella valenciana'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Campo obligatorio'
                            : null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    const _SectionLabel('Categoría *'),
                    _Pad(
                      DropdownButtonFormField<String>(
                        initialValue: _categoryId.isEmpty ? null : _categoryId,
                        decoration: _inputDeco('Selecciona categoría'),
                        items: widget.categories
                            .map<DropdownMenuItem<String>>(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _categoryId = v ?? _categoryId),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Selecciona una categoría'
                            : null,
                      ),
                    ),
                    const _SectionLabel('Precios y tiempo'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _price,
                              decoration: _inputDeco('Precio (€)'),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Obligatorio';
                                }
                                if (double.tryParse(v.trim()) == null) {
                                  return 'Número inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _prepTime,
                              decoration: _inputDeco('Prep. (min)'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _SectionLabel('Etiquetas especiales'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Plato en oferta'),
                            value: _isOffer,
                            activeThumbColor: AppTokens.brandPrimary,
                            onChanged: (v) => setState(() => _isOffer = v),
                          ),
                          if (_isOffer) ...[
                            TextFormField(
                              controller: _offerPrice,
                              decoration: _inputDeco('Precio de oferta (€)'),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (v) {
                                if (!_isOffer) return null;
                                if (v == null || v.trim().isEmpty) {
                                  return 'Introduce precio de oferta';
                                }
                                if (double.tryParse(v.trim()) == null) {
                                  return 'Número inválido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                          ],
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Plato de temporada'),
                            value: _isSeasonal,
                            activeThumbColor: AppTokens.brandPrimary,
                            onChanged: (v) => setState(() => _isSeasonal = v),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Disponible para pedir'),
                        value: _isAvailable,
                        activeThumbColor: AppTokens.brandPrimary,
                        onChanged: (v) => setState(() => _isAvailable = v),
                      ),
                    ),
                    const _SectionLabel('Descripción'),
                    _Pad(
                      TextFormField(
                        controller: _description,
                        decoration: _inputDeco('Descripción del plato…'),
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    const _SectionLabel('Alérgenos'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: AllergenChips(
                        selected: _allergens,
                        onToggle: (id, {required bool isSelected}) {
                          setState(() {
                            if (isSelected) {
                              _allergens.add(id);
                            } else {
                              _allergens.remove(id);
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    _Pad(
                      FilledButton(
                        onPressed: _saving ? null : _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTokens.brandPrimary,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isEdit ? 'Guardar cambios' : 'Crear plato',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    if (isEdit) ...[
                      const SizedBox(height: 4),
                      _Pad(
                        OutlinedButton.icon(
                          onPressed: _saving ? null : _deactivateDish,
                          icon: const Icon(
                            Icons.visibility_off_outlined,
                            color: Colors.orange,
                          ),
                          label: const Text(
                            'Desactivar plato',
                            style: TextStyle(color: Colors.orange),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.orange),
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _Pad(
                        OutlinedButton.icon(
                          onPressed: _saving ? null : _deleteDish,
                          icon: const Icon(
                            Icons.delete_forever_outlined,
                            color: Colors.red,
                          ),
                          label: const Text(
                            'Eliminar permanentemente',
                            style: TextStyle(color: Colors.red),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                    SizedBox(
                      height: MediaQuery.of(context).viewInsets.bottom + 24,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDeco(String hint) => InputDecoration(
  hintText: hint,
  filled: true,
  fillColor: const Color(0xFFE5E5E3),
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppTokens.brandPrimary, width: 1.5),
  ),
);

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.grey,
        letterSpacing: 0.5,
      ),
    ),
  );
}

class _Pad extends StatelessWidget {
  const _Pad(this.child);
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 16), child: child);
}
