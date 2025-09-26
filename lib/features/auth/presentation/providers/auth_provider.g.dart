// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getCurrentUserHash() => r'c7ff9d712020b021dc2d0bc128d190755e3995ba';

/// See also [getCurrentUser].
@ProviderFor(getCurrentUser)
final getCurrentUserProvider = AutoDisposeProvider<GetCurrentUser>.internal(
  getCurrentUser,
  name: r'getCurrentUserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getCurrentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetCurrentUserRef = AutoDisposeProviderRef<GetCurrentUser>;
String _$signInAnonymouslyHash() => r'a08e5cd15e5e6496417cde2bb11137bcb84c37d8';

/// See also [signInAnonymously].
@ProviderFor(signInAnonymously)
final signInAnonymouslyProvider =
    AutoDisposeProvider<SignInAnonymously>.internal(
  signInAnonymously,
  name: r'signInAnonymouslyProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$signInAnonymouslyHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SignInAnonymouslyRef = AutoDisposeProviderRef<SignInAnonymously>;
String _$signOutHash() => r'b4d3cd9b81bd36812e30072c0f8be479f35e4389';

/// See also [signOut].
@ProviderFor(signOut)
final signOutProvider = AutoDisposeProvider<SignOut>.internal(
  signOut,
  name: r'signOutProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$signOutHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SignOutRef = AutoDisposeProviderRef<SignOut>;
String _$authNotifierHash() => r'2fde96549f4e3dc8c9168f6f0232dc48034ea73e';

/// See also [AuthNotifier].
@ProviderFor(AuthNotifier)
final authNotifierProvider =
    AutoDisposeAsyncNotifierProvider<AuthNotifier, AuthUserEntity?>.internal(
  AuthNotifier.new,
  name: r'authNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthNotifier = AutoDisposeAsyncNotifier<AuthUserEntity?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
