
import 'package:flutter_player_ui/flutter_player_ui.dart';

import '../route/locator.dart';

class PlayerStorage extends PlayerDataStorage {
  @override
  Future<void> save(String key, value) {
    return locator<PlayerStorage>().save(key, value);
  }
  @override
  Future get(String key) {
    // TODO: implement get
    throw UnimplementedError();
  }
  @override
  Future<void> delete(String key) {
    // TODO: implement delete
    throw UnimplementedError();
  }


  @override
  Future<void> savePlayHistory(String videoId, PlayHistoryModel historyModel) {
    // TODO: implement savePlayHistory
    throw UnimplementedError();
  }


  @override
  Future<PlayHistoryModel> getPlayHistory(String videoId) {
    // TODO: implement getPlayHistory
    throw UnimplementedError();
  }

  @override
  Future<void> deletePlayHistory(String videoId) async {

  }


  @override
  Future<void> saveSetting(String key, value) {
    // TODO: implement saveSetting
    throw UnimplementedError();
  }

  @override
  Future getSetting(String key) {
    // TODO: implement getSetting
    throw UnimplementedError();
  }


  @override
  Future<void> deleteSetting(String key) {
    // TODO: implement deleteSetting
    throw UnimplementedError();
  }

}