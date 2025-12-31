
import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';
import 'package:source_video_player/platform/platform_asset_entity.dart';

class AssetEntityModel extends PlatformAssetEntity<AssetEntity> {
  final AssetEntity assetEntity;

  AssetEntityModel({required this.assetEntity});

  @override
  int get duration => throw UnimplementedError();

  @override
  // TODO: implement title
  String get title => throw UnimplementedError();

  @override
  Future<Uint8List?> get thumbnail async => await assetEntity.thumbnailData ;
}