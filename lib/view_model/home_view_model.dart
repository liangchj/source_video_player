
import 'package:source_video_player/view_model/base_view_model.dart';

import '../state/home_state.dart';

class HomeViewModel extends BaseViewModel {
  late HomeState state;
  HomeViewModel() {
    init();
  }
  @override
  void init() {
    state = HomeState();
  }

  @override
  void dispose() {
    state.dispose();
  }

}