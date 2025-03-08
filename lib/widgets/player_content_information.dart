import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:open_media_station_audiobook/globals.dart';
import 'package:open_media_station_base/widgets/custom_image.dart';

class PlayerContentInformation extends StatelessWidget {
  const PlayerContentInformation({super.key});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    double imageSize = width;

    if (height < width || width > height / 2) {
      imageSize = height / 2;
    }

    return StreamBuilder<MediaItem?>(
      stream: Globals.audioPlayer.mediaItem,
      builder: (context, snapshot) {
        final mediaItem = snapshot.data;
        return Column(
          children: [
            SizedBox(
              height: imageSize,
              width: imageSize,
              child: CustomImage(
                imageUrl: mediaItem?.artUri.toString(),
                pictureNotFoundUrl: Globals.PictureNotFoundUrl,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              mediaItem?.title ?? "Title unknown",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              mediaItem?.artist ?? '',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }
}
