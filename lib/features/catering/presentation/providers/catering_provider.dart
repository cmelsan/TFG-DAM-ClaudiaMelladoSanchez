import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/features/catering/data/repositories/catering_repository.dart';
import 'package:sabor_de_casa/features/catering/domain/models/event_menu.dart';

part 'catering_provider.g.dart';

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<EventMenu>> cateringMenus(CateringMenusRef ref) {
  return ref.watch(cateringRepositoryProvider).getActiveMenus();
}
