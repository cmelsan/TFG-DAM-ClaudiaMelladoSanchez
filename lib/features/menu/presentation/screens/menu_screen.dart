import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/cart/presentation/providers/cart_provider.dart';
import 'package:sabor_de_casa/features/menu/domain/models/category.dart';
import 'package:sabor_de_casa/features/menu/presentation/providers/categories_provider.dart';
import 'package:sabor_de_casa/features/menu/presentation/providers/daily_special_provider.dart';
import 'package:sabor_de_casa/features/menu/presentation/providers/menu_provider.dart';
import 'package:sabor_de_casa/features/menu/presentation/widgets/daily_special_banner.dart';
import 'package:sabor_de_casa/features/menu/presentation/widgets/dish_card.dart';
import 'package:speech_to_text/speech_to_text.dart';

const _allergenOptions = [
  'Gluten',
  'Lactosa',
  'Huevos',
  'Frutos secos',
  'Pescado',
  'Mariscos',
  'Soja',
  'Mostaza',
];

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  String? _selectedCategoryId;
  late final TextEditingController _searchCtrl;
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _startVoiceSearch() async {
    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (_) => setState(() => _isListening = false),
    );
    if (available) {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            _searchCtrl.text = result.recognizedWords;
            ref
                .read(menuSearchQueryProvider.notifier)
                .setQuery(result.recognizedWords);
            setState(() => _isListening = false);
          }
        },
        localeId: 'es_ES',
      );
    }
  }

  Future<void> _stopVoiceSearch() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final dishesAsync = ref.watch(
      dishesProvider(categoryId: _selectedCategoryId),
    );
    final dailySpecialAsync = ref.watch(todaySpecialProvider);
    final cartCount = ref.watch(cartItemsCountProvider);
    final searchQuery = ref.watch(menuSearchQueryProvider);
    final allergenFilter = ref.watch(menuAllergenFilterProvider);

    // Filtrar localmente
    final filteredDishes = dishesAsync.whenData((dishes) {
      var result = dishes;
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        result = result
            .where(
              (d) =>
                  d.name.toLowerCase().contains(q) ||
                  d.description.toLowerCase().contains(q),
            )
            .toList();
      }
      if (allergenFilter.isNotEmpty) {
        result = result
            .where(
              (d) => allergenFilter.every(
                (a) => !d.allergens
                    .map((x) => x.toLowerCase())
                    .contains(a.toLowerCase()),
              ),
            )
            .toList();
      }
      return result;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú'),
        centerTitle: false,
        actions: [
          if (allergenFilter.isNotEmpty)
            IconButton(
              onPressed: () =>
                  ref.read(menuAllergenFilterProvider.notifier).clear(),
              icon: Badge.count(
                count: allergenFilter.length,
                backgroundColor: Colors.orange,
                child: const Icon(Icons.filter_alt_outlined),
              ),
              tooltip: 'Quitar filtros de alérgenos',
            ),
          IconButton(
            onPressed: () => _showAllergenFilterSheet(context),
            icon: const Icon(Icons.tune_outlined),
            tooltip: 'Filtrar por alérgenos',
          ),
          IconButton(
            onPressed: () => context.pushNamed(RouteNames.cart),
            icon: Badge.count(
              count: cartCount,
              isLabelVisible: cartCount > 0,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            tooltip: 'Carrito',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(categoriesProvider)
            ..invalidate(dishesProvider(categoryId: _selectedCategoryId))
            ..invalidate(todaySpecialProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Búsqueda por texto y voz
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: _isListening
                        ? 'Escuchando...'
                        : '¿Qué te apetece hoy?',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchCtrl.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              ref
                                  .read(menuSearchQueryProvider.notifier)
                                  .clear();
                            },
                          ),
                        IconButton(
                          icon: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            color: _isListening ? Colors.red : null,
                          ),
                          onPressed: _isListening
                              ? _stopVoiceSearch
                              : _startVoiceSearch,
                          tooltip: 'Buscar por voz',
                        ),
                      ],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                  ),
                  onChanged: (value) {
                    ref.read(menuSearchQueryProvider.notifier).setQuery(value);
                  },
                ),
              ),
            ),

            // Plato del día
            SliverToBoxAdapter(
              child: dailySpecialAsync.when(
                data: (data) {
                  if (data == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: DailySpecialBanner(
                      dish: data.dish,
                      discountPercent: data.special.discountPercent,
                      note: data.special.note,
                      onTap: () => context.pushNamed(
                        RouteNames.dishDetail,
                        pathParameters: {'dishId': data.dish.id},
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // Filtro activo de alérgenos
            if (allergenFilter.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.filter_alt,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Sin: ${allergenFilter.join(', ')}',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => ref
                            .read(menuAllergenFilterProvider.notifier)
                            .clear(),
                        child: const Text(
                          'Quitar',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Título categorías
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  'Categorías',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Chips de categorías
            SliverToBoxAdapter(
              child: categoriesAsync.when(
                data: (categories) => _CategoryBar(
                  categories: categories,
                  selectedId: _selectedCategoryId,
                  onSelected: (id) => setState(() => _selectedCategoryId = id),
                ),
                loading: () => const SizedBox(height: 48),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // Título platos
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  searchQuery.isNotEmpty
                      ? 'Resultados para "$searchQuery"'
                      : 'Todos los platos',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Grid de platos (filtrado)
            filteredDishes.when(
              data: (dishes) {
                if (dishes.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 48,
                            color: Colors.black26,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            searchQuery.isNotEmpty
                                ? 'No hay platos para "$searchQuery"'
                                : allergenFilter.isNotEmpty
                                ? 'No hay platos sin esos alérgenos'
                                : 'No hay platos disponibles en esta categoría.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => DishCard(
                        dish: dishes[index],
                        onTap: () => context.pushNamed(
                          RouteNames.dishDetail,
                          pathParameters: {'dishId': dishes[index].id},
                        ),
                        onAddToCart: () {
                          ref
                              .read(cartNotifierProvider.notifier)
                              .addDish(dishes[index]);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${dishes[index].name} añadido al carrito',
                              ),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      childCount: dishes.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 400,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                  ),
                );
              },
              loading: () =>
                  const SliverFillRemaining(child: LoadingIndicator()),
              error: (error, _) => SliverFillRemaining(
                child: ErrorView(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(
                    dishesProvider(categoryId: _selectedCategoryId),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  void _showAllergenFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AllergenFilterSheet(),
    );
  }
}

class _AllergenFilterSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(menuAllergenFilterProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtrar alérgenos (sin)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (active.isNotEmpty)
                TextButton(
                  onPressed: () =>
                      ref.read(menuAllergenFilterProvider.notifier).clear(),
                  child: const Text('Limpiar'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Solo se mostrarán platos que NO contengan los alérgenos seleccionados.',
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _allergenOptions.map((a) {
              final selected = active.contains(a);
              return FilterChip(
                label: Text(a),
                selected: selected,
                onSelected: (_) =>
                    ref.read(menuAllergenFilterProvider.notifier).toggle(a),
                selectedColor: Colors.orange.withValues(alpha: 0.2),
                checkmarkColor: Colors.orange,
                labelStyle: TextStyle(
                  color: selected
                      ? Colors.orange.shade800
                      : const Color(0xFF111111),
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aplicar filtros'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isAllSelected = selectedId == null;
            return FilterChip(
              label: Text(
                'Todos',
                style: TextStyle(
                  color: isAllSelected ? Colors.white : null,
                  fontWeight: isAllSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              selected: isAllSelected,
              onSelected: (_) => onSelected(null),
              selectedColor: AppTokens.brandPrimary,
              showCheckmark: false,
            );
          }
          final category = categories[index - 1];
          final isSelected = selectedId == category.id;
          return FilterChip(
            label: Text(
              category.name,
              style: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            selected: isSelected,
            onSelected: (_) => onSelected(category.id),
            selectedColor: AppTokens.brandPrimary,
            showCheckmark: false,
          );
        },
      ),
    );
  }
}
