import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/menu/presentation/providers/favorites_provider.dart';
import 'package:sabor_de_casa/features/menu/presentation/providers/menu_provider.dart';
import 'package:sabor_de_casa/features/menu/presentation/widgets/allergen_badge.dart';

class DishDetailScreen extends ConsumerWidget {
  const DishDetailScreen({required this.dishId, super.key});

  final String dishId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dishAsync = ref.watch(dishDetailProvider(dishId));
    final isFavAsync = ref.watch(isFavoriteProvider(dishId));
    final theme = Theme.of(context);

    return Scaffold(
      body: dishAsync.when(
        data: (dish) => CustomScrollView(
          slivers: [
            // App bar con imagen
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  dish.name,
                  style: const TextStyle(
                    shadows: [
                      Shadow(blurRadius: 8),
                    ],
                  ),
                ),
                background: dish.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: dish.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => ColoredBox(
                          color:
                              theme.colorScheme.surfaceContainerHighest,
                        ),
                        errorWidget: (_, __, ___) => ColoredBox(
                          color:
                              theme.colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.restaurant, size: 64),
                        ),
                      )
                    : ColoredBox(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.restaurant, size: 64),
                      ),
              ),
              actions: [
                isFavAsync.when(
                  data: (isFav) => IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : null,
                    ),
                    onPressed: () => ref
                        .read(favoriteToggleProvider.notifier)
                        .toggle(dishId),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Precio + disponibilidad
                  Row(
                    children: [
                      Text(
                        Formatters.price(dish.price),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      if (!dish.isAvailable)
                        Chip(
                          label: Text(
                            'No disponible',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                          side:
                              BorderSide(color: theme.colorScheme.error),
                        )
                      else
                        Chip(
                          avatar:
                              const Icon(Icons.access_time, size: 16),
                          label: Text('${dish.prepTimeMin} min'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Descripción
                  if (dish.description.isNotEmpty) ...[
                    Text(
                      'Descripción',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dish.description,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Alérgenos
                  if (dish.allergens.isNotEmpty) ...[
                    Text(
                      'Alérgenos',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: dish.allergens
                          .map((a) => AllergenBadge(allergen: a))
                          .toList(),
                    ),
                  ],
                ]),
              ),
            ),
          ],
        ),
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(dishDetailProvider(dishId)),
        ),
      ),
    );
  }
}
