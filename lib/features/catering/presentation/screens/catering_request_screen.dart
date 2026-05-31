import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/features/catering/data/repositories/catering_repository.dart';
import 'package:sabor_de_casa/features/catering/domain/models/event_menu.dart';
import 'package:sabor_de_casa/features/catering/presentation/providers/catering_provider.dart';

class CateringRequestScreen extends ConsumerStatefulWidget {
  const CateringRequestScreen({super.key});

  @override
  ConsumerState<CateringRequestScreen> createState() =>
      _CateringRequestScreenState();
}

class _CateringRequestScreenState extends ConsumerState<CateringRequestScreen> {
  int _step = 0;

  // Paso 1 – selección de menú
  EventMenu? _selectedMenu;
  bool _customMenu = false;

  // Paso 2 – detalles del evento
  final _guestsCtrl = TextEditingController(text: '20');
  DateTime? _eventDate;
  final _eventTypeCtrl = TextEditingController(text: 'Cumpleaños');
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  // Paso 3 – notas
  final _customMenuCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _guestsCtrl.dispose();
    _eventTypeCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _customMenuCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  int get _guests => int.tryParse(_guestsCtrl.text) ?? 0;
  double get _estimated =>
      _customMenu ? 0 : (_selectedMenu?.pricePerPerson ?? 0) * _guests;

  @override
  Widget build(BuildContext context) {
    final menusAsync = ref.watch(cateringMenusProvider);
    return Scaffold(
      backgroundColor: AppTokens.pageBg,
      appBar: AppBar(
        title: const Text('Solicitar catering'),
        centerTitle: true,
      ),
      body: menusAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error al cargar menús: $e')),
        data: _buildStepper,
      ),
    );
  }

  Widget _buildStepper(List<EventMenu> menus) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(
          context,
        ).colorScheme.copyWith(primary: AppTokens.brandPrimary),
      ),
      child: Stepper(
        currentStep: _step,
        onStepTapped: (s) {
          if (s < _step) setState(() => _step = s);
        },
        onStepContinue: _continue,
        onStepCancel: _step > 0 ? () => setState(() => _step--) : null,
        controlsBuilder: (context, details) => Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            children: [
              if (_step < 3)
                FilledButton(
                  onPressed: details.onStepContinue,
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                  child: const Text('Continuar'),
                )
              else
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                  child: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Enviar solicitud'),
                ),
              if (_step > 0) ...[
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: details.onStepCancel,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                  ),
                  child: const Text('Atrás'),
                ),
              ],
            ],
          ),
        ),
        steps: [
          Step(
            title: const Text('Selecciona un menú'),
            subtitle: _customMenu
                ? const Text('Menú personalizado')
                : _selectedMenu != null
                ? Text(_selectedMenu!.name)
                : null,
            isActive: _step >= 0,
            state: _step > 0 ? StepState.complete : StepState.indexed,
            content: menus.isEmpty
                ? _CustomMenuCard(
                    selected: _customMenu,
                    onTap: () => setState(() {
                      _customMenu = true;
                      _selectedMenu = null;
                    }),
                  )
                : Column(
                    children: [
                      ...menus.map(
                        (m) => _MenuCard(
                          menu: m,
                          selected: !_customMenu && _selectedMenu?.id == m.id,
                          onTap: () => setState(() {
                            _customMenu = false;
                            _selectedMenu = m;
                          }),
                        ),
                      ),
                      _CustomMenuCard(
                        selected: _customMenu,
                        onTap: () => setState(() {
                          _customMenu = true;
                          _selectedMenu = null;
                        }),
                      ),
                    ],
                  ),
          ),
          Step(
            title: const Text('Detalles del evento'),
            subtitle: _eventDate != null
                ? Text(DateFormat('dd/MM/yyyy').format(_eventDate!))
                : null,
            isActive: _step >= 1,
            state: _step > 1 ? StepState.complete : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _guestsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Nº de comensales',
                    prefixIcon: const Icon(Icons.people_outline),
                    helperText: !_customMenu && _selectedMenu != null
                        ? 'Mín. ${_selectedMenu!.minGuests} · Máx. ${_selectedMenu!.maxGuests}'
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _eventTypeCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Tipo de evento',
                    hintText:
                        'Ej: bautizo, comunión, inauguración, reunión privada...',
                    prefixIcon: const Icon(Icons.celebration_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _EventTypeSuggestions(
                  onSelected: (value) =>
                      setState(() => _eventTypeCtrl.text = value),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Teléfono de contacto',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          color: _eventDate != null
                              ? AppTokens.brandPrimary
                              : Colors.black54,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _eventDate != null
                              ? DateFormat(
                                  "EEEE, d 'de' MMMM yyyy",
                                  'es',
                                ).format(_eventDate!)
                              : 'Seleccionar fecha del evento',
                          style: TextStyle(
                            color: _eventDate != null
                                ? const Color(0xFF111111)
                                : Colors.black54,
                            fontWeight: _eventDate != null
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationCtrl,
                  decoration: InputDecoration(
                    labelText: 'Lugar del evento',
                    hintText: 'Ej: Salón Bellaluz, C/ Mayor 10, Huelva',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Notas y presupuesto'),
            isActive: _step >= 2,
            state: _step > 2 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                if (_customMenu) ...[
                  TextFormField(
                    controller: _customMenuCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Qué menú quieres diseñar',
                      hintText:
                          'Cuéntanos estilo, platos favoritos, alergias, servicio o cualquier idea inicial.',
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Notas adicionales (opcional)',
                    hintText:
                        'Alergias, preferencias, personalización del menú...',
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                if (!_customMenu && _selectedMenu != null && _guests > 0) ...[
                  const SizedBox(height: 20),
                  _CostEstimate(
                    menu: _selectedMenu!,
                    guests: _guests,
                    estimated: _estimated,
                  ),
                ],
              ],
            ),
          ),
          Step(
            title: const Text('Confirmar solicitud'),
            isActive: _step >= 3,
            content: _ConfirmCard(
              menu: _selectedMenu,
              customMenu: _customMenu,
              guests: _guests,
              eventDate: _eventDate,
              eventType: _eventTypeCtrl.text.trim(),
              phone: _phoneCtrl.text,
              location: _locationCtrl.text,
              customMenuDescription: _customMenuCtrl.text,
              notes: _notesCtrl.text,
              estimated: _estimated,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? now.add(const Duration(days: 14)),
      firstDate: now.add(const Duration(days: 7)),
      lastDate: now.add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _eventDate = picked);
  }

  void _continue() {
    if (_step == 0 && !_customMenu && _selectedMenu == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un menú o elige menú personalizado'),
        ),
      );
      return;
    }
    if (_step == 1) {
      final n = int.tryParse(_guestsCtrl.text);
      final min = _customMenu ? 10 : _selectedMenu?.minGuests ?? 1;
      final max = _customMenu ? 9999 : _selectedMenu?.maxGuests ?? 9999;
      if (n == null || n < min || n > max) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('El nº de comensales debe estar entre $min y $max'),
          ),
        );
        return;
      }
      if (_phoneCtrl.text.trim().length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Indica un teléfono de contacto válido'),
          ),
        );
        return;
      }
      if (_eventTypeCtrl.text.trim().length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Indica el tipo de evento')),
        );
        return;
      }
      if (_eventDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona la fecha del evento')),
        );
        return;
      }
      if (_locationCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Indica el lugar del evento')),
        );
        return;
      }
    }
    if (_step == 2 && _customMenu && _customMenuCtrl.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cuéntanos un poco más sobre el menú personalizado'),
        ),
      );
      return;
    }
    if (_step < 3) setState(() => _step++);
  }

  Future<void> _submit() async {
    if ((!_customMenu && _selectedMenu == null) || _eventDate == null) return;
    setState(() => _submitting = true);
    try {
      await ref
          .read(cateringRepositoryProvider)
          .sendRequest(
            menuId: _customMenu ? null : _selectedMenu!.id,
            guestCount: _guests,
            eventDate: _eventDate!,
            location: _locationCtrl.text.trim(),
            eventType: _eventTypeCtrl.text.trim(),
            contactPhone: _phoneCtrl.text.trim(),
            menuType: _customMenu ? 'custom' : 'closed',
            customMenuDescription: _customMenu
                ? _customMenuCtrl.text.trim()
                : null,
            notes: _notesCtrl.text.trim().isEmpty
                ? null
                : _notesCtrl.text.trim(),
          );
      ref.invalidate(myCateringRequestsProvider);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          icon: const Icon(
            Icons.check_circle,
            color: AppTokens.brandPrimary,
            size: 52,
          ),
          title: const Text('¡Solicitud enviada!'),
          content: const Text(
            'Hemos recibido tu solicitud de catering. '
            'Nos pondremos en contacto contigo pronto con el presupuesto oficial.',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.goNamed(RouteNames.myCateringRequests);
              },
              child: const Text('Ver mis solicitudes'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ Widgets privados â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _EventTypeSuggestions extends StatelessWidget {
  const _EventTypeSuggestions({required this.onSelected});

  final ValueChanged<String> onSelected;

  static const _suggestions = [
    'Cumpleaños',
    'Boda',
    'Empresa',
    'Reunión familiar',
    'Comunión',
    'Bautizo',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _suggestions
          .map(
            (eventType) => ActionChip(
              label: Text(eventType),
              onPressed: () => onSelected(eventType),
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey.shade200),
              labelStyle: const TextStyle(fontSize: 12),
            ),
          )
          .toList(),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.menu,
    required this.selected,
    required this.onTap,
  });
  final EventMenu menu;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? AppTokens.brandPrimary.withValues(alpha: 0.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppTokens.brandPrimary : Colors.grey.shade200,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: selected ? AppTokens.brandPrimary : AppTokens.pageBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.restaurant_menu,
                  color: selected ? Colors.white : AppTokens.brandPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menu.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (menu.description != null &&
                        menu.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        menu.description!,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          Formatters.price(menu.pricePerPerson),
                          style: const TextStyle(
                            color: AppTokens.brandPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          '/persona  ·  ',
                          style: TextStyle(color: Colors.black45, fontSize: 12),
                        ),
                        Text(
                          '${menu.minGuests}–${menu.maxGuests} pax',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle, color: AppTokens.brandPrimary),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomMenuCard extends StatelessWidget {
  const _CustomMenuCard({required this.selected, required this.onTap});
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? AppTokens.brandPrimary.withValues(alpha: 0.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppTokens.brandPrimary : Colors.grey.shade200,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: selected ? AppTokens.brandPrimary : AppTokens.pageBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit_note_outlined,
                  color: selected ? Colors.white : AppTokens.brandPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diseñar mi propio menú',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'El admin concertará una cita contigo para cerrar la propuesta.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle, color: AppTokens.brandPrimary),
            ],
          ),
        ),
      ),
    );
  }
}

class _CostEstimate extends StatelessWidget {
  const _CostEstimate({
    required this.menu,
    required this.guests,
    required this.estimated,
  });
  final EventMenu menu;
  final int guests;
  final double estimated;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTokens.brandPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTokens.brandPrimary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Estimación de coste',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Precio por persona',
            value: Formatters.price(menu.pricePerPerson),
          ),
          _SummaryRow(label: 'Comensales', value: '$guests personas'),
          const Divider(height: 16),
          _SummaryRow(
            label: 'Total estimado',
            value: Formatters.price(estimated),
            bold: true,
          ),
          const SizedBox(height: 8),
          const Text(
            'Precio orientativo. El presupuesto final lo confirma nuestro equipo.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ConfirmCard extends StatelessWidget {
  const _ConfirmCard({
    required this.menu,
    required this.customMenu,
    required this.guests,
    required this.eventDate,
    required this.eventType,
    required this.phone,
    required this.location,
    required this.customMenuDescription,
    required this.notes,
    required this.estimated,
  });
  final EventMenu? menu;
  final bool customMenu;
  final int guests;
  final DateTime? eventDate;
  final String eventType;
  final String phone;
  final String location;
  final String customMenuDescription;
  final String notes;
  final double estimated;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Menú',
            value: customMenu ? 'Menú personalizado' : menu?.name ?? '—',
          ),
          _SummaryRow(label: 'Tipo de evento', value: eventType),
          _SummaryRow(label: 'Comensales', value: '$guests personas'),
          if (eventDate != null)
            _SummaryRow(label: 'Fecha', value: Formatters.date(eventDate!)),
          _SummaryRow(label: 'Teléfono', value: phone.isNotEmpty ? phone : '—'),
          _SummaryRow(
            label: 'Lugar',
            value: location.isNotEmpty ? location : '—',
          ),
          if (customMenuDescription.isNotEmpty)
            _SummaryRow(label: 'Idea de menú', value: customMenuDescription),
          if (notes.isNotEmpty) _SummaryRow(label: 'Notas', value: notes),
          if (!customMenu) ...[
            const Divider(height: 20),
            _SummaryRow(
              label: 'Estimación',
              value: Formatters.price(estimated),
              bold: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });
  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black54,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
