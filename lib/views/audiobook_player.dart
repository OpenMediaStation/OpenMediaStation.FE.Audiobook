import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:open_media_station_base/apis/base_api.dart';

class AudiobookPlayer extends StatefulWidget {
  const AudiobookPlayer({
    super.key,
    required this.url,
  });

  final String url;

  @override
  State<AudiobookPlayer> createState() => _AudiobookPlayerState();
}

class _AudiobookPlayerState extends State<AudiobookPlayer> {
  late final player = Player();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Placeholder(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.play_arrow),
        onPressed: () async {

          await player.open(
            Media(
              widget.url,
              httpHeaders: BaseApi.getHeaders(),
            ),
          );
          await player.play();
        },
      ),
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
