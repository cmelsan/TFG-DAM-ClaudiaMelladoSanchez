import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
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

  String? _selectedDishId;  // gestionado internamente, no expuesto en UI
  final _primeroCtrl = TextEditingController();
  final _segundoCtrl = TextEditingController();
  final _postreCtrl = TextEditingController();
  final _bebidaCtrl = TextEditingController();
  final _menuPriceCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  // Imagen del menú del día
  String? _currentImageUrl; // URL guardada en BD
  bool _uploadingImage = false;

  bool _populated = false;

  @override
  void dispose() {
    _primeroCtrl.dispose();
    _segundoCtrl.dispose();
    _postreCtrl.dispose();
    _bebidaCtrl.dispose();
    _menuPriceCtrl.dispose();
    _noteCtrl.dispose();
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
      _currentImageUrl = special.imageUrl;
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedDishId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay platos disponibles. Crea un plato primero.')),
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
          imageUrl: _currentImageUrl,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu del dia guardado')),
      );
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (xFile == null || !mounted) return;

    setState(() => _uploadingImage = true);
    try {
      final bytes = await xFile.readAsBytes();
      final mimeType = xFile.mimeType ?? 'image/jpeg';
      final url = await ref.read(menuRepositoryProvider).uploadDailySpecialImage(
            bytes: bytes,
            mimeType: mimeType,
          );
      if (mounted) setState(() => _currentImageUrl = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir imagen: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref
      ..listen<AsyncValue<DailySpecial?>>(
        dailySpecialNotifierProvider,
        (_, next) => next.whenOrNull(data: _populateFromSpecial),
      )
      // Auto-selecciona el primer plato disponible si aún no hay ninguno.
      ..listen<AsyncValue<List<Dish>>>(_allDishesProvider, (_, next) {
      next.whenOrNull(data: (dishes) {
        if (_selectedDishId == null && dishes.isNotEmpty) {
          setState(() => _selectedDishId = dishes.first.id);
        }
      });
    });

    final specialAsync = ref.watch(dailySpecialNotifierProvider);

    return AdminShell(
      title: 'Menu del dia',
      child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    _PriceField(
                      controller: _menuPriceCtrl,
                      label: 'Precio menu completo (EUR)',
                      hint: 'ej. 9.90',
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
                    const SizedBox(height: 24),
                    const _SectionTitle('Imagen del menú del día (opcional)'),
                    const SizedBox(height: 12),
                    _DailySpecialImagePicker(
                      currentUrl: _currentImageUrl,
                      isUploading: _uploadingImage,
                      onPickImage: _pickAndUploadImage,
                      onClear: () => setState(() => _currentImageUrl = null),
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

// ─── Widget para seleccionar/previsualizar imagen del menú del día ───────────

class _DailySpecialImagePicker extends StatelessWidget {
  const _DailySpecialImagePicker({
    required this.currentUrl,
    required this.isUploading,
    required this.onPickImage,
    required this.onClear,
  });

  final String? currentUrl;
  final bool isUploading;
  final VoidCallback onPickImage;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (currentUrl != null && currentUrl!.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: currentUrl!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 200,
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (_, __, ___) => Container(
                height: 200,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 36),
                ),
                onPressed: isUploading ? null : onPickImage,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Cambiar imagen'),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  foregroundColor: Colors.red,
                ),
                onPressed: isUploading ? null : onClear,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Eliminar imagen'),
              ),
            ],
          ),
        ] else ...[
          InkWell(
            onTap: isUploading ? null : onPickImage,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTokens.brandPrimary.withValues(alpha: 0.4),
                  width: 2,
                ),
                color: AppTokens.brandLight,
              ),
              child: isUploading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 40,
                          color: AppTokens.brandPrimary,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Seleccionar imagen',
                          style: TextStyle(
                            color: AppTokens.brandPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Si no se selecciona ninguna se usará\nla imagen del plato seleccionado',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ],
    );
  }
}
