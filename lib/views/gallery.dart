import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_media_station_audiobook/globals.dart';
import 'package:open_media_station_audiobook/services/inventory_service.dart';
import 'package:open_media_station_audiobook/views/settings.dart';
import 'package:open_media_station_audiobook/widgets/grid.dart';
import 'package:open_media_station_audiobook/widgets/mini_audio_player.dart';
import 'package:open_media_station_base/globals/platform_globals.dart';
import 'package:open_media_station_base/models/inventory/inventory_item.dart';
import 'package:open_media_station_base/widgets/alphabet_bar.dart';
import 'package:open_media_station_base/widgets/app_bar_title.dart';

class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  late Future<List<InventoryItem>> futureItems;
  var searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool searchBarVisible = false;
  bool _descending = false;

  @override
  void initState() {
    futureItems = InventoryService.getInventoryItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double desiredItemWidth = 150;
    int crossAxisCount = (screenWidth / desiredItemWidth).floor();
    double gridMainAxisSpacing = 8.0;
    double gridCrossAxisSpacing = 8.0;
    double gridItemAspectRatio = 0.85;

    double scrollableWidth = screenWidth - 50;
    bool largeScreen = false;
    if (screenWidth > 1000) {
      desiredItemWidth = 300;
      largeScreen = true;
    }
    double gridItemHeight =
        (((scrollableWidth - gridCrossAxisSpacing * (crossAxisCount - 1)) /
                crossAxisCount) /
            gridItemAspectRatio);

    var searchBar = Flexible(
      fit: FlexFit.tight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550, minWidth: 200),
        child: Padding(
            padding: const EdgeInsets.only(right: 8.0, left: 8.0),
            child: TextField(
              controller: searchController,
              expands: false,
              decoration: const InputDecoration(
                icon: Icon(
                  Icons.search,
                  size: 15,
                  color: Colors.grey,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            )),
      ),
    );

    List<Widget> appBarTitleSpace = [];
    if ((PlatformGlobals.isMobile || !largeScreen) && searchBarVisible) {
      appBarTitleSpace.add(searchBar);
    } else if (searchBarVisible) {
      appBarTitleSpace.addAll([
        AppBarTitle(
          screenWidth: screenWidth,
          title: Globals.Title,
        ),
        searchBar
      ]);
    } else {
      appBarTitleSpace.add(AppBarTitle(
        screenWidth: screenWidth,
        title: Globals.Title,
      ));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: appBarTitleSpace,
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () => setState(() {
                    searchBarVisible = !searchBarVisible;
                    if (!searchBarVisible) {
                      searchController.text = "";
                    }
                  }),
              icon: !searchBarVisible
                  ? const Icon(Icons.search)
                  : const Icon(Icons.search_off)),
          IconButton(
              onPressed: () => setState(() {
                    _descending = !_descending;
                  }),
              icon: const Icon(Icons.sort_by_alpha)),
          PlatformGlobals.isKiosk
              ? IconButton(
                  onPressed: () => exit(0), icon: const Icon(Icons.close))
              : const Text(''),
          PlatformGlobals.isMobile
              ? const Text('')
              : IconButton(
                  onPressed: () => setState(() {
                        futureItems = InventoryService.getInventoryItems();
                      }),
                  icon: const Icon(Icons.refresh)),
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
      body: Stack(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(right: 0, left: 8, top: 8, bottom: 8),
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
                List<InventoryItem> filteredItems = filterItems(items);

                return Stack(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: scrollableWidth,
                          child: RefreshIndicator(
                            displacement: 40,
                            onRefresh: () async {
                              setState(() {
                                futureItems =
                                    InventoryService.getInventoryItems();
                              });
                            },
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context)
                                  .copyWith(scrollbars: false),
                              child: Grid(
                                inventoryItems: filteredItems,
                                scrollController: _scrollController,
                                desiredItemWidth: desiredItemWidth,
                                crossAxisCount: crossAxisCount,
                                gridMainAxisSpacing: gridMainAxisSpacing,
                                gridCrossAxisSpacing: gridCrossAxisSpacing,
                                gridItemAspectRatio: gridItemAspectRatio,
                              ),
                            ),
                          ),
                        ),
                        const Expanded(child: Text(''))
                      ],
                    ),
                    if (filteredItems.length ~/ crossAxisCount > 5)
                      AlphabetBar(
                        scrollController: _scrollController,
                        filteredItems: filteredItems,
                        descending: _descending,
                        gridLineHeight: gridItemHeight + gridMainAxisSpacing,
                        crossAxisCount: crossAxisCount,
                      ),
                  ],
                );
              },
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: MiniAudioPlayer(),
          ),
        ],
      ),
    );
  }

  List<InventoryItem> filterItems(List<InventoryItem> items) {
    var filteredList = items
        .where((item) => (searchController.text == "" ||
            (item.title
                    ?.toLowerCase()
                    .contains(searchController.text.toLowerCase()) ??
                false)))
        .toList();

    filteredList.sort((a, b) =>
        a.title?.toLowerCase().compareTo(b.title?.toLowerCase() ?? '') ?? 0);

    if (_descending) {
      filteredList.sort((a, b) =>
          b.title?.toLowerCase().compareTo(a.title?.toLowerCase() ?? '') ?? 0);
    }
    return filteredList;
  }
}
