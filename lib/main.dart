import 'package:open_media_station_audiobook/views/gallery.dart';
import 'package:open_media_station_base/helpers/app_helper.dart';

Future main(List<String> args) async {
  AppHelper.start(args, const Gallery(), "Open Media Station");
}