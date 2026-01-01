import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:signals/signals_flutter.dart';
import 'package:source_video_player/route/app_pages.dart';
import 'package:source_video_player/view_model/local_media_library_list_view_model.dart';

import '../../permission/permission_constants.dart';
import '../../permission/permission_controller.dart';
import '../../permission/permission_request_dialog.dart';
import '../../route/locator.dart';
import '../../state/local_media_library_list_state.dart';
import '../../widgets/directory_item_widget.dart';

class LocalMediaDirectoryListPage extends StatefulWidget {
  const LocalMediaDirectoryListPage({super.key});

  @override
  State<LocalMediaDirectoryListPage> createState() =>
      _LocalMediaDirectoryListPageState();
}

class _LocalMediaDirectoryListPageState
    extends State<LocalMediaDirectoryListPage> {
  late LocalMediaLibraryListViewModel viewModel;
  LocalMediaLibraryListState get state => viewModel.state;

  @override
  void initState() {
    super.initState();
    viewModel = LocalMediaLibraryListViewModel();
    _checkPermission();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    state.isCheckingPermission.value = true;

    bool hasPermission = PermissionController().hasMediaPermission;

    if (!hasPermission) {
      // 未授权，请求权限
      bool isPermanentlyDenied = await PermissionController()
          .checkMediaPermissionPermanentlyDenied();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => PermissionRequestDialog(
            isPermanentlyDenied: isPermanentlyDenied,
            onGranted: () {
              state.canAccessMediaLibrary.value = true;
              viewModel.loadMediaLibrary();
            },
          ),
        );
      }
    } else {
      // 已授权，加载媒体库
      state.canAccessMediaLibrary.value = true;
      viewModel.loadMediaLibrary();
    }

    state.isCheckingPermission.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      if (state.isCheckingPermission.value) {
        return Scaffold(
          appBar: AppBar(title: const Text("本地视频列表")),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
      if (!state.canAccessMediaLibrary.value) {
        Scaffold(
          appBar: AppBar(title: const Text("本地视频列表")),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(PermissionTips.mediaPermissionDenied),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _checkPermission(),
                  child: const Text("重新授权"),
                ),
              ],
            ),
          ),
        );
      }
      return Scaffold(
        appBar: AppBar(
          title: const Text("本地视频列表"),
          actions: [
            IconButton(
              onPressed: () => {},
              icon: const Icon(Icons.search_rounded),
            ),
            IconButton(
              onPressed: () {
                viewModel.loadMediaLibrary();
              },
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: Watch((context) {
          if (state.loadingState.value.loading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            var videoDirectoryList = state.localVideoDirectoryList.value;
            return videoDirectoryList.isEmpty
                ? const Center(child: Text("没有视频"))
                : ListView.builder(
                    itemExtent: 66,
                    itemCount: videoDirectoryList.length,
                    itemBuilder: (context, index) {
                      var fileDirectoryModel = videoDirectoryList[index];
                      return DirectoryItemWidget(
                        directoryModel: fileDirectoryModel,
                        onTap: () {
                          appGoRouter.push(AppPages.mediaListPage, extra: fileDirectoryModel);
                          // Get.toNamed(AppRoutes.mediaList, arguments: fileDirectoryModel);
                        },
                      );
                    },
                  );
          }
        }),
      );
    });
  }
}
