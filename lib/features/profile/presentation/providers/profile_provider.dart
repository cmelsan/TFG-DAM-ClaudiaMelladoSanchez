import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/features/auth/domain/models/user_profile.dart';
import 'package:sabor_de_casa/features/profile/data/repositories/profile_repository.dart';

part 'profile_provider.g.dart';

@riverpod
class AddressesNotifier extends _$AddressesNotifier {
  @override
  Future<List<Map<String, dynamic>>> build() {
    // ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
    return ref.watch(profileRepositoryProvider).getAddresses();
  }

  Future<void> add({
    required String label,
    required String street,
    required String city,
    required String postalCode,
    String? notes,
    bool isDefault = false,
  }) async {
    await ref
        .read(profileRepositoryProvider)
        .addAddress(
          label: label,
          street: street,
          city: city,
          postalCode: postalCode,
          notes: notes,
          isDefault: isDefault,
        );
    ref.invalidateSelf();
  }

  Future<void> remove(String id) async {
    await ref.read(profileRepositoryProvider).deleteAddress(id);
    ref.invalidateSelf();
  }
}

@Riverpod(keepAlive: true)
class ProfileNotifier extends _$ProfileNotifier {
  late final ProfileRepository _repo;

  @override
  FutureOr<UserProfile> build() async {
    // ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
    _repo = ref.watch(profileRepositoryProvider);
    return _repo.getMyProfile();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repo.getMyProfile);
  }

  Future<void> updateProfile({required String fullName, String? phone}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repo.updateMyProfile(fullName: fullName, phone: phone),
    );
  }
}
