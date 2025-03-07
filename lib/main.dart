import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:open_media_station_audiobook/views/gallery.dart';
import 'package:open_media_station_base/helpers/app_helper.dart';

Future main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  AppHelper.start(args, const Gallery(), "Open Media Station");
}
