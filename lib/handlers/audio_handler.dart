import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:open_media_station_audiobook/globals.dart';
import 'package:open_media_station_audiobook/models/internal/media_state.dart';
import 'package:open_media_station_base/globals/logging.dart';
import 'package:open_media_station_base/models/internal/grid_item_model.dart';
import 'package:open_media_station_base/open_media_station_base.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final player = AudioPlayer();
  Timer? _sleepTimer;
  StreamSubscription<MediaState>? _streamSubscription;
  MediaItem? _mediaItem;
  GridItemModel? currentGridItemModel;
  String? currentVersionId;
  String? currentUrl;
  List<FileInfo> fileInfosForCurrentParts = [];

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

  @override
  Future<void> setSpeed(double speed) async {
    await player.setSpeed(speed);
  }

  @override
  Future<void> fastForward() async {
    var position = (await (mediaStateStream.first)).position;

    await seek(position + const Duration(seconds: 10));
  }

  @override
  Future<void> rewind() async {
    var position = (await (mediaStateStream.first)).position;

    await seek(position - const Duration(seconds: 10));
  }

  Future<void> _playFromUri(Uri uri, GridItemModel? itemModel,
      [Map<String, dynamic>? extras]) async {
    Logging.logger.d("Playing Uri: $uri");

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
          fileInfo?.mediaData.duration ?? fileInfo?.mediaData.format?.duration;
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

  Future<Duration> calculateDuration() async {
    var version = currentGridItemModel?.inventoryItem?.versions
        ?.where((i) => i.id == currentVersionId)
        .firstOrNull;

    var calculatedDuration = const Duration();
    for (var element in version!.parts!) {
      var fileInfo = fileInfosForCurrentParts
          ?.where((i) => i.id == element.fileInfoId)
          .firstOrNull;

      var extractedDuration =
          fileInfo?.mediaData.duration ?? fileInfo?.mediaData.format?.duration;

      if (extractedDuration != null) {
        calculatedDuration += extractedDuration;
      }
    }

    return calculatedDuration;
  }

  Duration calculateDurationBeforeIndex(int? index) {
    var version = currentGridItemModel?.inventoryItem?.versions
        ?.where((i) => i.id == currentVersionId)
        .firstOrNull;

    var calculatedDuration = const Duration();

    if (index == null) {
      return calculatedDuration;
    }

    for (var i = 0; i < index; i++) {
      var fileInfo = fileInfosForCurrentParts
          ?.where((item) => item.id == version!.parts![i].fileInfoId)
          .firstOrNull;

      var extractedDuration =
          fileInfo?.mediaData.duration ?? fileInfo?.mediaData.format?.duration;

      if (extractedDuration != null) {
        calculatedDuration += extractedDuration;
      }
    }

    return calculatedDuration;
  }

  Future<(int, Duration)> calculateIndexForDuration(Duration duration) async {
    var version = currentGridItemModel?.inventoryItem?.versions
        ?.where((i) => i.id == currentVersionId)
        .firstOrNull;

    var calculatedDuration = const Duration();

    Duration? extractedDuration;

    int index = -1;
    while (calculatedDuration < duration) {
      index++;
      var fileInfo = fileInfosForCurrentParts
          ?.where((item) => item.id == version!.parts![index].fileInfoId)
          .firstOrNull;
      extractedDuration =
          fileInfo?.mediaData.duration ?? fileInfo?.mediaData.format?.duration;

      if (extractedDuration != null) {
        calculatedDuration += extractedDuration;
      }
    }

    var temp = calculatedDuration - duration;
    var positionInItem = extractedDuration! - temp;

    return (index, positionInItem);
  }

  Future<void> _playFromItemModel(
      GridItemModel? itemModel, String? versionId) async {
    var version = itemModel?.inventoryItem?.versions
        ?.where((i) => i.id == versionId)
        .firstOrNull;

    AudioSource? audioSource;
    List<AudioSource>? audioSources;

    if (version?.parts == null) {
      String url =
          "${Preferences.prefs?.getString("BaseUrl")}/stream/${itemModel?.inventoryItem?.category}/${itemModel?.inventoryItem?.id}${versionId != null ? "?versionId=$versionId" : ""}";

      Logging.logger.d("PlayBackUrl: $url");

      audioSource = AudioSource.uri(
        Uri.parse(url),
        headers: BaseApi.getHeaders(),
      );
    } else {
      audioSource = null;

      version?.parts?.sort(
        (i1, i2) {
          int primaryComparison =
              i1.primaryIdentifier?.compareTo(i2.primaryIdentifier ?? 0) ?? 0;

          if (primaryComparison != 0) {
            return primaryComparison;
          }

          return i1.secondaryIdentifier
                  ?.compareTo(i2.secondaryIdentifier ?? 0) ??
              0;
        },
      );

      for (var element in version!.parts!) {
        var fileInfo = await FileInfoApi.getFileInfo(
            currentGridItemModel!.inventoryItem!.category,
            element.fileInfoId ?? "");

        fileInfosForCurrentParts.add(fileInfo!);
      }

      audioSources = [];

      for (var element in version.parts!) {
        String url =
            "${Preferences.prefs?.getString("BaseUrl")}/stream/${itemModel?.inventoryItem?.category}/${itemModel?.inventoryItem?.id}?partId=${element.id}${versionId != null ? "&versionId=$versionId" : ""}";

        Logging.logger.d("PlayBackUrl: $url");

        audioSources.add(
          AudioSource.uri(
            Uri.parse(url),
            headers: BaseApi.getHeaders(),
          ),
        );
      }
    }

    Duration? duration;

    if (version?.parts != null) {
      var calculatedDuration = await calculateDuration();
      duration = calculatedDuration;
    }

    Duration? tempDuration;

    if (audioSource != null) {
      tempDuration = await player.setAudioSource(audioSource);
    } else if (audioSources != null) {
      tempDuration = await player.setAudioSources(audioSources);
    }

    if (tempDuration != null &&
        tempDuration != const Duration() &&
        version?.parts == null) {
      duration = tempDuration;
    }

    // if using media kit we are blind here...
    if (duration == const Duration(seconds: 0) || duration == null) {
      if (version?.parts == null) {
        var fileInfo = await FileInfoApi.getFileInfo(
            itemModel!.inventoryItem!.category,
            itemModel.inventoryItem!.versions?.first.fileInfoId ?? "");
        duration = fileInfo?.mediaData.duration ??
            fileInfo?.mediaData.format?.duration;
      }
    }

    _mediaItem = MediaItem(
      id: version?.id ?? "unknown",
      title: itemModel?.metadataModel?.title ?? "Unknown title",
      artist: itemModel?.metadataModel?.audiobook?.authors?.firstOrNull ??
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
    _sleepTimer?.cancel();
  }

  @override
  Future<void> seek(Duration position) async {
    var version = currentGridItemModel?.inventoryItem?.versions
        ?.where((i) => i.id == currentVersionId)
        .firstOrNull;

    if (version?.parts != null) {
      var (index, indexDuration) = await calculateIndexForDuration(position);
      await player.seek(index: index, indexDuration);
    } else {
      await player.seek(position);
    }
  }

  Future<void> initializePlayer(
    GridItemModel itemModel,
    String? versionId,
  ) async {
    currentVersionId = versionId;

    if (itemModel.inventoryItem?.versions
            ?.where((i) => i.id == currentVersionId)
            .firstOrNull
            ?.id ==
        _mediaItem?.id) {
      return;
    }

    currentGridItemModel = itemModel;

    await _playFromItemModel(itemModel, currentVersionId);

    // Handle progress
    int? lastUpdatedSecond;
    bool finished = false;
    bool initialRun = true;

    if (_streamSubscription != null) {
      _streamSubscription!.cancel();
    }

    _streamSubscription = mediaStateStream.listen((mediaState) async {
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

    await seek(
      Duration(seconds: itemModel.progress?.progressSeconds ?? 0),
    );
  }

  /// Sleep timer function
  void startSleepTimer(Duration duration) {
    _sleepTimer?.cancel();
    _sleepTimer = Timer(duration, () {
      stop();
    });
  }

  /// Cancel the sleep timer manually if needed
  void cancelSleepTimer() {
    _sleepTimer?.cancel();
  }

  Stream<MediaState> get mediaStateStream =>
      Rx.combineLatest2<MediaItem?, Duration, MediaState>(
        mediaItem,
        AudioService.position,
        (mediaItem, position) => MediaState(mediaItem, position),
      ).asyncMap(
        (mediaState) async {
          var version = currentGridItemModel?.inventoryItem?.versions
              ?.where((i) => i.id == currentVersionId)
              .firstOrNull;

          Duration additionalTime = const Duration();

          if (version?.parts != null) {
            additionalTime = calculateDurationBeforeIndex(player.currentIndex);
          }

          return MediaState(
              mediaState.mediaItem, mediaState.position + additionalTime);
        },
      );

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
