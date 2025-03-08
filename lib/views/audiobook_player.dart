import 'dart:async';
import 'package:flutter/material.dart';
import 'package:open_media_station_audiobook/globals.dart';
import 'package:open_media_station_audiobook/models/internal/grid_item_model.dart';
import 'package:open_media_station_base/helpers/preferences.dart';

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
  late StreamSubscription<Duration> _positionSubscription;

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    String url =
        "${Preferences.prefs?.getString("BaseUrl")}/stream/${widget.itemModel.inventoryItem?.category}/${widget.itemModel.inventoryItem?.id}${widget.versionID != null ? "?versionId=${widget.versionID}" : ""}";

    await Globals.audioPlayer.initializePlayer(widget.itemModel, url);

    _positionSubscription =
        Globals.audioPlayer.player.stream.position.listen((duration) async {
      // Set position for progress bar
      Duration totalDuration = _totalDuration;
      if (_totalDuration == const Duration(seconds: 0)) {
        totalDuration = await _getTotalDuration();
      }

      setState(() {
        _totalDuration = totalDuration;
        _currentPosition = duration;
      });
    });
  }

  // Call after opening media to update the total duration.
  Future<Duration> _getTotalDuration() async {
    var duration = Globals.audioPlayer.player.state.duration;

    while (duration == const Duration(seconds: 0)) {
      await Future.delayed(const Duration(milliseconds: 100));

      duration = Globals.audioPlayer.player.state.duration;
    }

    return duration;
  }

  // Formats a Duration into a string (e.g., 00:02:15 or 02:15).
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = d.inHours;
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return hours > 0
        ? '${twoDigits(hours)}:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Audiobook Player"),
      ),
      body: Column(
        children: [
          // Cover image
          Expanded(
            child: Center(
              child: Image.network(
                widget.itemModel.image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Seekbar slider
          Slider(
            value: _currentPosition.inSeconds.toDouble(),
            min: 0,
            max: _totalDuration.inSeconds.toDouble() > 0
                ? _totalDuration.inSeconds.toDouble()
                : 1,
            onChanged: (value) async {
              final newPosition = Duration(seconds: value.toInt());
              await Globals.audioPlayer.seek(newPosition);
              setState(() {
                _currentPosition = newPosition;
              });
            },
          ),
          // Current position / Total duration labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(_currentPosition)),
                Text(_formatDuration(_totalDuration)),
              ],
            ),
          ),
          // Playback controls: rewind, play/pause, fast-forward.
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.replay_10),
                  iconSize: 36,
                  onPressed: () async {
                    final newPosition =
                        _currentPosition - const Duration(seconds: 10);
                    await Globals.audioPlayer.seek(newPosition < Duration.zero
                        ? Duration.zero
                        : newPosition);
                  },
                ),
                IconButton(
                  icon: Icon(
                    _isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                  ),
                  iconSize: 64,
                  onPressed: () async {
                    if (_isPlaying) {
                      await Globals.audioPlayer.pause();
                    } else {
                      await Globals.audioPlayer.play();
                    }
                    setState(() {
                      _isPlaying = !_isPlaying;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.forward_10),
                  iconSize: 36,
                  onPressed: () async {
                    var newPosition =
                        _currentPosition + const Duration(seconds: 10);
                    if (newPosition > _totalDuration) {
                      newPosition = _totalDuration;
                    }
                    await Globals.audioPlayer.seek(newPosition);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
