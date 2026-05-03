import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/screens/settings/legal_documents_screen.dart';

class LegalNoticeWidget extends StatelessWidget {
  const LegalNoticeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Center(
        child: Text.rich(
          TextSpan(
            text: "En utilisant cette application, vous acceptez nos ",
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: Colors.grey[600],
            ),
            children: [
              TextSpan(
                text: "Documents légaux",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LegalDocumentsScreen()),
                    );
                  },
              ),
              const TextSpan(text: " (CGU, Confidentialité)."),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
