import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../controller/local_media_library_list_controller.dart';
import '../../permission/permission_constants.dart';
import '../../permission/permission_controller.dart';
import '../../permission/permission_request_dialog.dart';
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
  late LocalMediaLibraryListController _controller;
  LocalMediaLibraryListState get state => _controller.state;

  bool _isCheckingPermission = true;
  bool _canAccessMediaLibrary = false;

  @override
  void initState() {
    super.initState();
    _controller = LocalMediaLibraryListController();
    _checkPermission();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    setState(() => _isCheckingPermission = true);

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
              setState(() => _canAccessMediaLibrary = true);
              // _loadMediaLibrary();
            },
          ),
        );
      }
    } else {
      // 已授权，加载媒体库
      setState(() => _canAccessMediaLibrary = true);
      // _loadMediaLibrary();
    }

    setState(() => _isCheckingPermission = false);
  }


  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermission) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_canAccessMediaLibrary) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(PermissionTips.mediaPermissionDenied),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkPermission,
              child: const Text("重新授权"),
            ),
          ],
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
            onPressed: () => {},
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
                        // Get.toNamed(AppRoutes.mediaList, arguments: fileDirectoryModel);
                      },
                    );
                  },
                );
        }
      }),
    );
  }
}
