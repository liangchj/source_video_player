
import 'dart:typed_data';

abstract class PlatformAssetEntity {
  String get title;
  int get duration;

  // final T entity;

  // PlatformAssetEntity({required this.entity});

  Uint8List? get thumbnail;

  String? get mediaUrl;

  String get id;

  DateTime get modifiedDateTime;

}