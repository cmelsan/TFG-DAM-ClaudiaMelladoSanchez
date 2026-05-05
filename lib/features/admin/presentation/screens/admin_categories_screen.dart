import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';
import 'package:sabor_de_casa/features/admin/presentation/widgets/admin_shell.dart';
import 'package:sabor_de_casa/features/menu/domain/models/category.dart';

class AdminCategoriesScreen extends ConsumerWidget {
  const AdminCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(adminCategoriesProvider);

    return AdminShell(
      title: 'Categorías',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCategoryForm(context, ref, null),
        backgroundColor: AppTokens.brandPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Nueva categoría'),
      ),
      child: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(
              child: Text(
                'No hay categorías',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) {
              final cat = categories[i];
              return _CategoryTile(
                category: cat,
                index: i,
                onEdit: () => _openCategoryForm(ctx, ref, cat),
                onDelete: () => _confirmDelete(ctx, ref, cat),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, WidgetRef ref, Category cat) {
    showDialog<void>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar categoría'),
        content: Text(
          '¿Desactivar "${cat.name}"? Los platos asociados no se eliminarán.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
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

// Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€ Category Tile Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  final Category category;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTokens.brandPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '${category.sortOrder}',
                  style: const TextStyle(
                    color: AppTokens.brandPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            title: Text(
              category.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF111111),
              ),
            ),
            subtitle:
                category.description != null && category.description!.isNotEmpty
                ? Text(
                    category.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!category.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Inactiva',
                      style: TextStyle(fontSize: 10, color: Colors.red),
                    ),
                  ),
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppTokens.brandPrimary,
                  ),
                  onPressed: onEdit,
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: 'Eliminar',
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 250.ms, delay: (index * 50).ms)
        .slideX(begin: -0.05, end: 0, duration: 250.ms, delay: (index * 50).ms);
  }
}

// Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€ Category Form Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€Ã¢”€

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
                  isEdit ? 'Editar categoría' : 'Nueva categoría',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
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
                  decoration: _inputDeco('Descripción (opcional)'),
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _sortOrder,
                  decoration: _inputDeco('Orden de visualización'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Categoría activa'),
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
                          isEdit ? 'Guardar cambios' : 'Crear categoría',
                          style: const TextStyle(
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
  fillColor: const Color(0xFFE5E5E3),
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppTokens.brandPrimary, width: 1.5),
  ),
);
