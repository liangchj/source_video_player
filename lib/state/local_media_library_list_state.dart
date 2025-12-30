import 'package:signals/signals.dart';

import '../models/app_directory_model.dart';
import '../models/loading_state_model.dart';
import 'signals_base_state.dart';

class LocalMediaLibraryListState extends SignalsBaseState {
  LocalMediaLibraryListState() {
    init();
  }
  final Signal<LoadingStateModel> loadingState = Signal<LoadingStateModel>(
    LoadingStateModel(),
  );

  final Signal<List<AppDirectoryModel>> localVideoDirectoryList = Signal([]);
  @override
  void init() {
    // TODO: implement init
  }
  @override
  void dispose() {
    loadingState.dispose();
    localVideoDirectoryList.dispose();
  }
}
