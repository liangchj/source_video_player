import 'package:flutter_player_ui/flutter_player_ui.dart';

import '../route/locator.dart';
import 'istorage.dart';
import 'objectbox/models/history_model.dart';

class PlayerStorage extends PlayerDataStorage {
  @override
  Future<bool> saveSetting<T>(
    String key,
    T value, {
    bool nullRemove = true,
    String Function(T)? toJson,
    String Function(List<T>)? listToJson,
  }) {
    IBaseStorage settings = storage.settings;
    if ((T is List<T>? || T is List<T>) &&
        (toJson != null || listToJson != null)) {
      return settings.saveObjectList<T>(
        key,
        value as List<T>?,
        toJson: toJson,
        listToJson: listToJson,
        nullRemove: nullRemove,
      );
    }
    if (toJson != null) {
      return settings.saveObject<T>(key, value, toJson, nullRemove: nullRemove);
    }
    if (value is List<T>) {
      return settings.saveList(key, value);
    }
    return settings.save(key, value, nullRemove: nullRemove);
  }

  @override
  Future getSetting<T>(String key) {
    IBaseStorage settings = storage.settings;
    if (T is List<T>?) {
      return settings.getList(key);
    } else if (T is int) {
      return settings.getInt(key);
    } else if (T is double) {
      return settings.getDouble(key);
    } else if (T is bool) {
      return settings.getBool(key);
    } else {
      return settings.getString(key);
    }
  }

  @override
  Future<void> deleteSetting(String key) async {
    storage.settings.remove(key);
  }

  @override
  Future<bool> savePlayHistory(String key, PlayHistoryModel historyModel) {
    HistoryModel history = HistoryModel.fromPlayHistoryModel(historyModel);
    // print("保存历史记录：${historyModel.key}, ${history.databaseId}:${historyModel.toJson()}");
    return storage.playHistory.save(history.databaseId, history);
  }

  @override
  Future<PlayHistoryModel?> getPlayHistory(String key) async {
    // return storage.playHistory.getObject(key);
    // print("获取播放历史：${key}");
    PlayHistoryModel? history;
    HistoryModel? model = await storage.playHistory.getObject(key);
    if (model != null) {
      history = model.toPlayHistoryModel();
      // print("获取播放历史：$key->${history.toJson()}");
    }
    return history;
  }

  @override
  Future<void> deletePlayHistory(String key) async {
    storage.playHistory.remove(key);
  }
}
