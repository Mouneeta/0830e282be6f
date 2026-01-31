import 'package:flutter/cupertino.dart';

import 'app_color.dart';


/// Custom text styles for the app
class AppTextStyles {
  static const double height = 1.4;

  static TextStyle base = const TextStyle(
    fontFamily: 'Rubik',
    height: height,
    fontWeight: FontWeight.w400,
  );

  static TextStyle h1 = base.copyWith(
    fontSize: 34,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  static TextStyle h2 = base.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  static TextStyle h3 = base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
  );

  static TextStyle p1 = base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
  );

  static TextStyle p2 = base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
  );

  static TextStyle p3 = base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  static TextStyle p4 = base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
  );

  static TextStyle p5 = base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
  );

  static TextStyle p6 = base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
  );

  static TextStyle p7 = base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
  );

  static TextStyle p9 = base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );

  static TextStyle p8 = base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static TextStyle p10 = base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w700,
  );

  static TextStyle p1Bold = base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static TextStyle p6Bold = p6.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.bold,
  );

  static TextStyle p7Bold = base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static TextStyle bold = base.copyWith(
    fontWeight: FontWeight.bold,
  );

  static TextStyle discountTab = TextStyle(
      fontFamily: 'RacingSansOne', height: height, color: AppColors.white);

  static TextStyle showcaseTitle = const TextStyle(
      fontFamily: 'Poppins',
      height: height,
      fontSize: 12,
      fontWeight: FontWeight.w700);

  static TextStyle showcaseSubTitle =
  const TextStyle(fontFamily: 'Poppins', height: height, fontSize: 10);

/// Add more [TextStyle]s below
}
