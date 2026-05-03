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
    {'id': 'tricycle', 'label': 'Tricycle', 'icon': Icons.electric_rickshaw},
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
                "Quel véhicule possédez-vous ?",
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
                    final isAvailable = transport['id'] == 'moto';
                    
                    return GestureDetector(
                      onTap: isAvailable ? () {
                        setState(() {
                          _selectedTransport = transport['id'];
                        });
                      } : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Cette option sera bientôt disponible")),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isAvailable ? Colors.white : Colors.grey.shade50,
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
                         child: Stack(
                           children: [
                             Center(
                               child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                   Icon(
                                     transport['icon'],
                                     size: 60.sp,
                                     color: isSelected 
                                      ? AppColors.primary 
                                      : (isAvailable ? Colors.grey.shade600 : Colors.grey.shade300),
                                   ),
                                   SizedBox(height: 16.h),
                                   Text(
                                      transport['label'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected 
                                          ? AppColors.primary 
                                          : (isAvailable ? AppColors.text : Colors.grey.shade400),
                                      ),
                                   ),
                                ],
                               ),
                             ),
                             if (!isAvailable)
                               Positioned(
                                 top: 10.h,
                                 right: 10.w,
                                 child: Container(
                                   padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                   decoration: BoxDecoration(
                                     color: Colors.grey.shade200,
                                     borderRadius: BorderRadius.circular(12.r),
                                   ),
                                   child: Text(
                                     "Bientôt",
                                     style: GoogleFonts.poppins(
                                       fontSize: 10.sp,
                                       color: Colors.grey.shade600,
                                       fontWeight: FontWeight.w600,
                                     ),
                                   ),
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
              
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedTransport = 'none';
                  });
                },
                child: Text(
                  "Je ne possède aucun véhicule",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: _selectedTransport == 'none' ? AppColors.primary : Colors.grey,
                    fontWeight: _selectedTransport == 'none' ? FontWeight.w600 : FontWeight.w400,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              
              SizedBox(height: 16.h),

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
                : null,
              ),
               SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}
