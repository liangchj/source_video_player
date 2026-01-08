
import '../models/app_directory_model.dart';
import '../models/app_file_model.dart';
import '../view_model/media_library_play_list_view_model.dart';

class MediaLibraryPlayListCache {
  // 是否加载了本地播放目录列表
  static bool loadedLocalPlayDirectoryList = false;
  // 本地播放目录列表
  static List<AppDirectoryModel> localPlayDirectoryList = [];
  // 视频文件列表
  static Map<String, List<AppFileModel>> videoFileListMap = {};
  // 是否加载了播放目录列表
  static bool loadedPlayDirectoryList = false;
  // 播放目录
  static List<AppDirectoryModel> playDirectoryList = [];
  // 播放目录文件
  static Map<String, List<AppFileModel>> playFileListMap = {};
}