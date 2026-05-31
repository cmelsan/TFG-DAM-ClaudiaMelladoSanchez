import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/admin/domain/models/admin_event_request.dart';
import 'package:sabor_de_casa/features/admin/domain/models/admin_event_request_extensions.dart';
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';
import 'package:sabor_de_casa/features/admin/presentation/widgets/admin_shell.dart';
import 'package:sabor_de_casa/features/catering/domain/models/event_menu.dart';

class AdminCateringScreen extends ConsumerStatefulWidget {
  const AdminCateringScreen({super.key});

  @override
  ConsumerState<AdminCateringScreen> createState() =>
      _AdminCateringScreenState();
}

class _AdminCateringScreenState extends ConsumerState<AdminCateringScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Catering',
      floatingActionButton: _tab.index == 0
          ? FloatingActionButton.extended(
              backgroundColor: AppTokens.brandPrimary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text(
                'Nuevo menú',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => _showMenuDialog(context, ref, null),
            )
          : null,
      child: Column(
        children: [
          // ── Tab bar ────────────────────────────────────────────────────
          ColoredBox(
            color: Colors.white,
            child: TabBar(
              controller: _tab,
              labelColor: AppTokens.brandPrimary,
              unselectedLabelColor: Colors.black45,
              indicatorColor: AppTokens.brandPrimary,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              tabs: const [
                Tab(icon: Icon(Icons.restaurant_menu, size: 20), text: 'Menús'),
                Tab(
                  icon: Icon(Icons.event_note_outlined, size: 20),
                  text: 'Solicitudes',
                ),
              ],
            ),
          ),

          // ── Tab content ─────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: const [_MenusTab(), _RequestsTab()],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════ TAB 1: MENÚS ═════════
class _MenusTab extends ConsumerWidget {
  const _MenusTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menusAsync = ref.watch(adminEventMenusProvider);

    return menusAsync.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(adminEventMenusProvider),
      ),
      data: (menus) {
        if (menus.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 56,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay menús de evento',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.black45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pulsa + para crear el primer menú',
                  style: TextStyle(color: Colors.black38, fontSize: 14),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: menus.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (ctx, i) => _MenuAdminCard(menu: menus[i]),
        );
      },
    );
  }
}

class _MenuAdminCard extends ConsumerWidget {
  const _MenuAdminCard({required this.menu});
  final EventMenu menu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [AppTokens.cardShadow],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Badge activo/inactivo
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: menu.isActive
                        ? AppTokens.brandPrimary.withValues(alpha: 0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    menu.isActive ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: menu.isActive
                          ? AppTokens.brandPrimary
                          : Colors.grey,
                    ),
                  ),
                ),
                const Spacer(),
                // Acciones
                IconButton(
                  tooltip: 'Editar',
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppTokens.brandPrimary,
                  ),
                  onPressed: () => _showMenuDialog(context, ref, menu),
                ),
                IconButton(
                  tooltip: 'Eliminar',
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDelete(context, ref, menu),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              menu.name,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111111),
              ),
            ),
            if ((menu.description ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                menu.description!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 14),
            // Datos numéricos
            Row(
              children: [
                _DataChip(
                  icon: Icons.euro,
                  label: '${Formatters.price(menu.pricePerPerson)} / pax',
                  primary: true,
                ),
                const SizedBox(width: 8),
                _DataChip(
                  icon: Icons.people_outline,
                  label: '${menu.minGuests}–${menu.maxGuests} personas',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, WidgetRef ref, EventMenu menu) {
    showDialog<void>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('¿Eliminar menú?'),
        content: Text(
          'Se eliminará "${menu.name}" de forma permanente. Las solicitudes existentes no se verán afectadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(adminActionProvider.notifier).deleteEventMenu(menu.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _DataChip extends StatelessWidget {
  const _DataChip({
    required this.icon,
    required this.label,
    this.primary = false,
  });
  final IconData icon;
  final String label;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: primary
            ? AppTokens.brandPrimary.withValues(alpha: 0.08)
            : AppTokens.pageBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: primary ? AppTokens.brandPrimary : Colors.black45,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: primary ? AppTokens.brandPrimary : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════ TAB 2: SOLICITUDES ════════════
class _RequestsTab extends ConsumerWidget {
  const _RequestsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(adminEventRequestsProvider);

    return requestsAsync.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(adminEventRequestsProvider),
      ),
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.event_note_outlined,
                  size: 56,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Sin solicitudes de catering',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.black45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (ctx, i) => _RequestAdminCard(request: requests[i]),
        );
      },
    );
  }
}

class _RequestAdminCard extends ConsumerStatefulWidget {
  const _RequestAdminCard({required this.request});
  final AdminEventRequest request;

  @override
  ConsumerState<_RequestAdminCard> createState() => _RequestAdminCardState();
}

class _RequestAdminCardState extends ConsumerState<_RequestAdminCard> {
  late String _status;
  final _quoteCtrl = TextEditingController();
  final _adminNotesCtrl = TextEditingController();
  final _appointmentCtrl = TextEditingController();
  final _appointmentNotesCtrl = TextEditingController();
  bool _showQuote = false;
  bool _showAppointment = false;

  static const _statuses = {
    'pending': ('Pendiente', Colors.orange),
    'appointment': ('Cita', Colors.teal),
    'quoted': ('Presupuestado', Colors.blue),
    'accepted': ('Aceptado', Color(0xFF1D9E75)),
    'rejected': ('Rechazado', Colors.red),
    'cancelled': ('Cancelado', Colors.grey),
    'completed': ('Completado', Colors.purple),
  };

  @override
  void initState() {
    super.initState();
    _status = widget.request.status;
    if (widget.request.quotedTotal != null) {
      _quoteCtrl.text = widget.request.quotedTotal!.toStringAsFixed(2);
    }
    _adminNotesCtrl.text = widget.request.adminNotes ?? '';
    _appointmentNotesCtrl.text = widget.request.appointmentNotes ?? '';
    if (widget.request.appointmentAt != null) {
      final value = widget.request.appointmentAt!;
      _appointmentCtrl.text =
          '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    }
    _showQuote = _status == 'quoted';
    _showAppointment = _status == 'appointment';
  }

  @override
  void dispose() {
    _quoteCtrl.dispose();
    _adminNotesCtrl.dispose();
    _appointmentCtrl.dispose();
    _appointmentNotesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor) =
        _statuses[_status] ?? ('Desconocido', Colors.grey);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [AppTokens.cardShadow],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cabecera ───────────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '#${widget.request.shortId}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Datos del evento ────────────────────────────────────────
            _InfoRow(
              icon: Icons.people_outline,
              label: 'Comensales',
              value: '${widget.request.guestCount} personas',
            ),
            _InfoRow(
              icon: Icons.restaurant_menu_outlined,
              label: 'Menú',
              value: widget.request.menuType == 'custom'
                  ? 'Personalizado'
                  : widget.request.eventMenuName ?? 'Menú cerrado',
            ),
            if ((widget.request.eventType ?? '').isNotEmpty)
              _InfoRow(
                icon: Icons.celebration_outlined,
                label: 'Evento',
                value: widget.request.eventType!,
              ),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Fecha evento',
              value: Formatters.date(widget.request.eventDate),
            ),
            if ((widget.request.contactPhone ?? '').isNotEmpty)
              _InfoRow(
                icon: Icons.phone_outlined,
                label: 'Teléfono',
                value: widget.request.contactPhone!,
              ),
            _InfoRow(
              icon: Icons.location_on_outlined,
              label: 'Lugar',
              value: widget.request.location,
            ),
            if ((widget.request.customMenuDescription ?? '').isNotEmpty)
              _InfoRow(
                icon: Icons.edit_note_outlined,
                label: 'Idea menú',
                value: widget.request.customMenuDescription!,
              ),
            if ((widget.request.notes ?? '').isNotEmpty)
              _InfoRow(
                icon: Icons.notes_outlined,
                label: 'Notas',
                value: widget.request.notes!,
              ),
            if (widget.request.quotedTotal != null)
              _InfoRow(
                icon: Icons.euro,
                label: 'Presupuesto',
                value: Formatters.price(widget.request.quotedTotal!),
                highlight: true,
              ),
            if (widget.request.appointmentAt != null)
              _InfoRow(
                icon: Icons.event_available_outlined,
                label: 'Cita',
                value:
                    '${Formatters.date(widget.request.appointmentAt!)} ${widget.request.appointmentAt!.hour.toString().padLeft(2, '0')}:${widget.request.appointmentAt!.minute.toString().padLeft(2, '0')}',
                highlight: true,
              ),

            const Divider(height: 24, color: Color(0xFFF0F0EE)),

            // ── Cambiar estado ──────────────────────────────────────────
            Text(
              'Actualizar estado',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _statuses.entries.map((e) {
                final selected = _status == e.key;
                return ChoiceChip(
                  label: Text(e.value.$1),
                  selected: selected,
                  onSelected: (_) => setState(() {
                    _status = e.key;
                    _showQuote = _status == 'quoted';
                    _showAppointment = _status == 'appointment';
                  }),
                  selectedColor: e.value.$2.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                    color: selected ? e.value.$2 : Colors.black54,
                    fontSize: 13,
                  ),
                );
              }).toList(),
            ),

            // ── Campo importe presupuesto ──────────────────────────────
            if (_showQuote) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _quoteCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Importe presupuestado (€)',
                  prefixIcon: const Icon(Icons.euro_outlined),
                  filled: true,
                  fillColor: AppTokens.pageBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],

            if (_showAppointment) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _appointmentCtrl,
                decoration: InputDecoration(
                  labelText: 'Fecha y hora de cita',
                  hintText: '2026-06-15 18:30',
                  prefixIcon: const Icon(Icons.event_available_outlined),
                  filled: true,
                  fillColor: AppTokens.pageBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _appointmentNotesCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Mensaje de cita para el cliente',
                  hintText: 'Proponemos reunirnos para diseñar el menú.',
                  filled: true,
                  fillColor: AppTokens.pageBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),
            TextFormField(
              controller: _adminNotesCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notas para el cliente',
                hintText:
                    'Detalles del presupuesto o condiciones del servicio.',
                filled: true,
                fillColor: AppTokens.pageBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Guardar ─────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTokens.brandPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Guardar cambios',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    double? quoted;
    if (_showQuote && _quoteCtrl.text.isNotEmpty) {
      quoted = double.tryParse(_quoteCtrl.text.replaceAll(',', '.'));
    }
    final appointmentAt = _showAppointment && _appointmentCtrl.text.isNotEmpty
        ? DateTime.tryParse(_appointmentCtrl.text.replaceFirst(' ', 'T'))
        : null;
    await ref
        .read(adminActionProvider.notifier)
        .updateEventRequestQuote(
          requestId: widget.request.id,
          status: _status,
          quotedTotal: quoted,
          adminNotes: _adminNotesCtrl.text.trim().isEmpty
              ? null
              : _adminNotesCtrl.text.trim(),
          appointmentAt: appointmentAt,
          appointmentNotes: _appointmentNotesCtrl.text.trim().isEmpty
              ? null
              : _appointmentNotesCtrl.text.trim(),
        );
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Solicitud actualizada')));
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.black38),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black45,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: highlight
                    ? AppTokens.brandPrimary
                    : const Color(0xFF222222),
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════ MENU DIALOG ════════════════════
void _showMenuDialog(BuildContext context, WidgetRef ref, EventMenu? existing) {
  showDialog<void>(
    context: context,
    builder: (_) => _MenuFormDialog(existing: existing, ref: ref),
  );
}

class _MenuFormDialog extends StatefulWidget {
  const _MenuFormDialog({required this.ref, this.existing});
  final WidgetRef ref;
  final EventMenu? existing;

  @override
  State<_MenuFormDialog> createState() => _MenuFormDialogState();
}

class _MenuFormDialogState extends State<_MenuFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _minCtrl;
  late final TextEditingController _maxCtrl;
  late final TextEditingController _descCtrl;
  late bool _isActive;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final m = widget.existing;
    _nameCtrl = TextEditingController(text: m?.name ?? '');
    _priceCtrl = TextEditingController(
      text: m != null ? m.pricePerPerson.toStringAsFixed(2) : '',
    );
    _minCtrl = TextEditingController(text: m != null ? '${m.minGuests}' : '10');
    _maxCtrl = TextEditingController(
      text: m != null ? '${m.maxGuests}' : '100',
    );
    _descCtrl = TextEditingController(text: m?.description ?? '');
    _isActive = m?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return AlertDialog(
      title: Text(
        isEdit ? 'Editar menú' : 'Nuevo menú de evento',
        style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 18),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Field(
                  controller: _nameCtrl,
                  label: 'Nombre del menú',
                  hint: 'Ej: Menú Boda Premium',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Campo obligatorio'
                      : null,
                ),
                const SizedBox(height: 12),
                _Field(
                  controller: _priceCtrl,
                  label: 'Precio por persona (€)',
                  hint: 'Ej: 35.00',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Obligatorio';
                    if (double.tryParse(v.replaceAll(',', '.')) == null) {
                      return 'Número no válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                        controller: _minCtrl,
                        label: 'Mín. personas',
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Obligatorio';
                          if (int.tryParse(v) == null) return 'Número';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Field(
                        controller: _maxCtrl,
                        label: 'Máx. personas',
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Obligatorio';
                          if (int.tryParse(v) == null) return 'Número';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _Field(
                  controller: _descCtrl,
                  label: 'Descripción (opcional)',
                  hint: 'Detalla los platos incluidos, modalidades, etc.',
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Menú activo (visible a clientes)'),
                  value: _isActive,
                  activeThumbColor: AppTokens.brandPrimary,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          style: FilledButton.styleFrom(
            backgroundColor: AppTokens.brandPrimary,
          ),
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(isEdit ? 'Guardar' : 'Crear menú'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final name = _nameCtrl.text.trim();
    final price = double.parse(_priceCtrl.text.trim().replaceAll(',', '.'));
    final min = int.parse(_minCtrl.text.trim());
    final max = int.parse(_maxCtrl.text.trim());
    final desc = _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim();

    final notifier = widget.ref.read(adminActionProvider.notifier);

    if (widget.existing != null) {
      await notifier.updateEventMenu(
        id: widget.existing!.id,
        name: name,
        pricePerPerson: price,
        minGuests: min,
        maxGuests: max,
        description: desc,
        isActive: _isActive,
      );
    } else {
      await notifier.createEventMenu(
        name: name,
        pricePerPerson: price,
        minGuests: min,
        maxGuests: max,
        description: desc,
        isActive: _isActive,
      );
    }

    if (mounted) Navigator.pop(context);
  }
}

// ─────────────────────────────── Reusable form field ──────────────────────────
class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });
  final TextEditingController controller;
  final String label;
  final String? hint;
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
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppTokens.pageBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTokens.brandPrimary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
