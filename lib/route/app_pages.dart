import 'package:get/get.dart';
import 'package:source_video_player/getx_controller/Local_media_controller.dart';
import 'package:source_video_player/getx_controller/file_list_controller.dart';
import 'package:source_video_player/pages/file_list_page.dart';
import 'package:source_video_player/pages/local_media_page.dart';
import 'package:source_video_player/route/app_routes.dart';

import '../main.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.index, page: () => const SourceVideoPlayerApp()),
    GetPage(
        name: AppRoutes.localMediaPage,
        page: () => const LocalMediaPage(),
        binding:
            BindingsBuilder(() => Get.lazyPut(() => LocalMediaController()))),
    GetPage(
        name: AppRoutes.fileListPage,
        page: () => FileListPage(),
        binding:
            BindingsBuilder(() => Get.lazyPut(() => FileListController()))),
  ];
}
