import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/features/contact/data/repositories/contact_repository.dart';

part 'contact_provider.g.dart';

@riverpod
class ContactSubmit extends _$ContactSubmit {
  @override
  FutureOr<void> build() {}

  Future<void> submit({
    required String name,
    required String email,
    required String subject,
    required String message,
    String? phone,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(contactRepositoryProvider)
          .sendMessage(
            name: name,
            email: email,
            phone: phone,
            subject: subject,
            message: message,
          ),
    );
  }
}
