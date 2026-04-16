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
Future<Dish> dishDetail(DishDetailRef ref, String dishId) {
  return ref.watch(menuRepositoryProvider).getDishById(dishId);
}
