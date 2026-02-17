import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_button.dart';
import 'package:livreur_le_transporteur/pages/profile_creation/prise_photo_page.dart';

import 'package:livreur_le_transporteur/models/registration_data.dart';

class MoyenTransportPage extends StatefulWidget {
  final RegistrationData registrationData;
  const MoyenTransportPage({super.key, required this.registrationData});

  @override
  State<MoyenTransportPage> createState() => _MoyenTransportPageState();
}

class _MoyenTransportPageState extends State<MoyenTransportPage> {
  String? _selectedTransport;
  
  final List<Map<String, dynamic>> _transports = [
    {'id': 'moto', 'label': 'Moto', 'icon': Icons.two_wheeler},
    {'id': 'tricycle', 'label': 'Tricycle', 'icon': Icons.electric_rickshaw}, // Using electric_rickshaw as approx for tricycle
    {'id': 'fourgonnette', 'label': 'Fourgonnette', 'icon': Icons.local_shipping_outlined},
    {'id': 'camion', 'label': 'Camion', 'icon': Icons.local_shipping},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 10.h),
               Text(
                "Vous souhaitez livrer à",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 40.h),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: _transports.length,
                  itemBuilder: (context, index) {
                    final transport = _transports[index];
                    final isSelected = _selectedTransport == transport['id'];
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTransport = transport['id'];
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                         child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             Icon(
                               transport['icon'],
                               size: 60.sp,
                               color: isSelected ? AppColors.primary : Colors.grey.shade600,
                             ),
                             SizedBox(height: 16.h),
                             Text(
                                transport['label'],
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected ? AppColors.primary : AppColors.text,
                                ),
                             ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20.h),
              AppButton(
                text: "Continuer",
                onPressed: _selectedTransport != null
                ? () {
                    widget.registrationData.vehiculeType = _selectedTransport;
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrisePhotoPage(registrationData: widget.registrationData),
                      ),
                    );
                  }
                : null, // Disable if none selected
              ),
               SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}
