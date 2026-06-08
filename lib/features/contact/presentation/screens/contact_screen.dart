import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/utils/validators.dart';
import 'package:sabor_de_casa/core/widgets/web_footer.dart';
import 'package:sabor_de_casa/core/widgets/web_navbar.dart';
import 'package:sabor_de_casa/features/auth/presentation/providers/auth_provider.dart';
import 'package:sabor_de_casa/features/contact/presentation/providers/contact_provider.dart';
import 'package:sabor_de_casa/features/support/domain/models/support_thread.dart';
import 'package:sabor_de_casa/features/support/presentation/providers/support_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({super.key});

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supportFormKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _supportNameCtrl = TextEditingController();
  final _supportEmailCtrl = TextEditingController();
  final _supportSubjectCtrl = TextEditingController();
  final _supportMessageCtrl = TextEditingController();
  late final ScrollController _scrollCtrl;

  String? _selectedType;
  bool _isScrolled = false;

  static const _whatsAppPhone = '34658284920';

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
    _supportNameCtrl.dispose();
    _supportEmailCtrl.dispose();
    _supportSubjectCtrl.dispose();
    _supportMessageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(contactSubmitProvider);
    final supportState = ref.watch(supportActionProvider);
    final profile = ref.watch(authNotifierProvider).valueOrNull;
    if (profile != null) {
      if (_supportNameCtrl.text.isEmpty) _supportNameCtrl.text = profile.fullName ?? '';
      if (_supportEmailCtrl.text.isEmpty) _supportEmailCtrl.text = profile.email;
    }
    final screenW = MediaQuery.sizeOf(context).width;
    const maxW = 1180.0;
    final sidePad = screenW > maxW ? (screenW - maxW) / 2 : 0.0;

    ref
      ..listen(contactSubmitProvider, (prev, next) {
        if ((prev?.isLoading ?? false) && next.hasValue) {
          _showSnack('Correo enviado. Te responderemos en tu bandeja de entrada.');
          _formKey.currentState?.reset();
          _nameCtrl.clear();
          _emailCtrl.clear();
          _phoneCtrl.clear();
          _messageCtrl.clear();
          setState(() => _selectedType = null);
        }
        if ((prev?.isLoading ?? false) && next.hasError) {
          _showSnack('No se ha podido enviar el formulario.', isError: true);
        }
      })
      ..listen(supportActionProvider, (prev, next) {
        if ((prev?.isLoading ?? false) && next.hasValue) {
          _supportFormKey.currentState?.reset();
          _supportSubjectCtrl.clear();
          _supportMessageCtrl.clear();
          _showSnack('Mensaje enviado. El equipo lo revisara y te respondera pronto.');
        }
        if ((prev?.isLoading ?? false) && next.hasError) {
          _showSnack('No se ha podido abrir la conversacion.', isError: true);
        }
      });

    return Scaffold(
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
          SliverToBoxAdapter(
            child: _HeroSection(
              sidePad: sidePad,
              onWhatsApp: _openWhatsApp,
              onInternal: () => _scrollTo(760),
            ),
          ),
          SliverToBoxAdapter(
            child: _ChannelSection(
              sidePad: sidePad,
              onWhatsApp: () => _openWhatsApp(topic: 'consulta general'),
              onForm: () => _scrollTo(1320),
              onSupport: () => _scrollTo(760),
            ),
          ),
          SliverToBoxAdapter(
            child: _SupportSection(
              sidePad: sidePad,
              isLoggedIn: profile != null,
              formKey: _supportFormKey,
              nameCtrl: _supportNameCtrl,
              emailCtrl: _supportEmailCtrl,
              subjectCtrl: _supportSubjectCtrl,
              messageCtrl: _supportMessageCtrl,
              isLoading: supportState.isLoading,
              onSubmit: _submitSupport,
              onLogin: () => context.goNamed(RouteNames.login),
            ),
          ),
          SliverToBoxAdapter(
            child: _FormSection(
              sidePad: sidePad,
              formKey: _formKey,
              nameCtrl: _nameCtrl,
              emailCtrl: _emailCtrl,
              phoneCtrl: _phoneCtrl,
              messageCtrl: _messageCtrl,
              selectedType: _selectedType,
              submitState: submitState,
              onTypeChanged: (value) => setState(() => _selectedType = value),
              onSubmit: _submitPublicForm,
            ),
          ),
          SliverToBoxAdapter(child: _InfoSection(sidePad: sidePad)),
          const SliverToBoxAdapter(child: WebFooter()),
        ],
      ),
    );
  }

  Future<void> _openWhatsApp({String? topic}) async {
    final message =
        'Hola, soy cliente de Sabor de Casa. Quiero hacer una ${topic ?? 'consulta'}.';
    final uri = Uri.https('wa.me', '/$_whatsAppPhone', {'text': message});
    unawaited(launchUrl(uri, mode: LaunchMode.externalApplication));
  }

  Future<void> _submitPublicForm() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(contactSubmitProvider.notifier)
        .submit(
          name: _nameCtrl.text,
          email: _emailCtrl.text,
          phone: _phoneCtrl.text,
          subject: _selectedType!,
          message: _messageCtrl.text,
        );
  }

  Future<void> _submitSupport() async {
    if (!_supportFormKey.currentState!.validate()) return;
    await ref
        .read(supportActionProvider.notifier)
        .createThread(
          subject: _supportSubjectCtrl.text,
          category: 'general',
          message: _supportMessageCtrl.text,
        );
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        backgroundColor: isError ? AppTokens.danger : AppTokens.brandPrimary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _scrollTo(double offset) {
    _scrollCtrl.animateTo(
      offset,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.sidePad,
    required this.onWhatsApp,
    required this.onInternal,
  });
  final double sidePad;
  final VoidCallback onWhatsApp;
  final VoidCallback onInternal;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 860;
    return ColoredBox(
      color: const Color(0xFFF7FAF6),
      child: Padding(
        padding: EdgeInsets.fromLTRB(sidePad + 24, 44, sidePad + 24, 56),
        child: compact
            ? Column(
                children: [
                  _HeroCopy(onWhatsApp: onWhatsApp, onInternal: onInternal),
                  const SizedBox(height: 34),
                  const _HeroVisual(),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: _HeroCopy(
                      onWhatsApp: onWhatsApp,
                      onInternal: onInternal,
                    ),
                  ),
                  const SizedBox(width: 42),
                  const Expanded(child: _HeroVisual()),
                ],
              ),
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.onWhatsApp, required this.onInternal});
  final VoidCallback onWhatsApp;
  final VoidCallback onInternal;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Column(
      crossAxisAlignment: width < 860
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        const _TinyLabel(label: 'CONTACTO Y SOPORTE'),
        const SizedBox(height: 18),
        Text(
          'Hablemos sin perder el hilo.',
          textAlign: width < 860 ? TextAlign.center : TextAlign.start,
          style: GoogleFonts.inter(
            fontSize: width < 620 ? 42 : 68,
            height: 0.96,
            fontWeight: FontWeight.w900,
            color: AppTokens.surfaceDark,
          ),
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            'Dudas de pedidos, catering e incidencias desde un panel interno. Para algo urgente, WhatsApp queda a un toque.',
            textAlign: width < 860 ? TextAlign.center : TextAlign.start,
            style: GoogleFonts.inter(
              fontSize: 16,
              height: 1.65,
              color: const Color(0xFF5E655F),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: width < 860 ? WrapAlignment.center : WrapAlignment.start,
          children: [
            _HeroButton(
              label: 'Abrir WhatsApp',
              icon: Icons.chat_rounded,
              onTap: onWhatsApp,
              filled: true,
            ),
            _HeroButton(
              label: 'Soporte interno',
              icon: Icons.forum_rounded,
              onTap: onInternal,
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SizedBox(
          height: 430,
          child: Container(
            decoration: BoxDecoration(
              color: AppTokens.surfaceDark,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppTokens.brandDark.withValues(alpha: 0.18),
                  blurRadius: 36,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/movilopiniones.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.centerRight,
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTokens.surfaceDark.withValues(alpha: 0.94),
                          AppTokens.surfaceDark.withValues(alpha: 0.64),
                          AppTokens.brandPrimary.withValues(alpha: 0.16),
                        ],
                        stops: const [0, 0.58, 1],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/logo_bueno.png', width: 122),
                      const Spacer(),
                      const _ChatBubble(
                        label: 'Cliente',
                        text: 'Necesito cambiar la hora de recogida.',
                      ),
                      const SizedBox(height: 10),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: _ChatBubble(
                          label: 'Admin',
                          text: 'Te lo gestionamos desde aqui.',
                          incoming: false,
                        ),
                      ),
                      const SizedBox(height: 26),
                      const Row(
                        children: [
                          _MetricPill(label: '< 24 h', value: 'Respuesta'),
                          SizedBox(width: 10),
                          _MetricPill(label: '4', value: 'Canales'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChannelSection extends StatelessWidget {
  const _ChannelSection({
    required this.sidePad,
    required this.onWhatsApp,
    required this.onForm,
    required this.onSupport,
  });
  final double sidePad;
  final VoidCallback onWhatsApp;
  final VoidCallback onForm;
  final VoidCallback onSupport;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 980
        ? 4
        : width >= 640
        ? 2
        : 1;
    final cards = [
      _ChannelData(
        Icons.forum_rounded,
        'Escríbenos un mensaje',
        'Rellena el formulario con tu consulta y conserva la respuesta en tu cuenta.',
        'Ir al formulario',
        onSupport,
      ),
      _ChannelData(
        Icons.chat_rounded,
        'WhatsApp rapido',
        'Para dudas urgentes sobre pedidos de hoy o recogidas.',
        'Escribir ahora',
        onWhatsApp,
      ),
      _ChannelData(
        Icons.mail_outline_rounded,
        'Correo electronico',
        'Contactanos por email sin cuenta. Te respondemos en tu bandeja de entrada.',
        'Enviar correo',
        onForm,
      ),
      _ChannelData(
        Icons.celebration_rounded,
        'Catering',
        'Eventos y presupuestos desde el flujo especializado.',
        'Ver catering',
        () => context.goNamed(RouteNames.catering),
      ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(sidePad + 24, 42, sidePad + 24, 28),
      child: Column(
        children: [
          Text(
            'Elige el canal que encaja con tu consulta',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: width < 620 ? 30 : 40,
              fontWeight: FontWeight.w900,
              color: AppTokens.surfaceDark,
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: 220,
            ),
            itemCount: cards.length,
            itemBuilder: (_, index) => _ChannelCard(data: cards[index]),
          ),
        ],
      ),
    );
  }
}

class _SupportSection extends ConsumerWidget {
  const _SupportSection({
    required this.sidePad,
    required this.isLoggedIn,
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.subjectCtrl,
    required this.messageCtrl,
    required this.isLoading,
    required this.onSubmit,
    required this.onLogin,
  });

  final double sidePad;
  final bool isLoggedIn;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController subjectCtrl;
  final TextEditingController messageCtrl;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threadsAsync = isLoggedIn
        ? ref.watch(mySupportThreadsProvider)
        : null;
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 940;
    return ColoredBox(
      color: const Color(0xFF10251F),
      child: Padding(
        padding: EdgeInsets.fromLTRB(sidePad + 24, 70, sidePad + 24, 72),
        child: wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _SupportIntro(
                      isLoggedIn: isLoggedIn,
                      onLogin: onLogin,
                    ),
                  ),
                  const SizedBox(width: 28),
                  Expanded(
                    child: _SupportComposer(
                      formKey: formKey,
                      nameCtrl: nameCtrl,
                      emailCtrl: emailCtrl,
                      subjectCtrl: subjectCtrl,
                      messageCtrl: messageCtrl,
                      isLoggedIn: isLoggedIn,
                      isLoading: isLoading,
                      onSubmit: onSubmit,
                      onLogin: onLogin,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(child: _MyThreadsPanel(threadsAsync: threadsAsync)),
                ],
              )
            : Column(
                children: [
                  _SupportIntro(isLoggedIn: isLoggedIn, onLogin: onLogin),
                  const SizedBox(height: 22),
                  _SupportComposer(
                    formKey: formKey,
                    nameCtrl: nameCtrl,
                    emailCtrl: emailCtrl,
                    subjectCtrl: subjectCtrl,
                    messageCtrl: messageCtrl,
                    isLoggedIn: isLoggedIn,
                    isLoading: isLoading,
                    onSubmit: onSubmit,
                    onLogin: onLogin,
                  ),
                  const SizedBox(height: 18),
                  _MyThreadsPanel(threadsAsync: threadsAsync),
                ],
              ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.sidePad,
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.messageCtrl,
    required this.selectedType,
    required this.submitState,
    required this.onTypeChanged,
    required this.onSubmit,
  });

  final double sidePad;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController messageCtrl;
  final String? selectedType;
  final AsyncValue<void> submitState;
  final ValueChanged<String?> onTypeChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final twoCol = width >= 720;
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.fromLTRB(sidePad + 24, 72, sidePad + 24, 72),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Container(
              padding: EdgeInsets.all(width < 620 ? 22 : 34),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                border: Border.all(color: const Color(0xFFE7E1DA)),
                boxShadow: [AppTokens.cardShadow],
              ),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _TinyLabel(label: 'CORREO ELECTRONICO'),
                    const SizedBox(height: 12),
                    Text(
                      'Contactanos por correo',
                      style: GoogleFonts.inter(
                        fontSize: width < 620 ? 28 : 36,
                        fontWeight: FontWeight.w900,
                        color: AppTokens.surfaceDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Redacta tu mensaje y te respondemos directamente en tu bandeja de entrada. No necesitas tener cuenta.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF77716B),
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (twoCol)
                      Row(
                        children: [
                          Expanded(
                            child: _Field(
                              controller: nameCtrl,
                              label: 'Nombre completo',
                              icon: Icons.person_outline,
                              validator: (v) =>
                                  Validators.required(v) ??
                                  Validators.maxLength(v, 100),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _Field(
                              controller: emailCtrl,
                              label: 'Email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.email,
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _Field(
                        controller: nameCtrl,
                        label: 'Nombre completo',
                        icon: Icons.person_outline,
                        validator: (v) =>
                            Validators.required(v) ??
                            Validators.maxLength(v, 100),
                      ),
                      const SizedBox(height: 14),
                      _Field(
                        controller: emailCtrl,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                      ),
                    ],
                    const SizedBox(height: 14),
                    if (twoCol)
                      Row(
                        children: [
                          Expanded(
                            child: _Field(
                              controller: phoneCtrl,
                              label: 'Telefono',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: Validators.phone,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _TypeDropdown(
                              value: selectedType,
                              onChanged: onTypeChanged,
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _Field(
                        controller: phoneCtrl,
                        label: 'Telefono',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: Validators.phone,
                      ),
                      const SizedBox(height: 14),
                      _TypeDropdown(
                        value: selectedType,
                        onChanged: onTypeChanged,
                      ),
                    ],
                    const SizedBox(height: 14),
                    _Field(
                      controller: messageCtrl,
                      label: 'Tu mensaje',
                      icon: Icons.edit_note_rounded,
                      maxLines: 5,
                      validator: (v) =>
                          Validators.required(v) ??
                          Validators.maxLength(v, 1000),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: submitState.isLoading ? null : onSubmit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTokens.brandPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppTokens.radiusMd,
                            ),
                          ),
                        ),
                        icon: submitState.isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded),
                        label: Text(
                          submitState.isLoading
                              ? 'Enviando...'
                              : 'Enviar correo',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.sidePad});
  final double sidePad;

  static const _faq = [
    (
      '¿Que canal debo usar para cada caso?',
      'Usa soporte interno si tienes cuenta y quieres seguimiento en app. Usa correo para consultas generales. Usa WhatsApp para urgencias del mismo dia.',
    ),
    (
      '¿Formulario por correo requiere cuenta?',
      'No. Puedes escribir sin iniciar sesion y te responderemos en email que indiques.',
    ),
    (
      '¿Donde recibo respuesta si uso formulario por correo?',
      'Respuesta llega a bandeja de entrada del email que pongas en formulario. Revisa tambien spam o promociones.',
    ),
    (
      '¿Donde veo respuesta del soporte interno?',
      'Si abriste consulta interna, respuesta aparece en tus conversaciones dentro de perfil.',
    ),
    (
      '¿Puedo consultar catering desde contacto?',
      'Si, pero para presupuesto completo usa seccion Catering: ahi pedimos fecha, invitados y detalles de menu.',
    ),
    (
      '¿Cuanto tarda respuesta?',
      'Consultas se revisan en horario de servicio. Si incidencia urgente, escribe por WhatsApp.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: EdgeInsets.fromLTRB(sidePad + 24, 70, sidePad + 24, 70),
      child: Column(
        children: [
          Text(
            'Preguntas frecuentes',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: width < 620 ? 30 : 40,
              fontWeight: FontWeight.w900,
              color: AppTokens.surfaceDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Elige el canal adecuado y evita duplicar mensajes.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: const Color(0xFF77716B),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              children: _faq
                  .map((item) => _FaqTile(title: item.$1, text: item.$2))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportIntro extends StatelessWidget {
  const _SupportIntro({required this.isLoggedIn, required this.onLogin});
  final bool isLoggedIn;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _TinyLabel(label: 'SOPORTE INTERNO', dark: true),
        const SizedBox(height: 16),
        Text(
          'Escríbenos con tu consulta o incidencia.',
          style: GoogleFonts.inter(
            fontSize: 34,
            height: 1.04,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Para clientes registrados: rellena el formulario, el equipo lo revisara y podras ver la respuesta en tu perfil.',
          style: GoogleFonts.inter(
            fontSize: 15,
            height: 1.6,
            color: Colors.white.withValues(alpha: 0.72),
          ),
        ),
        if (!isLoggedIn) ...[
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: onLogin,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTokens.brandDark,
              minimumSize: const Size(0, 44),
            ),
            icon: const Icon(Icons.login_rounded),
            label: const Text('Iniciar sesion'),
          ),
        ],
      ],
    );
  }
}

class _SupportComposer extends StatelessWidget {
  const _SupportComposer({
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.subjectCtrl,
    required this.messageCtrl,
    required this.isLoggedIn,
    required this.isLoading,
    required this.onSubmit,
    required this.onLogin,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController subjectCtrl;
  final TextEditingController messageCtrl;
  final bool isLoggedIn;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Envianos tu mensaje',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppTokens.surfaceDark,
              ),
            ),
            const SizedBox(height: 14),
            _Field(
              controller: nameCtrl,
              label: 'Nombre completo',
              icon: Icons.person_outline,
              readOnly: true,
              validator: (v) =>
                  Validators.required(v) ?? Validators.maxLength(v, 100),
            ),
            const SizedBox(height: 12),
            _Field(
              controller: emailCtrl,
              label: 'Email',
              icon: Icons.email_outlined,
              readOnly: true,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
            ),
            const SizedBox(height: 12),
            _Field(
              controller: subjectCtrl,
              label: 'Asunto',
              icon: Icons.subject_rounded,
              validator: (v) =>
                  Validators.required(v) ?? Validators.maxLength(v, 120),
            ),
            const SizedBox(height: 12),
            _Field(
              controller: messageCtrl,
              label: 'Tu mensaje',
              icon: Icons.mode_comment_outlined,
              maxLines: 4,
              validator: (v) =>
                  Validators.required(v) ?? Validators.maxLength(v, 1000),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: isLoggedIn ? (isLoading ? null : onSubmit) : onLogin,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTokens.brandPrimary,
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  ),
                ),
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        isLoggedIn ? Icons.send_rounded : Icons.login_rounded,
                      ),
                label: Text(
                  isLoggedIn
                      ? 'Enviar mensaje'
                      : 'Entrar para enviar',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyThreadsPanel extends StatelessWidget {
  const _MyThreadsPanel({required this.threadsAsync});
  final AsyncValue<List<SupportThread>>? threadsAsync;

  @override
  Widget build(BuildContext context) {
    final async = threadsAsync;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mis ultimos hilos',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          if (async == null)
            Text(
              'Inicia sesion para ver tus conversaciones internas.',
              style: GoogleFonts.inter(color: Colors.white70, height: 1.5),
            )
          else
            async.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
              error: (_, __) => Text(
                'No se han podido cargar tus conversaciones.',
                style: GoogleFonts.inter(color: Colors.white70),
              ),
              data: (threads) {
                if (threads.isEmpty) {
                  return Text(
                    'Cuando abras una conversacion apareceran aqui las respuestas del equipo.',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  );
                }
                return Column(
                  children: threads
                      .take(3)
                      .map((thread) => _ThreadMiniCard(thread: thread))
                      .toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ThreadMiniCard extends StatelessWidget {
  const _ThreadMiniCard({required this.thread});
  final SupportThread thread;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      ),
      child: Row(
        children: [
          Icon(_categoryIcon(thread.category), color: AppTokens.brandPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  thread.subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTokens.surfaceDark,
                  ),
                ),
                if (thread.lastMessageAt != null)
                  Text(
                    Formatters.dateTime(thread.lastMessageAt!),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF8C8984),
                    ),
                  ),
              ],
            ),
          ),
          if (thread.unreadForCustomer > 0)
            const _UnreadDot(color: AppTokens.brandPrimary),
        ],
      ),
    );
  }
}

class _TypeDropdown extends StatelessWidget {
  const _TypeDropdown({required this.value, required this.onChanged});
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: _inputDecoration('Tipo de consulta', Icons.help_outline),
      items:
          const [
                'Consulta general',
                'Pedido o incidencia',
                'Propuesta de evento',
                'Oferta de trabajo',
                'Colaboracion',
              ]
              .map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(type, style: GoogleFonts.inter(fontSize: 14)),
                ),
              )
              .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Selecciona un tipo' : null,
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.readOnly = false,
  });
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      validator: validator,
      style: GoogleFonts.inter(fontSize: 14),
      decoration: _inputDecoration(label, icon),
    );
  }
}

InputDecoration _inputDecoration(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    labelStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF8A8782)),
    prefixIcon: Icon(icon, color: AppTokens.brandPrimary, size: 20),
    filled: true,
    fillColor: const Color(0xFFFAF9F6),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      borderSide: const BorderSide(color: Color(0xFFE7E1DA)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      borderSide: const BorderSide(color: Color(0xFFE7E1DA)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      borderSide: const BorderSide(color: AppTokens.brandPrimary, width: 1.4),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}

class _ChannelData {
  const _ChannelData(this.icon, this.title, this.text, this.action, this.onTap);
  final IconData icon;
  final String title;
  final String text;
  final String action;
  final VoidCallback onTap;
}

class _ChannelCard extends StatelessWidget {
  const _ChannelCard({required this.data});
  final _ChannelData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: const Color(0xFFE8E4DE)),
        boxShadow: [AppTokens.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTokens.brandLight,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            ),
            child: Icon(data.icon, color: AppTokens.brandPrimary),
          ),
          const SizedBox(height: 14),
          Text(
            data.title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppTokens.surfaceDark,
            ),
          ),
          const SizedBox(height: 7),
          Expanded(
            child: Text(
              data.text,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.45,
                color: const Color(0xFF74716C),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: data.onTap,
            style: TextButton.styleFrom(
              foregroundColor: AppTokens.brandPrimary,
              minimumSize: const Size(0, 38),
            ),
            icon: const Icon(Icons.arrow_forward_rounded, size: 17),
            label: Text(
              data.action,
              style: GoogleFonts.inter(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.filled = false,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return filled
        ? FilledButton.icon(
            onPressed: onTap,
            icon: Icon(icon),
            label: Text(label),
            style: FilledButton.styleFrom(
              backgroundColor: AppTokens.brandPrimary,
              minimumSize: const Size(0, 50),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          )
        : OutlinedButton.icon(
            onPressed: onTap,
            icon: Icon(icon),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTokens.brandDark,
              side: const BorderSide(color: AppTokens.brandPrimary),
              minimumSize: const Size(0, 50),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          );
  }
}

class _TinyLabel extends StatelessWidget {
  const _TinyLabel({required this.label, this.dark = false});
  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: dark
            ? Colors.white.withValues(alpha: 0.12)
            : AppTokens.brandLight,
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: dark ? AppTokens.brandLight : AppTokens.brandDark,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.9,
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.label,
    required this.text,
    this.incoming = true,
  });
  final String label;
  final String text;
  final bool incoming;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: incoming ? Colors.white : AppTokens.brandPrimary,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: incoming ? AppTokens.brandPrimary : Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w700,
              color: incoming ? AppTokens.surfaceDark : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.title, required this.text});
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: const Color(0xFFEDE8E1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, color: AppTokens.brandPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w900,
                    color: AppTokens.surfaceDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF77716B),
                    height: 1.45,
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

class _UnreadDot extends StatelessWidget {
  const _UnreadDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

IconData _categoryIcon(String category) => switch (category) {
  'order' => Icons.receipt_long_rounded,
  'catering' => Icons.celebration_rounded,
  'incident' => Icons.report_problem_rounded,
  _ => Icons.support_agent_rounded,
};
