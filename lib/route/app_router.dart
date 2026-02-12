import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';

import '../models/app_directory_model.dart';
import '../models/app_media_file_model.dart';
import '../pages/api_select_list_page.dart';
import '../pages/bind_danmaku_page.dart';
import '../pages/home_page.dart';
import '../pages/media_library/local_media_directory_list_page.dart';
import '../pages/media_library/media_library_play_dir_list_page.dart';
import '../pages/media_library/media_list_page.dart';
import '../view_model/base_view_model.dart';
import '../view_model/net_resource_home_view_model.dart';
import 'app_pages.dart';

class AppRouter {
  late final GoRouter router;

  void initRouter() {
    router = GoRouter(
      initialLocation: AppPages.home,
      routes: [
        GoRoute(
          path: AppPages.home,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: AppPages.localMediaLibraryPage,
          builder: (context, state) => LocalMediaDirectoryListPage(),
        ),
        GoRoute(
          path: AppPages.mediaListPage,
          builder: (context, state) {
            AppDirectoryModel? folder;
            BaseViewModel? dirListViewModel;
            var extra = state.extra;
            if (extra != null) {
              if (extra is AppDirectoryModel) {
                folder = extra;
              } else if (extra is Map) {
                folder = extra['folder'];
                dirListViewModel = extra['dirListViewModel'];
              }
            }
            // final folder = state.extra is AppDirectoryModel ? state.extra as AppDirectoryModel : null;
            return MediaListPage(
              folder: folder,
              dirListViewModel: dirListViewModel,
            );
          },
        ),
        GoRoute(
          path: AppPages.mediaLibraryPlayListPage,
          builder: (context, state) => MediaLibraryPlayDirListPage(),
        ),

        GoRoute(
          path: AppPages.bindDanmakuPage,
          builder: (context, state) {
            // try {
            AppMediaFileModel fileModel = state.extra as AppMediaFileModel;
            /*} catch (e) {
              SmartDialog.showToast('参数错误');
              return const Scaffold(body: Center(child: Text('参数错误')));
            }*/
            return BindDanmakuPage(fileModel: fileModel);
          },
        ),

        GoRoute(
          path: AppPages.apiSelectListPage,
          builder: (context, state) {
            try {
              NetResourceHomeViewModel viewModel =
                  state.extra as NetResourceHomeViewModel;
              return ApiSelectListPage(netResourceHomeViewModel: viewModel);
            } catch (e) {
              SmartDialog.showToast('参数错误');
              return const Scaffold(body: Center(child: Text('参数错误')));
            }
          },
        ),
      ],
      errorBuilder: (context, state) =>
          const Scaffold(body: Center(child: Text('404'))),
    );
  }
}
