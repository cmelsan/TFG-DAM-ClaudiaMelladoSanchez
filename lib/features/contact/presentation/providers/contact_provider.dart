import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/features/contact/data/repositories/contact_repository.dart';
import 'package:sabor_de_casa/features/contact/domain/models/contact_admin_message.dart';

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

final adminContactMessagesProvider = FutureProvider<List<ContactAdminMessage>>((
  ref,
) async {
  return ref.read(contactRepositoryProvider).getAdminMessages();
});

class ContactAdminActionNotifier extends StateNotifier<AsyncValue<void>> {
  ContactAdminActionNotifier(this._ref) : super(const AsyncData(null));

  final Ref _ref;

  Future<void> markRead(String id, {required bool isRead}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _ref
          .read(contactRepositoryProvider)
          .markAdminMessageRead(id, isRead: isRead),
    );
    _ref.invalidate(adminContactMessagesProvider);
  }
}

final contactAdminActionProvider =
    StateNotifierProvider<ContactAdminActionNotifier, AsyncValue<void>>(
      ContactAdminActionNotifier.new,
    );
