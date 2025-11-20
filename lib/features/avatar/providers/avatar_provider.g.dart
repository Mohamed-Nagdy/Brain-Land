// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avatar_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$avatarStorageServiceHash() =>
    r'0cc456efe2cfb6aadc006e63249ba9a9af205eef';

/// Provider for the avatar storage service
///
/// Copied from [avatarStorageService].
@ProviderFor(avatarStorageService)
final avatarStorageServiceProvider =
    AutoDisposeProvider<AvatarStorageService>.internal(
  avatarStorageService,
  name: r'avatarStorageServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$avatarStorageServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AvatarStorageServiceRef = AutoDisposeProviderRef<AvatarStorageService>;
String _$avatarNotifierHash() => r'570726c8c6ea0b76beb9adf359daeb649938dc5c';

/// Avatar state notifier with code generation
///
/// Copied from [AvatarNotifier].
@ProviderFor(AvatarNotifier)
final avatarNotifierProvider =
    AutoDisposeNotifierProvider<AvatarNotifier, Avatar>.internal(
  AvatarNotifier.new,
  name: r'avatarNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$avatarNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AvatarNotifier = AutoDisposeNotifier<Avatar>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
