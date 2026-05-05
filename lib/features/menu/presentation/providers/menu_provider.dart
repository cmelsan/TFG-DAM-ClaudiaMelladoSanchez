import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/features/menu/data/repositories/menu_repository.dart';
import 'package:sabor_de_casa/features/menu/domain/models/dish.dart';

part 'menu_provider.g.dart';

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<Dish>> dishes(DishesRef ref, {String? categoryId}) {
  return ref.watch(menuRepositoryProvider).getDishes(categoryId: categoryId);
}

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<Dish>> offerDishes(OfferDishesRef ref) {
  return ref.watch(menuRepositoryProvider).getOfferDishes();
}

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<Dish>> seasonalDishes(SeasonalDishesRef ref) {
  return ref.watch(menuRepositoryProvider).getSeasonalDishes();
}

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<Dish> dishDetail(DishDetailRef ref, String dishId) {
  return ref.watch(menuRepositoryProvider).getDishById(dishId);
}

// ── Búsqueda por texto ──
@riverpod
class MenuSearchQuery extends _$MenuSearchQuery {
  @override
  String build() => '';

  // ignore: use_setters_to_change_properties
  void setQuery(String query) => state = query;
  void clear() => state = '';
}

// ── Filtro por alérgenos a excluir ──
@riverpod
class MenuAllergenFilter extends _$MenuAllergenFilter {
  @override
  List<String> build() => [];

  void toggle(String allergen) {
    final current = state.toList();
    if (current.contains(allergen)) {
      current.remove(allergen);
    } else {
      current.add(allergen);
    }
    state = current;
  }

  void clear() => state = [];
}
