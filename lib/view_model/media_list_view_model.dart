import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_player_ui/flutter_player_ui.dart';
import 'package:flutter_player_ui/model/file_source_model.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:media_kit/media_kit.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:signals/signals.dart';
import 'package:source_video_player/player/media_kit_player.dart';
import 'package:source_video_player/route/locator.dart';

import '../models/app_directory_model.dart';
import '../models/app_media_file_model.dart';
import '../models/asset_entity_model.dart';
import '../models/loading_state_model.dart';
import '../models/play_video_storage_model.dart';
import '../storage/istorage.dart';
import '../storage/player_storage.dart';
import 'base_view_model.dart';

class MediaListViewModel extends BaseViewModel {
  final AppDirectoryModel? folder;
  late AppDirectorySourceType? appDirectorySourceType;
  int pageSize = 20;

  bool isRefresh = false;

  final Signal<LoadingStateModel> loadingState = Signal(LoadingStateModel());

  final Signal<String> title = Signal("");

  final Signal<int> fileNumber = Signal(0);

  late final bool isLocal =
      folder?.appDirectorySourceType == AppDirectorySourceType.localDirectory;

  late PagingController<int, AppMediaFileModel> pagingController;

  MediaListViewModel(this.folder) {
    appDirectorySourceType = folder?.appDirectorySourceType;
    fileNumber.value = folder?.fileNumber ?? 0;
    init();
  }
  @override
  void init() {
    title.value = folder?.path ?? "未传入目录";
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
        // 如果当前页返回的数据量小于pageSize，说明已经是最后一页
        // 获取最后一页的数据量
        if (state.pages != null && state.pages!.isNotEmpty) {
          final lastPage = state.pages!.last;
          if (lastPage.length < pageSize) return null;
        }
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
    title.dispose();
    fileNumber.dispose();

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
    if (folder == null) {
      return mediaFileList;
    }
    late List<AssetEntity> assetEntityList;
    if (isLocal) {
      assetEntityList = await (folder!.assetPathEntity! as AssetPathEntity)
          .getAssetListPaged(
            page: page == 0 ? 0 : page - 1, // 分页获取，0为第一页
            size: limit, // 每页数量
          );
      for (var item in assetEntityList) {
        var file = await item.file;
        String fullFilePath = file?.path ?? "";
        if (fullFilePath.isEmpty) {
          continue;
        }
        String key = fullFilePath;
        mediaFileList.add(
          AppMediaFileModel(
            isLocal: true,
            // assetEntity: item,
            // assetEntity: AssetEntityModel(entity: item),
            assetEntity: AssetEntityModel(
              id: item.id,
              duration: item.duration,
              title: item.title ?? "",
              thumbnail: await item.thumbnailData,
              mediaUrl: await item.getMediaUrl(),
              modifiedDateTime: item.modifiedDateTime,
            ),
            danmakuSource: await getFileSourceModel(key, storage.danmaku),
            subtitleSource: await getFileSourceModel(key, storage.subtitle),
            file: file,
          ),
        );
      }
    } else {
      List<PlayVideoStorageModel>? list = await storage.playList
          .getStringToObject<PlayVideoStorageModel>(
            folder!.name,
            PlayVideoStorageModel.fromJson,
          );
      if (list != null && list.isNotEmpty) {
        PhotoManager.getAssetPathList(
          type: RequestType.video,
          filterOption: FilterOptionGroup(),
        );
        // 计算当前页的数据范围
        int startIndex = (page - 1) * limit;
        if (startIndex > list.length) {
          return mediaFileList;
        }
        int endIndex = startIndex + limit;
        if (endIndex > list.length) {
          endIndex = list.length;
        }
        List<PlayVideoStorageModel> currentPageItems = list.sublist(
          startIndex,
          endIndex,
        );

        for (var item in currentPageItems) {
          String key = item.url;
          late AppMediaFileModel mediaFile;
          if (item.assetId != null) {
            File file = File(item.url);
            if (await file.exists()) {
              AssetEntity? assetEntity = await AssetEntity.fromId(
                item.assetId!,
              );
              if (assetEntity == null) {
                mediaFile = AppMediaFileModel(
                  isLocal: false,
                  assetEntity: AssetEntityModel(
                    id: item.url,
                    duration: 0,
                    title: item.name,
                    thumbnail: null,
                    mediaUrl: item.url,
                    modifiedDateTime: DateTime.now(),
                  ),
                );
              } else {
                mediaFile = AppMediaFileModel(
                  isLocal: true,
                  assetEntity: AssetEntityModel(
                    id: item.url,
                    duration: assetEntity.duration,
                    title: item.name,
                    thumbnail: await assetEntity.thumbnailData,
                    mediaUrl: await assetEntity.getMediaUrl(),
                    modifiedDateTime: assetEntity.modifiedDateTime,
                  ),
                  file: file,
                );
              }
            } else {
              mediaFile = AppMediaFileModel(
                isLocal: false,
                errorMsg: "文件已不存在",
                assetEntity: AssetEntityModel(
                  id: item.url,
                  duration: 0,
                  title: item.name,
                  thumbnail: null,
                  mediaUrl: item.url,
                  modifiedDateTime: DateTime.now(),
                ),
              );
            }
          } else {
            // 处理网络视频
            mediaFile = AppMediaFileModel(
              isLocal: false,
              assetEntity: AssetEntityModel(
                id: item.url,
                duration: 0,
                title: item.name,
                thumbnail: null,
                mediaUrl: item.url,
                modifiedDateTime: DateTime.now(),
              ),
            );
          }

          mediaFile.playDir = folder!.name;
          mediaFile.subtitleSource = await getFileSourceModel(
            key,
            storage.danmaku,
          );
          mediaFile.subtitleSource = await getFileSourceModel(
            key,
            storage.subtitle,
          );
          mediaFileList.add(mediaFile);
        }
      }
    }
    return mediaFileList;
  }

  // 辅助方法：加载所有页面
  Future<void> _loadAllPages() async {
    while (pagingController.hasNextPage &&
        (pagingController.error == null ||
            pagingController.error is! Exception)) {
      pagingController.fetchNextPage();
      // 避免阻塞UI线程
      await Future.delayed(Duration(milliseconds: 50));
    }
  }

  Future<List<ChapterModel>> getChapterList({
    int pageStartIndex = 0,
    AppMediaFileModel? activeMediaFileModel,
    int startIndex = 0,
  }) async {
    List<ChapterModel> chapterList = [];
    var pages = pagingController.pages ?? [];
    if (pages.isEmpty) {
      return chapterList;
    }
    int globalIndex = startIndex;
    for (
      int pageIndex = pageStartIndex;
      pageIndex < pages.length;
      pageIndex++
    ) {
      var list = pages[pageIndex];
      for (var item in list) {
        bool activated = false;
        if (activeMediaFileModel != null && activeMediaFileModel == item) {
          activated = true;
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
        var mediaUrl = item.assetEntity?.mediaUrl;

        chapterList.add(
          ChapterModel(
            name: name,
            index: globalIndex,
            playUrl: mediaUrl ?? item.file?.path,
            activated: activated,
            danmakuSource: item.danmakuSource,
            subtitleSource: item.subtitleSource,
            // mediaFileModel: item,
          ),
        );
        globalIndex++;
      }
    }
    return chapterList;
  }

  playVideo(AppMediaFileModel mediaFileModel, BuildContext context) async {
    if (mediaFileModel.errorMsg != null &&
        mediaFileModel.errorMsg!.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("提示"),
            content: Text(mediaFileModel.errorMsg!),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("确定"),
              ),
            ],
          );
        },
      );
      return;
    }
    String name = "";
    if (mediaFileModel.file != null) {
      name = mediaFileModel.file!.path.substring(
        mediaFileModel.file!.path.lastIndexOf("/") + 1,
      );
      name = name.substring(0, name.lastIndexOf("."));
    } else {
      name = mediaFileModel.assetEntity?.title ?? "";
    }
    var mediaUrl = mediaFileModel.assetEntity?.mediaUrl;

    if (context.mounted) {
      MediaKit.ensureInitialized();
      IPlayer player = MediaKitPlayer();
      PlayerUtils.openLocalVideo(
        context: context,
        player: player,
        chapterList: [
          ChapterModel(
            name: name,
            index: 0,
            playUrl: mediaUrl ?? mediaFileModel.file?.path,
            activated: true,
            danmakuSource: mediaFileModel.danmakuSource,
            subtitleSource: mediaFileModel.subtitleSource,
            // mediaFileModel: item,
          ),
        ],
        chapterListLoaded: false,
        playerViewModelCallback: (viewModel) {
          viewModel.dataStorage = PlayerStorage();
          // if (isLocal) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // 异步加载完整列表
            _loadCompletePlaylist(mediaFileModel, viewModel);
          });
          // }
        },
      );
    }
  }

  _loadCompletePlaylist(
    AppMediaFileModel currentMediaFile,
    PlayerViewModel playerViewModel,
  ) async {
    var pages = pagingController.pages ?? [];
    if (pages.isEmpty) {
      PlayerUtils.appendResourceAndUpdateLoadingState(true, playerViewModel);
      return;
    }

    // 分批加载，避免阻塞UI
    await _loadAllPages();

    List<ChapterModel> completeChapterList = await getChapterList(
      startIndex: 0,
      activeMediaFileModel: currentMediaFile,
      pageStartIndex: 0,
    );
    PlayerUtils.appendResourceAndUpdateLoadingState(
      true,
      playerViewModel,
      chapterList: completeChapterList,
    );
  }

  void removeMediaItem(AppMediaFileModel fileModel) {
    folder?.fileNumber = (folder?.fileNumber ?? 0) - 1;
    fileNumber.value = folder?.fileNumber ?? 0;
    _refreshCurrentPosition();
  }

  Future<void> _refreshCurrentPosition() async {
    // 保存当前滚动位置
    final currentItemsCount = pagingController.pages?.length ?? 0;

    // 刷新数据
    pagingController.refresh();

    // 如果之前已经加载了多页，继续加载到之前的页面数
    final totalPages = (currentItemsCount / pageSize).ceil();
    for (int i = 2; i <= totalPages && pagingController.hasNextPage; i++) {
      pagingController.fetchNextPage();
    }
  }

  Future<FileSourceModel?> getFileSourceModel(
    String key,
    IBaseStorage storage,
  ) async {
    var jsonStr = await storage.getString(key);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        return FileSourceModel.fromJson(jsonDecode(jsonStr));
      } catch (_) {}
    }
    return null;
  }
}
