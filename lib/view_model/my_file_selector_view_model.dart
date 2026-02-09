import 'dart:io';

import 'package:flutter/material.dart';
import 'package:signals/signals.dart';

import '../enum/file_format.dart';
import '../models/loading_state_model.dart';
import '../utils/file_directory_utils.dart';
import 'base_view_model.dart';

class MyFileSelectorViewModel extends BaseViewModel {
  final Signal<LoadingStateModel> loadingState = Signal<LoadingStateModel>(
    LoadingStateModel(),
  );
  final Signal<LoadingStateModel> navLoadingState = Signal<LoadingStateModel>(
    LoadingStateModel(),
  );

  final Signal<List<File>> fileList = Signal<List<File>>([]);

  // 当前目录导航栏列表
  final Signal<List<Widget>> directoryNavList = Signal<List<Widget>>([]);

  @override
  void init() {
    // TODO: implement init
  }
  @override
  void dispose() {
    loadingState.dispose();
    navLoadingState.dispose();
    fileList.dispose();
  }

  /// 获取指定目录下所有的文件和目录
  Future<void> getFileAndDirByPath(
    String path, {
    FileFormat? fileFormat,
  }) async {
    try {
      loadingState.value = loadingState.value.copyWith(
        loading: true,
        data: null,
      );
      fileList.clear();
      var fileAndDirList = await FileDirectoryUtils.getFileAndDirByPath(
        path,
        fileFormat: fileFormat,
      );
      if (fileAndDirList.isNotEmpty) {
        fileList.addAll(fileAndDirList);
      }
    } finally {
      loadingState.value = loadingState.value.copyWith(loading: false);
    }
  }

  /// 生成当前目录导航栏
  void createCurrentDirectoryNav(
    Directory directory, {
    bool firstEntry = true,
    FileFormat? fileFormat,
  }) {
    if (firstEntry) {
      directoryNavList.value.clear();
    }
    try {
      navLoadingState.value = navLoadingState.value.copyWith(
        loading: true,
        data: null,
      );
      late String name;
      if (directory.path == "/storage/emulated/0") {
        name = "根目录";
      } else {
        name = directory.path.split('/').last;
      }
      if (directoryNavList.isEmpty) {
        directoryNavList.value.add(Row(children: [Text(name)]));
      } else {
        directoryNavList.value.add(
          Row(
            children: [
              InkWell(
                child: Text(
                  name,
                  maxLines: 1,
                  style: const TextStyle(color: Colors.blue),
                ),
                onTap: () {
                  createCurrentDirectoryNav(
                    Directory(directory.path),
                    firstEntry: true,
                    fileFormat: fileFormat,
                  );
                  // 获取当前目录下所有文件夹和文件
                  getFileAndDirByPath(directory.path, fileFormat: fileFormat);
                },
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        );
      }
      if (directory.path != "/storage/emulated/0") {
        createCurrentDirectoryNav(
          directory.parent,
          firstEntry: false,
          fileFormat: fileFormat,
        );
      }
    } finally {
      navLoadingState.value = navLoadingState.value.copyWith(loading: false);
    }
  }
}
