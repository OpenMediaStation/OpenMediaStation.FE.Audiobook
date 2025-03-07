import 'package:open_media_station_audiobook/globals.dart';
import 'package:open_media_station_audiobook/models/internal/grid_item_model.dart';
import 'package:open_media_station_base/apis/favorites_api.dart';
import 'package:open_media_station_base/apis/inventory_api.dart';
import 'package:open_media_station_base/apis/metadata_api.dart';
import 'package:open_media_station_base/apis/progress_api.dart';
import 'package:open_media_station_base/models/inventory/inventory_item.dart';
import 'package:open_media_station_base/models/metadata/metadata_model.dart';
import 'package:open_media_station_base/models/progress/progress.dart';

class InventoryService {
  static Future<List<InventoryItem>> getInventoryItems() async {
    InventoryApi inventoryApi = InventoryApi();

    var items = await inventoryApi.listItems("Audiobook");

    items.sort((a, b) => a.title?.compareTo(b.title ?? '') ?? 0);
    return items;
  }

  static Future<GridItemModel> getAudiobook(InventoryItem element) async {
    InventoryApi inventoryApi = InventoryApi();
    MetadataApi metadataApi = MetadataApi();
    FavoritesApi favoritesApi = FavoritesApi();
    ProgressApi progressApi = ProgressApi();

    var audiobook = await inventoryApi.getAudiobook(element.id);

    Future<MetadataModel?> metadataFuture = audiobook.metadataId != null
        ? metadataApi.getMetadata(audiobook.metadataId!, "Audiobook")
        : Future.value(null);

    Future<bool?> favFuture = favoritesApi.isFavorited("Audiobook", audiobook.id);
    Future<Progress?> progressFuture =
        progressApi.getProgress("Audiobook", audiobook.id);

    var results = await Future.wait([metadataFuture, favFuture, progressFuture]);

    var metadata = results[0] as MetadataModel?;
    var fav = results[1] as bool?;
    var progress = results[2] as Progress?;

    var gridItem = GridItemModel(
      inventoryItem: audiobook,
      metadataModel: metadata,
      isFavorite: fav,
      progress: progress,
    );

    gridItem.image = metadata?.audiobook?.thumbnail ?? Globals.PictureNotFoundUrl;

    return gridItem;
  }

}
