import 'package:flutter/material.dart';
import 'package:open_media_station_audiobook/globals.dart';
import 'package:open_media_station_base/apis/bookmarks_api.dart';
import 'package:open_media_station_base/models/bookmark.dart';
import 'package:open_media_station_base/models/internal/grid_item_model.dart';

class CreateBookmarkButton extends StatelessWidget {
  const CreateBookmarkButton({super.key, required this.gridItemModel});

  final GridItemModel gridItemModel;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            TextEditingController titleController = TextEditingController();
            TextEditingController descriptionController =
                TextEditingController();

            return AlertDialog(
              title: const Text("Create Bookmark"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Title",
                    ),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: "Description",
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Close the dialog without doing anything
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    String title = titleController.text;
                    String description = descriptionController.text;
                    var position =
                        (await (Globals.audioPlayer.mediaStateStream.first))
                            .position;

                    await BookmarksApi.addBookmark(
                      "Audiobook",
                      gridItemModel.inventoryItem!.id,
                      Bookmark(
                        title: title,
                        description: description,
                        positionInSeconds: position.inSeconds,
                      ),
                    );

                    Navigator.of(context).pop();
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
      child: const Text("Create Bookmark"),
    );
  }
}
