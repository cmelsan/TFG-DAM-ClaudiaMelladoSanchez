import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_service.g.dart';

@Riverpod(keepAlive: true)
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
SupabaseClient supabaseClient(SupabaseClientRef ref) {
  return Supabase.instance.client;
}
