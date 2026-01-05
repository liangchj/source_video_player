abstract class IStorage {
  void dispose();

  late IBaseStorage settings;
  late IBaseStorage playList;
  late IBaseStorage danmaku;
  late IBaseStorage subtitle;
  late IBaseStorage playHistory;
}

abstract class IBaseStorage {
  dynamic get storage;
  Future<bool> save(String key, dynamic value, {bool nullRemove = true});
  // 对象保存 - 使用泛型
  Future<bool> saveObject<T>(
    String key,
    T value,
    String Function(T) toJson, {
    bool nullRemove = true,
  });

  Future<String?> getString(String key);
  Future<int?> getInt(String key);
  Future<double?> getDouble(String key);
  Future<bool?> getBool(String key);

  // 字符串转对象方法 - 使用泛型
  Future<T?> getStringToObject<T>(String key, T Function(String) fromJson);

  Future<void> remove(String key);
  Future<void> clear();

  Future<bool> saveList(String key, List<dynamic> value);
  Future<List<dynamic>?> getList(String key);
}
