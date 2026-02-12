import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';

import '../commons/storage_key_commons.dart';
import '../models/filter_criteria_list_model.dart';
import '../route/locator.dart';

/// 当前运行的配置信息
class CurrentConfigs {
  /// api json文件存储路径
  static String apiJsonFilePath = "assets/net_api/net_api.json";
  /// 当前api
  static ApiConfigModel? currentApi;
  static NetApiModel? listApi;
  static Map<String, Map<String, dynamic>> enNameToApiJsonMap = {};
  // static List<ApiModel> allApiList = [];
  static Map<String, ApiConfigModel> enNameToApiMap = {};

  /// 当前api的资源类型
  static Map<String, FilterCriteriaListModel?> currentApiVideoTypeMap = {};

  /// 当前请求参数key

  // 通用的过滤条件
  static Map<String, FilterCriteriaListModel> commonFilterMap = {};

  static double statusBarHeight = 0.0;

  static updateCurrentApi(ApiConfigModel? api) {
    CurrentConfigs.currentApi = api;
    storage.settings.save(
      StorageKeyCommons.currentApiKey,
      CurrentConfigs.currentApi?.toJson(),
    );
    CurrentConfigs.updateCurrentApiInfo();
  }

  static updateCurrentApiInfo() {
    if (CurrentConfigs.currentApi == null) {
      listApi = null;
    } else {
      listApi = CurrentConfigs.currentApi!.netApiMap["listApi"];
    }
  }

  static mergeCommonFilterMap(Map<String, dynamic> map) {
    for (var entry in map.entries) {
      try {
        commonFilterMap[entry.key] = FilterCriteriaListModel.fromJson(
          entry.value,
        );
      } catch (e) {
        continue;
      }
    }
  }
}
