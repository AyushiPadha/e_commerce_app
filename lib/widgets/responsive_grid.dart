import 'package:flutter/material.dart';

/// Computes a product-grid column count from the available width so the
/// same screens work on phones, unfolded foldables, and tablets/desktop.
int responsiveCrossAxisCount(double width) {
  if (width >= 1200) return 5;
  if (width >= 900) return 4;
  if (width >= 600) return 3;
  return 2;
}

/// A SliverGridDelegate that adapts column count to the current width.
SliverGridDelegateWithFixedCrossAxisCount responsiveSliverGridDelegate(
    BuildContext context,
    ) {
  final width = MediaQuery.of(context).size.width;
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: responsiveCrossAxisCount(width),
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    childAspectRatio: 0.62,
  );
}