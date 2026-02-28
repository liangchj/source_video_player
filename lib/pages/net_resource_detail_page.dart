import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_player_ui/flutter_player_ui.dart';
import 'package:signals/signals_flutter.dart';
import '../cache/current_configs.dart';
import '../commons/widget_style_commons.dart';
import '../utils/logger_utils.dart';
import '../view_model/net_resource_detail_view_model.dart';
import '../widgets/loading_widget.dart';
import '../widgets/resource_detail_widget.dart';

class NetResourceDetailPage extends StatefulWidget {
  const NetResourceDetailPage({super.key, required this.resourceId});
  final String resourceId;

  @override
  State<NetResourceDetailPage> createState() => _NetResourceDetailPageState();
}

class _NetResourceDetailPageState extends State<NetResourceDetailPage>
    with TickerProviderStateMixin {
  String get resourceId => widget.resourceId;
  late NetResourceDetailViewModel _viewModel;
  final double _playerAspectRatio = 9 / 16.0;

  // 详情页的tab控制器
  late TabController _tabController;
  final List<Widget> tabs = [Tab(text: "详情"), Tab(text: "评论")];

  final GlobalKey _playerWidgetKey = GlobalKey();
  final GlobalKey<ScaffoldState> _childWidgetKey = GlobalKey<ScaffoldState>();

  // 添加动画控制器
  late AnimationController _detailAnimationController;
  late Animation<Offset> _detailSlideAnimation;

  @override
  void initState() {
    _tabController = TabController(length: tabs.length, vsync: this);
    _viewModel = NetResourceDetailViewModel(resourceId);

    // 初始化动画控制器
    _detailAnimationController = AnimationController(
      duration: const Duration(milliseconds: 33),
      vsync: this,
    );
    _detailSlideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 1), // 从底部滑入
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _detailAnimationController,
            curve: Curves.easeOut,
          ),
        );
    super.initState();
  }

  @override
  void dispose() {
    _detailAnimationController.dispose();
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Watch(
        (context) => Watch(
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
              : _createPlayerAndDetailWidget(context),
        ),
      ),
    );
  }

  Widget _createPlayerAndDetailWidget(BuildContext context) {
    return Watch((context) {
      var fullscreen =
          _viewModel.playerViewModel.value != null &&
          _viewModel.playerViewModel.value!.playerState.isFullscreen.value;

      if (fullscreen) {
        _detailAnimationController.reverse();
        return _createPlayerWidget();
      } else {
        _detailAnimationController.forward();
      }

      var size = MediaQuery.of(context).size;
      double playerHeight = size.width * 9 / 16;
      return Padding(
        padding: EdgeInsets.only(
          top: fullscreen ? 0 : CurrentConfigs.statusBarHeight,
        ),
        child: Stack(
          children: [
            // 播放器
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: playerHeight,
              child: Container(
                color: Colors.black,
                child: _createPlayerWidget(),
              ),
            ),
            // 详情面板 - 带动画滑入
            Positioned(
              left: 0,
              right: 0,
              top: playerHeight,
              bottom: 0,
              child: SlideTransition(
                position: _detailSlideAnimation,
                child: Scaffold(
                  key: _childWidgetKey,
                  body: Container(
                    color: Theme.of(context).canvasColor,
                    child: _createDetailWidget(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _createPlayerWidget() {
    return SizedBox(
      key: _playerWidgetKey,
      width: double.infinity,
      height: double.infinity,
      child: _viewModel.playerWidget.value,
    );
  }

  /*_createPlayerWidget() {
    return Watch((context) {
      double height = 0;
      double width = 0;
      var size = MediaQuery.of(context).size;
      if (_viewModel.playerViewModel.value != null &&
          _viewModel.playerViewModel.value!.playerState.isFullscreen.value) {
        height = size.height;
        width = size.width;
      } else {
        width = size.width;
        height = size.width * _playerAspectRatio;
      }
      return SizedBox(
        width: width,
        height: height,
        child: _viewModel.playerWidget.value,
      );
    });
  }*/

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
                    Padding(
                      padding: EdgeInsets.all(WidgetStyleCommons.safeSpace),
                      child: ApiWidget(
                        uiViewModel:
                            _viewModel.playerViewModel.value!.uiViewModel,
                        option: SourceOptionModel(singleHorizontalScroll: true),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(WidgetStyleCommons.safeSpace),
                      child: SourceGroupWidget(
                        uiViewModel:
                            _viewModel.playerViewModel.value!.uiViewModel,
                        option: SourceOptionModel(singleHorizontalScroll: true),
                      ),
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
                      if (_viewModel.bottomSheetController != null) {
                        _viewModel.bottomSheetController!.close();
                        _viewModel.bottomSheetController = null;
                      }
                      _viewModel.bottomSheetController = _childWidgetKey.currentState?.showBottomSheet((context) => ResourceDetailWidget(viewModel: _viewModel,));
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
