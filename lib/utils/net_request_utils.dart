import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';

import '../cache/current_configs.dart';
import '../commons/public_commons.dart';
import '../http/dio_utils.dart';

class NetRequestUtils {
  // 获取列表数据
  static Future<PageModel<T>> loadPageResource<T>(
    NetApiModel api,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? params,
  }) async {
    String baseUrl = api.useBaseUrl
        ? CurrentConfigs.currentApi!.apiBaseModel.baseUrl
        : "";
    String url = baseUrl + api.path;
    Map<String, dynamic> queryParams = {...params ?? {}};

    Map<String, dynamic>? staticParams = api.requestParams.staticParams;
    if (staticParams != null && staticParams.isNotEmpty) {
      queryParams.addAll({...staticParams});
    }
    Options options = Options(
      // 响应流上前后两次接受到数据的间隔，单位为毫秒。
      receiveTimeout: PublicCommons.netLoadTimeOutDuration,
    );
    try {
      var res = await DioUtils().get(
        url,
        params: queryParams,
        options: options,
        extra: {"customError": ""},
        shouldRethrow: true,
      );
      var data = res.data;
      Map<String, dynamic> dataMap = {};
      if (data is Map<String, dynamic>) {
        dataMap = data;
      } else if (data is String) {
        try {
          dataMap = jsonDecode(data);
        } catch (e) {
          throw Exception("结果转换成json报错：\n${e.toString()}");
        }
      }
      if (api.extendMap != null) {
        dataMap.addAll(api.extendMap!);
      }

      PageModel<T> result = DefaultResponseParser(
        fromJson,
      ).listDataParse(dataMap, api);

      return result;
    } on DioException catch (e) {
      throw Exception("api连接异常，请检查！\n${e.message}");
    } catch (e) {
      if (e.toString().startsWith("结果转换成json报错：")) {
        throw Exception(e);
      }
      throw Exception("api连接异常，请检查！$e");
    }
  }

  static String getRequestUrl(NetApiModel api, Map<String, dynamic>? params) {
    String baseUrl = api.useBaseUrl
        ? CurrentConfigs.currentApi!.apiBaseModel.baseUrl
        : "";
    final uri = Uri(
      scheme: Uri.parse(baseUrl).scheme,
      host: Uri.parse(baseUrl).host,
      port: Uri.parse(baseUrl).port,
      path: api.path,
      queryParameters: params == null ? null : Map.from(params),
    );
    final fullUrl = uri.toString();
    return fullUrl;
  }

  /// 获取单个
  static Future<DefaultResponseModel<T>> loadResource<T>(
    NetApiModel api,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? params,
  }) async {
    var data = await netRequest(api, headers: headers, params: params);

    Map<String, dynamic> dataMap = {};
    if (data is Map<String, dynamic>) {
      dataMap = data;
    } else if (data is List) {
      try {
        dataMap = data.isEmpty
            ? {}
            : DataTypeConvertUtils.toMapStrDyMap(data[0]);
      } catch (e) {
        throw Exception("结果转换成json报错：\n${e.toString()}");
      }
    } else if (data is String) {
      try {
        dataMap = jsonDecode(data);
      } catch (e) {
        throw Exception("结果转换成json报错：\n${e.toString()}");
      }
    } else {
      try {
        dataMap = DataTypeConvertUtils.toMapStrDyMap(data);
      } catch (e) {
        throw Exception("结果转换成json报错：\n${e.toString()}");
      }
    }
    return DefaultResponseParser<T>(fromJson).detailParse(dataMap, api);
  }

  // 网络请求
  static Future<dynamic> netRequest(
    NetApiModel api, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? params,
  }) async {
    String baseUrl = api.useBaseUrl
        ? CurrentConfigs.currentApi!.apiBaseModel.baseUrl
        : "";
    String url = baseUrl + api.path;
    Map<String, dynamic> queryParams = {...params ?? {}};

    Map<String, dynamic>? staticParams = api.requestParams.staticParams;
    if (staticParams != null && staticParams.isNotEmpty) {
      queryParams.addAll({...staticParams});
    }
    Options options = Options(
      headers: {...?headers, ...?api.requestParams.headerParams},
      // 响应流上前后两次接受到数据的间隔，单位为毫秒。
      receiveTimeout: PublicCommons.netLoadTimeOutDuration,
    );

    try {
      var res = api.usePost
          ? await DioUtils().post(
              url,
              params: queryParams,
              options: options,
              extra: {"customError": ""},
              shouldRethrow: true,
            )
          : await DioUtils().get(
              url,
              params: queryParams,
              options: options,
              extra: {"customError": ""},
              shouldRethrow: true,
            );
      return res.data;
    } on DioException catch (e) {
      throw Exception("api连接异常，请检查！\n${e.message}");
    } catch (e) {
      if (e.toString().startsWith("结果转换成json报错：")) {
        throw Exception(e);
      }
      throw Exception("api连接异常，请检查！$e");
    }
  }
}
