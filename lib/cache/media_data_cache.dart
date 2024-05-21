

import 'package:source_video_player/model/directory_model.dart';
import 'package:source_video_player/model/file_model.dart';

class MediaDataCache {

  // 本地播放目录列表
  static List<DirectoryModel> localDirectoryList = [];
  // 视频文件列表
  static Map<String, List<FileModel>> videoFileListMap = {};

  // 播放目录
  static List<DirectoryModel> playDirectoryList = [];
  // 播放目录文件
  static Map<String, List<FileModel>> playFileListMap = {};
}