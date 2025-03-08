import 'package:flutter/material.dart';
import 'package:open_media_station_audiobook/globals.dart';

class PlayerControlRow extends StatelessWidget {
  const PlayerControlRow({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: Globals.audioPlayer.playbackState
          .map((state) => state.playing)
          .distinct(),
      builder: (context, snapshot) {
        final playing = snapshot.data ?? false;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.replay_10),
              iconSize: 36,
              onPressed: () async {
                await Globals.audioPlayer.rewind();
              },
            ),
            if (playing)
              IconButton(
                icon: const Icon(Icons.pause_circle_filled),
                iconSize: 64,
                onPressed: () async {
                  await Globals.audioPlayer.pause();
                },
              )
            else
              IconButton(
                icon: const Icon(Icons.play_circle_filled),
                iconSize: 64,
                onPressed: () async {
                  await Globals.audioPlayer.play();
                },
              ),
            IconButton(
              icon: const Icon(Icons.forward_10),
              iconSize: 36,
              onPressed: () async {
                await Globals.audioPlayer.fastForward();
              },
            ),
          ],
        );
      },
    );
  }
}
