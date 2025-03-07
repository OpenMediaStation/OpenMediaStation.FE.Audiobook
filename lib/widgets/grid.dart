import 'package:flutter/material.dart';
import 'package:open_media_station_audiobook/models/internal/grid_item_model.dart';
import 'package:open_media_station_audiobook/services/inventory_service.dart';
import 'package:open_media_station_audiobook/widgets/grid_item.dart';
import 'package:open_media_station_base/models/inventory/inventory_item.dart';

class Grid extends StatelessWidget {
  const Grid({super.key, required this.inventoryItems});

  final List<InventoryItem> inventoryItems;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double desiredItemWidth = 150;
    int crossAxisCount = (screenWidth / desiredItemWidth).floor();
    double gridMainAxisSpacing = 8.0;
    double gridCrossAxisSpacing = 8.0;
    double gridItemAspectRatio = 0.6;

    return GridView.builder(
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
              ),
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) {
                //     if (filteredItems[index].category == "Movie") {
                //       return MovieDetailView(
                //         itemModel: gridItem,
                //       );
                //     }
                //     if (filteredItems[index].category == "Show") {
                //       return ShowDetailView(
                //         itemModel: gridItem,
                //       );
                //     }

                //     throw ArgumentError("Server models not correct");
                //   }),
                // );
              },
            );
          },
        );
      },
    );
  }
}
