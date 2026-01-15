import 'package:flutter/material.dart';

class KeyValueRow extends StatelessWidget {
  const KeyValueRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.labelStyle,
    this.valueStyle,
    this.iconColor,
    this.iconSize = 16,
    this.iconSpacing = 8,
    this.columnSpacing = 8,
    this.labelFlex = 4,
    this.valueFlex = 6,
    this.stackBreakpoint = 280,
    this.stackTextScale = 1.25,
    this.showColon = true,
  });

  final String label;
  final String value;
  final IconData? icon;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final Color? iconColor;
  final double iconSize;
  final double iconSpacing;
  final double columnSpacing;
  final int labelFlex;
  final int valueFlex;
  final double stackBreakpoint;
  final double stackTextScale;
  final bool showColon;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScaleFactorOf(context);
    final labelText = showColon ? '$label:' : label;

    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldStack = constraints.maxWidth < stackBreakpoint ||
            textScale >= stackTextScale;
        if (shouldStack) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Icon(icon, size: iconSize, color: iconColor),
                SizedBox(width: iconSpacing),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(labelText, style: labelStyle),
                    const SizedBox(height: 2),
                    Text(value, style: valueStyle),
                  ],
                ),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, size: iconSize, color: iconColor),
              SizedBox(width: iconSpacing),
            ],
            Expanded(
              flex: labelFlex,
              child: Text(labelText, style: labelStyle),
            ),
            SizedBox(width: columnSpacing),
            Expanded(
              flex: valueFlex,
              child: Text(value, style: valueStyle),
            ),
          ],
        );
      },
    );
  }
}
