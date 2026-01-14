import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:signals/signals_flutter.dart';

import '../../commons/widget_style_commons.dart';
import '../../models/app_directory_model.dart';
import '../../models/app_media_file_model.dart';
import '../../models/play_video_storage_model.dart';
import '../../route/locator.dart';
import '../../storage/storage_keys.dart';
import '../../utils/bottom_sheet_dialog_utils.dart';
import '../../view_model/base_view_model.dart';
import '../../view_model/media_library_play_dir_list_view_model.dart';
import '../../view_model/media_list_view_model.dart';
import '../../widgets/custom_page_error.dart';
import '../../widgets/media_item_widget.dart';

class MediaListPage extends StatefulWidget {
  const MediaListPage({super.key, this.folder, this.dirListViewModel});

  final AppDirectoryModel? folder;
  final BaseViewModel? dirListViewModel;

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
        title: Watch((context) => Text(_viewModel.title.value)),
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
              deleteMediaItemWidget: _deleteMediaItemWidget(context, item),
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
        child: Watch(
          (context) => Text(
            "$dirName(${_viewModel.fileNumber}个视频)",
            textAlign: TextAlign.left,
          ),
        ),
      ),
    );
  }

  Widget? _deleteMediaItemWidget(
    BuildContext context,
    AppMediaFileModel fileModel,
  ) {
    if (widget.dirListViewModel == null) {
      return null;
    }
    return widget.folder?.appDirectorySourceType ==
            AppDirectorySourceType.playDirectory
        ? TextButton.icon(
            style: WidgetStyleCommons.mediaOperateButtonStyle,
            icon: WidgetStyleCommons.mediaOperateDelIcon,
            label: const Text("移除"),
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
                      title: Text("移除视频"),
                      content: Text("您确定想要从播放列表中移除“${fileModel.fileName}”？"),
                      actions: [
                        TextButton(
                          child: const Text("取消"),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        TextButton(
                          child: const Text("移除"),
                          onPressed: () async {
                            var flag = await _removeMediaItemFromPlayList(
                              fileModel,
                            );
                            if (!flag) {
                              return;
                            }
                            _viewModel.removeMediaItem(fileModel);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          }, //关闭对话框
                        ),
                      ],
                    );
                  },
                );
              }
            },
          )
        : null;
  }

  Future<bool> _removeMediaItemFromPlayList(AppMediaFileModel fileModel) async {
    if (_viewModel.folder != null && _viewModel.folder!.name != "") {
      List<PlayVideoStorageModel>? list = await storage.playList
          .getStringToObject<PlayVideoStorageModel>(
            _viewModel.folder!.name,
            PlayVideoStorageModel.fromJson,
          );
      if (list == null || list.isEmpty) {
        SmartDialog.showToast('获取播放列表为空，无法移除！');
        return false;
      }
      int oldNum = list.length;

      list.removeWhere((item) => item.url == fileModel.fullFilePath);

      // int num = list.isNotEmpty ? list.length - 1 : 0;
      int num = list.length;

      if (num == oldNum) {
        SmartDialog.showToast('列表中已不存在此视频，请刷新列表后重试！');
        return false;
      }

      await storage.playList.saveObjectList<PlayVideoStorageModel>(
        _viewModel.folder!.name,
        list,
        listToJson: playVideoStorageModelListToJson,
      );

      List<AppDirectoryModel>? playDirList = await storage.settings
          .getStringToObject<AppDirectoryModel>(
            StorageKeys.playList,
            AppDirectoryModel.fromJson,
          );
      if (playDirList != null && playDirList.isNotEmpty) {
        int index = -1;
        for (int i = 0; i < playDirList.length; i++) {
          if (playDirList[i].name == fileModel.playDir) {
            index = i;
            break;
          }
        }
        if (index != -1) {
          playDirList[index].fileNumber = num;
          storage.settings.saveObjectList<AppDirectoryModel>(
            StorageKeys.playList,
            playDirList,
            listToJson: appDirectoryModelListToJson,
          );
          if (widget.dirListViewModel != null &&
              widget.dirListViewModel is MediaLibraryPlayDirListViewModel) {
            (widget.dirListViewModel as MediaLibraryPlayDirListViewModel)
                    .playDirectoryList
                    .value =
                playDirList;
          }
        }
      }
      return true;
    }
    SmartDialog.showToast('播放目录为空，无法移除！');
    return false;
  }
}
