import 'dart:convert';

import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';
import 'package:signals/signals.dart';

List<FilterCriteriaItemModel> filterCriteriaItemModelListFromJsonStr(
  String str,
) => List<FilterCriteriaItemModel>.from(
  json.decode(str).map((x) => FilterCriteriaItemModel.fromJson(x)),
);

List<FilterCriteriaItemModel> filterCriteriaItemModelListFromListJson(
  List<Map<String, dynamic>> list,
) => List<FilterCriteriaItemModel>.from(
  list.map((x) => FilterCriteriaItemModel.fromJson(x)),
);

String filterCriteriaItemModelListToJson(List<FilterCriteriaItemModel> data) =>
    json.encode(List<Map<String, dynamic>>.from(data.map((e) => e.toJson())));

class FilterCriteriaItemModel extends FilterCriteriaParamsModel {
  final Signal<bool> activated;

  FilterCriteriaItemModel({
    bool activated = false,
    required super.value,
    required super.label,
    super.parentValue,
  }) : activated = Signal(activated);

  factory FilterCriteriaItemModel.fromJson(Map<dynamic, dynamic> json) {
    var activated = json['activated'];

    return FilterCriteriaItemModel(
      activated: activated == null ? false : bool.tryParse(activated) ?? false,
      value: json['value'] ?? "",
      label: json['label'] ?? "",
      parentValue: json['parentValue'] ?? "",
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'activated': activated.value,
      'value': value,
      'label': label,
      'parentValue': parentValue,
    };
  }
}
