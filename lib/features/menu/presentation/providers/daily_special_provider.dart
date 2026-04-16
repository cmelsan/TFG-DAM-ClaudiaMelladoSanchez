import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/features/menu/data/repositories/menu_repository.dart';
import 'package:sabor_de_casa/features/menu/domain/models/daily_special.dart';
import 'package:sabor_de_casa/features/menu/domain/models/dish.dart';

part 'daily_special_provider.g.dart';

/// Plato del día con el Dish incluido para mostrar toda la info.
@riverpod
Future<({DailySpecial special, Dish dish})?> todaySpecial(
  // ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
  TodaySpecialRef ref,
) async {
  final repo = ref.watch(menuRepositoryProvider);
  final special = await repo.getTodaySpecial();
  if (special == null) return null;
  final dish = await repo.getDishById(special.dishId);
  return (special: special, dish: dish);
}
