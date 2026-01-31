import 'package:flutter/material.dart';

import '../resources/enum.dart';

/*mShowToast(
    {required BuildContext context,
      required String text,
      required ToastType toastType,
      int? duration,
      StyledToastAnimation? animation}) {
  if (text.isEmpty) return;
  final mediaQuery = MediaQuery.of(context);
  final keyboardHeight = mediaQuery.viewInsets.bottom;
  final double offsetFromCenter = (keyboardHeight > 0)
      ? -(keyboardHeight / 2 + 60) // place toast above keyboard
      : 0;

  showToast(
    text.length < 200 ? text : '${text.substring(0, 200)}...',
    context: context,
    backgroundColor: getToastColor(toastType),
    animation: animation ?? StyledToastAnimation.slideFromBottom,
    reverseAnimation: StyledToastAnimation.slideToBottom,
    startOffset: const Offset(0.0, 3.0),
    reverseEndOffset: const Offset(0.0, 3.0),
    position: StyledToastPosition(offset: offsetFromCenter),
    duration: Duration(seconds: duration ?? 3),
    animDuration: const Duration(seconds: 1),
    curve: Curves.elasticOut,
    reverseCurve: Curves.fastOutSlowIn,
    textStyle: AppTextStyles.p6.copyWith(
      color: toastType == ToastType.warning ? AppColors.text : AppColors.white,
    ),
  );
}*/

/*
Color getToastColor(ToastType type) {
  switch (type) {
    case ToastType.warning:
      return AppColors.toastWarningMsgColor;
    case ToastType.success:
      return AppColors.toastSuccessMsgColor.withOpacity(0.9);
    default:
      return AppColors.toastErrorMsgColor;
  }
}*/
