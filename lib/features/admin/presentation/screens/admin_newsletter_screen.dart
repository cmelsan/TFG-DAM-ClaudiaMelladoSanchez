import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/features/admin/presentation/widgets/admin_shell.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PANTALLA: COMUNICADOS (envío de newsletter / notificaciones in-app)
// ─────────────────────────────────────────────────────────────────────────────

class AdminNewsletterScreen extends ConsumerStatefulWidget {
  const AdminNewsletterScreen({super.key});

  @override
  ConsumerState<AdminNewsletterScreen> createState() =>
      _AdminNewsletterScreenState();
}

class _AdminNewsletterScreenState
    extends ConsumerState<AdminNewsletterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();

  bool _channelEmail = true;
  bool _channelInApp = true;
  bool _sending = false;
  _SendResult? _lastResult;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_channelEmail && !_channelInApp) {
      _showSnack('Selecciona al menos un canal de envío', isError: true);
      return;
    }

    setState(() {
      _sending = true;
      _lastResult = null;
    });

    try {
      final channels = [
        if (_channelEmail) 'email',
        if (_channelInApp) 'inapp',
      ];

      final res = await Supabase.instance.client.functions.invoke(
        'send-newsletter',
        body: {
          'subject': _subjectCtrl.text.trim(),
          'body': _bodyCtrl.text.trim(),
          'channels': channels,
        },
      );

      final data = res.data as Map<String, dynamic>? ?? {};

      if (data['error'] != null) {
        _showSnack(data['error'] as String, isError: true);
        setState(() => _sending = false);
        return;
      }

      setState(() {
        _sending = false;
        _lastResult = _SendResult(
          emailsSent: (data['emailsSent'] as num? ?? 0).toInt(),
          emailsFailed: (data['emailsFailed'] as num? ?? 0).toInt(),
          inappInserted: (data['inappInserted'] as num? ?? 0).toInt(),
        );
        _subjectCtrl.clear();
        _bodyCtrl.clear();
      });
    } catch (e) {
      setState(() => _sending = false);
      _showSnack('Error al enviar: $e', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade700 : AppTokens.brandPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Comunicados',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Descripción ──────────────────────────────────────────
                _InfoBanner(),
                const SizedBox(height: 32),

                // ── Formulario ───────────────────────────────────────────
                _ComposeCard(
                  formKey: _formKey,
                  subjectCtrl: _subjectCtrl,
                  bodyCtrl: _bodyCtrl,
                  channelEmail: _channelEmail,
                  channelInApp: _channelInApp,
                  onToggleEmail: (v) => setState(() => _channelEmail = v),
                  onToggleInApp: (v) => setState(() => _channelInApp = v),
                  sending: _sending,
                  onSend: _send,
                ),
                const SizedBox(height: 24),

                // ── Resultado del último envío ───────────────────────────
                if (_lastResult != null)
                  _ResultCard(result: _lastResult!)
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.05, end: 0),

                const SizedBox(height: 32),

                // ── Historial ────────────────────────────────────────────
                const _HistorySection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Banner informativo ────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTokens.brandLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTokens.brandPrimary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppTokens.brandPrimary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Como funciona',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF111111),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Canal Email: envia un correo HTML a todos los suscriptores de la newsletter (tabla subscriptions).\n'
                  'Canal In-app: crea una notificacion interna para todos los usuarios registrados en la app.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF555555), height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tarjeta de redacción ──────────────────────────────────────────────────────

class _ComposeCard extends StatelessWidget {
  const _ComposeCard({
    required this.formKey,
    required this.subjectCtrl,
    required this.bodyCtrl,
    required this.channelEmail,
    required this.channelInApp,
    required this.onToggleEmail,
    required this.onToggleInApp,
    required this.sending,
    required this.onSend,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController subjectCtrl;
  final TextEditingController bodyCtrl;
  final bool channelEmail;
  final bool channelInApp;
  final ValueChanged<bool> onToggleEmail;
  final ValueChanged<bool> onToggleInApp;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nuevo comunicado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 24),

            // Asunto
            TextFormField(
              controller: subjectCtrl,
              decoration: _inputDec(
                label: 'Asunto / Titulo',
                hint: 'Ej: Menu especial de junio',
                icon: Icons.title_rounded,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'El asunto es obligatorio' : null,
            ),
            const SizedBox(height: 16),

            // Cuerpo
            TextFormField(
              controller: bodyCtrl,
              maxLines: 8,
              decoration: _inputDec(
                label: 'Contenido del mensaje',
                hint: 'Escribe aqui el cuerpo del comunicado...',
                icon: Icons.notes_rounded,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'El contenido es obligatorio' : null,
            ),
            const SizedBox(height: 24),

            // Canales
            const Text(
              'Canales de envio',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _ChannelChip(
                  label: 'Email',
                  icon: Icons.email_outlined,
                  selected: channelEmail,
                  onChanged: onToggleEmail,
                ),
                const SizedBox(width: 12),
                _ChannelChip(
                  label: 'In-app',
                  icon: Icons.notifications_outlined,
                  selected: channelInApp,
                  onChanged: onToggleInApp,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Botón enviar
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: sending ? null : onSend,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTokens.brandPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(
                  sending ? 'Enviando...' : 'Enviar comunicado',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDec({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppTokens.brandPrimary, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTokens.brandPrimary, width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
    );
  }
}

// ── Chip de canal ─────────────────────────────────────────────────────────────

class _ChannelChip extends StatelessWidget {
  const _ChannelChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!selected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTokens.brandPrimary : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppTokens.brandPrimary : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : const Color(0xFF6B7280)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tarjeta de resultado ──────────────────────────────────────────────────────

class _SendResult {
  const _SendResult({
    required this.emailsSent,
    required this.emailsFailed,
    required this.inappInserted,
  });
  final int emailsSent;
  final int emailsFailed;
  final int inappInserted;
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});
  final _SendResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTokens.brandPrimary.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppTokens.brandPrimary, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Comunicado enviado correctamente',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF065F46),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${result.emailsSent} emails enviados'
                  '${result.emailsFailed > 0 ? ' (${result.emailsFailed} fallidos)' : ''}'
                  '  ·  '
                  '${result.inappInserted} notificaciones in-app',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF047857)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Historial de envíos ───────────────────────────────────────────────────────

class _HistorySection extends ConsumerWidget {
  const _HistorySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Supabase.instance.client
          .from('newsletter_sends')
          .select('subject, channels, emails_sent, inapp_inserted, created_at')
          .order('created_at', ascending: false)
          .limit(10),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        final rows = snap.data ?? [];
        if (rows.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Historial de envios',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              clipBehavior: Clip.hardEdge,
              child: Column(
                children: [
                  for (int i = 0; i < rows.length; i++) ...[
                    _HistoryRow(row: rows[i]),
                    if (i < rows.length - 1)
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.row});
  final Map<String, dynamic> row;

  @override
  Widget build(BuildContext context) {
    final subject = row['subject'] as String? ?? '—';
    final emailsSent = (row['emails_sent'] as num? ?? 0).toInt();
    final inapp = (row['inapp_inserted'] as num? ?? 0).toInt();
    final channels = (row['channels'] as List<dynamic>?)?.join(', ') ?? '—';
    final createdAt = row['created_at'] as String? ?? '';
    String dateLabel = '';
    if (createdAt.isNotEmpty) {
      final dt = DateTime.tryParse(createdAt)?.toLocal();
      if (dt != null) {
        dateLabel =
            '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTokens.brandLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.campaign_rounded,
              size: 18,
              color: AppTokens.brandPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF111111),
                  ),
                ),
                Text(
                  '$channels  ·  $emailsSent emails  ·  $inapp in-app',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          Text(
            dateLabel,
            style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}
