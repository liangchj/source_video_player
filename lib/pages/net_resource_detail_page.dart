import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_player_ui/flutter_player_ui.dart';
import 'package:signals/signals_flutter.dart';
import '../cache/current_configs.dart';
import '../commons/widget_style_commons.dart';
import '../utils/bottom_sheet_dialog_utils.dart';
import '../utils/logger_utils.dart';
import '../view_model/net_resource_detail_view_model.dart';
import '../widgets/loading_widget.dart';

class NetResourceDetailPage extends StatefulWidget {
  const NetResourceDetailPage({super.key, required this.resourceId});
  final String resourceId;

  @override
  State<NetResourceDetailPage> createState() => _NetResourceDetailPageState();
}

class _NetResourceDetailPageState extends State<NetResourceDetailPage>
    with SingleTickerProviderStateMixin {
  String get resourceId => widget.resourceId;
  late NetResourceDetailViewModel _viewModel;
  final double _playerAspectRatio = 16.0 / 9;

  // 详情页的tab控制器
  late TabController _tabController;
  final List<Widget> tabs = [Tab(text: "详情"), Tab(text: "评论")];

  @override
  void initState() {
    _tabController = TabController(length: tabs.length, vsync: this);
    _viewModel = NetResourceDetailViewModel(resourceId);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      // appBar: AppBar(leading: BackButton()),
      body: Padding(
        padding: EdgeInsets.only(top: CurrentConfigs.statusBarHeight),
        child: Watch(
          (context) => _viewModel.loadingState.value.loading
              ? const Center(
                  child: SizedBox(
                    height: 500,
                    child: LoadingWidget(textWidget: Text("资源加载中...")),
                  ),
                )
              : !_viewModel.loadingState.value.loadedSuc
              ? Center(
                  child: Text(
                    "资源加载失败: ${_viewModel.loadingState.value.errorMsg}",
                  ),
                )
              : _viewModel.videoModel.value == null
              ? const Center(child: Text("获取资源为空"))
              : _createPlayerAndDetailWidget(context)
              /*: SafeArea(
                  top: true,
                  left: false,
                  right: false,
                  bottom: false,
                  child: _createPlayerAndDetailWidget(context),
                ),*/
        ),
      ),
    );
  }

  Widget _createPlayerAndDetailWidget(BuildContext context) {
    return Column(
      children: [
        _createPlayerWidget(),
        Expanded(child: _createDetailWidget(context)),
      ],
    );
  }

  _createPlayerWidget() {
    return AspectRatio(
      aspectRatio: _playerAspectRatio,
      child: _viewModel.playerWidget.value,
    );
  }

  _createDetailWidget(BuildContext context) {
    return Column(
      children: [
        TabBar(controller: _tabController, tabs: tabs),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _createDetailInfoWidget(context),
              _createCommentWidget(),
            ],
          ),
        ),
      ],
    );
  }

  _createDetailInfoWidget(BuildContext context) {
    return Column(
      children: [
        _createResourceDetailInfoWidget(context),
        // 创建资源播放控件按钮
        _createResourceControlBtnWidget(),
        Watch(
          (context) => _viewModel.playerViewModel.value == null
              ? Container()
              : Column(
                  children: [
                    ApiWidget(
                      uiViewModel:
                          _viewModel.playerViewModel.value!.uiViewModel,
                      option: SourceOptionModel(isSelect: true),
                    ),
                    SourceGroupWidget(
                      uiViewModel:
                          _viewModel.playerViewModel.value!.uiViewModel,
                      option: SourceOptionModel(singleHorizontalScroll: true),
                    ),
                    ChapterListWidget(
                      uiViewModel:
                          _viewModel.playerViewModel.value!.uiViewModel,
                      option: SourceOptionModel(singleHorizontalScroll: true),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  _createCommentWidget() {
    return Column(children: [Text("评论信息")]);
  }

  // 详情信息
  _createResourceDetailInfoWidget(BuildContext context) {
    return Watch((context) {
      if (_viewModel.videoModel.value == null) {
        return const Center(child: Text("获取资源为空"));
      }
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: WidgetStyleCommons.safeSpace,
          horizontal: WidgetStyleCommons.safeSpace,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: WidgetStyleCommons.safeSpace / 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _viewModel.videoModel.value!.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      BottomSheetDialogUtils.openModalBottomSheet(
                        (context) => Container(),
                        context: context,
                        closeBtnShow: false,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadiusDirectional.only(
                            topStart: Radius.circular(10),
                            topEnd: Radius.circular(10),
                          ),
                        ),
                        isScrollControlled: true,
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "详情",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_right_rounded,
                          // size: secondaryTextFontSize * 1.5,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  scrollbars: false,
                  dragDevices: {
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.touch,
                  },
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 评分
                      Text(
                        _viewModel.videoModel.value!.score != null
                            ? "${_viewModel.videoModel.value!.score}分"
                            : "暂无",
                        // style: TextStyle(fontSize: secondaryTextFontSize),
                      ),
                      // 地区
                      Container(
                        padding: EdgeInsets.only(
                          left: WidgetStyleCommons.safeSpace / 2,
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                right: WidgetStyleCommons.safeSpace / 2,
                              ),
                              child: Text(
                                "|",
                                style: TextStyle(
                                  // fontSize: secondaryTextFontSize,
                                ),
                              ),
                            ),
                            Text(
                              _viewModel.videoModel.value!.area != null
                                  ? "${_viewModel.videoModel.value!.area}"
                                  : "地区缺失",
                              // style: TextStyle(fontSize: secondaryTextFontSize),
                            ),
                          ],
                        ),
                      ),
                      // 时间
                      Container(
                        padding: EdgeInsets.only(
                          left: WidgetStyleCommons.safeSpace / 2,
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                right: WidgetStyleCommons.safeSpace / 2,
                              ),
                              child: Text(
                                "|",
                                style: TextStyle(
                                  // fontSize: secondaryTextFontSize,
                                ),
                              ),
                            ),
                            Text(
                              _viewModel.videoModel.value!.year != null
                                  ? "${_viewModel.videoModel.value!.year}"
                                  : "时间缺失",
                              // style: TextStyle(fontSize: secondaryTextFontSize),
                            ),
                          ],
                        ),
                      ),

                      // 类型
                      Container(
                        padding: EdgeInsets.only(
                          left: WidgetStyleCommons.safeSpace / 2,
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                right: WidgetStyleCommons.safeSpace / 2,
                              ),
                              child: Text(
                                "|",
                                style: TextStyle(
                                  // fontSize: secondaryTextFontSize,
                                ),
                              ),
                            ),
                            Text(
                              "${_viewModel.videoModel.value!.classList == null ? '未知类型' : _viewModel.videoModel.value!.classList?.join(' ')}",
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              // style: TextStyle(fontSize: secondaryTextFontSize),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _viewModel.videoModel.value!.detailContent ?? '',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    });
  }

  // 资源播放控件按钮
  _createResourceControlBtnWidget() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(
            horizontal: WidgetStyleCommons.safeSpace,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth - WidgetStyleCommons.safeSpace * 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Icon(Icons.favorite_outline_rounded, size: 30),
                        Text("收藏"),
                      ],
                    ),
                  ),
                  onTap: () {},
                ),
                InkWell(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Icon(Icons.downloading_rounded, size: 30),
                        Text("下载"),
                      ],
                    ),
                  ),
                  onTap: () {},
                ),
                InkWell(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Icon(Icons.share_rounded, size: 30),
                        Text("分享"),
                      ],
                    ),
                  ),
                  onTap: () {},
                ),
                InkWell(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Icon(Icons.link_rounded, size: 30),
                        Text("链接"),
                      ],
                    ),
                  ),
                  onTap: () {
                    var chapterUrl = _viewModel
                        .playerViewModel
                        .value
                        ?.resourceState
                        .playingChapter
                        ?.playUrl;
                    LoggerUtils.logger.d("当前播放章节链接：$chapterUrl");
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
