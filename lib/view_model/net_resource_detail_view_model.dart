import 'package:flutter/material.dart';
import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';
import 'package:flutter_dynamic_api/models/dynamic_params_model.dart';
import 'package:flutter_player_ui/flutter_player_ui.dart';
import 'package:signals/signals.dart';

import '../cache/current_configs.dart';
import '../models/loading_state_model.dart';
import '../models/video_model.dart';
import '../utils/logger_utils.dart';
import '../utils/net_request_utils.dart';
import 'base_view_model.dart';

class NetResourceDetailViewModel extends BaseViewModel {
  final String resourceId;
  NetResourceDetailViewModel(this.resourceId) {
    init();
  }
  // 加载状态
  final Signal<LoadingStateModel> loadingState = Signal(LoadingStateModel());

  final Signal<VideoModel?> videoModel = Signal(null);
  final Signal<Widget> playerWidget = Signal(Container());

  final Signal<PlayerViewModel?> playerViewModel = Signal(null);

  List<EffectCleanup> effectCleanupList = [];

  NetApiModel? detailApi;

  @override
  void init() {
    loadingState.value = loadingState.value.copyWith(
      loading: true,
      loadedSuc: false,
      errorMsg: null,
    );
    detailApi = CurrentConfigs.currentApi!.netApiMap["detailApi"];
    if (detailApi == null) {
      loadingState.value = loadingState.value.copyWith(
        loading: false,
        loadedSuc: false,
        errorMsg: "未配置详情接口",
      );
    } else if (resourceId.isEmpty) {
      loadingState.value = loadingState.value.copyWith(
        loading: false,
        loadedSuc: false,
        errorMsg: "传入的资源id为空!",
      );
    } else {
      playerWidget.value = PlayerView(
        onCreatePlayerViewModel: (playerViewModel) {
          playerViewModel = playerViewModel;
        },
      );
    }
    effectCleanupList.addAll([
      effect(() {
        var viewModel = playerViewModel.value;
        var value = videoModel.value;
        if (viewModel != null && value != null) {
          untracked(() {
            playerViewModel.value!.resourceState.resourceModel.value =
                ResourceModel(
                  id: value.id,
                  name: value.name,
                  url: value.url,
                  apiList: value.apiList,
                );
          });
        }
      }),
    ]);
    loadResourceDetail();
  }

  @override
  void dispose() {
    for (var e in effectCleanupList) {
      e.call();
    }
    videoModel.dispose();
    playerWidget.dispose();
    playerViewModel.value?.dispose();
    playerViewModel.dispose();
  }

  // 加载资源详情
  Future<void> loadResourceDetail() async {
    loadingState.value = loadingState.value.copyWith(
      loading: true,
      loadedSuc: false,
      errorMsg: null,
    );
    videoModel.value = null;
    Map<String, dynamic> params = {};
    var dynamicParams = detailApi!.requestParams.dynamicParams;
    if (dynamicParams == null || !dynamicParams.keys.contains("id")) {
      params["id"] = resourceId;
    } else {
      DynamicParamsModel idParams = dynamicParams["id"]!;
      params[idParams.requestKey] = resourceId;
    }
    try {
      DefaultResponseModel<VideoModel> res =
          await NetRequestUtils.loadResource<VideoModel>(
            detailApi!,
            VideoModel.fromJson,
            params: params,
          );
      if (res.statusCode == ResponseParseStatusCodeEnum.success.code) {
        if (res.model != null && res.model!.id == resourceId) {
          videoModel.value = res.model;
          String requestUrl = NetRequestUtils.getRequestUrl(detailApi!, params);
          videoModel.value!.url = requestUrl;
          for (var playSource in res.model!.playSourceList!) {
            playSource.api ??= CurrentConfigs.currentApi;
          }
        }
      } else {
        loadingState.value = loadingState.value.copyWith(
          loading: false,
          loadedSuc: false,
          errorMsg: "加载资源失败：${res.msg}",
        );
        return;
      }

      LoggerUtils.logger.d("资源信息: ${videoModel.value?.toJson()}");
    } catch (e) {
      loadingState.value = loadingState.value.copyWith(
        loading: false,
        loadedSuc: false,
        errorMsg: "加载资源报错：${e.toString()}",
      );
    }
    loadingState.value = loadingState.value.copyWith(
      loading: false,
      loadedSuc: true,
      errorMsg: null,
    );
  }
}
