import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';
import 'package:flutter_player_ui/flutter_player_ui.dart';

class ApiSourceModel {
  // 来源api
  ApiConfigModel? api;
  // 当前api下有哪些资源列表
  final List<SourceGroupModel> playSourceGroupList;

  ApiSourceModel({this.api, required this.playSourceGroupList});

  factory ApiSourceModel.fromJson(Map<dynamic, dynamic> json) {
    List<SourceGroupModel> playSourceGroupList = [];
    var playSourceGroupListVar = json['playSourceGroupList'];
    if (playSourceGroupListVar != null) {
      /*List<Map<String, dynamic>> playSourceGroups =
          DataTypeConvertUtils.toListMapStrDyMap(playSourceGroupListVar);
      playSourceGroupList = playSourceGroups
          .map((e) => SourceGroupModel.fromJson(e))
          .toList();*/
      playSourceGroupList = sourceGroupModelListFromDynamic(
        playSourceGroupListVar,
      );
    }
    ApiConfigModel? api;
    var apiVar = json['api'];
    if (apiVar != null) {
      api = ApiConfigModel.fromJson(apiVar);
    }
    return ApiSourceModel(api: api, playSourceGroupList: playSourceGroupList);
  }
  Map<String, dynamic> toJson() {
    return {
      "api": api?.toJson(),
      "SourceGroupModel": playSourceGroupList.map((e) => e.toJson()).toList(),
    };
  }

  ApiInfoModel? get playerApi => api == null
      ? null
      : ApiInfoModel(
          url: api!.apiBaseModel.baseUrl,
          name: api!.apiBaseModel.name,
          enName: api!.apiBaseModel.enName,
        );

  ApiModel get playApi =>
      ApiModel(api: playerApi, sourceGroupList: playSourceGroupList);
}
