import 'package:source_video_player/view_model/base_view_model.dart';

import '../state/media_library_home_state.dart';

class MediaLibraryHomeViewModel extends BaseViewModel {
  late MediaLibraryHomeState state;
  MediaLibraryHomeViewModel() {
    init();
  }
  @override
  void init() {
    state = MediaLibraryHomeState();
  }

  @override
  void dispose() {
    state.dispose();
  }
}
