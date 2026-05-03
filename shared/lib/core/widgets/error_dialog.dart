// shared/lib/core/widgets/error_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';

class ErrorDialog extends StatefulWidget {
  final String title;
  final String message;
  final String? details;
  final String? actionLabel;
  final VoidCallback? onAction;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.details,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<ErrorDialog> createState() => _ErrorDialogState();
}

class _ErrorDialogState extends State<ErrorDialog> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.r,
              offset: Offset(0, 10.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // To make the dialog compact
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 40.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              widget.title,
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              widget.message,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.details != null && widget.details!.isNotEmpty) ...[
              SizedBox(height: 12.h),
              TextButton(
                onPressed: () => setState(() => _showDetails = !_showDetails),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _showDetails ? "Masquer les détails" : "Voir les détails techniques",
                      style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.blue),
                    ),
                    Icon(
                      _showDetails ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 16.sp,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
              if (_showDetails)
                Container(
                  constraints: BoxConstraints(maxHeight: 150.h),
                  width: double.infinity,
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      widget.details!,
                      style: GoogleFonts.firaCode(
                        fontSize: 10.sp,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ),
            ],
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "OK",
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (widget.actionLabel != null && widget.onAction != null) ...[
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog first
                    widget.onAction!(); // Execute action
                  },
                  child: Text(
                    widget.actionLabel!,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
