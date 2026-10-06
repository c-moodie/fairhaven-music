import 'package:finamp/components/finamp_section_header.dart';
import 'package:finamp/components/global_snackbar.dart';
import 'package:finamp/extensions/localizations.dart';
import 'package:finamp/fairhaven_theme.dart';
import 'package:finamp/live_radio.dart';
import 'package:finamp/services/current_track_metadata_provider.dart';
import 'package:finamp/services/music_player_background_task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

/// Fairhaven Music: the "Radio" row on the home screen, one card per station
/// in [liveRadioStations].
class LiveRadioSection extends ConsumerWidget {
  const LiveRadioSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (liveRadioStations.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final viewPadding = MediaQuery.paddingOf(context);
    final currentItem = ref.watch(currentTrackProvider).value?.baseItem;

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 20.0),
      sliver: FinampSectionHeader(
        key: const Key("fairhaven-live-radio-section"),
        sticky: false,
        title: context.l10n.liveRadioSectionTitle,
        headerPadding: EdgeInsets.only(left: viewPadding.left + 14.0, right: viewPadding.right + 20.0),
        sectionContentSliver: SliverToBoxAdapter(
          child: SizedBox(
            height: 116,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: viewPadding.left + 14.0, right: viewPadding.right + 14.0),
              itemCount: liveRadioStations.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final station = liveRadioStations[index];
                return _LiveRadioCard(station: station, isCurrent: currentItem?.id == station.itemId);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveRadioCard extends StatelessWidget {
  const _LiveRadioCard({required this.station, required this.isCurrent});

  final LiveRadioStation station;
  final bool isCurrent;

  Future<void> _onTap() async {
    final audioHandler = GetIt.instance<MusicPlayerBackgroundTask>();
    try {
      if (isCurrent) {
        // Tapping the station that's already loaded pauses / resumes it.
        if (audioHandler.playbackState.value.playing) {
          await audioHandler.pause();
        } else {
          await audioHandler.play();
        }
      } else {
        await playLiveRadioStation(station);
      }
    } catch (error) {
      GlobalSnackbar.error(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final background = isCurrent ? scheme.primaryContainer : fairhavenTonalFill(context);
    final foreground = isCurrent ? scheme.onPrimaryContainer : fairhavenOnTonal(context);

    return Semantics(
      button: true,
      label: "${station.name}, $liveRadioLabel",
      excludeSemantics: true,
      child: SizedBox(
        width: 156,
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(FairhavenRadius.md),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _onTap,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.radio, size: 22, color: isCurrent ? scheme.onPrimaryContainer : scheme.primary),
                      const Spacer(),
                      if (isCurrent) Icon(Icons.graphic_eq, size: 18, color: foreground),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    station.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: fairhavenDisplayStyle(fontSize: 15, color: foreground, height: 1.15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    liveRadioLabel,
                    style: TextStyle(fontSize: 12, color: foreground.withOpacity(0.75)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
