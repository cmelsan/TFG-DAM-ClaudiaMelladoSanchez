import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/admin/presentation/widgets/admin_shell.dart';
import 'package:sabor_de_casa/features/testimonials/domain/models/testimonial.dart';
import 'package:sabor_de_casa/features/testimonials/presentation/providers/testimonials_provider.dart';

class AdminTestimonialsScreen extends ConsumerStatefulWidget {
  const AdminTestimonialsScreen({super.key});

  @override
  ConsumerState<AdminTestimonialsScreen> createState() =>
      _AdminTestimonialsScreenState();
}

class _AdminTestimonialsScreenState
    extends ConsumerState<AdminTestimonialsScreen> {
  String _filter = 'all'; // all | featured | hidden

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminTestimonialsProvider);

    return AdminShell(
      title: 'Reseñas',
      actions: [
        IconButton(
          icon: const Icon(
            Icons.refresh_rounded,
            color: AppTokens.brandPrimary,
          ),
          tooltip: 'Actualizar',
          onPressed: () => ref.invalidate(adminTestimonialsProvider),
        ),
        const SizedBox(width: 8),
      ],
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTokens.brandPrimary,
        onPressed: () => _showForm(context),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Nueva reseña',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      child: async.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (e, _) => Center(
          child: ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(adminTestimonialsProvider),
          ),
        ),
        data: (items) {
          final featured = items.where((t) => t.isFeatured).length;
          final avg = items.isEmpty
              ? 0.0
              : items.map((t) => t.rating).reduce((a, b) => a + b) /
                  items.length;
          final filtered = switch (_filter) {
            'featured' => items.where((t) => t.isFeatured).toList(),
            'hidden' => items.where((t) => !t.isFeatured).toList(),
            _ => items,
          };

          return ColoredBox(
            color: const Color(0xFFF4F6F8),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
              children: [
                _Summary(
                  total: items.length,
                  featured: featured,
                  avgRating: avg,
                ),
                const SizedBox(height: 18),
                _FilterChips(
                  value: _filter,
                  onChanged: (v) => setState(() => _filter = v),
                ),
                const SizedBox(height: 14),
                if (filtered.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    alignment: Alignment.center,
                    child: Text(
                      'Sin reseñas en esta vista',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF6B7280),
                        fontSize: 13,
                      ),
                    ),
                  )
                else
                  LayoutBuilder(
                    builder: (ctx, c) {
                      final cols = c.maxWidth >= 1100
                          ? 3
                          : c.maxWidth >= 720
                              ? 2
                              : 1;
                      return Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        children: [
                          for (final t in filtered)
                            SizedBox(
                              width:
                                  (c.maxWidth - 14 * (cols - 1)) / cols,
                              child: _TestimonialCard(
                                item: t,
                                onEdit: () => _showForm(context, item: t),
                                onToggle: () => ref
                                    .read(testimonialActionProvider.notifier)
                                    .updateOne(
                                      id: t.id,
                                      isFeatured: !t.isFeatured,
                                    ),
                                onDelete: () => _confirmDelete(t),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showForm(BuildContext context, {Testimonial? item}) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _TestimonialFormDialog(item: item),
    );
  }

  Future<void> _confirmDelete(Testimonial t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Eliminar reseña', style: GoogleFonts.inter()),
        content: Text(
          '¿Eliminar la reseña de ${t.authorName}? Esta acción no se puede deshacer.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTokens.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(testimonialActionProvider.notifier).remove(t.id);
  }
}

// ── Resumen ──────────────────────────────────────────────────────────────────

class _Summary extends StatelessWidget {
  const _Summary({
    required this.total,
    required this.featured,
    required this.avgRating,
  });
  final int total, featured;
  final double avgRating;

  @override
  Widget build(BuildContext context) {
    final items = <(String, String, Color, IconData)>[
      ('Total', '$total', AppTokens.brandDark, Icons.format_quote_rounded),
      (
        'Destacadas',
        '$featured',
        AppTokens.brandPrimary,
        Icons.star_rounded
      ),
      (
        'Valoración media',
        avgRating == 0 ? '—' : avgRating.toStringAsFixed(1),
        AppTokens.warning,
        Icons.trending_up_rounded,
      ),
    ];
    return LayoutBuilder(
      builder: (ctx, c) {
        final cols = c.maxWidth >= 720 ? 3 : 1;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final it in items)
              SizedBox(
                width: (c.maxWidth - 12 * (cols - 1)) / cols,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                    boxShadow: [AppTokens.cardShadow],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: it.$3.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(it.$4, color: it.$3, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            it.$1,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            it.$2,
                            style: GoogleFonts.inter(
                              fontSize: 22,
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

// ── Filter chips ─────────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final opts = const [
      ('all', 'Todas'),
      ('featured', 'Destacadas'),
      ('hidden', 'Ocultas'),
    ];
    return Wrap(
      spacing: 8,
      children: [
        for (final o in opts)
          ChoiceChip(
            label: Text(
              o.$2,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: value == o.$1 ? Colors.white : AppTokens.brandDark,
              ),
            ),
            selected: value == o.$1,
            selectedColor: AppTokens.brandPrimary,
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFE5E7EB)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            onSelected: (_) => onChanged(o.$1),
          ),
      ],
    );
  }
}

// ── Card ─────────────────────────────────────────────────────────────────────

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard({
    required this.item,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });
  final Testimonial item;
  final VoidCallback onEdit, onToggle, onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(
          color: item.isFeatured
              ? AppTokens.brandPrimary.withValues(alpha: 0.4)
              : const Color(0xFFEEEEEE),
          width: item.isFeatured ? 1.4 : 1,
        ),
        boxShadow: [AppTokens.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTokens.brandLight,
                child: Text(
                  item.authorName.isEmpty
                      ? '?'
                      : item.authorName[0].toUpperCase(),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    color: AppTokens.brandDark,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.authorName,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy', 'es').format(item.createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              if (item.isFeatured)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTokens.brandPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 12,
                        color: AppTokens.brandPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'En home',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppTokens.brandPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < item.rating ? Icons.star_rounded : Icons.star_border_rounded,
                size: 16,
                color: AppTokens.warning,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.body,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.5,
              color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Pos. ${item.position}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: item.isFeatured ? 'Ocultar de home' : 'Mostrar en home',
                icon: Icon(
                  item.isFeatured
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  size: 18,
                  color: AppTokens.brandDark,
                ),
                onPressed: onToggle,
              ),
              IconButton(
                tooltip: 'Editar',
                icon: const Icon(
                  Icons.edit_rounded,
                  size: 18,
                  color: AppTokens.info,
                ),
                onPressed: onEdit,
              ),
              IconButton(
                tooltip: 'Eliminar',
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: AppTokens.danger,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Form dialog ──────────────────────────────────────────────────────────────

class _TestimonialFormDialog extends ConsumerStatefulWidget {
  const _TestimonialFormDialog({this.item});
  final Testimonial? item;

  @override
  ConsumerState<_TestimonialFormDialog> createState() =>
      _TestimonialFormDialogState();
}

class _TestimonialFormDialogState
    extends ConsumerState<_TestimonialFormDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bodyCtrl;
  late final TextEditingController _positionCtrl;
  late int _rating;
  late bool _featured;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.item;
    _nameCtrl = TextEditingController(text: t?.authorName ?? '');
    _bodyCtrl = TextEditingController(text: t?.body ?? '');
    _positionCtrl =
        TextEditingController(text: (t?.position ?? 0).toString());
    _rating = t?.rating ?? 5;
    _featured = t?.isFeatured ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bodyCtrl.dispose();
    _positionCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    if (name.isEmpty || body.isEmpty) return;
    setState(() => _saving = true);
    final notifier = ref.read(testimonialActionProvider.notifier);
    final position = int.tryParse(_positionCtrl.text.trim()) ?? 0;
    if (widget.item == null) {
      await notifier.create(
        authorName: name,
        body: body,
        rating: _rating,
        isFeatured: _featured,
        position: position,
      );
    } else {
      await notifier.updateOne(
        id: widget.item!.id,
        authorName: name,
        body: body,
        rating: _rating,
        isFeatured: _featured,
        position: position,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.item == null ? 'Nueva reseña' : 'Editar reseña',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Autor *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bodyCtrl,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(labelText: 'Reseña *'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Valoración:',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  for (var i = 1; i <= 5; i++)
                    IconButton(
                      iconSize: 22,
                      visualDensity: VisualDensity.compact,
                      onPressed: () => setState(() => _rating = i),
                      icon: Icon(
                        i <= _rating
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: AppTokens.warning,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _positionCtrl,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Posición'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppTokens.brandPrimary,
                      value: _featured,
                      onChanged: (v) => setState(() => _featured = v),
                      title: Text(
                        'Destacar',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Mostrar en la home',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _saving
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTokens.brandPrimary,
                    ),
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Guardar',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                            ),
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
