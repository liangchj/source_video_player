import 'dart:io';

import '../enum/file_format.dart';
import '../models/app_directory_model.dart';
import '../models/app_file_model.dart';

class FileDirectoryUtils {
  /// 获取指定目录下所有文件和目录
  static Future<List<File>> getFileAndDirByPath(
    String path, {
    FileFormat? fileFormat,
  }) async {
    List<File> fileList = [];
    List<File> dirList = [];
    if (path.isEmpty) {
      return dirList;
    }
    Directory directory = Directory(path);
    if (!directory.existsSync()) {
      return dirList;
    }
    Stream<FileSystemEntity> list = directory.list(recursive: false);
    if (fileFormat == null) {
      await list.forEach((entity) {
        fileList.add(File(entity.path));
      });
    } else {
      await list.forEach((entity) {
        FileSystemEntityType type = FileSystemEntity.typeSync(entity.path);
        if (type == FileSystemEntityType.file) {
          /// 只获取指定格式
          String format = entity.path.split(".").last;
          List<String> formatList = fileFormat.formatList;
          if (formatList.contains(format.toLowerCase())) {
            fileList.add(File(entity.path));
          }
        } else {
          dirList.add(File(entity.path));
        }
      });
    }
    dirList.sort((File a, File b) {
      return a.path
          .split("/")
          .last
          .toLowerCase()
          .compareTo(b.path.split("/").last.toLowerCase());
    });
    fileList.sort((File a, File b) {
      return a.path
          .split("/")
          .last
          .toLowerCase()
          .compareTo(b.path.split("/").last.toLowerCase());
    });
    dirList.addAll(fileList);
    return dirList;
  }

  /// 根据父级路径获取目录下指定文件格式类型的所有非空目录
  /// [path] 父级目录
  /// [fileFormat] 文件格式
  /// [recursive] 递归获取
  static Future<List<AppDirectoryModel>> getNotEmptyDirListByPathAndFormatSync({
    required String path,
    bool recursive = false,
    FileFormat? fileFormat,
  }) async {
    List<AppDirectoryModel> dirList = [];

    /// 父级目录是否为空
    if (path.isEmpty) {
      return dirList;
    }

    /// Directory直接是获取目录下，没有包含自己
    Directory directory = Directory(path);
    if (!directory.existsSync()) {
      return dirList;
    }
    FileStat statSync = directory.statSync();
    if (statSync.type != FileSystemEntityType.directory) {
      return dirList;
    }
    String name = path.contains("/") ? path.split("/").last : path;
    // 先获取当前目录（Directory直接是获取目录下，没有包含自己）
    List<AppFileModel> fileList = await getFileListByPath(
      path: path,
      fileFormat: fileFormat,
    );

    /// 目录下存在对应文件不为空的才放入list
    if (fileList.isNotEmpty) {
      dirList.add(
        AppDirectoryModel(path: path, name: name, fileNumber: fileList.length),
      );
    }
    Stream<FileSystemEntity> list = directory.list(recursive: recursive);
    await list.forEach((entity) async {
      FileSystemEntityType type = await FileSystemEntity.type(entity.path);
      if (type == FileSystemEntityType.directory) {
        List<AppFileModel> fileList = await getFileListByPath(
          path: path,
          fileFormat: fileFormat,
        );

        /// 目录下对的文件不为空的才放入list
        if (fileList.isNotEmpty) {
          dirList.add(
            AppDirectoryModel(
              path: path,
              name: name,
              fileNumber: fileList.length,
            ),
          );
        }
      }
    });
    dirList.sort((AppDirectoryModel a, AppDirectoryModel b) {
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return dirList;
  }

  /// 获取指定目录下所有的文件
  static List<AppFileModel> getFileListByPathSync({
    required String path,
    FileFormat? fileFormat,
    bool getBarrage = false,
  }) {
    List<AppFileModel> fileList = [];
    if (path.isEmpty) {
      return fileList;
    }
    Directory directory = Directory(path);
    if (!directory.existsSync()) {
      return fileList;
    }
    List<FileSystemEntity> listSync = directory.listSync(recursive: false);
    for (FileSystemEntity entity in listSync) {
      FileSystemEntityType type = FileSystemEntity.typeSync(entity.path);
      if (type == FileSystemEntityType.file) {
        bool isAdd = false;

        /// 只获取指定格式
        if (fileFormat != null) {
          String format = entity.path.split(".").last;
          List<String> formatList = fileFormat.formatList;
          if (formatList.contains(format.toLowerCase())) {
            isAdd = true;
          } else {
            isAdd = false;
          }
        } else {
          isAdd = true;
        }
        if (isAdd) {
          String entryPath = entity.path;
          String fullName = entryPath.contains("/")
              ? entryPath.split("/").last
              : entryPath;
          String name = fullName.contains(".")
              ? fullName.substring(0, fullName.lastIndexOf("."))
              : fullName;
          String? barragePath;
          if (getBarrage) {
            // barragePath = DanmakuMMKVCache.getInstance().getString(entity.path);
          }
          fileList.add(
            AppFileModel(
              path: entity.path,
              fullName: fullName,
              name: name,
              directory: entity.parent.path,
              barragePath: barragePath,
            ),
          );
        }
      }
    }
    fileList.sort((AppFileModel a, AppFileModel b) {
      return a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
    });
    return fileList;
  }

  /// 获取指定目录下所有的文件 (仅一层)
  static Future<List<AppFileModel>> getFileListByPath({
    required String path,
    FileFormat? fileFormat,
    bool getBarrage = false,
  }) async {
    List<AppFileModel> fileList = [];
    if (path.isEmpty) {
      return fileList;
    }
    Directory directory = Directory(path);
    if (!directory.existsSync()) {
      return fileList;
    }

    Stream<FileSystemEntity> list = directory.list(recursive: false);
    await list.forEach((entity) {
      // FileSystemEntityType type = await FileSystemEntity.type(entity.path);
      FileSystemEntityType type = FileSystemEntity.typeSync(entity.path);
      if (type == FileSystemEntityType.file) {
        bool isAdd = false;

        /// 只获取指定格式
        if (fileFormat != null) {
          String format = entity.path.split(".").last;
          List<String> formatList = fileFormat.formatList;
          if (formatList.contains(format.toLowerCase())) {
            isAdd = true;
          } else {
            isAdd = false;
          }
        } else {
          isAdd = true;
        }
        if (isAdd) {
          String entryPath = entity.path;
          String fullName = entryPath.contains("/")
              ? entryPath.split("/").last
              : entryPath;
          String name = fullName.contains(".")
              ? fullName.substring(0, fullName.lastIndexOf("."))
              : fullName;
          String? barragePath;
          if (getBarrage) {
            // barragePath = DanmakuMMKVCache.getInstance().getString(entity.path);
          }
          fileList.add(
            AppFileModel(
              path: entity.path,
              fullName: fullName,
              name: name,
              directory: entity.parent.path,
              barragePath: barragePath,
            ),
          );
        }
      }
    });
    fileList.sort((AppFileModel a, AppFileModel b) {
      return a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
    });
    return fileList;
  }
}
