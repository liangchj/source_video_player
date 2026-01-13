import 'package:signals/signals.dart';
import 'package:source_video_player/route/locator.dart';
import 'package:source_video_player/utils/logger_utils.dart';

import '../cache/media_library_play_list_cache.dart';
import '../models/app_directory_model.dart';
import '../models/app_media_file_model.dart';
import '../models/loading_state_model.dart';
import '../models/play_video_storage_model.dart';
import '../storage/storage_keys.dart';
import 'base_view_model.dart';

class MediaLibraryPlayDirListViewModel extends BaseViewModel {
  final Signal<LoadingStateModel> loadingState = Signal(LoadingStateModel());
  final Signal<List<AppDirectoryModel>> playDirectoryList = Signal([]);
  MediaLibraryPlayDirListViewModel() {
    init();
  }

  @override
  void init() {
    getPlayDirectoryList();
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
        List<AppDirectoryModel>? list = await storage.settings
            .getStringToObject<AppDirectoryModel>(
              StorageKeys.playList,
              AppDirectoryModel.fromJson,
            );
        if (list != null && list.isNotEmpty) {
          list.sort((a, b) {
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });
          playDirectoryList.addAll(list);
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
      // 移出播放目录下的视频
      storage.playList.remove(playDirectoryModel.name);
      savePlayDirectoryToStorage();
    }
  }

  /// 转换为字符串存入内存
  void savePlayDirectoryToStorage() {
    /// 转换为字符串存入内存
    storage.settings.saveObjectList<AppDirectoryModel>(
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
  Future<String?> renamePlayDirectoryFile(
    AppDirectoryModel playDirectoryModel,
    String newName,
    int index,
  ) async {
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
      String oldName = playDirectoryModel.name;

      playDirectoryModel.name = newName;
      playDirectoryList[i] = playDirectoryModel;
      // 修改原播放目录下的视频
      // storage.playList.rename(oldName, newName);
      var videoListStr = await storage.playList.getString(oldName);
      if (videoListStr != null && videoListStr.isNotEmpty) {
        storage.playList.remove(oldName);
        storage.playList.save(newName, videoListStr);
      }
      savePlayDirectoryToStorage();
    } catch (e) {
      errorText = "重命名播放列表中的目录名称失败：$e";
      LoggerUtils.logger.e("重命名播放列表中的目录名称失败：$e");
    }
    return errorText;
  }

  /// 添加视频到播放目录
  Future<String> addVideoToPlayDirectory(
    AppDirectoryModel playDirectoryModel,
    AppMediaFileModel fileModel,
  ) async {
    String msg = "";
    String dirName = playDirectoryModel.name;

    List<PlayVideoStorageModel> videoFileList =
        await storage.playList.getStringToObject<PlayVideoStorageModel>(
          dirName,
          PlayVideoStorageModel.fromJson,
        ) ??
        [];
    int insertIndex = 0;
    if (videoFileList.isNotEmpty) {
      String lowerUrl = fileModel.fullFilePath!.toLowerCase();
      for (var item in videoFileList) {
        if (item.url.toLowerCase() == lowerUrl) {
          msg = "视频已经存在于“$dirName”列表中";
          return msg;
        }
      }

      for (int i = 0; i < videoFileList.length; i++) {
        if (videoFileList[i].url.toLowerCase().compareTo(lowerUrl) > 0) {
          insertIndex = i;
          break;
        }
        insertIndex = i + 1;
      }
    }
    PlayVideoStorageModel model = PlayVideoStorageModel(
      name: fileModel.fileName,
      url: fileModel.fullFilePath!,
      assetId: fileModel.assetEntity?.id,
    );

    videoFileList.insert(insertIndex, model);
    msg = "视频已添加到“$dirName”列表";
    int i = playDirectoryList.indexOf(playDirectoryModel);
    playDirectoryModel.fileNumber = videoFileList.length;
    playDirectoryList[i] = playDirectoryModel;
    savePlayDirectoryToStorage();

    await storage.playList.saveObjectList<PlayVideoStorageModel>(
      dirName,
      videoFileList,
      listToJson: playVideoStorageModelListToJson,
    );
    return msg;
  }
}
