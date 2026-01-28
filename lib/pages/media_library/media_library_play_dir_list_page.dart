import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../models/app_directory_model.dart';
import '../../route/app_pages.dart';
import '../../route/locator.dart';
import '../../utils/bottom_sheet_dialog_utils.dart';
import '../../utils/widget_utils.dart';
import '../../view_model/media_library_play_dir_list_view_model.dart';
import '../../widgets/directory_item_widget.dart';

class MediaLibraryPlayDirListPage extends StatefulWidget {
  const MediaLibraryPlayDirListPage({super.key});

  @override
  State<MediaLibraryPlayDirListPage> createState() =>
      _MediaLibraryPlayDirListPageState();
}

class _MediaLibraryPlayDirListPageState
    extends State<MediaLibraryPlayDirListPage> {
  late MediaLibraryPlayDirListViewModel viewModel;
  TextEditingController? renameController;

  late final Signal<String?> renameErrorText;

  @override
  void initState() {
    super.initState();
    viewModel = MediaLibraryPlayDirListViewModel();
    renameErrorText = Signal(null);
  }

  @override
  void dispose() {
    renameController?.dispose();
    viewModel.dispose();
    renameErrorText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('视频播放列表'),
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
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton(
                onPressed: () {
                  WidgetUtils.createNewPlayDirectory(context, viewModel);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [Icon(Icons.add), Text("创建新播放列表")],
                ),
              ),
            ),
            Expanded(
              child: Watch((context) {
                if (viewModel.loadingState.value.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  var playDirectoryList = viewModel.playDirectoryList.value;
                  return playDirectoryList.isEmpty
                      ? const Center(child: Text("没有视频"))
                      : _buildPlayDirectoryList(playDirectoryList);
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// 创建右边操作栏
  Widget _buildOperateListWidget(
    BuildContext context, {
    required AppDirectoryModel playDirectoryModel,
    required int index,
  }) {
    // name 重命名 字幕 弹幕 添加到播放列表 删除
    final ButtonStyle buttonStyle = ButtonStyle(
      alignment: Alignment.centerLeft,
      foregroundColor: WidgetStateProperty.all(Colors.black87),
    );
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          shrinkWrap: true,
          children: <Widget>[
            TextButton.icon(
              style: buttonStyle,
              icon: const Icon(Icons.edit_rounded),
              label: const Text("重命名"),
              onPressed: () =>
                  _renamePlayDirectoryFile(context, playDirectoryModel, index),
            ),
            TextButton.icon(
              style: buttonStyle,
              icon: const Icon(Icons.delete_rounded),
              label: const Text("删除"),
              onPressed: () async {
                //关闭BottomSheet
                BottomSheetDialogUtils.closeCurrentBottomSheet(context);
                // 等待下一帧，确保 UI 状态更新
                await WidgetsBinding.instance.endOfFrame;
                if (context.mounted) {
                  showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("删除"),
                        content: const Text("您确定想要删除此播放列表吗？"),
                        actions: [
                          TextButton(
                            child: const Text("取消"),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          TextButton(
                            child: const Text("删除"),
                            onPressed: () {
                              viewModel.removePlayDirectory(playDirectoryModel);
                              Navigator.of(context).pop();
                            }, //关闭对话框
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 构建目录
  Widget _buildPlayDirectoryList(List<AppDirectoryModel> playDirectoryList) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false,
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
      ),
      child: ListView.builder(
        itemExtent: 66,
        itemCount: playDirectoryList.length,
        itemBuilder: (context, index) {
          var fileDirectoryModel = playDirectoryList[index];
          return DirectoryItemWidget(
            directoryModel: fileDirectoryModel,
            onTap: () {
              Map<String, dynamic> extra = {
                "folder": fileDirectoryModel,
                "dirListViewModel": viewModel,
              };
              appGoRouter.push(AppPages.mediaListPage, extra: extra);
            },
            trailingWidget: IconButton(
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 10,
              ),
              onPressed: () {
                BottomSheetDialogUtils.openModalBottomSheet(
                  (context) => _buildOperateListWidget(
                    context,
                    playDirectoryModel: fileDirectoryModel,
                    index: index,
                  ),
                  context: context,
                  closeBtnShow: false,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadiusDirectional.only(
                      topStart: Radius.circular(10),
                      topEnd: Radius.circular(10),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.more_vert_rounded),
            ),
            contentPadding: const EdgeInsets.only(left: 16, right: 0),
          );
        },
      ),
    );
  }

  /// 重命名
  _renamePlayDirectoryFile(
    BuildContext context,
    AppDirectoryModel playDirectoryModel,
    int index,
  ) async {
    //关闭对话框
    //关闭BottomSheet
    BottomSheetDialogUtils.closeCurrentBottomSheet(context);
    // 等待下一帧，确保 UI 状态更新
    await WidgetsBinding.instance.endOfFrame;
    String oldName = playDirectoryModel.name;
    //定义一个controller
    renameController ??= TextEditingController.fromValue(
      TextEditingValue(
        text: oldName,
        selection: TextSelection.fromPosition(
          const TextPosition(affinity: TextAffinity.downstream, offset: 0),
        ),
      ),
    );
    if (!context.mounted) {
      return;
    }
    renameController!.text = oldName;
    renameErrorText.value = null;

    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("重命名为"),
          content: Watch(
            (context) => TextField(
              controller: renameController, //设置cont
              autofocus: true,
              inputFormatters: const [], // roller
              decoration: InputDecoration(
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                //获得焦点下划线设为蓝色
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                border: const OutlineInputBorder(),
                errorText: renameErrorText.value,
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("取消"),
              onPressed: () {
                renameController!.text = "";
                renameErrorText.value = null;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("确定"),
              onPressed: () async {
                var newName = renameController!.text;
                if (newName != oldName) {
                  playDirectoryModel.appDirectorySourceType =
                      AppDirectorySourceType.playDirectory;
                  renameErrorText.value = await viewModel
                      .renamePlayDirectoryFile(
                        playDirectoryModel,
                        newName,
                        index,
                      );
                  if (renameErrorText.value == null ||
                      renameErrorText.value!.isEmpty) {
                    renameController!.text = "";
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                }
              }, //关闭对话框
            ),
          ],
        );
      },
    );
  }
}
