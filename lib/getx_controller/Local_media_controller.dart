
import 'package:get/get.dart';
import 'package:source_video_player/cache/media_data_cache.dart';
import 'package:source_video_player/model/directory_model.dart';
import 'package:source_video_player/utils/media_store_utils.dart';

class LocalMediaController extends GetxController {
  String title = "本地媒体库";
  var loading = true.obs;
  var localDirectoryList = <DirectoryModel>[].obs;

  @override
  void onInit() {
    getLocalVideoDirectoryList();
    super.onInit();
  }

  void getLocalVideoDirectoryList() async {
    try {
      loading(true);
      if (MediaDataCache.localDirectoryList.isNotEmpty) {
        localDirectoryList.clear();
        localDirectoryList.assignAll(MediaDataCache.localDirectoryList);
      } else {
        var mediaStoreVideoDirList = await MediaStoreUtils.getMediaStoreVideoDirList();
        if (mediaStoreVideoDirList.isNotEmpty) {
          localDirectoryList.assignAll(mediaStoreVideoDirList);
          localDirectoryList.sort((DirectoryModel a, DirectoryModel b) {
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });
        }
        MediaDataCache.localDirectoryList.clear();
        MediaDataCache.localDirectoryList.assignAll(localDirectoryList);
      }
    } finally {
      loading(false);
    }
  }

}