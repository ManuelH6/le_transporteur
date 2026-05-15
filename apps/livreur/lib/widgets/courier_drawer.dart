import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/api/v1/auth_api.dart';
import 'package:shared_le_transporteur/models/user.dart';
import 'package:shared_le_transporteur/core/widgets/user_drawer_header.dart';
import 'package:shared_le_transporteur/screens/info/about_screen.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Drawer(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              children: [
                _buildSectionTitle(context, 'Navigation'),
                _buildMenuItem(context, 0, Icons.dashboard_outlined, 'Tableau de bord'),
                _buildMenuItem(context, 1, Icons.list_alt_outlined, 'Courses disponibles'),
                _buildMenuItem(context, 2, Icons.local_shipping_outlined, 'Mes Courses'),
                _buildMenuItem(context, 3, Icons.settings_outlined, 'Paramètres'),
                
                Divider(color: isDark ? Colors.grey[800] : Colors.grey[200]),
                _buildSectionTitle(context, 'Compte'),
                _buildMenuItem(context, -1, Icons.person_outline, 'Mon Profil', onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
                }),
                
                Divider(color: isDark ? Colors.grey[800] : Colors.grey[200]),
                _buildSectionTitle(context, 'Support'),
                _buildMenuItem(context, -1, Icons.help_outline, 'Aide', onTap: () {}),
                _buildMenuItem(context, -1, Icons.info_outline, 'À propos', onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
                }),
              ],
            ),
          ),
          _buildLogoutItem(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return UserDrawerHeader(
      user: user,
      onTapProfile: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
      },
      onTapEdit: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(left: 24.w, top: 16.h, bottom: 8.h),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 11.sp, 
          fontWeight: FontWeight.bold, 
          color: isDark ? Colors.grey[600] : Colors.grey[500], 
          letterSpacing: 1.2
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, int index, IconData icon, String title, {VoidCallback? onTap}) {
    final isSelected = currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w),
      leading: Icon(
        icon, 
        color: isSelected ? AppColors.primary : (isDark ? Colors.grey[400] : Colors.grey[600]), 
        size: 22.sp
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? AppColors.primary : (isDark ? AppColors.darkText : Colors.black87),
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
