import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/cart/presentation/providers/cart_provider.dart';
import 'package:sabor_de_casa/features/menu/domain/models/category.dart';
import 'package:sabor_de_casa/features/menu/presentation/providers/categories_provider.dart';
import 'package:sabor_de_casa/features/menu/presentation/providers/daily_special_provider.dart';
import 'package:sabor_de_casa/features/menu/presentation/providers/menu_provider.dart';
import 'package:sabor_de_casa/features/menu/presentation/widgets/category_chip.dart';
import 'package:sabor_de_casa/features/menu/presentation/widgets/daily_special_banner.dart';
import 'package:sabor_de_casa/features/menu/presentation/widgets/dish_card.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final dishesAsync = ref.watch(
      dishesProvider(categoryId: _selectedCategoryId),
    );
    final dailySpecialAsync = ref.watch(todaySpecialProvider);
    final cartCount = ref.watch(cartItemsCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú'),
        actions: [
          IconButton(
            onPressed: () => context.pushNamed(RouteNames.cart),
            icon: Badge.count(
              count: cartCount,
              isLabelVisible: cartCount > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            tooltip: 'Carrito',
          ),
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
            // Plato del día
            SliverToBoxAdapter(
              child: dailySpecialAsync.when(
                data: (data) {
                  if (data == null) return const SizedBox.shrink();
                  return DailySpecialBanner(
                    dish: data.dish,
                    discountPercent: data.special.discountPercent,
                    note: data.special.note,
                    onTap: () => context.pushNamed(
                      RouteNames.dishDetail,
                      pathParameters: {'dishId': data.dish.id},
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // Chips de categorías
            SliverToBoxAdapter(
              child: categoriesAsync.when(
                data: (categories) => _CategoryBar(
                  categories: categories,
                  selectedId: _selectedCategoryId,
                  onSelected: (id) =>
                      setState(() => _selectedCategoryId = id),
                ),
                loading: () => const SizedBox(height: 48),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // Grid de platos
            dishesAsync.when(
              data: (dishes) {
                if (dishes.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text('No hay platos disponibles'),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.all(12),
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
                            ),
                          );
                        },
                      ),
                      childCount: dishes.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: LoadingIndicator(),
              ),
              error: (error, _) => SliverFillRemaining(
                child: ErrorView(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(
                    dishesProvider(categoryId: _selectedCategoryId),
                  ),
                ),
              ),
            ),
          ],
        ),
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
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return FilterChip(
              label: const Text('Todos'),
              selected: selectedId == null,
              showCheckmark: false,
              onSelected: (_) => onSelected(null),
            );
          }
          final cat = categories[index - 1];
          return CategoryChip(
            category: cat,
            isSelected: selectedId == cat.id,
            onSelected: (_) => onSelected(
              selectedId == cat.id ? null : cat.id,
            ),
          );
        },
      ),
    );
  }
}
