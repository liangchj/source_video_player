import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_video_player/getx_controller/media_library_controller.dart';
import 'package:source_video_player/widgets/loading_widget.dart';

class MediaLibraryPage extends StatefulWidget {
  const MediaLibraryPage({super.key});

  @override
  State<MediaLibraryPage> createState() => _MediaLibraryPageState();
}

class _MediaLibraryPageState extends State<MediaLibraryPage> {
  final MediaLibraryController controller = Get.put(MediaLibraryController());
  @override
  Widget build(BuildContext context) {
    return controller.pageInitiated.value
        ? ListView(
            children: controller.libraryList.map((e) => e).toList(),
          )
        : const LoadingWidget();
  }
}
