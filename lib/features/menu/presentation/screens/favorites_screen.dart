import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/cart/presentation/providers/cart_provider.dart';
import 'package:sabor_de_casa/features/menu/presentation/providers/favorites_provider.dart';
import 'package:sabor_de_casa/features/menu/presentation/widgets/dish_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dishesAsync = ref.watch(favoriteDishesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: dishesAsync.when(
        data: (dishes) {
          if (dishes.isEmpty) {
            return const Center(
              child: Text('No tienes platos favoritos todavía'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: dishes.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (_, index) {
              final dish = dishes[index];
              return DishCard(
                dish: dish,
                onTap: () => context.pushNamed(
                  RouteNames.dishDetail,
                  pathParameters: {'dishId': dish.id},
                ),
                onAddToCart: () {
                  ref.read(cartNotifierProvider.notifier).addDish(dish);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${dish.name} añadido al carrito')),
                  );
                },
              );
            },
          );
        },
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(favoriteDishesProvider),
        ),
      ),
    );
  }
}
