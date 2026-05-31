import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/auth/presentation/providers/auth_provider.dart';
import 'package:sabor_de_casa/features/cart/presentation/providers/cart_provider.dart';
import 'package:sabor_de_casa/features/menu/domain/models/dish.dart';
import 'package:sabor_de_casa/features/menu/presentation/providers/favorites_provider.dart';
import 'package:sabor_de_casa/features/menu/presentation/providers/menu_provider.dart';
import 'package:sabor_de_casa/features/menu/presentation/widgets/allergen_badge.dart';

// Muestra diálogo de login si no autenticado; si sí, ejecuta el toggle.
void _tapFavorite(BuildContext context, WidgetRef ref, String dishId) {
  final user = ref.read(authNotifierProvider).valueOrNull;
  if (user == null) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.favorite_border, color: Colors.red, size: 36),
        title: const Text(
          'Inicia sesión para guardar favoritos',
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Necesitas una cuenta para guardar tus platos favoritos y acceder a ellos cuando quieras.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Ahora no'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.pushNamed(RouteNames.login);
            },
            child: const Text('Iniciar sesión'),
          ),
        ],
      ),
    );
    return;
  }
  ref.read(favoriteToggleProvider.notifier).toggle(dishId);
}

class DishDetailScreen extends ConsumerStatefulWidget {
  const DishDetailScreen({required this.dishId, super.key});

  final String dishId;

  @override
  ConsumerState<DishDetailScreen> createState() => _DishDetailScreenState();
}

class _DishDetailScreenState extends ConsumerState<DishDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final dishAsync = ref.watch(dishDetailProvider(widget.dishId));
    final isFavAsync = ref.watch(isFavoriteProvider(widget.dishId));
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = kIsWeb && screenWidth >= 800;

    return Scaffold(
      backgroundColor: isWide ? Colors.white : const Color(0xFFF4F6F2),
      body: dishAsync.when(
        data: (dish) => isWide
            ? _WebLayout(
                dish: dish,
                isFavAsync: isFavAsync,
                quantity: _quantity,
                onQuantityChanged: (v) => setState(() => _quantity = v),
                onAddToCart: () => _addToCart(context, dish),
                dishId: widget.dishId,
              )
            : _MobileLayout(
                dish: dish,
                isFavAsync: isFavAsync,
                quantity: _quantity,
                onQuantityChanged: (v) => setState(() => _quantity = v),
                onAddToCart: () => _addToCart(context, dish),
                dishId: widget.dishId,
              ),
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(dishDetailProvider(widget.dishId)),
        ),
      ),
    );
  }

  void _addToCart(BuildContext context, Dish dish) {
    for (var i = 0; i < _quantity; i++) {
      ref.read(cartNotifierProvider.notifier).addDish(dish);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_quantity ${dish.name} añadido al carrito'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.pop();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WEB LAYOUT — dos columnas, card centrada, max 1100px
// ─────────────────────────────────────────────────────────────────────────────

class _WebLayout extends ConsumerWidget {
  const _WebLayout({
    required this.dish,
    required this.isFavAsync,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onAddToCart,
    required this.dishId,
  });

  final Dish dish;
  final AsyncValue<bool> isFavAsync;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAddToCart;
  final String dishId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111111)),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(48, 8, 48, 48),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final twoCol = constraints.maxWidth >= 600;
                if (twoCol) {
                  final imgWidth = constraints.maxWidth * 0.45;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen izquierda — redondeada
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          width: imgWidth,
                          height: 480,
                          child: _DishImage(dish: dish),
                        ),
                      ),
                      const SizedBox(width: 48),
                      // Info derecha
                      Expanded(
                        child: _DishInfo(
                          dish: dish,
                          isFavAsync: isFavAsync,
                          quantity: quantity,
                          onQuantityChanged: onQuantityChanged,
                          onAddToCart: onAddToCart,
                          dishId: dishId,
                          ref: ref,
                          theme: theme,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  );
                }
                // Pantalla estrecha: apilado
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 280,
                        child: _DishImage(dish: dish),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _DishInfo(
                      dish: dish,
                      isFavAsync: isFavAsync,
                      quantity: quantity,
                      onQuantityChanged: onQuantityChanged,
                      onAddToCart: onAddToCart,
                      dishId: dishId,
                      ref: ref,
                      theme: theme,
                      padding: EdgeInsets.zero,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOBILE LAYOUT — diseño original con SliverAppBar
// ─────────────────────────────────────────────────────────────────────────────

class _MobileLayout extends ConsumerWidget {
  const _MobileLayout({
    required this.dish,
    required this.isFavAsync,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onAddToCart,
    required this.dishId,
  });

  final Dish dish;
  final AsyncValue<bool> isFavAsync;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAddToCart;
  final String dishId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Color(0xFF111111)),
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.8),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _DishImage(dish: dish),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.8),
                  child: isFavAsync.when(
                    data: (isFav) => IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : const Color(0xFF111111),
                      ),
                      onPressed: () => _tapFavorite(context, ref, dishId),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: _DishInfo(
                dish: dish,
                isFavAsync: isFavAsync,
                quantity: quantity,
                onQuantityChanged: onQuantityChanged,
                onAddToCart: null, // se usa bottomNavigationBar
                dishId: dishId,
                ref: ref,
                theme: theme,
                padding: EdgeInsets.zero,
                showFavButton: false,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: dish.isAvailable
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    _QuantityPicker(
                      quantity: quantity,
                      onChanged: onQuantityChanged,
                      theme: theme,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: onAddToCart,
                        child: Text(
                          'Añadir  ·  ${Formatters.price(dish.price * quantity)}',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Componentes compartidos
// ─────────────────────────────────────────────────────────────────────────────

class _DishImage extends StatelessWidget {
  const _DishImage({required this.dish});
  final Dish dish;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (dish.imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: dish.imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (_, __) => ColoredBox(
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        errorWidget: (_, __, ___) => ColoredBox(
          color: theme.colorScheme.surfaceContainerHighest,
          child: const Icon(Icons.restaurant, size: 64),
        ),
      );
    }
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: const Center(child: Icon(Icons.restaurant, size: 64)),
    );
  }
}

class _DishInfo extends StatelessWidget {
  const _DishInfo({
    required this.dish,
    required this.isFavAsync,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onAddToCart,
    required this.dishId,
    required this.ref,
    required this.theme,
    required this.padding,
    this.showFavButton = true,
  });

  final Dish dish;
  final AsyncValue<bool> isFavAsync;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback? onAddToCart;
  final String dishId;
  final WidgetRef ref;
  final ThemeData theme;
  final EdgeInsets padding;
  final bool showFavButton;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título + favorito
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  dish.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF111111),
                    height: 1.2,
                  ),
                ),
              ),
              if (showFavButton) ...[
                const SizedBox(width: 12),
                isFavAsync.when(
                  data: (isFav) => IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : Colors.black38,
                    ),
                    onPressed: () => _tapFavorite(context, ref, dishId),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Precio + tiempo / agotado
          Row(
            children: [
              Text(
                Formatters.price(dish.price),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTokens.brandPrimary,
                ),
              ),
              const SizedBox(width: 16),
              if (!dish.isAvailable)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Agotado',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 15, color: Colors.black45),
                    const SizedBox(width: 4),
                    Text(
                      '${dish.prepTimeMin} min',
                      style: const TextStyle(
                          color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Divider sutil
          const Divider(color: Color(0xFFEEEEEC), height: 1),
          const SizedBox(height: 24),

          // Descripción
          if (dish.description.isNotEmpty) ...[
            Text(
              'Descripción',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111111),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dish.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Alérgenos
          if (dish.allergens.isNotEmpty) ...[
            Text(
              'Alérgenos',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111111),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  dish.allergens.map((a) => AllergenBadge(allergen: a)).toList(),
            ),
            const SizedBox(height: 32),
          ],

          // Controles de cantidad + botón (solo en web)
          if (onAddToCart != null && dish.isAvailable) ...[
            const Divider(color: Color(0xFFEEEEEC), height: 1),
            const SizedBox(height: 24),
            Row(
              children: [
                _QuantityPicker(
                  quantity: quantity,
                  onChanged: onQuantityChanged,
                  theme: theme,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: onAddToCart,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTokens.brandPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Añadir  ·  ${Formatters.price(dish.price * quantity)}',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (onAddToCart != null && !dish.isAvailable)
            const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Modal helper — web: dialog, mobile: push route
// ─────────────────────────────────────────────────────────────────────────────

void showDishDetailModal(BuildContext context, String dishId) {
  if (!kIsWeb) {
    context.pushNamed(RouteNames.dishDetail, pathParameters: {'dishId': dishId});
    return;
  }
  showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => _DishDetailModal(dishId: dishId),
  );
}

class _DishDetailModal extends ConsumerStatefulWidget {
  const _DishDetailModal({required this.dishId});
  final String dishId;

  @override
  ConsumerState<_DishDetailModal> createState() => _DishDetailModalState();
}

class _DishDetailModalState extends ConsumerState<_DishDetailModal> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final dishAsync = ref.watch(dishDetailProvider(widget.dishId));
    final isFavAsync = ref.watch(isFavoriteProvider(widget.dishId));
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 80, vertical: 48),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: SizedBox(
          height: 460,
          child: Stack(
            children: [
              dishAsync.when(
                data: (dish) => Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Imagen izquierda ──────────────────────────────
                    SizedBox(
                      width: 260,
                      child: _DishImage(dish: dish),
                    ),
                    // ── Info derecha (scrollable) ─────────────────────
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(32, 52, 52, 32),
                        child: _DishInfo(
                          dish: dish,
                          isFavAsync: isFavAsync,
                          quantity: _quantity,
                          onQuantityChanged: (v) =>
                              setState(() => _quantity = v),
                          onAddToCart:
                              dish.isAvailable ? () => _addToCart(dish) : null,
                          dishId: widget.dishId,
                          ref: ref,
                          theme: theme,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
                loading: () => const Center(child: LoadingIndicator()),
                error: (e, _) =>
                    Center(child: ErrorView(message: e.toString())),
              ),
              // ── Botón cerrar ────────────────────────────────────────
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black12,
                    foregroundColor: const Color(0xFF333333),
                    minimumSize: const Size(36, 36),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToCart(Dish dish) {
    for (var i = 0; i < _quantity; i++) {
      ref.read(cartNotifierProvider.notifier).addDish(dish);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_quantity × ${dish.name} añadido al carrito'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop();
  }
}

class _QuantityPicker extends StatelessWidget {
  const _QuantityPicker({
    required this.quantity,
    required this.onChanged,
    required this.theme,
  });

  final int quantity;
  final ValueChanged<int> onChanged;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E5E3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed:
                quantity > 1 ? () => onChanged(quantity - 1) : null,
          ),
          Text(
            '$quantity',
            style:
                theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => onChanged(quantity + 1),
          ),
        ],
      ),
    );
  }
}
