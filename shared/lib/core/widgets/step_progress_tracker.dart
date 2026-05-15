import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';

class StepProgressTracker extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const StepProgressTracker({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        children: List.generate(steps.length, (index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;
          final isLast = index == steps.length - 1;

          return Column(
            children: [
              Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 24.w,
                        height: 24.w,
                        decoration: BoxDecoration(
                          color: isCompleted || isCurrent
                              ? AppColors.primary
                              : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCompleted ? Icons.check : Icons.circle,
                          size: isCompleted ? 14.sp : 8.sp,
                          color: Colors.white,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2.w,
                          height: 30.h,
                          color: isCompleted ? AppColors.primary : Colors.grey[300],
                        ),
                    ],
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          steps[index],
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: isCurrent || isCompleted ? FontWeight.bold : FontWeight.w500,
                            color: isCurrent || isCompleted
                                ? (isDark ? AppColors.darkText : AppColors.text)
                                : Colors.grey[500],
                          ),
                        ),
                        if (isCurrent)
                          Text(
                            "En cours",
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!isLast) SizedBox(height: 4.h),
            ],
          );
        }),
      ),
    );
  }
}
