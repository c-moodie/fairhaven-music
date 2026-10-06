import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:finamp/live_radio.dart';
import 'package:finamp/components/print_duration.dart';
import 'package:finamp/l10n/app_localizations.dart';
import 'package:finamp/services/progress_state_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../services/music_player_background_task.dart';

typedef DragCallback = void Function(double? value);

class ProgressSlider extends StatefulWidget {
  const ProgressSlider({
    super.key,
    this.allowSeeking = true,
    this.showBuffer = true,
    this.showDuration = true,
    this.showPlaceholder = true,
  });

  final bool allowSeeking;
  final bool showBuffer;
  final bool showDuration;
  final bool showPlaceholder;

  @override
  State<ProgressSlider> createState() => _ProgressSliderState();
}

class _ProgressSliderState extends State<ProgressSlider> {
  /// Value used to hold the slider's value when dragging.
  double? _dragValue;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // The slider always needs to be LTR, so we use Directionality to save
    // putting TextDirection.ltr all over the place
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: ((constraints.maxWidth - 260) / 4).clamp(0, 20) + 16),
          child: Directionality(
            textDirection: TextDirection.ltr,
            // The slider can refresh up to 60 times per second, so we wrap it in a
            // RepaintBoundary to avoid more areas being repainted than necessary
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(trackHeight: 4.0, trackShape: CustomTrackShape()),
              child: StreamBuilder<ProgressState>(
                initialData: progressState,
                stream: progressStateStream,
                builder: (context, snapshot) {
                  if (snapshot.data?.mediaItem == null) {
                    // If nothing is playing or the AudioService isn't connected, return a
                    // greyed out slider with some fake numbers. We also do this if
                    // currentPosition is null, which sometimes happens when the app is
                    // closed and reopened.
                    return widget.showPlaceholder
                        ? Column(
                            children: [
                              SizedBox(
                                height: 24.0,
                                child: Stack(
                                  children: [
                                    Slider(
                                      value: 0,
                                      max: 1,
                                      onChanged: null,
                                      autofocus: false,
                                      focusNode: FocusNode(skipTraversal: true, canRequestFocus: false),
                                    ),
                                  ],
                                ),
                              ),
                              if (widget.showDuration) const _ProgressSliderDuration(position: Duration()),
                            ],
                          )
                        : const SizedBox.shrink();
                  } else if (isLiveRadioMediaItem(snapshot.data!.mediaItem)) {
                    // Fairhaven Music live radio: nothing to seek, show a "Live" bar instead.
                    return widget.showDuration ? const _LiveRadioProgressBar() : const SizedBox.shrink();
                  } else if (snapshot.hasData) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 24.0,
                          child: Stack(
                            children: [
                              // Slider displaying playback progress.
                              _PlaybackProgressSlider(
                                allowSeeking: widget.allowSeeking,
                                playbackState: snapshot.data!.playbackState,
                                position: snapshot.data!.position,
                                mediaItem: snapshot.data!.mediaItem,
                                onDrag: (value) => setState(() {
                                  _dragValue = value;
                                }),
                              ),
                            ],
                          ),
                        ),
                        if (widget.showDuration)
                          _ProgressSliderDuration(
                            position: _dragValue == null
                                ? snapshot.data!.position
                                : Duration(microseconds: _dragValue!.toInt()),
                            itemDuration: snapshot.data!.mediaItem?.duration,
                          ),
                      ],
                    );
                  } else {
                    return const Text(
                      "Snapshot doesn't have data and MediaItem isn't null and AudioService is connected?",
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProgressSliderDuration extends StatelessWidget {
  const _ProgressSliderDuration({required this.position, this.itemDuration});

  final Duration position;
  final Duration? itemDuration;

  @override
  Widget build(BuildContext context) {
    final showRemaining = Platform.isIOS || Platform.isMacOS;
    final currentPosition = Duration(seconds: (position.inMilliseconds / 1000).round());
    final roundedDuration = Duration(seconds: ((itemDuration?.inMilliseconds ?? 0) / 1000).round());
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          printDuration(currentPosition),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            height: 0.5, // reduce line height
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.75),
            fontFeatures: const [
              // fixed-width digits
              FontFeature.tabularFigures(),
            ],
          ),
        ),
        Text(
          printDuration(
            // display remaining time if on iOS or macOS
            showRemaining ? (roundedDuration - currentPosition) : roundedDuration,
            isRemaining: showRemaining,
          ),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            height: 0.5, // reduce line height
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.75),
            fontFeatures: const [
              // fixed-width digits
              FontFeature.tabularFigures(),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlaybackProgressSlider extends ConsumerStatefulWidget {
  const _PlaybackProgressSlider({
    required this.allowSeeking,
    this.mediaItem,
    required this.playbackState,
    required this.position,
    required this.onDrag,
  });

  final bool allowSeeking;
  final MediaItem? mediaItem;
  final PlaybackState playbackState;
  final Duration position;
  final DragCallback onDrag; // should probably be nullable but its never null

  @override
  ConsumerState<_PlaybackProgressSlider> createState() => __PlaybackProgressSliderState();
}

class __PlaybackProgressSliderState extends ConsumerState<_PlaybackProgressSlider> {
  /// Value used to hold the slider's value when dragging.
  double? _dragValue;

  final _audioHandler = GetIt.instance<MusicPlayerBackgroundTask>();

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: widget.allowSeeking
          // ? _sliderThemeData.copyWith(
          ? SliderTheme.of(context).copyWith(
              inactiveTrackColor: IconTheme.of(context).color!.withOpacity(0.18),
              secondaryActiveTrackColor: IconTheme.of(context).color!.withOpacity(0.38),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.5, elevation: 2.0),
            )
          // )
          // : _sliderThemeData.copyWith(
          : SliderTheme.of(context).copyWith(
              inactiveTrackColor: IconTheme.of(context).color!.withOpacity(0.18),
              secondaryActiveTrackColor: IconTheme.of(context).color!.withOpacity(0.38),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0.1),
              // gets rid of both horizontal and vertical padding
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 0.1),
              trackShape: const RectangularSliderTrackShape(),
              // rectangular shape is thinner than round
              trackHeight: 4.0,
            ),
      // ),
      child: Slider(
        min: 0.0,
        max: widget.mediaItem?.duration == null
            ? widget.playbackState.bufferedPosition.inMicroseconds.toDouble()
            : widget.mediaItem?.duration?.inMicroseconds.toDouble() ?? 0,
        value: (_dragValue ?? widget.position.inMicroseconds)
            .clamp(0, widget.mediaItem?.duration?.inMicroseconds.toDouble() ?? 0)
            .toDouble(),
        semanticFormatterCallback: (double value) {
          final positionFullMinutes = Duration(microseconds: value.toInt()).inMinutes % 60;
          final positionFullHours = Duration(microseconds: value.toInt()).inHours;
          final positionSeconds = Duration(microseconds: value.toInt()).inSeconds % 60;
          final durationFullHours = (widget.mediaItem?.duration?.inHours ?? 0);
          final durationFullMinutes = (widget.mediaItem?.duration?.inMinutes ?? 0) % 60;
          final durationSeconds = (widget.mediaItem?.duration?.inSeconds ?? 0) % 60;
          final positionString =
              "${positionFullHours > 0 ? "$positionFullHours ${AppLocalizations.of(context)!.hours} " : ""}${positionFullMinutes > 0 ? "$positionFullMinutes ${AppLocalizations.of(context)!.minutes} " : ""}$positionSeconds ${AppLocalizations.of(context)!.seconds}";
          final durationString =
              "${durationFullHours > 0 ? "$durationFullHours ${AppLocalizations.of(context)!.hours} " : ""}${durationFullMinutes > 0 ? "$durationFullMinutes ${AppLocalizations.of(context)!.minutes} " : ""}$durationSeconds ${AppLocalizations.of(context)!.seconds}";
          return AppLocalizations.of(context)!.timeFractionTooltip(positionString, durationString);
        },
        secondaryTrackValue: widget.mediaItem?.extras?["downloadedTrackPath"] == null
            ? widget.playbackState.bufferedPosition.inMicroseconds
                  .clamp(
                    0.0,
                    widget.mediaItem?.duration == null
                        ? widget.playbackState.bufferedPosition.inMicroseconds
                        : widget.mediaItem?.duration?.inMicroseconds ?? 0,
                  )
                  .toDouble()
            : 0,
        onChanged: widget.allowSeeking
            ? (newValue) async {
                // We don't actually tell audio_service to seek here
                // because it would get flooded with seek requests
                setState(() {
                  _dragValue = newValue;
                });
                widget.onDrag(newValue);
              }
            : (_) {},
        onChangeStart: widget.allowSeeking
            ? (value) {
                setState(() {
                  _dragValue = value;
                });
                widget.onDrag(value);
              }
            : (_) {},
        onChangeEnd: widget.allowSeeking
            ? (newValue) async {
                // Seek to the new position
                await _audioHandler.seek(Duration(microseconds: newValue.toInt()));

                // Clear drag value so that the slider uses the play
                // duration again.
                if (mounted) {
                  setState(() {
                    _dragValue = null;
                  });
                }
                widget.onDrag(null);
              }
            : (_) {},
        autofocus: false,
        focusNode: FocusNode(skipTraversal: true, canRequestFocus: false),
      ),
    );
  }
}

class HiddenThumbComponentShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double>? activationAnimation,
    Animation<double>? enableAnimation,
    bool? isDiscrete,
    TextPainter? labelPainter,
    RenderBox? parentBox,
    SliderThemeData? sliderTheme,
    TextDirection? textDirection,
    double? value,
    double? textScaleFactor,
    Size? sizeWithOverflow,
  }) {}
}

/// Track shape used to remove horizontal padding.
/// https://github.com/flutter/flutter/issues/37057
class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

/// https://stackoverflow.com/a/68481487/8532605
class BufferTrackShape extends CustomTrackShape {
  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    super.paint(
      context,
      offset,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      enableAnimation: enableAnimation,
      textDirection: textDirection,
      thumbCenter: thumbCenter,
      secondaryOffset: secondaryOffset,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
      additionalActiveTrackHeight: 0,
    );
  }
}

class _LiveRadioProgressBar extends StatelessWidget {
  const _LiveRadioProgressBar();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 24.0,
          child: Center(
            child: Container(
              height: 4.0,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2.0)),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              liveRadioLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
