import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/core/constants/supabase_constants.dart';
import 'package:sabor_de_casa/core/errors/failures.dart';
import 'package:sabor_de_casa/features/menu/domain/models/category.dart';
import 'package:sabor_de_casa/features/menu/domain/models/daily_special.dart';
import 'package:sabor_de_casa/features/menu/domain/models/dish.dart';
import 'package:sabor_de_casa/features/menu/domain/models/favorite.dart';
import 'package:sabor_de_casa/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'menu_repository.g.dart';

@Riverpod(keepAlive: true)
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
MenuRepository menuRepository(MenuRepositoryRef ref) {
  return MenuRepository(ref.watch(supabaseClientProvider));
}

class MenuRepository {
  MenuRepository(this._client);

  final SupabaseClient _client;

  // ──── Categorías ────

  Future<List<Category>> getCategories() async {
    try {
      final data = await _client
          .from(SupabaseConstants.categories)
          .select()
          .eq('is_active', true)
          .order('sort_order');
      return data.map(Category.fromJson).toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  // ──── Platos ────

  Future<List<Dish>> getDishes({String? categoryId}) async {
    try {
      var query = _client
          .from(SupabaseConstants.dishes)
          .select()
          .eq('is_active', true);

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      final data = await query.order('name');
      return data.map(Dish.fromJson).toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<Dish> getDishById(String id) async {
    try {
      final data = await _client
          .from(SupabaseConstants.dishes)
          .select()
          .eq('id', id)
          .single();
      return Dish.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  // ──── Plato del día ────

  Future<DailySpecial?> getTodaySpecial() async {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final data = await _client
          .from(SupabaseConstants.dailySpecial)
          .select()
          .eq('date', today)
          .maybeSingle();
      if (data == null) return null;
      return DailySpecial.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  // ──── Favoritos ────

  Future<List<Favorite>> getFavorites(String userId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.favorites)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return data.map(Favorite.fromJson).toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<List<Dish>> getFavoriteDishes(String userId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.favorites)
          .select('dishes(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return data
          .map((json) => json['dishes'])
          .whereType<Map<String, dynamic>>()
          .map(Dish.fromJson)
          .toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<void> addFavorite({
    required String userId,
    required String dishId,
  }) async {
    try {
      await _client.from(SupabaseConstants.favorites).insert({
        'user_id': userId,
        'dish_id': dishId,
      });
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<void> removeFavorite({
    required String userId,
    required String dishId,
  }) async {
    try {
      await _client
          .from(SupabaseConstants.favorites)
          .delete()
          .eq('user_id', userId)
          .eq('dish_id', dishId);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<bool> isFavorite({
    required String userId,
    required String dishId,
  }) async {
    try {
      final data = await _client
          .from(SupabaseConstants.favorites)
          .select('id')
          .eq('user_id', userId)
          .eq('dish_id', dishId)
          .maybeSingle();
      return data != null;
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }
}
