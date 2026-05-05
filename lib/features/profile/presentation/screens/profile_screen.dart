import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/theme/theme_provider.dart';
import 'package:sabor_de_casa/core/utils/validators.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/auth/presentation/providers/auth_provider.dart';
import 'package:sabor_de_casa/features/profile/presentation/providers/profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String? _lastProfileId;

  // â”€â”€ Alérgenos (SharedPreferences) â”€â”€
  static const _allergenOptions = [
    'Gluten',
    'Lactosa',
    'Huevos',
    'Frutos secos',
    'Pescado',
    'Mariscos',
    'Soja',
    'Mostaza',
  ];
  List<String> _myAllergens = [];
  bool _notifOrders = true;
  bool _notifOffers = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _myAllergens = prefs.getStringList('user_allergens') ?? [];
      _notifOrders = prefs.getBool('notif_orders') ?? true;
      _notifOffers = prefs.getBool('notif_offers') ?? false;
    });
  }

  Future<void> _toggleAllergen(String allergen) async {
    final updated = _myAllergens.toList();
    if (updated.contains(allergen)) {
      updated.remove(allergen);
    } else {
      updated.add(allergen);
    }
    setState(() => _myAllergens = updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_allergens', updated);
  }

  Future<void> _setNotifOrders(bool value) async {
    setState(() => _notifOrders = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_orders', value);
  }

  Future<void> _setNotifOffers(bool value) async {
    setState(() => _notifOffers = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_offers', value);
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final isDarkMode =
        ref.watch(themeNotifierProvider).valueOrNull == ThemeMode.dark;

    ref.listen(profileNotifierProvider, (prev, next) {
      final hadValue = prev?.hasValue ?? false;
      if (hadValue && next.hasValue) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente'),
            backgroundColor: AppTokens.brandPrimary,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Mi cuenta'), centerTitle: true),
      body: profileAsync.when(
        data: (profile) {
          if (_lastProfileId != profile.id) {
            _lastProfileId = profile.id;
            _fullNameCtrl.text = profile.fullName ?? '';
            _phoneCtrl.text = profile.phone ?? '';
          }

          return RefreshIndicator(
            onRefresh: ref.read(profileNotifierProvider.notifier).refresh,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _ProfileHeader(
                  email: profile.email,
                  role: profile.role.name,
                  name: profile.fullName,
                ),
                const SizedBox(height: 32),

                Text(
                  'Datos personales',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _fullNameCtrl,
                          decoration: InputDecoration(
                            labelText: 'Nombre completo',
                            prefixIcon: const Icon(Icons.person_outline),
                            filled: true,
                            fillColor: const Color(0xFFE5E5E3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            final requiredError = Validators.required(value);
                            if (requiredError != null) return requiredError;
                            return Validators.maxLength(value, 80);
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Teléfono',
                            prefixIcon: const Icon(Icons.phone_outlined),
                            filled: true,
                            fillColor: const Color(0xFFE5E5E3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: Validators.phone,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: profileAsync.isLoading
                                ? null
                                : () => _saveProfile(context),
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('Actualizar datos'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Panel de administración (solo admin)
                if (profile.role.name == 'admin') ...[
                  Text(
                    'Administración',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ProfileMenuOption(
                    icon: Icons.dashboard_outlined,
                    title: 'Panel de administración',
                    subtitle: 'Gestión general del sistema',
                    onTap: () => context.pushNamed(RouteNames.adminDashboard),
                  ),
                  const SizedBox(height: 12),
                  _ProfileMenuOption(
                    icon: Icons.restaurant_menu_outlined,
                    title: 'Gestión de platos',
                    subtitle: 'Añadir, editar o eliminar platos',
                    onTap: () => context.pushNamed(RouteNames.adminDishes),
                  ),
                  const SizedBox(height: 12),
                  _ProfileMenuOption(
                    icon: Icons.receipt_outlined,
                    title: 'Gestión de pedidos',
                    subtitle: 'Ver y gestionar todos los pedidos',
                    onTap: () => context.pushNamed(RouteNames.adminOrders),
                  ),
                  const SizedBox(height: 12),
                  _ProfileMenuOption(
                    icon: Icons.people_outline,
                    title: 'Usuarios',
                    subtitle: 'Gestión de cuentas y roles',
                    onTap: () => context.pushNamed(RouteNames.adminUsers),
                  ),
                  const SizedBox(height: 12),
                  _ProfileMenuOption(
                    icon: Icons.bar_chart_outlined,
                    title: 'Estadísticas',
                    subtitle: 'Informes y métricas',
                    onTap: () => context.pushNamed(RouteNames.adminStats),
                  ),
                  const SizedBox(height: 32),
                ],

                // Panel de empleado (employee y admin)
                if (profile.role.name == 'employee' ||
                    profile.role.name == 'admin') ...[
                  Text(
                    'Herramientas de trabajo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ProfileMenuOption(
                    icon: Icons.kitchen_outlined,
                    title: 'Pantalla de cocina',
                    subtitle: 'Ver pedidos en preparación',
                    onTap: () => context.pushNamed(RouteNames.kitchen),
                  ),
                  const SizedBox(height: 12),
                  _ProfileMenuOption(
                    icon: Icons.delivery_dining_outlined,
                    title: 'Gestión de entregas',
                    subtitle: 'Pedidos pendientes de reparto',
                    onTap: () => context.pushNamed(RouteNames.delivery),
                  ),
                  const SizedBox(height: 12),
                  _ProfileMenuOption(
                    icon: Icons.point_of_sale_outlined,
                    title: 'TPV / Mostrador',
                    subtitle: 'Tomar pedidos en caja',
                    onTap: () => context.pushNamed(RouteNames.pos),
                  ),
                  const SizedBox(height: 32),
                ],

                // Apariencia
                Text(
                  'Apariencia',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.dark_mode_outlined,
                          color: AppTokens.brandPrimary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Modo oscuro',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Cambiar aspecto de la app',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isDarkMode,
                        activeThumbColor: AppTokens.brandPrimary,
                        onChanged: (value) => ref
                            .read(themeNotifierProvider.notifier)
                            .setMode(value ? ThemeMode.dark : ThemeMode.light),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ Mis alérgenos â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                Text(
                  'Mis alérgenos',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Marca los alérgenos que tienes. Te avisaremos en los platos que los contengan.',
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _allergenOptions.map((a) {
                          final selected = _myAllergens.contains(a);
                          return FilterChip(
                            label: Text(a),
                            selected: selected,
                            onSelected: (_) => _toggleAllergen(a),
                            selectedColor: AppTokens.brandPrimary.withValues(
                              alpha: 0.2,
                            ),
                            checkmarkColor: AppTokens.brandPrimary,
                            labelStyle: TextStyle(
                              color: selected
                                  ? AppTokens.brandPrimary
                                  : const Color(0xFF111111),
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ Notificaciones â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                Text(
                  'Notificaciones',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.receipt_outlined,
                            color: AppTokens.brandPrimary,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Estado de pedidos',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Confirmar, preparando, listo...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _notifOrders,
                            activeThumbColor: AppTokens.brandPrimary,
                            onChanged: _setNotifOrders,
                          ),
                        ],
                      ),
                      const Divider(height: 1),
                      Row(
                        children: [
                          const Icon(
                            Icons.local_offer_outlined,
                            color: AppTokens.brandPrimary,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ofertas y novedades',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Plato del día, promociones especiales',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _notifOffers,
                            activeThumbColor: AppTokens.brandPrimary,
                            onChanged: _setNotifOffers,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ Mis direcciones â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mis direcciones',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddAddressSheet(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Añadir'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _AddressesSection(
                  onAddNew: () => _showAddAddressSheet(context),
                ),
                const SizedBox(height: 32),

                // Mi cuenta
                Text(
                  'Mi cuenta',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                _ProfileMenuOption(
                  icon: Icons.receipt_long_outlined,
                  title: 'Mis pedidos',
                  subtitle: 'Historial y seguimiento',
                  onTap: () => context.pushNamed(RouteNames.orders),
                ),
                const SizedBox(height: 12),
                _ProfileMenuOption(
                  icon: Icons.favorite_border,
                  title: 'Favoritos',
                  subtitle: 'Platos guardados',
                  onTap: () => context.pushNamed(RouteNames.favorites),
                ),
                const SizedBox(height: 12),
                _ProfileMenuOption(
                  icon: Icons.support_agent_outlined,
                  title: 'Atención al cliente',
                  subtitle: 'Ayuda y contacto',
                  onTap: () => context.pushNamed(RouteNames.contact),
                ),
                const SizedBox(height: 48),

                OutlinedButton.icon(
                  onPressed: () => _signOut(context),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Cerrar sesión',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: ref.read(profileNotifierProvider.notifier).refresh,
        ),
      ),
    );
  }

  Future<void> _saveProfile(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(profileNotifierProvider.notifier)
        .updateProfile(fullName: _fullNameCtrl.text, phone: _phoneCtrl.text);

    ref.invalidate(authNotifierProvider);
  }

  Future<void> _signOut(BuildContext context) async {
    await ref.read(authNotifierProvider.notifier).signOut();
    if (!context.mounted) return;
    context.goNamed(RouteNames.login);
  }

  Future<void> _showAddAddressSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AddAddressSheet(),
    );
    ref.invalidate(addressesNotifierProvider);
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ Widget sección de direcciones â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _AddressesSection extends ConsumerWidget {
  const _AddressesSection({required this.onAddNew});
  final VoidCallback onAddNew;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(addressesNotifierProvider);
    return addressesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Text('Error: $e', style: const TextStyle(color: Colors.red)),
      data: (addresses) {
        if (addresses.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.location_off_outlined,
                  size: 40,
                  color: Colors.black26,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Aún no tienes direcciones guardadas',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: onAddNew,
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir dirección'),
                ),
              ],
            ),
          );
        }
        return Column(
          children: addresses.map((addr) {
            final label = addr['label'] as String? ?? 'Dirección';
            final street = addr['street'] as String? ?? '';
            final city = addr['city'] as String? ?? '';
            final postalCode = addr['postal_code'] as String? ?? '';
            final isDefault = addr['is_default'] as bool? ?? false;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDefault
                        ? AppTokens.brandPrimary.withValues(alpha: 0.5)
                        : Theme.of(context).colorScheme.outlineVariant,
                    width: isDefault ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDefault
                            ? AppTokens.brandPrimary.withValues(alpha: 0.1)
                            : const Color(0xFFE5E5E3).withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.location_on_outlined,
                        color: isDefault
                            ? AppTokens.brandPrimary
                            : Colors.black45,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isDefault) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTokens.brandPrimary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Predeterminada',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            '$street, $postalCode $city',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Eliminar',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('¿Eliminar dirección?'),
                            content: Text(
                              '¿Seguro que deseas eliminar "$label"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancelar'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );
                        if (confirm ?? false) {
                          await ref
                              .read(addressesNotifierProvider.notifier)
                              .remove(addr['id'] as String);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ Bottom sheet: añadir dirección â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _AddAddressSheet extends ConsumerStatefulWidget {
  const _AddAddressSheet();

  @override
  ConsumerState<_AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends ConsumerState<_AddAddressSheet> {
  final _formKey = GlobalKey<FormState>();
  final _labelCtrl = TextEditingController(text: 'Casa');
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController(text: 'Huelva');
  final _postalCodeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isDefault = false;
  bool _saving = false;

  @override
  void dispose() {
    _labelCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _postalCodeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nueva dirección',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildField(
              _labelCtrl,
              'Etiqueta',
              Icons.label_outline,
              hint: 'Casa, Trabajo, etc.',
            ),
            const SizedBox(height: 12),
            _buildField(
              _streetCtrl,
              'Calle y número',
              Icons.signpost_outlined,
              required: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    _cityCtrl,
                    'Ciudad',
                    Icons.location_city_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    _postalCodeCtrl,
                    'Código postal',
                    Icons.markunread_mailbox_outlined,
                    required: true,
                    keyboard: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildField(_notesCtrl, 'Notas (opcional)', Icons.notes_outlined),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: _isDefault,
                  activeColor: AppTokens.brandPrimary,
                  onChanged: (v) => setState(() => _isDefault = v ?? false),
                ),
                const Text('Establecer como predeterminada'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: const Text('Guardar dirección'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool required = false,
    String? hint,
    TextInputType? keyboard,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      validator: required
          ? (v) => (v?.trim().isEmpty ?? true) ? 'Requerido' : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFE5E5E3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(addressesNotifierProvider.notifier)
          .add(
            label: _labelCtrl.text,
            street: _streetCtrl.text,
            city: _cityCtrl.text,
            postalCode: _postalCodeCtrl.text,
            notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
            isDefault: _isDefault,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.email, required this.role, this.name});

  final String email;
  final String role;
  final String? name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppTokens.brandPrimary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person,
            color: AppTokens.brandPrimary,
            size: 36,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name?.isNotEmpty ?? false ? name! : 'Usuario',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: const TextStyle(color: Colors.black54, fontSize: 16),
              ),
              if (role != 'client') ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuOption extends StatelessWidget {
  const _ProfileMenuOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTokens.brandPrimary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}
