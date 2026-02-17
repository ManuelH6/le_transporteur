import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';

class ClientDeliveriesPage extends StatefulWidget {
  const ClientDeliveriesPage({super.key});

  @override
  State<ClientDeliveriesPage> createState() => _ClientDeliveriesPageState();
}

class _ClientDeliveriesPageState extends State<ClientDeliveriesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _mockDeliveries = [
    {
      "id": "DLV-001",
      "status": "En cours",
      "price": "2,500 FCFA",
      "date": "16 Fév. 2026",
      "pickup": "Cotonou, Fidjrossè",
      "dropoff": "Akpakpa",
      "livreur": "Sam Le Rapide",
    },
    {
      "id": "DLV-002",
      "status": "Terminée",
      "price": "1,800 FCFA",
      "date": "15 Fév. 2026",
      "pickup": "Calavi, IITA",
      "dropoff": "St Michel",
      "livreur": "Jean Destin",
    },
    {
      "id": "DLV-003",
      "status": "Terminée",
      "price": "3,000 FCFA",
      "date": "14 Fév. 2026",
      "pickup": "Etoile Rouge",
      "dropoff": "Porto-Novo",
      "livreur": "Marc Express",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mes Livraisons", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "En cours"),
            Tab(text: "Terminées"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDeliveryList("En cours"),
          _buildDeliveryList("Terminée"),
        ],
      ),
    );
  }

  Widget _buildDeliveryList(String filterStatus) {
    final filtered = _mockDeliveries.where((d) => d['status'] == filterStatus).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64.sp, color: Colors.grey[300]),
            SizedBox(height: 16.h),
            Text("Aucune livraison $filterStatus", style: GoogleFonts.poppins(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final data = filtered[index];
        return Card(
          elevation: 2,
          margin: EdgeInsets.only(bottom: 16.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),

          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(data['id'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: data['status'] == "En cours" ? Colors.blue.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        data['status'],
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: data['status'] == "En cours" ? Colors.blue : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                    SizedBox(width: 8.w),
                    Expanded(child: Text(data['pickup'], style: GoogleFonts.poppins(fontSize: 13.sp))),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    const Icon(Icons.flag_outlined, size: 16, color: Colors.red),
                    SizedBox(width: 8.w),
                    Expanded(child: Text(data['dropoff'], style: GoogleFonts.poppins(fontSize: 13.sp))),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(radius: 12.r, backgroundColor: Colors.grey[200], child: const Icon(Icons.person, size: 14)),
                        SizedBox(width: 8.w),
                        Text(data['livreur'], style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Text(data['price'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

