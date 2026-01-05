import 'dart:convert';

import 'package:mmkv/mmkv.dart';
import 'package:source_video_player/utils/logger_utils.dart';

import 'istorage.dart';

class MMKVStorage extends IStorage {
  static final MMKVStorage _storage = MMKVStorage._internal();
  factory MMKVStorage() => _storage;
  MMKVStorage._internal();
  static MMKVStorage get storage => _storage;

  static Future<void> init() async {
    await MMKV.initialize();
    storage.settings = MMKVCache(MMKV(MMKVMapID.settings.mmapID));
    storage.playList = MMKVCache(MMKV(MMKVMapID.playList.mmapID));
    storage.playHistory = MMKVCache(MMKV(MMKVMapID.playHistory.mmapID));
    storage.danmaku = MMKVCache(MMKV(MMKVMapID.danmaku.mmapID));
    storage.subtitle = MMKVCache(MMKV(MMKVMapID.subtitle.mmapID));
  }

  static void close() {
    storage.settings.storage.close();
    storage.playList.storage.close();
    storage.playHistory.storage.close();
    storage.danmaku.storage.close();
    storage.subtitle.storage.close();
  }

  @override
  void dispose() {
    close();
  }
}

class MMKVCache extends IBaseStorage {
  final MMKV _mmkv;
  MMKVCache(this._mmkv);

  @override
  MMKV get storage => _mmkv;

  @override
  Future<bool> save(String key, dynamic value, {bool nullRemove = true}) async {
    if (key.isEmpty) {
      return false;
    }

    try {
      if (value == null) {
        if (nullRemove) {
          _mmkv.removeValue(key);
          return true; // 删除成功也算执行成功
        } else {
          return false;
        }
      }
      if (value is int) {
        return _mmkv.encodeInt(key, value);
      } else if (value is double) {
        return _mmkv.encodeDouble(key, value);
      } else if (value is String) {
        return _mmkv.encodeString(key, value);
      } else if (value is bool) {
        return _mmkv.encodeBool(key, value);
      } else if (value is List<int>) {
        var bytes = MMBuffer.fromList(value);
        return _mmkv.encodeBytes(key, bytes);
      } else if (value is List<dynamic> || value is Map<dynamic, dynamic>) {
        var str = jsonEncode(value);
        return _mmkv.encodeString(key, str);
      }
      return false;
    } catch (e, stackTrace) {
      // 捕获所有异常，避免上层崩溃，并可打印日志便于调试
      LoggerUtils.logger.e(
        "MMKV save failed! key: $key, value: $value, error: $e, stack: $stackTrace",
      );
      return false;
    }
  }

  @override
  Future<bool> saveObject<T>(
    String key,
    T value,
    String Function(T) toJson, {
    bool nullRemove = true,
  }) async {
    if (key.isEmpty) return false;
    try {
      // 和save方法保持一致：value为null时删除key
      if (value == null) {
        if (nullRemove) {
          _mmkv.removeValue(key);
          return true; // 删除成功也算执行成功
        } else {
          return false;
        }
      }
      var jsonStr = toJson(value);
      return _mmkv.encodeString(key, jsonStr);
    } catch (e, stackTrace) {
      LoggerUtils.logger.e(
        "MMKV saveObject failed! key: $key, error: $e, stack: $stackTrace",
      );
      return false;
    }
  }

  @override
  Future<String?> getString(String key) async {
    return _mmkv.decodeString(key);
  }

  @override
  Future<int?> getInt(String key) async {
    return _mmkv.decodeInt(key);
  }

  @override
  Future<double?> getDouble(String key) async {
    return _mmkv.decodeDouble(key);
  }

  @override
  Future<bool?> getBool(String key) async {
    return _mmkv.decodeBool(key);
  }

  @override
  Future<T?> getStringToObject<T>(
    String key,
    T Function(String) fromJson,
  ) async {
    if (key.isEmpty) {
      return null;
    }
    var value = _mmkv.decodeString(key);
    if (value == null || value.isEmpty) {
      return null;
    } else {
      return fromJson(value);
      /*try {
        return fromJson(value);
      } catch (e, stackTrace) {
        LoggerUtils.logger.e(
          "MMKV getStringToObject failed! key: $key, error: $e, stack: $stackTrace",
        );
        return null;
      }*/
    }
  }

  @override
  Future<void> remove(String key) async {
    _mmkv.removeValue(key);
  }

  @override
  Future<void> clear() async {
    _mmkv.clearAll(keepSpace: true);
  }

  @override
  Future<bool> saveList(String key, List<dynamic> value) async {
    var str = jsonEncode(value);
    return _mmkv.encodeString(key, str);
  }

  @override
  Future<List<dynamic>?> getList(String key) async {
    var value = _mmkv.decodeString(key);
    if (value == null) {
      return null;
    }
    return jsonDecode(value);
  }
}

enum MMKVMapID {
  settings("settings"),
  playList("playList"),
  danmaku("danmaku"),
  subtitle("subtitle"),
  playHistory("playHistory");

  final String mmapID;
  const MMKVMapID(this.mmapID);
}

enum MMKVType { int, int32, double, string, bool, bytes, bytesConvert, intList }
