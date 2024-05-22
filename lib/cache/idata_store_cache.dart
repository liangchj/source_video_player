
abstract class IDataStoreCache {
  setString(String key, String value);

  setBool(String key, bool value);

  setInt(String key, int value);

  setDouble(String key, double value);

  setInt32(String key, int value);

  setIntList(String key, List<int> list);

  setStringList(String key, List<String> list);

  Object? get<T>(String key, CacheType type);
  bool? getBool(String key);
  List<String>? getStringList(String key);
  String? getString(String key);
  double? getDouble(String key);
  int? getInt(String key);
  int? getInt32(String key);
  String? getBytesConvert(String key);
  removeKey(String key);
  removeKeyList(List<String> keyList);
}

enum CacheType { int, int32, double, string, bool, bytes, bytesConvert, intList, stringList }