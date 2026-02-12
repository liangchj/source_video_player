import 'package:flutter/material.dart';

import '../commons/widget_style_commons.dart';

class ErrorHitWidget extends StatelessWidget {
  const ErrorHitWidget({
    super.key,
    required this.errorMsg,
    this.refreshButtonTitle,
    this.padding,
    this.onRefresh,
    this.msgMaxHeight,
  });
  final String errorMsg;
  final String? refreshButtonTitle;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onRefresh;
  final double? msgMaxHeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.all(WidgetStyleCommons.safeSpace),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => onRefresh?.call(),
                icon: Icon(Icons.refresh_rounded, size: 30),
                tooltip: refreshButtonTitle,
              ),
              // 测量文本高度
              LayoutBuilder(
                builder: (context, innerConstraints) {
                  final textPainter = TextPainter(
                    text: TextSpan(
                      text: errorMsg,
                      style: DefaultTextStyle.of(context).style,
                    ),
                    maxLines: null,
                    textDirection: TextDirection.ltr,
                  )..layout(maxWidth: innerConstraints.maxWidth);

                  // 如果文本高度超过限制高度，则使用滚动视图
                  if (textPainter.size.height > (msgMaxHeight ?? constraints.maxHeight * 0.6)) {
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: msgMaxHeight ?? constraints.maxHeight * 0.6,
                      ),
                      child: SingleChildScrollView(
                        child: Text(errorMsg),
                      ),
                    );
                  } else {
                    // 否则直接显示文本并居中
                    return Text(errorMsg);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
