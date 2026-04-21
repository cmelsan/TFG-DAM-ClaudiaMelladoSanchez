import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/core/constants/supabase_constants.dart';
import 'package:sabor_de_casa/core/errors/failures.dart';
import 'package:sabor_de_casa/features/catering/domain/models/event_menu.dart';
import 'package:sabor_de_casa/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'catering_repository.g.dart';

@Riverpod(keepAlive: true)
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
CateringRepository cateringRepository(CateringRepositoryRef ref) {
  return CateringRepository(ref.watch(supabaseClientProvider));
}

class CateringRepository {
  CateringRepository(this._client);

  final SupabaseClient _client;

  Future<List<EventMenu>> getActiveMenus() async {
    try {
      final data = await _client
          .from(SupabaseConstants.eventMenus)
          .select()
          .eq('is_active', true)
          .order('name');

      return data.map(EventMenu.fromJson).toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }
}
