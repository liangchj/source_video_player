import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../route/app_pages.dart';
import '../route/locator.dart';
import '../view_model/error_hit_widget.dart';
import '../view_model/net_resource_home_view_model.dart';
import '../widgets/loading_widget.dart';

class NetResourceHomePage extends StatefulWidget {
  const NetResourceHomePage({super.key});

  @override
  State<NetResourceHomePage> createState() => _NetResourceHomePageState();
}

class _NetResourceHomePageState extends State<NetResourceHomePage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late NetResourceHomeViewModel _viewModel;

  @override
  void initState() {
    _viewModel = NetResourceHomeViewModel(this);
    super.initState();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Watch((context) {
      if (_viewModel.activatedApiConfigLoadingState.value.loading ||
          _viewModel.apiConfigLoadingState.value.loading) {
        return const Center(
          child: LoadingWidget(textWidget: Text("加载api配置中...")),
        );
      }
      if (!_viewModel.activatedApiConfigLoadingState.value.loadedSuc) {
        return ErrorHitWidget(
          errorMsg:
              "加载api配置失败：${_viewModel.activatedApiConfigLoadingState.value.errorMsg}；${_viewModel.apiConfigLoadingState.value.errorMsg}",
          refreshButtonTitle: "重新加载api",
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: InkWell(
            onTap: () {
              appRouter.push(AppPages.apiSelectListPage, extra: _viewModel);
            },
            child: Watch(
              (context) => Text(
                _viewModel.activatedApi.value == null
                    ? _viewModel
                              .activatedApiConfigLoadingState
                              .value
                              .errorMsg ??
                          "（未设置）"
                    : _viewModel.activatedApi.value?.apiBaseModel.name ?? "（空）",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.start,
              ),
            ),
          ),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          ],
          toolbarHeight: 36,
        ),
        body: _viewModel.activatedApi.value == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("未设置api"),
                    TextButton(
                      onPressed: () {
                        // Get.to(() => ApiSelectListPage());
                      },
                      child: Text("点击设置"),
                    ),
                  ],
                ),
              )
            : _buildResource(),
      );
    });
  }

  Widget _buildResource() {
    return Watch((context) {
      if (_viewModel.loadingState.value.loading) {
        return const Center(
          child: LoadingWidget(textWidget: Text("页面加载中...")),
        );
      }
      if (_viewModel.typeLoadingState.value.loading) {
        return const Center(
          child: LoadingWidget(textWidget: Text("加载视频类型中...")),
        );
      }
      if (!_viewModel.typeLoadingState.value.loadedSuc) {
        return Center(
          child: ErrorHitWidget(
            errorMsg: "加载视频类型失败：${_viewModel.typeLoadingState.value.errorMsg}",
            refreshButtonTitle: "重新加载",
            onRefresh: () {
              _viewModel.loadInfo();
            },
          ),
        );
      }
      if (_viewModel.videoTypeList.isEmpty) {
        return Center(child: Text("当前api无数据"));
      }
      if (_viewModel.tabController.value == null) {
        return ErrorHitWidget(
          errorMsg: "构建失败，请重试！",
          refreshButtonTitle: "重新构建",
          onRefresh: () {
            _viewModel.createTabBarViews();
          },
        );
      }
      return DefaultTabController(
        length: _viewModel.videoTypeList.value.length,
        child: Column(
          children: [
            SizedBox(
              height: 42,
              width: double.infinity,
              child: TabBar(
                padding: EdgeInsets.only(top: 0),
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                controller: _viewModel.tabController.value,
                tabs: _viewModel.videoTypeList
                    .map((e) => Tab(text: e.name))
                    .toList(),
              ),
            ),
            Expanded(child: _buildTypeResourceList()),
          ],
        ),
      );
    });
  }

  // 构建类型下的资源列表
  Widget _buildTypeResourceList() {
    return TabBarView(
      controller: _viewModel.tabController.value,
      children: _viewModel.typeTabBarViews,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
