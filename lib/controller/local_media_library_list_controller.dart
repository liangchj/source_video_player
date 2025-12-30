import 'package:source_video_player/controller/base_controller.dart';

import '../state/local_media_library_list_state.dart';

class LocalMediaLibraryListController extends BaseController {
  late LocalMediaLibraryListState state;
  LocalMediaLibraryListController() {
    init();
  }
  @override
  void init() {
    state = LocalMediaLibraryListState();
  }

  @override
  void dispose() {
    state.dispose();
  }
}
