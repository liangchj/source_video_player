
import 'dart:typed_data';

abstract class PlatformAssetEntity<T> {
  String get title;
  int get duration;

  Future<Uint8List?> get thumbnail;
}