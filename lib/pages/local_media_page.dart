import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_video_player/getx_controller/Local_media_controller.dart';
import 'package:source_video_player/model/directory_model.dart';
import 'package:source_video_player/route/app_routes.dart';
import 'package:source_video_player/widgets/directory_item_widget.dart';

/// 本地媒体列表
class LocalMediaPage extends GetView<LocalMediaController> {
  const LocalMediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.title),
        actions: [
          IconButton(
              onPressed: () => {}, icon: const Icon(Icons.search_rounded)),
          IconButton(
              onPressed: () => {
                    if (!controller.loading.value)
                      {controller.getLocalVideoDirectoryList()}
                  },
              icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          var videoDirectoryList = controller.localDirectoryList;
          return videoDirectoryList.isEmpty
              ? const Center(
                  child: Text("没有视频"),
                )
              : Scrollbar(
                  child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 14.0),
                      itemExtent: 66,
                      itemCount: videoDirectoryList.length,
                      itemBuilder: (context, index) {
                        var fileDirectoryModel = videoDirectoryList[index];
                        return DirectoryItemWidget(
                            directoryModel: fileDirectoryModel,
                            onTap: () {
                              Map<String, dynamic> params = {
                                "path": fileDirectoryModel.path,
                                "title": "本地播放列表",
                                "directorySourceType":
                                    DirectorySourceType.localDirectory,
                                "dirName":
                                    fileDirectoryModel.path.split("/").last
                              };
                              Get.toNamed(AppRoutes.fileListPage,
                                  arguments: params);
                            });
                      }));
        }
      }),
    );
  }
}
