import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/store.dart';

/// True when the system or the parents' setting asks for less motion.
bool reducedMotion(BuildContext context, WidgetRef ref) =>
    MediaQuery.disableAnimationsOf(context) ||
    ref.watch(settingsProvider).reduceMotion;

/// An animation duration that collapses to zero under reduced motion.
Duration motion(BuildContext context, WidgetRef ref, int milliseconds) =>
    reducedMotion(context, ref)
    ? Duration.zero
    : Duration(milliseconds: milliseconds);

/// Formats a number with Western (123) or Eastern Arabic (١٢٣) digits.
String digits(int n, {required bool eastern}) {
  if (!eastern) return '$n';
  const map = '٠١٢٣٤٥٦٧٨٩';
  return '$n'.split('').map((c) => c == '-' ? c : map[int.parse(c)]).join();
}
