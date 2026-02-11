import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_player_ui/flutter_player_ui.dart';
import 'package:flutter_player_ui/model/file_source_model.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:signals/signals_flutter.dart';
import 'package:source_video_player/widgets/my_file_selector.dart';
import '../commons/widget_style_commons.dart';
import '../enum/file_format.dart';
import '../models/app_media_file_model.dart';
import '../utils/bottom_sheet_dialog_utils.dart';
import '../utils/datetime_utils.dart';
import '../view_model/bind_danmaku_view_model.dart';
import '../widgets/media_item_view.dart';

class BindDanmakuPage extends StatefulWidget {
  const BindDanmakuPage({super.key, required this.fileModel});
  final AppMediaFileModel fileModel;

  @override
  State<BindDanmakuPage> createState() => _BindDanmakuPageState();
}

class _BindDanmakuPageState extends State<BindDanmakuPage>
    with SingleTickerProviderStateMixin {
  AppMediaFileModel get appMediaFileModel => widget.fileModel;
  Signal<FileSourceModel?> danmakuSourceSignal = Signal<FileSourceModel?>(null);
  late BindDanmakuViewModel _viewModel;
  late TabController tabController;
  final Signal<int> _tabIndexSignal = Signal<int>(0);

  DateTime? get modTime =>
      appMediaFileModel.assetEntity?.modifiedDateTime ??
      appMediaFileModel.file?.lastModifiedSync();

  String? get storageKey => appMediaFileModel.fullFilePath;

  @override
  void initState() {
    if (appMediaFileModel.danmakuSource != null) {
      danmakuSourceSignal.value = appMediaFileModel.danmakuSource;
    }
    _viewModel = BindDanmakuViewModel();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(_listenTab);
    super.initState();
  }

  @override
  void dispose() {
    tabController.removeListener(_listenTab);
    tabController.dispose();
    _tabIndexSignal.dispose();
    _viewModel.dispose();
    danmakuSourceSignal.dispose();
    super.dispose();
  }

  void _listenTab() {
    _tabIndexSignal.value = tabController.index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // 键盘显示不上移内容区域
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        title: Watch(
          (context) => _tabIndexSignal.value == 0
              ? Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _viewModel.searchTextEditingController,
                        // autofocus: true,
                        maxLines: 1,
                        scrollPadding: EdgeInsets.zero,
                        onChanged: (value) {},
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
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // fileModel.barragePath = "xxx";
                        // Get.find<VideoFileController>().videoFileList.refresh();
                        // controller.getBarrageList("d");
                      },
                      child: const Text("搜素"),
                    ),
                  ],
                )
              : Text("本地弹幕"),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            MediaItemView(
              fileModel: appMediaFileModel,
              subtitleWidget: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Watch(
                      (context) => danmakuSourceSignal.value == null
                          ? Container()
                          : InkWell(
                              onTap: () async {
                                if (storageKey == null || storageKey!.isEmpty) {
                                  SmartDialog.showToast('获取文件链接为空，无法移除！');
                                  return;
                                }
                                await _viewModel.unbindDanmaku(storageKey!);
                                danmakuSourceSignal.value = null;
                                appMediaFileModel.danmakuSource = null;
                                // setState(() {});
                              },
                              child: Text(
                                "弹·移除",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                    ),
                    if (modTime != null)
                      Text(DateTimeUtils.ymdhmsFormatter.format(modTime!)),
                  ],
                ),
              ),
              trailingWidget: IconButton(
                constraints: const BoxConstraints(),
                padding: WidgetStyleCommons.mediaTrailingIconPadding,
                onPressed: () {
                  BottomSheetDialogUtils.openModalBottomSheet(
                    (context) =>
                        Watch((context) => _buildOperateListWidget(context)),
                    context: context,
                    closeBtnShow: false,
                  );
                },
                icon: WidgetStyleCommons.mediaTrailingIcon,
              ),
            ),
            TabBar(
              controller: tabController,
              tabs: [
                Tab(text: "网络弹幕"),
                Tab(text: "本地弹幕"),
                // Tab(text: "移除弹幕"),
              ],
            ),
            // const Divider(),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [_buildNetDanmakuList(), _buildLocalDanmakuList()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildNetDanmakuList() {
    return Padding(
      padding: EdgeInsets.all(WidgetStyleCommons.safeSpace),
      child: Text("网络弹幕（后续实现）"),
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
              child: Text(
                appMediaFileModel.fileName,
                textAlign: TextAlign.left,
              ),
            ),
            ListView(
              padding: WidgetStyleCommons.mediaOperateContentListPadding,
              shrinkWrap: true,
              children: [
                Watch(
                  (context) => danmakuSourceSignal.value == null
                      ? Padding(
                          padding: EdgeInsetsGeometry.symmetric(vertical: 20),
                          child: Text("当前未绑定弹幕"),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("当前绑定弹幕："),
                            Text(
                              "来源：${danmakuSourceSignal.value!.sourceType.label}",
                            ),
                            Text("链接：${danmakuSourceSignal.value!.path}"),
                            Center(
                              child: TextButton(
                                onPressed: () async {
                                  if (storageKey == null ||
                                      storageKey!.isEmpty) {
                                    SmartDialog.showToast('获取文件链接为空，无法移除！');
                                    return;
                                  }
                                  await _viewModel.unbindDanmaku(storageKey!);
                                  danmakuSourceSignal.value = null;
                                  appMediaFileModel.danmakuSource = null;
                                },
                                child: const Text("移除弹幕"),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _buildLocalDanmakuList() {
    return MyFileSelector(
      directory: Directory(
        appMediaFileModel.playDir ?? File(appMediaFileModel.fullFilePath!).path,
      ),
      fileFormat: FileFormat.xml,
      onTapFile: (file) async {
        if (storageKey == null || storageKey!.isEmpty) {
          SmartDialog.showToast('获取文件链接为空，无法绑定！');
          return;
        }
        var fileSourceModel = FileSourceModel(
          path: file.path,
          sourceType: FileSourceEnums.localFile,
        );
        await _viewModel.bindDanmaku(
          appMediaFileModel.fullFilePath!,
          fileSourceModel,
        );
        appMediaFileModel.danmakuSource = fileSourceModel;
        danmakuSourceSignal.value = fileSourceModel;
      },
    );
  }
}
