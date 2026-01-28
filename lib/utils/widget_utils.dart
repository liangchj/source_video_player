import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../models/app_directory_model.dart';
import '../view_model/media_library_play_dir_list_view_model.dart';
import '../widgets/create_new_play_directory_widget.dart';
import 'bottom_sheet_dialog_utils.dart';

class WidgetUtils {
  static void createNewPlayDirectory(
    BuildContext context,
    MediaLibraryPlayDirListViewModel viewModel, {
    Function(AppDirectoryModel)? createdCallBack,
  }) {
    if (!context.mounted) {
      SmartDialog.showToast("组件未挂载完，请稍等！");
      return;
    }
    BottomSheetDialogUtils.openModalBottomSheet(
      (context) => CreateNewPlayDirectoryWidget(
        viewModel: viewModel,
        createdCallBack: createdCallBack,
      ),
      context: context,
      closeBtnShow: false,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(10),
          topEnd: Radius.circular(10),
        ),
      ),
    );
  }
}
