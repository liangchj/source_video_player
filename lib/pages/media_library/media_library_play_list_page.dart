import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../models/app_directory_model.dart';
import '../../utils/bottom_sheet_dialog_utils.dart';
import '../../view_model/media_library_play_list_view_model.dart';
import '../../widgets/directory_item_widget.dart';

class MediaLibraryPlayListPage extends StatefulWidget {
  const MediaLibraryPlayListPage({super.key});

  @override
  State<MediaLibraryPlayListPage> createState() =>
      _MediaLibraryPlayListPageState();
}

class _MediaLibraryPlayListPageState extends State<MediaLibraryPlayListPage> {
  late MediaLibraryPlayListViewModel viewModel;
  TextEditingController? renameController;
  TextEditingController? newPlayListController;
  @override
  void initState() {
    super.initState();
    viewModel = MediaLibraryPlayListViewModel();
  }

  @override
  void dispose() {
    renameController?.dispose();
    newPlayListController?.dispose();
    viewModel.dispose();
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
                  if (context.mounted) {
                    BottomSheetDialogUtils.openModalBottomSheet(
                        _buildNewPlayDirectory(context),
                        context: context,
                        closeBtnShow: false,
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadiusDirectional.only(
                                topStart: Radius.circular(10),
                                topEnd: Radius.circular(10)))
                    );
                  }
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
                  _renamePlayDirectoryFile(context, playDirectoryModel),
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
              // Map<String, dynamic> params = {"path": fileDirectoryModel.name, "title": "播放列表",
              //   "directorySourceType": DirectorySourceType.playDirectory, "dirName": fileDirectoryModel.name};
              // Get.toNamed(AppRoutes.videoFileList, arguments: params);
            },
            trailingWidget: IconButton(
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 10,
              ),
              onPressed: () {
                BottomSheetDialogUtils.openModalBottomSheet(
                  _buildOperateListWidget(
                    context,
                    playDirectoryModel: fileDirectoryModel,
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

  /// 创建新的播放列表
  Widget _buildNewPlayDirectory(BuildContext context) {
    //定义一个controller
    newPlayListController ??= TextEditingController.fromValue(
      TextEditingValue(
        /// 设置光标在最后
        selection: TextSelection.fromPosition(
          const TextPosition(affinity: TextAffinity.downstream, offset: 0),
        ),
      ),
    );
    viewModel.createNewPlayDirectoryName.value = ""; // 清除新增播放目录名称
    viewModel.createNewPlayDirectoryErrorText.value = ""; // 清除新增播放目录验证信息
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Container(
        padding: EdgeInsets.only(
          top: 10,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 10,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,  // 重要：添加这行
          children: [
            Row(
              children: const [
                Icon(Icons.playlist_play_rounded),
                Text("创建新的播放列表"),
              ],
            ),
            Row(
              children: [
                Watch(
                  (context) => Expanded(
                    child: TextField(
                      controller: newPlayListController,
                      autofocus: true,
                      maxLines: 1,
                      // scrollPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        viewModel.createNewPlayDirectoryName.value =
                            value; // 新增播放目录名称
                        if (value.isEmpty) {
                          // 新增播放目录名称为空时清除验证信息
                          viewModel.createNewPlayDirectoryErrorText.value = "";
                        }
                      },
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
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        border: const OutlineInputBorder(),
                        // 新增播放目录名称验证信息
                        errorText:
                            viewModel
                                .createNewPlayDirectoryErrorText
                                .value
                                .isEmpty
                            ? null
                            : viewModel.createNewPlayDirectoryErrorText.value,
                      ),
                    ),
                  ),
                ),
      
                const Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                Watch(
                  (context) => Padding(
                    // 新增播放目录名称验证不通过时显示错误信息导致输入框上移，因此按钮也同步上移
                    padding:
                        viewModel.createNewPlayDirectoryErrorText.value.isEmpty
                        ? EdgeInsets.zero
                        : const EdgeInsets.only(bottom: 22.0),
                    child: ElevatedButton(
                      // 新增播放目录名称为空时不可点击创建按钮
                      onPressed:
                          viewModel.createNewPlayDirectoryName.value.isEmpty
                          ? null
                          : () {
                              String text = newPlayListController!.text.trim();
                              if (text.isNotEmpty) {
                                var msg = viewModel.addPlayDirectory(
                                  AppDirectoryModel(
                                    path: text,
                                    name: text,
                                    fileNumber: 0,
                                  ),
                                );
                                if (msg == null || msg.isEmpty) {
                                  Navigator.of(context).pop();
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 36),
                      ),
                      child: const Text("创建"),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 重命名
  _renamePlayDirectoryFile(
    BuildContext context,
    AppDirectoryModel playDirectoryModel,
  ) async {
    //关闭对话框
    //关闭BottomSheet
    BottomSheetDialogUtils.closeCurrentBottomSheet(context);
    // 等待下一帧，确保 UI 状态更新
    await WidgetsBinding.instance.endOfFrame;
    String oldName = playDirectoryModel.name;
    //定义一个controller
    renameController ??= TextEditingController.fromValue(
      TextEditingValue(text: oldName),
    );
    if (!context.mounted) {
      return;
    }
    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("重命名为"),
          content: TextField(
            controller: renameController!, //设置cont
            inputFormatters: const [], // roller
          ),
          actions: [
            TextButton(
              child: const Text("取消"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("确定"),
              onPressed: () {
                var newName = renameController!.text;
                if (newName != oldName) {
                  playDirectoryModel.name = newName;
                  viewModel.reorder();
                  Navigator.of(context).pop();
                }
              }, //关闭对话框
            ),
          ],
        );
      },
    );
  }
}
