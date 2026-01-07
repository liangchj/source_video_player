import 'package:objectbox/objectbox.dart';
import 'package:source_video_player/storage/istorage.dart';

import '../../utils/logger_utils.dart';
import '../objectbox.g.dart';
import 'models/history_model.dart';

class ObjectBoxHistoryStorage extends IBaseStorage {
  final Store store;
  ObjectBoxHistoryStorage({required this.store}) {
    _histories = store.box<HistoryModel>();
  }
  late Box<HistoryModel> _histories;

  @override
  Box<HistoryModel> get storage => _histories;

  @override
  Future<bool> save(String key, dynamic value, {bool nullRemove = true}) async {
    if (key.isEmpty) {
      return false;
    }
    try {
      if (value == null) {
        if (nullRemove) {
          var query = storage
              .query(HistoryModel_.databaseId.equals(key))
              .build();
          var findFirst = query.findFirst();
          if (findFirst != null) {
            storage.remove(findFirst.id);
          }
          query.close();
          return true; // 删除成功也算执行成功
        } else {
          return false;
        }
      }
      if (value is HistoryModel) {
        var id = storage.put(value);
        return id != 0;
      }
      throw "传入的数据类型不是HistoryModel";
    } catch (e, stackTrace) {
      // 捕获所有异常，避免上层崩溃，并可打印日志便于调试
      LoggerUtils.logger.e(
        "ObjectBoxHistoryStorage save failed! key: $key, value: $value, error: $e, stack: $stackTrace",
      );
      return false;
    }
  }

  @override
  Future<void> clear() async {
    storage.removeAll();
  }

  @override
  Future<bool?> getBool(String key) {
    throw Exception("播放历史没有boolean类型");
  }

  @override
  Future<double?> getDouble(String key) {
    throw Exception("播放历史没有double类型");
  }

  @override
  Future<int?> getInt(String key) {
    throw Exception("播放历史没有int类型");
  }

  @override
  Future<List?> getList(String key) {
    throw Exception("播放历史没有List类型");
  }

  @override
  Future<String?> getString(String key) {
    throw Exception("播放历史没有String类型");
  }

  @override
  Future<List<T>?> getStringToObject<T>(
    String key,
    T Function(Map<String, dynamic> p1) fromJson,
  ) {
    throw Exception("播放历史没有List<T>类型");
  }

  @override
  Future<HistoryModel?> getObject<HistoryModel>(String key) async {
    var query = storage.query(HistoryModel_.databaseId.equals(key)).build();
    HistoryModel? model = query.findFirst() as HistoryModel?;
    query.close();
    return model;
  }

  @override
  Future<void> remove(String key) async {
    var query = storage.query(HistoryModel_.databaseId.equals(key)).build();
    var findFirst = query.findFirst();
    if (findFirst != null) {
      storage.remove(findFirst.id);
    }
    query.close();
  }

  @override
  Future<bool> saveList(String key, List value) {
    throw Exception("播放历史没有saveList");
  }

  @override
  Future<bool> saveObject<T>(
    String key,
    T value,
    String Function(T p1) toJson, {
    bool nullRemove = true,
  }) {
    throw Exception("播放历史没有saveObject");
  }

  @override
  Future<bool> saveObjectList<T>(
    String key,
    List<T>? value, {
    String Function(T p1)? toJson,
    String Function(List<T> p1)? listToJson,
    bool nullRemove = true,
  }) {
    throw Exception("播放历史没有saveObjectList");
  }
}
