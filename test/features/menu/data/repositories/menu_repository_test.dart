import 'package:flutter_test/flutter_test.dart';
import 'package:sabor_de_casa/features/auth/domain/models/user_profile.dart';
import 'package:sabor_de_casa/features/menu/domain/models/category.dart';
import 'package:sabor_de_casa/features/menu/domain/models/dish.dart';

// ─── Tests de serialización de modelos de dominio del menú ───────────────────
//
// Al no poder mockear fácilmente la cadena de query builder de Supabase
// (PostgrestFilterBuilder es un tipo sellado con generics complejos), los tests
// de integración real con Supabase se realizan en entorno de staging.
// Aquí se verifica que los modelos de dominio deserializan correctamente.

void main() {
  group('Category.fromJson', () {
    test('deserializa todos los campos obligatorios', () {
      final json = <String, dynamic>{
        'id': 'cat-uuid-1',
        'name': 'Entrantes',
        'is_active': true,
        'sort_order': 1,
      };

      final category = Category.fromJson(json);

      expect(category.id, 'cat-uuid-1');
      expect(category.name, 'Entrantes');
      expect(category.isActive, isTrue);
    });

    test('deserializa con imageUrl nulo sin error', () {
      final json = <String, dynamic>{
        'id': 'cat-uuid-2',
        'name': 'Postres',
        'is_active': true,
        'sort_order': 5,
        'image_url': null,
      };

      final category = Category.fromJson(json);
      expect(category.imageUrl, isNull);
    });
  });

  group('Dish.fromJson', () {
    test('deserializa precio como double', () {
      final json = <String, dynamic>{
        'id': 'dish-uuid-1',
        'category_id': 'cat-uuid-1',
        'name': 'Croquetas caseras',
        'price': 8.5,
        'is_active': true,
        'is_available': true,
      };

      final dish = Dish.fromJson(json);

      expect(dish.name, 'Croquetas caseras');
      expect(dish.price, 8.5);
    });

    test('deserializa precio entero como double sin error', () {
      final json = <String, dynamic>{
        'id': 'dish-uuid-2',
        'category_id': 'cat-uuid-1',
        'name': 'Gazpacho',
        'price': 6,
        'is_active': true,
        'is_available': true,
      };

      final dish = Dish.fromJson(json);
      expect(dish.price, 6.0);
    });
  });

  group('UserProfile.fromJson', () {
    test('deserializa rol por defecto como client', () {
      final json = <String, dynamic>{
        'id': 'user-uuid-1',
        'email': 'test@example.com',
      };

      final profile = UserProfile.fromJson(json);
      expect(profile.role, UserRole.client);
    });

    test('deserializa rol admin correctamente', () {
      final json = <String, dynamic>{
        'id': 'user-uuid-2',
        'email': 'admin@example.com',
        'role': 'admin',
      };

      final profile = UserProfile.fromJson(json);
      expect(profile.role, UserRole.admin);
    });
  });
}
