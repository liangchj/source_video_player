import 'package:signals/signals.dart';
import 'package:source_video_player/route/locator.dart';
import 'package:source_video_player/utils/logger_utils.dart';

import '../cache/media_library_play_list_cache.dart';
import '../models/app_directory_model.dart';
import '../models/loading_state_model.dart';
import '../storage/storage_keys.dart';
import 'base_view_model.dart';

class MediaLibraryPlayListViewModel extends BaseViewModel {

  late final Signal<LoadingStateModel> loadingState;
  final Signal<List<AppDirectoryModel>> playDirectoryList = Signal([]);


  @override
  void init() {
    getPlayDirectoryList();
  }

  void initData() {
    loadingState = Signal(LoadingStateModel());
  }

  @override
  void dispose() {
    loadingState.dispose();
    playDirectoryList.dispose();
  }

  /// 获取播放目录列表
  void getPlayDirectoryList() async {
    try {
      loadingState.value = loadingState.value.copyWith(
        loading: true,
        loadedSuc: false,
        errorMsg: null,
        isRefresh: false,
        data: null,
      );
      if (MediaLibraryPlayListCache.loadedPlayDirectoryList) {
        playDirectoryList.value.clear();
        playDirectoryList.value.addAll(
          MediaLibraryPlayListCache.playDirectoryList,
        );
      } else {
        /// 从存储中获取播放目录列表
        List<AppDirectoryModel>? list = await storage.playList
            .getStringToObject<AppDirectoryModel>(
              StorageKeys.playList,
              AppDirectoryModel.fromJson,
            );
        if (list != null && list.isNotEmpty) {
          list.sort((a, b) {
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });
          playDirectoryList.value.addAll(list);
          MediaLibraryPlayListCache.playDirectoryList = list;
        }
      }
    } finally {
      loadingState.value = loadingState.value.copyWith(
        loading: false,
        loadedSuc: true,
        errorMsg: null,
        isRefresh: false,
        data: null,
      );
    }
  }

  /// 新增播放目录
  String? addPlayDirectory(AppDirectoryModel playDirectoryModel) {
    String? msg;
    for (var item in playDirectoryList.value) {
      if (item.name == playDirectoryModel.name) {
        msg = "播放目录已存在";
        return msg;
      }
    }
    if (msg == null || msg.isEmpty) {
      int insertIndex = 0;
      String lowerName = playDirectoryModel.name.toLowerCase();
      for (int i = 0; i < playDirectoryList.value.length; i++) {
        if (playDirectoryList.value[i].name.toLowerCase().compareTo(lowerName) >
            0) {
          insertIndex = i;
          break;
        }
        insertIndex = i + 1;
      }
      playDirectoryList.insert(insertIndex, playDirectoryModel);
      // 保存播放目录列表
      savePlayDirectoryToStorage();
    }
    return msg;
  }

  /// 删除播放目录
  void removePlayDirectory(AppDirectoryModel playDirectoryModel) {
    bool isChange = false;
    for (var item in playDirectoryList.value) {
      if (item.name == playDirectoryModel.name) {
        playDirectoryList.remove(item);
        isChange = true;
        break;
      }
    }
    if (isChange) {
      savePlayDirectoryToStorage();
    }
  }

  /// 转换为字符串存入内存
  void savePlayDirectoryToStorage() {
    /// 转换为字符串存入内存
    storage.playList.saveObjectList<AppDirectoryModel>(
      StorageKeys.playList,
      playDirectoryList.value,
      listToJson: appDirectoryModelListToJson,
    );
    MediaLibraryPlayListCache.playDirectoryList = playDirectoryList.value;
  }

  /// 排序
  void reorder() {
    /// 重新排序
    playDirectoryList.sort((a, b) {
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  }

  /// 重命名
  String? renamePlayDirectoryFile(
    AppDirectoryModel playDirectoryModel,
    String newName,
    int index,
  ) {
    String? errorText;
    try {
      if (playDirectoryList.value.length < index) {
        errorText = "目录位置不对或已不存在";
        return errorText;
      }
      int i = playDirectoryList.indexOf(playDirectoryModel);
      if (i != index) {
        errorText = "目录位置不对";
        return errorText;
      }
      for (var j = 0; j < playDirectoryList.value.length; j++) {
        if (playDirectoryList.value[j].name == newName && j != i) {
          errorText = "目录已存在";
          return errorText;
        }
      }

      playDirectoryModel.name = newName;
      playDirectoryList[i] = playDirectoryModel;
      savePlayDirectoryToStorage();
    } catch (e) {
      errorText = "重命名播放列表中的目录名称失败：$e";
      LoggerUtils.logger.e("重命名播放列表中的目录名称失败：$e");
    }
    return errorText;
  }


  /// 添加视频到播放目录
  /*String addVideoToPlayDirectory(AppDirectoryModel playDirectoryModel, FileModel fileModel) {
    String msg = "";
    String dirName = playDirectoryModel.name;
    List<FileModel> videoFileList = [];
    if (MediaData.playFileListMap.containsKey(CacheConst.cachePrev + dirName)) {
      videoFileList = MediaData.playFileListMap[CacheConst.cachePrev + dirName] ?? [];
    } else {
      // 从存储中获取播放文件列表（path相当于key）
      String? playFileListJson = PlayListMMKVCache.getInstance().getString(CacheConst.cachePrev + dirName);
      if (playFileListJson != null && playFileListJson.isNotEmpty) {
        /// 转换为list
        videoFileList.assignAll(fileModelListFromJson(playFileListJson));
      }
    }
    if (videoFileList.isNotEmpty) {
      bool exists = false;
      for (FileModel element in videoFileList) {
        if (element.name == fileModel.name) {
          exists = true;
          break;
        }
      }
      if (exists) {
        msg = "视频已经存在于“$dirName”列表中";
      } else {
        msg = handleAddAndSaveToPlayDirectory(playDirectoryModel, dirName, videoFileList, fileModel);
      }
    } else {
      msg = handleAddAndSaveToPlayDirectory(playDirectoryModel, dirName, videoFileList, fileModel);
    }
    return msg;
  }*/
}
