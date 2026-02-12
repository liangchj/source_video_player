import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';

import 'filter_criteria_item_model.dart';

class FilterCriteriaListModel extends FilterCriteriaModel {
  List<FilterCriteriaItemModel> filterCriteriaItemList;

  FilterCriteriaListModel({
    required super.enName,
    required super.name,
    required this.filterCriteriaItemList,
    super.multiples,
  });
  FilterCriteriaListModel copyWidth({
    String? enName,
    String? name,
    List<FilterCriteriaItemModel>? filterCriteriaItemList,
    bool? multiples,
  }) {
    return FilterCriteriaListModel(
      enName: enName ?? this.enName,
      name: name ?? this.name,
      filterCriteriaItemList:
          filterCriteriaItemList ?? this.filterCriteriaItemList,
      multiples: multiples ?? false,
    );
  }

  factory FilterCriteriaListModel.fromJson(Map<String, dynamic> json) {
    var filterCriteriaItemListVar = json['filterCriteriaItemList'];
    List<Map<String, dynamic>> filterCriteriaItems = [];
    if (filterCriteriaItemListVar != null) {
      filterCriteriaItems = DataTypeConvertUtils.toListMapStrDyMap(
        filterCriteriaItemListVar,
      );
    }
    List<FilterCriteriaItemModel> filterCriteriaItemList = [];
    if (filterCriteriaItems.isNotEmpty) {
      filterCriteriaItemList = filterCriteriaItems
          .map((e) => FilterCriteriaItemModel.fromJson(e))
          .toList();
    }
    var multiples = json['multiples'];
    return FilterCriteriaListModel(
      enName: json['enName'] ?? "",
      name: json['name'],
      filterCriteriaItemList: filterCriteriaItemList,
      multiples: multiples == null ? false : bool.tryParse(multiples) ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'enName': enName,
      'name': name,
      'filterCriteriaItemList': filterCriteriaItemModelListToJson(
        filterCriteriaItemList,
      ),
      'multiples': multiples,
    };
  }
}
