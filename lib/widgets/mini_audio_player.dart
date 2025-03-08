import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:open_media_station_audiobook/globals.dart';
import 'package:open_media_station_audiobook/models/internal/grid_item_model.dart';
import 'package:open_media_station_audiobook/views/audiobook_player.dart';
import 'package:open_media_station_base/widgets/custom_image.dart';

class MiniAudioPlayer extends StatelessWidget {
  const MiniAudioPlayer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      child: StreamBuilder<MediaItem?>(
        stream: Globals.audioPlayer.mediaItem,
        builder: (context, snapshot) {
          final mediaItem = snapshot.data;
          if (mediaItem == null) return const SizedBox.shrink();

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AudiobookPlayer(
                    itemModel: Globals.audioPlayer.currentGridItemModel!,
                    versionID: Globals.audioPlayer.currentGridItemModel?.inventoryItem?.versions?.first.id,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 58, 58, 58),
              ),
              child: Row(
                children: [
                  // Thumbnail

                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CustomImage(
                      imageUrl: mediaItem.artUri.toString(),
                      pictureNotFoundUrl: Globals.PictureNotFoundUrl,
                      height: 49,
                      width: 49,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title and artist
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mediaItem.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          mediaItem.artist ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Play/Pause Button
                  StreamBuilder<bool>(
                    stream: Globals.audioPlayer.playbackState
                        .map((state) => state.playing)
                        .distinct(),
                    builder: (context, snapshot) {
                      final playing = snapshot.data ?? false;
                      return Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.replay_10),
                            iconSize: 24,
                            onPressed: () async {
                              await Globals.audioPlayer.rewind();
                            },
                          ),
                          if (playing)
                            IconButton(
                              icon: const Icon(Icons.pause_circle_filled),
                              iconSize: 45,
                              onPressed: () async {
                                await Globals.audioPlayer.pause();
                              },
                            )
                          else
                            IconButton(
                              icon: const Icon(Icons.play_circle_filled),
                              iconSize: 45,
                              onPressed: () async {
                                await Globals.audioPlayer.play();
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.forward_10),
                            iconSize: 24,
                            onPressed: () async {
                              await Globals.audioPlayer.fastForward();
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
