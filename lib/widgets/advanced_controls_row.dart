import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:open_media_station_audiobook/globals.dart';

class AdvancedControlsRow extends StatelessWidget {
  const AdvancedControlsRow({super.key});

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
            onPressed: () async {},
          ),
        ],
      ),
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
