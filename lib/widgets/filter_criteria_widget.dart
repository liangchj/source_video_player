import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../models/filter_criteria_list_model.dart';
import '../view_model/net_resource_list_view_model.dart';

class FilterCriteriaWidget extends StatelessWidget {
  const FilterCriteriaWidget({
    super.key,
    this.activeTextColor,
    this.activeBackgroundColor,
    this.padding,
    this.textHorizontalPadding,
    this.textVerticalPadding,
    this.textBorderRadius,
    required this.viewModel,
  });
  final Color? activeTextColor;
  final Color? activeBackgroundColor;
  final EdgeInsetsGeometry? padding;
  final double? textHorizontalPadding;
  final double? textVerticalPadding;
  final BorderRadiusGeometry? textBorderRadius;
  final NetResourceListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Watch(
      (context) => Column(
        children: viewModel.filterCriteriaList.value.map((item) {
          return _createCriteriaListWidget(filterCriteriaModel: item);
        }).toList(),
      ),
    );
  }

  Widget _createCriteriaListWidget({
    required FilterCriteriaListModel filterCriteriaModel,
  }) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(vertical: 0, horizontal: 6.0),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: filterCriteriaModel.filterCriteriaItemList.map((e) {
                  return InkWell(
                    onTap: () {
                      if (!e.activated.value) {
                        e.activated.value = true;
                        // 不支持多选就需要将其他选中取消
                        if (filterCriteriaModel.multiples == null ||
                            !filterCriteriaModel.multiples!) {
                          for (var element
                              in filterCriteriaModel.filterCriteriaItemList) {
                            if (element.value != e.value) {
                              element.activated.value = false;
                            }
                          }
                        }
                        viewModel.changeFilterCriteria();
                      }
                    },
                    child: Watch(
                      (context) => Container(
                        padding: EdgeInsets.symmetric(
                          vertical: textVerticalPadding ?? 4.0,
                          horizontal: textHorizontalPadding ?? 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: e.activated.value
                              ? activeBackgroundColor ?? Colors.black12
                              : null,
                          borderRadius:
                              textBorderRadius ??
                              const BorderRadius.all(Radius.circular(4.0)),
                        ),
                        child: Text(
                          e.label,
                          style: TextStyle(
                            color: e.activated.value
                                ? activeTextColor ?? Colors.green
                                : null,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
