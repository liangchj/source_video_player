import 'dart:convert';

import 'package:mmkv/mmkv.dart';
import 'package:source_video_player/cache/idata_store_cache.dart';


/// 等待MMKV初始化
class MMKVCacheInit {
  static bool initialize = false;

  MMKVCacheInit._() {
    init();
  }

  MMKVCacheInit._setInitialize(bool flag) {
    initialize = flag;
  }

  static Future<bool> preInit() async {
    if (!initialize) {
      // var initialize = await MMKV.initialize();
      MMKVCacheInit._setInitialize(true);
    }
    return initialize;
  }

  Future<void> init() async {
    // var initialize = await MMKV.initialize();
  }
}

abstract class MMKVDataCacheBase extends IDataStoreCache {
  setBytes(String key, MMBuffer value);
  MMBuffer? getBytes(String key);
}

class MMKVCache extends MMKVDataCacheBase {
  final MMKV _mmkv;
  MMKVCache(this._mmkv) {
    MMKVCacheInit.preInit();
  }

  @override
  Object? get<T>(String key, CacheType type) {
    dynamic value;
    switch (type) {
      case CacheType.string:
        value = getString(key);
        break;
      case CacheType.bool:
        value = getBool(key);
        break;
      case CacheType.int:
        value = getInt(key);
        break;
      case CacheType.int32:
        value = getInt32(key);
        break;
      case CacheType.double:
        value = getDouble(key);
        break;
      case CacheType.bytes:
        value = getBytes(key);
        break;
      case CacheType.bytesConvert:
        value = getBytesConvert(key);
        break;
      case CacheType.stringList:
        value = getStringList(key);
        break;
      default:
        break;
    }
    return value;
  }

  @override
  List<String>? getStringList(String key) {
    var str = getString(key);
    List<String>? list;
    if (str != null && str.isNotEmpty) {
      try {
        var json = jsonEncode(str);
        if (json is List<String>) {
          list = json as List<String>?;
        }
      } catch (e) {
        list = null;
      }
    }
    return list;
  }

  @override
  bool? getBool(String key) {
    return _mmkv.decodeBool(key);
  }

  @override
  MMBuffer? getBytes(String key) {
    return _mmkv.decodeBytes(key);
  }

  @override
  String? getBytesConvert(String key) {
    MMBuffer? bytes = _mmkv.decodeBytes(key);
    if (bytes == null) {
      return null;
    }
    return const Utf8Decoder().convert(bytes.asList()!);
  }

  @override
  double? getDouble(String key) {
    return _mmkv.decodeDouble(key);
  }

  @override
  int? getInt(String key) {
    return _mmkv.decodeInt(key);
  }

  @override
  int? getInt32(String key) {
    return _mmkv.decodeInt32(key);
  }

  @override
  String? getString(String key) {
    return _mmkv.decodeString(key);
  }

  @override
  setBool(String key, bool value) {
    return _mmkv.decodeBool(key);
  }

  @override
  setBytes(String key, MMBuffer value) {
    return _mmkv.decodeBytes(key);
  }

  @override
  setDouble(String key, double value) {
    return _mmkv.decodeDouble(key);
  }

  @override
  setInt(String key, int value) {
    _mmkv.encodeInt(key, value);
  }

  @override
  setInt32(String key, int value) {
    _mmkv.encodeInt32(key, value);
  }

  @override
  setIntList(String key, List<int> list) {
    var bytes = MMBuffer.fromList(list);
    _mmkv.encodeBytes(key, bytes);
  }

  @override
  setString(String key, String value) {
    _mmkv.encodeString(key, value);
  }

  @override
  setStringList(String key, List<String> list) {
    var str = jsonEncode(list);
    setString(key, str);
  }

  @override
  removeKey(String key) {
    _mmkv.removeValue(key);
  }

  @override
  removeKeyList(List<String> keyList) {
    _mmkv.removeValues(keyList);
  }
}

/// 默认的MMKV
class DefaultDataStoreCache extends MMKVCache {
  DefaultDataStoreCache._() : super(MMKV.defaultMMKV());
  static final DefaultDataStoreCache _instance = DefaultDataStoreCache._();

  static MMKVCache getInstance() {
    return _instance;
  }
}

/// 播放列表MMKV
class PlayListDataStoreCache extends MMKVCache {
  PlayListDataStoreCache._() : super(MMKV(MMKVMapID.playList.mmapID));
  static final PlayListDataStoreCache _instance = PlayListDataStoreCache._();
  static MMKVCache getInstance() {
    return _instance;
  }
}

/// 播放历史MMKV
class PlayHistoryDataStoreCache extends MMKVCache {
  PlayHistoryDataStoreCache._() : super(MMKV(MMKVMapID.playHistory.mmapID));
  static final PlayHistoryDataStoreCache _instance =
      PlayHistoryDataStoreCache._();
  static MMKVCache getInstance() {
    return _instance;
  }
}

/// 弹幕MMKV
class DanmakuDataStoreCache extends MMKVCache {
  DanmakuDataStoreCache._() : super(MMKV(MMKVMapID.danmaku.mmapID));
  static final DanmakuDataStoreCache _instance = DanmakuDataStoreCache._();
  static MMKVCache getInstance() {
    return _instance;
  }
}

/// 字幕MMKV
class SubtitleDataStoreCache extends MMKVCache {
  SubtitleDataStoreCache._() : super(MMKV(MMKVMapID.subtitle.mmapID));
  static final SubtitleDataStoreCache _instance = SubtitleDataStoreCache._();
  static MMKVCache getInstance() {
    return _instance;
  }
}

enum MMKVMapID {
  playList("playList"),
  danmaku("danmaku"),
  subtitle("subtitle"),
  playHistory("playHistory");

  final String mmapID;
  const MMKVMapID(this.mmapID);
}
