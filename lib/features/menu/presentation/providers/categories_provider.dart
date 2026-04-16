import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/features/menu/data/repositories/menu_repository.dart';
import 'package:sabor_de_casa/features/menu/domain/models/category.dart';

part 'categories_provider.g.dart';

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<Category>> categories(CategoriesRef ref) {
  return ref.watch(menuRepositoryProvider).getCategories();
}
