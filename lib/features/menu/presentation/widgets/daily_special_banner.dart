import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/features/menu/domain/models/dish.dart';

class DailySpecialBanner extends StatelessWidget {
  const DailySpecialBanner({
    required this.dish,
    required this.onTap,
    super.key,
    this.discountPercent,
    this.note,
  });

  final Dish dish;
  final int? discountPercent;
  final String? note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDiscount = discountPercent != null && discountPercent! > 0;
    final discountedPrice = hasDiscount
        ? dish.price * (1 - discountPercent! / 100)
        : dish.price;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: theme.colorScheme.primaryContainer,
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              // Imagen
              SizedBox(
                width: 100,
                height: 100,
                child: dish.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: dish.imageUrl!,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.restaurant,
                        size: 40,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
              ),
              // Texto
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 18,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Plato del día',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dish.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (note != null && note!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          note!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (hasDiscount) ...[
                            Text(
                              Formatters.price(dish.price),
                              style: theme.textTheme.bodySmall?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: theme.colorScheme.onPrimaryContainer
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            Formatters.price(discountedPrice),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          if (hasDiscount) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '-$discountPercent%',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onError,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
