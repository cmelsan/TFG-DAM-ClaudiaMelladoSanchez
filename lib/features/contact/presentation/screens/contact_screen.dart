import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/validators.dart';
import 'package:sabor_de_casa/core/widgets/location_section.dart';
import 'package:sabor_de_casa/core/widgets/web_footer.dart';
import 'package:sabor_de_casa/core/widgets/web_navbar.dart';
import 'package:sabor_de_casa/features/contact/presentation/providers/contact_provider.dart';

class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({super.key});

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _selectedType;
  final _messageCtrl = TextEditingController();
  late final ScrollController _scrollCtrl;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController()
      ..addListener(() {
        final scrolled = _scrollCtrl.offset > 10;
        if (scrolled != _isScrolled) setState(() => _isScrolled = scrolled);
      });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(contactSubmitProvider);
    final screenW = MediaQuery.sizeOf(context).width;
    const maxW = 1200.0;
    final sidePad = screenW > maxW ? (screenW - maxW) / 2 : 0.0;
    final isWide = screenW >= 800;

    ref.listen(contactSubmitProvider, (prev, next) {
      if ((prev?.isLoading ?? false) && next.hasValue) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Mensaje enviado. Nos pondremos en contacto pronto.',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppTokens.brandPrimary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _formKey.currentState?.reset();
        _nameCtrl.clear();
        _emailCtrl.clear();
        _phoneCtrl.clear();
        _messageCtrl.clear();
        setState(() => _selectedType = null);
      }
    });

    return Scaffold(
      backgroundColor: AppTokens.pageBg,
      body: CustomScrollView(
        slivers: [
          // ── AppBar fijo ───────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTokens.brandDark,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'Contacto',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            centerTitle: false,
          ),

          // ── Hero banner ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: ColoredBox(
              color: AppTokens.brandDark,
              child: Padding(
                padding: EdgeInsets.fromLTRB(sidePad + 24, 48, sidePad + 24, 52),
                child: Column(
                  children: [
                    Text(
                      '¿Hablamos?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1.5,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Si tienes dudas sobre tu pedido, sobre nuestros platos\no quieres dejarnos algo de feedback, escríbenos.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.72),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Info rápida en chips
                    const Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _InfoChip(icon: Icons.phone_outlined, label: '+34 900 123 456'),
                        _InfoChip(icon: Icons.email_outlined, label: 'info@sabordecasa.com'),
                        _InfoChip(icon: Icons.access_time, label: 'L-D · 12:00 – 23:30'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Cuerpo principal ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(sidePad + 24, 40, sidePad + 24, 0),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Columna izquierda – info
                        SizedBox(width: 320, child: _InfoCard()),
                        const SizedBox(width: 32),
                        // Columna derecha – formulario
                        Expanded(child: _buildForm(submitState)),
                      ],
                    )
                  : Column(
                      children: [
                        _InfoCard(),
                        const SizedBox(height: 24),
                        _buildForm(submitState),
                      ],
                    ),
            ),
          ),

          // ── Sección mapa ──────────────────────────────────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
          const SliverToBoxAdapter(child: LocationSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
          const SliverToBoxAdapter(child: WebFooter()),
        ],
      ),
    );
  }

  Widget _buildForm(AsyncValue<void> submitState) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Envíanos un mensaje',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Te respondemos en menos de 24 horas.',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.black45),
            ),
            const SizedBox(height: 24),
            _Field(
              controller: _nameCtrl,
              label: 'Nombre completo',
              icon: Icons.person_outline,
              validator: (v) =>
                  Validators.required(v) ?? Validators.maxLength(v, 100),
            ),
            const SizedBox(height: 14),
            _Field(
              controller: _emailCtrl,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
            ),
            const SizedBox(height: 14),
            _Field(
              controller: _phoneCtrl,
              label: 'Teléfono',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: Validators.phone,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: InputDecoration(
                labelText: 'Tipo de consulta',
                labelStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.black45,
                ),
                prefixIcon: const Icon(Icons.help_outline, color: Colors.black38, size: 20),
                filled: true,
                fillColor: AppTokens.pageBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTokens.brandPrimary,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              items: [
                'Consulta general',
                'Propuesta de evento',
                'Oferta de trabajo',
                'Colaboración',
                'Otro',
              ]
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t, style: GoogleFonts.inter(fontSize: 14)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedType = v),
              validator: (v) =>
                  v == null ? 'Selecciona un tipo de consulta' : null,
            ),
            const SizedBox(height: 14),
            _Field(
              controller: _messageCtrl,
              label: 'Tu mensaje',
              icon: Icons.chat_bubble_outline,
              maxLines: 5,
              validator: (v) =>
                  Validators.required(v) ?? Validators.maxLength(v, 1000),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: submitState.isLoading ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTokens.brandPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: submitState.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_outlined, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            'Enviar mensaje',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(contactSubmitProvider.notifier).submit(
          name: _nameCtrl.text,
          email: _emailCtrl.text,
          phone: _phoneCtrl.text,
          subject: _selectedType!,
          message: _messageCtrl.text,
        );
  }
}

// ── Info card lateral ──────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTokens.brandDark,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTokens.brandDark.withValues(alpha: 0.30),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿En qué podemos\nayudarte?',
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Estamos aquí para lo que necesites.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 28),
          const _ContactRow(
            icon: Icons.phone_outlined,
            title: 'Teléfono',
            value: '+34 900 123 456',
          ),
          const _Divider(),
          const _ContactRow(
            icon: Icons.email_outlined,
            title: 'Email',
            value: 'info@sabordecasa.com',
          ),
          const _Divider(),
          const _ContactRow(
            icon: Icons.access_time,
            title: 'Horario',
            value: 'L a D · 12:00 – 23:30',
          ),
          const _Divider(),
          const _ContactRow(
            icon: Icons.location_on_outlined,
            title: 'Dirección',
            value: 'Calle Ejemplo, 12\nSanlúcar de Barrameda',
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.title,
    required this.value,
  });
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTokens.brandLight, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.55),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Colors.white.withValues(alpha: 0.10),
      height: 1,
    );
  }
}

// ── Chip de info rápida en el banner ───────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTokens.brandLight, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Campo de texto reutilizable ────────────────────────────────────────────────

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.inter(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(fontSize: 14, color: Colors.black45),
        alignLabelWithHint: maxLines > 1,
        prefixIcon: Icon(icon, color: Colors.black38, size: 20),
        filled: true,
        fillColor: AppTokens.pageBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTokens.brandPrimary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}
