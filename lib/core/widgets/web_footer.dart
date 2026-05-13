import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';

/// Footer web compartido por todas las páginas públicas.
class WebFooter extends StatelessWidget {
  const WebFooter({super.key});

  static const _bg = Color(0xFF0D3B2E);
  static const _bgCard = Color(0xFF0F4433);
  static const _muted = Color(0xFF8FBFB0);
  static const _divider = Color(0xFF1A5C47);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Cuerpo: 4 columnas ──────────────────────────────────────────
          LayoutBuilder(
            builder: (context, lc) {
              final narrow = lc.maxWidth < 700;
              final hPad = narrow ? 20.0 : 48.0;
              final colW = narrow ? (lc.maxWidth - hPad * 2 - 24) / 2 : 0.0;
              final col1 = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Conócenos',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sabor de Casa es tu servicio de comida casera '
                    'de confianza en Sanlúcar de Barrameda. Platos '
                    'elaborados a diario con ingredientes frescos, sin '
                    'conservantes, para que comas rico cada día.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: _muted,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Recogida en local, encargo previo o entrega a domicilio.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: _muted,
                      height: 1.7,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              );
              final col2 = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Navegación',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FooterLink(
                    label: 'Menú del día',
                    onTap: () => context.goNamed(RouteNames.menu),
                  ),
                  _FooterLink(
                    label: 'Catering y eventos',
                    onTap: () => context.goNamed(RouteNames.catering),
                  ),
                  _FooterLink(
                    label: 'Mis pedidos',
                    onTap: () => context.goNamed(RouteNames.orders),
                  ),
                  _FooterLink(
                    label: 'Mi perfil',
                    onTap: () => context.goNamed(RouteNames.profile),
                  ),
                  _FooterLink(
                    label: 'Contacto',
                    onTap: () => context.goNamed(RouteNames.contact),
                  ),
                ],
              );
              final col3 = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contacto',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _FooterInfoRow(
                    icon: Icons.location_on_outlined,
                    text: 'Sanlúcar de Barrameda, Cádiz',
                  ),
                  const SizedBox(height: 10),
                  const _FooterInfoRow(
                    icon: Icons.phone_outlined,
                    text: '956 36 30 09',
                  ),
                  const SizedBox(height: 10),
                  const _FooterInfoRow(
                    icon: Icons.email_outlined,
                    text: 'info@sabordecasa.es',
                  ),
                  const SizedBox(height: 10),
                  const _FooterInfoRow(
                    icon: Icons.access_time_outlined,
                    text: 'Lun – Sáb: 12:00 – 16:00',
                  ),
                ],
              );
              final col4 = Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: _bgCard,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SocialCircle(icon: Icons.facebook, tooltip: 'Facebook'),
                    _SocialCircle(
                      icon: Icons.camera_alt_outlined,
                      tooltip: 'Instagram',
                    ),
                    _SocialCircle(
                      icon: Icons.alternate_email,
                      tooltip: 'Email',
                    ),
                  ],
                ),
              );
              return Padding(
                padding: EdgeInsets.fromLTRB(hPad, 64, hPad, 48),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: narrow
                        ? Wrap(
                            spacing: 24,
                            runSpacing: 32,
                            children: [
                              SizedBox(width: colW, child: col1),
                              SizedBox(width: colW, child: col2),
                              SizedBox(width: colW, child: col3),
                              SizedBox(width: colW, child: col4),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: col1),
                              const SizedBox(width: 48),
                              Expanded(flex: 2, child: col2),
                              const SizedBox(width: 48),
                              Expanded(flex: 2, child: col3),
                              const SizedBox(width: 48),
                              SizedBox(width: 280, child: col4),
                            ],
                          ),
                  ),
                ),
              );
            },
          ),

          // ── Divisor ─────────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Divider(color: _divider, height: 1),
          ),

          // ── Nombre de marca centrado ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Sabor de Casa',
                  style: GoogleFonts.syne(
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    fontSize: 72,
                    letterSpacing: 0,
                    height: 1,
                    color: AppTokens.brandPrimary,
                  ),
                ),
              ),
            ),
          ),

          // ── Barra legal ──────────────────────────────────────────────────
          LayoutBuilder(
            builder: (context, lc) {
              final narrow = lc.maxWidth < 700;
              final hPad = narrow ? 20.0 : 48.0;
              const links = Wrap(
                spacing: 24,
                runSpacing: 8,
                children: [
                  _LegalLink(label: 'Aviso legal'),
                  _LegalLink(label: 'Privacidad'),
                  _LegalLink(label: 'Cookies'),
                  _LegalLink(label: 'Términos y condiciones'),
                  _LegalLink(label: 'Preguntas frecuentes'),
                ],
              );
              final copyright = Text(
                'Copyright \u00a9 ${DateTime.now().year} Sabor de Casa. '
                'Todos los derechos reservados.',
                style: const TextStyle(color: _muted, fontSize: 12),
              );
              return Padding(
                padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 36),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: narrow
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              links,
                              const SizedBox(height: 12),
                              copyright,
                            ],
                          )
                        : Row(
                            children: [
                              const Expanded(child: links),
                              copyright,
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Helpers internos ──────────────────────────────────────────────────────────

class _FooterLink extends StatefulWidget {
  const _FooterLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: _hover ? Colors.white : const Color(0xFF8FBFB0),
              fontWeight: _hover ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterInfoRow extends StatelessWidget {
  const _FooterInfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppTokens.brandPrimary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF8FBFB0),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialCircle extends StatefulWidget {
  const _SocialCircle({required this.icon, required this.tooltip});

  final IconData icon;
  final String tooltip;

  @override
  State<_SocialCircle> createState() => _SocialCircleState();
}

class _SocialCircleState extends State<_SocialCircle> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _hover ? AppTokens.brandPrimary : const Color(0xFF1A5C47),
          ),
          child: Icon(widget.icon, color: Colors.white, size: 17),
        ),
      ),
    );
  }
}

class _LegalLink extends StatefulWidget {
  const _LegalLink({required this.label});

  final String label;

  @override
  State<_LegalLink> createState() => _LegalLinkState();
}

class _LegalLinkState extends State<_LegalLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Text(
        widget.label,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: _hover ? Colors.white : const Color(0xFF8FBFB0),
        ),
      ),
    );
  }
}
