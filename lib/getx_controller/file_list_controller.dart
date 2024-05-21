
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:source_video_player/cache/media_data_cache.dart';
import 'package:source_video_player/common/cache_constants.dart';
import 'package:source_video_player/model/directory_model.dart';
import 'package:source_video_player/model/file_model.dart';
import 'package:source_video_player/utils/file_directory_utils.dart';

/// 文件列表
class FileListController extends GetxController {
  Logger logger = Logger();
  var loading = true.obs;
  var params = <String, dynamic>{}.obs;
  var fileList = <FileModel>[].obs;

  @override
  void onInit() {
    loading(true);
    super.onInit();
  }

  void getFileList(Map<String, dynamic> map) {
    params(map);
    logger.d("传入的参数：");
    logger.d(params);
    getVideoFileList(params["path"], DirectorySourceType.localDirectory);
    // loading(false);
  }


  // 加载文件列表
  Future<void> getVideoFileList(String path, DirectorySourceType directorySourceType) async {
    try {
      loading(true);
      fileList.clear();
      switch (directorySourceType) {
        case DirectorySourceType.localDirectory:
          if (MediaDataCache.playFileListMap.containsKey(CacheConst.cachePrev + path)) {
            fileList.addAll(MediaDataCache.playFileListMap[CacheConst.cachePrev + path] ?? []);
          } else {
            /// 从存储中获取播放文件列表（path相当于key）
            String? playFileListJson = null;// PlayListDataStoreCache.getInstance().getString(CacheConst.cachePrev + path);
            if (playFileListJson != null && playFileListJson.isNotEmpty) {
              /// 转换为list
              fileList.assignAll(fileModelListFromJson(playFileListJson));
              fileList.sort((FileModel a, FileModel b) {
                return a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
              });
            }
            MediaDataCache.playFileListMap[CacheConst.cachePrev + path] = fileList;
          }
          for (var element in fileList) {
            element.fileSourceType = FileSourceType.playListFile;
            element.directory = CacheConst.cachePrev + path;
            // element.barragePath = DanmakuDataStoreCache.getInstance().getString(CacheConst.cachePrev + element.path);
          }
          break;

        case DirectorySourceType.playDirectory:
          var fileList = await FileDirectoryUtils.getFileListByPath(path: path, fileFormat: FileFormat.video);
          if (fileList.isNotEmpty) {
            for (var element in fileList) {
              // element.barragePath = DanmakuDataStoreCache.getInstance().getString(CacheConst.cachePrev + element.path);
            }
            fileList.assignAll(fileList);
          }
          break;
      }

    } catch (e) {
      logger.e("获取失败：$e");
    } finally {
      loading(false);
    }
  }

  /// 排序
  void reorder() {
    fileList.sort((FileModel a, FileModel b) {
      return a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
    });
    fileList.refresh();
  }

  /// 从播放列表中移除视频
  bool removeFileFromPlayDirectory(FileModel fileModel) {
    bool remove = fileList.remove(fileModel);
    if (remove) {
      MediaDataCache.playFileListMap[fileModel.directory] = fileList;
      // PlayListDataStoreCache.getInstance().setString(fileModel.directory, fileModelListToJson(fileList));
    }
    return remove;
  }

}