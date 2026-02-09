import 'dart:io';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../enum/file_format.dart';
import '../view_model/my_file_selector_view_model.dart';

class MyFileSelector extends StatefulWidget {
  const MyFileSelector({
    super.key,
    required this.directory,
    this.fileFormat,
    this.onConfirm,
    this.onCancel,
    this.onTapFile,
  });
  final Directory directory;
  final FileFormat? fileFormat;
  final Function? onConfirm;
  final Function? onCancel;
  final Function(File)? onTapFile;

  @override
  State<MyFileSelector> createState() => _MyFileSelectorState();
}

class _MyFileSelectorState extends State<MyFileSelector> {
  late final MyFileSelectorViewModel fileSelectorViewModel;
  late ScrollController scrollController;

  @override
  void initState() {
    fileSelectorViewModel = MyFileSelectorViewModel();
    fileSelectorViewModel.getFileAndDirByPath(
      widget.directory.path,
      fileFormat: widget.fileFormat,
    );
    fileSelectorViewModel.createCurrentDirectoryNav(
      widget.directory,
      fileFormat: widget.fileFormat,
    );

    scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Watch((context) {
            if (fileSelectorViewModel.navLoadingState.value.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Row(
              children: [
                fileSelectorViewModel
                    .directoryNavList
                    .value[fileSelectorViewModel.directoryNavList.value.length -
                    1],
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: fileSelectorViewModel.directoryNavList
                          .getRange(
                            0,
                            fileSelectorViewModel
                                    .directoryNavList
                                    .value
                                    .length -
                                1,
                          )
                          .toList()
                          .reversed
                          .map((e) => e)
                          .toList(),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
        Expanded(
          child: Watch((context) {
            if (fileSelectorViewModel.navLoadingState.value.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
              controller: scrollController,
              itemExtent: 50,
              itemCount: fileSelectorViewModel.fileList.value.length,
              itemBuilder: (context, index) {
                File file = fileSelectorViewModel.fileList.value[index];
                var isFile = FileSystemEntity.isFileSync(file.path);
                return InkWell(
                  onTap: () {
                    if (isFile) {
                      widget.onTapFile?.call(file);
                    } else {
                      fileSelectorViewModel.createCurrentDirectoryNav(
                        Directory(file.path),
                        firstEntry: true,
                        fileFormat: widget.fileFormat,
                      );
                      fileSelectorViewModel.getFileAndDirByPath(
                        file.path,
                        fileFormat: widget.fileFormat,
                      );
                    }
                  },
                  child: ListTile(
                    horizontalTitleGap: 0,
                    // contentPadding: const EdgeInsets.only(left: 16, right: 0),
                    leading: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(
                        Icons.file_copy_rounded,
                        size: 40,
                        color: Colors.black26,
                      ),
                    ),
                    title: Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: Text(
                        file.path.split("/").last,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
