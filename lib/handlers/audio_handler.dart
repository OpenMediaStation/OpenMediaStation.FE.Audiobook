import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:open_media_station_audiobook/globals.dart';
import 'package:open_media_station_audiobook/models/internal/grid_item_model.dart';
import 'package:open_media_station_audiobook/models/internal/media_state.dart';
import 'package:open_media_station_base/apis/base_api.dart';
import 'package:open_media_station_base/apis/file_info_api.dart';
import 'package:open_media_station_base/apis/progress_api.dart';
import 'package:open_media_station_base/models/progress/progress.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final player = AudioPlayer();
  StreamSubscription<MediaState>? _streamSubscription;
  MediaItem? _mediaItem;

  AudioPlayerHandler() {
    player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  @override
  Future<void> play() async {
    await player.play();
  }

  @override
  Future<void> playFromUri(Uri uri, [Map<String, dynamic>? extras]) async {
    await _playFromUri(uri, null, extras);
  }

  Future<void> _playFromUri(Uri uri, GridItemModel? itemModel,
      [Map<String, dynamic>? extras]) async {
    var duration = await player.setAudioSource(
      AudioSource.uri(
        uri,
        headers: BaseApi.getHeaders(),
      ),
    );

    // if using media kit we are blind here...
    if (duration == const Duration(seconds: 0)) {
      var fileInfo = await FileInfoApi.getFileInfo(
          itemModel!.inventoryItem!.category,
          itemModel.inventoryItem!.versions?.first.fileInfoId ?? "");
      duration =
          fileInfo?.mediaData.duration ?? fileInfo?.mediaData.format.duration;
    }

    _mediaItem = MediaItem(
      id: uri.toString(),
      title: itemModel?.metadataModel?.title ?? "Unknown title",
      artist: itemModel?.metadataModel?.audiobook?.authors?.first ??
          "Unknown author",
      duration: duration,
      artUri: Uri.parse(itemModel?.image ?? Globals.PictureNotFoundUrl),
      artHeaders: BaseApi.getHeaders(),
    );

    mediaItem.add(_mediaItem);
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
    if (url == _mediaItem?.id) {
      return;
    }

    await _playFromUri(Uri.parse(url), itemModel);

    // Handle progress
    int? lastUpdatedSecond;
    bool finished = false;
    bool initialRun = true;

    if (_streamSubscription != null) {
      _streamSubscription!.cancel();
    }

    _streamSubscription = _mediaStateStream.listen((mediaState) async {
      var positionInSeconds = mediaState.position.inSeconds;
      var durationInSeconds = mediaState.mediaItem?.duration?.inSeconds ?? 0;

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

        if (progressPercentage >= 95) {
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

      // The commented out code may be needed for windows and linux which run on media kit

      // var position = mediaState.position.inSeconds;

      // if (initialRun) {
      //   // while (position < (itemModel.progress?.progressSeconds ?? 0)) {
      //     await player.seek(
      //       Duration(seconds: itemModel.progress?.progressSeconds ?? 0),
      //     );

      //   //   await Future.delayed(const Duration(milliseconds: 100));

      //   //   position = mediaState.position.inSeconds;
      //   // }

      //   initialRun = false;
      // }
    });

    await player.seek(
      Duration(seconds: itemModel.progress?.progressSeconds ?? 0),
    );
  }

  Stream<MediaState> get _mediaStateStream =>
      Rx.combineLatest2<MediaItem?, Duration, MediaState>(
          mediaItem,
          AudioService.position,
          (mediaItem, position) => MediaState(mediaItem, position));

  /// Transform a just_audio event into an audio_service state.
  ///
  /// This method is used from the constructor. Every event received from the
  /// just_audio player will be transformed into an audio_service state so that
  /// it can be broadcast to audio_service clients.
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[player.processingState]!,
      playing: player.playing,
      updatePosition: player.position,
      bufferedPosition: player.bufferedPosition,
      speed: player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
