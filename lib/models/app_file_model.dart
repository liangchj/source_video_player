import 'dart:convert';
import 'dart:io';

List<AppFileModel> appFileModelListFromJson(String str) =>
    List<AppFileModel>.from(
      json.decode(str).map((x) => AppFileModel.fromJson(x)),
    );

String appFileModelListToJson(List<AppFileModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
/// 使用appFileModel避免与基础文件冲突
class AppFileModel {
  AppFileModel({
    required this.path,
    required this.fullName,
    required this.name,
    this.appFileSourceType = AppFileSourceType.localFile,
    required this.directory,
    this.barragePath,
    this.subtitlePath,
  });
  final String path;
  String fullName;
  String name;
  // 本地文件、播放列表文件
  AppFileSourceType appFileSourceType;
  String directory;
  String? barragePath;
  String? subtitlePath;

  factory AppFileModel.fromJson(Map<String, dynamic> json) => AppFileModel(
    path: json["path"] ?? "",
    fullName: json["fullName"] ?? "",
    directory: json["directory"] ?? "",
    barragePath: json["barragePath"],
    subtitlePath: json["subtitlePath"],
    name:
        json["name"] ??
        (json["fullName"].contains(".")
            ? json["fullName"].substring(0, json["fullName"].lastIndexOf("."))
            : json["fullName"] ?? ""),
  );

  Map<String, dynamic> toJson() => {
    "path": path,
    "fullName": fullName,
    "name": name,
    "directory": directory,
    "barragePath": barragePath,
    "subtitlePath": subtitlePath,
  };

  File get file => File(path);

  bool get isExist => file.existsSync();

  String get dir => file.parent.path;

  FileStat get stat => file.statSync();

  //文件创建日期
  DateTime get createTime => stat.accessed;
  //文件修改日期
  DateTime get modTime => stat.modified;

  // 文件的大小
  int get size => isExist ? stat.size : -1;
}

enum AppFileSourceType { localFile, playListFile }
