

import 'package:mmkv/mmkv.dart';
import 'package:objectbox/objectbox.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:source_video_player/storage/objectbox/objectbox_history_storage.dart';

import 'istorage.dart';
import 'mmkv_storage.dart';
import 'objectbox.g.dart';

class StorageService extends IStorage {
  static final StorageService _storage = StorageService._internal();
  factory StorageService() => _storage;
  StorageService._internal();
  static StorageService get storage => _storage;

  static late Store _objectBoxStore;

  static Future<void> init() async {
    await MMKV.initialize();
    storage.settings = MMKVCache(MMKV(MMKVMapID.settings.mmapID));
    storage.playList = MMKVCache(MMKV(MMKVMapID.playList.mmapID));
    storage.danmaku = MMKVCache(MMKV(MMKVMapID.danmaku.mmapID));
    storage.subtitle = MMKVCache(MMKV(MMKVMapID.subtitle.mmapID));

    _objectBoxStore = await openStore(
      directory: p.join(
          (await getApplicationDocumentsDirectory()).path,
          "objectbox-storage"
      ),
    );
    storage.playHistory = ObjectBoxHistoryStorage(store: _objectBoxStore);
  }


  static void close() {
    storage.settings.storage.close();
    storage.playList.storage.close();
    storage.playHistory.storage.close();
    storage.danmaku.storage.close();
    storage.subtitle.storage.close();

    _objectBoxStore.close();
  }

  @override
  void dispose() {
    close();
  }
 }