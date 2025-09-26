// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'party_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$partyListNotifierHash() => r'1d33f6c79c57a427d03584976727b8ca2e1d60fd';

/// See also [PartyListNotifier].
@ProviderFor(PartyListNotifier)
final partyListNotifierProvider = AutoDisposeAsyncNotifierProvider<
    PartyListNotifier, List<PartyEntity>>.internal(
  PartyListNotifier.new,
  name: r'partyListNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$partyListNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PartyListNotifier = AutoDisposeAsyncNotifier<List<PartyEntity>>;
String _$partyDetailNotifierHash() =>
    r'a19a4b027424d846ea4f7234f6f2a660076a78d9';

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

abstract class _$PartyDetailNotifier
    extends BuildlessAutoDisposeAsyncNotifier<PartyEntity?> {
  late final String partyId;

  FutureOr<PartyEntity?> build(
    String partyId,
  );
}

/// See also [PartyDetailNotifier].
@ProviderFor(PartyDetailNotifier)
const partyDetailNotifierProvider = PartyDetailNotifierFamily();

/// See also [PartyDetailNotifier].
class PartyDetailNotifierFamily extends Family<AsyncValue<PartyEntity?>> {
  /// See also [PartyDetailNotifier].
  const PartyDetailNotifierFamily();

  /// See also [PartyDetailNotifier].
  PartyDetailNotifierProvider call(
    String partyId,
  ) {
    return PartyDetailNotifierProvider(
      partyId,
    );
  }

  @override
  PartyDetailNotifierProvider getProviderOverride(
    covariant PartyDetailNotifierProvider provider,
  ) {
    return call(
      provider.partyId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'partyDetailNotifierProvider';
}

/// See also [PartyDetailNotifier].
class PartyDetailNotifierProvider extends AutoDisposeAsyncNotifierProviderImpl<
    PartyDetailNotifier, PartyEntity?> {
  /// See also [PartyDetailNotifier].
  PartyDetailNotifierProvider(
    String partyId,
  ) : this._internal(
          () => PartyDetailNotifier()..partyId = partyId,
          from: partyDetailNotifierProvider,
          name: r'partyDetailNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$partyDetailNotifierHash,
          dependencies: PartyDetailNotifierFamily._dependencies,
          allTransitiveDependencies:
              PartyDetailNotifierFamily._allTransitiveDependencies,
          partyId: partyId,
        );

  PartyDetailNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.partyId,
  }) : super.internal();

  final String partyId;

  @override
  FutureOr<PartyEntity?> runNotifierBuild(
    covariant PartyDetailNotifier notifier,
  ) {
    return notifier.build(
      partyId,
    );
  }

  @override
  Override overrideWith(PartyDetailNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: PartyDetailNotifierProvider._internal(
        () => create()..partyId = partyId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        partyId: partyId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<PartyDetailNotifier, PartyEntity?>
      createElement() {
    return _PartyDetailNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PartyDetailNotifierProvider && other.partyId == partyId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, partyId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PartyDetailNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<PartyEntity?> {
  /// The parameter `partyId` of this provider.
  String get partyId;
}

class _PartyDetailNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PartyDetailNotifier,
        PartyEntity?> with PartyDetailNotifierRef {
  _PartyDetailNotifierProviderElement(super.provider);

  @override
  String get partyId => (origin as PartyDetailNotifierProvider).partyId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
