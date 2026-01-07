import 'dart:convert';

import 'package:mmkv/mmkv.dart';
import 'package:source_video_player/utils/logger_utils.dart';

import 'istorage.dart';

/*class MMKVStorage extends IStorage {
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
}*/

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
          storage.removeValue(key);
          return true; // 删除成功也算执行成功
        } else {
          return false;
        }
      }
      if (value is int) {
        return storage.encodeInt(key, value);
      } else if (value is double) {
        return storage.encodeDouble(key, value);
      } else if (value is String) {
        return storage.encodeString(key, value);
      } else if (value is bool) {
        return storage.encodeBool(key, value);
      } else if (value is List<int>) {
        var bytes = MMBuffer.fromList(value);
        return storage.encodeBytes(key, bytes);
      } else if (value is List<dynamic> || value is Map<dynamic, dynamic>) {
        var str = jsonEncode(value);
        return storage.encodeString(key, str);
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
          storage.removeValue(key);
          return true; // 删除成功也算执行成功
        } else {
          return false;
        }
      }
      var jsonStr = toJson(value);
      return storage.encodeString(key, jsonStr);
    } catch (e, stackTrace) {
      LoggerUtils.logger.e(
        "MMKV saveObject failed! key: $key, error: $e, stack: $stackTrace",
      );
      return false;
    }
  }

  @override
  Future<bool> saveObjectList<T>(
      String key,
      List<T>? value,
      {
        String Function(T)? toJson,
        String Function(List<T>)? listToJson,
        bool nullRemove = true,
      }) async {
    assert(toJson != null || listToJson != null);
    if (key.isEmpty) return false;
    try {
      // 和save方法保持一致：value为null时删除key
      if (value == null || value.isEmpty) {
        if (nullRemove) {
          storage.removeValue(key);
          return true; // 删除成功也算执行成功
        } else {
          return false;
        }
      }
      String jsonStr = "";
      if (listToJson != null) {
        jsonStr = listToJson.call(value);
      }
      else if (toJson != null) {
        jsonStr = json.encode(List<dynamic>.from(value.map((x) => toJson.call(x))));
      }
      return storage.encodeString(key, jsonStr);
    } catch (e, stackTrace) {
      LoggerUtils.logger.e(
        "MMKV saveObjectList failed! key: $key, error: $e, stack: $stackTrace",
      );
      return false;
    }
  }

  @override
  Future<String?> getString(String key) async {
    return storage.decodeString(key);
  }

  @override
  Future<int?> getInt(String key) async {
    return storage.decodeInt(key);
  }

  @override
  Future<double?> getDouble(String key) async {
    return storage.decodeDouble(key);
  }

  @override
  Future<bool?> getBool(String key) async {
    return storage.decodeBool(key);
  }

  @override
  Future<List<T>?> getStringToObject<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    if (key.isEmpty) {
      return null;
    }
    var value = storage.decodeString(key);
    if (value == null || value.isEmpty) {
      return null;
    } else {
      var json = jsonDecode(value);
      List<T> list = [];
      for (var item in json) {
        list.add(fromJson.call(item));
      }
      return list;
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
  Future<T?> getObject<T>(String key) async {
    throw Exception("mmkv存储请使用带有fromJson的方法");
  }

  @override
  Future<void> remove(String key) async {
    storage.removeValue(key);
  }

  @override
  Future<void> clear() async {
    storage.clearAll(keepSpace: true);
  }

  @override
  Future<bool> saveList(String key, List<dynamic> value) async {
    var str = jsonEncode(value);
    return storage.encodeString(key, str);
  }

  @override
  Future<List<dynamic>?> getList(String key) async {
    var value = storage.decodeString(key);
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
