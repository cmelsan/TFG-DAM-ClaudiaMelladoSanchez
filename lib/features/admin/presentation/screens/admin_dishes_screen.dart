import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';

class AdminDishesScreen extends ConsumerWidget {
  const AdminDishesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dishesAsync = ref.watch(adminDishesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Platos')),
      body: dishesAsync.when(
        data: (dishes) => ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: dishes.length,
          itemBuilder: (_, index) {
            final dish = dishes[index];
            return SwitchListTile(
              title: Text(dish.name),
              subtitle: Text(dish.categoryId),
              value: dish.isAvailable,
              onChanged: (value) => ref
                  .read(adminActionProvider.notifier)
                  .updateDishAvailability(
                    dishId: dish.id,
                    isAvailable: value,
                  ),
            );
          },
        ),
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(adminDishesProvider),
        ),
      ),
    );
  }
}
