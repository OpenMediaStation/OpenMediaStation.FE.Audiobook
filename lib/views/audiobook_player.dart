import 'dart:async';
import 'package:flutter/material.dart';
import 'package:open_media_station_audiobook/globals.dart';
import 'package:open_media_station_audiobook/widgets/advanced_controls_row.dart';
import 'package:open_media_station_audiobook/widgets/player_content_information.dart';
import 'package:open_media_station_audiobook/widgets/player_control_row.dart';
import 'package:open_media_station_audiobook/widgets/seek_bar.dart';
import 'package:open_media_station_base/models/internal/grid_item_model.dart';

class AudiobookPlayer extends StatefulWidget {
  const AudiobookPlayer({
    super.key,
    required this.itemModel,
    required this.versionID,
  });

  final GridItemModel itemModel;
  final String? versionID;

  @override
  State<AudiobookPlayer> createState() => _AudiobookPlayerState();
}

class _AudiobookPlayerState extends State<AudiobookPlayer> {
  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    await Globals.audioPlayer.initializePlayer(widget.itemModel, widget.versionID);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Column(
        children: [
          PlayerContentInformation(),
          Spacer(),
          SeekBar(),
          PlayerControlRow(),
          AdvancedControlsRow(),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
