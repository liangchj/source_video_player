import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals.dart';

import '../enum/file_source_enums.dart';
import '../models/app_media_file_model.dart';
import '../models/loading_state_model.dart';
import '../route/locator.dart';
import 'base_view_model.dart';

class BindDanmakuViewModel extends BaseViewModel {
  final Signal<LoadingStateModel> loadingState = Signal<LoadingStateModel>(
    LoadingStateModel(),
  );
  late TextEditingController searchTextEditingController;

  final AppMediaFileModel appMediaFileModel;

  BindDanmakuViewModel({required this.appMediaFileModel}) {
    init();
  }

  @override
  void init() {
    searchTextEditingController = TextEditingController();
  }

  @override
  void dispose() {
    searchTextEditingController.dispose();
    loadingState.dispose();
  }

  /// 绑定弹幕
  void bindDanmaku(String path, FileSourceEnums fileSource) {
    appMediaFileModel.danmakuPath = path;
    storage.danmaku.save(appMediaFileModel.fullFilePath!, {
      'path': path,
      'fileSource': fileSource.name,
    });
  }
}
