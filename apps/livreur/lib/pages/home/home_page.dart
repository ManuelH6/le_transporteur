import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/models/user.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:livreur_le_transporteur/pages/home/dashboard_tab.dart';
import 'package:livreur_le_transporteur/pages/deliveries/course_history_page.dart';

import 'package:livreur_le_transporteur/pages/orders/available_orders_page.dart';
import 'package:livreur_le_transporteur/widgets/courier_drawer.dart';
import 'package:shared_le_transporteur/api/v1/livreur_api.dart';
import 'package:livreur_le_transporteur/pages/profile_creation/analyse_encours_page.dart';
import 'package:livreur_le_transporteur/models/registration_data.dart';
import 'package:shared_le_transporteur/api/v1/api_client.dart'; 
import 'package:shared_le_transporteur/screens/notifications/notification_screen.dart';
import 'package:livreur_le_transporteur/pages/settings/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isCheckingProfile = true;
  User? _user;

  final List<Widget> _tabs = [
    const DashboardTab(),
    const AvailableOrdersPage(),
    const CourseHistoryPage(),

    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _checkProfileStatus();
  }

  Future<void> _checkProfileStatus() async {
    try {
      // 1. Fetch user for drawer
      final user = await ApiClient().user;
      
      // 2. Fetch profile to verify completeness and verification status
      final profile = await LivreurApi().getMyProfile();

      if (mounted) {
        setState(() {
          _user = user;
        });

        final status = profile.verificationStatus?.toLowerCase();
        // Redirect if not approved yet
        if (status != 'approved') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AnalyseEncoursPage(registrationData: RegistrationData())),
          );
          return;
        }

        setState(() => _isCheckingProfile = false);
      }
    } catch (e) {
      if (e is ApiException && e.statusCode == 403) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AnalyseEncoursPage(registrationData: RegistrationData())),
          );
        }
      } else {
        if (mounted) setState(() => _isCheckingProfile = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingProfile) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: CourierDrawer(
        user: _user,
        currentIndex: _currentIndex,
        onSelectItem: (index) {
          setState(() => _currentIndex = index);
          Navigator.pop(context); // Close drawer
        },
      ),
      appBar: _buildAppBar(),
      body: _tabs[_currentIndex],
      bottomNavigationBar: _currentIndex == 3 ? null : Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex < 3 ? _currentIndex : 0,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey[400],
            selectedLabelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w700, 
              fontSize: 11.sp,
              letterSpacing: -0.2,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w500, 
              fontSize: 10.sp,
            ),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.dashboard_outlined, size: 24),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.dashboard_rounded, size: 26),
                ),
                label: 'Tableau de bord',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.shopping_bag_outlined, size: 24),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.shopping_bag_rounded, size: 26),
                ),
                label: 'Courses disponibles',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.local_shipping_outlined, size: 24),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.local_shipping_rounded, size: 26),
                ),
                label: 'Mes Courses',
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    String title = "Tableau de bord";
    if (_currentIndex == 1) title = "Courses disponibles";
    if (_currentIndex == 2) title = "Mes Courses";

    if (_currentIndex == 3) title = "Paramètres";

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.menu, color: AppColors.text, size: 28.sp),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.text,
        ),
      ),
      actions: _currentIndex == 0 ? [
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: AppColors.text, size: 26.sp),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationScreen()),
            );
          },
        ),
        SizedBox(width: 8.w),
      ] : null,
    );
  }
}
