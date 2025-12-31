import 'dart:io';
import 'dart:typed_data';

import '../platform/platform_asset_entity.dart';

enum AppMediaFileSourceType { localFile, playListFile }

class AppMediaFileModel {
  File? file;

  // 本地文件、播放列表文件
  AppMediaFileSourceType fileSourceType;

  String? danmakuPath;
  String? subtitlePath;

  PlatformAssetEntity? assetEntity;

  Uint8List? thumbnailUint8List;

  Duration? playHistoryDuration;

  AppMediaFileModel({
    this.file,
    this.fileSourceType = AppMediaFileSourceType.localFile,
    this.danmakuPath,
    this.subtitlePath,
    this.assetEntity,
    this.thumbnailUint8List,
    this.playHistoryDuration,
  });

  AppMediaFileModel copyWith({
    File? file,
    AppMediaFileSourceType? fileSourceType,
    String? danmakuPath,
    String? subtitlePath,
    PlatformAssetEntity? assetEntity,
    Uint8List? thumbnailUint8List,
  }) {
    return AppMediaFileModel(
      file: file ?? this.file,
      fileSourceType: fileSourceType ?? this.fileSourceType,
      danmakuPath: danmakuPath ?? this.danmakuPath,
      subtitlePath: subtitlePath ?? this.subtitlePath,
      assetEntity: assetEntity ?? this.assetEntity,
      thumbnailUint8List: thumbnailUint8List ?? this.thumbnailUint8List,
    );
  }

  String? get fullFilePath => file?.path;
  String? get filePath =>
      fullFilePath?.substring(fullFilePath!.lastIndexOf("/") + 1);
  String? get filePathName =>
      filePath?.substring(0, filePath!.lastIndexOf("."));

  String get fileName => filePathName ?? assetEntity?.title ?? "";

  String get suffix => filePath == null
      ? ""
      : filePath!.contains(".")
      ? filePath!.split(".").last
      : "";

  Duration? get duration => assetEntity == null
      ? null
      : Duration(seconds: assetEntity!.duration.toInt());
}
