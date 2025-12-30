import 'package:source_video_player/controller/base_controller.dart';

import '../state/home_state.dart';

class HomeController extends BaseController {
  late HomeState state;

  @override
  void init() {
    state = HomeState()..init();
  }

  @override
  void dispose() {
    state.dispose();
  }
}
