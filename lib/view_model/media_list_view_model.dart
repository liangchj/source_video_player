import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_player_ui/flutter_player_ui.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:media_kit/media_kit.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:signals/signals.dart';
import 'package:source_video_player/player/media_kit_player.dart';

import '../models/app_directory_model.dart';
import '../models/app_media_file_model.dart';
import '../models/asset_entity_model.dart';
import '../models/loading_state_model.dart';
import 'base_view_model.dart';

class MediaListViewModel extends BaseViewModel {
  final AppDirectoryModel? folder;
  int pageSize = 20;

  bool isRefresh = false;

  final Signal<LoadingStateModel> loadingState = Signal(LoadingStateModel());

  late PagingController<int, AppMediaFileModel> pagingController;

  MediaListViewModel(this.folder) {
    init();
  }
  @override
  void init() {
    if (folder == null) {
      loadingState.value = loadingState.value.copyWith(
        loading: false,
        loadedSuc: false,
        errorMsg: "传入的路径为空",
      );
    } else {
      loadingState.value = loadingState.value.copyWith(
        loading: false,
        loadedSuc: true,
        errorMsg: null,
      );
    }
    pagingController = PagingController<int, AppMediaFileModel>(
      getNextPageKey: (PagingState<int, AppMediaFileModel> state) {
        if (!state.hasNextPage || state.lastPageIsEmpty) return null;
        return state.nextIntPageKey;
      },
      fetchPage: (int pageKey) async {
        return await _fetchVideosInFolder(pageKey);
      },
    );

    // 注册资源变化监听
    PhotoManager.addChangeCallback(_onAssetsChanged);
  }

  @override
  void dispose() {
    loadingState.dispose();
    /// 取消事件通知订阅。
    PhotoManager.stopChangeNotify();
    // 移除监听，避免内存泄漏
    PhotoManager.removeChangeCallback(_onAssetsChanged);
  }

  void _onAssetsChanged(MethodCall call) {
    var index = ((pagingController.pages?.length ?? 0) / 20).ceil();
    pagingController.value.reset();
    pagingController.refresh();
    if (index > 1) {
      for (int i = 2; i <= index; i++) {
        pagingController.fetchNextPage();
      }
    }
  }

  Future<void> onRefresh() async {
    isRefresh = true;
    pagingController.value = pagingController.value.copyWith(
      isLoading: true,
      error: null,
    );

    await _fetchVideosInFolder(1);
    isRefresh = false;
    pagingController.value = pagingController.value.copyWith(
      isLoading: false,
      error: null,
    );
  }

  Future<List<AppMediaFileModel>> _fetchVideosInFolder(
    int page, {
    int limit = 20,
  }) async {
    List<AppMediaFileModel> mediaFileList = [];
    if (folder == null ||
        folder!.assetPathEntity == null) {
      return mediaFileList;
    }
    List<AssetEntity> assetEntityList =
        await (folder!.assetPathEntity! as AssetPathEntity).getAssetListPaged(
          page: page == 0 ? 0 : page - 1, // 分页获取，0为第一页
          size: limit, // 每页数量
        );
    for (var item in assetEntityList) {
      var file = await item.file;
      String fullFilePath = file?.path ?? "";
      if (fullFilePath.isEmpty) {
        continue;
      }
      String key = "--$fullFilePath-0";
      // 获取绑定的弹幕文件
      // var danmakuPaths = GStorage.danmakuPaths.get(key);
      // var danmakuPath = danmakuPaths?.localPath;

      // 获取绑定的字幕文件
      // var subtitlePaths = GStorage.subtitlePaths.get(key);
      // var subtitlePath = subtitlePaths?.path;
      mediaFileList.add(
          AppMediaFileModel(
            // assetEntity: item,
            assetEntity: AssetEntityModel(entity: item),
            // danmakuPath: danmakuPath,
            // subtitlePath: subtitlePath,
            file: file,
          ),

      );
    }
    return mediaFileList;
  }

  playVideo(AppMediaFileModel mediaFileModel, BuildContext context) async {
    var pages = pagingController.pages ?? [];
    if (pages.isEmpty) {
      return;
    }
    int index = -1;
    List<ChapterModel> chapterList = [];
    int i = 0;
    for (var list in pages) {
      for (var item in list) {
        if (mediaFileModel == item) {
          index = i;
        }
        String name = "";
        if (item.file != null) {
          name = item.file!.path.substring(
            item.file!.path.lastIndexOf("/") + 1,
          );
          name = name.substring(0, name.lastIndexOf("."));
        } else {
          name = item.assetEntity?.title ?? "";
        }
        var mediaUrl = await item.assetEntity?.mediaUrl;
        bool activated = item.assetEntity?.id == item.assetEntity?.id;
        /*if (item.danmakuPath == null || item.danmakuPath == "") {
          item.danmakuPath = "/storage/emulated/0/1/1.xml";
        }*/
        chapterList.add(
          ChapterModel(
            name: name,
            index: i,
            playUrl: mediaUrl ?? item.file?.path,
            activated: activated,
            // mediaFileModel: item,
          ),
        );
        i++;
      }
    }
    if (context.mounted) {
      MediaKit.ensureInitialized();
      IPlayer player = MediaKitPlayer();
      PlayerUtils.openLocalVideo(
        context: context,
        player: player,
        chapterList: chapterList,
      );
    }
  }
}
