import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_image.dart';

class ClientDashboardPage extends StatefulWidget {
  final VoidCallback onSelectDelivery;

  const ClientDashboardPage({
    super.key,
    required this.onSelectDelivery,
  });

  @override
  State<ClientDashboardPage> createState() => _ClientDashboardPageState();
}

class _ClientDashboardPageState extends State<ClientDashboardPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<String> _ads = [
    'assets/images/background_livreur_colis.jpg',
    'assets/images/background_livreur_moto_quatre_personnes.jpg',
    'assets/images/background_moto_livreur.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < _ads.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _showComingSoon(String serviceName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "$serviceName : Bientôt disponible",
          style: GoogleFonts.poppins(fontSize: 14.sp),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.grey[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: AppColors.text, size: 28.sp),
          onPressed: () {},
        ),
        title: AppImage(
          assetPath: 'assets/images/logo_le_transporteur_orange.png',
          height: 30.h,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppColors.text, size: 24.sp),
            onPressed: () {},
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none, color: AppColors.text, size: 24.sp),
                onPressed: () {},
              ),
              Positioned(
                top: 10.h,
                right: 10.w,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '5',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            // Advertisement Carousel
            Container(
              height: 180.h,
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      itemCount: _ads.length,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                _ads[index],
                                package: 'shared_le_transporteur',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.4),
                                  Colors.transparent,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 12.h,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _ads.length,
                          (index) => Container(
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            width: _currentPage == index ? 20.w : 6.w,
                            height: 6.h,
                            decoration: BoxDecoration(
                              color: _currentPage == index ? AppColors.primary : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(3.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),
            // Services Grid
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: 1.1,
                children: [
                   _buildServiceCard(
                    title: "Livreur",
                    icon: Icons.delivery_dining,
                    color: AppColors.primary,
                    onTap: widget.onSelectDelivery,
                    isAvailable: true,
                  ),
                  _buildServiceCard(
                    title: "Bons Plans",
                    icon: Icons.campaign_outlined,
                    color: Colors.orange,
                    onTap: () => _showComingSoon("Bons Plans"),
                  ),
                  _buildServiceCard(
                    title: "Plan bouffe",
                    icon: Icons.restaurant_outlined,
                    color: Colors.redAccent,
                    onTap: () => _showComingSoon("Plan bouffe"),
                  ),
                  _buildServiceCard(
                    title: "E-boutique",
                    icon: Icons.storefront_outlined,
                    color: Colors.blueAccent,
                    onTap: () => _showComingSoon("E-boutique"),
                  ),
                   _buildServiceCard(
                    title: "Frêt",
                    icon: Icons.local_shipping_outlined,
                    color: Colors.brown,
                    onTap: () => _showComingSoon("Frêt"),
                  ),
                  _buildServiceCard(
                    title: "Billetterie",
                    icon: Icons.confirmation_number_outlined,
                    color: Colors.purple,
                    onTap: () => _showComingSoon("Billetterie"),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isAvailable = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isAvailable ? color.withOpacity(0.1) : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isAvailable ? color : Colors.grey[400],
                size: 32.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isAvailable ? AppColors.text : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
