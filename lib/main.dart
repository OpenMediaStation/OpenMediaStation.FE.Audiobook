import 'dart:developer';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:open_media_station_audiobook/globals.dart';
import 'package:open_media_station_audiobook/handlers/audio_handler.dart';
import 'package:open_media_station_audiobook/views/gallery.dart';
import 'package:open_media_station_base/helpers/app_helper.dart';

Future main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());

  // Activate the audio session before playing audio.
  if (await session.setActive(true)) {
    log("message");
    // Now play audio.
  } else {
    // The request was denied and the app should not play audio
    log("message");
  }

  Globals.audioPlayer = await AudioService.init(
    builder: () => AudioPlayer(),
    config: const AudioServiceConfig(
      androidNotificationChannelId:
          'org.openmediastation.audiobook.channel.audio',
      androidNotificationChannelName: 'Audiobook playback',
      androidShowNotificationBadge: true,
      androidNotificationOngoing: true,
    ),
  );

  AppHelper.start(args, const Gallery(), "Open Media Station");
}
