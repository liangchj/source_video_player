import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jin_flutter_player/model/resource_model.dart';
import 'package:logger/logger.dart';
import 'package:source_video_player/model/file_model.dart';

class PlayController extends GetxController {
  Logger logger = Logger();
  // 仅支持全屏播放
  bool onlyFullScreenPlay = false;
  ResourceModel? resourceModel;
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
      canPop(false);
    }
    if (params.isNotEmpty &&
        params["fileModel"] != null &&
        params["fileModel"] is FileModel) {
      FileModel fileModel = params["fileModel"];
      resourceModel = ResourceModel(
          id: fileModel.path, name: fileModel.name, path: fileModel.path);
    }
    logger.d("播放页面接收到的参数：$params");
    super.onInit();
  }



  /*@override
  void onClose() {
    AutoOrientation.portraitUpMode();
  }

  @override
  void dispose() {
    super.dispose();
  }*/



  closePlayPage(bool didPop) {
    AutoOrientation.portraitUpMode();
  }
}
