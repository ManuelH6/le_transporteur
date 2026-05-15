import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_image.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.h,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sp),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'À Propos',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18.sp,
                ),
              ),
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.primary, Color(0xFFFF8C42)],
                      ),
                    ),
                  ),
                  Center(
                    child: Hero(
                      tag: 'app_logo_about',
                      child: Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.local_shipping_rounded,
                          size: 60.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIntroSection(isDark),
                  SizedBox(height: 32.h),
                  _buildSectionTitle('Nos Services & Expertise', Icons.auto_awesome_rounded, isDark),
                  SizedBox(height: 16.h),
                  _buildServiceCard(
                    'Livraison Express',
                    'Transport rapide de colis, courriers et repas avec une fiabilité garantie.',
                    Icons.bolt_rounded,
                    isDark,
                  ),
                  _buildServiceCard(
                    'Distribution Postale',
                    'Agréé par l\'ARCEP pour la distribution de documents officiels, factures et courriers.',
                    Icons.description_rounded,
                    isDark,
                  ),
                  _buildServiceCard(
                    'Logistique & Entreposage',
                    'Solutions complètes incluant le stockage, la gestion de stock et le suivi en temps réel.',
                    Icons.inventory_2_rounded,
                    isDark,
                  ),
                  SizedBox(height: 32.h),
                  _buildSectionTitle('Notre Présence', Icons.public_rounded, isDark),
                  SizedBox(height: 16.h),
                  _buildPresenceSection(isDark),
                  SizedBox(height: 32.h),
                  _buildSectionTitle('Historique', Icons.history_rounded, isDark),
                  SizedBox(height: 16.h),
                  _buildTimeline(isDark),
                  SizedBox(height: 40.h),
                  _buildFooter(isDark),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Le Transporteur',
          style: GoogleFonts.poppins(
            fontSize: 26.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.text,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Bâtir l\'Afrique de demain, aujourd\'hui.',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          'Le Transporteur est une enseigne spécialisée du Groupe SEED, dédiée à la logistique et à la distribution express. Notre ambition est d\'être un acteur majeur du développement économique africain en créant un écosystème plus fort, souverain et durable.',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            height: 1.6,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20.sp),
        SizedBox(width: 10.w),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(String title, String desc, IconData icon, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.grey[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.text,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  desc,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresenceSection(bool isDark) {
    final countries = [
      {'name': 'Bénin', 'city': 'Cotonou (Siège)', 'flag': '🇧🇯'},
      {'name': 'Togo', 'city': 'Lomé', 'flag': '🇹🇬'},
      {'name': 'Congo', 'city': 'Brazzaville', 'flag': '🇨🇬'},
    ];

    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: countries.map((c) => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
          border: Border.all(color: isDark ? Colors.grey[800]! : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(c['flag']!, style: TextStyle(fontSize: 18.sp)),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c['name']!,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.text,
                  ),
                ),
                Text(
                  c['city']!,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildTimeline(bool isDark) {
    final events = [
      {'year': '2014', 'title': 'Fondation du Groupe SEED', 'desc': 'Début de l\'aventure entrepreneuriale.'},
      {'year': 'Jan 2019', 'title': 'Enregistrement', 'desc': 'Création officielle du service Le Transporteur au Bénin.'},
      {'year': 'Sep 2019', 'title': 'Lancement Officiel', 'desc': 'Début des opérations de livraison à Cotonou.'},
    ];

    return Column(
      children: events.map((e) => Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 2.w,
                  height: 40.h,
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e['year']!,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    e['title']!,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkText : AppColors.text,
                    ),
                  ),
                  Text(
                    e['desc']!,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Column(
      children: [
        const Divider(),
        SizedBox(height: 24.h),
        Center(
          child: Text(
            'Pour plus d\'informations, visitez',
            style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey),
          ),
        ),
        SizedBox(height: 8.h),
        Center(
          child: InkWell(
            onTap: () => _launchUrl('https://groupe-seed.com/'),
            child: Text(
              'www.groupe-seed.com',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        SizedBox(height: 32.h),
        Text(
          'Version 1.1.0',
          style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey[400]),
        ),
      ],
    );
  }
}
