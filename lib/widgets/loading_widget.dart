import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
    this.padding,
    this.alignment,
    this.size,
    this.color,
    this.textWidget,
  });
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;
  final double? size;
  final Color? color;
  final Widget? textWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.only(bottom: 120),
      width: double.infinity,
      height: double.infinity,
      alignment: alignment ?? Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpinKitSpinningLines(
            size: size ?? 80,
            color: color ?? Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          if (textWidget != null) textWidget!,
        ],
      ),
    );
  }
}
