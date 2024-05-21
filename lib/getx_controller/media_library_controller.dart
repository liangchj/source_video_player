
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_video_player/route/app_routes.dart';

class MediaLibraryController extends GetxController {
  var pageInitiated = false.obs;
  List<Widget> libraryList = [];

  @override
  void onInit() {
    initData();
    super.onInit();
  }

  void initData() {
    libraryList = [
      InkWell(
        onTap: () {
          Get.toNamed(AppRoutes.localMediaPage);
        },
        child: const ListTile(
          leading: Icon(Icons.phone_android_rounded),
          title: Text("本地媒体"),
        ),
      ),
      InkWell(
        onTap: () {
          Get.toNamed(AppRoutes.playListPage);
        },
        child: const ListTile(
          leading: Icon(Icons.playlist_play_rounded),
          title: Text("播放列表"),
        ),
      ),
    ];

    pageInitiated(true);
  }
}