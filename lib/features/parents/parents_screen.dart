import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../ads/ads.dart';
import '../../app.dart';
import '../../core/art.dart';
import '../../core/theme.dart';
import '../../data/store.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets.dart';

/// Settings and information for grown-ups (reached only through the gate).
class ParentsScreen extends ConsumerWidget {
  const ParentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(settingsProvider);
    final settings = ref.read(settingsProvider.notifier);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;

    Widget toggle(
      Ico icon,
      String label,
      bool value,
      Settings Function(bool) change,
    ) => _Row(
      icon: icon,
      label: label,
      trailing: Switch(
        value: value,
        onChanged: (v) => settings.update((_) => change(v)),
      ),
    );

    return Scaffold(
      backgroundColor: Palette.cream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(Space.m),
              children: [
                Row(
                  children: [
                    IconBubble(
                      Ico.back,
                      label: l.a11yBack,
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: Space.s),
                    Text(l.parentsArea, style: text.headlineMedium),
                  ],
                ),
                const SizedBox(height: Space.m),
                _Card(
                  children: [
                    toggle(
                      s.sound ? Ico.soundOn : Ico.soundOff,
                      l.soundEffects,
                      s.sound,
                      (v) => s.copyWith(sound: v),
                    ),
                    toggle(
                      s.voice ? Ico.voiceOn : Ico.voiceOff,
                      l.voiceGuide,
                      s.voice,
                      (v) => s.copyWith(voice: v),
                    ),
                    toggle(
                      Ico.motion,
                      l.reduceMotion,
                      s.reduceMotion,
                      (v) => s.copyWith(reduceMotion: v),
                    ),
                  ],
                ),
                _Card(
                  children: [
                    _Row(
                      icon: Ico.language,
                      label: l.language,
                      trailing: _Segments(
                        values: const ['ar', 'en'],
                        labels: const ['العربية', 'English'],
                        selected: lang,
                        onSelect: (v) =>
                            settings.update((s) => s.copyWith(languageCode: v)),
                      ),
                    ),
                    _Row(
                      icon: Ico.digits,
                      label: l.numerals,
                      trailing: _Segments(
                        values: const [false, true],
                        labels: const ['123', '١٢٣'],
                        selected: s.easternDigits,
                        onSelect: (v) => settings.update(
                          (s) => s.copyWith(easternDigits: v),
                        ),
                      ),
                    ),
                  ],
                ),
                _Card(
                  children: [
                    _Row(icon: Ico.info, label: l.aboutGame),
                    _Row(
                      icon: Ico.parents,
                      label: Ads.supported ? l.aboutAdsAndroid : l.aboutAdsIos,
                    ),
                    _Row(
                      icon: Ico.next,
                      label: l.privacyPolicy,
                      onTap: () => launchUrl(
                        Uri.parse(privacyUrl(lang)),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                  ],
                ),
                _Card(
                  children: [
                    _Row(
                      icon: Ico.trash,
                      label: l.resetProgress,
                      onTap: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: Text(
                              l.resetConfirm,
                              style: text.bodyLarge,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(l.cancel),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(l.confirm),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) {
                          ref.read(progressProvider.notifier).reset();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: Space.m),
                Text(
                  '${l.madeBy} · ${l.versionLabel(kAppVersion)}',
                  textAlign: TextAlign.center,
                  style: text.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: Space.m),
    padding: const EdgeInsets.symmetric(vertical: Space.xs),
    decoration: const BoxDecoration(
      color: Palette.paper,
      borderRadius: Radii.card,
    ),
    child: Column(children: children),
  );
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  final Ico icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: kTouchTarget),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Space.m,
          vertical: Space.s,
        ),
        child: Row(
          children: [
            GameIcon(icon, size: 36),
            const SizedBox(width: Space.m),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
            ),
            ?trailing,
          ],
        ),
      ),
    ),
  );
}

class _Segments<T> extends StatelessWidget {
  const _Segments({
    required this.values,
    required this.labels,
    required this.selected,
    required this.onSelect,
  });

  final List<T> values;
  final List<String> labels;
  final T selected;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) => SegmentedButton<T>(
    showSelectedIcon: false,
    segments: [
      for (var i = 0; i < values.length; i++)
        ButtonSegment(value: values[i], label: Text(labels[i])),
    ],
    selected: {selected},
    onSelectionChanged: (v) => onSelect(v.first),
  );
}
