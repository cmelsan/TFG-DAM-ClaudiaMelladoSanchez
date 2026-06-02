import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/errors/failures.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/features/newsletter/presentation/providers/newsletter_provider.dart';

/// Mini-form de opt-in a la newsletter para footer / contacto.
class NewsletterOptIn extends ConsumerStatefulWidget {
  const NewsletterOptIn({super.key, this.source = 'web'});
  final String source;

  @override
  ConsumerState<NewsletterOptIn> createState() => _NewsletterOptInState();
}

class _NewsletterOptInState extends ConsumerState<NewsletterOptIn> {
  final _controller = TextEditingController();
  bool _sending = false;
  bool _done = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _controller.text.trim();
    if (!email.contains('@') || email.length < 5) {
      setState(() => _error = 'Introduce un email válido');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref
          .read(newsletterActionProvider.notifier)
          .subscribe(email: email, source: widget.source);
      if (!mounted) return;
      setState(() {
        _sending = false;
        _done = true;
      });
    } on DatabaseFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = e.code == 'duplicate_email'
            ? 'Este correo ya esta suscrito.'
            : 'No hemos podido suscribirte. Intentalo de nuevo.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = 'No hemos podido suscribirte. Intentalo de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTokens.brandLight,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppTokens.brandPrimary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              '¡Gracias! Te has suscrito a nuestras novedades.',
              style: GoogleFonts.inter(
                color: AppTokens.brandDark,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !_sending,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.inter(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'tu@email.com',
                  hintStyle: GoogleFonts.inter(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                    borderSide: const BorderSide(
                      color: AppTokens.brandPrimary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _sending ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppTokens.brandPrimary,
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                ),
              ),
              child: _sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Suscribirme',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
            ),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 6),
          Text(
            _error!,
            style: GoogleFonts.inter(color: AppTokens.danger, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
