import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/theme/theme_provider.dart';
import 'package:sabor_de_casa/core/utils/validators.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/core/widgets/web_footer.dart';
import 'package:sabor_de_casa/core/widgets/web_navbar.dart';
import 'package:sabor_de_casa/features/auth/presentation/providers/auth_provider.dart';
import 'package:sabor_de_casa/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:sabor_de_casa/features/profile/presentation/providers/profile_provider.dart';
import 'package:sabor_de_casa/features/support/domain/models/support_thread.dart';
import 'package:sabor_de_casa/features/support/presentation/providers/support_provider.dart';

const _kBgDark = Color(0xFF0D3B2E);
const _kCream = Color(0xFFF2EBD9);
const _kMuted = Color(0xFF8FBFB0);

// Theme-aware helpers
Color _cardBg(BuildContext c) =>
    Theme.of(c).brightness == Brightness.dark
        ? const Color(0xFF1E1E1E)
        : Colors.white;
Color _borderColor(BuildContext c) =>
    Theme.of(c).brightness == Brightness.dark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFE8E8E6);
Color _dividerColor(BuildContext c) =>
    Theme.of(c).brightness == Brightness.dark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFEEEEEC);
Color _textMain(BuildContext c) =>
    Theme.of(c).brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF111111);
Color _textMuted(BuildContext c) =>
    Theme.of(c).brightness == Brightness.dark
        ? const Color(0xFFAAAAAA)
        : const Color(0xFF888885);

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  late final ScrollController _scrollCtrl;
  bool _isScrolled = false;

  String? _lastProfileId;

  // 14 alérgenos obligatorios Reglamento UE 1169/2011 (clave = key en Supabase)
  static const _allergenOptions = [
    ('gluten',       'Gluten'),
    ('lactosa',      'Lactosa'),
    ('huevo',        'Huevo'),
    ('pescado',      'Pescado'),
    ('marisco',      'Marisco'),
    ('frutos_secos', 'Frutos secos'),
    ('soja',         'Soja'),
    ('apio',         'Apio'),
    ('mostaza',      'Mostaza'),
    ('sesamo',       'Sésamo'),
    ('sulfitos',     'Sulfitos'),
    ('moluscos',     'Moluscos'),
    ('altramuces',   'Altramuces'),
    ('cacahuete',    'Cacahuete'),
  ];
  bool _notifOrders = true;
  bool _notifOffers = false;

  @override
  void initState() {
    super.initState();
    _loadNotifPreferences();
    _scrollCtrl = ScrollController()
      ..addListener(() {
        final scrolled = _scrollCtrl.offset > 10;
        if (scrolled != _isScrolled) setState(() => _isScrolled = scrolled);
      });
  }

  Future<void> _loadNotifPreferences() async {
    // Las notificaciones siguen en SharedPreferences (solo son preferencias locales UI)
    if (!mounted) return;
    setState(() {
      _notifOrders = true;
      _notifOffers = false;
    });
  }

  Future<void> _toggleAllergen(
      String key, List<String> currentAllergens) async {
    final updated = currentAllergens.toList();
    if (updated.contains(key)) {
      updated.remove(key);
    } else {
      updated.add(key);
    }
    await ref
        .read(profileNotifierProvider.notifier)
        .updateAllergens(updated);
  }

  Future<void> _setNotifOrders(bool value) async {
    setState(() => _notifOrders = value);
  }

  Future<void> _setNotifOffers(bool value) async {
    setState(() => _notifOffers = value);
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final isDarkMode =
        ref.watch(themeNotifierProvider).valueOrNull == ThemeMode.dark;
    final screenW = MediaQuery.sizeOf(context).width;
    final hPad = screenW > 1200 ? (screenW - 1200) / 2 + 24.0 : 24.0;

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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: WebNavbar(
          isScrolled: _isScrolled,
          activeRoute: RouteNames.profile,
        ),
      ),
      body: profileAsync.when(
        data: (profile) {
          if (_lastProfileId != profile.id) {
            _lastProfileId = profile.id;
            _fullNameCtrl.text = profile.fullName ?? '';
            _phoneCtrl.text = profile.phone ?? '';
          }

          return RefreshIndicator(
            color: AppTokens.brandPrimary,
            onRefresh: ref.read(profileNotifierProvider.notifier).refresh,
            child: CustomScrollView(
              controller: _scrollCtrl,
              slivers: [
                SliverToBoxAdapter(
                  child: _ProfileHero(
                    name: profile.fullName,
                    email: profile.email,
                    role: profile.role.name,
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, 28, hPad, 40),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Datos personales
                      const _SectionLabel('Datos personales'),
                      const SizedBox(height: 12),
                      _PersonalDataCard(
                        formKey: _formKey,
                        fullNameCtrl: _fullNameCtrl,
                        phoneCtrl: _phoneCtrl,
                        isLoading: profileAsync.isLoading,
                        onSave: () => _saveProfile(context),
                      ),
                      const SizedBox(height: 32),

                      // Panel de administracion (solo admin)
                      if (profile.role.name == 'admin') ...[
                        const _SectionLabel('Administracion'),
                        const SizedBox(height: 12),
                        _SettingsGroup(
                          items: [
                            _SettingsRow(
                              icon: Icons.dashboard_outlined,
                              title: 'Panel de administracion',
                              subtitle: 'Gestion general del sistema',
                              onTap: () => context.pushNamed(
                                RouteNames.adminDashboard,
                              ),
                            ),
                            _SettingsRow(
                              icon: Icons.restaurant_menu_outlined,
                              title: 'Gestion de platos',
                              subtitle: 'Anadir, editar o eliminar platos',
                              onTap: () =>
                                  context.pushNamed(RouteNames.adminDishes),
                            ),
                            _SettingsRow(
                              icon: Icons.receipt_outlined,
                              title: 'Gestion de pedidos',
                              subtitle: 'Ver y gestionar todos los pedidos',
                              onTap: () =>
                                  context.pushNamed(RouteNames.adminOrders),
                            ),
                            _SettingsRow(
                              icon: Icons.people_outline,
                              title: 'Usuarios',
                              subtitle: 'Gestion de cuentas y roles',
                              onTap: () =>
                                  context.pushNamed(RouteNames.adminUsers),
                            ),
                            _SettingsRow(
                              icon: Icons.bar_chart_outlined,
                              title: 'Estadisticas',
                              subtitle: 'Informes y metricas',
                              onTap: () =>
                                  context.pushNamed(RouteNames.adminStats),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Panel de empleado
                      if (profile.role.name == 'employee' ||
                          profile.role.name == 'admin') ...[
                        const _SectionLabel('Herramientas de trabajo'),
                        const SizedBox(height: 12),
                        _SettingsGroup(
                          items: [
                            _SettingsRow(
                              icon: Icons.kitchen_outlined,
                              title: 'Pantalla de cocina',
                              subtitle: 'Ver pedidos en preparacion',
                              onTap: () =>
                                  context.pushNamed(RouteNames.kitchen),
                            ),
                            _SettingsRow(
                              icon: Icons.delivery_dining_outlined,
                              title: 'Gestion de entregas',
                              subtitle: 'Pedidos pendientes de reparto',
                              onTap: () =>
                                  context.pushNamed(RouteNames.delivery),
                            ),
                            _SettingsRow(
                              icon: Icons.point_of_sale_outlined,
                              title: 'TPV / Mostrador',
                              subtitle: 'Tomar pedidos en caja',
                              onTap: () => context.pushNamed(RouteNames.pos),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Apariencia
                      const _SectionLabel('Apariencia'),
                      const SizedBox(height: 12),
                      _SettingsGroup(
                        items: [
                          _SettingsRow(
                            icon: Icons.dark_mode_outlined,
                            title: 'Modo oscuro',
                            subtitle: 'Cambiar aspecto de la app',
                            trailing: Switch(
                              value: isDarkMode,
                              activeThumbColor: AppTokens.brandPrimary,
                              onChanged: (v) => ref
                                  .read(themeNotifierProvider.notifier)
                                  .setMode(
                                    v ? ThemeMode.dark : ThemeMode.light,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Mis alergenos
                      const _SectionLabel('Mis alergenos'),
                      const SizedBox(height: 12),
                      _AllergensCard(
                        selected: profile.allergens,
                        options: _allergenOptions,
                        onToggle: (key) => _toggleAllergen(key, profile.allergens),
                      ),
                      const SizedBox(height: 32),

                      // Notificaciones
                      const _SectionLabel('Notificaciones'),
                      const SizedBox(height: 12),
                      _SettingsGroup(
                        items: [
                          _SettingsRow(
                            icon: Icons.receipt_outlined,
                            title: 'Estado de pedidos',
                            subtitle: 'Confirmar, preparando, listo...',
                            trailing: Switch(
                              value: _notifOrders,
                              activeThumbColor: AppTokens.brandPrimary,
                              onChanged: _setNotifOrders,
                            ),
                          ),
                          _SettingsRow(
                            icon: Icons.local_offer_outlined,
                            title: 'Ofertas y novedades',
                            subtitle: 'Plato del dia, promociones especiales',
                            trailing: Switch(
                              value: _notifOffers,
                              activeThumbColor: AppTokens.brandPrimary,
                              onChanged: _setNotifOffers,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Mis direcciones
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const _SectionLabel('Mis direcciones'),
                          TextButton.icon(
                            onPressed: () => _showAddAddressSheet(context),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Anadir'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTokens.brandPrimary,
                              textStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _AddressesSection(
                        onAddNew: () => _showAddAddressSheet(context),
                      ),
                      const SizedBox(height: 32),

                      // Mi cuenta
                      const _SectionLabel('Mi cuenta'),
                      const SizedBox(height: 12),
                      _SettingsGroup(
                        items: [
                          _NotificationsRow(),
                          _SettingsRow(
                            icon: Icons.receipt_long_outlined,
                            title: 'Mis pedidos',
                            subtitle: 'Historial y seguimiento',
                            onTap: () => context.pushNamed(RouteNames.orders),
                          ),
                          _SettingsRow(
                            icon: Icons.favorite_border,
                            title: 'Favoritos',
                            subtitle: 'Platos guardados',
                            onTap: () =>
                                context.pushNamed(RouteNames.favorites),
                          ),
                          _SettingsRow(
                            icon: Icons.forum_outlined,
                            title: 'Mis consultas',
                            subtitle: 'Mensajes y soporte interno',
                            onTap: () =>
                                context.pushNamed(RouteNames.myConsultations),
                          ),
                          _SettingsRow(
                            icon: Icons.celebration_outlined,
                            title: 'Mis encargos de catering',
                            subtitle: 'Solicitudes y estado de eventos',
                            onTap: () => context.pushNamed(
                              RouteNames.myCateringRequests,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Cerrar sesion
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _signOut(context),
                          icon: const Icon(
                            Icons.logout,
                            color: AppTokens.danger,
                          ),
                          label: const Text(
                            'Cerrar sesion',
                            style: TextStyle(
                              color: AppTokens.danger,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppTokens.danger,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: const StadiumBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
                const SliverToBoxAdapter(child: WebFooter()),
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

// Hero header

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.name,
    required this.email,
    required this.role,
  });

  final String? name;
  final String email;
  final String role;

  String get _initials {
    final n = name?.trim() ?? '';
    if (n.isEmpty) return '?';
    final parts = n.split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _kBgDark,
      child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
          child: Row(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppTokens.brandPrimary.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTokens.brandPrimary.withValues(alpha: 0.6),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w900, 
                    fontSize: 32,
                    color: _kCream,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (name?.isNotEmpty ?? false) ? name! : 'Bienvenido',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w900, 
                        fontSize: 26,
                        color: _kCream,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(color: _kMuted, fontSize: 13),
                    ),
                    if (role != 'client') ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTokens.brandPrimary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
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

// Section label

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: _textMuted(context),
        ),
      ),
    );
  }
}

// Personal data card

class _PersonalDataCard extends StatelessWidget {
  const _PersonalDataCard({
    required this.formKey,
    required this.fullNameCtrl,
    required this.phoneCtrl,
    required this.isLoading,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameCtrl;
  final TextEditingController phoneCtrl;
  final bool isLoading;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor(context)),
      ),
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              controller: fullNameCtrl,
              decoration: InputDecoration(
                labelText: 'Nombre completo',
                prefixIcon: const Icon(Icons.person_outline),
                filled: true,
                fillColor: AppTokens.brandLight,
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
              validator: (value) {
                final requiredError = Validators.required(value);
                if (requiredError != null) return requiredError;
                return Validators.maxLength(value, 80);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Telefono',
                prefixIcon: const Icon(Icons.phone_outlined),
                filled: true,
                fillColor: AppTokens.brandLight,
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
              validator: Validators.phone,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isLoading ? null : onSave,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Actualizar datos'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTokens.brandPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
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

// Settings group

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.items});
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor(context)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1)
              Divider(height: 1, indent: 56, color: _dividerColor(context)),
          ],
        ],
      ),
    );
  }
}

// Settings row

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTokens.brandLight,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: AppTokens.brandPrimary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: _textMain(context),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: _textMuted(context),
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Color(0xFFBBBBB8),
              ),
          ],
        ),
      ),
    );
  }
}

// Notifications row with badge

class _NotificationsRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationsCountProvider);
    return InkWell(
      onTap: () => context.pushNamed(RouteNames.notifications),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTokens.brandLight,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    color: AppTokens.brandPrimary,
                    size: 20,
                  ),
                  if (unread > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            unread > 9 ? '9+' : '$unread',
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notificaciones',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: _textMain(context),
                    ),
                  ),
                  Text(
                    unread > 0
                        ? '$unread sin leer'
                        : 'Al dia con tus avisos',
                    style: TextStyle(
                      fontSize: 12,
                      color: _textMuted(context),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Color(0xFFBBBBB8),
            ),
          ],
        ),
      ),
    );
  }
}

// Allergens card

class _AllergensCard extends StatelessWidget {
  const _AllergensCard({
    required this.selected,
    required this.options,
    required this.onToggle,
  });

  final List<String> selected;
  final List<(String, String)> options;
  final void Function(String key) onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Marca los alergenos que tienes. Te avisaremos en los platos que los contengan.',
            style: TextStyle(color: _textMuted(context), fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map(((String, String) opt) {
              final (key, label) = opt;
              final isSelected = selected.contains(key);
              return FilterChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (_) => onToggle(key),
                selectedColor: AppTokens.brandPrimary.withValues(alpha: 0.15),
                checkmarkColor: AppTokens.brandPrimary,
                backgroundColor: const Color(0xFFF5F5F3),
                side: BorderSide(
                  color: isSelected
                      ? AppTokens.brandPrimary.withValues(alpha: 0.5)
                      : const Color(0xFFDDDDDA),
                  width: 1.5,
                ),
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppTokens.brandDark
                      : const Color(0xFF444441),
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                shape: const StadiumBorder(),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// Addresses section

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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _cardBg(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _borderColor(context)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.location_off_outlined,
                  size: 40,
                  color: Color(0xFFCCCCC8),
                ),
                const SizedBox(height: 8),
                Text(
                  'Aun no tienes direcciones guardadas',
                  style: TextStyle(color: _textMuted(context)),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: onAddNew,
                  icon: const Icon(Icons.add),
                  label: const Text('Anadir direccion'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTokens.brandPrimary,
                    side: const BorderSide(color: AppTokens.brandPrimary),
                    shape: const StadiumBorder(),
                  ),
                ),
              ],
            ),
          );
        }
        return Column(
          children: addresses.map((addr) {
            final label = addr['label'] as String? ?? 'Direccion';
            final street = addr['street'] as String? ?? '';
            final city = addr['city'] as String? ?? '';
            final postalCode = addr['postal_code'] as String? ?? '';
            final isDefault = addr['is_default'] as bool? ?? false;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: _cardBg(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDefault
                        ? AppTokens.brandPrimary.withValues(alpha: 0.5)
                        : _borderColor(context),
                    width: isDefault ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDefault
                            ? AppTokens.brandPrimary.withValues(alpha: 0.12)
                            : AppTokens.brandLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.location_on_outlined,
                        color: isDefault
                            ? AppTokens.brandPrimary
                            : _textMuted(context),
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
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: _textMain(context),
                                ),
                              ),
                              if (isDefault) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTokens.brandPrimary,
                                    borderRadius: BorderRadius.circular(20),
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
                            style: TextStyle(
                              color: _textMuted(context),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppTokens.danger,
                        size: 20,
                      ),
                      tooltip: 'Eliminar',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text('Eliminar direccion?'),
                            content: Text(
                              'Seguro que deseas eliminar "$label"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancelar'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppTokens.danger,
                                  shape: const StadiumBorder(),
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

class _ProfileSupportThreadsCard extends ConsumerWidget {
  const _ProfileSupportThreadsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threadsAsync = ref.watch(mySupportThreadsProvider);
    return Container(
      decoration: BoxDecoration(
        color: _cardBg(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor(context)),
      ),
      child: threadsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: LoadingIndicator()),
        ),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(18),
          child: Text(
            'No se han podido cargar tus conversaciones: $error',
            style: TextStyle(color: _textMuted(context), fontSize: 13),
          ),
        ),
        data: (threads) {
          if (threads.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aun no tienes conversaciones internas.',
                    style: TextStyle(
                      color: _textMuted(context),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => context.pushNamed(RouteNames.myConsultations),
                    icon: const Icon(Icons.add_comment_outlined, size: 16),
                    label: const Text('Abrir consulta'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTokens.brandPrimary,
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                for (final thread in threads.take(3))
                  _SupportThreadTile(
                    thread: thread,
                    onTap: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => _ThreadDetailSheet(thread: thread),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => context.pushNamed(RouteNames.myConsultations),
                    icon: const Icon(Icons.forum_outlined, size: 16),
                    label: const Text('Ver todas mis consultas'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTokens.brandPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SupportThreadTile extends StatelessWidget {
  const _SupportThreadTile({required this.thread, this.onTap});

  final SupportThread thread;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final unread = thread.unreadForCustomer;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF222222)
              : const Color(0xFFFAF8F4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor(context)),
        ),
        child: Row(
          children: [
            const Icon(Icons.support_agent_outlined, color: AppTokens.brandPrimary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thread.subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _textMain(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    thread.lastMessage ?? 'Sin mensajes',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: _textMuted(context), fontSize: 12),
                  ),
                ],
              ),
            ),
            if (unread > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTokens.brandPrimary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: AppTokens.brandPrimary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ThreadDetailSheet extends ConsumerStatefulWidget {
  const _ThreadDetailSheet({required this.thread});
  final SupportThread thread;

  @override
  ConsumerState<_ThreadDetailSheet> createState() => _ThreadDetailSheetState();
}

class _ThreadDetailSheetState extends ConsumerState<_ThreadDetailSheet> {
  final _replyCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    final body = _replyCtrl.text.trim();
    if (body.isEmpty) return;
    setState(() => _sending = true);
    try {
      await ref
          .read(supportActionProvider.notifier)
          .sendMessage(threadId: widget.thread.id, body: body, asAdmin: false);
      _replyCtrl.clear();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(supportMessagesProvider(widget.thread.id));
    final closed = widget.thread.status == 'closed';
    final maxH = MediaQuery.of(context).size.height * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: BoxDecoration(
        color: _cardBg(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _borderColor(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.thread.subject,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _textMain(context),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: closed
                        ? const Color(0xFFEDE8E1)
                        : AppTokens.brandLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    closed ? 'Cerrado' : 'Abierto',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: closed ? const Color(0xFF9A9188) : AppTokens.brandPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Messages
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: LoadingIndicator()),
              error: (e, _) => Center(
                child: Text('Error al cargar mensajes', style: TextStyle(color: _textMuted(context))),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay mensajes aún.',
                      style: TextStyle(color: _textMuted(context), fontSize: 13),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final msg = messages[i];
                    final fromAdmin = msg.senderRole == 'admin';
                    return Align(
                      alignment: fromAdmin ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 320),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: fromAdmin ? AppTokens.brandPrimary : const Color(0xFFF3F0EC),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fromAdmin ? 'Admin' : 'Tú',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: fromAdmin ? Colors.white70 : AppTokens.brandPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              msg.body,
                              style: TextStyle(
                                fontSize: 13,
                                color: fromAdmin ? Colors.white : _textMain(context),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Reply box or closed notice
          if (closed)
            Padding(
              padding: EdgeInsets.fromLTRB(
                16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 16),
              child: Text(
                'Conversación cerrada · El equipo la ha marcado como resuelta.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: _textMuted(context)),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.fromLTRB(
                12, 8, 12, MediaQuery.of(context).viewInsets.bottom + 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyCtrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendReply(),
                      decoration: InputDecoration(
                        hintText: 'Escribe tu respuesta...',
                        hintStyle: TextStyle(color: _textMuted(context), fontSize: 13),
                        filled: true,
                        fillColor: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF2A2A2A)
                            : const Color(0xFFF5F2ED),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _sendReply,
                    style: IconButton.styleFrom(backgroundColor: AppTokens.brandPrimary),
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Add address sheet

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
            Text(
              'Nueva direccion',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _textMain(context),
              ),
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
              'Calle y numero',
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
                    'Codigo postal',
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
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
                label: const Text('Guardar direccion'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTokens.brandPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
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
        fillColor: AppTokens.brandLight,
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
