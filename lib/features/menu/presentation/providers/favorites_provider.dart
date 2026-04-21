import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/features/auth/presentation/providers/auth_provider.dart';
import 'package:sabor_de_casa/features/menu/data/repositories/menu_repository.dart';
import 'package:sabor_de_casa/features/menu/domain/models/dish.dart';
import 'package:sabor_de_casa/features/menu/domain/models/favorite.dart';

part 'favorites_provider.g.dart';

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<Favorite>> favorites(FavoritesRef ref) async {
  final user = ref.watch(authNotifierProvider).valueOrNull;
  if (user == null) return [];
  return ref.watch(menuRepositoryProvider).getFavorites(user.id);
}

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<Dish>> favoriteDishes(FavoriteDishesRef ref) async {
  final user = ref.watch(authNotifierProvider).valueOrNull;
  if (user == null) return [];
  return ref.watch(menuRepositoryProvider).getFavoriteDishes(user.id);
}

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<bool> isFavorite(IsFavoriteRef ref, String dishId) async {
  final user = ref.watch(authNotifierProvider).valueOrNull;
  if (user == null) return false;
  return ref
      .watch(menuRepositoryProvider)
      .isFavorite(userId: user.id, dishId: dishId);
}

@riverpod
class FavoriteToggle extends _$FavoriteToggle {
  @override
  FutureOr<void> build() {}

  Future<void> toggle(String dishId) async {
    final user = ref.read(authNotifierProvider).valueOrNull;
    if (user == null) return;

    final repo = ref.read(menuRepositoryProvider);
    final isFav = await repo.isFavorite(userId: user.id, dishId: dishId);

    if (isFav) {
      await repo.removeFavorite(userId: user.id, dishId: dishId);
    } else {
      await repo.addFavorite(userId: user.id, dishId: dishId);
    }

    // Invalidar para refrescar la lista y el estado individual
    ref
      ..invalidate(favoritesProvider)
      ..invalidate(isFavoriteProvider(dishId));
  }
}
