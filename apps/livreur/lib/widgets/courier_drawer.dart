import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/api/v1/auth_api.dart';
import 'package:shared_le_transporteur/models/user.dart';
import 'package:livreur_le_transporteur/pages/profile/profile_page.dart';
import 'package:livreur_le_transporteur/pages/auth/login_page.dart';

class CourierDrawer extends StatelessWidget {
  final User? user;
  final int currentIndex;
  final Function(int) onSelectItem;

  const CourierDrawer({
    super.key,
    required this.user,
    required this.currentIndex,
    required this.onSelectItem,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              children: [
                _buildSectionTitle('Navigation'),
                _buildMenuItem(0, Icons.dashboard_outlined, 'Tableau de bord'),
                _buildMenuItem(1, Icons.list_alt_outlined, 'Courses disponibles'),
                _buildMenuItem(2, Icons.local_shipping_outlined, 'Mes Courses'),
                _buildMenuItem(3, Icons.settings_outlined, 'Paramètres'),
                
                const Divider(),
                _buildSectionTitle('Compte'),
                _buildMenuItem(-1, Icons.person_outline, 'Mon Profil', onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
                }),
                
                const Divider(),
                _buildSectionTitle('Support'),
                _buildMenuItem(-1, Icons.help_outline, 'Aide', onTap: () {}),
                _buildMenuItem(-1, Icons.info_outline, 'À propos', onTap: () {}),
              ],
            ),
          ),
          _buildLogoutItem(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 60.h, bottom: 24.h, left: 24.w, right: 24.w),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFFFF8C42)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 35.r,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : "?",
              style: GoogleFonts.poppins(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            user?.name ?? 'Livreur',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          Text(
            user?.email ?? '...',
            style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontSize: 13.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 24.w, top: 16.h, bottom: 8.h),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String title, {VoidCallback? onTap}) {
    final isSelected = currentIndex == index;
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w),
      leading: Icon(icon, color: isSelected ? AppColors.primary : Colors.grey[600], size: 22.sp),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? AppColors.primary : Colors.black87,
        ),
      ),
      selected: isSelected,
      onTap: onTap ?? () {
        onSelectItem(index);
      },
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      child: InkWell(
        onTap: () async {
          await AuthApi().logout(null);
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          }
        },
        child: Row(
          children: [
            const Icon(Icons.logout_rounded, color: Colors.redAccent),
            SizedBox(width: 12.w),
            Text(
              'Déconnexion',
              style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }
}
