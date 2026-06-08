import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/widgets/allergen_chips.dart';
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';
import 'package:sabor_de_casa/features/admin/presentation/widgets/admin_shell.dart';
import 'package:sabor_de_casa/features/menu/domain/models/category.dart';
import 'package:sabor_de_casa/features/menu/domain/models/dish.dart';

const _kPageBg = Color(0xFFF4F6F8);
const _kCardBorder = Color(0xFFEEEEEE);
const _kInk = Color(0xFF1A1A2E);
const _kInkMuted = Color(0xFF6B7280);
const _kInkSoft = Color(0xFF9CA3AF);

bool _canRenderNetworkDishImage(String? rawUrl) {
  final url = rawUrl?.trim();
  if (url == null || url.isEmpty) return false;

  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme) return false;
  if (uri.scheme != 'http' && uri.scheme != 'https') return false;

  final path = uri.path.toLowerCase();
  // Evita formatos que suelen romper en Android/ImageDecoder en runtime.
  if (path.endsWith('.svg') ||
      path.endsWith('.avif') ||
      path.endsWith('.heic') ||
      path.endsWith('.heif') ||
      path.endsWith('.tiff') ||
      path.endsWith('.bmp')) {
    return false;
  }

  return true;
}

enum _DishFilter { all, available, unavailable, offer, seasonal }

class AdminDishesScreen extends ConsumerStatefulWidget {
  const AdminDishesScreen({super.key});

  @override
  ConsumerState<AdminDishesScreen> createState() => _AdminDishesScreenState();
}

class _AdminDishesScreenState extends ConsumerState<AdminDishesScreen> {
  String _search = '';
  _DishFilter _filter = _DishFilter.all;
  String? _catFilter; // null = todas

  @override
  Widget build(BuildContext context) {
    final dishesAsync = ref.watch(adminDishesProvider);
    final categoriesAsync = ref.watch(adminCategoriesProvider);

    return AdminShell(
      title: 'Gestion de platos',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded,
              color: AppTokens.brandPrimary),
          tooltip: 'Actualizar',
          onPressed: () {
            ref
              ..invalidate(adminDishesProvider)
              ..invalidate(adminCategoriesProvider);
          },
        ),
        const SizedBox(width: 8),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => categoriesAsync.whenData(
          (cats) => _openDishForm(context, null, cats),
        ),
        backgroundColor: AppTokens.brandPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo plato'),
      ),
      child: ColoredBox(
        color: _kPageBg,
        child: dishesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_rounded,
                      size: 48, color: AppTokens.danger),
                  const SizedBox(height: 12),
                  Text(
                    'Error al cargar platos',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: _kInk,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$e',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        color: AppTokens.danger, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      ref
                        ..invalidate(adminDishesProvider)
                        ..invalidate(adminCategoriesProvider);
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reintentar'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTokens.brandPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          data: (dishes) {
            final categories = categoriesAsync.valueOrNull ?? const <Category>[];
            final catName = <String, String>{
              for (final c in categories) c.id: c.name,
            };

            final total = dishes.length;
            final available = dishes.where((d) => d.isAvailable).length;
            final offers = dishes.where((d) => d.isOffer).length;
            final seasonal = dishes.where((d) => d.isSeasonal).length;

            // Aplicar filtros
            final filtered = dishes.where((d) {
              if (_catFilter != null && d.categoryId != _catFilter) return false;
              switch (_filter) {
                case _DishFilter.all:
                  break;
                case _DishFilter.available:
                  if (!d.isAvailable) return false;
                case _DishFilter.unavailable:
                  if (d.isAvailable) return false;
                case _DishFilter.offer:
                  if (!d.isOffer) return false;
                case _DishFilter.seasonal:
                  if (!d.isSeasonal) return false;
              }
              if (_search.isNotEmpty &&
                  !d.name.toLowerCase().contains(_search)) {
                return false;
              }
              return true;
            }).toList();

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  sliver: SliverToBoxAdapter(
                    child: _KpiStrip(
                      items: [
                        _Kpi(
                          icon: Icons.restaurant_menu_rounded,
                          color: AppTokens.brandPrimary,
                          label: 'Total platos',
                          value: '$total',
                        ),
                        _Kpi(
                          icon: Icons.check_circle_rounded,
                          color: AppTokens.success,
                          label: 'Disponibles',
                          value: '$available',
                          subtitle: '${total - available} agotados',
                        ),
                        _Kpi(
                          icon: Icons.local_offer_rounded,
                          color: AppTokens.warning,
                          label: 'En oferta',
                          value: '$offers',
                        ),
                        _Kpi(
                          icon: Icons.eco_rounded,
                          color: AppTokens.brandDark,
                          label: 'De temporada',
                          value: '$seasonal',
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                  sliver: SliverToBoxAdapter(
                    child: _ToolbarCard(
                      onSearchChanged: (v) =>
                          setState(() => _search = v.toLowerCase()),
                      filter: _filter,
                      onFilterChanged: (f) => setState(() => _filter = f),
                      categories: categories,
                      selectedCat: _catFilter,
                      onCatChanged: (id) => setState(() => _catFilter = id),
                      onResetAvailability: () =>
                          _confirmResetAvailability(context),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Text(
                          '${filtered.length} ${filtered.length == 1 ? "plato" : "platos"}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: _kInkMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_search.isNotEmpty ||
                            _filter != _DishFilter.all ||
                            _catFilter != null) ...[
                          const SizedBox(width: 10),
                          TextButton.icon(
                            onPressed: () => setState(() {
                              _search = '';
                              _filter = _DishFilter.all;
                              _catFilter = null;
                            }),
                            icon: const Icon(Icons.close_rounded, size: 16),
                            label: const Text('Limpiar filtros'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTokens.brandPrimary,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: dishes.isEmpty
                          ? const _EmptyState(
                              icon: Icons.restaurant_menu_outlined,
                              title: 'No hay platos',
                              subtitle:
                                  'La base de datos no tiene platos registrados.\nPulsa "+ Nuevo plato" para añadir el primero.',
                            )
                          : _EmptyState(
                              icon: Icons.search_off_rounded,
                              title: 'Sin resultados',
                              subtitle: _search.isNotEmpty
                                  ? 'Ningun plato coincide con "$_search".'
                                  : 'No hay platos con estos filtros.',
                            ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 120),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 280,
                        childAspectRatio: 0.78,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          final d = filtered[i];
                          return _DishCard(
                            dish: d,
                            categoryName: catName[d.categoryId] ?? '—',
                            onTap: () => _openDishForm(ctx, d, categories),
                            onDelete: () => _confirmDelete(ctx, ref, d),
                          );
                        },
                        childCount: filtered.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, WidgetRef ref, Dish dish) {
    showDialog<void>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar plato'),
        content: Text('¿Desactivar "${dish.name}"? No se mostrara al cliente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTokens.danger),
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

  Future<void> _confirmResetAvailability(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Restaurar disponibilidad'),
        content: const Text(
          'Marcar todos los platos como disponibles. Util al inicio del servicio.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restaurar todos'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(adminActionProvider.notifier).resetAllDishAvailability();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todos los platos vuelven a estar disponibles'),
          backgroundColor: AppTokens.success,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

// ─── Toolbar (buscador + filtros) ────────────────────────────────────────────

class _ToolbarCard extends StatelessWidget {
  const _ToolbarCard({
    required this.onSearchChanged,
    required this.filter,
    required this.onFilterChanged,
    required this.categories,
    required this.selectedCat,
    required this.onCatChanged,
    required this.onResetAvailability,
  });

  final ValueChanged<String> onSearchChanged;
  final _DishFilter filter;
  final ValueChanged<_DishFilter> onFilterChanged;
  final List<Category> categories;
  final String? selectedCat;
  final ValueChanged<String?> onCatChanged;
  final VoidCallback onResetAvailability;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: _kCardBorder),
        boxShadow: [AppTokens.cardShadow],
      ),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (ctx, c) {
              final wide = c.maxWidth >= 720;
              final search = TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar platos por nombre...',
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: _kInkSoft, size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF8F8FA),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _kCardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _kCardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppTokens.brandPrimary, width: 1.5),
                  ),
                ),
                onChanged: onSearchChanged,
              );
              final catDropdown = Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kCardBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: selectedCat,
                    isExpanded: true,
                    hint: Text(
                      'Todas las categorias',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _kInkMuted,
                      ),
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        child: Text(
                          'Todas las categorias',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: _kInk,
                          ),
                        ),
                      ),
                      for (final c in categories)
                        DropdownMenuItem<String?>(
                          value: c.id,
                          child: Text(
                            c.name,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: _kInk,
                            ),
                          ),
                        ),
                    ],
                    onChanged: onCatChanged,
                  ),
                ),
              );
              final resetBtn = OutlinedButton.icon(
                onPressed: onResetAvailability,
                icon: const Icon(Icons.restart_alt_rounded, size: 18),
                label: const Text('Restaurar disp.'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTokens.brandPrimary,
                  side:
                      const BorderSide(color: AppTokens.brandPrimary),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
              if (wide) {
                return Row(
                  children: [
                    Expanded(flex: 3, child: search),
                    const SizedBox(width: 12),
                    Expanded(flex: 2, child: catDropdown),
                    const SizedBox(width: 12),
                    resetBtn,
                  ],
                );
              }
              return Column(
                children: [
                  search,
                  const SizedBox(height: 10),
                  catDropdown,
                  const SizedBox(height: 10),
                  SizedBox(width: double.infinity, child: resetBtn),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterChip(
                  label: 'Todos',
                  selected: filter == _DishFilter.all,
                  onTap: () => onFilterChanged(_DishFilter.all),
                ),
                _FilterChip(
                  label: 'Disponibles',
                  selected: filter == _DishFilter.available,
                  onTap: () => onFilterChanged(_DishFilter.available),
                ),
                _FilterChip(
                  label: 'Agotados',
                  selected: filter == _DishFilter.unavailable,
                  color: AppTokens.danger,
                  onTap: () => onFilterChanged(_DishFilter.unavailable),
                ),
                _FilterChip(
                  label: 'En oferta',
                  selected: filter == _DishFilter.offer,
                  color: AppTokens.warning,
                  onTap: () => onFilterChanged(_DishFilter.offer),
                ),
                _FilterChip(
                  label: 'Temporada',
                  selected: filter == _DishFilter.seasonal,
                  color: AppTokens.brandDark,
                  onTap: () => onFilterChanged(_DishFilter.seasonal),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color = AppTokens.brandPrimary,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.25),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}

// ─── Dish Card ──────────────────────────────────────────────────────────────

class _DishCard extends ConsumerWidget {
  const _DishCard({
    required this.dish,
    required this.categoryName,
    required this.onTap,
    required this.onDelete,
  });

  final Dish dish;
  final String categoryName;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  Future<void> _quickToggleOffer(BuildContext context, WidgetRef ref) async {
    if (dish.isOffer) {
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
      return;
    }
    final priceCtrl = TextEditingController(
      text: dish.offerPrice?.toString() ?? '',
    );
    final confirmed = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
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
    await ref.read(adminActionProvider.notifier).toggleDishOffer(
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      child: InkWell(
        onTap: onTap,
        onLongPress: onDelete,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
            border: Border.all(color: _kCardBorder),
            boxShadow: [AppTokens.cardShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppTokens.radiusLg),
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 10,
                        child: _canRenderNetworkDishImage(dish.imageUrl)
                          ? CachedNetworkImage(
                              imageUrl: dish.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: const Color(0xFFE5E5E3),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: const Color(0xFFE5E5E3),
                                alignment: Alignment.center,
                                child: const Icon(Icons.image_not_supported,
                                    color: Colors.grey),
                              ),
                            )
                          : Container(
                              color: const Color(0xFFE5E5E3),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.restaurant_rounded,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                    ),
                  ),
                  // Badge categoria
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        categoryName,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Estado disponibilidad
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: dish.isAvailable
                            ? AppTokens.success
                            : AppTokens.danger,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            dish.isAvailable
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dish.isAvailable ? 'Disponible' : 'Agotado',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Toggle oferta
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Material(
                      color: dish.isOffer
                          ? AppTokens.warning
                          : Colors.white.withValues(alpha: 0.9),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _quickToggleOffer(context, ref),
                        child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: Icon(
                            Icons.local_offer_rounded,
                            size: 15,
                            color: dish.isOffer ? Colors.white : _kInkMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (dish.isOffer || dish.isSeasonal) ...[
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          if (dish.isOffer)
                            const _Pill(
                              label: 'Oferta',
                              color: AppTokens.warning,
                            ),
                          if (dish.isSeasonal)
                            const _Pill(
                              label: 'Temporada',
                              color: AppTokens.brandDark,
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      dish.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _kInk,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (dish.isOffer && dish.offerPrice != null) ...[
                          Text(
                            '${dish.offerPrice!.toStringAsFixed(2)} €',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: AppTokens.warning,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${dish.price.toStringAsFixed(2)} €',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: _kInkSoft,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ] else
                          Text(
                            '${dish.price.toStringAsFixed(2)} €',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: AppTokens.brandPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        const Spacer(),
                        const Icon(Icons.timer_outlined,
                            size: 12, color: _kInkSoft),
                        const SizedBox(width: 3),
                        Text(
                          '${dish.prepTimeMin}m',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: _kInkMuted,
                          ),
                        ),
                      ],
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

// ─── Helpers compartidos ────────────────────────────────────────────────────

class _Kpi {
  const _Kpi({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.subtitle,
  });
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String? subtitle;
}

class _KpiStrip extends StatelessWidget {
  const _KpiStrip({required this.items});
  final List<_Kpi> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) {
        final cols = c.maxWidth >= 900
            ? 4
            : c.maxWidth >= 560
                ? 2
                : 1;
        const spacing = 14.0;
        final w = cols == 1
            ? c.maxWidth
            : (c.maxWidth - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final k in items)
              SizedBox(width: w, child: _KpiTile(data: k)),
          ],
        );
      },
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({required this.data});
  final _Kpi data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: _kCardBorder),
        boxShadow: [AppTokens.cardShadow],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: _kInkMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.value,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _kInk,
                    height: 1.05,
                  ),
                ),
                if (data.subtitle != null)
                  Text(
                    data.subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: _kInkSoft,
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

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: _kCardBorder),
      ),
      child: Column(
        children: [
          Icon(icon, size: 56, color: _kInkSoft),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _kInk,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: _kInkMuted),
          ),
        ],
      ),
    );
  }
}

// ─── Form sheet (sin cambios funcionales, estilo conservado) ────────────────

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
    _categoryId = d?.categoryId ??
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
            backgroundColor: AppTokens.danger,
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
          '"${widget.existing!.name}" dejara de mostrarse a los clientes. Puedes reactivarlo mas tarde desde el formulario.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTokens.warning),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false) || !mounted) return;
    setState(() => _saving = true);
    try {
      await ref.read(adminActionProvider.notifier).updateDishAvailability(
            dishId: widget.existing!.id,
            isAvailable: false,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al desactivar: $e'),
            backgroundColor: AppTokens.danger,
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
          '¿Eliminar "${widget.existing!.name}" de la base de datos? Esta accion no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTokens.danger),
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
            backgroundColor: AppTokens.danger,
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
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: _kInk,
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
                            : _canRenderNetworkDishImage(widget.existing?.imageUrl)
                                ? CachedNetworkImage(
                                    imageUrl: widget.existing!.imageUrl!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorWidget: (_, __, ___) => const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
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
                                          'Toca para anadir imagen',
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
                    const _SectionLabel('Categoria *'),
                    _Pad(
                      DropdownButtonFormField<String>(
                        initialValue: _categoryId.isEmpty ? null : _categoryId,
                        decoration: _inputDeco('Selecciona categoria'),
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
                            ? 'Selecciona una categoria'
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
                                  return 'Numero invalido';
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
                                  return 'Numero invalido';
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
                    const _SectionLabel('Descripcion'),
                    _Pad(
                      TextFormField(
                        controller: _description,
                        decoration: _inputDeco('Descripcion del plato...'),
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    const _SectionLabel('Alergenos'),
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
                                style: GoogleFonts.inter(
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
                            color: AppTokens.warning,
                          ),
                          label: const Text(
                            'Desactivar plato',
                            style: TextStyle(color: AppTokens.warning),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTokens.warning),
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
                            color: AppTokens.danger,
                          ),
                          label: const Text(
                            'Eliminar permanentemente',
                            style: TextStyle(color: AppTokens.danger),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTokens.danger),
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
      fillColor: const Color(0xFFF8F8FA),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        borderSide: const BorderSide(color: _kCardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        borderSide: const BorderSide(color: _kCardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
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
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _kInkMuted,
            letterSpacing: 0.5,
          ),
        ),
      );
}

class _Pad extends StatelessWidget {
  const _Pad(this.child);
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: child,
      );
}
