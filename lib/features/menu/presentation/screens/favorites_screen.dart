import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/core/widgets/web_footer.dart';
import 'package:sabor_de_casa/core/widgets/web_navbar.dart';
import 'package:sabor_de_casa/features/cart/presentation/providers/cart_provider.dart';
import 'package:sabor_de_casa/features/menu/domain/models/dish.dart';
import 'package:sabor_de_casa/features/menu/presentation/providers/favorites_provider.dart';
import 'package:sabor_de_casa/features/menu/presentation/screens/dish_detail_screen.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  late final TextEditingController _searchCtrl;
  late final ScrollController _scrollCtrl;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _scrollCtrl = ScrollController()
      ..addListener(() {
        final scrolled = _scrollCtrl.offset > 10;
        if (scrolled != _isScrolled) setState(() => _isScrolled = scrolled);
      });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  List<Dish> _filteredDishes(List<Dish> dishes) {
    final query = _searchCtrl.text.trim().toLowerCase();
    if (query.isEmpty) return dishes;

    return dishes.where((dish) {
      final haystack = [
        dish.name,
        dish.description,
        ...dish.allergens,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  void _addToCart(Dish dish) {
    ref.read(cartNotifierProvider.notifier).addDish(dish);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${dish.name} añadido al carrito'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dishesAsync = ref.watch(favoriteDishesProvider);
    final screenW = MediaQuery.sizeOf(context).width;
    final hPad = screenW > 1200 ? (screenW - 1200) / 2 + 24.0 : 24.0;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(76),
        child: WebNavbar(
          isScrolled: _isScrolled,
          activeRoute: RouteNames.favorites,
        ),
      ),
      body: dishesAsync.when(
        data: (dishes) {
          final filtered = _filteredDishes(dishes);
          return CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 42, hPad, 0),
                  child: _PageHeader(dishes: dishes),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 28, hPad, 0),
                  child: _FavoritesToolbar(
                    controller: _searchCtrl,
                    totalCount: dishes.length,
                    visibleCount: filtered.length,
                    onChanged: (_) => setState(() {}),
                    onClear: () {
                      _searchCtrl.clear();
                      setState(() {});
                    },
                  ),
                ),
              ),
              if (dishes.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(hPad, 28, hPad, 56),
                    child: const _EmptyFavoritesState(),
                  ),
                )
              else if (filtered.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(hPad, 28, hPad, 56),
                    child: _NoSearchResultsState(
                      onClear: () {
                        _searchCtrl.clear();
                        setState(() {});
                      },
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, 28, hPad, 64),
                  sliver: _FavoritesGrid(
                    dishes: filtered,
                    onOpenDish: (dish) => showDishDetailModal(context, dish.id),
                    onAddToCart: _addToCart,
                  ),
                ),
              const SliverToBoxAdapter(child: WebFooter()),
            ],
          );
        },
        loading: () => const _ScaffoldBodyState(child: LoadingIndicator()),
        error: (error, _) => _ScaffoldBodyState(
          child: ErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(favoriteDishesProvider),
          ),
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.dishes});

  final List<Dish> dishes;

  @override
  Widget build(BuildContext context) {
    final available = dishes.where((dish) => dish.isAvailable).length;
    final offerCount = dishes.where((dish) => dish.isOffer).length;
    final quickest = dishes.isEmpty
        ? 0
        : dishes
              .map((dish) => dish.prepTimeMin)
              .reduce((a, b) => a < b ? a : b);
    final compact = MediaQuery.sizeOf(context).width < 820;

    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppTokens.brandLight,
            borderRadius: BorderRadius.circular(AppTokens.radiusPill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.favorite_rounded,
                size: 16,
                color: AppTokens.brandPrimary,
              ),
              const SizedBox(width: 7),
              Text(
                'Tus platos guardados',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTokens.brandDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Favoritos listos para repetir',
          style: GoogleFonts.inter(
            fontSize: compact ? 34 : 44,
            fontWeight: FontWeight.w900,
            height: 1.02,
            color: AppTokens.surfaceDark,
          ),
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            'Encuentra rápido esos platos que ya sabes que funcionan y añádelos al carrito sin volver a buscar por todo el menú.',
            style: GoogleFonts.inter(
              fontSize: 16,
              height: 1.55,
              color: const Color(0xFF666663),
            ),
          ),
        ),
      ],
    );

    final panel = _HeaderPanel(
      total: dishes.length,
      available: available,
      offerCount: offerCount,
      quickest: quickest,
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [intro, const SizedBox(height: 24), panel],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: intro),
        const SizedBox(width: 32),
        SizedBox(width: 380, child: panel),
      ],
    );
  }
}

class _HeaderPanel extends StatelessWidget {
  const _HeaderPanel({
    required this.total,
    required this.available,
    required this.offerCount,
    required this.quickest,
  });

  final int total;
  final int available;
  final int offerCount;
  final int quickest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTokens.surfaceDark,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppTokens.surfaceDark.withValues(alpha: 0.16),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                ),
                child: const Icon(
                  Icons.bookmark_added_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  total == 0
                      ? 'Empieza tu lista personal'
                      : '$total favoritos guardados',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _HeaderMetric(
                  label: 'Disponibles',
                  value: '$available',
                  icon: Icons.check_circle_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeaderMetric(
                  label: 'Ofertas',
                  value: '$offerCount',
                  icon: Icons.local_offer_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeaderMetric(
                  label: 'Más rápido',
                  value: quickest == 0 ? '--' : '${quickest}m',
                  icon: Icons.timer_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppTokens.brandPrimary),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoritesToolbar extends StatelessWidget {
  const _FavoritesToolbar({
    required this.controller,
    required this.totalCount,
    required this.visibleCount,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final int totalCount;
  final int visibleCount;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 720;
    final search = TextField(
      controller: controller,
      onChanged: onChanged,
      style: GoogleFonts.inter(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Buscar por plato, descripción o alérgeno',
        hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.black38),
        prefixIcon: const Icon(Icons.search_rounded, color: Colors.black38),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: onClear,
              ),
        filled: true,
        fillColor: const Color(0xFFF7F7F5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: const BorderSide(color: Color(0xFFE6E4E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: const BorderSide(
            color: AppTokens.brandPrimary,
            width: 1.5,
          ),
        ),
      ),
    );

    final counter = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTokens.brandLight,
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.restaurant_menu_rounded,
            size: 17,
            color: AppTokens.brandPrimary,
          ),
          const SizedBox(width: 8),
          Text(
            '$visibleCount de $totalCount visibles',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppTokens.brandDark,
            ),
          ),
        ],
      ),
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          search,
          const SizedBox(height: 12),
          Align(child: counter),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: search),
        const SizedBox(width: 16),
        counter,
      ],
    );
  }
}

class _FavoritesGrid extends StatelessWidget {
  const _FavoritesGrid({
    required this.dishes,
    required this.onOpenDish,
    required this.onAddToCart,
  });

  final List<Dish> dishes;
  final ValueChanged<Dish> onOpenDish;
  final ValueChanged<Dish> onAddToCart;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        final columns = width >= 1050
            ? 3
            : width >= 680
            ? 2
            : 1;
        return SliverGrid.builder(
          itemCount: dishes.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 18,
            crossAxisSpacing: 18,
            mainAxisExtent: columns == 1 ? 250 : 340,
          ),
          itemBuilder: (context, index) => _FavoriteDishCard(
            dish: dishes[index],
            onOpen: () => onOpenDish(dishes[index]),
            onAddToCart: () => onAddToCart(dishes[index]),
          ),
        );
      },
    );
  }
}

class _FavoriteDishCard extends ConsumerStatefulWidget {
  const _FavoriteDishCard({
    required this.dish,
    required this.onOpen,
    required this.onAddToCart,
  });

  final Dish dish;
  final VoidCallback onOpen;
  final VoidCallback onAddToCart;

  @override
  ConsumerState<_FavoriteDishCard> createState() => _FavoriteDishCardState();
}

class _FavoriteDishCardState extends ConsumerState<_FavoriteDishCard> {
  bool _isHovering = false;
  bool _isRemoving = false;

  Future<void> _removeFavorite() async {
    setState(() => _isRemoving = true);
    await ref.read(favoriteToggleProvider.notifier).toggle(widget.dish.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.dish.name} eliminado de favoritos'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() => _isRemoving = false);
  }

  @override
  Widget build(BuildContext context) {
    final dish = widget.dish;
    final effectivePrice = dish.offerPrice ?? dish.price;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, _isHovering ? -3 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          border: Border.all(
            color: _isHovering
                ? AppTokens.brandPrimary.withValues(alpha: 0.35)
                : const Color(0xFFE8E6E2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovering ? 0.10 : 0.05),
              blurRadius: _isHovering ? 26 : 14,
              offset: Offset(0, _isHovering ? 14 : 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onOpen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _DishImage(imageUrl: dish.imageUrl),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.28),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.18),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _AvailabilityBadge(available: dish.isAvailable),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Tooltip(
                        message: 'Quitar de favoritos',
                        child: IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTokens.danger,
                            minimumSize: const Size(42, 42),
                          ),
                          onPressed: _isRemoving ? null : _removeFavorite,
                          icon: _isRemoving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTokens.danger,
                                  ),
                                )
                              : const Icon(Icons.favorite_rounded, size: 21),
                        ),
                      ),
                    ),
                    if (dish.isOffer)
                      const Positioned(
                        left: 12,
                        bottom: 12,
                        child: _SoftBadge(
                          icon: Icons.local_offer_rounded,
                          label: 'Oferta',
                          color: AppTokens.warning,
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            dish.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppTokens.surfaceDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          Formatters.price(effectivePrice),
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppTokens.brandPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dish.description.isEmpty
                          ? 'Plato preparado en cocina de Sabor de Casa.'
                          : dish.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        height: 1.35,
                        color: const Color(0xFF666663),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _SoftBadge(
                          icon: Icons.timer_rounded,
                          label: '${dish.prepTimeMin} min',
                          color: AppTokens.brandPrimary,
                        ),
                        if (dish.allergens.isNotEmpty)
                          _SoftBadge(
                            icon: Icons.info_outline_rounded,
                            label: '${dish.allergens.length} alérgenos',
                            color: AppTokens.info,
                          ),
                        if (dish.isSeasonal)
                          const _SoftBadge(
                            icon: Icons.eco_rounded,
                            label: 'Temporada',
                            color: AppTokens.success,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 44),
                              foregroundColor: AppTokens.brandDark,
                              side: const BorderSide(color: Color(0xFFD8D6D2)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppTokens.radiusPill,
                                ),
                              ),
                            ),
                            onPressed: widget.onOpen,
                            icon: const Icon(
                              Icons.visibility_rounded,
                              size: 18,
                            ),
                            label: const Text('Ver'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(0, 44),
                              backgroundColor: AppTokens.brandPrimary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFFE0E0DE),
                              disabledForegroundColor: Colors.black38,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppTokens.radiusPill,
                                ),
                              ),
                            ),
                            onPressed: dish.isAvailable
                                ? widget.onAddToCart
                                : null,
                            icon: const Icon(
                              Icons.add_shopping_cart_rounded,
                              size: 18,
                            ),
                            label: const Text('Añadir'),
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

class _DishImage extends StatelessWidget {
  const _DishImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const _DishImagePlaceholder();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      placeholder: (_, __) => const _DishImagePlaceholder(),
      errorWidget: (_, __, ___) => const _DishImagePlaceholder(),
    );
  }
}

class _DishImagePlaceholder extends StatelessWidget {
  const _DishImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE1F5EE), Color(0xFFF7F1E8)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: 44,
          color: AppTokens.brandPrimary.withValues(alpha: 0.72),
        ),
      ),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.available});

  final bool available;

  @override
  Widget build(BuildContext context) {
    final color = available ? AppTokens.brandPrimary : AppTokens.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            available ? Icons.check_circle_rounded : Icons.block_rounded,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            available ? 'Disponible' : 'Agotado',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftBadge extends StatelessWidget {
  const _SoftBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFavoritesState extends StatelessWidget {
  const _EmptyFavoritesState();

  @override
  Widget build(BuildContext context) {
    return _StateCard(
      icon: Icons.favorite_border_rounded,
      title: 'Aún no tienes favoritos',
      message:
          'Guarda tus platos preferidos desde el menú y volverán aquí para pedirlos en segundos.',
      primaryLabel: 'Explorar el menú',
      onPrimary: () => context.goNamed(RouteNames.menu),
    );
  }
}

class _NoSearchResultsState extends StatelessWidget {
  const _NoSearchResultsState({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return _StateCard(
      icon: Icons.search_off_rounded,
      title: 'No hay favoritos con esa búsqueda',
      message:
          'Prueba con el nombre de otro plato, un ingrediente o limpia el filtro.',
      primaryLabel: 'Limpiar búsqueda',
      onPrimary: onClear,
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
  });

  final IconData icon;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 46),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F5),
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: const Color(0xFFE6E4E0)),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTokens.radiusLg),
              border: Border.all(color: const Color(0xFFE8E6E2)),
            ),
            child: Icon(icon, size: 36, color: AppTokens.brandPrimary),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppTokens.surfaceDark,
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                height: 1.5,
                color: const Color(0xFF666663),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 48),
              backgroundColor: AppTokens.brandPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusPill),
              ),
            ),
            onPressed: onPrimary,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: Text(primaryLabel),
          ),
        ],
      ),
    );
  }
}

class _ScaffoldBodyState extends StatelessWidget {
  const _ScaffoldBodyState({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(padding: const EdgeInsets.all(24), child: child),
    );
  }
}
