import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:finamp/color_schemes.g.dart';
import 'package:finamp/components/AddToPlaylistScreen/add_to_playlist_button.dart';
import 'package:finamp/components/audio_fade_progress_visualizer_container.dart';
import 'package:finamp/components/global_snackbar.dart';
import 'package:finamp/components/one_line_marquee_helper.dart';
import 'package:finamp/components/print_duration.dart';
import 'package:finamp/extensions/color_extensions.dart';
import 'package:finamp/l10n/app_localizations.dart';
import 'package:finamp/models/finamp_models.dart';
import 'package:finamp/services/current_track_metadata_provider.dart';
import 'package:finamp/services/feedback_helper.dart';
import 'package:finamp/services/queue_service.dart';
import 'package:finamp/services/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get_it/get_it.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';

import '../models/jellyfin_models.dart' as jellyfin_models;
import '../screens/player_screen.dart';
import '../services/current_album_image_provider.dart';
import '../services/finamp_settings_helper.dart';
import '../services/media_state_stream.dart';
import '../services/music_player_background_task.dart';
import '../services/process_artist.dart';
import 'PlayerScreen/player_split_screen_scaffold.dart';
import 'album_image.dart';

class NowPlayingBar extends ConsumerWidget {
  const NowPlayingBar({super.key});

  static const horizontalPadding = 8.0;
  static const albumImageSize = 64.0;
  static const _artSize = 48.0;
  static const _barRadius = 20.0;
  static const _playButtonSize = 44.0;
  static const _progressHeight = 3.0;

  BoxDecoration? getShadow(BuildContext context) => BoxDecoration(
    borderRadius: const BorderRadius.all(Radius.circular(_barRadius)),
    boxShadow: [
      BoxShadow(
        blurRadius: 18.0,
        spreadRadius: -2.0,
        offset: const Offset(0, 6),
        color: Theme.brightnessOf(context) == Brightness.light
            ? darkColorScheme.surface.withOpacity(0.18)
            : Colors.black.withOpacity(0.55),
      ),
    ],
  );

  /// Background of the floating bar: the surface, lightly tinted with the
  /// current track's accent so the bar picks up the album's color.
  Color getBarColor(BuildContext context) {
    final scheme = ColorScheme.of(context);
    return Theme.brightnessOf(context) == Brightness.dark
        ? Color.alphaBlend(scheme.primary.withOpacity(0.16), scheme.surface)
        : Color.alphaBlend(scheme.primary.withOpacity(0.07), Colors.white);
  }

  Color getProgressForegroundColor(WidgetRef ref) {
    return ColorScheme.of(ref.context).primary;
  }

  Color getProgressBackgroundColor(WidgetRef ref) {
    return getProgressForegroundColor(ref).withOpacity(0.18);
  }

  Widget _buildBarShell(BuildContext context, {required Widget child}) {
    return Material(
      borderRadius: BorderRadius.circular(_barRadius),
      clipBehavior: Clip.antiAlias,
      color: getBarColor(context),
      elevation: 0,
      child: SizedBox(width: MediaQuery.widthOf(context), height: albumImageSize, child: child),
    );
  }

  Widget buildLoadingQueueBar(WidgetRef ref, void Function()? retryCallback) {
    var context = ref.context;

    return SimpleGestureDetector(
      onVerticalSwipe: (direction) {
        if (direction == SwipeDirection.up && retryCallback != null) {
          retryCallback();
        }
      },
      onTap: retryCallback,
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0, bottom: 12.0, right: 12.0),
        child: Container(
          decoration: getShadow(ref.context),
          child: _buildBarShell(
            context,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: _artSize,
                    height: _artSize,
                    decoration: BoxDecoration(
                      color: ColorScheme.of(context).primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: (retryCallback != null)
                        ? Icon(TablerIcons.refresh, size: 26, color: ColorScheme.of(context).primary)
                        : const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator.adaptive(strokeWidth: 2.5),
                          ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4, right: 16),
                    child: Text(
                      (retryCallback != null)
                          ? AppLocalizations.of(context)!.queueRetryMessage
                          : AppLocalizations.of(context)!.queueLoadingMessage,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextTheme.of(context).bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> openPlayerScreen() async {
    minimizeSplitScreen.value = false;
    await GlobalSnackbar.navigatorState?.push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) => const PlayerScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          if (MediaQuery.disableAnimationsOf(context)) {
            return child;
          }
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeInOutQuad));
          var offsetAnimation = animation.drive(tween);

          if (animation.status == AnimationStatus.reverse) {
            // dismiss animation
            return FadeTransition(opacity: animation, child: child);
          } else {
            return SlideTransition(position: offsetAnimation, child: child);
          }
        },
        settings: const RouteSettings(name: PlayerScreen.routeName),
      ),
    );
  }

  Widget buildNowPlayingBar(WidgetRef ref, FinampQueueItem currentTrack) {
    final audioHandler = GetIt.instance<MusicPlayerBackgroundTask>();
    final queueService = GetIt.instance<QueueService>();

    Duration? playbackPosition;

    final currentTrackBaseItem = currentTrack.item.extras?["itemJson"] != null
        ? jellyfin_models.BaseItemDto.fromJson(currentTrack.item.extras!["itemJson"] as Map<String, dynamic>)
        : null;
    var context = ref.context;

    final scheme = ColorScheme.of(context);
    final elapsedColor = getProgressForegroundColor(ref);
    final remainingColor = getProgressBackgroundColor(ref);
    final Color primaryTextColor = AtContrast.getContrastiveTintedTextColor(onBackground: getBarColor(context));
    final Color secondaryTextColor = primaryTextColor.withOpacity(0.68);

    final showPauseButton = ref.watch(
      mediaStateProvider.select((x) => x.playbackState.playing && x.fadeDirection != FadeDirection.fadeOut),
    );

    final timeStyle = TextStyle(
      fontSize: 12.5,
      fontWeight: FontWeight.w500,
      color: secondaryTextColor,
      fontFeatures: const [
        // fixed-width digits
        FontFeature.tabularFigures(),
      ],
    );

    Widget buildTime() {
      return StreamBuilder<Duration>(
        stream: AudioService.position,
        initialData: audioHandler.playbackState.value.position,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }
          playbackPosition = snapshot.data;
          final showRemaining = Platform.isIOS || Platform.isMacOS;
          final positionFullMinutes = (playbackPosition?.inMinutes ?? 0) % 60;
          final positionFullHours = (playbackPosition?.inHours ?? 0);
          final positionSeconds = (playbackPosition?.inSeconds ?? 0) % 60;
          final durationFullHours = (currentTrack.item.duration?.inHours ?? 0);
          final durationFullMinutes = (currentTrack.item.duration?.inMinutes ?? 0) % 60;
          final durationSeconds = (currentTrack.item.duration?.inSeconds ?? 0) % 60;
          final durationText = (currentTrack.item.duration?.inHours ?? 0.0) >= 1.0
              ? "${currentTrack.item.duration?.inHours.toString()}:${((currentTrack.item.duration?.inMinutes ?? 0) % 60).toString().padLeft(2, '0')}:${((currentTrack.item.duration?.inSeconds ?? 0) % 60).toString().padLeft(2, '0')}"
              : "${currentTrack.item.duration?.inMinutes.toString()}:${((currentTrack.item.duration?.inSeconds ?? 0) % 60).toString().padLeft(2, '0')}";
          final positionText = printDuration(
            showRemaining
                ? ((currentTrack.item.duration ?? Duration.zero) - (playbackPosition ?? Duration.zero))
                : playbackPosition,
            leadingZeroes: false,
            isRemaining: showRemaining,
          );
          return Semantics.fromProperties(
            properties: SemanticsProperties(
              label:
                  "${positionFullHours > 0 ? "$positionFullHours hours " : ""}${positionFullMinutes > 0 ? "$positionFullMinutes minutes " : ""}$positionSeconds seconds of ${durationFullHours > 0 ? "$durationFullHours hours " : ""}${durationFullMinutes > 0 ? "$durationFullMinutes minutes " : ""}$durationSeconds seconds",
            ),
            excludeSemantics: true,
            container: true,
            child: Text(showRemaining ? positionText : "$positionText / $durationText", style: timeStyle),
          );
        },
      );
    }

    Widget buildProgressLine() {
      return StreamBuilder<Duration>(
        stream: AudioService.position,
        initialData: audioHandler.playbackState.value.position,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }
          playbackPosition = snapshot.data;
          var itemLength = currentTrack.item.duration;
          final factor = itemLength == null || itemLength.inMilliseconds == 0
              ? 0.0
              : (playbackPosition!.inMilliseconds / itemLength.inMilliseconds).clamp(0.0, 1.0).toDouble();
          return SizedBox(
            height: _progressHeight,
            child: Stack(
              children: [
                Positioned.fill(child: ColoredBox(color: remainingColor)),
                FractionallySizedBox(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: factor,
                  heightFactor: 1.0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: elapsedColor,
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(_progressHeight)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    final playPauseButton = AudioFadeProgressVisualizerContainer(
      key: const Key("AlbumArtAudioFadeProgressVisualizer"),
      width: _playButtonSize,
      height: _playButtonSize,
      color: scheme.primary.withOpacity(0.5),
      borderRadius: BorderRadius.circular(_playButtonSize / 2),
      child: Material(
        color: scheme.primary,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            FeedbackHelper.feedback(FeedbackType.light);
            unawaited(audioHandler.togglePlayback());
          },
          child: Tooltip(
            message: AppLocalizations.of(context)!.togglePlaybackButtonTooltip,
            child: Center(
              child: Icon(
                showPauseButton ? TablerIcons.player_pause_filled : TablerIcons.player_play_filled,
                size: 22,
                color: scheme.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(left: 12.0, bottom: 12.0, right: 12.0),
      child: Semantics.fromProperties(
        properties: SemanticsProperties(label: AppLocalizations.of(context)!.nowPlayingBarTooltip, button: true),
        child: SimpleGestureDetector(
          onTap: () async => await openPlayerScreen(),
          child: Dismissible(
            key: const Key("NowPlayingBarDismiss"),
            direction: ref.watch(finampSettingsProvider.disableGesture)
                ? DismissDirection.none
                : DismissDirection.vertical,
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.down) {
                FeedbackHelper.feedback(FeedbackType.success);
                await queueService.stopAndClearQueue();
              } else {
                await openPlayerScreen();
              }
              return false;
            },
            dismissThresholds: const {DismissDirection.up: 0.15, DismissDirection.down: 0.7},
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: getShadow(context),
              //TODO use a PageView instead of a Dismissible, and only wrap dynamic items (not the buttons)
              child: Dismissible(
                key: const Key("NowPlayingBar"),
                direction: ref.watch(finampSettingsProvider.disableGesture)
                    ? DismissDirection.none
                    : DismissDirection.horizontal,
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    FeedbackHelper.feedback(FeedbackType.light);
                    await audioHandler.skipToNext();
                  } else {
                    FeedbackHelper.feedback(FeedbackType.light);
                    await audioHandler.skipToPrevious(forceSkip: true);
                  }
                  return false;
                },
                child: _buildBarShell(
                  context,
                  child: Stack(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Album art, inset with rounded corners
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: _artSize,
                              height: _artSize,
                              child: AlbumImage(
                                placeholderBuilder: (_) => const SizedBox.shrink(),
                                imageListenable: currentAlbumImageProvider,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                          // Title, artist and time
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4, right: 4),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  OneLineMarqueeHelper(
                                    key: ValueKey(currentTrack.item.id),
                                    text: currentTrack.item.title,
                                    style: TextStyle(
                                      fontSize: 15,
                                      height: 1.25,
                                      color: primaryTextColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          processArtist(currentTrack.item.artist, context),
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: secondaryTextColor,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      buildTime(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AddToPlaylistButton(
                            item: currentTrackBaseItem,
                            queueItem: currentTrack,
                            color: primaryTextColor,
                            size: 26,
                            visualDensity: const VisualDensity(horizontal: -4),
                          ),
                          Padding(padding: const EdgeInsets.only(left: 2.0, right: 10.0), child: playPauseButton),
                        ],
                      ),
                      if (ref.watch(finampSettingsProvider.showProgressOnNowPlayingBar))
                        Positioned(left: 0, right: 0, bottom: 0, child: buildProgressLine()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueService = GetIt.instance<QueueService>();

    return Hero(
      tag: "nowplaying",
      createRectTween: (from, to) => RectTween(begin: from, end: from),
      child: PlayerScreenTheme(
        // The now playing bar must be enclosed in a SafeArea at all times so that the enclosing scaffold properly adds
        // bottom padding, even if the now playing bar itself is empty.
        child: SafeArea(
          // use consumer to obtain ref of correct (player screen theme) ProviderContainer
          child: Consumer(
            builder: (context, ref, child) {
              ref.listen(currentTrackMetadataProvider, (metadataOrNull, metadata) {}); // keep provider alive
              return StreamBuilder<FinampQueueInfo?>(
                stream: queueService.getQueueStream(),
                initialData: queueService.getQueue(),
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data!.saveState == SavedQueueState.loading &&
                      !usingPlayerSplitScreen) {
                    return buildLoadingQueueBar(ref, null);
                  } else if (snapshot.hasData &&
                      snapshot.data!.saveState == SavedQueueState.failed &&
                      !usingPlayerSplitScreen) {
                    return buildLoadingQueueBar(ref, queueService.retryQueueLoad);
                  } else if (snapshot.hasData && snapshot.data!.currentTrack != null && !usingPlayerSplitScreen) {
                    return buildNowPlayingBar(ref, snapshot.data!.currentTrack!);
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
