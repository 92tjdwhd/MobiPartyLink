// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getJobCategoriesProviderHash() =>
    r'9b9afc8a64a9944f6f535ea2cad0f4feda790dd6';

/// See also [getJobCategoriesProvider].
@ProviderFor(getJobCategoriesProvider)
final getJobCategoriesProviderProvider =
    AutoDisposeFutureProvider<List<JobCategoryEntity>>.internal(
  getJobCategoriesProvider,
  name: r'getJobCategoriesProviderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getJobCategoriesProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetJobCategoriesProviderRef
    = AutoDisposeFutureProviderRef<List<JobCategoryEntity>>;
String _$getJobsProviderHash() => r'75389c82d0310d3c0e5dfed2fb3a0cf8c91efe1c';

/// See also [getJobsProvider].
@ProviderFor(getJobsProvider)
final getJobsProviderProvider =
    AutoDisposeFutureProvider<List<JobEntity>>.internal(
  getJobsProvider,
  name: r'getJobsProviderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getJobsProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetJobsProviderRef = AutoDisposeFutureProviderRef<List<JobEntity>>;
String _$getJobsByCategoryProviderHash() =>
    r'f16c47c09441d39e25be95ac62452d8ff961af3d';

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

/// See also [getJobsByCategoryProvider].
@ProviderFor(getJobsByCategoryProvider)
const getJobsByCategoryProviderProvider = GetJobsByCategoryProviderFamily();

/// See also [getJobsByCategoryProvider].
class GetJobsByCategoryProviderFamily
    extends Family<AsyncValue<List<JobEntity>>> {
  /// See also [getJobsByCategoryProvider].
  const GetJobsByCategoryProviderFamily();

  /// See also [getJobsByCategoryProvider].
  GetJobsByCategoryProviderProvider call(
    String categoryId,
  ) {
    return GetJobsByCategoryProviderProvider(
      categoryId,
    );
  }

  @override
  GetJobsByCategoryProviderProvider getProviderOverride(
    covariant GetJobsByCategoryProviderProvider provider,
  ) {
    return call(
      provider.categoryId,
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
  String? get name => r'getJobsByCategoryProviderProvider';
}

/// See also [getJobsByCategoryProvider].
class GetJobsByCategoryProviderProvider
    extends AutoDisposeFutureProvider<List<JobEntity>> {
  /// See also [getJobsByCategoryProvider].
  GetJobsByCategoryProviderProvider(
    String categoryId,
  ) : this._internal(
          (ref) => getJobsByCategoryProvider(
            ref as GetJobsByCategoryProviderRef,
            categoryId,
          ),
          from: getJobsByCategoryProviderProvider,
          name: r'getJobsByCategoryProviderProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$getJobsByCategoryProviderHash,
          dependencies: GetJobsByCategoryProviderFamily._dependencies,
          allTransitiveDependencies:
              GetJobsByCategoryProviderFamily._allTransitiveDependencies,
          categoryId: categoryId,
        );

  GetJobsByCategoryProviderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
  }) : super.internal();

  final String categoryId;

  @override
  Override overrideWith(
    FutureOr<List<JobEntity>> Function(GetJobsByCategoryProviderRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GetJobsByCategoryProviderProvider._internal(
        (ref) => create(ref as GetJobsByCategoryProviderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<JobEntity>> createElement() {
    return _GetJobsByCategoryProviderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetJobsByCategoryProviderProvider &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GetJobsByCategoryProviderRef
    on AutoDisposeFutureProviderRef<List<JobEntity>> {
  /// The parameter `categoryId` of this provider.
  String get categoryId;
}

class _GetJobsByCategoryProviderProviderElement
    extends AutoDisposeFutureProviderElement<List<JobEntity>>
    with GetJobsByCategoryProviderRef {
  _GetJobsByCategoryProviderProviderElement(super.provider);

  @override
  String get categoryId =>
      (origin as GetJobsByCategoryProviderProvider).categoryId;
}

String _$getJobByIdProviderHash() =>
    r'b6db872e517c62b237c8d7cdda1d652e72c3554e';

/// See also [getJobByIdProvider].
@ProviderFor(getJobByIdProvider)
const getJobByIdProviderProvider = GetJobByIdProviderFamily();

/// See also [getJobByIdProvider].
class GetJobByIdProviderFamily extends Family<AsyncValue<JobEntity>> {
  /// See also [getJobByIdProvider].
  const GetJobByIdProviderFamily();

  /// See also [getJobByIdProvider].
  GetJobByIdProviderProvider call(
    String jobId,
  ) {
    return GetJobByIdProviderProvider(
      jobId,
    );
  }

  @override
  GetJobByIdProviderProvider getProviderOverride(
    covariant GetJobByIdProviderProvider provider,
  ) {
    return call(
      provider.jobId,
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
  String? get name => r'getJobByIdProviderProvider';
}

/// See also [getJobByIdProvider].
class GetJobByIdProviderProvider extends AutoDisposeFutureProvider<JobEntity> {
  /// See also [getJobByIdProvider].
  GetJobByIdProviderProvider(
    String jobId,
  ) : this._internal(
          (ref) => getJobByIdProvider(
            ref as GetJobByIdProviderRef,
            jobId,
          ),
          from: getJobByIdProviderProvider,
          name: r'getJobByIdProviderProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$getJobByIdProviderHash,
          dependencies: GetJobByIdProviderFamily._dependencies,
          allTransitiveDependencies:
              GetJobByIdProviderFamily._allTransitiveDependencies,
          jobId: jobId,
        );

  GetJobByIdProviderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.jobId,
  }) : super.internal();

  final String jobId;

  @override
  Override overrideWith(
    FutureOr<JobEntity> Function(GetJobByIdProviderRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GetJobByIdProviderProvider._internal(
        (ref) => create(ref as GetJobByIdProviderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        jobId: jobId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<JobEntity> createElement() {
    return _GetJobByIdProviderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetJobByIdProviderProvider && other.jobId == jobId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, jobId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GetJobByIdProviderRef on AutoDisposeFutureProviderRef<JobEntity> {
  /// The parameter `jobId` of this provider.
  String get jobId;
}

class _GetJobByIdProviderProviderElement
    extends AutoDisposeFutureProviderElement<JobEntity>
    with GetJobByIdProviderRef {
  _GetJobByIdProviderProviderElement(super.provider);

  @override
  String get jobId => (origin as GetJobByIdProviderProvider).jobId;
}

String _$getJobsGroupedByCategoryProviderHash() =>
    r'98bf905f3bbc30ab26afad535f98c43270e8f2d5';

/// See also [getJobsGroupedByCategoryProvider].
@ProviderFor(getJobsGroupedByCategoryProvider)
final getJobsGroupedByCategoryProviderProvider =
    AutoDisposeFutureProvider<Map<String, List<JobEntity>>>.internal(
  getJobsGroupedByCategoryProvider,
  name: r'getJobsGroupedByCategoryProviderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getJobsGroupedByCategoryProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetJobsGroupedByCategoryProviderRef
    = AutoDisposeFutureProviderRef<Map<String, List<JobEntity>>>;
String _$getJobCategoriesUseCaseProviderHash() =>
    r'c27885126b7a0754a6ff45a293d2685b85858508';

/// See also [getJobCategoriesUseCaseProvider].
@ProviderFor(getJobCategoriesUseCaseProvider)
final getJobCategoriesUseCaseProviderProvider =
    AutoDisposeProvider<GetJobCategories>.internal(
  getJobCategoriesUseCaseProvider,
  name: r'getJobCategoriesUseCaseProviderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getJobCategoriesUseCaseProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetJobCategoriesUseCaseProviderRef
    = AutoDisposeProviderRef<GetJobCategories>;
String _$getJobsUseCaseProviderHash() =>
    r'43be50ef9dfc6f5fe71232fe89d664e163a2eeaf';

/// See also [getJobsUseCaseProvider].
@ProviderFor(getJobsUseCaseProvider)
final getJobsUseCaseProviderProvider = AutoDisposeProvider<GetJobs>.internal(
  getJobsUseCaseProvider,
  name: r'getJobsUseCaseProviderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getJobsUseCaseProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetJobsUseCaseProviderRef = AutoDisposeProviderRef<GetJobs>;
String _$getJobsByCategoryUseCaseProviderHash() =>
    r'3d5eff1d96240528e4545d0f2163252f9b077203';

/// See also [getJobsByCategoryUseCaseProvider].
@ProviderFor(getJobsByCategoryUseCaseProvider)
final getJobsByCategoryUseCaseProviderProvider =
    AutoDisposeProvider<GetJobsByCategory>.internal(
  getJobsByCategoryUseCaseProvider,
  name: r'getJobsByCategoryUseCaseProviderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getJobsByCategoryUseCaseProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetJobsByCategoryUseCaseProviderRef
    = AutoDisposeProviderRef<GetJobsByCategory>;
String _$getJobByIdUseCaseProviderHash() =>
    r'9c07ddc3702d89eeba3448f5a9012d1ea8f09bbb';

/// See also [getJobByIdUseCaseProvider].
@ProviderFor(getJobByIdUseCaseProvider)
final getJobByIdUseCaseProviderProvider =
    AutoDisposeProvider<GetJobById>.internal(
  getJobByIdUseCaseProvider,
  name: r'getJobByIdUseCaseProviderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getJobByIdUseCaseProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetJobByIdUseCaseProviderRef = AutoDisposeProviderRef<GetJobById>;
String _$getJobsGroupedByCategoryUseCaseProviderHash() =>
    r'6b805d85de7c1641648236f9906b45098dd87b8e';

/// See also [getJobsGroupedByCategoryUseCaseProvider].
@ProviderFor(getJobsGroupedByCategoryUseCaseProvider)
final getJobsGroupedByCategoryUseCaseProviderProvider =
    AutoDisposeProvider<GetJobsGroupedByCategory>.internal(
  getJobsGroupedByCategoryUseCaseProvider,
  name: r'getJobsGroupedByCategoryUseCaseProviderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getJobsGroupedByCategoryUseCaseProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetJobsGroupedByCategoryUseCaseProviderRef
    = AutoDisposeProviderRef<GetJobsGroupedByCategory>;
String _$jobNotifierHash() => r'cb33e7ddadec00b68a3b0f501a1f4fb4a69da3b7';

/// See also [JobNotifier].
@ProviderFor(JobNotifier)
final jobNotifierProvider = AutoDisposeAsyncNotifierProvider<JobNotifier,
    List<JobCategoryEntity>>.internal(
  JobNotifier.new,
  name: r'jobNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$jobNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$JobNotifier = AutoDisposeAsyncNotifier<List<JobCategoryEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
