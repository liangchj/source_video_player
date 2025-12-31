import 'package:source_video_player/view_model/base_view_model.dart';

import '../state/local_media_library_list_state.dart';

class LocalMediaLibraryListViewModel extends BaseViewModel{
  late LocalMediaLibraryListState state;
  LocalMediaLibraryListViewModel() {
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