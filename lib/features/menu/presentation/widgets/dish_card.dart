import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/features/menu/domain/models/dish.dart';
import 'package:sabor_de_casa/features/menu/presentation/providers/favorites_provider.dart';
import 'package:sabor_de_casa/features/menu/presentation/widgets/allergen_badge.dart';

class DishCard extends ConsumerWidget {
  const DishCard({
    required this.dish,
    required this.onTap,
    this.onAddToCart,
    super.key,
  });

  final Dish dish;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavAsync = ref.watch(isFavoriteProvider(dish.id));
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            AspectRatio(
              aspectRatio: 16 / 10,
              child: dish.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: dish.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (_, __, ___) => const _PlaceholderImage(),
                    )
                  : const _PlaceholderImage(),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre + favorito
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dish.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      isFavAsync.when(
                        data: (isFav) => IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : null,
                          ),
                          iconSize: 20,
                          visualDensity: VisualDensity.compact,
                          onPressed: () => ref
                              .read(favoriteToggleProvider.notifier)
                              .toggle(dish.id),
                        ),
                        loading: () => const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),

                  if (dish.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      dish.description,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Precio + disponibilidad
                  Row(
                    children: [
                      Text(
                        Formatters.price(dish.price),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      if (dish.isAvailable && onAddToCart != null)
                        IconButton(
                          onPressed: onAddToCart,
                          icon: const Icon(Icons.add_shopping_cart_outlined),
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Añadir al carrito',
                        ),
                      if (!dish.isAvailable)
                        Chip(
                          label: Text(
                            'Agotado',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                          side: BorderSide(color: theme.colorScheme.error),
                        ),
                    ],
                  ),

                  // Alérgenos
                  if (dish.allergens.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: dish.allergens
                          .map((a) => AllergenBadge(allergen: a))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(
        child: Icon(Icons.restaurant, size: 40),
      ),
    );
  }
}
