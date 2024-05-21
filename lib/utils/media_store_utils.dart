
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../model/directory_model.dart';

class MediaStoreUtils {
  static Logger logger = Logger();
  //1.创建Flutter端的MethodChannel
  static const MethodChannel _methodChannel = MethodChannel('GET_MEDIA_STORE_LIST_CHANNEL');
  static Future<List<DirectoryModel>> getMediaStoreVideoDirList() async {
    List<DirectoryModel> videoDirList = [];
    //2.通过invokeMethod调用Native方法，拿到返回值
    String dirStr = await _methodChannel.invokeMethod("getMediaStoreVideoDirList");
    logger.d("getMediaStoreVideoDirList dirStr: $dirStr");
    if (dirStr.isNotEmpty) {
      videoDirList = directoryModelListFromJson(dirStr);
    }
    return videoDirList;
  }
}