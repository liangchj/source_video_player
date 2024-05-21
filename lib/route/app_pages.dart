
import 'package:get/get.dart';
import 'package:source_video_player/route/app_routes.dart';

import '../main.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.index, page: () => const SourceVideoPlayerApp()),
    /*GetPage(
        name: AppRoutes.localMediaPage,
        page: () => const LocalMediaPage(),
        binding: BindingsBuilder(() => Get.lazyPut(() => LocalMediaController()))),
    GetPage(
        name: AppRoutes.fileListPage,
        page: () => FileListPage(),
        binding: BindingsBuilder(() => Get.lazyPut(() => FileListController())))*/
  ];
}
