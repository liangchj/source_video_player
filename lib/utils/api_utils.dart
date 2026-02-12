import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';

import '../cache/current_configs.dart';
import '../commons/net_api_key_common.dart';
import '../commons/storage_key_commons.dart';
import '../route/locator.dart';
import 'logger_utils.dart';

class ApiUtils {
  /// 加载当前设置的网络api
  static Future<String> loadCurrentApi() async {
    String msg = "";
    // 从缓存中获取
    var apiJson = await storage.settings.getString(
      StorageKeyCommons.currentApiKey,
    );

    if (apiJson != null && apiJson.isNotEmpty) {
      try {
        Map<String, dynamic> map = Map.from(jsonDecode(apiJson));
        handleDefaultApiKeyInfo(map);
        var apiConfigModel = ApiConfigModel.fromJson(map);
        CurrentConfigs.updateCurrentApi(apiConfigModel);
      } catch (e) {
        msg = "解析当前api出错：$e";
      }
    } else {
      msg = "当前未设置api";
    }
    return msg;
  }

  /// 从缓存中获取所有的api
  /// 将api转成json字符串，然后以英文名作为key生成map，再转成字符串存入
  static Future<List<String>> getAllApiFromCache() async {
    List<String> errorList = [];
    // 从缓存中获取
    var apiJson = await storage.settings.getString(
      StorageKeyCommons.customAddApiKey,
    );
    if (apiJson != null && apiJson.isNotEmpty) {
      try {
        Map<String, dynamic> map = Map.from(jsonDecode(apiJson));
        if (map.isEmpty) {
          return errorList;
        }
        for (var entry in map.entries) {
          var value = entry.value;
          Map<String, dynamic> apiJson = {};
          if (value is! Map<String, dynamic>) {
            try {
              apiJson.addAll(DataTypeConvertUtils.toMapStrDyMap(value));
            } catch (e2) {
              LoggerUtils.logger.e(
                "从缓存中获取api解析具体内容不是Map<String, dynamic>类型，无法解析，数据：${entry.value}",
              );
              errorList.add(
                "[${entry.key}]:从缓存中获取api解析具体内容不是Map<String, dynamic>类型，无法解析，数据：${entry.value}",
              );
              continue;
            }
          } else {
            apiJson.addAll(value);
          }
          handleDefaultApiKeyInfo(apiJson);
          CurrentConfigs.enNameToApiJsonMap[entry.key] = apiJson;
          try {
            ApiConfigModel apiModel = ApiConfigModel.fromJson(apiJson);
            CurrentConfigs.enNameToApiMap[apiModel.apiBaseModel.enName] =
                apiModel;
          } catch (e1) {
            LoggerUtils.logger.e(
              "从缓存中获取api解析具体内容错误，数据（已合并默认内容）：$apiJson，报错：$e1",
            );
            errorList.add(
              "[${entry.key}]:从缓存中获取api解析具体内容错误，数据（已合并默认内容）：$apiJson，报错：$e1",
            );
          }
        }
      } catch (e) {
        LoggerUtils.logger.e("从缓存中获取api解析错误：$e");
        errorList.add("从缓存中获取api解析错误：$e");
      }
    }
    LoggerUtils.logger.d(
      "从缓存中获取api信息：enNameToApiJsonMap：${CurrentConfigs.enNameToApiJsonMap}, enNameToApiMap: ${CurrentConfigs.enNameToApiMap}",
    );
    return errorList;
  }

  /// 从自定义json文件中获取
  static Future<List<String>> getAllApiFromCustomJsonFile() async {
    List<String> errorList = [];
    String filePath = CurrentConfigs.apiJsonFilePath;
    if (filePath.isEmpty) {
      return errorList;
    }
    try {
      Map<String, dynamic> resultMap = {};
      String jsonStr = await rootBundle.loadString(filePath);
      if (jsonStr.isEmpty) {
        return errorList;
      }
      try {
        resultMap = jsonDecode(jsonStr);
        if (resultMap.isEmpty) {
          return errorList;
        }
        for (var entry in resultMap.entries) {
          var value = entry.value;
          Map<String, dynamic> apiJson = {};
          if (value is! Map<String, dynamic>) {
            try {
              apiJson.addAll(DataTypeConvertUtils.toMapStrDyMap(value));
            } catch (e2) {
              LoggerUtils.logger.e(
                "读取路径：$filePath的json文件解析具体内容不是Map<String, dynamic>类型，无法解析，数据：${entry.value}",
              );
              errorList.add(
                "[${entry.key}]：读取路径：$filePath的json文件解析具体内容不是Map<String, dynamic>类型，无法解析，数据：${entry.value}",
              );
              continue;
            }
          } else {
            apiJson.addAll(value);
          }
          handleDefaultApiKeyInfo(apiJson);
          CurrentConfigs.enNameToApiJsonMap[entry.key] = apiJson;
          var validateResult = ApiConfigModel.validateField(apiJson);
          if (!validateResult.flag) {
            LoggerUtils.logger.e(
              "读取路径：$filePath的json文件解析具体内容验证不通过，数据（已合并默认内容）：$apiJson，验证信息：${JsonToModelUtils.getValidateResultMsg(validateResult)}",
            );
            errorList.add(
              "[${entry.key}]：读取路径：$filePath的json文件解析具体内容验证不通过，数据（已合并默认内容）：$apiJson，验证信息：${JsonToModelUtils.getValidateResultMsg(validateResult)}",
            );
            continue;
          }
          try {
            ApiConfigModel apiModel = ApiConfigModel.fromJson(apiJson);
            CurrentConfigs.enNameToApiMap[apiModel.apiBaseModel.enName] =
                apiModel;
          } catch (e1) {
            LoggerUtils.logger.e(
              "读取路径：$filePath的json文件解析具体内容错误，数据（已合并默认内容）：$apiJson，报错：$e1",
            );
            errorList.add(
              "[${entry.key}]：读取路径：$filePath的json文件解析具体内容错误，数据（已合并默认内容）：$apiJson，报错：$e1",
            );
          }
        }
      } catch (e) {
        LoggerUtils.logger.e("解析json报错：$e");
      }
    } catch (ee) {
      LoggerUtils.logger.e("读取路径：$filePath的json文件报错：$ee");
      errorList.add("读取路径：$filePath的json文件报错：$ee");
    }
    LoggerUtils.logger.d(
      "读取路径：$filePath的json文件后api信息：enNameToApiJsonMap：${CurrentConfigs.enNameToApiJsonMap}, enNameToApiMap: ${CurrentConfigs.enNameToApiMap}",
    );
    return errorList;
  }

  static handleDefaultApiKeyInfo(Map<String, dynamic> map) {
    String apiKeyConfig = map["apiKeyConfig"] ?? "";
    if (apiKeyConfig.isEmpty) {
      return;
    }
    Map<String, dynamic> apiKeyConfigMap =
        NetApiDefaultKeyCommon.apiKeys[apiKeyConfig] ?? {};
    if (apiKeyConfigMap.isEmpty) {
      return;
    }
    Map<String, dynamic> netApiMap = map["netApiMap"] ?? {};
    if (netApiMap.isEmpty) {
      return;
    }
    for (var entry in netApiMap.entries) {
      var defaultApi = apiKeyConfigMap[entry.key];
      Map<String, dynamic>? defaultApiMap;
      if (defaultApi is Map<String, dynamic>) {
        defaultApiMap = defaultApi;
      } else {
        try {
          defaultApiMap = DataTypeConvertUtils.toMapStrDyMap(defaultApi);
        } catch (e) {
          continue;
        }
      }
      if (defaultApiMap.isEmpty) {
        continue;
      }
      Map<String, dynamic>? dataJson;
      if (entry.value is Map<String, dynamic>) {
        dataJson = entry.value;
      } else {
        try {
          dataJson = DataTypeConvertUtils.toMapStrDyMap(entry.value);
        } catch (e) {
          LoggerUtils.logger.e(
            "解析api信息中的[${entry.key}]错误，内容不是Map<String, dynamic>类型，无法解析：${entry.value}；报错：$e",
          );
          continue;
        }
      }
      dataJson ??= {};
      netApiMap[entry.key] = dataJson;
      mergeMapInfo(dataJson, defaultApiMap);
    }

    /*Map<String, dynamic>? listApi = netApiMap["listApi"];
    if (listApi != null) {
      mergeMapInfo(listApi, apiKeyConfigMap);
    }*/
  }

  static void mergeMapInfo(
    Map<String, dynamic> targetMap,
    Map<String, dynamic> sourceMap,
  ) {
    for (var entry in sourceMap.entries) {
      if (entry.key == "filterCriteriaList") {
        if (entry.value == null) {
          continue;
        }
        List<Map<String, dynamic>> filterCriteriaList =
            DataTypeConvertUtils.toListMapStrDyMap(entry.value);
        if (filterCriteriaList.isEmpty) {
          continue;
        }
        List<Map<String, dynamic>> targetFilterCriteriaList = [];
        if (targetMap[entry.key] == null) {
          targetMap[entry.key] = filterCriteriaList;
          continue;
        } else {
          try {
            targetFilterCriteriaList = DataTypeConvertUtils.toListMapStrDyMap(
              targetMap[entry.key],
            );
          } catch (e) {
            continue;
          }
        }
        if (targetFilterCriteriaList.isEmpty) {
          targetMap[entry.key] = filterCriteriaList;
          continue;
        }
        List<String> targetFilterCriteriaKeyList = targetFilterCriteriaList
            .map((item) => (item["enName"] ?? item["name"] ?? "").toString())
            .toList();
        for (var filterCriteria in filterCriteriaList) {
          if (!targetFilterCriteriaKeyList.contains(
            (filterCriteria["enName"] ?? filterCriteria["name"] ?? "")
                .toString(),
          )) {
            targetFilterCriteriaList.add(filterCriteria);
          }
        }
        targetMap[entry.key] = filterCriteriaList;
        continue;
      }
      if (entry.value is Map) {
        if (entry.value.isEmpty) {
          continue;
        }
        Map<String, dynamic> config = DataTypeConvertUtils.toMapStrDyMap(
          entry.value,
        );
        Map<String, dynamic> map = {};
        if (targetMap[entry.key] == null) {
          map = {};
        } else {
          map = DataTypeConvertUtils.toMapStrDyMap(targetMap[entry.key]);
        }
        targetMap[entry.key] = map;
        mergeMapInfo(map, config);
        continue;
      }
      var targetValue = targetMap[entry.key];
      if (targetValue == null) {
        targetMap[entry.key] = entry.value;
      }
    }
  }
}
