import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:signals/signals_flutter.dart';

import '../commons/widget_style_commons.dart';
import '../models/video_model.dart';
import '../models/video_type_model.dart';
import '../view_model/error_hit_widget.dart';
import '../view_model/net_resource_list_view_model.dart';
import '../widgets/custom_page_error.dart';
import '../widgets/filter_criteria_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/video_card_widget.dart';

class NetResourceListPage extends StatefulWidget {
  const NetResourceListPage({super.key, required this.videoType});
  final VideoTypeModel videoType;

  @override
  State<NetResourceListPage> createState() => _NetResourceListPageState();
}

class _NetResourceListPageState extends State<NetResourceListPage> {
  late NetResourceListViewModel _viewModel;
  @override
  void initState() {
    _viewModel = NetResourceListViewModel(widget.videoType);
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
      body: Watch((context) {
        if (_viewModel.filterCriteriaLoadingState.value.loading) {
          return const Center(
            child: LoadingWidget(textWidget: Text("分类加载中...")),
          );
        }
        if (_viewModel.filterCriteriaLoadingState.value.loadedSuc) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FilterCriteriaWidget(
                padding: EdgeInsets.only(
                  top: WidgetStyleCommons.safeSpace / 2,
                  right: WidgetStyleCommons.safeSpace / 2,
                  left: WidgetStyleCommons.safeSpace / 2,
                ),
                viewModel: _viewModel,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: WidgetStyleCommons.safeSpace),
                  child: _buildResourceList(),
                ),
              ),
            ],
          );
        }
        return ErrorHitWidget(
          errorMsg:
              _viewModel.filterCriteriaLoadingState.value.errorMsg ?? "分类加载失败",
          refreshButtonTitle: "重新加载分类",
          onRefresh: () async {
            await _viewModel.loadFilterCriteriaList();
            if (_viewModel.filterCriteriaLoadingState.value.loadedSuc) {
              _viewModel.pagingController.refresh();
            }
          },
        );
      }),
    );
  }

  Widget _buildResourceList() {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(
        horizontal: WidgetStyleCommons.safeSpace,
      ),
      child: RefreshIndicator(
        onRefresh: () async => _viewModel.onRefresh(),
        child: PagingListener(
          controller: _viewModel.pagingController,
          builder: (context, state, fetchNextPage) => CustomScrollView(
            slivers: [
              PagedSliverGrid<int, VideoModel>(
                key: ValueKey('paged_sliver_grid_${_viewModel.videoType.id}'),
                state: state,
                fetchNextPage: fetchNextPage,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  childAspectRatio: 3 / 4.5,
                  crossAxisSpacing: WidgetStyleCommons.safeSpace,
                  mainAxisSpacing: WidgetStyleCommons.safeSpace,
                  maxCrossAxisExtent: 150,
                ),
                builderDelegate: PagedChildBuilderDelegate<VideoModel>(
                  animateTransitions: true,
                  itemBuilder: (context, item, index) =>
                      VideoCardWidget(videoModel: item),
                  /*CachedNetworkImage(
                    imageUrl: item.coverUrl!,
                    fit: BoxFit.cover,
                  ),*/
                  firstPageErrorIndicatorBuilder: (context) =>
                      CustomFirstPageError(
                        pagingController: _viewModel.pagingController,
                      ),
                  newPageErrorIndicatorBuilder: (context) => CustomNewPageError(
                    pagingController: _viewModel.pagingController,
                  ),
                  noItemsFoundIndicatorBuilder: (context) => SizedBox(
                    width: double.infinity,
                    child: Center(child: Text("---没有数据---")),
                  ),
                ),
              ),
              // 没有更多数据提示
              if (!state.hasNextPage &&
                  !state.isLoading &&
                  state.pages != null &&
                  state.pages!.isNotEmpty &&
                  state.pages![0].isNotEmpty)
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 48,
                    child: Center(child: Text("---没有更多了---")),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
