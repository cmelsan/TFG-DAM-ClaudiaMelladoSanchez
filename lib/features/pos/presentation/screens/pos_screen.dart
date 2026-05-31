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
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';
import 'package:sabor_de_casa/features/kitchen/presentation/providers/employee_orders_provider.dart';
import 'package:sabor_de_casa/features/menu/domain/models/dish.dart';
import 'package:sabor_de_casa/features/menu/presentation/providers/menu_provider.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order_extensions.dart';

// â”€â”€â”€ Constantes de diseño â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

const _kDivider = Color(0xFFE5E5E3);
const _kTextMuted = Color(0xFF6B7280);
const _kTextDark = Color(0xFF111111);

// â”€â”€â”€ Carrito (Tab 0) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _CartEntry {
  _CartEntry({required this.dish, required this.quantity});

  final Dish dish;
  int quantity;
}

// â”€â”€â”€ Scopes de encargos (Tabs 1-2) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

enum _EncargosScope { today, week }

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// PosScreen (root)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Mostrador',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: _kTextDark,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle:
              GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle:
              GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 11),
          labelColor: AppTokens.brandPrimary,
          unselectedLabelColor: _kTextMuted,
          indicatorColor: AppTokens.brandPrimary,
          indicatorWeight: 3,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(
              text: 'Nuevo Pedido',
              icon: Icon(Icons.add_circle_outline, size: 18),
            ),
            Tab(
              text: 'Encargos Hoy',
              icon: Icon(Icons.today_outlined, size: 18),
            ),
            Tab(
              text: 'Encargos Semana',
              icon: Icon(Icons.calendar_view_week_outlined, size: 18),
            ),
            Tab(
              text: 'Pedidos Hoy',
              icon: Icon(Icons.receipt_long_outlined, size: 18),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _NuevoPedidoTab(),
          _EncargosListTab(scope: _EncargosScope.today),
          _EncargosListTab(scope: _EncargosScope.week),
          _PedidosHoyTab(),
        ],
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// Tab 0 â€“ Nuevo Pedido (TPV)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class _NuevoPedidoTab extends ConsumerStatefulWidget {
  const _NuevoPedidoTab();

  @override
  ConsumerState<_NuevoPedidoTab> createState() => _NuevoPedidoTabState();
}

class _NuevoPedidoTabState extends ConsumerState<_NuevoPedidoTab> {
  final Map<String, _CartEntry> _cart = {};
  String? _selectedCategoryId;
  String _paymentMethod = 'cash';
  String? _notes;
  bool _isProcessing = false;

  double get _total =>
      _cart.values.fold<double>(0, (s, e) => s + e.dish.price * e.quantity);
  int get _cartCount => _cart.values.fold(0, (s, e) => s + e.quantity);

  void _addToCart(Dish dish) => setState(() {
        if (_cart.containsKey(dish.id)) {
          _cart[dish.id]!.quantity++;
        } else {
          _cart[dish.id] = _CartEntry(dish: dish, quantity: 1);
        }
      });

  void _removeFromCart(Dish dish) => setState(() {
        if (!_cart.containsKey(dish.id)) return;
        if (_cart[dish.id]!.quantity > 1) {
          _cart[dish.id]!.quantity--;
        } else {
          _cart.remove(dish.id);
        }
      });

  void _clearCart() => setState(_cart.clear);

  Future<void> _cobrar() async {
    if (_cart.isEmpty || _isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final items = _cart.values
          .map((e) => {
                'dishId': e.dish.id,
                'quantity': e.quantity,
                'unitPrice': e.dish.price,
              })
          .toList();
      final result = await ref
          .read(employeeOrderActionProvider.notifier)
          .createMostradorOrder(
            items: items,
            paymentMethod: _paymentMethod,
            notes: _notes,
          );
      if (!mounted) return;
      if (result != null) {
        final (orderId, displayId) = result;
        _clearCart();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pedido #${displayId ?? orderId.substring(0, 6).toUpperCase()} enviado a cocina ✓',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppTokens.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTokens.radiusMd)),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          backgroundColor: AppTokens.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 700;
    return isWide ? _buildWide() : _buildNarrow();
  }

  Widget _buildWide() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 3,
          child: _CatalogPanel(
            selectedCategoryId: _selectedCategoryId,
            onCategorySelected: (id) =>
                setState(() => _selectedCategoryId = id),
            cart: _cart,
            onAdd: _addToCart,
            onRemove: _removeFromCart,
          ),
        ),
        const VerticalDivider(width: 1, color: _kDivider),
        SizedBox(
          width: 320,
          child: _TicketPanel(
            cart: _cart,
            total: _total,
            paymentMethod: _paymentMethod,
            onPaymentMethodChanged: (m) =>
                setState(() => _paymentMethod = m),
            onClear: _clearCart,
            onCobrar: _cobrar,
            isProcessing: _isProcessing,
            onNotesChanged: (n) => _notes = n,
          ),
        ),
      ],
    );
  }

  Widget _buildNarrow() {
    return Column(
      children: [
        Expanded(
          child: _CatalogPanel(
            selectedCategoryId: _selectedCategoryId,
            onCategorySelected: (id) =>
                setState(() => _selectedCategoryId = id),
            cart: _cart,
            onAdd: _addToCart,
            onRemove: _removeFromCart,
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: _kDivider)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_cartCount artÃ­culo${_cartCount != 1 ? "s" : ""}',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: _kTextMuted),
                        ),
                        Text(
                          Formatters.price(_total),
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _kTextDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _cart.isEmpty || _isProcessing
                        ? null
                        : () => _showCobrarSheet(context),
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.payments_outlined, size: 18),
                    label: Text('Cobrar',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700)),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTokens.brandPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCobrarSheet(BuildContext ctx) {
    showModalBottomSheet<void>(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _CobrarSheet(
        cart: _cart,
        total: _total,
        paymentMethod: _paymentMethod,
        onPaymentMethodChanged: (m) =>
            setState(() => _paymentMethod = m),
        onCobrar: () {
          Navigator.pop(ctx);
          _cobrar();
        },
        isProcessing: _isProcessing,
        onNotesChanged: (n) => _notes = n,
      ),
    );
  }
}

// â”€â”€â”€ CatÃ¡logo (categorÃ­as + grid de platos) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _CatalogPanel extends ConsumerWidget {
  const _CatalogPanel({
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.cart,
    required this.onAdd,
    required this.onRemove,
  });

  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;
  final Map<String, _CartEntry> cart;
  final ValueChanged<Dish> onAdd;
  final ValueChanged<Dish> onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(adminCategoriesProvider);
    final dishesAsync =
        ref.watch(dishesProvider(categoryId: selectedCategoryId));

    return Column(
      children: [
        Container(
          color: Colors.white,
          height: 52,
          child: categoriesAsync.when(
            data: (cats) {
              final active =
                  cats.where((c) => c.isActive).toList()
                    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                itemCount: active.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return ChoiceChip(
                      label: Text('Todos',
                          style: GoogleFonts.inter(fontSize: 12)),
                      selected: selectedCategoryId == null,
                      selectedColor:
                          AppTokens.brandPrimary.withValues(alpha: 0.12),
                      onSelected: (_) => onCategorySelected(null),
                    );
                  }
                  final cat = active[i - 1];
                  return ChoiceChip(
                    label: Text(cat.name,
                        style: GoogleFonts.inter(fontSize: 12)),
                    selected: selectedCategoryId == cat.id,
                    selectedColor:
                        AppTokens.brandPrimary.withValues(alpha: 0.12),
                    onSelected: (_) => onCategorySelected(cat.id),
                  );
                },
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ),
        const Divider(height: 1, color: _kDivider),
        Expanded(
          child: dishesAsync.when(
            data: (dishes) {
              final available = dishes
                  .where((d) => d.isAvailable && d.isActive)
                  .toList();
              if (available.isEmpty) {
                return Center(
                  child: Text('Sin platos disponibles',
                      style: GoogleFonts.inter(color: _kTextMuted)),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate:
                    const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 180,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.78,
                ),
                itemCount: available.length,
                itemBuilder: (_, i) => _DishCard(
                  dish: available[i],
                  cartQty: cart[available[i].id]?.quantity ?? 0,
                  onAdd: onAdd,
                  onRemove: onRemove,
                ),
              );
            },
            loading: () => const LoadingIndicator(),
            error: (e, _) => ErrorView(
              message: e.toString(),
              onRetry: () {},
            ),
          ),
        ),
      ],
    );
  }
}

// â”€â”€â”€ Tarjeta de plato â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _DishCard extends StatelessWidget {
  const _DishCard({
    required this.dish,
    required this.cartQty,
    required this.onAdd,
    required this.onRemove,
  });

  final Dish dish;
  final int cartQty;
  final ValueChanged<Dish> onAdd;
  final ValueChanged<Dish> onRemove;

  @override
  Widget build(BuildContext context) {
    final inCart = cartQty > 0;
    return GestureDetector(
      onTap: () => onAdd(dish),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: inCart
              ? AppTokens.brandPrimary.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          border: Border.all(
            color: inCart ? AppTokens.brandPrimary : _kDivider,
            width: inCart ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (dish.isSeasonal || dish.isOffer)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: dish.isSeasonal
                            ? AppTokens.warning.withValues(alpha: 0.15)
                            : AppTokens.info.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        dish.isSeasonal ? 'Del día' : '% Oferta',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: dish.isSeasonal
                              ? AppTokens.warning
                              : AppTokens.info,
                        ),
                      ),
                    )
                  else
                    const SizedBox(),
                  if (inCart)
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppTokens.brandPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$cartQty',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(
                child: dish.imageUrl != null && dish.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl: dish.imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const ColoredBox(color: _kDivider),
                          errorWidget: (_, __, ___) => Container(
                            color: _kDivider,
                            child: const Icon(
                              Icons.restaurant,
                              color: _kTextMuted,
                              size: 28,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: _kDivider,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.restaurant,
                            color: _kTextMuted,
                            size: 28,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 6),
              Text(
                dish.name,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: _kTextDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Formatters.price(dish.offerPrice ?? dish.price),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppTokens.brandPrimary,
                    ),
                  ),
                  if (inCart)
                    GestureDetector(
                      onTap: () => onRemove(dish),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: _kDivider,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.remove,
                            size: 14, color: _kTextMuted),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// â”€â”€â”€ Panel ticket (wide) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _TicketPanel extends StatelessWidget {
  const _TicketPanel({
    required this.cart,
    required this.total,
    required this.paymentMethod,
    required this.onPaymentMethodChanged,
    required this.onClear,
    required this.onCobrar,
    required this.isProcessing,
    required this.onNotesChanged,
  });

  final Map<String, _CartEntry> cart;
  final double total;
  final String paymentMethod;
  final ValueChanged<String> onPaymentMethodChanged;
  final VoidCallback onClear;
  final VoidCallback onCobrar;
  final bool isProcessing;
  final ValueChanged<String?> onNotesChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
          child: Row(
            children: [
              Expanded(
                child: Text('Ticket',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: _kTextDark)),
              ),
              if (cart.isNotEmpty)
                TextButton(
                  onPressed: onClear,
                  child: Text('Limpiar',
                      style: GoogleFonts.inter(color: AppTokens.danger)),
                ),
            ],
          ),
        ),
        const Divider(height: 1, color: _kDivider),
        Expanded(
          child: cart.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shopping_basket_outlined,
                          size: 48, color: _kDivider),
                      const SizedBox(height: 12),
                      Text('Selecciona platos\ndel catÃ¡logo',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                              color: _kTextMuted, fontSize: 13)),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: cart.values
                      .map((e) => _TicketLine(entry: e))
                      .toList(),
                ),
        ),
        if (cart.isNotEmpty) ...[
          const Divider(height: 1, color: _kDivider),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: onNotesChanged,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Notas (alÃ©rgenos, variaciones...)',
                hintStyle:
                    GoogleFonts.inter(fontSize: 12, color: _kTextMuted),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppTokens.radiusSm),
                    borderSide:
                        const BorderSide(color: _kDivider)),
                enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppTokens.radiusSm),
                    borderSide:
                        const BorderSide(color: _kDivider)),
                isDense: true,
              ),
              style: GoogleFonts.inter(fontSize: 12),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Método de pago',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _kTextMuted)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _PayMethodChip(
                      label: 'Efectivo',
                      value: 'cash',
                      selected: paymentMethod == 'cash',
                      onTap: () => onPaymentMethodChanged('cash'),
                    ),
                    const SizedBox(width: 8),
                    _PayMethodChip(
                      label: 'Tarjeta',
                      value: 'tpv',
                      selected: paymentMethod == 'tpv',
                      onTap: () => onPaymentMethodChanged('tpv'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: _kDivider),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TOTAL',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            letterSpacing: 0.5)),
                    Text(
                      Formatters.price(total),
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: AppTokens.brandPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isProcessing ? null : onCobrar,
                    icon: isProcessing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white))
                        : const Icon(Icons.payments_outlined, size: 18),
                    label: Text(
                      isProcessing
                          ? 'Procesando...'
                          : 'Cobrar y enviar a cocina',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTokens.brandPrimary,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TicketLine extends StatelessWidget {
  const _TicketLine({required this.entry});
  final _CartEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTokens.brandPrimary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('${entry.quantity}',
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(entry.dish.name,
                style: GoogleFonts.inter(fontSize: 13),
                overflow: TextOverflow.ellipsis),
          ),
          Text(
            Formatters.price(
                (entry.dish.offerPrice ?? entry.dish.price) *
                    entry.quantity),
            style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _PayMethodChip extends StatelessWidget {
  const _PayMethodChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppTokens.brandPrimary.withValues(alpha: 0.1)
              : Colors.white,
          border: Border.all(
            color: selected ? AppTokens.brandPrimary : _kDivider,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
                color: selected
                    ? AppTokens.brandPrimary
                    : _kTextMuted)),
      ),
    );
  }
}

// â”€â”€â”€ Bottom sheet cobro (narrow) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _CobrarSheet extends StatelessWidget {
  const _CobrarSheet({
    required this.cart,
    required this.total,
    required this.paymentMethod,
    required this.onPaymentMethodChanged,
    required this.onCobrar,
    required this.isProcessing,
    required this.onNotesChanged,
  });

  final Map<String, _CartEntry> cart;
  final double total;
  final String paymentMethod;
  final ValueChanged<String> onPaymentMethodChanged;
  final VoidCallback onCobrar;
  final bool isProcessing;
  final ValueChanged<String?> onNotesChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _kDivider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Resumen del pedido',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 12),
              ...cart.values.map((e) => _TicketLine(entry: e)),
              const Divider(color: _kDivider, height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TOTAL',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700)),
                  Text(Formatters.price(total),
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: AppTokens.brandPrimary)),
                ],
              ),
              const SizedBox(height: 14),
              Text('Notas',
                  style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                onChanged: onNotesChanged,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Notas opcionales...',
                  hintStyle:
                      GoogleFonts.inter(fontSize: 12, color: _kTextMuted),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppTokens.radiusSm),
                      borderSide:
                          const BorderSide(color: _kDivider)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppTokens.radiusSm),
                      borderSide:
                          const BorderSide(color: _kDivider)),
                  isDense: true,
                ),
                style: GoogleFonts.inter(fontSize: 12),
              ),
              const SizedBox(height: 14),
              Text('Método de pago',
                  style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _PayMethodChip(
                    label: 'Efectivo',
                    value: 'cash',
                    selected: paymentMethod == 'cash',
                    onTap: () => onPaymentMethodChanged('cash'),
                  ),
                  const SizedBox(width: 8),
                  _PayMethodChip(
                    label: 'Tarjeta',
                    value: 'tpv',
                    selected: paymentMethod == 'tpv',
                    onTap: () => onPaymentMethodChanged('tpv'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isProcessing ? null : onCobrar,
                  icon: isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.payments_outlined, size: 18),
                  label: Text(
                    isProcessing
                        ? 'Procesando...'
                        : 'Cobrar y enviar a cocina',
                    style:
                        GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTokens.brandPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// Tabs 1-2 â€“ Lista de Encargos (hoy / semana)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class _EncargosListTab extends ConsumerWidget {
  const _EncargosListTab({required this.scope});

  final _EncargosScope scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = scope == _EncargosScope.today
        ? ref.watch(encargosHoyProvider)
        : ref.watch(encargosSemanaProvider);

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  scope == _EncargosScope.today
                      ? 'Encargos de hoy'
                      : 'Encargos de esta semana',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              FilledButton.icon(
                onPressed: () => context.goNamed(RouteNames.scanner),
                icon: const Icon(Icons.qr_code_scanner, size: 16),
                label: Text('Escanear QR',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, fontSize: 12)),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTokens.brandPrimary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: _kDivider),
        Expanded(
          child: async.when(
            data: (orders) {
              if (orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.event_available_outlined,
                          size: 56, color: _kDivider),
                      const SizedBox(height: 12),
                      Text(
                        scope == _EncargosScope.today
                            ? 'Sin encargos para hoy'
                            : 'Sin encargos esta semana',
                        style: GoogleFonts.inter(
                            color: _kTextMuted, fontSize: 15),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  if (scope == _EncargosScope.today) {
                    ref.invalidate(encargosHoyProvider);
                  } else {
                    ref.invalidate(encargosSemanaProvider);
                  }
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (_, i) =>
                      _EncargoCard(order: orders[i]),
                ),
              );
            },
            loading: () => const LoadingIndicator(),
            error: (e, _) => ErrorView(
              message: e.toString(),
              onRetry: () {
                if (scope == _EncargosScope.today) {
                  ref.invalidate(encargosHoyProvider);
                } else {
                  ref.invalidate(encargosSemanaProvider);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _EncargoCard extends ConsumerWidget {
  const _EncargoCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isReady = order.status == 'ready';
    final isPaid = order.paymentStatus == 'paid';
    final scheduledAt = order.scheduledAt;
    final daysLeft = scheduledAt?.difference(DateTime.now()).inHours;
    final isUrgent =
        daysLeft != null && daysLeft <= 24 && daysLeft >= 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(
          color: isReady
              ? AppTokens.success.withValues(alpha: 0.4)
              : isUrgent
                  ? AppTokens.warning.withValues(alpha: 0.4)
                  : _kDivider,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Encargo #${order.shortId}',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
                if (isUrgent && !isReady) ...[
                  _Badge(
                      label: 'URGENTE',
                      bg: AppTokens.warning.withValues(alpha: 0.15),
                      fg: AppTokens.warning),
                  const SizedBox(width: 6),
                ],
                _StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 8),
            if (scheduledAt != null) ...[
              Row(
                children: [
                  const Icon(Icons.event_outlined,
                      size: 14, color: _kTextMuted),
                  const SizedBox(width: 4),
                  Text(
                    'Recogida: ${Formatters.dateTime(scheduledAt)}',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: _kTextMuted),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                const Icon(Icons.payments_outlined,
                    size: 14, color: _kTextMuted),
                const SizedBox(width: 4),
                Text(
                  Formatters.price(order.total),
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(width: 10),
                _Badge(
                  label:
                      isPaid ? 'Pagado online' : 'Pendiente cobro',
                  bg: isPaid
                      ? AppTokens.success.withValues(alpha: 0.1)
                      : AppTokens.warning.withValues(alpha: 0.1),
                  fg: isPaid ? AppTokens.success : AppTokens.warning,
                ),
              ],
            ),
            if (isReady) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: _kDivider),
              const SizedBox(height: 10),
              if (!isPaid)
                _CobrarEntregarButton(orderId: order.id, displayId: order.displayId)
              else
                _EntregarButton(orderId: order.id, displayId: order.displayId),
            ],
          ],
        ),
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// Tab 3 â€“ Pedidos Hoy (mostrador + recogida)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class _PedidosHoyTab extends ConsumerWidget {
  const _PedidosHoyTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(counterOrdersTodayProvider);

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Pedidos de hoy',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              IconButton(
                onPressed: () =>
                    ref.invalidate(counterOrdersTodayProvider),
                icon: const Icon(Icons.refresh, size: 18),
                tooltip: 'Actualizar',
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: _kDivider),
        Expanded(
          child: async.when(
            data: (orders) {
              if (orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.receipt_long_outlined,
                          size: 56, color: _kDivider),
                      const SizedBox(height: 12),
                      Text('Sin pedidos hoy',
                          style: GoogleFonts.inter(
                              color: _kTextMuted, fontSize: 15)),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(counterOrdersTodayProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (_, i) =>
                      _PedidoHoyCard(order: orders[i]),
                ),
              );
            },
            loading: () => const LoadingIndicator(),
            error: (e, _) => ErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(counterOrdersTodayProvider),
            ),
          ),
        ),
      ],
    );
  }
}

class _PedidoHoyCard extends ConsumerWidget {
  const _PedidoHoyCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMostrador = order.orderType == 'mostrador';
    final isReady = order.status == 'ready';
    final isPaid = order.paymentStatus == 'paid';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(
          color: isReady
              ? AppTokens.success.withValues(alpha: 0.4)
              : _kDivider,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Badge(
                  label: isMostrador ? 'ðŸª Mostrador' : 'ðŸ›ï¸ Recogida',
                  bg: isMostrador
                      ? AppTokens.brandPrimary.withValues(alpha: 0.1)
                      : AppTokens.info.withValues(alpha: 0.1),
                  fg: isMostrador
                      ? AppTokens.brandPrimary
                      : AppTokens.info,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '#${order.shortId}',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
                _StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time_outlined,
                    size: 14, color: _kTextMuted),
                const SizedBox(width: 4),
                Text(
                  TimeOfDay.fromDateTime(order.createdAt)
                      .format(context),
                  style: GoogleFonts.inter(
                      fontSize: 12, color: _kTextMuted),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.payments_outlined,
                    size: 14, color: _kTextMuted),
                const SizedBox(width: 4),
                Text(
                  Formatters.price(order.total),
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700, fontSize: 13),
                ),
                if (isPaid) ...[
                  const SizedBox(width: 8),
                  _Badge(
                    label: 'Pagado',
                    bg: AppTokens.success.withValues(alpha: 0.1),
                    fg: AppTokens.success,
                  ),
                ],
              ],
            ),
            if (isReady) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: _kDivider),
              const SizedBox(height: 10),
              if (!isPaid)
                _CobrarEntregarButton(orderId: order.id, displayId: order.displayId)
              else
                _EntregarButton(orderId: order.id, displayId: order.displayId),
            ],
          ],
        ),
      ),
    );
  }
}

// â”€â”€â”€ Botones de acciÃ³n reutilizables â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _CobrarEntregarButton extends ConsumerWidget {
  const _CobrarEntregarButton({required this.orderId, this.displayId});

  final String orderId;
  final String? displayId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => _confirm(context, ref),
        icon: const Icon(Icons.payments_outlined, size: 16),
        label: Text('Cobrar y Entregar',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        style: FilledButton.styleFrom(
          backgroundColor: AppTokens.success,
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  void _confirm(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirmar cobro y entrega',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text(
          'Â¿Confirmas que has cobrado el pedido '
          '#${displayId ?? orderId.substring(0, 6).toUpperCase()} '
          'y lo has entregado al cliente?',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style: GoogleFonts.inter(color: _kTextMuted)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(employeeOrderActionProvider.notifier)
                  .markDeliveredAndPaid(orderId);
            },
            style: FilledButton.styleFrom(
                backgroundColor: AppTokens.success),
            child: Text('SÃ­, cobrado y entregado',
                style:
                    GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _EntregarButton extends ConsumerWidget {
  const _EntregarButton({required this.orderId, this.displayId});

  final String orderId;
  final String? displayId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _confirm(context, ref),
        icon: const Icon(Icons.check_circle_outline, size: 16),
        label: Text('Marcar como Entregado',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTokens.success),
          foregroundColor: AppTokens.success,
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  void _confirm(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirmar entrega',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text(
          'Â¿Has entregado el pedido '
          '#${displayId ?? orderId.substring(0, 6).toUpperCase()} '
          'al cliente? (Ya está pagado online.)',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style: GoogleFonts.inter(color: _kTextMuted)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(employeeOrderActionProvider.notifier)
                  .markDelivered(orderId);
            },
            style: FilledButton.styleFrom(
                backgroundColor: AppTokens.brandPrimary),
            child: Text('SÃ­, entregado',
                style:
                    GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€ Widgets auxiliares â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.bg, required this.fg});

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label,
          style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  static const _labels = {
    'pending': 'Pendiente',
    'confirmed': 'Confirmado',
    'preparing': 'En cocina',
    'ready': 'Listo âœ“',
    'delivering': 'En camino',
    'delivered': 'Entregado',
    'cancelled': 'Cancelado',
  };

  Color _bg() => switch (status) {
        'pending' => AppTokens.warning,
        'confirmed' => AppTokens.info,
        'preparing' => AppTokens.warning,
        'ready' => AppTokens.success,
        'cancelled' => AppTokens.danger,
        _ => _kTextMuted,
      };

  @override
  Widget build(BuildContext context) {
    final base = _bg();
    return _Badge(
      label: _labels[status] ?? status,
      bg: base.withValues(alpha: 0.12),
      fg: base,
    );
  }
}

