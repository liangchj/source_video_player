import 'package:source_video_player/controller/base_controller.dart';
import 'package:source_video_player/state/media_library_home_state.dart';

class MediaLibraryHomeController extends BaseController {
  late MediaLibraryHomeState state;
  @override
  void init() {
    state = MediaLibraryHomeState()..init();
  }

  @override
  void dispose() {
    state.dispose();
  }
}
