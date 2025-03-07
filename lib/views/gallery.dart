import 'package:flutter/material.dart';
import 'package:open_media_station_audiobook/globals.dart';
import 'package:open_media_station_audiobook/services/inventory_service.dart';
import 'package:open_media_station_audiobook/views/settings.dart';
import 'package:open_media_station_audiobook/widgets/grid.dart';
import 'package:open_media_station_base/models/inventory/inventory_item.dart';
import 'package:open_media_station_base/widgets/app_bar_title.dart';

class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  late Future<List<InventoryItem>> futureItems;

  @override
  void initState() {
    futureItems = InventoryService.getInventoryItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scrollableWidth = screenWidth - 50;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: AppBarTitle(
          screenWidth: screenWidth,
          title: Globals.Title,
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Settings(),
                ),
              )
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 0, left: 8, top: 8, bottom: 8),
        child: FutureBuilder<List<InventoryItem>>(
          future: futureItems,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No audiobooks found.'));
            }

            List<InventoryItem> items = snapshot.data!;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: scrollableWidth,
                  child: RefreshIndicator(
                    displacement: 40,
                    onRefresh: () async {
                      setState(() {
                        futureItems = InventoryService.getInventoryItems();
                      });
                    },
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(scrollbars: false),
                      child: Grid(
                        inventoryItems: items,
                      ),
                    ),
                  ),
                ),
                const Expanded(child: Text(''))
              ],
            );
          },
        ),
      ),
    );
  }
}
