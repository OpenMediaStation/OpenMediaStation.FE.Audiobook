import 'package:flutter/material.dart';
import 'package:open_media_station_audiobook/models/internal/grid_item_model.dart';
import 'package:open_media_station_audiobook/services/inventory_service.dart';
import 'package:open_media_station_audiobook/views/audiobook_detail_content.dart';
import 'package:open_media_station_base/widgets/favorite_button.dart';

class AudiobookDetailView extends StatelessWidget {
  const AudiobookDetailView({super.key, required this.gridItem});

  final GridItemModel gridItem;

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (!gridItem.fake) {
      body = AudiobookDetailContent(itemModel: gridItem);
    } else {
      body = FutureBuilder<GridItemModel>(
        future: InventoryService.getAudiobook(gridItem.inventoryItem!),
        builder: (context, snapshot) {
          GridItemModel gridItem;

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Grid item could not be loaded'));
          } else {
            gridItem = snapshot.data!;
          }

          return AudiobookDetailContent(itemModel: gridItem);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        actions: [
          FavoriteButton(
            inventoryItem: gridItem.inventoryItem,
            isFavorite: gridItem.isFavorite,
          ),
        ],
      ),
      body: body,
    );
  }
}
