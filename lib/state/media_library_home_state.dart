
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:source_video_player/route/app_pages.dart';

import '../route/app_router.dart';
import '../route/locator.dart';
import 'signals_base_state.dart';

class MediaLibraryHomeState extends SignalsBaseState {
  MediaLibraryHomeState() {
    init();
  }
  late final List<Widget> libraryList;
  @override
  void init() {
    libraryList = [
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
        InkWell(
          onTap: () {
            // appGoRouter.pushNamed(AppPages.localMediaLibraryPage);
            locator<AppRouter>().router.push(AppPages.localMediaLibraryPage);
            // Get.toNamed(AppRoutes.localMediaDirectoryList);
            // Get.to(() => LocalMediaDirectoryListPage());
          },
          child: const ListTile(
            leading: Icon(Icons.phone_android_rounded),
            title: Text("本地媒体"),
          ),
        ),
      InkWell(
        onTap: () {
          // Get.toNamed(AppRoutes.playDirectoryList);
        },
        child: const ListTile(
          leading: Icon(Icons.playlist_play_rounded),
          title: Text("播放列表"),
        ),
      ),
      InkWell(
        onTap: () {
          // Get.to(const DanPage());
          //Get.to(const DirtPage());
        },
        child: const ListTile(
          leading: Icon(Icons.stream_rounded),
          title: Text("串流播放"),
        ),
      ),
      InkWell(
        onTap: () {
          //Get.to(const AKDanmakuTest());
          // Get.to(const DirPage());
        },
        child: const ListTile(
          leading: Icon(Icons.boy_outlined),
          title: Text("磁力播放"),
        ),
      ),
    ];
  }
  @override
  void dispose() {
    // TODO: implement dispose
  }


}