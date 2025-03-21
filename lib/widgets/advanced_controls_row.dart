import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:open_media_station_audiobook/globals.dart';
import 'package:open_media_station_base/models/internal/grid_item_model.dart';
import 'package:open_media_station_base/models/metadata/metadata_audiobook_chapter.dart';

class AdvancedControlsRow extends StatelessWidget {
  const AdvancedControlsRow({
    super.key,
    required this.gridItemModel,
  });

  final GridItemModel gridItemModel;

  @override
  Widget build(BuildContext context) {
    double size = 28;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            iconSize: size,
            onPressed: () async {},
          ),
          IconButton(
            icon: const Icon(Icons.speed_outlined),
            iconSize: size,
            onPressed: () async {
              _showPlaybackSpeedDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.moon_outline),
            iconSize: size - 4,
            onPressed: () async {
              _showSleeptimerDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.list_outlined),
            iconSize: size,
            onPressed: () async {
              _showChapterDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showChapterDialog(BuildContext context) {
    var chapters = gridItemModel.metadataModel?.audiobook?.chapters;

    if (chapters?.isEmpty ?? true) {
      var parts = gridItemModel.inventoryItem?.versions?.firstOrNull?.parts;

      if (parts != null) {
        var counter = 0;
        for (var element in parts) {
          var durationCurrentPart = Globals
                  .audioPlayer
                  .fileInfosForCurrentParts[counter]
                  .mediaData
                  .format
                  ?.duration ??
              const Duration(seconds: 0);
          var endtime =
              Globals.audioPlayer.calculateDurationBeforeIndex(counter) +
                  durationCurrentPart;

          chapters?.add(MetadataAudiobookChapter(
            title: element.name,
            startTimeInSeconds: Globals.audioPlayer
                .calculateDurationBeforeIndex(counter)
                .inSeconds,
            endTimeInSeconds: endtime.inSeconds,
          ));

          counter++;
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Chapter"),
          content: SizedBox(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: chapters?.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("${chapters![index].title}"),
                  onTap: () {
                    if (chapters[index].startTimeInSeconds != null) {
                      Globals.audioPlayer.seek(
                        Duration(
                          seconds: chapters[index].startTimeInSeconds!,
                        ),
                      );
                    }

                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showPlaybackSpeedDialog(BuildContext context) {
    List<double> speeds = [0.5, 1.0, 1.25, 1.5, 2.0, 2.5, 3.0, 4.0];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Playback Speed"),
          content: SizedBox(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: speeds.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("${speeds[index]}x"),
                  onTap: () {
                    Globals.audioPlayer.setSpeed(speeds[index]);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showSleeptimerDialog(BuildContext context) {
    List<Duration> durations = [
      const Duration(minutes: 1),
      const Duration(minutes: 5),
      const Duration(minutes: 10),
      const Duration(minutes: 15),
      const Duration(minutes: 30),
      const Duration(minutes: 45),
      const Duration(hours: 1),
      const Duration(hours: 1, minutes: 30),
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Set Sleeptimer"),
          content: SizedBox(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: durations.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(durations[index].inMinutes == 1
                      ? "${durations[index].inMinutes} minute"
                      : "${durations[index].inMinutes} minutes"),
                  onTap: () {
                    Globals.audioPlayer.startSleepTimer(durations[index]);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
