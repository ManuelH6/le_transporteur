import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:client_le_transporteur/pages/home/client_dashboard_page.dart';
import 'package:client_le_transporteur/pages/orders/client_orders_page.dart';
import 'package:client_le_transporteur/pages/settings/client_settings_page.dart';

import 'package:shared_le_transporteur/api/v1/api_client.dart';
import 'package:shared_le_transporteur/models/user.dart';
import 'package:shared_le_transporteur/api/v1/auth_api.dart';
import 'package:client_le_transporteur/pages/auth/login_page.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  int _currentIndex = 0;
  User? _user;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _pages = [
      ClientDashboardPage(
        onSelectDelivery: () => setState(() => _currentIndex = 1),
      ),
      const ClientOrdersPage(),
      const ClientSettingsPage(),
    ];
  }

  Future<void> _loadUser() async {
    final user = await ApiClient().user;
    setState(() => _user = user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: GoogleFonts.poppins(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
          ),
          showUnselectedLabels: true,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.home_outlined, size: 24),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.home_rounded, size: 26),
              ),
              label: "Accueil",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.inventory_2_outlined, size: 24),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.inventory_2_rounded, size: 26),
              ),
              label: "Mes Livraisons",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.settings_outlined, size: 24),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.settings_rounded, size: 26),
              ),
              label: "Paramètres",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              children: [
                _buildDrawerSectionTitle('Menu principal'),
                _buildDrawerItem(0, Icons.home_rounded, 'Accueil'),
                _buildDrawerItem(1, Icons.inventory_2_rounded, 'Mes Livraisons'),
                _buildDrawerItem(2, Icons.settings_rounded, 'Paramètres'),
                
                const Divider(),
                _buildDrawerSectionTitle('Support & Aide'),
                _buildDrawerItem(3, Icons.help_outline_rounded, 'Centre d\'aide', onTap: () {
                  // Action pour l'aide
                }),
                _buildDrawerItem(4, Icons.support_agent_rounded, 'Contacter le support', onTap: () {
                  // Action pour le support
                }),
                _buildDrawerItem(5, Icons.info_outline_rounded, 'À propos', onTap: () {
                  // Action pour à propos
                }),
              ],
            ),
          ),
          _buildLogoutItem(),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 60.h, bottom: 24.h, left: 24.w, right: 24.w),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFFFF8C42)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 35.r,
              backgroundColor: Colors.grey[200],
              child: _user?.name != null 
                ? Text(_user!.name[0].toUpperCase(), style: GoogleFonts.poppins(fontSize: 24.sp, fontWeight: FontWeight.bold, color: AppColors.primary))
                : Icon(Icons.person, size: 35.sp, color: AppColors.primary),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            _user?.name ?? 'Utilisateur',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _user?.email ?? 'Chargement...',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 24.w, top: 16.h, bottom: 8.h),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
          color: Colors.grey[500],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(int index, IconData icon, String title, {VoidCallback? onTap}) {
    final isSelected = _currentIndex == index;
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
        setState(() => _currentIndex = index);
        Navigator.pop(context);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
    );
  }

  Widget _buildLogoutItem() {
    return Container(
      padding: EdgeInsets.all(24.w),
      child: InkWell(
        onTap: () async {
          await AuthApi().logout(null);
          if (mounted) {
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
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
