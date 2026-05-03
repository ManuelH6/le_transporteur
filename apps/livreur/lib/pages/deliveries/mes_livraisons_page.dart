import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:livreur_le_transporteur/pages/deliveries/detail_livraison_page.dart';

class MesLivraisonsPage extends StatefulWidget {
  const MesLivraisonsPage({super.key});

  @override
  State<MesLivraisonsPage> createState() => _MesLivraisonsPageState();
}

class _MesLivraisonsPageState extends State<MesLivraisonsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDeliveryList("En cours"),
          _buildDeliveryList("En attente"),
          _buildDeliveryList("Terminées"),
          _buildDeliveryList("Annulées"),
        ],
      ),
    );
  }

  Widget _buildDeliveryList(String status) {
    // Mock Data based on status
    final List<Map<String, dynamic>> deliveries = _getMockDeliveries(status);

    if (deliveries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 60.sp, color: Colors.grey[300]),
            SizedBox(height: 16.h),
            Text(
              "Aucune livraison $status",
              style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      itemCount: deliveries.length,
      itemBuilder: (context, index) {
        return _buildDeliveryCard(deliveries[index], status);
      },
    );
  }

  List<Map<String, dynamic>> _getMockDeliveries(String status) {
    switch (status) {
      case "En cours":
        return [
          {
            "id": "FFPPOL636",
            "date": "15:30",
            "description": "Titre de la description",
            "progress": 0.35,
          }
        ];
      case "En attente":
        return [
           {
            "id": "FFPPOL700",
            "date": "15:30",
            "description": "Titre de la description",
          },
          {
            "id": "FFPPOL701",
            "date": "16:00",
            "description": "Titre de la description",
          }
        ];
      case "Terminées":
        return [
           {
            "id": "XCSKF1545",
            "date": "Mar 20",
            "description": "Titre de la description",
            "status": "Livré"
          }
        ];
      case "Annulées":
        return [
           {
            "id": "DGKRMF5241",
            "date": "Jeu 22",
            "description": "Titre de la description",
            "status": "Annulé"
          }
        ];
      default:
        return [];
    }
  }

  Widget _buildDeliveryCard(Map<String, dynamic> data, String status) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailLivraisonPage(livraisonId: data['id'])),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Circle
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5722), // Orange/Red color
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.inventory_2_outlined, color: Colors.white, size: 24.sp),
                ),
                SizedBox(width: 12.w),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Livraison ${data['id']}",
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            data['date'],
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        status == "Terminées" ? "Livré" : (status == "Annulées" ? "Annulé" : "Livraison ${status.toLowerCase()}"),
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        data['description'],
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            if (status == "En cours") ...[
              SizedBox(height: 16.h),
              LinearProgressIndicator(
                value: data['progress'],
                backgroundColor: const Color(0xFFFFF0EB),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF5722)),
                minHeight: 4.h,
                borderRadius: BorderRadius.circular(2.r),
              ),
               SizedBox(height: 8.h),
               Text(
                "En cours ${(data['progress'] * 100).toInt()}%",
                style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey[600]),
               ),
            ],

            if (status == "En attente") ...[
              SizedBox(height: 16.h),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    // Accept Logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5722),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                    elevation: 0,
                  ),
                  child: Text(
                    "Accepter",
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
            
            if (status == "Terminées") ...[
               SizedBox(height: 16.h),
               Container(
                 height: 4.h,
                 width: double.infinity,
                 decoration: BoxDecoration(
                   color: const Color(0xFFFF5722),
                   borderRadius: BorderRadius.circular(2.r),
                 ),
               ),
               SizedBox(height: 8.h),
               Text(
                "Livrée 100%",
                style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey[600]),
               ),
            ],
             if (status == "Annulées") ...[
               SizedBox(height: 16.h),
               Container(
                 height: 4.h,
                 width: double.infinity,
                 decoration: BoxDecoration(
                   color: Colors.grey[300],
                   borderRadius: BorderRadius.circular(2.r),
                 ),
               ),
               SizedBox(height: 8.h),
               Text(
                "Annulé",
                style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey[600]),
               ),
            ],
          ],
        ),
      ),
    );
  }
}
