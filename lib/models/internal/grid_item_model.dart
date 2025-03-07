import 'package:open_media_station_audiobook/globals.dart';
import 'package:open_media_station_base/models/file_info/file_info.dart';
import 'package:open_media_station_base/models/inventory/inventory_item.dart';
import 'package:open_media_station_base/models/metadata/metadata_model.dart';
import 'package:open_media_station_base/models/progress/progress.dart';

class GridItemModel {
  final InventoryItem? inventoryItem;
  final MetadataModel? metadataModel;
  Progress? progress;
  FileInfo? fileInfo;
  bool? isFavorite;
  bool fake = false;
  String image = Globals.PictureNotFoundUrl;

  GridItemModel({
    required this.inventoryItem,
    required this.metadataModel,
    required this.isFavorite,
    required this.progress,
    this.fileInfo,
  });
}
