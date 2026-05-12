import 'dart:typed_data';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_image_compress/flutter_image_compress.dart';
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

  /// Devuelve los platos más pedidos contando ocurrencias en order_items.
  /// Si no hay datos de pedidos, cae al listado general de platos activos.
  Future<List<Dish>> getTopOrderedDishes({int limit = 8}) async {
    try {
      // 1. Obtener todos los dish_id de order_items
      final res = await _client
          .from(SupabaseConstants.orderItems)
          .select('dish_id');
      final raw = res;
      final items = (raw as List).cast<Map<String, dynamic>>();

      // 2. Contar por dish_id en Dart
      final counts = <String, int>{};
      for (final item in items) {
        final id = item['dish_id'] as String?;
        if (id != null) counts[id] = (counts[id] ?? 0) + 1;
      }

      if (counts.isEmpty) {
        // Fallback: platos activos ordenados por nombre
        return getDishes();
      }

      // 3. Top IDs ordenados por frecuencia
      final sortedEntries = counts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final topIds = sortedEntries.take(limit).map((e) => e.key).toList();

      // 4. Obtener los platos por esos IDs
      final dishRes = await _client
          .from(SupabaseConstants.dishes)
          .select()
          .inFilter('id', topIds)
          .eq('is_active', true)
          .eq('is_available', true);
      final dishRaw = dishRes;
      final dishList = (dishRaw as List).cast<Map<String, dynamic>>();

      final dishes = dishList
          .map(Dish.fromJson)
          .toList()
        ..sort((a, b) {
          final countA = counts[a.id] ?? 0;
          final countB = counts[b.id] ?? 0;
          return countB.compareTo(countA);
        });

      return dishes;
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e, st) {
      debugPrint('getTopOrderedDishes ERROR: $e');
      debugPrint('getTopOrderedDishes STACKTRACE: $st');
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

  /// Sube una imagen al bucket `dish-images` (carpeta daily-special/) y
  /// devuelve la URL pública. En web sube sin comprimir; en móvil comprime a WebP.
  Future<String> uploadDailySpecialImage({
    required Uint8List bytes,
    String mimeType = 'image/jpeg',
  }) async {
    try {
      Uint8List toUpload;
      String contentType;
      String ext;

      if (!kIsWeb) {
        final compressed = await FlutterImageCompress.compressWithList(
          bytes,
          minWidth: 800,
          minHeight: 600,
          quality: 85,
          format: CompressFormat.webp,
        );
        toUpload = compressed;
        contentType = 'image/webp';
        ext = 'webp';
      } else {
        toUpload = bytes;
        contentType = mimeType;
        ext = mimeType.contains('png') ? 'png' : 'jpg';
      }

      final ts = DateTime.now().millisecondsSinceEpoch;
      final path = 'daily-special/$ts.$ext';
      await _client.storage
          .from(SupabaseConstants.dishImagesBucket)
          .uploadBinary(
            path,
            toUpload,
            fileOptions: FileOptions(contentType: contentType),
          );
      return _client.storage
          .from(SupabaseConstants.dishImagesBucket)
          .getPublicUrl(path);
    } on StorageException catch (e) {
      throw UnexpectedFailure(message: 'Storage error: ${e.message}');
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<DailySpecial?> getTodaySpecial() async {
    try {
      // Devuelve el menú más reciente disponible (hoy o días anteriores).
      final res = await _client
          .from(SupabaseConstants.dailySpecial)
          .select()
          .order('date', ascending: false)
          .limit(1)
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

  Future<DailySpecial> upsertTodaySpecial({
    required String dishId,
    int? discountPercent,
    String? note,
    String? primeroText,
    String? segundoText,
    String? postreText,
    String? bebidaText,
    double? menuPrice,
    String? imageUrl,
  }) async {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final payload = <String, dynamic>{
        'dish_id': dishId,
        'date': today,
        if (discountPercent != null) 'discount_percent': discountPercent,
        if (note != null) 'note': note,
        if (primeroText != null) 'primero_text': primeroText,
        if (segundoText != null) 'segundo_text': segundoText,
        if (postreText != null) 'postre_text': postreText,
        if (bebidaText != null) 'bebida_text': bebidaText,
        if (menuPrice != null) 'menu_price': menuPrice,
        if (imageUrl != null) 'image_url': imageUrl,
      };
      final res = await _client
          .from(SupabaseConstants.dailySpecial)
          .upsert(payload, onConflict: 'date')
          .select()
          .single();
      final dynamic data = res;
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
