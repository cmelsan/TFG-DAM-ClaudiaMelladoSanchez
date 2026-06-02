import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';
import 'package:sabor_de_casa/features/support/data/repositories/support_repository.dart';
import 'package:sabor_de_casa/features/support/domain/models/support_message.dart';
import 'package:sabor_de_casa/features/support/domain/models/support_thread.dart';

part 'support_provider.g.dart';

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<SupportThread>> mySupportThreads(MySupportThreadsRef ref) {
  return ref.watch(supportRepositoryProvider).getMyThreads();
}

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<SupportThread>> adminSupportThreads(AdminSupportThreadsRef ref) {
  return ref.watch(supportRepositoryProvider).getAllThreads();
}

@riverpod
Future<List<SupportMessage>> supportMessages(
  // ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
  SupportMessagesRef ref,
  String threadId,
) {
  return ref.watch(supportRepositoryProvider).getMessages(threadId);
}

@riverpod
class SupportAction extends _$SupportAction {
  @override
  FutureOr<void> build() {}

  Future<String?> createThread({
    required String subject,
    required String category,
    required String message,
  }) async {
    state = const AsyncLoading();
    String? threadId;
    state = await AsyncValue.guard(() async {
      threadId = await ref
          .read(supportRepositoryProvider)
          .createThread(subject: subject, category: category, message: message);
    });
    ref
      ..invalidate(mySupportThreadsProvider)
      ..invalidate(adminSupportThreadsProvider)
      ..invalidate(adminDashboardStatsProvider);
    return threadId;
  }

  Future<void> sendMessage({
    required String threadId,
    required String body,
    required bool asAdmin,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(supportRepositoryProvider)
          .sendMessage(threadId: threadId, body: body, asAdmin: asAdmin),
    );
    ref
      ..invalidate(supportMessagesProvider(threadId))
      ..invalidate(mySupportThreadsProvider)
      ..invalidate(adminSupportThreadsProvider)
      ..invalidate(adminDashboardStatsProvider);
  }

  Future<void> markRead(String threadId, {required bool asAdmin}) async {
    await ref
        .read(supportRepositoryProvider)
        .markRead(threadId, asAdmin: asAdmin);
    ref
      ..invalidate(mySupportThreadsProvider)
      ..invalidate(adminSupportThreadsProvider)
      ..invalidate(adminDashboardStatsProvider);
  }

  Future<void> closeThread(String threadId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(supportRepositoryProvider).closeThread(threadId),
    );
    ref
      ..invalidate(mySupportThreadsProvider)
      ..invalidate(adminSupportThreadsProvider)
      ..invalidate(adminDashboardStatsProvider);
  }
}
