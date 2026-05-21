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
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: WebNavbar(
          isScrolled: _isScrolled,
          activeRoute: RouteNames.contact,
        ),
      ),
      body: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          // ── Hero ─────────────────────────────────────────────────────────
          const SliverToBoxAdapter(child: _HeroBanner()),

          // ── Strip de contacto ─────────────────────────────────────────────
          const SliverToBoxAdapter(child: _ContactStrip()),

          // ── Formulario ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: ColoredBox(
              color: const Color(0xFFF4F6F2),
              child: Padding(
                padding: EdgeInsets.fromLTRB(sidePad + 24, 72, sidePad + 24, 72),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: _buildForm(submitState),
                  ),
                ),
              ),
            ),
          ),

          // ── Horarios ─────────────────────────────────────────────────────
          SliverToBoxAdapter(child: _ScheduleSection(sidePad: sidePad)),

          // ── FAQ ───────────────────────────────────────────────────────────
          SliverToBoxAdapter(child: _FaqSection(sidePad: sidePad)),

          // ── Mapa ─────────────────────────────────────────────────────────
          const SliverToBoxAdapter(child: LocationSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
          const SliverToBoxAdapter(child: WebFooter()),
        ],
      ),
    );
  }

  Widget _buildForm(AsyncValue<void> submitState) {
    final screenW = MediaQuery.sizeOf(context).width;
    final twoCol = screenW >= 600;
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              'Envíanos un mensaje',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1A1A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Te respondemos en menos de 24 horas.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.black45),
            ),
            const SizedBox(height: 32),
            // Fila 1: nombre + email
            if (twoCol)
              Row(children: [
                Expanded(
                  child: _Field(
                    controller: _nameCtrl,
                    label: 'Nombre completo',
                    icon: Icons.person_outline,
                    validator: (v) => Validators.required(v) ?? Validators.maxLength(v, 100),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _Field(
                    controller: _emailCtrl,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                ),
              ])
            else ...[
              _Field(
                controller: _nameCtrl,
                label: 'Nombre completo',
                icon: Icons.person_outline,
                validator: (v) => Validators.required(v) ?? Validators.maxLength(v, 100),
              ),
              const SizedBox(height: 14),
              _Field(
                controller: _emailCtrl,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
            ],
            const SizedBox(height: 14),
            // Fila 2: teléfono + tipo
            if (twoCol)
              Row(children: [
                Expanded(
                  child: _Field(
                    controller: _phoneCtrl,
                    label: 'Teléfono',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: Validators.phone,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildDropdown(),
                ),
              ])
            else ...[
              _Field(
                controller: _phoneCtrl,
                label: 'Teléfono',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: Validators.phone,
              ),
              const SizedBox(height: 14),
              _buildDropdown(),
            ],
            const SizedBox(height: 14),
            _Field(
              controller: _messageCtrl,
              label: 'Tu mensaje',
              icon: Icons.chat_bubble_outline,
              maxLines: 5,
              validator: (v) => Validators.required(v) ?? Validators.maxLength(v, 1000),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
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
                              fontSize: 16,
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

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedType,
      decoration: InputDecoration(
        labelText: 'Tipo de consulta',
        labelStyle: GoogleFonts.inter(fontSize: 14, color: Colors.black45),
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
          borderSide: const BorderSide(color: AppTokens.brandPrimary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: ['Consulta general', 'Propuesta de evento', 'Oferta de trabajo', 'Colaboración', 'Otro']
          .map((t) => DropdownMenuItem(
                value: t,
                child: Text(t, style: GoogleFonts.inter(fontSize: 14)),
              ))
          .toList(),
      onChanged: (v) => setState(() => _selectedType = v),
      validator: (v) => v == null ? 'Selecciona un tipo de consulta' : null,
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

// ── Hero banner ───────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          // Fondo verde
          const Positioned.fill(child: ColoredBox(color: AppTokens.brandDark)),
          // Círculo decorativo top-right
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          // Círculo decorativo bottom-left
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Círculo decorativo center
          Positioned(
            top: 30,
            left: screenW * 0.35,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),
          // Contenido
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenW > 1200 ? (screenW - 1200) / 2 + 24 : 24,
              vertical: 80,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    'CONTACTO',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTokens.brandLight,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '¿Hablamos?', 
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: screenW < 600 ? 44 : 68,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -2,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 20),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Text(
                    'Si tienes dudas sobre tu pedido, nuestros platos '
                    'o quieres dejarnos algún comentario, estamos aquí.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.72),
                      height: 1.65,
                    ),
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

// ── Strip de contacto ─────────────────────────────────────────────────────────

class _ContactStrip extends StatelessWidget {
  const _ContactStrip();

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final isWide = screenW >= 700;
    return ColoredBox(
      color: Colors.white,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE8EBE5))),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: screenW > 1200 ? (screenW - 1200) / 2 + 24 : 24,
          vertical: 32,
        ),
        child: isWide
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ContactItem(
                    icon: Icons.phone_outlined,
                    label: 'Teléfono',
                    value: '+34 900 123 456',
                  ),
                  _StripDivider(),
                  _ContactItem(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: 'info@sabordecasa.com',
                  ),
                  _StripDivider(),
                  _ContactItem(
                    icon: Icons.location_on_outlined,
                    label: 'Dirección',
                    value: 'Sanlúcar de Barrameda',
                  ),
                  _StripDivider(),
                  _ContactItem(
                    icon: Icons.access_time,
                    label: 'Horario',
                    value: 'L–D · 12:00 – 23:30',
                  ),
                ],
              )
            : const Wrap(
                spacing: 24,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  _ContactItem(
                    icon: Icons.phone_outlined,
                    label: 'Teléfono',
                    value: '+34 900 123 456',
                  ),
                  _ContactItem(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: 'info@sabordecasa.com',
                  ),
                  _ContactItem(
                    icon: Icons.access_time,
                    label: 'Horario',
                    value: 'L–D · 12:00 – 23:30',
                  ),
                ],
              ),
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  const _ContactItem({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTokens.brandPrimary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTokens.brandPrimary, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.black38,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StripDivider extends StatelessWidget {
  const _StripDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 36, width: 1, color: const Color(0xFFE5E8E3));
  }
}

// ── Horarios ──────────────────────────────────────────────────────────────────

class _ScheduleSection extends StatelessWidget {
  const _ScheduleSection({required this.sidePad});
  final double sidePad;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    return ColoredBox(
      color: AppTokens.brandDark,
      child: Padding(
        padding: EdgeInsets.fromLTRB(sidePad + 24, 72, sidePad + 24, 72),
        child: Column(
          children: [
            Text(
              'Horarios',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: screenW < 600 ? 32 : 40,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cocinamos con pasión todos los días de la semana.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 40),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: _ScheduleGrid(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Lunes – Domingo', '12:00 – 23:30', true),
      ('Cocina abierta', 'Hasta las 23:00', false),
      ('Reparto a domicilio', '12:00 – 22:30', false),
      ('Reservas online', 'Hasta las 21:00', false),
    ];
    return Column(
      children: rows.map((r) {
        final highlight = r.$3;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: highlight
                ? Colors.white.withValues(alpha: 0.13)
                : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: highlight
                ? Border.all(
                    color: AppTokens.brandLight.withValues(alpha: 0.35))
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  r.$1,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight:
                        highlight ? FontWeight.w700 : FontWeight.w500,
                    color: highlight
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ),
              Text(
                r.$2,
                style: GoogleFonts.inter(
                  fontSize: highlight ? 16 : 15,
                  fontWeight: FontWeight.w700,
                  color: highlight
                      ? AppTokens.brandLight
                      : Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── FAQ ───────────────────────────────────────────────────────────────────────

class _FaqSection extends StatelessWidget {
  const _FaqSection({required this.sidePad});
  final double sidePad;

  static const _items = [
    (
      '¿Cómo puedo hacer un pedido?',
      'Puedes hacer tu pedido directamente desde nuestra app o web, en la sección Menú. Elige tus platos, añádelos al carrito y completa el pago de forma segura.'
    ),
    (
      '¿Realizáis envíos a domicilio?',
      'Sí, realizamos envíos a domicilio todos los días de 12:00 a 22:30. El tiempo estimado de entrega es de 30–45 minutos según la zona.'
    ),
    (
      '¿Puedo cancelar o modificar un pedido?',
      'Puedes cancelar o modificar tu pedido dentro de los primeros 5 minutos tras confirmarlo, desde el historial de pedidos de tu cuenta.'
    ),
    (
      '¿Tenéis opciones para celíacos o alérgicos?',
      'Sí. En cada plato del menú puedes ver los alérgenos detallados. Además, puedes filtrar el menú por alérgenos para ver solo los platos que se adaptan a ti.'
    ),
    (
      '¿Cómo funciona el servicio de catering?',
      'Nuestro servicio de catering está pensado para eventos privados y empresariales. Contáctanos con los detalles de tu evento y te preparamos un presupuesto personalizado.'
    ),
    (
      '¿Aceptáis reservas para comer en el local?',
      'De momento operamos exclusivamente con servicio a domicilio y recogida en local. Para recogida puedes indicarlo al hacer el pedido.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: EdgeInsets.fromLTRB(sidePad + 24, 72, sidePad + 24, 72),
      child: Column(
        children: [
          Text(
            'Preguntas frecuentes',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: screenW < 600 ? 28 : 40,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Resolvemos las dudas más habituales.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 15, color: Colors.black45),
          ),
          const SizedBox(height: 48),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenW > 1200 ? 760 : double.infinity,
            ),
            child: Column(
              children: _items
                  .map((item) => _FaqItem(question: item.$1, answer: item.$2))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  const _FaqItem({required this.question, required this.answer});
  final String question;
  final String answer;

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _expanded ? const Color(0xFFF0F7F3) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _expanded
              ? AppTokens.brandPrimary.withValues(alpha: 0.3)
              : const Color(0xFFE5E8E3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.question,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A1A),
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedRotation(
                      turns: _expanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.add,
                        color: _expanded
                            ? AppTokens.brandPrimary
                            : Colors.black38,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                if (_expanded) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.answer,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.65,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Campo de texto reutilizable ───────────────────────────────────────────────

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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          borderSide: const BorderSide(color: AppTokens.brandPrimary, width: 1.5),
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
