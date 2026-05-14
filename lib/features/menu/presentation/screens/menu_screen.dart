import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:sabor_de_casa/core/widgets/web_footer.dart';
import 'package:sabor_de_casa/core/widgets/web_navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/features/auth/presentation/providers/auth_provider.dart';
import 'package:sabor_de_casa/features/cart/presentation/providers/cart_provider.dart';
import 'package:sabor_de_casa/features/menu/domain/models/category.dart';
import 'package:sabor_de_casa/features/menu/domain/models/dish.dart';
import 'package:sabor_de_casa/features/menu/presentation/providers/categories_provider.dart';
import 'package:sabor_de_casa/features/menu/presentation/providers/menu_provider.dart';
import 'package:sabor_de_casa/features/menu/presentation/screens/dish_detail_screen.dart';
import 'package:sabor_de_casa/features/menu/presentation/widgets/card_add_to_cart.dart';
import 'package:speech_to_text/speech_to_text.dart';

const _heroImageUrl =
    'https://images.unsplash.com/photo-1414235077428-338989a2e8c0'
    '?q=80&w=1400&auto=format&fit=crop';

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

// ─────────────────────────────────────────────────────────────────────────────
class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedCategoryId;
  late final TextEditingController _searchCtrl;
  late final AnimationController _heroFade;
  late final ScrollController _scrollCtrl;
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _heroFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _scrollCtrl = ScrollController()
      ..addListener(() {
        final scrolled = _scrollCtrl.offset > 10;
        if (scrolled != _isScrolled) setState(() => _isScrolled = scrolled);
      });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _heroFade.dispose();
    _scrollCtrl.dispose();
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
    // Centra el contenido a 1200 px en pantallas anchas (web)
    final screenW = MediaQuery.sizeOf(context).width;
    const maxContentW = 1200.0;
    final sidePad = screenW > maxContentW ? (screenW - maxContentW) / 2 : 0.0;

    final categoriesAsync = ref.watch(categoriesProvider);
    final dishesAsync =
        ref.watch(dishesProvider(categoryId: _selectedCategoryId));
    final searchQuery = ref.watch(menuSearchQueryProvider);
    final allergenFilter = ref.watch(menuAllergenFilterProvider);

    // Filtrado local
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
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: WebNavbar(
          isScrolled: _isScrolled,
          activeRoute: RouteNames.menu,
          trailingActions: [
            IconButton(
              onPressed: () => _showAllergenFilterSheet(context),
              tooltip: 'Filtrar por alérgenos',
              icon: Badge.count(
                count: allergenFilter.length,
                isLabelVisible: allergenFilter.isNotEmpty,
                backgroundColor: Colors.orange,
                child: Icon(
                  Icons.tune_outlined,
                  size: 22,
                  color: allergenFilter.isNotEmpty
                      ? Colors.orange.shade700
                      : const Color(0xFF444444),
                ),
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(categoriesProvider)
            ..invalidate(dishesProvider(categoryId: _selectedCategoryId));
        },
        child: CustomScrollView(
          controller: _scrollCtrl,
          slivers: [
            // ── Hero ──────────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _heroFade,
                  curve: Curves.easeOut,
                ),
                child: SizedBox(
                  height: 220,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        _heroImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const ColoredBox(color: Color(0xFF0D3B2E)),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF0D3B2E).withValues(alpha: 0.93),
                              const Color(0xFF0D3B2E).withValues(alpha: 0.35),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: sidePad + 48,
                        right: sidePad + 48,
                        top: 0,
                        bottom: 0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(-0.08, 0),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: _heroFade,
                                  curve: Curves.easeOut,
                                ),
                              ),
                              child: Text(
                                'Nuestro Menú',
                                style: GoogleFonts.inter(
                                  fontSize: 46,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Cocina casera de verdad, hecha con cariño cada día.',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: Colors.white.withValues(alpha: 0.80),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Barra de búsqueda ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: ColoredBox(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(sidePad + 16, 16, sidePad + 16, 14),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: _isListening
                          ? 'Escuchando...'
                          : '¿Qué te apetece hoy?',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.black38,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.black38,
                        size: 20,
                      ),
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
                              color: _isListening
                                  ? Colors.red
                                  : Colors.black38,
                              size: 20,
                            ),
                            onPressed: _isListening
                                ? _stopVoiceSearch
                                : _startVoiceSearch,
                          ),
                        ],
                      ),
                      filled: true,
                      fillColor: AppTokens.pageBg,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppTokens.brandPrimary,
                          width: 1.5,
                        ),
                      ),
                    ),
                    style: GoogleFonts.inter(fontSize: 14),
                    onChanged: (v) =>
                        ref.read(menuSearchQueryProvider.notifier).setQuery(v),
                  ),
                ),
              ),
            ),

            // ── Categorías (sticky) ────────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              toolbarHeight: 0,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 3,
              shadowColor: Colors.black.withValues(alpha: 0.06),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(64),
                child: _CategoryBar(
                  categories: categoriesAsync.valueOrNull ?? [],
                  selectedId: _selectedCategoryId,
                  onSelected: (id) => setState(() => _selectedCategoryId = id),
                  sidePad: sidePad + 16,
                ),
              ),
            ),

            // ── Chips de alérgenos activos ────────────────────────────────────
            if (allergenFilter.isNotEmpty)
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding:
                      EdgeInsets.fromLTRB(sidePad + 16, 12, sidePad + 16, 4),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: allergenFilter
                        .map(
                          (a) => Chip(
                            label: Text(
                              'Sin $a',
                              style: GoogleFonts.inter(fontSize: 12),
                            ),
                            backgroundColor:
                                Colors.orange.withValues(alpha: 0.10),
                            labelStyle:
                                TextStyle(color: Colors.orange.shade800),
                            deleteIcon: const Icon(Icons.close, size: 14),
                            deleteIconColor: Colors.orange.shade700,
                            onDeleted: () => ref
                                .read(menuAllergenFilterProvider.notifier)
                                .toggle(a),
                            side: BorderSide.none,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),



            // ── Título sección platos ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(sidePad + 16, 20, sidePad + 16, 12),
                child: Row(
                  children: [
                    Text(
                      searchQuery.isNotEmpty
                          ? 'Resultados para "$searchQuery"'
                          : 'Todos los platos',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const Spacer(),
                    filteredDishes.maybeWhen(
                      data: (d) => Text(
                        '${d.length} platos',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.black38,
                        ),
                      ),
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),

            // ── Grid de platos ─────────────────────────────────────────────
            filteredDishes.when(
              data: (dishes) {
                if (dishes.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 52,
                            color: Colors.black.withValues(alpha: 0.12),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            searchQuery.isNotEmpty
                                ? 'No hay platos para "$searchQuery"'
                                : allergenFilter.isNotEmpty
                                    ? 'No hay platos sin esos alérgenos'
                                    : 'No hay platos disponibles',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: Colors.black45,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(sidePad + 16, 4, sidePad + 16, 4),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _MenuDishCard(
                        dish: dishes[i],
                        index: i,
                        onTap: () => showDishDetailModal(context, dishes[i].id),
                      ),
                      childCount: dishes.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 290,
                      mainAxisExtent: 360,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTokens.brandPrimary,
                    strokeWidth: 2,
                  ),
                ),
              ),
              error: (error, _) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 40,
                        color: Colors.black26,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black45),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => ref.invalidate(
                          dishesProvider(categoryId: _selectedCategoryId),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTokens.brandPrimary,
                        ),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: WebFooter()),
          ],
        ),
      ),
    );
  }

  void _showAllergenFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _AllergenFilterSheet(),
    );
  }
}

// ─── Category bar delegate (sticky) ──────────────────────────────────────────

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
    required this.sidePad,
  });

  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelected;
  final double sidePad;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: sidePad, vertical: 12),
        child: Row(
          children: [
            _CategoryTab(
              label: 'Todo',
              selected: selectedId == null,
              onTap: () => onSelected(null),
            ),
            ...categories.map(
              (cat) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _CategoryTab(
                  label: cat.name,
                  selected: selectedId == cat.id,
                  onTap: () => onSelected(cat.id),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Category tab chip ─────────────────────────────────────────────────────

class _CategoryTab extends StatefulWidget {
  const _CategoryTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends State<_CategoryTab> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: widget.selected
                ? AppTokens.brandPrimary
                : _hovered
                    ? AppTokens.brandPrimary.withValues(alpha: 0.08)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: widget.selected
                ? null
                : Border.all(color: const Color(0xFFDDDDDD)),
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.selected
                  ? Colors.white
                  : _hovered
                      ? AppTokens.brandPrimary
                      : const Color(0xFF555555),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Dish card con animación y hover ─────────────────────────────────────────

class _MenuDishCard extends StatefulWidget {
  const _MenuDishCard({
    required this.dish,
    required this.index,
    required this.onTap,
  });

  final Dish dish;
  final int index;
  final VoidCallback onTap;

  @override
  State<_MenuDishCard> createState() => _MenuDishCardState();
}

class _MenuDishCardState extends State<_MenuDishCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _opacity = CurvedAnimation(parent: _enter, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enter, curve: Curves.easeOut));
    Future.delayed(
      Duration(milliseconds: 40 * (widget.index % 12)),
      () {
        if (mounted) _enter.forward();
      },
    );
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(0, _hovered ? -6.0 : 0.0, 0),
              transformAlignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: _hovered ? 0.13 : 0.07),
                    blurRadius: _hovered ? 28 : 12,
                    offset: Offset(0, _hovered ? 10 : 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Imagen ────────────────────────────────────────────────
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: SizedBox(
                      height: 190,
                      width: double.infinity,
                      child: widget.dish.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: widget.dish.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => const ColoredBox(
                                color: Color(0xFFF0F0F0),
                              ),
                              errorWidget: (_, __, ___) =>
                                  const _PlaceholderImg(),
                            )
                          : const _PlaceholderImg(),
                    ),
                  ),

                  // ── Info ──────────────────────────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.dish.name,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A1A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.dish.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.dish.description,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.black45,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const Spacer(),
                          Row(
                            children: [
                              Text(
                                Formatters.price(widget.dish.price),
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppTokens.brandPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (widget.dish.isAvailable)
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {},
                              child: CardAddToCart(dish: widget.dish),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black
                                    .withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Agotado',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.black38,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceholderImg extends StatelessWidget {
  const _PlaceholderImg();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTokens.brandLight,
      child: Center(
        child: Icon(
          Icons.restaurant_menu,
          color: AppTokens.brandPrimary.withValues(alpha: 0.35),
          size: 30,
        ),
      ),
    );
  }
}

// ─── Allergen filter sheet ─────────────────────────────────────────────────

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
              Text(
                'Filtrar alérgenos',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (active.isNotEmpty)
                TextButton(
                  onPressed: () =>
                      ref.read(menuAllergenFilterProvider.notifier).clear(),
                  child: const Text('Limpiar'),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Solo se mostrarán platos que NO contengan los alérgenos seleccionados.',
            style: GoogleFonts.inter(color: Colors.black45, fontSize: 13),
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
                  fontWeight:
                      selected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: AppTokens.brandPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Aplicar filtros',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
