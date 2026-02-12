import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

class RequestInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // super.onRequest(options, handler);

    // http header 头加入 Authorization
    // if (UserService.to.hasToken) {
    //   options.headers['Authorization'] = 'Bearer ${UserService.to.token}';
    // }

    return handler.next(options);
    // 如果你想完成请求并返回一些自定义数据，你可以resolve一个Response对象 `handler.resolve(response)`。
    // 这样请求将会被终止，上层then会被调用，then中返回的数据将是你的自定义response.
    //
    // 如果你想终止请求并触发一个错误,你可以返回一个`DioError`对象,如`handler.reject(error)`，
    // 这样请求将被中止并触发异常，上层catchError会被调用。
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // // 200 请求成功, 201 添加成功
    // if (response.statusCode != 200 && response.statusCode != 201) {
    //   handler.reject(
    //     DioException(
    //       requestOptions: response.requestOptions,
    //       response: response,
    //       type: DioExceptionType.badResponse,
    //     ),
    //     true,
    //   );
    // } else {
    //   handler.next(response);
    // }
    handler.next(response);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    String url = err.requestOptions.uri.toString();
    if (!url.contains('heartBeat') &&
        err.requestOptions.extra['customError'] != '') {
      if (err.requestOptions.extra['customError'] == null) {
        throw Exception(await dioError(err));
        // KazumiDialog.showToast(
        //     message: await dioError(err),
        // );
      } else {
        throw Exception(err.requestOptions.extra['customError']);
        // KazumiDialog.showToast(
        // message: err.requestOptions.extra['customError'],
        // );
      }
    }
    super.onError(err, handler);
  }

  static Future<String> dioError(DioException error) async {
    switch (error.type) {
      case DioExceptionType.badCertificate:
        return '证书有误！';
      case DioExceptionType.badResponse:
        return '服务器异常，请稍后重试！';
      case DioExceptionType.cancel:
        return '请求已被取消，请重新请求';
      case DioExceptionType.connectionError:
        return '连接错误，请检查网络设置';
      case DioExceptionType.connectionTimeout:
        return '网络连接超时，请检查网络设置';
      case DioExceptionType.receiveTimeout:
        return '响应超时，请稍后重试！';
      case DioExceptionType.sendTimeout:
        return '发送请求超时，请检查网络设置';
      case DioExceptionType.unknown:
        final String res = await checkConnect();
        return '$res 网络异常';
    }
  }

  static Future<String> checkConnect() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      return '正在使用移动流量';
    }
    if (connectivityResult.contains(ConnectivityResult.wifi)) {
      return '正在使用wifi';
    }
    if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      return '正在使用局域网';
    }
    if (connectivityResult.contains(ConnectivityResult.vpn)) {
      return '正在使用代理网络';
    }
    if (connectivityResult.contains(ConnectivityResult.other)) {
      return '正在使用其他网络';
    }
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return '未连接到任何网络';
    }
    return '';
  }
}
