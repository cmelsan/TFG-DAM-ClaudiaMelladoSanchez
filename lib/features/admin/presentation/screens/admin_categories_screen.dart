import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';
import 'package:sabor_de_casa/features/admin/presentation/widgets/admin_shell.dart';
import 'package:sabor_de_casa/features/menu/domain/models/category.dart';

const _kPageBg = Color(0xFFF4F6F8);
const _kCardBorder = Color(0xFFEEEEEE);
const _kInk = Color(0xFF1A1A2E);
const _kInkMuted = Color(0xFF6B7280);
const _kInkSoft = Color(0xFF9CA3AF);

class AdminCategoriesScreen extends ConsumerWidget {
  const AdminCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(adminCategoriesProvider);
    final dishesAsync = ref.watch(adminDishesProvider);

    return AdminShell(
      title: 'Categorias',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded,
              color: AppTokens.brandPrimary),
          tooltip: 'Actualizar',
          onPressed: () {
            ref
              ..invalidate(adminCategoriesProvider)
              ..invalidate(adminDishesProvider);
          },
        ),
        const SizedBox(width: 8),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCategoryForm(context, ref, null),
        backgroundColor: AppTokens.brandPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Nueva categoria'),
      ),
      child: ColoredBox(
        color: _kPageBg,
        child: categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              'Error: $e',
              style: GoogleFonts.inter(color: AppTokens.danger, fontSize: 13),
            ),
          ),
          data: (categories) {
            final dishes = dishesAsync.valueOrNull ?? const [];
            final countPerCat = <String, int>{};
            for (final d in dishes) {
              countPerCat[d.categoryId] =
                  (countPerCat[d.categoryId] ?? 0) + 1;
            }
            final active = categories.where((c) => c.isActive).length;
            final inactive = categories.length - active;
            final dishesTotal = dishes.length;

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
              children: [
                _KpiStrip(
                  items: [
                    _Kpi(
                      icon: Icons.category_rounded,
                      color: AppTokens.brandPrimary,
                      label: 'Total categorias',
                      value: '${categories.length}',
                    ),
                    _Kpi(
                      icon: Icons.check_circle_rounded,
                      color: AppTokens.success,
                      label: 'Activas',
                      value: '$active',
                    ),
                    _Kpi(
                      icon: Icons.visibility_off_rounded,
                      color: AppTokens.warning,
                      label: 'Inactivas',
                      value: '$inactive',
                    ),
                    _Kpi(
                      icon: Icons.restaurant_menu_rounded,
                      color: AppTokens.brandDark,
                      label: 'Platos asignados',
                      value: '$dishesTotal',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (categories.isEmpty)
                  const _EmptyState(
                    icon: Icons.category_outlined,
                    title: 'No hay categorias',
                    subtitle:
                        'Crea la primera categoria para organizar tu carta.',
                  )
                else ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, left: 4),
                    child: Text(
                      'Listado (ordenado por orden de visualizacion)',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _kInk,
                      ),
                    ),
                  ),
                  for (final cat in (categories.toList()
                        ..sort((a, b) =>
                            a.sortOrder.compareTo(b.sortOrder))))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CategoryCard(
                        category: cat,
                        dishCount: countPerCat[cat.id] ?? 0,
                        onEdit: () => _openCategoryForm(context, ref, cat),
                        onDelete: () => _confirmDelete(context, ref, cat),
                      ),
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, WidgetRef ref, Category cat) {
    showDialog<void>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar categoria'),
        content: Text(
          '¿Desactivar "${cat.name}"? Los platos asociados no se eliminaran.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTokens.danger),
            onPressed: () {
              Navigator.pop(dialogCtx);
              ref.read(adminActionProvider.notifier).deleteCategory(cat.id);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// ─── Card ───────────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.dishCount,
    required this.onEdit,
    required this.onDelete,
  });

  final Category category;
  final int dishCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: _kCardBorder),
        boxShadow: [AppTokens.cardShadow],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: category.isActive
                    ? const [AppTokens.brandPrimary, AppTokens.brandDark]
                    : [
                        AppTokens.warning.withValues(alpha: 0.8),
                        AppTokens.warning.withValues(alpha: 0.5),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              '${category.sortOrder}',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: _kInk,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!category.isActive)
                      const _Pill(
                        label: 'Inactiva',
                        color: AppTokens.warning,
                      ),
                  ],
                ),
                if ((category.description ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    category.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _kInkMuted,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.restaurant_menu_rounded,
                        size: 13, color: _kInkSoft),
                    const SizedBox(width: 4),
                    Text(
                      '$dishCount ${dishCount == 1 ? "plato" : "platos"}',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: _kInkMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                color: AppTokens.brandPrimary, size: 20),
            onPressed: onEdit,
            tooltip: 'Editar',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: AppTokens.danger, size: 20),
            onPressed: onDelete,
            tooltip: 'Eliminar',
          ),
        ],
      ),
    );
  }
}

// ─── KPI strip & helpers ────────────────────────────────────────────────────

class _Kpi {
  const _Kpi({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final Color color;
  final String label;
  final String value;
}

class _KpiStrip extends StatelessWidget {
  const _KpiStrip({required this.items});
  final List<_Kpi> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) {
        final cols = c.maxWidth >= 900
            ? 4
            : c.maxWidth >= 560
                ? 2
                : 1;
        const spacing = 14.0;
        final w = cols == 1
            ? c.maxWidth
            : (c.maxWidth - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final k in items)
              SizedBox(width: w, child: _KpiTile(data: k)),
          ],
        );
      },
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({required this.data});
  final _Kpi data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: _kCardBorder),
        boxShadow: [AppTokens.cardShadow],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: _kInkMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.value,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _kInk,
                    height: 1.05,
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

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: _kCardBorder),
      ),
      child: Column(
        children: [
          Icon(icon, size: 56, color: _kInkSoft),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _kInk,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: _kInkMuted),
          ),
        ],
      ),
    );
  }
}

// ─── Form sheet ─────────────────────────────────────────────────────────────

Future<void> _openCategoryForm(
  BuildContext context,
  WidgetRef ref,
  Category? existing,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CategoryFormSheet(existing: existing, ref: ref),
  );
}

class _CategoryFormSheet extends StatefulWidget {
  const _CategoryFormSheet({required this.existing, required this.ref});
  final Category? existing;
  final WidgetRef ref;

  @override
  State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _sortOrder;
  late bool _isActive;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    _name = TextEditingController(text: c?.name ?? '');
    _description = TextEditingController(text: c?.description ?? '');
    _sortOrder = TextEditingController(text: (c?.sortOrder ?? 0).toString());
    _isActive = c?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _sortOrder.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final category = Category(
      id: widget.existing?.id ?? '',
      name: _name.text.trim(),
      description: _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
      sortOrder: int.tryParse(_sortOrder.text.trim()) ?? 0,
      isActive: _isActive,
    );

    final notifier = widget.ref.read(adminActionProvider.notifier);
    if (widget.existing == null) {
      await notifier.createCategory(category);
    } else {
      await notifier.updateCategory(category);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  isEdit ? 'Editar categoria' : 'Nueva categoria',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _kInk,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _name,
                  decoration: _inputDeco('Nombre *'),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Campo obligatorio'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  decoration: _inputDeco('Descripcion (opcional)'),
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _sortOrder,
                  decoration: _inputDeco('Orden de visualizacion'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Categoria activa'),
                  value: _isActive,
                  activeThumbColor: AppTokens.brandPrimary,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTokens.brandPrimary,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isEdit ? 'Guardar cambios' : 'Crear categoria',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
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

InputDecoration _inputDeco(String hint) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8F8FA),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kCardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kCardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTokens.brandPrimary, width: 1.5),
      ),
    );
