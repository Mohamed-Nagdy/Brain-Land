// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dailyRewardsHash() => r'dd475654bf57c85642f33a1ec161e689728ca7ec';

/// Provider for daily rewards (30-day cycle)
///
/// Copied from [dailyRewards].
@ProviderFor(dailyRewards)
final dailyRewardsProvider = Provider<List<DailyReward>>.internal(
  dailyRewards,
  name: r'dailyRewardsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$dailyRewardsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DailyRewardsRef = ProviderRef<List<DailyReward>>;
String _$todaysRewardHash() => r'7bb07604f2d4109192635b5f7cce96b29cdca8f0';

/// Provider for today's reward based on current streak
///
/// Copied from [todaysReward].
@ProviderFor(todaysReward)
final todaysRewardProvider = FutureProvider<DailyReward?>.internal(
  todaysReward,
  name: r'todaysRewardProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$todaysRewardHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TodaysRewardRef = FutureProviderRef<DailyReward?>;
String _$hasLoggedInTodayHash() => r'1471781944ebf9245789bff844cea6cc29999784';

/// Provider to check if user has logged in today
///
/// Copied from [hasLoggedInToday].
@ProviderFor(hasLoggedInToday)
final hasLoggedInTodayProvider = FutureProvider<bool>.internal(
  hasLoggedInToday,
  name: r'hasLoggedInTodayProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasLoggedInTodayHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HasLoggedInTodayRef = FutureProviderRef<bool>;
String _$streakCalendarHash() => r'd754f69514423f8ec8e025f0145476bc10517a76';

/// Provider for streak calendar (last 7 days)
///
/// Copied from [streakCalendar].
@ProviderFor(streakCalendar)
final streakCalendarProvider = FutureProvider<List<DateTime>>.internal(
  streakCalendar,
  name: r'streakCalendarProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$streakCalendarHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef StreakCalendarRef = FutureProviderRef<List<DateTime>>;
String _$isDateInStreakHash() => r'e6f9acf28c412dfe74ce8d8e93a725a691da3254';

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

/// Provider to check if a specific date is in the streak
///
/// Copied from [isDateInStreak].
@ProviderFor(isDateInStreak)
const isDateInStreakProvider = IsDateInStreakFamily();

/// Provider to check if a specific date is in the streak
///
/// Copied from [isDateInStreak].
class IsDateInStreakFamily extends Family<AsyncValue<bool>> {
  /// Provider to check if a specific date is in the streak
  ///
  /// Copied from [isDateInStreak].
  const IsDateInStreakFamily();

  /// Provider to check if a specific date is in the streak
  ///
  /// Copied from [isDateInStreak].
  IsDateInStreakProvider call(
    DateTime date,
  ) {
    return IsDateInStreakProvider(
      date,
    );
  }

  @override
  IsDateInStreakProvider getProviderOverride(
    covariant IsDateInStreakProvider provider,
  ) {
    return call(
      provider.date,
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
  String? get name => r'isDateInStreakProvider';
}

/// Provider to check if a specific date is in the streak
///
/// Copied from [isDateInStreak].
class IsDateInStreakProvider extends FutureProvider<bool> {
  /// Provider to check if a specific date is in the streak
  ///
  /// Copied from [isDateInStreak].
  IsDateInStreakProvider(
    DateTime date,
  ) : this._internal(
          (ref) => isDateInStreak(
            ref as IsDateInStreakRef,
            date,
          ),
          from: isDateInStreakProvider,
          name: r'isDateInStreakProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$isDateInStreakHash,
          dependencies: IsDateInStreakFamily._dependencies,
          allTransitiveDependencies:
              IsDateInStreakFamily._allTransitiveDependencies,
          date: date,
        );

  IsDateInStreakProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final DateTime date;

  @override
  Override overrideWith(
    FutureOr<bool> Function(IsDateInStreakRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsDateInStreakProvider._internal(
        (ref) => create(ref as IsDateInStreakRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  FutureProviderElement<bool> createElement() {
    return _IsDateInStreakProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsDateInStreakProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin IsDateInStreakRef on FutureProviderRef<bool> {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _IsDateInStreakProviderElement extends FutureProviderElement<bool>
    with IsDateInStreakRef {
  _IsDateInStreakProviderElement(super.provider);

  @override
  DateTime get date => (origin as IsDateInStreakProvider).date;
}

String _$streakNotifierHash() => r'2d9bfabbdab1748fe61b6a627ed73a6c3083cff9';

/// Streak state notifier
///
/// Copied from [StreakNotifier].
@ProviderFor(StreakNotifier)
final streakNotifierProvider =
    AutoDisposeAsyncNotifierProvider<StreakNotifier, int>.internal(
  StreakNotifier.new,
  name: r'streakNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$streakNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StreakNotifier = AutoDisposeAsyncNotifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
