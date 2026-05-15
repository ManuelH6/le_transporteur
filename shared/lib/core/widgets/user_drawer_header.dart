import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/models/user.dart';

class UserDrawerHeader extends StatelessWidget {
  final User? user;
  final VoidCallback onTapProfile;
  final VoidCallback onTapEdit;

  const UserDrawerHeader({
    super.key,
    required this.user,
    required this.onTapProfile,
    required this.onTapEdit,
  });

  String _getRoleLabel(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return 'Administrateur';
      case 'livreur':
        return 'Livreur';
      case 'client':
        return 'Client';
      case 'operateur':
        return 'Opérateur';
      default:
        return 'Utilisateur';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTapProfile,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 16.h,
          bottom: 16.h,
          left: 20.w,
          right: 12.w,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [AppColors.darkSurface, AppColors.darkSurface.withOpacity(0.8)]
              : [AppColors.primary, const Color(0xFFFF8C42)],
          ),
        ),
        child: Row(
          children: [
            // Avatar with Edit button overlay
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 28.r,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: user?.profileImageUrl != null 
                        ? NetworkImage(user!.profileImageUrl!) 
                        : null,
                    child: user?.profileImageUrl == null
                        ? Text(
                            user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : "?",
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
            SizedBox(width: 16.w),
            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user?.name ?? 'Utilisateur',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.email ?? '...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  // Role Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      _getRoleLabel(user?.role),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Edit Button
            IconButton(
              onPressed: onTapEdit,
              icon: Icon(Icons.edit_note_rounded, color: Colors.white, size: 22.sp),
              tooltip: "Modifier le profil",
              constraints: const BoxConstraints(),
              padding: EdgeInsets.all(8.w),
            ),
          ],
        ),
      ),
    );
  }
}
