import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';

class ClientOrdersPage extends StatelessWidget {
  const ClientOrdersPage({super.key});

  final List<Map<String, dynamic>> _mockOrders = const [
    {
      "id": "ORD-7290",
      "date": "14 Fév. 2026",
      "items": "2x Pizza XXL, 1x Coca 1.5L",
      "shop": "La Pizza Cotonou",
      "total": "12,500 FCFA",
      "status": "Livré",
    },
    {
      "id": "ORD-7285",
      "date": "12 Fév. 2026",
      "items": "1x Burger King Menu",
      "shop": "Burger King",
      "total": "4,500 FCFA",
      "status": "Livré",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mes Commandes", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: _mockOrders.length,
        itemBuilder: (context, index) {
          final order = _mockOrders[index];
          return Card(
            elevation: 1,
            margin: EdgeInsets.only(bottom: 16.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),

            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(order['shop'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                      Text(order['date'], style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(order['items'], style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey[700])),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)),
                        child: Text(order['status'], style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.green, fontWeight: FontWeight.bold)),
                      ),
                      Text(order['total'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

