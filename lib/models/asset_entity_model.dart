import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';
import 'package:source_video_player/platform/platform_asset_entity.dart';

class AssetEntityModel extends PlatformAssetEntity {
  // @override
  // final AssetEntity assetEntity;

  // AssetEntityModel({required super.entity});

  @override
  final String id;
  @override
  final int duration;
  @override
  final String title;
  @override
  final Uint8List? thumbnail;
  @override
  final String? mediaUrl;
  @override
  final DateTime modifiedDateTime;

  AssetEntityModel({
    required this.id,
    required this.duration,
    required this.title,
    this.thumbnail,
    this.mediaUrl,
    required this.modifiedDateTime,
  });

  /*@override
  int get duration => entity.duration ?? 0;

  @override
  String get title => entity.title ?? '';

  @override
  Future<Uint8List?> get thumbnail async => await entity.thumbnailData ;

  @override
  Future<String?> get mediaUrl => super.entity.getMediaUrl();

  @override
  String get id => super.entity.id;

  @override
  DateTime get modifiedDateTime => super.entity.modifiedDateTime;*/

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'duration': duration,
      'title': title,
      'thumbnail': thumbnail,
      'mediaUrl': mediaUrl,
      'modifiedDateTime': modifiedDateTime.millisecondsSinceEpoch,
    };
  }
}
