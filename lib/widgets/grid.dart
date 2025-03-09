import 'package:flutter/material.dart';
import 'package:open_media_station_audiobook/models/internal/grid_item_model.dart';
import 'package:open_media_station_audiobook/services/inventory_service.dart';
import 'package:open_media_station_audiobook/views/audiobook_detail_view.dart';
import 'package:open_media_station_audiobook/widgets/grid_item.dart';
import 'package:open_media_station_base/models/inventory/inventory_item.dart';

class Grid extends StatelessWidget {
  const Grid({
    super.key,
    required this.inventoryItems,
    required this.scrollController,
    required this.desiredItemWidth,
    required this.crossAxisCount,
    required this.gridMainAxisSpacing,
    required this.gridCrossAxisSpacing,
    required this.gridItemAspectRatio, 
  });

  final List<InventoryItem> inventoryItems;
  final ScrollController scrollController;

  final double desiredItemWidth;
  final int crossAxisCount;
  final double gridMainAxisSpacing;
  final double gridCrossAxisSpacing;
  final double gridItemAspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      itemCount: inventoryItems.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: gridCrossAxisSpacing,
        mainAxisSpacing: gridMainAxisSpacing,
        childAspectRatio: gridItemAspectRatio,
      ),
      itemBuilder: (context, index) {
        return FutureBuilder<GridItemModel>(
          future: InventoryService.getAudiobook(inventoryItems[index]),
          builder: (context, snapshot) {
            GridItemModel gridItem;

            if (snapshot.connectionState == ConnectionState.waiting) {
              gridItem = GridItemModel(
                inventoryItem: inventoryItems[index],
                metadataModel: null,
                isFavorite: null,
                progress: null,
              );

              gridItem.fake = true;
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('Grid item could not be loaded'));
            } else {
              gridItem = snapshot.data!;
            }

            return InkWell(
              child: GridItem(
                item: gridItem,
                desiredItemWidth: desiredItemWidth,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    if (inventoryItems[index].category == "Audiobook") {
                      return AudiobookDetailView(
                        gridItem: gridItem,
                      );
                    }

                    throw ArgumentError("Server models not correct");
                  }),
                );
              },
            );
          },
        );
      },
    );
  }
}
