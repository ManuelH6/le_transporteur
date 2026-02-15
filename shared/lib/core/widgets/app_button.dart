// lib/core/widgets/app_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;

  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          if (isPrimary)
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Material(
        color: isPrimary ? AppColors.primary : AppColors.white,
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
                    color: isPrimary ? AppColors.white : AppColors.primary,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
