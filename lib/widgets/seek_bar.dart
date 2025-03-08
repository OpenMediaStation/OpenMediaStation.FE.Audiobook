import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:open_media_station_audiobook/globals.dart';
import 'package:open_media_station_audiobook/models/internal/media_state.dart';
import 'package:rxdart/rxdart.dart';

class SeekBar extends StatelessWidget {
  const SeekBar({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MediaState>(
      stream: _mediaStateStream,
      builder: (context, snapshot) {
        final mediaState = snapshot.data;
        final position = mediaState?.position ?? Duration.zero;
        final duration = mediaState?.mediaItem?.duration ?? Duration.zero;

        var positionTextStyle = const TextStyle(
          fontSize: 12,
        );

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(position),
                    style: positionTextStyle,
                  ),
                  Text(
                    "-${_formatDuration(duration - position)}",
                    style: positionTextStyle,
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -10), // Moves the slider up by 10 pixels
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                ),
                child: Slider(
                  value: position.inSeconds.toDouble(),
                  min: 0,
                  max: duration.inSeconds > 0
                      ? duration.inSeconds.toDouble()
                      : 1,
                  onChanged: (value) async {
                    final newPosition = Duration(seconds: value.toInt());
                    await Globals.audioPlayer.seek(newPosition);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// A stream reporting the combined state of the current media item and its
  /// current position.
  Stream<MediaState> get _mediaStateStream =>
      Rx.combineLatest2<MediaItem?, Duration, MediaState>(
          Globals.audioPlayer.mediaItem,
          AudioService.position,
          (mediaItem, position) => MediaState(mediaItem, position));

  /// Formats a [Duration] into `HH:mm:ss` format.
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}
