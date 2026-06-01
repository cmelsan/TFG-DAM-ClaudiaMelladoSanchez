import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/features/newsletter/data/repositories/newsletter_repository.dart';
import 'package:sabor_de_casa/features/newsletter/domain/models/newsletter_subscriber.dart';

part 'newsletter_provider.g.dart';

@riverpod
Future<List<NewsletterSubscriber>> newsletterSubscribers(
  NewsletterSubscribersRef ref, // ignore: deprecated_member_use_from_same_package
) {
  return ref.watch(newsletterRepositoryProvider).list();
}

@riverpod
class NewsletterAction extends _$NewsletterAction {
  @override
  FutureOr<void> build() {
    ref.keepAlive();
  }

  Future<void> subscribe({
    required String email,
    String? fullName,
    String source = 'web',
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(newsletterRepositoryProvider)
          .subscribe(email: email, fullName: fullName, source: source),
    );
  }

  Future<void> updateStatus({
    required String id,
    required String status,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(newsletterRepositoryProvider)
          .updateStatus(id: id, status: status),
    );
    ref.invalidate(newsletterSubscribersProvider);
  }

  Future<void> remove(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(newsletterRepositoryProvider).remove(id),
    );
    ref.invalidate(newsletterSubscribersProvider);
  }
}
