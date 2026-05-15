import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_le_transporteur/screens/settings/pdf_viewer_screen.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';

class LegalDocumentsScreen extends StatelessWidget {
  const LegalDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Documents légaux",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.text,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : AppColors.text, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildDocItem(
            context,
            "Conditions Générales d'Utilisation",
            "Règles d'utilisation de la plateforme",
            'packages/shared_le_transporteur/assets/docs/general_use.pdf',
            isDark,
          ),
          SizedBox(height: 12.h),
          _buildDocItem(
            context,
            "Mentions Légales",
            "Informations sur l'éditeur",
            'packages/shared_le_transporteur/assets/docs/legal_mentions.pdf',
            isDark,
          ),
          SizedBox(height: 12.h),
          _buildDocItem(
            context,
            "Politique de confidentialité",
            "Protection de vos données personnelles",
            'packages/shared_le_transporteur/assets/docs/politics.pdf',
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildDocItem(BuildContext context, String title, String subtitle, String assetPath, bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.picture_as_pdf, color: Colors.red.shade400),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600, 
            fontSize: 15.sp,
            color: isDark ? AppColors.darkText : AppColors.text,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(fontSize: 12.sp, color: isDark ? Colors.grey[400] : Colors.grey),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfViewerScreen(
                assetPath: assetPath,
                title: title,
              ),
            ),
          );
        },
      ),
    );
  }
}
