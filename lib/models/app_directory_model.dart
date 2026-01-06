import 'dart:convert';
import 'dart:io';

List<AppDirectoryModel> appDirectoryModelListFromJson(String str) =>
    List<AppDirectoryModel>.from(
      json.decode(str).map((x) => AppDirectoryModel.fromJson(x)),
    );

String appDirectoryModelListToJson(List<AppDirectoryModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

/// 目录
/// 加上前缀app，避免和系统目录冲突
class AppDirectoryModel<T> {
  AppDirectoryModel({
    required this.path,
    required this.name,
    this.fileNumber = 0,
    this.appDirectorySourceType = AppDirectorySourceType.localDirectory,
    this.assetPathEntity,
  });

  final String path;
  String name;
  int fileNumber;
  AppDirectorySourceType appDirectorySourceType;
  T? assetPathEntity;

  factory AppDirectoryModel.fromJson(Map<String, dynamic> json) =>
      AppDirectoryModel(
        path: json["path"] ?? "",
        name: json["name"] ?? "",
        fileNumber:
            json["fileNumber"] == null ||
                (json["fileNumber"] is String &&
                    double.tryParse(json["fileNumber"]) == null)
            ? 0
            : json["fileNumber"] is int
            ? json["fileNumber"]
            : int.parse(json["fileNumber"].toString()),
      );

  Map<String, dynamic> toJson() => {
    "path": path,
    "name": name,
    "fileNumber": fileNumber,
  };

  File get file => File(path);

  bool get isExist => file.existsSync();

  FileStat get stat => file.statSync();

  //文件创建日期
  DateTime get createTime => stat.accessed;
  //文件修改日期
  DateTime get modTime => stat.modified;
}

enum AppDirectorySourceType { localDirectory, playDirectory }
