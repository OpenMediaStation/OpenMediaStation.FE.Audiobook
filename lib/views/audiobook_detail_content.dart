import 'package:flutter/material.dart';
import 'package:open_media_station_audiobook/extensions/file_info_box_creator.dart';
import 'package:open_media_station_audiobook/globals.dart';
import 'package:open_media_station_audiobook/models/internal/grid_item_model.dart';
import 'package:open_media_station_audiobook/views/audiobook_player.dart';
import 'package:open_media_station_base/apis/file_info_api.dart';
import 'package:open_media_station_base/models/file_info/file_info.dart';
import 'package:open_media_station_base/widgets/custom_image.dart';
import 'package:open_media_station_base/widgets/file_info_row.dart';
import 'package:open_media_station_base/widgets/play_button.dart';

class AudiobookDetailContent extends StatelessWidget {
  const AudiobookDetailContent({
    super.key,
    required this.itemModel,
  });

  final GridItemModel itemModel;

  @override
  Widget build(BuildContext context) {
    ValueNotifier<String?> selectedVersionID = ValueNotifier<String?>(
        itemModel.inventoryItem?.versions?.firstOrNull?.id);

    Future<FileInfo?> fileInfoFuture = FileInfoApi.getFileInfo(
        itemModel.inventoryItem!.category,
        itemModel.inventoryItem!.versions
                ?.firstWhere((v) => v.id == (selectedVersionID.value ?? ""))
                .fileInfoId ??
            "");

    bool smallScreen = (MediaQuery.of(context).size.width < 434);

    var versionDropdown = ((itemModel.inventoryItem?.versions?.length ?? 0) > 1)
        ? DropdownMenu(
            textStyle: const TextStyle(fontSize: 15),
            inputDecorationTheme: Theme.of(context).inputDecorationTheme,
            enableSearch: false,
            dropdownMenuEntries: itemModel.inventoryItem?.versions
                    ?.map((v) => DropdownMenuEntry(
                        value: v.id,
                        label: v.name ??
                            itemModel.inventoryItem!.versions!
                                .indexOf(v)
                                .toString()))
                    .toList() ??
                List.empty(),
            initialSelection: itemModel.inventoryItem?.versions?.first.id,
            onSelected: (newVID) {
              selectedVersionID.value = newVID as String;
              if (itemModel.inventoryItem?.category != null) {
                fileInfoFuture = FileInfoApi.getFileInfo(
                    itemModel.inventoryItem!.category,
                    itemModel.inventoryItem!.versions!
                            .firstWhere((v) => v.id == newVID)
                            .fileInfoId ??
                        "");
              }
            },
          )
        : null;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (rect) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black, // Softer black
                  Colors.transparent,
                ],
              ).createShader(Rect.fromLTRB(220, 220, rect.width, rect.height));
            },
            blendMode: BlendMode.dstIn,
            child: CustomImage(
              imageUrl: itemModel.image,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              pictureNotFoundUrl: Globals.PictureNotFoundUrl,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        itemModel.inventoryItem?.title ?? "Title unknown",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!smallScreen && versionDropdown != null)
                      Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: versionDropdown)
                  ],
                ),
                if (smallScreen && versionDropdown != null) versionDropdown,
                ValueListenableBuilder(
                    valueListenable: selectedVersionID,
                    builder: (context, _, __) {
                      return FutureBuilder(
                          future: fileInfoFuture,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData ||
                                snapshot.data == null ||
                                snapshot.error != null) {
                              return const Text("");
                            }

                            return FileInfoRow(
                                fileInfoBoxes: snapshot.data!.createBoxes());
                          });
                    }),
                const SizedBox(
                  height: 16,
                ),
                ValueListenableBuilder(
                    valueListenable: selectedVersionID,
                    builder: (context, versionID, __) {
                      return PlayButton(
                        child: AudiobookPlayer(
                          itemModel: itemModel,
                          versionID: versionID,
                        ),
                      );
                    }),
                const SizedBox(height: 8),
                Text(
                  itemModel.metadataModel?.audiobook?.description ?? "",
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
