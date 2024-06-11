import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_jin_player/flutter_jin_player.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:source_video_player/model/file_model.dart';

class PlayController extends GetxController {
  Logger logger = Logger();
  // 仅支持全屏播放
  bool onlyFullScreenPlay = false;
  ResourceItem? resourceItem;
  List<ResourceChapterItem>? resourceChapterList;
  var canPop = true.obs;
  @override
  void onInit() {
    Map<String, dynamic> params = Get.arguments;
    onlyFullScreenPlay = params.isEmpty ||
            params["onlyFullScreenPlay"] == null ||
            params["onlyFullScreenPlay"] is! bool
        ? onlyFullScreenPlay
        : params["onlyFullScreenPlay"];
    if (onlyFullScreenPlay) {
      AutoOrientation.landscapeAutoMode();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
      canPop(false);
    }
    if (params.isNotEmpty &&
        params["fileModel"] != null &&
        params["fileModel"] is FileModel) {
      FileModel fileModel = params["fileModel"];
      resourceItem = ResourceItem(
          id: fileModel.path, name: fileModel.name, path: fileModel.path);
    }
    int index =
        params.isNotEmpty && params["index"] is int ? params["index"] : 0;
    if (params.isNotEmpty &&
        params["fileList"] != null &&
        params["fileList"] is List<FileModel>) {
      List<FileModel> list = params["fileList"];
      resourceChapterList = [];
      for (int i = 0; i < list.length; i++) {
        FileModel fileModel = list[i];
        ResourceItem item = ResourceItem(
            id: fileModel.path,
            name: fileModel.name,
            path: fileModel.path,
            danmakuSourceItem: DanmakuSourceItem(path: "assets/1.xml"));

        ResourceChapterItem chapterModel = ResourceChapterItem(
            resourceItem: item, index: i, activated: i == index);
        resourceChapterList?.add(chapterModel);
      }
    }
    logger.d("播放页面接收到的参数：$params");
    super.onInit();
  }

  /*@override
  void onClose() {
    AutoOrientation.portraitUpMode();
  }*/

  @override
  void dispose() {
    AutoOrientation.portraitUpMode();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  closePlayPage(bool didPop) {
    AutoOrientation.portraitUpMode();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
  }
}
