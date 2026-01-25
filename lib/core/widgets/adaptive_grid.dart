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
    this.preferSingleColumnOnSmall = true,
  });

  final List<Widget> children;
  final double minItemWidth;
  final int maxColumns;
  final double baseChildAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final bool preferSingleColumnOnSmall;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final effectiveScale = textScale < 1.0 ? 1.0 : textScale;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final targetWidth = minItemWidth * effectiveScale;
        final rawColumns =
            ((maxWidth + crossAxisSpacing) / (targetWidth + crossAxisSpacing))
                .floor();
        final isSmallScreen = screenWidth < 360;
        final columns = (isSmallScreen && preferSingleColumnOnSmall)
            ? 1
            : rawColumns.clamp(1, maxColumns).toInt();

        // Adjust aspect ratio based on screen size and text scale
        // For small screens, increase aspect ratio to make cards less wide
        // For large text, also increase aspect ratio to prevent cards from becoming too tall
        final smallScreenBoost = screenWidth < 360
            ? (columns == 1 ? 1.0 : 1.15)
            : screenWidth < 400
            ? 1.08
            : 1.0;
        final textScaleAdjustment = effectiveScale > 1.0
            ? 1.0 + ((effectiveScale - 1.0) * 0.3)
            : 1.0;
        final aspectRatio =
            (baseChildAspectRatio * smallScreenBoost * textScaleAdjustment);

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
