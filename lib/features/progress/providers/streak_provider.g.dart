// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Streak state notifier

@ProviderFor(StreakNotifier)
const streakProvider = StreakNotifierProvider._();

/// Streak state notifier
final class StreakNotifierProvider
    extends $AsyncNotifierProvider<StreakNotifier, int> {
  /// Streak state notifier
  const StreakNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'streakProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$streakNotifierHash();

  @$internal
  @override
  StreakNotifier create() => StreakNotifier();
}

String _$streakNotifierHash() => r'2d9bfabbdab1748fe61b6a627ed73a6c3083cff9';

/// Streak state notifier

abstract class _$StreakNotifier extends $AsyncNotifier<int> {
  FutureOr<int> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<int>, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int>, int>,
              AsyncValue<int>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for daily rewards (30-day cycle)

@ProviderFor(dailyRewards)
const dailyRewardsProvider = DailyRewardsProvider._();

/// Provider for daily rewards (30-day cycle)

final class DailyRewardsProvider
    extends
        $FunctionalProvider<
          List<DailyReward>,
          List<DailyReward>,
          List<DailyReward>
        >
    with $Provider<List<DailyReward>> {
  /// Provider for daily rewards (30-day cycle)
  const DailyRewardsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dailyRewardsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dailyRewardsHash();

  @$internal
  @override
  $ProviderElement<List<DailyReward>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<DailyReward> create(Ref ref) {
    return dailyRewards(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<DailyReward> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<DailyReward>>(value),
    );
  }
}

String _$dailyRewardsHash() => r'dd475654bf57c85642f33a1ec161e689728ca7ec';

/// Provider for today's reward based on current streak

@ProviderFor(todaysReward)
const todaysRewardProvider = TodaysRewardProvider._();

/// Provider for today's reward based on current streak

final class TodaysRewardProvider
    extends
        $FunctionalProvider<
          AsyncValue<DailyReward?>,
          DailyReward?,
          FutureOr<DailyReward?>
        >
    with $FutureModifier<DailyReward?>, $FutureProvider<DailyReward?> {
  /// Provider for today's reward based on current streak
  const TodaysRewardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todaysRewardProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todaysRewardHash();

  @$internal
  @override
  $FutureProviderElement<DailyReward?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DailyReward?> create(Ref ref) {
    return todaysReward(ref);
  }
}

String _$todaysRewardHash() => r'7bb07604f2d4109192635b5f7cce96b29cdca8f0';

/// Provider to check if user has logged in today

@ProviderFor(hasLoggedInToday)
const hasLoggedInTodayProvider = HasLoggedInTodayProvider._();

/// Provider to check if user has logged in today

final class HasLoggedInTodayProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Provider to check if user has logged in today
  const HasLoggedInTodayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasLoggedInTodayProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasLoggedInTodayHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return hasLoggedInToday(ref);
  }
}

String _$hasLoggedInTodayHash() => r'1471781944ebf9245789bff844cea6cc29999784';

/// Provider for streak calendar (last 7 days)

@ProviderFor(streakCalendar)
const streakCalendarProvider = StreakCalendarProvider._();

/// Provider for streak calendar (last 7 days)

final class StreakCalendarProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DateTime>>,
          List<DateTime>,
          FutureOr<List<DateTime>>
        >
    with $FutureModifier<List<DateTime>>, $FutureProvider<List<DateTime>> {
  /// Provider for streak calendar (last 7 days)
  const StreakCalendarProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'streakCalendarProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$streakCalendarHash();

  @$internal
  @override
  $FutureProviderElement<List<DateTime>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DateTime>> create(Ref ref) {
    return streakCalendar(ref);
  }
}

String _$streakCalendarHash() => r'd754f69514423f8ec8e025f0145476bc10517a76';

/// Provider to check if a specific date is in the streak

@ProviderFor(isDateInStreak)
const isDateInStreakProvider = IsDateInStreakFamily._();

/// Provider to check if a specific date is in the streak

final class IsDateInStreakProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Provider to check if a specific date is in the streak
  const IsDateInStreakProvider._({
    required IsDateInStreakFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'isDateInStreakProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isDateInStreakHash();

  @override
  String toString() {
    return r'isDateInStreakProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as DateTime;
    return isDateInStreak(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IsDateInStreakProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isDateInStreakHash() => r'e6f9acf28c412dfe74ce8d8e93a725a691da3254';

/// Provider to check if a specific date is in the streak

final class IsDateInStreakFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, DateTime> {
  const IsDateInStreakFamily._()
    : super(
        retry: null,
        name: r'isDateInStreakProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Provider to check if a specific date is in the streak

  IsDateInStreakProvider call(DateTime date) =>
      IsDateInStreakProvider._(argument: date, from: this);

  @override
  String toString() => r'isDateInStreakProvider';
}
