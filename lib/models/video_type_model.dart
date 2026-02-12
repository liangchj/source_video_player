import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';

import 'filter_criteria_list_model.dart';

class VideoTypeModel {
  final String id;
  final String? enName;
  final String name;
  final String? parentId;

  FilterCriteriaListModel? childType;

  VideoTypeModel({
    required this.id,
    this.enName,
    required this.name,
    this.parentId,
    this.childType,
  });
  factory VideoTypeModel.fromJson(Map<String, dynamic> json) {
    FilterCriteriaListModel? childType;
    var childTypeVar = json['childType'];
    if (childTypeVar != null) {
      Map<String, dynamic> childTypeMap = DataTypeConvertUtils.toMapStrDyMap(
        childTypeVar,
      );

      childType = FilterCriteriaListModel.fromJson(childTypeMap);
    }
    return VideoTypeModel(
      id: (json['id'] ?? "").toString(),
      enName: json['enName'] ?? "",
      name: json['name'],
      parentId: (json['parentId'] ?? "").toString(),
      childType: childType,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enName': enName,
      'name': name,
      'parentId': parentId,
      "childType": childType?.toJson(),
    };
  }
}
