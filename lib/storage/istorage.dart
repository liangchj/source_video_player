abstract class IStorage {
  Future<void> init();
  late IBaseStorage settings;
  late IBaseStorage playList;
  late IBaseStorage danmaku;
  late IBaseStorage subtitle;
  late IHistoryStorage playHistory;
}

abstract class IBaseStorage {
  dynamic get storage;
  void close();
  Future<bool> save(String key, dynamic value, {bool nullRemove = true});
  // 对象保存 - 使用泛型
  Future<bool> saveObject<T>(
    String key,
    T value,
    String Function(T) toJson, {
    bool nullRemove = true,
  });

  Future<bool> saveObjectList<T>(
      String key,
      List<T>? value,
      {
        String Function(T)? toJson,
        String Function(List<T>)? listToJson,
        bool nullRemove = true,
      });
  Future<bool> saveList(String key, List<dynamic> value);

  Future<String?> getString(String key);
  Future<int?> getInt(String key);
  Future<double?> getDouble(String key);
  Future<bool?> getBool(String key);

  // 字符串转对象方法 - 使用泛型
  Future<List<T>?> getStringToObject<T>(String key, T Function(Map<String, dynamic>) fromJson);

  Future<List<dynamic>?> getList(String key);
  Future<T?> getObject<T>(String key);

  Future<void> remove(String key);
  Future<void> clear();

}


abstract class IHistoryStorage<T> extends IBaseStorage {
  Future<List<T>> getHistoryList({
    int page = 0,
    int pageSize = 20,
    String? filter,
  });
  Future<int> getHistoryCount();
}
