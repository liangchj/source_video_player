import 'package:source_video_player/controller/base_controller.dart';

import '../state/home_state.dart';

class HomeController extends BaseController {
  late HomeState state;

  HomeController() {
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
