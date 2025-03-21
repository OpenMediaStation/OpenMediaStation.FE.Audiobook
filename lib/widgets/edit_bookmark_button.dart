import 'package:flutter/material.dart';
import 'package:open_media_station_base/apis/bookmarks_api.dart';
import 'package:open_media_station_base/models/bookmark.dart';
import 'package:open_media_station_base/models/internal/grid_item_model.dart';

class EditBookmarkButton extends StatelessWidget {
  const EditBookmarkButton({
    super.key,
    required this.gridItemModel,
    required this.bookmark,
  });

  final GridItemModel gridItemModel;
  final Bookmark bookmark;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            TextEditingController titleController = TextEditingController();
            TextEditingController descriptionController =
                TextEditingController();

            titleController.text = bookmark.title ?? "";
            descriptionController.text = bookmark.description ?? "";

            return AlertDialog(
              title: const Text("Edit Bookmark"),
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
                    bookmark.title = titleController.text;
                    bookmark.description = descriptionController.text;

                    if (bookmark.id != null) {
                      await BookmarksApi.updateBookmark(
                        bookmark.id!,
                        bookmark,
                        gridItemModel.inventoryItem!.id,
                        "Audiobook",
                      );

                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
      icon: const Icon(Icons.edit),
    );
  }
}
