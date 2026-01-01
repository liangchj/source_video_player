
import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';
import 'package:source_video_player/platform/platform_asset_entity.dart';

class AssetEntityModel extends PlatformAssetEntity<AssetEntity> {
  // @override
  // final AssetEntity assetEntity;

  AssetEntityModel({required super.entity});

  @override
  int get duration => entity.duration ?? 0;

  @override
  String get title => entity.title ?? '';

  @override
  Future<Uint8List?> get thumbnail async => await entity.thumbnailData ;

  @override
  Future<String?> get mediaUrl => super.entity.getMediaUrl();

  @override
  String get id => super.entity.id;

}