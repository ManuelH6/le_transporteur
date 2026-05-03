import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_le_transporteur/screens/settings/pdf_viewer_screen.dart';

class LegalDocumentsScreen extends StatelessWidget {
  const LegalDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Documents légaux",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildDocItem(
            context,
            "Conditions Générales d'Utilisation",
            "Règles d'utilisation de la plateforme",
            'packages/shared_le_transporteur/assets/docs/general_use.pdf',
          ),
          SizedBox(height: 12.h),
          _buildDocItem(
            context,
            "Mentions Légales",
            "Informations sur l'éditeur",
            'packages/shared_le_transporteur/assets/docs/legal_mentions.pdf',
          ),
          SizedBox(height: 12.h),
          _buildDocItem(
            context,
            "Politique de confidentialité",
            "Protection de vos données personnelles",
            'packages/shared_le_transporteur/assets/docs/politics.pdf',
          ),
        ],
      ),
    );
  }

  Widget _buildDocItem(BuildContext context, String title, String subtitle, String assetPath) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.picture_as_pdf, color: Colors.red.shade400),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15.sp),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey),
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
