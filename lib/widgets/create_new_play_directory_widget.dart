import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../models/app_directory_model.dart';
import '../view_model/media_library_play_dir_list_view_model.dart';

class CreateNewPlayDirectoryWidget extends StatefulWidget {
  const CreateNewPlayDirectoryWidget({
    super.key,
    required this.viewModel,
    this.createdCallBack,
  });
  final MediaLibraryPlayDirListViewModel viewModel;
  final Function(AppDirectoryModel)? createdCallBack;

  @override
  State<CreateNewPlayDirectoryWidget> createState() =>
      _CreateNewPlayDirectoryWidgetState();
}

class _CreateNewPlayDirectoryWidgetState
    extends State<CreateNewPlayDirectoryWidget> {
  MediaLibraryPlayDirListViewModel get viewModel => widget.viewModel;
  late TextEditingController newPlayListController;
  late final Signal<String> createNewPlayDirectoryName;
  late final Signal<String?> createNewPlayDirectoryErrorText;

  @override
  void initState() {
    super.initState();
    newPlayListController = TextEditingController.fromValue(
      TextEditingValue(
        /// 设置光标在最后
        selection: TextSelection.fromPosition(
          const TextPosition(affinity: TextAffinity.downstream, offset: 0),
        ),
      ),
    );
    createNewPlayDirectoryName = signal("");
    createNewPlayDirectoryErrorText = signal(null);
  }

  @override
  void dispose() {
    newPlayListController.dispose();
    createNewPlayDirectoryName.dispose();
    createNewPlayDirectoryErrorText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: 10,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: const [
              Icon(Icons.playlist_play_rounded),
              Text("创建新的播放列表"),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Watch(
                  (context) => TextField(
                    controller: newPlayListController,
                    autofocus: true,
                    maxLines: 1,
                    scrollPadding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    onChanged: (value) {
                      createNewPlayDirectoryName.value = value; // 新增播放目录名称
                      if (value.isEmpty) {
                        // 新增播放目录名称为空时清除验证信息
                        createNewPlayDirectoryErrorText.value = null;
                      }
                    },
                    decoration: InputDecoration(
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      //获得焦点下划线设为蓝色
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      border: const OutlineInputBorder(),
                      // 新增播放目录名称验证信息
                      errorText: createNewPlayDirectoryErrorText.value,
                    ),
                  ),
                ),
              ),

              const Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
              Watch(
                (context) => Padding(
                  // 新增播放目录名称验证不通过时显示错误信息导致输入框上移，因此按钮也同步上移
                  padding:
                      createNewPlayDirectoryErrorText.value == null ||
                          createNewPlayDirectoryErrorText.value!.isEmpty
                      ? EdgeInsets.zero
                      : const EdgeInsets.only(bottom: 22.0),
                  child: ElevatedButton(
                    // 新增播放目录名称为空时不可点击创建按钮
                    onPressed: createNewPlayDirectoryName.value.isEmpty
                        ? null
                        : () {
                            String text = newPlayListController.text.trim();
                            if (text.isNotEmpty) {
                              var appDirectoryModel = AppDirectoryModel(
                                path: text,
                                name: text,
                                fileNumber: 0,
                                appDirectorySourceType:
                                    AppDirectorySourceType.playDirectory,
                              );
                              createNewPlayDirectoryErrorText.value = viewModel
                                  .addPlayDirectory(appDirectoryModel);
                              if (createNewPlayDirectoryErrorText.value ==
                                      null ||
                                  createNewPlayDirectoryErrorText
                                      .value!
                                      .isEmpty) {
                                newPlayListController.text = "";
                                createNewPlayDirectoryName.value = "";
                                widget.createdCallBack?.call(appDirectoryModel);
                                Navigator.of(context).pop();
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                    ),
                    child: const Text("创建"),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
