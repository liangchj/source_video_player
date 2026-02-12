import 'package:flutter/material.dart';
import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';
import 'package:flutter_dynamic_api/models/dynamic_params_model.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:signals/signals.dart';

import '../cache/current_configs.dart';
import '../models/filter_criteria_item_model.dart';
import '../models/filter_criteria_list_model.dart';
import '../models/loading_state_model.dart';
import '../models/video_model.dart';
import '../models/video_type_model.dart';
import '../utils/net_request_utils.dart';
import 'base_view_model.dart';

class NetResourceListViewModel extends BaseViewModel {
  final VideoTypeModel videoType;
  NetResourceListViewModel(this.videoType) {
    init();
  }
  // 加载状态
  final Signal<LoadingStateModel> loadingState = Signal(LoadingStateModel());
  // 过滤条件加载状态
  final Signal<LoadingStateModel> filterCriteriaLoadingState = Signal(
    LoadingStateModel(),
  );
  final Signal<List<FilterCriteriaListModel>> filterCriteriaList = Signal([]);

  // 资源列表加载状态
  final Signal<LoadingStateModel> listLoadingState = Signal(
    LoadingStateModel(),
  );

  late PagingController<int, VideoModel> pagingController;

  // 资源列表
  NetApiModel? listApi;

  List<String> notFilterCriteriaKey = [
    "page",
    "pageSize",
    "totalPage",
    "totalCount",
    "keyword",
  ];
  bool hasChildType = false;


  @override
  Future<void> init() async {
    listApi = CurrentConfigs.currentApi!.netApiMap["listApi"];
    pagingController = PagingController<int, VideoModel>(
      getNextPageKey: (PagingState<int, VideoModel> state) {
        if (!state.hasNextPage || state.lastPageIsEmpty) return null;
        return state.nextIntPageKey;
      },
      fetchPage: (int pageKey) async {
        return await loadTypeResource(pageKey);
      },
    );
    await loadFilterCriteriaList();
  }

  @override
  void dispose() {
    loadingState.dispose();
    filterCriteriaLoadingState.dispose();
    filterCriteriaList.dispose();
    listLoadingState.dispose();
  }

  changeFilterCriteria() {
    // 使用一个微任务来延迟刷新，让当前帧完成后再执行刷新
    Future.microtask(() {
      pagingController.refresh();
    });
  }

  /// 加载过滤列表
  Future<void> loadFilterCriteriaList() async {
    filterCriteriaLoadingState.value = filterCriteriaLoadingState.value
        .copyWith(loading: true, loadedSuc: false, errorMsg: null);
    // 当前视频类型下是否存在子类型
    FilterCriteriaListModel? classFilterCriteria =
        CurrentConfigs.currentApiVideoTypeMap[videoType.id];
    if (classFilterCriteria != null &&
        classFilterCriteria.filterCriteriaItemList.isNotEmpty) {
      hasChildType = true;
      filterCriteriaList.add(
        classFilterCriteria.copyWidth(
          enName: classFilterCriteria.enName,
          name: classFilterCriteria.name,
          filterCriteriaItemList: classFilterCriteria.filterCriteriaItemList,
        ),
      );
    }
    // 获取当前视频类型下的过滤条件
    if (listApi == null || listApi!.requestParams.dynamicParams == null) {
      filterCriteriaLoadingState.value = filterCriteriaLoadingState.value
          .copyWith(loading: false, loadedSuc: true, errorMsg: null);
      return;
    }
    for (var entry in listApi!.requestParams.dynamicParams!.entries) {
      if (notFilterCriteriaKey.contains(entry.key)) {
        continue;
      }
      if (entry.value.dataSource !=
          DynamicParamsDataSourceEnum.filterCriteria) {
        continue;
      }
      var filterCriteria = entry.value.filterCriteria;
      if (filterCriteria == null) {
        continue;
      }
      FilterCriteriaListModel model = FilterCriteriaListModel(
        enName: filterCriteria.enName,
        name: filterCriteria.name,
        filterCriteriaItemList: [],
      );
      if (classFilterCriteria != null &&
          classFilterCriteria.enName == model.enName &&
          classFilterCriteria.filterCriteriaItemList.isNotEmpty) {
        continue;
      }
      if (filterCriteria.netApi == null &&
          (filterCriteria.filterCriteriaParamsList == null ||
              filterCriteria.filterCriteriaParamsList!.isEmpty)) {
        continue;
      }
      if (filterCriteria.netApi != null) {
        PageModel<FilterCriteriaParamsModel> result =
            await loadFilterCriteriaFromNetApi(filterCriteria.netApi!);
        if (result.statusCode != ResponseParseStatusCodeEnum.success.code) {
          filterCriteriaLoadingState.value = filterCriteriaLoadingState.value
              .copyWith(
                loading: false,
                loadedSuc: false,
                errorMsg: result.msg ?? "加载过滤条件失败",
              );
          break;
        }
        if (result.modelList == null || result.modelList!.isEmpty) {
          continue;
        }
        model.filterCriteriaItemList = result.modelList!
            .map(
              (e) => FilterCriteriaItemModel(
                value: e.value,
                label: e.label,
                activated: false,
              ),
            )
            .toList();

        model.filterCriteriaItemList.insert(
          0,
          FilterCriteriaItemModel(value: "", label: "全部", activated: true),
        );
        filterCriteriaList.add(model);
        continue;
      }

      model.filterCriteriaItemList = filterCriteria.filterCriteriaParamsList!
          .map(
            (e) => FilterCriteriaItemModel(
              value: e.value,
              label: e.label,
              activated: false,
            ),
          )
          .toList();

      model.filterCriteriaItemList.insert(
        0,
        FilterCriteriaItemModel(value: "", label: "全部", activated: true),
      );
      filterCriteriaList.add(model);
    }
    filterCriteriaLoadingState.value = filterCriteriaLoadingState.value
        .copyWith(loading: false, loadedSuc: true, errorMsg: null);
  }

  /// 从网络中获取过滤条件
  Future<PageModel<FilterCriteriaParamsModel>> loadFilterCriteriaFromNetApi(
    NetApiModel api,
  ) async {
    Map<String, dynamic> params = {"videoTypeId": videoType.id};
    PageModel<FilterCriteriaParamsModel> result =
        await NetRequestUtils.loadPageResource<FilterCriteriaParamsModel>(
          api,
          FilterCriteriaParamsModel.fromJson,
          params: params,
        );

    return result;
  }

  Future<void> onRefresh() async {
    pagingController.value = pagingController.value.copyWith(
      isLoading: false,
      error: null,
    );
    await loadTypeResource(1, isRefresh: true);
  }

  Future<List<VideoModel>> loadTypeResource(
    int page, {
    int limit = 20,
    String? search,
    bool isRefresh = false,
  }) async {
    listLoadingState.value = listLoadingState.value.copyWith(
      loading: true,
      loadedSuc: false,
      errorMsg: null,
      isRefresh: isRefresh,
    );
    List<VideoModel> list = [];
    try {
      Map<String, dynamic> params = {};
      var dynamicParams = CurrentConfigs.listApi!.requestParams.dynamicParams;
      if (dynamicParams == null) {
        params["page"] = page;
      } else {
        for (var entry in dynamicParams.entries) {
          String key = entry.value.requestKey;
          dynamic paramValue;
          if (entry.value.dataSource ==
              DynamicParamsDataSourceEnum.filterCriteria) {
            FilterCriteriaListModel? filterCriteria;
            for (var item in filterCriteriaList.value) {
              if (item.enName == entry.key) {
                filterCriteria = item;
                break;
              }
            }

            if (filterCriteria != null) {
              for (var item in filterCriteria.filterCriteriaItemList) {
                if (item.activated.value) {
                  paramValue = item.value;
                  break;
                }
              }
            }
          } else {
            switch (entry.key) {
              case "page":
                paramValue = page;
                break;
              case "pageSize":
                paramValue = limit;
                break;
              default:
                break;
            }
          }
          if (paramValue != null) {
            params[key] = paramValue;
          } else {
            if (entry.value.emptyNeedSend) {
              params[key] = "";
            }
          }
        }

        if (!hasChildType) {
          var dynamicParam = dynamicParams["typeId"];
          if (dynamicParam != null) {
            var key = dynamicParam.requestKey;
            if (key.isNotEmpty) {
              params[key] = videoType.id;
            }
          }
        }
      }
      var res = await NetRequestUtils.loadPageResource<VideoModel>(
        CurrentConfigs.listApi!,
        VideoModel.fromJson,
        params: params,
      );
      if (listLoadingState.value.isRefresh) {
        pagingController.value = pagingController.value.copyWith(
          pages: [res.modelList ?? []],
          keys: [page],
          hasNextPage: res.page < res.totalPage,
          isLoading: false,
        );
      } else {
        pagingController.value = pagingController.value.copyWith(
          hasNextPage: res.page < res.totalPage,
          isLoading: false,
        );
      }
      list = res.modelList ?? [];
      listLoadingState.value = listLoadingState.value.copyWith(
        loading: false,
        loadedSuc: true,
        errorMsg: null,
      );
    } catch (e) {
      pagingController.value = pagingController.value.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      if (listLoadingState.value.isRefresh) {
        SmartDialog.showToast(
          '刷新失败',
          alignment: Alignment.center,
          maskColor: Colors.red,
        );
      }
      listLoadingState.value = listLoadingState.value.copyWith(
        loading: false,
        loadedSuc: false,
        errorMsg: "加载资源报错：${e.toString()}",
      );
    }
    return list;
  }
}
