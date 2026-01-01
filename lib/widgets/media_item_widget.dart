import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../commons/widget_style_commons.dart';
import '../models/app_media_file_model.dart';
import '../utils/bottom_sheet_dialog_utils.dart';
import '../utils/logger_utils.dart';
import 'time_format_utils.dart';

class MediaItemWidget extends StatelessWidget {
  const MediaItemWidget({
    super.key,
    required this.fileModel,
    this.leadingWidget,
    this.subtitleWidget,
    this.trailingWidget,
    this.onTap,
  });

  final AppMediaFileModel fileModel;
  final Widget? leadingWidget;
  final Widget? subtitleWidget;
  final Widget? trailingWidget;
  final VoidCallback? onTap;

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
          width: 80,
          height: 60,
          child: Stack(
            children: [
              Positioned.fill(child: _videoThumbnail()),
              Positioned(
                bottom: 3,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  color: Colors.black26.withValues(alpha: 0.5),
                  child: duration == null
                      ? null
                      : Text(
                          TimeFormatUtils.durationToMinuteAndSecond(
                            Duration(seconds: duration),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
              if (fileModel.playHistoryDuration != null && duration != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SizedBox(
                    height: 3,
                    child: LinearProgressIndicator(
                      backgroundColor: Theme.of(context).primaryColor,
                      valueColor: AlwaysStoppedAnimation(Colors.blue),
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
      thumbnail = await fileModel.assetEntity!.thumbnail;
    } else if (fileModel.file != null) {
      thumbnail = await fileModel.file!.readAsBytes();
    }
    return thumbnail == null
        ? const Icon(Icons.video_library)
        : Image.memory(thumbnail, fit: BoxFit.cover, width: 80, height: 60);
  }

  _buildTitle() {
    return Text(
      fileModel.fileName,
      maxLines: 2,
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

    /*var modTime =
        fileModel.assetEntity?.modifiedDateTime ??
        fileModel.file?.lastModifiedSync();
    if (modTime != null) {
      subtitleList.add(Text(DateTimeUtils.ymdhmsFormatter.format(modTime)));
    }*/
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
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
      onPressed: () {
        BottomSheetDialogUtils.openModalBottomSheet(
          _buildOperateListWidget(context),
          context: context,
          closeBtnShow: false,
        );
      },
      icon: const Icon(Icons.more_vert_rounded),
    );
  }

  /// 操作弹窗
  Widget _buildOperateListWidget(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                top: 6,
                right: 16,
                bottom: 0,
              ),
              child: Text(fileModel.fileName, textAlign: TextAlign.left),
            ),
            ListView(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
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
    final ButtonStyle buttonStyle = ButtonStyle(
      alignment: Alignment.centerLeft,
      foregroundColor: WidgetStateProperty.all(Colors.black87),
    );
    Widget renameWidget = TextButton.icon(
      style: buttonStyle,
      icon: const Icon(Icons.edit_rounded),
      label: const Text("重命名"),
      onPressed: () => _renameFile(context),
    );
    Widget subtitlesWidget = TextButton.icon(
      style: buttonStyle,
      icon: const Icon(Icons.subtitles_rounded),
      label: const Text("搜索字幕"),
      onPressed: () {},
    );
    Widget danmakuWidget = TextButton.icon(
      style: buttonStyle,
      icon: const Icon(Icons.subject_rounded),
      label: const Text("绑定弹幕"),
      onPressed: () {
        // Get.toNamed(AppRoutes.searchDanmakuSubtitle, arguments: fileModel);
      },
    );
    Widget addToPlayDirectoryWidget = TextButton.icon(
      style: buttonStyle,
      icon: const Icon(Icons.playlist_play_rounded),
      label: const Text("添加到播放列表"),
      onPressed: () => _addToPlayList(),
    );
    Widget playWidget = TextButton.icon(
      style: buttonStyle,
      icon: const Icon(Icons.play_circle_fill_rounded),
      label: const Text("播放"),
      onPressed: () {
        //关闭对话框
      },
    );
    /*if (fileModel.fileSourceType == AppMediaFileSourceType.playListFile) {
      return [
        playWidget,
        subtitlesWidget,
        danmakuWidget,
        TextButton.icon(
          style: buttonStyle,
          icon: const Icon(Icons.delete_rounded),
          label: const Text("移除"),
          onPressed: () async {
            //关闭对话框
            bool open = Get.isBottomSheetOpen ?? false;
            if (open) {
              Get.back();
            }
            Get.defaultDialog(
              title: "移除视频",
              radius: 6,
              content: Text("您确定想要从播放列表中移除“${fileModel.fileName}”？"),
              actions: [
                TextButton(
                  child: const Text("取消"),
                  onPressed: () {
                    bool open = Get.isDialogOpen ?? false;
                    if (open) {
                      Get.back();
                    }
                  },
                ),
                TextButton(
                  child: const Text("移除"),
                  onPressed: () {
                    */ /*var remove = Get.find<VideoFileController>().removeVideoFromPlayDirectory(fileModel);
                      if (remove) {
                        Get.find<PlayDirectoryListController>().removeVideoFromPlayDirectory(fileModel.directory);
                      }
                      Fluttertoast.showToast(
                          msg: "移除成功",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black.withOpacity(0.7),
                          textColor: Colors.white,
                          fontSize: 16.0
                      );*/ /*
                    bool open = Get.isDialogOpen ?? false;
                    if (open) {
                      Get.back();
                    }
                  }, //关闭对话框
                ),
              ],
            );
          },
        ),
      ];
    }*/
    return [
      renameWidget,
      subtitlesWidget,
      danmakuWidget,
      addToPlayDirectoryWidget,
      TextButton.icon(
        style: buttonStyle,
        icon: const Icon(Icons.delete_rounded),
        label: const Text("删除"),
        onPressed: () async {
          //关闭对话框
          /*bool open = Get.isBottomSheetOpen ?? false;
          if (open) {
            Get.back();
          }*/
          /*Fluttertoast.showToast(
              msg: "点击删除",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black.withOpacity(0.7),
              textColor: Colors.white,
              fontSize: 16.0
          );*/
        },
      ),
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
      TextEditingController nameController = TextEditingController.fromValue(
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
                  var newName = nameController.text;
                  LoggerUtils.logger.d("确认变更，${nameController.text}");
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
  _addToPlayList() {
    //关闭对话框
    /*bool open = Get.isBottomSheetOpen ?? false;
    if (open) {
      Get.closeAllBottomSheets();
    }
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text("将视频添加至播放列表", textAlign: TextAlign.left),
            ),
            OutlinedButton(
              onPressed: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [Icon(Icons.add), Text("创建新播放列表")],
              ),
            ),
            Expanded(child: _buildPlayDirectoryList()),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(10),
          topEnd: Radius.circular(10),
        ),
      ),
    );*/
  }

  /// 构建播放目录列表
  Widget _buildPlayDirectoryList() {
    return Container();
    /*var playDirectoryController = Get.find<PlayDirectoryListController>();
    var videoFileController = Get.find<VideoFileController>();
    var videoDirectoryList = playDirectoryController.videoDirectoryList;
    return Scrollbar(
        child: ListView.builder(
            itemExtent: 66,
            itemCount: videoDirectoryList.length,
            itemBuilder: (context, index) {
              var fileDirectoryModel = videoDirectoryList[index];
              return DirectoryItemWidget(
                directoryModel: fileDirectoryModel,
                onTap: () {
                  String toastText = playDirectoryController.addVideoToPlayDirectory(fileDirectoryModel, fileModel);
                  //关闭对话框
                  bool open = Get.isBottomSheetOpen ?? false;
                  if (open) {
                    Get.back();
                  }
                  // 视频已经存在于“”列表中
                  // 一个视频已添加到“”列表
                  if (toastText.isNotEmpty) {
                    Fluttertoast.showToast(
                        msg: toastText,
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.black.withOpacity(0.7),
                        textColor: Colors.white,
                        fontSize: 16.0
                    );
                  }
                },
                contentPadding: const EdgeInsets.only(left: 0, right: 0),
              );
            }));*/
  }

  /// 创建新的播放列表
  Widget _buildNewPlayDirectory() {
    return Container();
    /*var playDirectoryController = Get.find<PlayDirectoryListController>();
    //关闭对话框
    bool open = Get.isBottomSheetOpen ?? false;
    if(open) {
      Get.back();
    }
    //定义一个controller
    TextEditingController newPlayListController =
    TextEditingController.fromValue(TextEditingValue(
      /// 设置光标在最后
      selection: TextSelection.fromPosition(const TextPosition(
          affinity: TextAffinity.downstream,
          offset: 0)),
    ));
    playDirectoryController.createNewPlayDirectoryName.value = ""; // 清除新增播放目录名称
    playDirectoryController.createNewPlayDirectoryErrorText.value = ""; // 清除新增播放目录验证信息
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          children: [
            Row(
              children: const [
                Icon(Icons.playlist_play_rounded),
                Text("创建新的播放列表")
              ],
            ),
            Row(
              children: [
                Obx(() => Expanded(child: TextField(
                  controller: newPlayListController,
                  autofocus: true,
                  maxLines: 1,
                  scrollPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    playDirectoryController.createNewPlayDirectoryName.value = value; // 新增播放目录名称
                    if (value.isEmpty) { // 新增播放目录名称为空时清除验证信息
                      playDirectoryController.createNewPlayDirectoryErrorText.value = "";
                    }
                  },
                  decoration: InputDecoration(
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      //获得焦点下划线设为蓝色
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Get.theme.backgroundColor),
                      ),
                      border: const OutlineInputBorder(
                      ),
                      // 新增播放目录名称验证信息
                      errorText: playDirectoryController.createNewPlayDirectoryErrorText.value.isEmpty ? null : playDirectoryController.createNewPlayDirectoryErrorText.value
                  ),
                ),
                ),),

                const Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                Obx(() =>  Padding(
                  // 新增播放目录名称验证不通过时显示错误信息导致输入框上移，因此按钮也同步上移
                  padding: playDirectoryController.createNewPlayDirectoryErrorText.value.isEmpty ? EdgeInsets.zero : const EdgeInsets.only(bottom: 22.0),
                  child: ElevatedButton(
                    // 新增播放目录名称为空时不可点击创建按钮
                      onPressed: playDirectoryController.createNewPlayDirectoryName.value.isEmpty ? null : (){
                        String text = newPlayListController.text.trim();
                        if (text.isNotEmpty) {
                          var fileDirectoryModel = DirectoryModel(path: text,name: text, fileNumber: 0);
                          var msg = playDirectoryController.addVideoPlayDirectory(fileDirectoryModel);
                          String toastText = playDirectoryController.addVideoToPlayDirectory(fileDirectoryModel, fileModel);
                          if (msg == null || msg.isEmpty) {
                            //关闭对话框
                            bool open = Get.isBottomSheetOpen ?? false;
                            if(open) {
                              Get.back();
                            }
                          }
                          // 视频已经存在于“”列表中
                          // 一个视频已添加到“”列表
                          if (toastText.isNotEmpty) {
                            Fluttertoast.showToast(
                                msg: toastText,
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.black.withOpacity(0.7),
                                textColor: Colors.white,
                                fontSize: 16.0
                            );
                          }
                        }
                      }, style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 36)
                  ),
                      child: const Text("创建")),
                )),
              ],
            ),
          ],
        ),
      ),
    );*/
  }
}
