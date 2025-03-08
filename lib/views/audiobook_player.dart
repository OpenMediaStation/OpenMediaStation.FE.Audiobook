import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_media_station_audiobook/globals.dart';
import 'package:open_media_station_audiobook/models/internal/grid_item_model.dart';
import 'package:open_media_station_audiobook/models/internal/media_state.dart';
import 'package:open_media_station_base/helpers/preferences.dart';
import 'package:rxdart/rxdart.dart';

class AudiobookPlayer extends StatefulWidget {
  const AudiobookPlayer({
    Key? key,
    required this.itemModel,
    required this.versionID,
  }) : super(key: key);

  final GridItemModel itemModel;
  final String? versionID;

  @override
  State<AudiobookPlayer> createState() => _AudiobookPlayerState();
}

class _AudiobookPlayerState extends State<AudiobookPlayer> {
  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    String url =
        "${Preferences.prefs?.getString("BaseUrl")}/stream/${widget.itemModel.inventoryItem?.category}/${widget.itemModel.inventoryItem?.id}${widget.versionID != null ? "?versionId=${widget.versionID}" : ""}";

    await Globals.audioPlayer.initializePlayer(widget.itemModel, url);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Audiobook Player"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Show media item title
            StreamBuilder<MediaItem?>(
              stream: Globals.audioPlayer.mediaItem,
              builder: (context, snapshot) {
                final mediaItem = snapshot.data;
                return Text(mediaItem?.title ?? '');
              },
            ),
            // Play/pause/stop buttons.
            StreamBuilder<bool>(
              stream: Globals.audioPlayer.playbackState
                  .map((state) => state.playing)
                  .distinct(),
              builder: (context, snapshot) {
                final playing = snapshot.data ?? false;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _button(Icons.fast_rewind, Globals.audioPlayer.rewind),
                    if (playing)
                      _button(Icons.pause, Globals.audioPlayer.pause)
                    else
                      _button(Icons.play_arrow, Globals.audioPlayer.play),
                    _button(Icons.stop, Globals.audioPlayer.stop),
                    _button(
                        Icons.fast_forward, Globals.audioPlayer.fastForward),
                  ],
                );
              },
            ),
            // A seek bar.
            StreamBuilder<MediaState>(
              stream: _mediaStateStream,
              builder: (context, snapshot) {
                final mediaState = snapshot.data;
                return Slider(
                  value: (mediaState?.position ?? Duration.zero).inSeconds.toDouble(),
                  min: 0,
                  max: (mediaState?.mediaItem?.duration ?? Duration.zero).inSeconds.toDouble() > 0
                      ? (mediaState?.mediaItem?.duration ?? Duration.zero).inSeconds.toDouble()
                      : 1,
                  onChanged: (value) async {
                    final newPosition = Duration(seconds: value.toInt());
                    await Globals.audioPlayer.seek(newPosition);
                  },
                );
              },
            ),
            // Display the processing state.
            StreamBuilder<AudioProcessingState>(
              stream: Globals.audioPlayer.playbackState
                  .map((state) => state.processingState)
                  .distinct(),
              builder: (context, snapshot) {
                final processingState =
                    snapshot.data ?? AudioProcessingState.idle;
                return Text(
                    "Processing state: ${describeEnum(processingState)}");
              },
            ),
          ],
        ),
      ),
    );
  }

  /// A stream reporting the combined state of the current media item and its
  /// current position.
  Stream<MediaState> get _mediaStateStream =>
      Rx.combineLatest2<MediaItem?, Duration, MediaState>(
          Globals.audioPlayer.mediaItem,
          AudioService.position,
          (mediaItem, position) => MediaState(mediaItem, position));

  IconButton _button(IconData iconData, VoidCallback onPressed) => IconButton(
        icon: Icon(iconData),
        iconSize: 64.0,
        onPressed: onPressed,
      );
}
