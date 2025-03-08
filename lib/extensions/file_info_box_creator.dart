import 'package:flutter/material.dart';
import 'package:open_media_station_base/helpers/duration_extension_methods.dart';
import 'package:open_media_station_base/models/file_info/file_info.dart';
import 'package:open_media_station_base/widgets/file_info_box.dart';

extension FileInfoBoxCreator on FileInfo {
  List<FileInfoBox> createBoxes() {
    List<FileInfoBox> boxes = [];

    var mediaData = this.mediaData;

    var duration = mediaData.duration ?? mediaData.format.duration;
    if (duration != null) {
      boxes.add(FileInfoBox(duration.toformattedString(), key: GlobalKey(),));
    }

    var vStr = mediaData.primaryVideoStream;

    if (vStr.codecName != null || vStr.profile != null) {
      boxes.add(FileInfoBox(vStr.codecName?.toUpperCase() ?? vStr.profile!, key: GlobalKey(),));
    }

    if (mediaData.audioStreams.isNotEmpty) {
      for (var aStr in mediaData.audioStreams) {
        boxes.add(FileInfoBox(
            "${aStr.profile ?? aStr.codecName?.toUpperCase() ?? ""} ${aStr.channelLayout}${" ${aStr.language ?? ""}"}", key: GlobalKey(),));
      }
    }

    if (mediaData.format.formatLongName != null) {
      boxes.add(FileInfoBox(mediaData.format.formatLongName!, key: GlobalKey(),));
    }

    return boxes;
  }
}