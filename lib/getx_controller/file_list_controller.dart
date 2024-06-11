import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:source_video_player/cache/media_data_cache.dart';
import 'package:source_video_player/cache/mmkv_cache.dart';
import 'package:source_video_player/common/cache_constants.dart';
import 'package:source_video_player/model/directory_model.dart';
import 'package:source_video_player/model/file_model.dart';
import 'package:source_video_player/utils/file_directory_utils.dart';

/// 文件列表
class FileListController extends GetxController {
  Logger logger = Logger();
  var title = "文件列表".obs;
  var loading = true.obs;
  var params = <String, dynamic>{}.obs;
  var fileList = <FileModel>[].obs;
  var dirPath = "".obs;
  String path = "";
  DirectorySourceType directorySourceType = DirectorySourceType.localDirectory;

  @override
  void onInit() {
    super.onInit();
  }

  void getFileList(Map<String, dynamic> map) {
    params(map);
    logger.d("传入的参数：");
    logger.d(params);
    dirPath(params["dirName"]);
    directorySourceType = DirectorySourceType.localDirectory;
    path = params["path"];
    title(params["title"]);
    getVideoFileList();
    // loading(false);
  }

  // 加载文件列表
  Future<void> getVideoFileList() async {
    try {
      loading(true);
      fileList.clear();
      switch (directorySourceType) {
        case DirectorySourceType.playDirectory:
          if (MediaDataCache.playFileListMap
                  .containsKey(CacheConst.cachePrev + path) &&
              MediaDataCache.playFileListMap[CacheConst.cachePrev + path] !=
                  null &&
              MediaDataCache
                  .playFileListMap[CacheConst.cachePrev + path]!.isNotEmpty) {
            fileList.addAll(
                MediaDataCache.playFileListMap[CacheConst.cachePrev + path] ??
                    []);
          } else {
            /// 从存储中获取播放文件列表（path相当于key）
            String? playFileListJson = PlayListDataStoreCache.getInstance()
                .getString(CacheConst.cachePrev + path);
            if (playFileListJson != null && playFileListJson.isNotEmpty) {
              /// 转换为list
              fileList.assignAll(fileModelListFromJson(playFileListJson));
              fileList.sort((FileModel a, FileModel b) {
                return a.fullName
                    .toLowerCase()
                    .compareTo(b.fullName.toLowerCase());
              });
            }
            MediaDataCache.playFileListMap[CacheConst.cachePrev + path] =
                fileList;
          }
          for (var element in fileList) {
            element.fileSourceType = FileSourceType.playListFile;
            element.directory = CacheConst.cachePrev + path;
            element.danmakuPath = DanmakuDataStoreCache.getInstance()
                .getString(CacheConst.cachePrev + element.path);
          }
          break;

        case DirectorySourceType.localDirectory:
          var fileList = await FileDirectoryUtils.getFileListByPath(
              path: path, fileFormat: FileFormat.video);
          if (fileList.isNotEmpty) {
            for (var element in fileList) {
              element.danmakuPath = DanmakuDataStoreCache.getInstance()
                      .getString(CacheConst.cachePrev + element.path) ??
                  "";
            }
            this.fileList.assignAll(fileList);
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
      PlayListDataStoreCache.getInstance()
          .setString(fileModel.directory, fileModelListToJson(fileList));
    }
    return remove;
  }
}
