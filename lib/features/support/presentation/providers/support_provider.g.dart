// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mySupportThreadsHash() => r'24240d834d07787c74cdd8634313a8c461505b30';

/// See also [mySupportThreads].
@ProviderFor(mySupportThreads)
final mySupportThreadsProvider =
    AutoDisposeFutureProvider<List<SupportThread>>.internal(
      mySupportThreads,
      name: r'mySupportThreadsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$mySupportThreadsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MySupportThreadsRef = AutoDisposeFutureProviderRef<List<SupportThread>>;
String _$adminSupportThreadsHash() =>
    r'5ce8ca8a7be37176f174ea76b15bca858c79092f';

/// See also [adminSupportThreads].
@ProviderFor(adminSupportThreads)
final adminSupportThreadsProvider =
    AutoDisposeFutureProvider<List<SupportThread>>.internal(
      adminSupportThreads,
      name: r'adminSupportThreadsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminSupportThreadsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminSupportThreadsRef =
    AutoDisposeFutureProviderRef<List<SupportThread>>;
String _$supportMessagesHash() => r'b1a31c9c06e0f85cf60cfff5ca459a9d2bc82263';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [supportMessages].
@ProviderFor(supportMessages)
const supportMessagesProvider = SupportMessagesFamily();

/// See also [supportMessages].
class SupportMessagesFamily extends Family<AsyncValue<List<SupportMessage>>> {
  /// See also [supportMessages].
  const SupportMessagesFamily();

  /// See also [supportMessages].
  SupportMessagesProvider call(String threadId) {
    return SupportMessagesProvider(threadId);
  }

  @override
  SupportMessagesProvider getProviderOverride(
    covariant SupportMessagesProvider provider,
  ) {
    return call(provider.threadId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'supportMessagesProvider';
}

/// See also [supportMessages].
class SupportMessagesProvider
    extends AutoDisposeFutureProvider<List<SupportMessage>> {
  /// See also [supportMessages].
  SupportMessagesProvider(String threadId)
    : this._internal(
        (ref) => supportMessages(ref as SupportMessagesRef, threadId),
        from: supportMessagesProvider,
        name: r'supportMessagesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$supportMessagesHash,
        dependencies: SupportMessagesFamily._dependencies,
        allTransitiveDependencies:
            SupportMessagesFamily._allTransitiveDependencies,
        threadId: threadId,
      );

  SupportMessagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.threadId,
  }) : super.internal();

  final String threadId;

  @override
  Override overrideWith(
    FutureOr<List<SupportMessage>> Function(SupportMessagesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SupportMessagesProvider._internal(
        (ref) => create(ref as SupportMessagesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        threadId: threadId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SupportMessage>> createElement() {
    return _SupportMessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SupportMessagesProvider && other.threadId == threadId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, threadId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SupportMessagesRef on AutoDisposeFutureProviderRef<List<SupportMessage>> {
  /// The parameter `threadId` of this provider.
  String get threadId;
}

class _SupportMessagesProviderElement
    extends AutoDisposeFutureProviderElement<List<SupportMessage>>
    with SupportMessagesRef {
  _SupportMessagesProviderElement(super.provider);

  @override
  String get threadId => (origin as SupportMessagesProvider).threadId;
}

String _$supportActionHash() => r'a37ec4f467be450f86578436e683fae3bef145f1';

/// See also [SupportAction].
@ProviderFor(SupportAction)
final supportActionProvider =
    AutoDisposeAsyncNotifierProvider<SupportAction, void>.internal(
      SupportAction.new,
      name: r'supportActionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$supportActionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SupportAction = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
