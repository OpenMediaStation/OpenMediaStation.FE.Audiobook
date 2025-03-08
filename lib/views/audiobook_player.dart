import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:open_media_station_audiobook/globals.dart';
import 'package:open_media_station_audiobook/models/internal/grid_item_model.dart';
import 'package:open_media_station_audiobook/widgets/advanced_controls_row.dart';
import 'package:open_media_station_audiobook/widgets/player_content_information.dart';
import 'package:open_media_station_audiobook/widgets/player_control_row.dart';
import 'package:open_media_station_audiobook/widgets/seek_bar.dart';
import 'package:open_media_station_base/helpers/preferences.dart';
import 'package:open_media_station_base/widgets/custom_image.dart';

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
    String url =
        "${Preferences.prefs?.getString("BaseUrl")}/stream/${widget.itemModel.inventoryItem?.category}/${widget.itemModel.inventoryItem?.id}${widget.versionID != null ? "?versionId=${widget.versionID}" : ""}";

    await Globals.audioPlayer.initializePlayer(widget.itemModel, url);
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
