import 'package:flutter/material.dart';

class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 150,
    this.maxColumns = 4,
    this.baseChildAspectRatio = 1.2,
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 12,
  });

  final List<Widget> children;
  final double minItemWidth;
  final int maxColumns;
  final double baseChildAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    final textScale = MediaQuery.textScaleFactorOf(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final effectiveScale = textScale < 1.0 ? 1.0 : textScale;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final targetWidth = minItemWidth * effectiveScale;
        final rawColumns = ((maxWidth + crossAxisSpacing) /
                (targetWidth + crossAxisSpacing))
            .floor();
        final columns = rawColumns.clamp(1, maxColumns).toInt();

        // Increase aspect ratio for small screens to make cards taller/less wide
        final smallScreenBoost = screenWidth < 360 ? 1.15 :
                                 screenWidth < 400 ? 1.08 : 1.0;
        final aspectRatio = (baseChildAspectRatio * smallScreenBoost) / effectiveScale;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: children.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            childAspectRatio: aspectRatio,
          ),
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}
