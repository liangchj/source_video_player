import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_player_ui/flutter_player_ui.dart';
import 'package:signals/signals.dart';

import '../models/loading_state_model.dart';
import '../route/locator.dart';
import 'base_view_model.dart';

class BindDanmakuViewModel extends BaseViewModel {
  final Signal<LoadingStateModel> loadingState = Signal<LoadingStateModel>(
    LoadingStateModel(),
  );
  late TextEditingController searchTextEditingController;

  BindDanmakuViewModel() {
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
  Future<void> bindDanmaku(String key, FileSourceModel fileSourceModel) async {
    await storage.danmaku.save(key, fileSourceModel.toJson());
  }

  Future<void> unbindDanmaku(String key) async {
    await storage.danmaku.remove(key);
  }
}
