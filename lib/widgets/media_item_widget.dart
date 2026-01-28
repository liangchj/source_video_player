import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:signals/signals_flutter.dart';
import '../commons/widget_style_commons.dart';
import '../models/app_directory_model.dart';
import '../models/app_media_file_model.dart';
import '../utils/bottom_sheet_dialog_utils.dart';
import '../utils/datetime_utils.dart';
import '../utils/logger_utils.dart';
import '../utils/widget_utils.dart';
import '../view_model/media_library_play_dir_list_view_model.dart';
import 'directory_item_widget.dart';
import 'time_format_utils.dart';

class MediaItemWidget extends StatefulWidget {
  const MediaItemWidget({
    super.key,
    required this.fileModel,
    this.leadingWidget,
    this.subtitleWidget,
    this.trailingWidget,
    this.onTap,
    this.playDirListViewModel,
    this.delMediaItemFn,
    this.deleteMediaItemWidget,
  });

  final AppMediaFileModel fileModel;
  final Widget? leadingWidget;
  final Widget? subtitleWidget;
  final Widget? trailingWidget;
  final VoidCallback? onTap;
  final MediaLibraryPlayDirListViewModel? playDirListViewModel;
  final Function(AppMediaFileModel)? delMediaItemFn;
  final Widget? deleteMediaItemWidget;

  @override
  State<MediaItemWidget> createState() => _MediaItemWidgetState();
}

class _MediaItemWidgetState extends State<MediaItemWidget> {
  AppMediaFileModel get fileModel => widget.fileModel;
  Widget? get leadingWidget => widget.leadingWidget;
  Widget? get subtitleWidget => widget.subtitleWidget;
  Widget? get trailingWidget => widget.trailingWidget;
  VoidCallback? get onTap => widget.onTap;
  TextEditingController? nameController;
  TextEditingController? newPlayListController;
  MediaLibraryPlayDirListViewModel? addVideoToPlayDirListViewModel;

  @override
  void dispose() {
    nameController?.dispose();
    newPlayListController?.dispose();
    addVideoToPlayDirListViewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap?.call(),
      child: ListTile(
        horizontalTitleGap: WidgetStyleCommons.safeSpace / 2,
        contentPadding: EdgeInsets.only(
          left: WidgetStyleCommons.safeSpace,
          right: 0,
        ),
        leading: _buildLeadingWidget(context),
        title: _buildTitle(),
        subtitle: _buildSubtitle(),
        trailing: trailingWidget ?? _buildRightOperateIcon(context),
      ),
      /*child: Watch((context) => ListTile(
        horizontalTitleGap: WidgetStyleCommons.safeSpace / 2,
        contentPadding: EdgeInsets.only(
          left: WidgetStyleCommons.safeSpace,
          right: 0,
        ),
        leading: _buildLeadingWidget(context),
        title: _buildTitle(),
        subtitle: _buildSubtitle(),
        trailing: trailingWidget ?? _buildRightOperateIcon(context),
      )),*/
    );
  }

  _buildLeadingWidget(BuildContext context) {
    var duration = fileModel.assetEntity?.duration;
    return leadingWidget ??
        SizedBox(
          width: WidgetStyleCommons.mediaLeadingSize.width,
          height: WidgetStyleCommons.mediaLeadingSize.height,
          child: Stack(
            children: [
              Positioned.fill(child: _videoThumbnail()),
              if (fileModel.isLocal)
                Positioned(
                  bottom: WidgetStyleCommons.mediaLeadingRect.bottom,
                  right: WidgetStyleCommons.mediaLeadingRect.right,
                  child: Container(
                    padding: WidgetStyleCommons.mediaDurationPadding,
                    color: WidgetStyleCommons.mediaDurationBgColor,
                    child: duration == null
                        ? null
                        : Text(
                            TimeFormatUtils.durationToMinuteAndSecond(
                              Duration(seconds: duration),
                            ),
                            style: WidgetStyleCommons.mediaDurationTextStyle,
                          ),
                  ),
                ),
              if (fileModel.playHistoryDuration != null && duration != null)
                Positioned(
                  left: WidgetStyleCommons.mediaPlayProgressRect.left,
                  right: WidgetStyleCommons.mediaPlayProgressRect.right,
                  bottom: WidgetStyleCommons.mediaPlayProgressRect.bottom,
                  child: SizedBox(
                    height: WidgetStyleCommons.mediaPlayProgressHeight,
                    child: LinearProgressIndicator(
                      backgroundColor:
                          WidgetStyleCommons.mediaPlayProgressBgColor,
                      valueColor:
                          WidgetStyleCommons.mediaPlayProgressColorAnimation,
                      value:
                          fileModel.playHistoryDuration!.inSeconds / duration,
                    ),
                  ),
                ),
            ],
          ),
        );
  }

  Widget _videoThumbnail() {
    return FutureBuilder<Widget>(
      future: _buildVideoThumbnail(),
      builder: (context, snapshot) {
        return snapshot.data ??
            const Center(child: CircularProgressIndicator());
      },
    );
  }

  // 构建视频缩略图
  Future<Widget> _buildVideoThumbnail() async {
    Uint8List? thumbnail;
    if (fileModel.thumbnailUint8List != null) {
      thumbnail = fileModel.thumbnailUint8List!;
    } else if (fileModel.assetEntity != null) {
      thumbnail = fileModel.assetEntity!.thumbnail;
    } else if (fileModel.file != null) {
      thumbnail = await fileModel.file!.readAsBytes();
    }
    return thumbnail == null
        ? const Icon(Icons.video_library)
        : Image.memory(
            thumbnail,
            fit: BoxFit.cover,
            width: WidgetStyleCommons.mediaLeadingSize.width,
            height: WidgetStyleCommons.mediaLeadingSize.height,
          );
  }

  _buildTitle() {
    return Text(
      fileModel.fileName,
      maxLines: WidgetStyleCommons.mediaTitleMaxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  _buildSubtitle() {
    if (subtitleWidget != null) {
      return subtitleWidget;
    }

    /// 弹幕和字幕信息
    List<Widget> subtitleList = [];
    if (fileModel.danmakuPath != null && fileModel.danmakuPath!.isNotEmpty) {
      subtitleList.add(
        const CircleAvatar(
          backgroundColor: Colors.blue,
          radius: 8,
          child: Text("弹", style: TextStyle(fontSize: 10)),
        ),
      );
    }
    if (fileModel.subtitlePath != null && fileModel.subtitlePath!.isNotEmpty) {
      subtitleList.add(
        const CircleAvatar(
          backgroundColor: Colors.blue,
          radius: 8,
          child: Text("字", style: TextStyle(fontSize: 10)),
        ),
      );
    }
    if (subtitleList.isEmpty) {
      // barrageSubtitleList.add(Container(width: 0,));
    }
    subtitleList.add(Spacer());

    var modTime =
        fileModel.assetEntity?.modifiedDateTime ??
        fileModel.file?.lastModifiedSync();
    if (modTime != null) {
      subtitleList.add(Text(DateTimeUtils.ymdhmsFormatter.format(modTime)));
    }
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: subtitleList.map((e) => e).toList(),
      ),
    );
  }

  /// 右边操作图标
  IconButton _buildRightOperateIcon(BuildContext context) {
    return IconButton(
      constraints: const BoxConstraints(),
      padding: WidgetStyleCommons.mediaTrailingIconPadding,
      onPressed: () {
        BottomSheetDialogUtils.openModalBottomSheet(
          (context) => _buildOperateListWidget(context),
          context: context,
          closeBtnShow: false,
        );
      },
      icon: WidgetStyleCommons.mediaTrailingIcon,
    );
  }

  /// 操作弹窗
  Widget _buildOperateListWidget(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: WidgetStyleCommons.mediaOperateBoxPadding,
        decoration: WidgetStyleCommons.mediaOperateBoxDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: WidgetStyleCommons.mediaOperateTitlePadding,
              child: Text(fileModel.fileName, textAlign: TextAlign.left),
            ),
            ListView(
              padding: WidgetStyleCommons.mediaOperateContentListPadding,
              shrinkWrap: true,
              children: _createOperateList(context),
            ),
          ],
        ),
      ),
    );
  }

  /// 生成操作列表
  List<Widget> _createOperateList(BuildContext context) {
    // name 重命名 字幕 弹幕 添加到播放列表 删除
    Widget renameWidget = TextButton.icon(
      style: WidgetStyleCommons.mediaOperateButtonStyle,
      icon: WidgetStyleCommons.mediaOperateRenameIcon,
      label: const Text("重命名"),
      onPressed: () => _renameFile(context),
    );
    Widget subtitlesWidget = TextButton.icon(
      style: WidgetStyleCommons.mediaOperateButtonStyle,
      icon: WidgetStyleCommons.mediaOperateSubtitleIcon,
      label: const Text("搜索字幕"),
      onPressed: () {},
    );
    Widget danmakuWidget = TextButton.icon(
      style: WidgetStyleCommons.mediaOperateButtonStyle,
      icon: WidgetStyleCommons.mediaOperateDanmakuIcon,
      label: const Text("绑定弹幕"),
      onPressed: () {
        // Get.toNamed(AppRoutes.searchDanmakuSubtitle, arguments: fileModel);
      },
    );
    Widget addToPlayDirectoryWidget = TextButton.icon(
      style: WidgetStyleCommons.mediaOperateButtonStyle,
      icon: WidgetStyleCommons.mediaOperateAddToPlayDirectoryIcon,
      label: const Text("添加到播放列表"),
      onPressed: () => _addToPlayList(context),
    );
    Widget playWidget = TextButton.icon(
      style: WidgetStyleCommons.mediaOperateButtonStyle,
      icon: WidgetStyleCommons.mediaOperatePlayIcon,
      label: const Text("播放"),
      onPressed: () {
        //关闭对话框
      },
    );

    return [
      renameWidget,
      subtitlesWidget,
      danmakuWidget,
      addToPlayDirectoryWidget,
      widget.deleteMediaItemWidget ?? Container(),
    ];
  }

  /// 重命名
  Future<void> _renameFile(BuildContext context) async {
    String oldName = fileModel.fileName;
    //关闭BottomSheet
    BottomSheetDialogUtils.closeCurrentBottomSheet(context);
    // 等待下一帧，确保 UI 状态更新
    await WidgetsBinding.instance.endOfFrame;
    if (context.mounted) {
      //定义一个controller
      nameController ??= TextEditingController.fromValue(
        TextEditingValue(text: oldName),
      );

      showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("重命名为"),
            content: TextField(
              controller: nameController, //设置cont
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
                  var newName = nameController?.text;
                  LoggerUtils.logger.d("确认变更，${nameController?.text}");
                  if (newName != oldName) {
                    File file = fileModel.file!;
                    try {
                      String dir = fileModel.file!.parent.path;
                      LoggerUtils.logger.d(
                        "重命名,$dir${Platform.pathSeparator}$newName${fileModel.suffix.isEmpty ? '' : '.${fileModel.suffix}'}}",
                      );
                      File renameSync = file.renameSync(
                        "$dir${Platform.pathSeparator}$newName${fileModel.suffix.isEmpty ? '' : '.${fileModel.suffix}'}",
                      );
                      LoggerUtils.logger.d(
                        "重命名成功,$renameSync,${renameSync.path},${FileSystemEntity.isFileSync(renameSync.path)}",
                      );
                      if (renameSync.existsSync()) {
                        SmartDialog.showToast('重命名成功');
                        // Get.find<VideoFileController>().videoFileList.refresh();
                        // Get.find<VideoFileController>().reorder();
                      }
                    } catch (e) {
                      LoggerUtils.logger.e("重命名失败:$e");
                      SmartDialog.showToast('重命名失败：$e');
                    }
                    //关闭对话框并返回true
                    Navigator.of(context).pop(true);
                  }
                }, //关闭对话框
              ),
            ],
          );
        },
      );
    }
  }

  /// 添加到播放列表
  _addToPlayList(BuildContext context) {
    // BottomSheetDialogUtils.closeCurrentBottomSheet(context);
    Navigator.of(context).pop();
    if (!context.mounted) {
      return;
    }
    BottomSheetDialogUtils.openModalBottomSheet(
      (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: WidgetStyleCommons.mediaOperateAddToPlayDirectoryBoxPadding,
        decoration:
            WidgetStyleCommons.mediaOperateAddToPlayDirectoryBoxDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  WidgetStyleCommons.mediaOperateAddToPlayDirectoryBoxPadding,
              child: Text("将视频添加至播放列表", textAlign: TextAlign.left),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
                addVideoToPlayDirListViewModel ??=
                    MediaLibraryPlayDirListViewModel();
                WidgetUtils.createNewPlayDirectory(
                  context,
                  addVideoToPlayDirListViewModel!,
                  createdCallBack: (fileDirectoryModel) {
                    _handleAddVideoToPlayDirList(fileDirectoryModel, context);
                  },
                );
                // _buildNewPlayDirectory();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [Icon(Icons.add), Text("创建新播放列表")],
              ),
            ),
            Expanded(child: _buildPlayDirectoryList()),
          ],
        ),
      ),
      context: context,
      closeBtnShow: false,
      isScrollControlled: true,
      backgroundColor:
          WidgetStyleCommons.mediaOperateAddToPlayDirectoryBoxBgColor,
      shape: WidgetStyleCommons.mediaOperateAddToPlayDirectoryBoxShapeBorder,
    );
  }

  /// 构建播放目录列表
  Widget _buildPlayDirectoryList() {
    addVideoToPlayDirListViewModel ??= MediaLibraryPlayDirListViewModel();
    return Watch(
      (context) => Scrollbar(
        child: ListView.builder(
          itemExtent: 66,
          itemCount:
              addVideoToPlayDirListViewModel!.playDirectoryList.value.length,
          itemBuilder: (context, index) {
            AppDirectoryModel<dynamic> fileDirectoryModel =
                addVideoToPlayDirListViewModel!.playDirectoryList.value[index];
            return DirectoryItemWidget(
              directoryModel: fileDirectoryModel,
              onTap: () =>
                  _handleAddVideoToPlayDirList(fileDirectoryModel, context),
              contentPadding: const EdgeInsets.only(left: 0, right: 0),
            );
          },
        ),
      ),
    );
  }

  void _handleAddVideoToPlayDirList(
    AppDirectoryModel<dynamic> fileDirectoryModel,
    BuildContext context,
  ) async {
    String toastText = await addVideoToPlayDirListViewModel!
        .addVideoToPlayDirectory(fileDirectoryModel, fileModel);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
    // 视频已经存在于“”列表中
    // 一个视频已添加到“”列表
    if (toastText.isNotEmpty) {
      SmartDialog.showToast(toastText);
    }
  }
}
