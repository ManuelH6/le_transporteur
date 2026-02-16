// lib/core/widgets/app_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final Color? backgroundColor;
  final Color? textColor;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;
    final bgColor = isDisabled
        ? Colors.grey.shade300
        : (backgroundColor ?? (isPrimary ? AppColors.primary : AppColors.white));
    final txtColor = isDisabled
        ? Colors.grey.shade500
        : (textColor ?? (isPrimary ? AppColors.white : AppColors.primary));

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          if (isPrimary && backgroundColor == null && !isDisabled)
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            width: double.infinity,
            height: 56.h,
            alignment: Alignment.center,
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: txtColor,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
