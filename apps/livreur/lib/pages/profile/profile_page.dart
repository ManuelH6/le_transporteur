import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/api/v1/user_api.dart';
import 'package:shared_le_transporteur/api/v1/livreur_api.dart';
import 'package:shared_le_transporteur/models/user.dart';
import 'package:shared_le_transporteur/models/livreur_profile.dart';
import 'package:shared_le_transporteur/screens/settings/edit_profile_screen.dart';
import 'package:livreur_le_transporteur/models/registration_data.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  LivreurProfile? _livreurProfile;
  RegistrationData? _localData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userApi = UserApi();
      final livreurApi = LivreurApi();
      final box = Hive.box('livreur_registration');
      
      final results = await Future.wait([
        userApi.getMe(),
        livreurApi.getMyProfile(),
      ]);

      final savedData = box.get('current');
      
      if (mounted) {
        setState(() {
          _user = results[0] as User;
          _livreurProfile = results[1] as LivreurProfile;
          if (savedData != null) {
            _localData = RegistrationData.fromJson(Map<String, dynamic>.from(savedData));
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFFFF0EB),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? AppColors.darkText : AppColors.text, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Mon Profil",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.text,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: AppColors.primary, size: 24.sp),
            onPressed: () async {
              if (_user != null) {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen(user: _user!)),
                );
                if (updated == true) {
                  _loadData();
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          children: [
            _buildProfileHeader(_livreurProfile?.verificationStatus),
            SizedBox(height: 24.h),
            _buildPersonalInfoSection(),
            SizedBox(height: 16.h),
            _buildVehicleInfoSection(),
            SizedBox(height: 16.h),
            _buildIdentitySection(),

            SizedBox(height: 16.h),
            _buildStatisticsSection(),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String? status) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.help_outline;
    String statusText = "Statut inconnu";

    if (status?.toLowerCase() == 'approved') {
      statusColor = const Color(0xFF4CAF50);
      statusIcon = Icons.check_circle;
      statusText = "Compte Vérifié";
    } else if (status?.toLowerCase() == 'pending') {
      statusColor = Colors.orange;
      statusIcon = Icons.hourglass_empty;
      statusText = "En attente";
    } else if (status?.toLowerCase() == 'rejected') {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      statusText = "Refusé";
    }

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                  ),
                  border: Border.all(color: isDark ? AppColors.darkSurface : Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _user?.name.isNotEmpty == true ? _user!.name[0].toUpperCase() : "?",
                    style: GoogleFonts.poppins(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    status == 'approved' ? Icons.verified : statusIcon,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            _user?.name ?? "Livreur",
            style: GoogleFonts.poppins(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : AppColors.text,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusColor, size: 16.sp),
                SizedBox(width: 6.w),
                Text(
                  statusText,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: AppColors.primary, size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                "Informations Personnelles",
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.text,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(Icons.badge, "Nom complet", _user?.name ?? ""),
          _buildDivider(),
          _buildInfoRow(Icons.email, "Email", _user?.email ?? ""),
          _buildDivider(),
          _buildInfoRow(Icons.phone, "Téléphone", _user?.phoneNumber ?? ""),
          _buildDivider(),
          _buildInfoRow(Icons.location_on, "Zone", _livreurProfile?.ifuNumber ?? "Non renseigné"),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.two_wheeler, color: AppColors.primary, size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                "Mon Véhicule",
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.text,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(Icons.category, "Type", _livreurProfile?.motoPlateNumber != null ? "Moto" : "Aucun"),
          _buildDivider(),
          _buildInfoRow(Icons.business, "Marque", _livreurProfile?.motoBrand ?? ""),
          _buildDivider(),
          _buildInfoRow(Icons.motorcycle, "Modèle", _livreurProfile?.motoModel ?? ""),
          _buildDivider(),
          _buildInfoRow(Icons.pin, "Plaque", _livreurProfile?.motoPlateNumber ?? ""),
          _buildDivider(),
          _buildInfoRow(Icons.numbers, "Châssis", _livreurProfile?.motoChassisNumber ?? ""),
          _buildDivider(),
          _buildInfoRow(Icons.palette, "Couleur", _livreurProfile?.motoCouleur ?? _localData?.vehiculeCouleur ?? "Non renseigné"),
        ],
      ),
    );
  }

  Widget _buildIdentitySection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.badge, color: AppColors.primary, size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                "Identité",
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.text,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(Icons.assignment_ind, "Type de pièce", _livreurProfile?.idType ?? _localData?.pieceIdentiteType ?? "Non renseigné"),

          _buildDivider(),
          _buildInfoRow(Icons.numbers, "Numéro de pièce", _livreurProfile?.idNumber ?? _localData?.pieceIdentiteNumero ?? "Non renseigné"),

          _buildDivider(),
          _buildInfoRow(Icons.directions_car, "Numéro Carte Grise", _livreurProfile?.motoCarteGriseNumber ?? _localData?.numeroCarteGrise ?? "Non renseigné"),
        ],
      ),
    );
  }


  Widget _buildStatisticsSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? [AppColors.darkSurface, const Color(0xFF2D2D2D)] : [const Color(0xFF2D2D2D), const Color(0xFF424242)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: Colors.white, size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                "Mes Statistiques",
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem("0", "Livraisons", Icons.local_shipping),
              ),
              Expanded(
                child: _buildStatItem("0%", "Taux Réussite", Icons.check_circle),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem("0 FCFA", "Revenus", Icons.account_balance_wallet),
              ),
              Expanded(
                child: _buildStatItem("0h", "Heures", Icons.access_time),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 28.sp),
        SizedBox(height: 8.h),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, color: isDark ? Colors.grey[500] : Colors.grey[600], size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkText : AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentRow(String name, bool isVerified) {
    return Row(
      children: [
        Icon(
          isVerified ? Icons.check_circle : Icons.cancel,
          color: isVerified ? const Color(0xFF4CAF50) : const Color(0xFFFF5252),
          size: 20.sp,
        ),
        SizedBox(width: 12.w),
        Text(
          name,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      color: isDark ? Colors.grey[800] : Colors.grey[200],
      height: 1,
      thickness: 1,
    );
  }
}
