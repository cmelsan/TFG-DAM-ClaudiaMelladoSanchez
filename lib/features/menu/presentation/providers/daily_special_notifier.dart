import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/features/menu/data/repositories/menu_repository.dart';
import 'package:sabor_de_casa/features/menu/domain/models/daily_special.dart';

part 'daily_special_notifier.g.dart';

/// Notifier para gestionar el menú del día desde el panel de admin.
/// Expone el estado actual y un método [upsert] para crear/actualizar.
@riverpod
class DailySpecialNotifier extends _$DailySpecialNotifier {
  @override
  Future<DailySpecial?> build() async {
    final repo = ref.watch(menuRepositoryProvider);
    return repo.getTodaySpecial();
  }

  Future<void> upsert({
    required String dishId,
    int? discountPercent,
    String? note,
    String? primeroText,
    String? segundoText,
    String? postreText,
    String? bebidaText,
    double? menuPrice,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(menuRepositoryProvider).upsertTodaySpecial(
            dishId: dishId,
            discountPercent: discountPercent,
            note: note,
            primeroText: primeroText,
            segundoText: segundoText,
            postreText: postreText,
            bebidaText: bebidaText,
            menuPrice: menuPrice,
          ),
    );
    // Invalida el provider de consulta para que la home refresque.
    ref.invalidate(menuRepositoryProvider);
  }
}
