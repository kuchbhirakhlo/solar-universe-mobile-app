import 'package:flutter/material.dart';

/// Lays out [children] as a 2-column grid where each row's height is
/// determined by its tallest cell's actual content (via [IntrinsicHeight]),
/// instead of forcing a fixed `childAspectRatio` like [GridView.count] does.
///
/// A fixed aspect ratio breaks across different screen widths (text wraps
/// differently), font-scale/accessibility settings (larger system text needs
/// more height), and any future copy changes — the cell either overflows or
/// leaves awkward empty space. Sizing to intrinsic content avoids all of
/// that at the cost of not being lazily built, which is fine for the small,
/// fixed-length stat/feature lists this is used for.
class TwoColumnGrid extends StatelessWidget {
  final List<Widget> children;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const TwoColumnGrid({
    super.key,
    required this.children,
    this.mainAxisSpacing = 12,
    this.crossAxisSpacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 2) {
      final hasSecond = i + 1 < children.length;
      if (rows.isNotEmpty) rows.add(SizedBox(height: mainAxisSpacing));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: children[i]),
              SizedBox(width: crossAxisSpacing),
              Expanded(child: hasSecond ? children[i + 1] : const SizedBox.shrink()),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}
