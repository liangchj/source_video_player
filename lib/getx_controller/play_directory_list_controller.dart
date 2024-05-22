
import 'package:get/get.dart';
import 'package:source_video_player/cache/media_data_cache.dart';
import 'package:source_video_player/cache/mmkv_cache.dart';
import 'package:source_video_player/common/cache_constants.dart';
import 'package:source_video_player/model/directory_model.dart';
import 'package:source_video_player/model/file_model.dart';

/// 播放目录列表Controller
class PlayDirectoryListController extends GetxController {
  var loading = true.obs;
  var directoryList = <DirectoryModel>[].obs;
  var createNewPlayDirectoryName = ''.obs;
  var createNewPlayDirectoryErrorText = ''.obs;


  /// 获取播放目录列表
  void getVideoPlayDirectoryList() async {
    try {
      loading(true);
      if (MediaDataCache.playDirectoryList.isNotEmpty) {
        directoryList.clear();
        directoryList.addAll(MediaDataCache.playDirectoryList);
      } else {
        /// 从存储中获取播放目录列表
        String? playDirectoryListJson = PlayListDataStoreCache.getInstance().getString(CacheConst.playDirectoryList);
        if (playDirectoryListJson != null && playDirectoryListJson.isNotEmpty) {
          /// 转换为list
          directoryList.assignAll(directoryModelListFromJson(playDirectoryListJson));
          directoryList.sort((DirectoryModel a, DirectoryModel b) {
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });
        }
      }
    } finally {
      loading(false);
    }
  }

  /// 新增播放目录
  String? addVideoPlayDirectory(DirectoryModel playDirectoryModel) {
    String? msg;
    for (var item in directoryList) {
      if (item.name == playDirectoryModel.name) {
        msg = "播放目录已存在";
        createNewPlayDirectoryErrorText.value = msg;
        break;
      }
    }
    if (msg == null || msg.isEmpty) {
      /// 添加到列表
      directoryList.add(playDirectoryModel);
      /// 重新排序
      reorder();
      /// 刷新
      // directoryList.refresh();
      saveVideoPlayDirectoryToStorage();
    }
    return msg;
  }
  /// 删除播放目录
  void removeVideoPlayDirectory(DirectoryModel playDirectoryModel) {
    bool isChange = false;
    for (var item in directoryList) {
      if (item.name == playDirectoryModel.name) {
        directoryList.remove(item);
        isChange = true;
        break;
      }
    }
    if (isChange) {
      saveVideoPlayDirectoryToStorage();
    }
  }
  /// 移除视频
  void removeVideoFromPlayDirectory(String directory) {
    print("directory:$directory");
    for(DirectoryModel directoryModel in directoryList) {
      print("directoryModel.name: ${directoryModel.name}");
      if (CacheConst.cachePrev + directoryModel.name == directory) {
        directoryModel.fileNumber -= 1;
        break;
      }
    }
    directoryList.refresh();
    MediaDataCache.playDirectoryList = directoryList;
    saveVideoPlayDirectoryToStorage();
  }
  /// 排序
  void reorder() {
    /// 重新排序
    directoryList.sort((DirectoryModel a, DirectoryModel b) {
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    directoryList.refresh();
  }

  /// 转换为字符串存入内存
  void saveVideoPlayDirectoryToStorage() {
    /// 转换为字符串存入内存
    PlayListDataStoreCache.getInstance().setString(CacheConst.playDirectoryList, directoryModelListToJson(directoryList));
  }

  /// 添加视频到播放目录
  String addVideoToPlayDirectory(DirectoryModel playDirectoryModel, FileModel fileModel) {
    String msg = "";
    String dirName = playDirectoryModel.name;
    List<FileModel> videoFileList = [];
    if (MediaDataCache.playFileListMap.containsKey(CacheConst.cachePrev + dirName)) {
      videoFileList = MediaDataCache.playFileListMap[CacheConst.cachePrev + dirName] ?? [];
    } else {
      // 从存储中获取播放文件列表（path相当于key）
      String? playFileListJson = PlayListDataStoreCache.getInstance().getString(CacheConst.cachePrev + dirName);
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
  }
  /// 执行添加到播放列表和存入存储中
  String handleAddAndSaveToPlayDirectory(DirectoryModel playDirectoryModel, String dirName, List<FileModel> videoFileList, FileModel fileModel) {
    String msg = "";
    videoFileList.add(fileModel);
    videoFileList.sort((FileModel a, FileModel b) {
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    playDirectoryModel.fileNumber = videoFileList.length;
    MediaDataCache.playFileListMap[CacheConst.cachePrev + dirName] = videoFileList;
    msg = "视频已添加到“$dirName”列表";
    PlayListDataStoreCache.getInstance().setString(CacheConst.cachePrev + dirName, fileModelListToJson(videoFileList));
    saveVideoPlayDirectoryToStorage();
    return msg;
  }

}