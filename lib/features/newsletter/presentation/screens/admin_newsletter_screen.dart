import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sabor_de_casa/core/errors/failures.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/admin/presentation/widgets/admin_shell.dart';
import 'package:sabor_de_casa/features/newsletter/domain/models/newsletter_subscriber.dart';
import 'package:sabor_de_casa/features/newsletter/presentation/providers/newsletter_provider.dart';

class AdminNewsletterScreen extends ConsumerStatefulWidget {
  const AdminNewsletterScreen({super.key});

  @override
  ConsumerState<AdminNewsletterScreen> createState() =>
      _AdminNewsletterScreenState();
}

class _AdminNewsletterScreenState
    extends ConsumerState<AdminNewsletterScreen> {
  String _query = '';
  String _statusFilter = 'all';
  final _subjectCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  bool _sendingCampaign = false;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(newsletterSubscribersProvider);

    return AdminShell(
      title: 'Newsletter',
      actions: [
        IconButton(
          icon: const Icon(
            Icons.refresh_rounded,
            color: AppTokens.brandPrimary,
          ),
          tooltip: 'Actualizar',
          onPressed: () => ref.invalidate(newsletterSubscribersProvider),
        ),
        const SizedBox(width: 8),
      ],
      child: async.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (e, _) => Center(
          child: ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(newsletterSubscribersProvider),
          ),
        ),
        data: (subs) {
          final active = subs.where((s) => s.status == 'active').length;
          final unsubscribed =
              subs.where((s) => s.status == 'unsubscribed').length;
          final filtered = _filter(subs);

          return ColoredBox(
            color: const Color(0xFFF4F6F8),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              children: [
                _Summary(
                  total: subs.length,
                  active: active,
                  unsubscribed: unsubscribed,
                ),
                const SizedBox(height: 14),
                _CampaignComposer(
                  subjectCtrl: _subjectCtrl,
                  bodyCtrl: _bodyCtrl,
                  sending: _sendingCampaign,
                  onSend: () => _sendCampaign(active),
                ),
                const SizedBox(height: 18),
                _FiltersBar(
                  query: _query,
                  statusFilter: _statusFilter,
                  onQuery: (v) => setState(() => _query = v),
                  onStatus: (v) => setState(() => _statusFilter = v),
                  onExport: () => _exportCsv(filtered),
                  onAdd: _showAddDialog,
                ),
                const SizedBox(height: 14),
                if (filtered.isEmpty)
                  _Empty(query: _query)
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                      boxShadow: [AppTokens.cardShadow],
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < filtered.length; i++) ...[
                          if (i > 0)
                            Container(
                              height: 1,
                              color: const Color(0xFFF0F0F0),
                            ),
                          _SubscriberRow(sub: filtered[i]),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<NewsletterSubscriber> _filter(List<NewsletterSubscriber> all) {
    final q = _query.trim().toLowerCase();
    return all.where((s) {
      if (_statusFilter != 'all' && s.status != _statusFilter) return false;
      if (q.isEmpty) return true;
      return s.email.toLowerCase().contains(q) ||
          (s.fullName ?? '').toLowerCase().contains(q);
    }).toList();
  }

  void _exportCsv(List<NewsletterSubscriber> subs) {
    final buffer = StringBuffer('email,nombre,estado,fuente,alta\n');
    for (final s in subs) {
      buffer
        ..write('${s.email},')
        ..write('"${s.fullName ?? ''}",')
        ..write('${s.status},')
        ..write('${s.source},')
        ..write(s.createdAt.toIso8601String())
        ..writeln();
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'CSV copiado (${subs.length} filas)',
          style: GoogleFonts.inter(),
        ),
        backgroundColor: AppTokens.brandPrimary,
      ),
    );
  }

  Future<void> _showAddDialog() async {
    final emailCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Añadir suscriptor manual',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email *'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre (opcional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTokens.brandPrimary,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final email = emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) return;
    try {
      await ref.read(newsletterActionProvider.notifier).subscribe(
            email: email,
            fullName: nameCtrl.text.trim().isEmpty
                ? null
                : nameCtrl.text.trim(),
            source: 'admin',
          );
      ref.invalidate(newsletterSubscribersProvider);
    } on DatabaseFailure catch (e) {
      if (!mounted) return;
      final isDuplicate = e.code == 'duplicate_email';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isDuplicate
                ? 'Ese correo ya estaba suscrito.'
                : 'No se pudo añadir suscriptor.',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: isDuplicate
              ? AppTokens.warning
              : AppTokens.danger,
        ),
      );
    }
  }

  Future<void> _sendCampaign(int activeCount) async {
    final subject = _subjectCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    if (subject.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Asunto y mensaje son obligatorios',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: AppTokens.danger,
        ),
      );
      return;
    }
    if (activeCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No hay suscriptores activos',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: AppTokens.warning,
        ),
      );
      return;
    }

    setState(() => _sendingCampaign = true);
    try {
      final sent = await ref
          .read(newsletterActionProvider.notifier)
          .sendCampaign(subject: subject, body: body);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Campaña enviada a $sent suscriptores',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: AppTokens.brandPrimary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error enviando campaña: $e',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: AppTokens.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _sendingCampaign = false);
    }
  }
}

class _CampaignComposer extends StatelessWidget {
  const _CampaignComposer({
    required this.subjectCtrl,
    required this.bodyCtrl,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController subjectCtrl;
  final TextEditingController bodyCtrl;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [AppTokens.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enviar campaña de newsletter',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: subjectCtrl,
            enabled: !sending,
            decoration: const InputDecoration(
              labelText: 'Asunto',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: bodyCtrl,
            enabled: !sending,
            minLines: 4,
            maxLines: 8,
            decoration: const InputDecoration(
              labelText: 'Mensaje (texto plano)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: sending ? null : onSend,
              icon: sending
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 16),
              label: Text(
                sending ? 'Enviando...' : 'Enviar a activos',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppTokens.brandPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Resumen ──────────────────────────────────────────────────────────────────

class _Summary extends StatelessWidget {
  const _Summary({
    required this.total,
    required this.active,
    required this.unsubscribed,
  });
  final int total;
  final int active;
  final int unsubscribed;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Total', '$total', AppTokens.brandDark),
      ('Activos', '$active', AppTokens.brandPrimary),
      ('Bajas', '$unsubscribed', AppTokens.danger),
    ];
    return LayoutBuilder(
      builder: (ctx, c) {
        final cols = c.maxWidth >= 540 ? 3 : 1;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final it in items)
              SizedBox(
                width: (c.maxWidth - 12 * (cols - 1)) / cols,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                    boxShadow: [AppTokens.cardShadow],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 28,
                        decoration: BoxDecoration(
                          color: it.$3,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            it.$1,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            it.$2,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ── Filtros + acciones ───────────────────────────────────────────────────────

class _FiltersBar extends StatelessWidget {
  const _FiltersBar({
    required this.query,
    required this.statusFilter,
    required this.onQuery,
    required this.onStatus,
    required this.onExport,
    required this.onAdd,
  });
  final String query;
  final String statusFilter;
  final ValueChanged<String> onQuery;
  final ValueChanged<String> onStatus;
  final VoidCallback onExport;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [AppTokens.cardShadow],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 980;

          final searchField = SizedBox(
            width: wide ? 320 : 280,
            child: TextField(
              onChanged: onQuery,
              style: GoogleFonts.inter(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Buscar por email o nombre…',
                hintStyle: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF9CA3AF),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF9CA3AF),
                  size: 18,
                ),
                filled: true,
                fillColor: const Color(0xFFF4F6F8),
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          );

          final statusDropdown = Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6F8),
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: statusFilter,
                isDense: true,
                icon: const Icon(
                  Icons.expand_more_rounded,
                  color: Color(0xFF6B7280),
                ),
                style: GoogleFonts.inter(
                  color: const Color(0xFF1A1A2E),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Todos')),
                  DropdownMenuItem(value: 'active', child: Text('Activos')),
                  DropdownMenuItem(
                    value: 'unsubscribed',
                    child: Text('Bajas'),
                  ),
                  DropdownMenuItem(value: 'bounced', child: Text('Rebotados')),
                ],
                onChanged: (v) {
                  if (v != null) onStatus(v);
                },
              ),
            ),
          );

          final exportButton = OutlinedButton.icon(
            onPressed: onExport,
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Exportar CSV'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTokens.brandDark,
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              ),
              textStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          );

          final addButton = FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.person_add_rounded, size: 16),
            label: const Text('Añadir'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTokens.brandPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              ),
              textStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          );

          if (wide) {
            return Row(
              children: [
                searchField,
                const SizedBox(width: 12),
                statusDropdown,
                const Spacer(),
                exportButton,
                const SizedBox(width: 8),
                addButton,
              ],
            );
          }

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              searchField,
              statusDropdown,
              exportButton,
              addButton,
            ],
          );
        },
      ),
    );
  }
}

// ── Empty ────────────────────────────────────────────────────────────────────

class _Empty extends StatelessWidget {
  const _Empty({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F0F0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mail_outline_rounded,
              color: Color(0xFF9CA3AF),
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            query.isEmpty
                ? 'Aún no hay suscriptores'
                : 'Sin coincidencias para "$query"',
            style: GoogleFonts.inter(
              color: const Color(0xFF6B7280),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Fila ─────────────────────────────────────────────────────────────────────

class _SubscriberRow extends ConsumerWidget {
  const _SubscriberRow({required this.sub});
  final NewsletterSubscriber sub;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = switch (sub.status) {
      'active' => AppTokens.brandPrimary,
      'unsubscribed' => AppTokens.danger,
      _ => AppTokens.warning,
    };
    final label = switch (sub.status) {
      'active' => 'Activo',
      'unsubscribed' => 'Baja',
      _ => 'Rebotado',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(Icons.email_rounded, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sub.email,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                if ((sub.fullName ?? '').isNotEmpty)
                  Text(
                    sub.fullName!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Origen: ${sub.source}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              DateFormat('dd MMM yyyy', 'es').format(sub.createdAt),
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_horiz_rounded,
              color: Color(0xFF6B7280),
              size: 20,
            ),
            onSelected: (v) {
              final notifier = ref.read(newsletterActionProvider.notifier);
              switch (v) {
                case 'reactivate':
                  notifier.updateStatus(id: sub.id, status: 'active');
                case 'unsubscribe':
                  notifier.updateStatus(id: sub.id, status: 'unsubscribed');
                case 'delete':
                  notifier.remove(sub.id);
              }
            },
            itemBuilder: (_) => [
              if (sub.status != 'active')
                const PopupMenuItem(
                  value: 'reactivate',
                  child: Text('Reactivar'),
                ),
              if (sub.status == 'active')
                const PopupMenuItem(
                  value: 'unsubscribe',
                  child: Text('Dar de baja'),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Eliminar', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
