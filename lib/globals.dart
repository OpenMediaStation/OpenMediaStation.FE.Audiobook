import 'package:flutter/material.dart';
import 'package:open_media_station_audiobook/handlers/audio_handler.dart';
import 'package:open_media_station_audiobook/services/inventory_service.dart';
import 'package:open_media_station_audiobook/views/audiobook_detail_view.dart';
import 'package:open_media_station_audiobook/views/settings.dart';
import 'package:open_media_station_audiobook/widgets/mini_audio_player.dart';
import 'package:open_media_station_base/views/gallery.dart';

class Globals {
  static String Title = "Open Media Station";
  static String PictureNotFoundUrl =
      "https://static.vecteezy.com/system/resources/previews/005/337/799/original/icon-image-not-found-free-vector.jpg";
  static AudioPlayerHandler audioPlayer = AudioPlayerHandler();
  static Gallery gallery = Gallery(
    gridItemAspectRatio: 0.85,
    getInventoryItems: InventoryService.getInventoryItems,
    appTitle: Globals.Title,
    settings: const Settings(),
    additionalWidgets: const [
      Align(
        alignment: Alignment.bottomCenter,
        child: MiniAudioPlayer(),
      ),
    ],
    getGridItemModel: InventoryService.getAudiobook,
    onGridItemTap: (context, inventoryItem, gridItem) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          if (inventoryItem.category == "Audiobook") {
            return AudiobookDetailView(
              gridItem: gridItem,
            );
          }

          throw ArgumentError("Server models not correct");
        }),
      );
    },
    pictureNotFoundUrl: Globals.PictureNotFoundUrl,
    setFilter: null,
  );
}
