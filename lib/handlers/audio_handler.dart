import 'package:audio_service/audio_service.dart';
import 'package:media_kit/media_kit.dart';
import 'package:open_media_station_audiobook/models/internal/grid_item_model.dart';
import 'package:open_media_station_base/apis/base_api.dart';
import 'package:open_media_station_base/apis/progress_api.dart';
import 'package:open_media_station_base/models/progress/progress.dart';

class AudioPlayer extends BaseAudioHandler with QueueHandler, SeekHandler {
  final player = Player();

  @override
  Future<void> play() async {
    await player.play();
  }

  @override
  Future<void> playFromUri(Uri uri, [Map<String, dynamic>? extras]) async {
    await player.open(
      Media(
        uri.toString(),
        httpHeaders: BaseApi.getHeaders(),
      ),
      play: false,
    );
  }

  @override
  Future<void> pause() async {
    await player.pause();
  }

  @override
  Future<void> stop() async {
    await player.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await player.seek(position);
  }

  Future<void> initializePlayer(GridItemModel itemModel, String url) async {
    await playFromUri(Uri.parse(url));

    // Handle progress
    int? lastUpdatedSecond;
    bool finished = false;

    player.stream.position.listen((duration) async {
      var positionInSeconds = duration.inSeconds;
      var durationInSeconds = player.state.duration.inSeconds;

      if (positionInSeconds % 10 == 0 &&
          !finished &&
          lastUpdatedSecond != positionInSeconds &&
          positionInSeconds != 0 &&
          durationInSeconds != 0) {
        lastUpdatedSecond = positionInSeconds;

        double? progressPercentage =
            (positionInSeconds / durationInSeconds) * 100;

        ProgressApi progressApi = ProgressApi();
        itemModel.progress ??= Progress(
          id: null,
          category: itemModel.inventoryItem?.category,
          parentId: itemModel.inventoryItem?.id,
          progressSeconds: positionInSeconds,
          progressPercentage: progressPercentage,
          completions: null,
        );

        if (progressPercentage >= 85) {
          itemModel.progress!.completions ??= 0;
          itemModel.progress!.completions =
              itemModel.progress!.completions! + 1;

          finished = true;

          itemModel.progress!.progressSeconds = 0;
          itemModel.progress!.progressPercentage = 0;
        } else {
          itemModel.progress!.progressSeconds = positionInSeconds;
          itemModel.progress!.progressPercentage = progressPercentage;
        }

        await progressApi.updateProgress(itemModel.progress!);
        itemModel.progress = await progressApi.getProgress(
          itemModel.inventoryItem?.category,
          itemModel.inventoryItem?.id,
        );
      }
    });

    var position = player.state.duration.inSeconds;

    while (position < (itemModel.progress?.progressSeconds ?? 0)) {
      await player.seek(
        Duration(seconds: itemModel.progress?.progressSeconds ?? 0),
      );

      await Future.delayed(const Duration(milliseconds: 100));

      position = player.state.position.inSeconds;
    }
  }
}
