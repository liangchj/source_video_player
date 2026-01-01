import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:source_video_player/pages/media_library/local_media_directory_list_page.dart';

import '../models/app_directory_model.dart';
import '../pages/home_page.dart';
import '../pages/media_library/media_list_page.dart';
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
            final folder = state.extra is AppDirectoryModel ? state.extra as AppDirectoryModel : null;
            return MediaListPage(folder:  folder,);
          },
        ),
      ],
      errorBuilder: (context, state) =>
          const Scaffold(body: Center(child: Text('404'))),
    );
  }
}
