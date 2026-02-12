import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';
import 'package:signals/signals.dart';
import 'package:source_video_player/utils/logger_utils.dart';

import '../cache/current_configs.dart';
import '../http/dio_utils.dart';
import '../models/filter_criteria_item_model.dart';
import '../models/loading_state_model.dart';
import '../models/video_model.dart';
import '../models/video_type_model.dart';
import '../pages/net_resource_list_page.dart';
import '../utils/api_utils.dart';
import '../utils/net_request_utils.dart';
import 'base_view_model.dart';

class NetResourceHomeViewModel extends BaseViewModel {
  final TickerProvider tickerProvider;
  NetResourceHomeViewModel(this.tickerProvider) {
    init();
  }
  // 加载状态
  final Signal<LoadingStateModel> loadingState = Signal(LoadingStateModel());
  final Signal<LoadingStateModel> activatedApiConfigLoadingState = Signal(
    LoadingStateModel(),
  );
  final Signal<LoadingStateModel> apiConfigLoadingState = Signal(
    LoadingStateModel(),
  );
  final Signal<LoadingStateModel> typeLoadingState = Signal(
    LoadingStateModel(),
  );

  final Signal<ApiConfigModel?> activatedApi = Signal(null);

  // 视频类型列表
  final Signal<List<VideoTypeModel>> videoTypeList = Signal([]);

  /// 类型切换controller
  final Signal<TabController?> tabController = Signal<TabController?>(null);

  /// 每个类型的列表
  List<Widget> typeTabBarViews = [];

  late EffectCleanup activatedApiEffect;

  @override
  Future<void> init() async {
    loadingState.value = loadingState.value.copyWith(loading: true);
    await loadApiSetting();
    loadingState.value = loadingState.value.copyWith(loading: false);
    activatedApiEffect = effect(() {
      var value = activatedApi.value;
      untracked(() {
        videoTypeList.value = [];
        typeTabBarViews.clear();
        _clearTabController();
        tabController.value = null;
        loadInfo();
      });
    });
  }

  @override
  void dispose() {
    activatedApiEffect.call();
  }

  Future<void> loadApiSetting() async {
    activatedApiConfigLoadingState.value = activatedApiConfigLoadingState.value
        .copyWith(loading: true);
    apiConfigLoadingState.value = apiConfigLoadingState.value.copyWith(
      loading: true,
    );

    // 获取当前api
    var curApiMsg = await ApiUtils.loadCurrentApi();
    bool needWaitLoadOtherApi = curApiMsg == "当前未设置api";
    activatedApiConfigLoadingState.value = activatedApiConfigLoadingState.value
        .copyWith(loading: false);

    List<String> cacheErrorMsgList = [];
    List<String> fileErrorMsgList = [];
    if (needWaitLoadOtherApi) {
      // 加载其他api
      cacheErrorMsgList.addAll(await ApiUtils.getAllApiFromCache());
      if (CurrentConfigs.enNameToApiMap.isEmpty) {
        fileErrorMsgList.addAll(await ApiUtils.getAllApiFromCustomJsonFile());
      } else {
        fileErrorMsgList.addAll(await ApiUtils.getAllApiFromCustomJsonFile());
      }
      if (CurrentConfigs.enNameToApiMap.isEmpty) {
        apiConfigLoadingState.value = apiConfigLoadingState.value.copyWith(
          errorMsg: "当前未设置api",
        );
      } else {
        CurrentConfigs.updateCurrentApi(
          CurrentConfigs.enNameToApiMap.values.first,
        );
      }
    } else {
      // 加载其他api
      cacheErrorMsgList.addAll(await ApiUtils.getAllApiFromCache());
      fileErrorMsgList.addAll(await ApiUtils.getAllApiFromCustomJsonFile());
    }
    apiConfigLoadingState.value = apiConfigLoadingState.value.copyWith(
      loading: false,
      loadedSuc: cacheErrorMsgList.isEmpty && fileErrorMsgList.isEmpty,
      errorMsg: cacheErrorMsgList.isEmpty && fileErrorMsgList.isEmpty
          ? null
          : cacheErrorMsgList.join("；") + fileErrorMsgList.join("；"),
    );
    activatedApi.value = CurrentConfigs.currentApi;

    if (activatedApi.value != null) {
      activatedApiConfigLoadingState.value = activatedApiConfigLoadingState
          .value
          .copyWith(loadedSuc: true, errorMsg: null);
    } else {
      if (cacheErrorMsgList.isEmpty && fileErrorMsgList.isEmpty) {
        activatedApiConfigLoadingState.value = activatedApiConfigLoadingState
            .value
            .copyWith(loadedSuc: curApiMsg == "当前未设置api", errorMsg: curApiMsg);
      } else {
        activatedApiConfigLoadingState.value = activatedApiConfigLoadingState
            .value
            .copyWith(loadedSuc: false, errorMsg: "解析api配置出错");
      }
    }

    typeLoadingState.value = typeLoadingState.value.copyWith(loading: false);
  }

  Future<void> loadInfo() async {
    if (apiConfigLoadingState.value.loadedSuc) {
      // 加载视频类型
      await loadVideoType();
    }
    if (typeLoadingState.value.loadedSuc) {
      // 设置过滤类型
      createTabBarViews();
    }
  }

  void _clearTabController() {
    if (tabController.value != null) {
      tabController.value!.dispose();
    }
  }

  /// 视频类型
  loadVideoType() async {
    typeLoadingState.value = typeLoadingState.value.copyWith(
      loading: true,
      loadedSuc: true,
    );
    videoTypeList.value = [];
    typeTabBarViews.clear();
    _clearTabController();
    tabController.value = null;
    CurrentConfigs.currentApiVideoTypeMap = {};
    String desc = "获取视频类型api";
    NetApiModel? typeListApi = activatedApi.value?.netApiMap["typeListApi"];
    if (typeListApi == null) {
      typeLoadingState.value = typeLoadingState.value.copyWith(
        loading: false,
        loadedSuc: true,
      );
      return;
    }
    try {
      PageModel<VideoTypeModel> result =
          await NetRequestUtils.loadPageResource<VideoTypeModel>(
            typeListApi,
            VideoTypeModel.fromJson,
          );
      bool suc = result.statusCode == ResponseParseStatusCodeEnum.success.code;
      String errorMsg = "";
      if (suc) {
        videoTypeList.value = result.modelList ?? [];
        if (videoTypeList.isNotEmpty) {
          for (var item in videoTypeList.value) {
            if (item.childType != null &&
                item.childType!.filterCriteriaItemList.isNotEmpty) {
              item.childType!.filterCriteriaItemList.insert(
                0,
                FilterCriteriaItemModel(
                  value: item.id,
                  label: '全部',
                  activated: true,
                ),
              );
            }
            CurrentConfigs.currentApiVideoTypeMap[item.id] = item.childType;
          }
        }
      } else {
        errorMsg = result.msg ?? "获取数据失败";
      }
      typeLoadingState.value = typeLoadingState.value.copyWith(
        loading: false,
        loadedSuc: suc,
        errorMsg: errorMsg,
      );
    } catch (e) {
      LoggerUtils.logger.e("$desc，$e");
      typeLoadingState.value = typeLoadingState.value.copyWith(
        loading: false,
        errorMsg: e.toString(),
      );
    }
  }

  /// 根据视频类型生成视频列表页面
  createTabBarViews() {
    typeTabBarViews.clear();
    if (videoTypeList.isEmpty) {
      tabController.value = TabController(length: 1, vsync: tickerProvider);
      typeTabBarViews.add(
        NetResourceListPage(
          videoType: VideoTypeModel(id: "", name: ""),
          key: ValueKey("${activatedApi.value?.apiBaseModel.enName}-"),
        ),
      );
      return;
    }
    tabController.value = TabController(
      length: videoTypeList.value.length,
      vsync: tickerProvider,
    );
    for (var item in videoTypeList.value) {
      typeTabBarViews.add(
        NetResourceListPage(
          videoType: item,
          key: ValueKey(
            "${activatedApi.value?.apiBaseModel.enName}-${item.id}",
          ),
        ),
      );
    }
  }

  loadNetResourceList() {
    NetApiModel listApi = activatedApi.value!.netApiMap["listApi"]!;
    String url = activatedApi.value!.apiBaseModel.baseUrl + listApi.path;
    Map<String, dynamic> params = {"pg": 1};
    Map<String, dynamic>? staticParams = listApi.requestParams.staticParams;
    if (staticParams != null && staticParams.isNotEmpty) {
      params.addAll({...staticParams});
    }
    Options options = Options(
      //响应流上前后两次接受到数据的间隔，单位为毫秒。
      receiveTimeout: const Duration(milliseconds: 60000),
    );
    DioUtils().get(url, params: params, options: options).then((res) {
      LoggerUtils.logger.d("请求返回数据：$res");
      Map<String, dynamic> dataMap = {};
      var data = res.data;
      LoggerUtils.logger.d(data.runtimeType);
      if (data is Map<String, dynamic>) {
        dataMap = data;
      } else if (data is String) {
        try {
          dataMap = jsonDecode(data);
        } catch (e) {
          LoggerUtils.logger.e("结果转换成json报错：$e");
        }
      }
      var listParseFromJson = DefaultResponseParser(
        VideoModel.fromJson,
      ).listDataParse(dataMap, listApi);

      LoggerUtils.logger.d("数据转换后：${listParseFromJson.toJson()}");
    });
  }
}
