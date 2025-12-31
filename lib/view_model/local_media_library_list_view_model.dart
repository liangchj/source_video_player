import 'package:photo_manager/photo_manager.dart';
import 'package:source_video_player/view_model/base_view_model.dart';

import '../models/app_directory_model.dart';
import '../state/local_media_library_list_state.dart';

class LocalMediaLibraryListViewModel extends BaseViewModel {
  late LocalMediaLibraryListState state;
  LocalMediaLibraryListViewModel() {
    init();
  }
  @override
  void init() {
    state = LocalMediaLibraryListState();
  }

  @override
  void dispose() {
    state.dispose();
  }

  /// 获取本地媒体列表
  Future<void> loadMediaLibrary() async {
    state.loadingState.value = state.loadingState.value.copyWith(
      loading: true,
      errorMsg: null,
      loadedSuc: false,
      isRefresh: false,
      data: null,
    );

    // 获取本地媒体列表
    List<AssetPathEntity> assetPathList = await PhotoManager.getAssetPathList(
      // hasAll:  true,
      // onlyAll: false, // 只获取所有媒体
      type: RequestType.video,
    );

    List<AppDirectoryModel> list = [];
    for (AssetPathEntity assetPath in assetPathList) {
      // print(assetPath.name);
      if (assetPath.isAll) {
        continue;
      }
      int assetCountAsync = await assetPath.assetCountAsync;
      list.add(
        AppDirectoryModel<AssetPathEntity>(
          path: assetPath.name,
          name: assetPath.name,
          fileNumber: assetCountAsync,
          assetPathEntity: assetPath,
        ),
      );
    }

    // 4. 排序：按文件夹名称或修改时间排序
    list.sort((a, b) => a.name.compareTo(b.name));
    state.localVideoDirectoryList.value = list;

    state.loadingState.value = state.loadingState.value.copyWith(
      loading: false,
      errorMsg: null,
      loadedSuc: true,
      isRefresh: false,
      data: [],
    );
  }
}
