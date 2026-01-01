
import 'dart:typed_data';

abstract class PlatformAssetEntity<T> {
  String get title;
  int get duration;

  final T entity;

  PlatformAssetEntity({required this.entity});

  Future<Uint8List?> get thumbnail;

  Future<String?> get mediaUrl;

  String get id;
}