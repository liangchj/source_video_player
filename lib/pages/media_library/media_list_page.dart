import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:signals/signals.dart';

import '../../models/app_directory_model.dart';
import '../../models/app_media_file_model.dart';
import '../../view_model/media_list_view_model.dart';
import '../../widgets/custom_page_error.dart';
import '../../widgets/media_item_widget.dart';

class MediaListPage extends StatefulWidget {
  const MediaListPage({super.key, this.folder});

  final AppDirectoryModel? folder;

  @override
  State<MediaListPage> createState() => _MediaListPageState();
}

class _MediaListPageState extends State<MediaListPage> {
  late MediaListViewModel _viewModel;

  @override
  void initState() {
    _viewModel = MediaListViewModel(widget.folder);
    super.initState();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_viewModel.folder?.path ?? "未传入目录"),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
          IconButton(
            onPressed: () => _viewModel.pagingController.refresh(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _viewModel.folder == null
          ? Center(
              child: Text(_viewModel.loadingState.value.errorMsg ?? "传入的路径为空"),
            )
          : Column(
              children: [
                _defaultHeaderWidget(_viewModel.folder?.name ?? "", context),
                Expanded(child: _buildRefreshIndicator()),
              ],
            ),
    );
  }

  RefreshIndicator _buildRefreshIndicator() {
    return RefreshIndicator(
      onRefresh: () async => _viewModel.onRefresh(),
      child: PagingListener(
        controller: _viewModel.pagingController,
        builder: (context, state, fetchNextPage) =>
            _customScrollView(state, fetchNextPage),
      ),
    );
  }

  CustomScrollView _customScrollView(
    PagingState<int, AppMediaFileModel> state,
    NextPageCallback fetchNextPage,
  ) {
    return CustomScrollView(
      slivers: [
        // 如果正在刷新，显示刷新 header
        /*if (state.isLoading && controller.isRefresh)
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 60,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),*/
        PagedSliverList<int, AppMediaFileModel>.separated(
          state: state,
          fetchNextPage: fetchNextPage,
          itemExtent: 48,
          builderDelegate: PagedChildBuilderDelegate(
            animateTransitions: true,
            itemBuilder: (context, item, index) => MediaItemWidget(
              fileModel: item,
              onTap: () => _viewModel.playVideo(item, context),
            ),
            // _mediaListTile(item),
            firstPageErrorIndicatorBuilder: (context) => CustomFirstPageError(
              pagingController: _viewModel.pagingController,
            ),
            newPageErrorIndicatorBuilder: (context) => CustomNewPageError(
              pagingController: _viewModel.pagingController,
            ),
          ),
          separatorBuilder: (context, index) => const Divider(),
        ),
        // 没有更多数据提示
        if (!state.hasNextPage && !state.isLoading)
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: Center(child: Text("---没有更多了---")),
            ),
          ),
      ],
    );
  }

  Widget _defaultHeaderWidget(String dirName, BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: MediaQuery.of(context).size.width,
        // 标题名称与列表的padding
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.2), //边框颜色
            width: 1, //边框宽度
          ), // 边色与边宽度
          color: Colors.white, // 底色
          boxShadow: [
            BoxShadow(
              blurRadius: 10, //阴影范围
              spreadRadius: 0.1, //阴影浓度
              color: Colors.grey.withValues(alpha: 0.2), //阴影颜色
            ),
          ],
        ),
        child: Text(
          "$dirName(${_viewModel.folder?.fileNumber ?? 0}个视频)",
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}
