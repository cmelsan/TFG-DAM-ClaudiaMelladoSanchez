import 'package:flutter/foundation.dart' show debugPrint;
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
      final res = await _client
          .from(SupabaseConstants.categories)
          .select()
          .eq('is_active', true)
          .order('sort_order');
      final dynamic data = res;

      var resultList = <dynamic>[];
      if (data is List) {
        resultList = List<dynamic>.from(data);
      }

      return resultList
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
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

      final res = await query.order('name');
      final dynamic data =
          res; // Evitar autovalidaciones rígidas de postgrest en la respuesta

      var resultList = <dynamic>[];
      if (data is List) {
        resultList = List<dynamic>.from(data);
      } else if (data != null) {
        resultList = [data]; // Or handle as needed
      }

      return resultList
          .map((e) => Dish.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e, st) {
      debugPrint('getDishes ERROR: $e');
      debugPrint('getDishes STACKTRACE: $st');
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<List<Dish>> getSeasonalDishes() async {
    try {
      final res = await _client
          .from(SupabaseConstants.dishes)
          .select()
          .eq('is_active', true)
          .eq('is_seasonal', true)
          .eq('is_available', true)
          .order('name');
      final dynamic data = res;
      var resultList = <dynamic>[];
      if (data is List) {
        resultList = List<dynamic>.from(data);
      }
      return resultList
          .map((e) => Dish.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<List<Dish>> getOfferDishes() async {
    try {
      final res = await _client
          .from(SupabaseConstants.dishes)
          .select()
          .eq('is_active', true)
          .eq('is_offer', true)
          .eq('is_available', true)
          .order('name');
      final dynamic data = res;
      var resultList = <dynamic>[];
      if (data is List) {
        resultList = List<dynamic>.from(data);
      }
      return resultList
          .map((e) => Dish.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<Dish> getDishById(String id) async {
    try {
      final res = await _client
          .from(SupabaseConstants.dishes)
          .select()
          .eq('id', id)
          .single();
      final dynamic data = res;
      return Dish.fromJson(data as Map<String, dynamic>);
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
      final res = await _client
          .from(SupabaseConstants.dailySpecial)
          .select()
          .eq('date', today)
          .maybeSingle();
      final dynamic data = res;
      if (data == null) return null;
      return DailySpecial.fromJson(data as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  // ──── Favoritos ────

  Future<List<Favorite>> getFavorites(String userId) async {
    try {
      final res = await _client
          .from(SupabaseConstants.favorites)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      final dynamic data = res;

      var resultList = <dynamic>[];
      if (data is List) {
        resultList = List<dynamic>.from(data);
      }

      return resultList
          .map((e) => Favorite.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<List<Dish>> getFavoriteDishes(String userId) async {
    try {
      final res = await _client
          .from(SupabaseConstants.favorites)
          .select('dishes(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      final dynamic data = res;

      var resultList = <dynamic>[];
      if (data is List) {
        resultList = List<dynamic>.from(data);
      }

      return resultList
          .map((json) => (json as Map<String, dynamic>)['dishes'])
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
      final res = await _client
          .from(SupabaseConstants.favorites)
          .select('id')
          .eq('user_id', userId)
          .eq('dish_id', dishId)
          .maybeSingle();
      final dynamic data = res;
      return data != null;
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }
}
