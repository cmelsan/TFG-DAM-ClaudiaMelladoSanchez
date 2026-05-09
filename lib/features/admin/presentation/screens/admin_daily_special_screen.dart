import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/admin/presentation/widgets/admin_shell.dart';
import 'package:sabor_de_casa/features/menu/data/repositories/menu_repository.dart';
import 'package:sabor_de_casa/features/menu/domain/models/daily_special.dart';
import 'package:sabor_de_casa/features/menu/domain/models/dish.dart';
import 'package:sabor_de_casa/features/menu/presentation/providers/daily_special_notifier.dart';

/// Pantalla admin para crear/editar el menu del dia de hoy.
class AdminDailySpecialScreen extends ConsumerStatefulWidget {
  const AdminDailySpecialScreen({super.key});

  @override
  ConsumerState<AdminDailySpecialScreen> createState() =>
      _AdminDailySpecialScreenState();
}

class _AdminDailySpecialScreenState
    extends ConsumerState<AdminDailySpecialScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedDishId;
  final _primeroCtrl = TextEditingController();
  final _segundoCtrl = TextEditingController();
  final _postreCtrl = TextEditingController();
  final _bebidaCtrl = TextEditingController();
  final _menuPriceCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();

  bool _populated = false;

  @override
  void dispose() {
    _primeroCtrl.dispose();
    _segundoCtrl.dispose();
    _postreCtrl.dispose();
    _bebidaCtrl.dispose();
    _menuPriceCtrl.dispose();
    _noteCtrl.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  void _populateFromSpecial(DailySpecial? special) {
    if (_populated || special == null) return;
    setState(() {
      _populated = true;
      _selectedDishId = special.dishId;
      _primeroCtrl.text = special.primeroText ?? '';
      _segundoCtrl.text = special.segundoText ?? '';
      _postreCtrl.text = special.postreText ?? '';
      _bebidaCtrl.text = special.bebidaText ?? '';
      _menuPriceCtrl.text = special.menuPrice != null
          ? special.menuPrice!.toStringAsFixed(2)
          : '';
      _noteCtrl.text = special.note ?? '';
      _discountCtrl.text =
          special.discountPercent != null ? '${special.discountPercent}' : '';
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedDishId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un plato destacado')),
      );
      return;
    }

    await ref.read(dailySpecialNotifierProvider.notifier).upsert(
          dishId: _selectedDishId!,
          primeroText: _primeroCtrl.text.trim().isEmpty
              ? null
              : _primeroCtrl.text.trim(),
          segundoText: _segundoCtrl.text.trim().isEmpty
              ? null
              : _segundoCtrl.text.trim(),
          postreText: _postreCtrl.text.trim().isEmpty
              ? null
              : _postreCtrl.text.trim(),
          bebidaText: _bebidaCtrl.text.trim().isEmpty
              ? null
              : _bebidaCtrl.text.trim(),
          menuPrice: _menuPriceCtrl.text.trim().isEmpty
              ? null
              : double.tryParse(
                  _menuPriceCtrl.text.trim().replaceAll(',', '.'),
                ),
          note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
          discountPercent: _discountCtrl.text.trim().isEmpty
              ? null
              : int.tryParse(_discountCtrl.text.trim()),
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu del dia guardado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<DailySpecial?>>(
      dailySpecialNotifierProvider,
      (_, next) => next.whenOrNull(data: _populateFromSpecial),
    );

    final specialAsync = ref.watch(dailySpecialNotifierProvider);
    final allDishesAsync = ref.watch(_allDishesProvider);

    return AdminShell(
      title: 'Menu del dia',
      child: allDishesAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(_allDishesProvider),
        ),
        data: (dishes) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Plato destacado del dia'),
                    const SizedBox(height: 12),
                    _DishDropdown(
                      dishes: dishes,
                      selectedId: _selectedDishId,
                      onChanged: (id) => setState(() => _selectedDishId = id),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _NumberField(
                            controller: _discountCtrl,
                            label: 'Descuento (%)',
                            hint: 'ej. 10',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _PriceField(
                            controller: _menuPriceCtrl,
                            label: 'Precio menu completo (EUR)',
                            hint: 'ej. 9.90',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle('Composicion del menu'),
                    const SizedBox(height: 12),
                    _FormTextField(
                      controller: _primeroCtrl,
                      label: 'Primer plato',
                      hint: 'ej. Crema de calabaza con picatostes',
                    ),
                    const SizedBox(height: 12),
                    _FormTextField(
                      controller: _segundoCtrl,
                      label: 'Segundo plato',
                      hint: 'ej. Pollo al horno con patatas',
                    ),
                    const SizedBox(height: 12),
                    _FormTextField(
                      controller: _postreCtrl,
                      label: 'Postre',
                      hint: 'ej. Flan de huevo casero',
                    ),
                    const SizedBox(height: 12),
                    _FormTextField(
                      controller: _bebidaCtrl,
                      label: 'Bebida',
                      hint: 'ej. Agua, refresco o vino de la casa',
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle('Nota adicional (opcional)'),
                    const SizedBox(height: 12),
                    _FormTextField(
                      controller: _noteCtrl,
                      label: 'Nota',
                      hint: 'ej. Disponible hasta las 15:30',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: specialAsync.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppTokens.brandPrimary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              onPressed: _save,
                              child: Text(
                                'Guardar menu del dia',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                    ),
                    if (specialAsync.hasError) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${specialAsync.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
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

// -- Provider helper local ---------------------------------------------------

final _allDishesProvider = FutureProvider.autoDispose<List<Dish>>((ref) {
  return ref.watch(menuRepositoryProvider).getDishes();
});

// -- Widgets auxiliares -------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }
}

class _DishDropdown extends StatelessWidget {
  const _DishDropdown({
    required this.dishes,
    required this.selectedId,
    required this.onChanged,
  });

  final List<Dish> dishes;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      // ignore: deprecated_member_use
      initialValue: selectedId,
      decoration: const InputDecoration(
        labelText: 'Plato',
        border: OutlineInputBorder(),
      ),
      items: dishes
          .map(
            (d) => DropdownMenuItem(
              value: d.id,
              child: Text(d.name, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _FormTextField extends StatelessWidget {
  const _FormTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  final TextEditingController controller;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return null;
        final n = int.tryParse(v);
        if (n == null || n < 0 || n > 100) return 'Valor no valido (0-100)';
        return null;
      },
    );
  }
}

class _PriceField extends StatelessWidget {
  const _PriceField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  final TextEditingController controller;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return null;
        final n = double.tryParse(v.replaceAll(',', '.'));
        if (n == null || n < 0) return 'Precio no valido';
        return null;
      },
    );
  }
}
