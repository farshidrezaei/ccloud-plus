import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';

class ResponsiveMediaGrid extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final ScrollController? controller;
  final bool hasMore;
  final EdgeInsetsGeometry padding;
  final double cardWidth;
  final double childAspectRatio;
  final double spacing;
  final int minColumns;
  final int maxColumns;
  final Widget? header;

  const ResponsiveMediaGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.hasMore = false,
    this.padding = AppDimensions.gridPadding,
    this.cardWidth = AppDimensions.cardWidth,
    this.childAspectRatio = AppDimensions.cardAspectRatio,
    this.spacing = AppDimensions.gridSpacing,
    this.minColumns = AppDimensions.minGridColumns,
    this.maxColumns = AppDimensions.maxGridColumns,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = padding.horizontal;
        final availableWidth = constraints.maxWidth - horizontalPadding;
        final crossAxisCount =
            ((availableWidth + spacing) / (cardWidth + spacing))
                .floor()
                .toInt();

        final count = crossAxisCount.clamp(minColumns, maxColumns);

        if (header != null) {
          return CustomScrollView(
            controller: controller,
            slivers: [
              SliverToBoxAdapter(child: header),
              SliverPadding(
                padding: padding,
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: count,
                    childAspectRatio: childAspectRatio,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index == itemCount) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return itemBuilder(context, index);
                  }, childCount: itemCount + (hasMore ? 1 : 0)),
                ),
              ),
            ],
          );
        }

        return GridView.builder(
          controller: controller,
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
          ),
          itemCount: itemCount + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == itemCount) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return itemBuilder(context, index);
          },
        );
      },
    );
  }
}
