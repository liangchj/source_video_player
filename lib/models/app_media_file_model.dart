import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_player_ui/model/file_source_model.dart';

import '../platform/platform_asset_entity.dart';

/*
List<AppMediaFileModel> appMediaFileModelListFromJson(String str) =>
    List<AppMediaFileModel>.from(
      json.decode(str).map((x) => AppMediaFileModel.fromJson(x)),
    );
*/

String appMediaFileModelListToJson(List<AppMediaFileModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AppMediaFileModel {
  File? file;

  final bool isLocal;

  FileSourceModel? danmakuSource;
  FileSourceModel? subtitleSource;

  PlatformAssetEntity? assetEntity;

  Uint8List? thumbnailUint8List;

  Duration? playHistoryDuration;

  String? errorMsg;

  String? playDir;

  AppMediaFileModel({
    this.file,
    this.isLocal = true,
    this.danmakuSource,
    this.subtitleSource,
    this.assetEntity,
    this.thumbnailUint8List,
    this.playHistoryDuration,
    this.errorMsg,
    this.playDir,
  });

  /*factory AppMediaFileModel.fromJson(Map<String, dynamic> json) {
    String? filePath = json['file'];
    String? danmakuSourceStr = json['danmakuSource'];
    String? assetEntityStr = json['assetEntity'];
    return AppMediaFileModel(
      file: filePath == null || filePath.isEmpty ? null : File(filePath),
      isLocal: json['isLocal'],
      danmakuSource: danmakuSourceStr == null || danmakuSourceStr.isEmpty
          ? null
          : FileSourceModel.fromJson(jsonDecode(danmakuSourceStr)),
      subtitlePath: json['subtitlePath'],
      assetEntity: json['assetEntity'],
      thumbnailUint8List: json['thumbnailUint8List'],
      playHistoryDuration: json['playHistoryDuration'],
      errorMsg: json['errorMsg'],
      playDir: json['playDir'],
    );
  }*/

  AppMediaFileModel copyWith({
    File? file,
    bool? isLocal,
    FileSourceModel? danmakuSource,
    FileSourceModel? subtitleSource,
    PlatformAssetEntity? assetEntity,
    Uint8List? thumbnailUint8List,
  }) {
    return AppMediaFileModel(
      file: file ?? this.file,
      isLocal: isLocal ?? this.isLocal,
      danmakuSource: danmakuSource ?? this.danmakuSource,
      subtitleSource: subtitleSource ?? this.subtitleSource,
      assetEntity: assetEntity ?? this.assetEntity,
      thumbnailUint8List: thumbnailUint8List ?? this.thumbnailUint8List,
      playHistoryDuration: playHistoryDuration,
      errorMsg: errorMsg,
      playDir: playDir,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'file': file,
      'isLocal': isLocal,
      'danmakuSource': danmakuSource?.toJson(),
      'subtitleSource': subtitleSource?.toJson(),
      'assetEntity': assetEntity?.toJson(),
      'thumbnailUint8List': thumbnailUint8List,
      'playHistoryDuration': playHistoryDuration,
      'errorMsg': errorMsg,
      'playDir': playDir,
    };
  }

  String? get fullFilePath => file?.path ?? assetEntity?.mediaUrl;
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
