import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppBorders {
  // Border radius values
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusXXLarge = 32.0;
  static const double radiusRound = 999.0;

  // Border radius objects
  static const BorderRadius none = BorderRadius.zero;

  static const BorderRadius small = BorderRadius.all(
    Radius.circular(radiusSmall),
  );

  static const BorderRadius medium = BorderRadius.all(
    Radius.circular(radiusMedium),
  );

  static const BorderRadius large = BorderRadius.all(
    Radius.circular(radiusLarge),
  );

  static const BorderRadius xLarge = BorderRadius.all(
    Radius.circular(radiusXLarge),
  );

  static const BorderRadius xxLarge = BorderRadius.all(
    Radius.circular(radiusXXLarge),
  );

  static const BorderRadius round = BorderRadius.all(
    Radius.circular(radiusRound),
  );

  // Top only radius
  static const BorderRadius topSmall = BorderRadius.only(
    topLeft: Radius.circular(radiusSmall),
    topRight: Radius.circular(radiusSmall),
  );

  static const BorderRadius topMedium = BorderRadius.only(
    topLeft: Radius.circular(radiusMedium),
    topRight: Radius.circular(radiusMedium),
  );

  static const BorderRadius topLarge = BorderRadius.only(
    topLeft: Radius.circular(radiusLarge),
    topRight: Radius.circular(radiusLarge),
  );

  // Bottom only radius
  static const BorderRadius bottomSmall = BorderRadius.only(
    bottomLeft: Radius.circular(radiusSmall),
    bottomRight: Radius.circular(radiusSmall),
  );

  static const BorderRadius bottomMedium = BorderRadius.only(
    bottomLeft: Radius.circular(radiusMedium),
    bottomRight: Radius.circular(radiusMedium),
  );

  static const BorderRadius bottomLarge = BorderRadius.only(
    bottomLeft: Radius.circular(radiusLarge),
    bottomRight: Radius.circular(radiusLarge),
  );

  // Border width values
  static const double widthThin = 1.0;
  static const double widthMedium = 2.0;
  static const double widthThick = 3.0;
  static const double widthExtraThick = 4.0;

  // Border styles
  static const BorderSide noneSide = BorderSide.none;

  static const BorderSide thin = BorderSide(
    color: AppColors.border,
    width: widthThin,
  );

  static const BorderSide mediumSide = BorderSide(
    color: AppColors.border,
    width: widthMedium,
  );

  static const BorderSide thick = BorderSide(
    color: AppColors.border,
    width: widthThick,
  );

  static const BorderSide primary = BorderSide(
    color: AppColors.primary,
    width: widthThin,
  );

  static const BorderSide primaryThick = BorderSide(
    color: AppColors.primary,
    width: widthMedium,
  );

  static BorderSide get error =>
      BorderSide(color: AppColors.error, width: widthThin);

  static BorderSide get success =>
      BorderSide(color: AppColors.success, width: widthThin);

  static BorderSide get warning =>
      BorderSide(color: AppColors.warning, width: widthThin);

  // Complete border styles
  static const Border thinBorder = Border(
    top: thin,
    right: thin,
    bottom: thin,
    left: thin,
  );

  static const Border mediumBorder = Border(
    top: mediumSide,
    right: mediumSide,
    bottom: mediumSide,
    left: mediumSide,
  );

  static const Border primaryBorder = Border(
    top: primary,
    right: primary,
    bottom: primary,
    left: primary,
  );

  static const Border primaryThickBorder = Border(
    top: primaryThick,
    right: primaryThick,
    bottom: primaryThick,
    left: primaryThick,
  );

  // Custom border builder
  static BorderSide custom({
    required Color color,
    double width = widthThin,
    BorderStyle style = BorderStyle.solid,
  }) {
    return BorderSide(color: color, width: width, style: style);
  }

  // Custom border radius builder
  static BorderRadius customRadius({
    double? topLeft,
    double? topRight,
    double? bottomLeft,
    double? bottomRight,
    double? all,
  }) {
    if (all != null) {
      return BorderRadius.all(Radius.circular(all));
    }

    return BorderRadius.only(
      topLeft: Radius.circular(topLeft ?? 0),
      topRight: Radius.circular(topRight ?? 0),
      bottomLeft: Radius.circular(bottomLeft ?? 0),
      bottomRight: Radius.circular(bottomRight ?? 0),
    );
  }

  // Context-aware border methods
  static Border subtleBorder(BuildContext? context) {
    if (context != null) {
      return Border.all(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        width: widthThin,
      );
    }
    return thinBorder;
  }

  static BorderSide subtleSide(BuildContext? context) {
    if (context != null) {
      return BorderSide(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        width: widthThin,
      );
    }
    return thin;
  }
}
