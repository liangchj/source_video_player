import 'dart:io';

import 'package:flutter/material.dart';
import 'package:signals/signals.dart';
import 'package:signals/signals_flutter.dart';
import 'package:source_video_player/widgets/media_item_widget.dart';
import 'package:source_video_player/widgets/my_file_selector.dart';

import '../enum/file_format.dart';
import '../enum/file_source_enums.dart';
import '../models/app_media_file_model.dart';
import '../view_model/bind_danmaku_view_model.dart';

class BindDanmakuPage extends StatefulWidget {
  const BindDanmakuPage({super.key, required this.fileModel});
  final AppMediaFileModel fileModel;

  @override
  State<BindDanmakuPage> createState() => _BindDanmakuPageState();
}

class _BindDanmakuPageState extends State<BindDanmakuPage>
    with SingleTickerProviderStateMixin {
  late BindDanmakuViewModel _viewModel;
  late TabController tabController;
  final Signal<int> _tabIndexSignal = Signal<int>(0);

  @override
  void initState() {
    super.initState();
    _viewModel = BindDanmakuViewModel(appMediaFileModel: widget.fileModel);
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(_listenTab);
  }

  @override
  void dispose() {
    tabController.removeListener(_listenTab);
    tabController.dispose();
    _tabIndexSignal.dispose();
    _viewModel.dispose();
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
            MediaItemWidget(fileModel: _viewModel.appMediaFileModel),
            /*Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(onPressed: () {}, child: const Text("网络弹幕")),
                TextButton(onPressed: () {}, child: const Text("本地弹幕")),
                TextButton(onPressed: () {}, child: const Text("移除弹幕")),
              ],
            ),*/
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
    return Text("网络弹幕");
  }

  _buildLocalDanmakuList() {
    return MyFileSelector(
      directory: Directory(
        _viewModel.appMediaFileModel.playDir ??
            File(_viewModel.appMediaFileModel.fullFilePath!).path,
      ),
      fileFormat: FileFormat.xml,
      onTapFile: (file) {
        _viewModel.bindDanmaku(file.path, FileSourceEnums.localFile);
      },
    );
  }
}
