import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:shared_le_transporteur/components/shared_map_widget.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_button.dart';
import 'package:shared_le_transporteur/core/widgets/app_text_field.dart';

enum LivraisonStatus {
  enAttente,
  negociation,
  validationClient,
  versRecuperation,
  versDestination,
  terminee
}

class DetailLivraisonPage extends StatefulWidget {
  final String livraisonId;
  const DetailLivraisonPage({super.key, required this.livraisonId});

  @override
  State<DetailLivraisonPage> createState() => _DetailLivraisonPageState();
}

class _DetailLivraisonPageState extends State<DetailLivraisonPage> {
  LivraisonStatus _status = LivraisonStatus.enAttente;
  final TextEditingController _priceController = TextEditingController();
  
  // Mock Coordinates (Cotonou)
  final LatLng _livreurPos = const LatLng(6.3654, 2.4183);
  final LatLng _clientPos = const LatLng(6.3700, 2.4200);
  final LatLng _destPos = const LatLng(6.3800, 2.4300);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map Background
          Positioned.fill(
            child: SharedMapWidget(
              center: _livreurPos,
              zoom: 14.0,
              markers: _buildMarkers(),
              polylines: _buildPolylines(),
            ),
          ),
          
          // Back Button
          Positioned(
            top: 50.h,
            left: 20.w,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Bottom Sheet Content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, -5))
                ],
              ),
              child: _buildBottomSheetContent(),
            ),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [
      Marker(point: _livreurPos, width: 40, height: 40, child: const Icon(Icons.motorcycle, color: AppColors.primary, size: 40)),
    ];
    
    if (_status == LivraisonStatus.enAttente || _status == LivraisonStatus.versRecuperation) {
       markers.add(Marker(point: _clientPos, width: 40, height: 40, child: const Icon(Icons.location_on, color: Colors.red, size: 40)));
    } else if (_status == LivraisonStatus.versDestination) {
       markers.add(Marker(point: _destPos, width: 40, height: 40, child: const Icon(Icons.flag, color: Colors.green, size: 40)));
    }
    return markers;
  }

  List<Polyline> _buildPolylines() {
     if (_status == LivraisonStatus.versRecuperation) {
       return [Polyline(points: [_livreurPos, _clientPos], color: AppColors.primary, strokeWidth: 4.0)];
     } else if (_status == LivraisonStatus.versDestination) {
       return [Polyline(points: [_clientPos, _destPos], color: AppColors.primary, strokeWidth: 4.0)];
     }
     return [];
  }

  Widget _buildBottomSheetContent() {
    switch (_status) {
      case LivraisonStatus.enAttente:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Livraison ${widget.livraisonId}", style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
            SizedBox(height: 16.h),
            _buildLocationRow(Icons.location_on_outlined, "Adresse de récupération", "Arconville, Abomey Calavi"),
            SizedBox(height: 12.h),
             _buildLocationRow(Icons.flag_outlined, "Adresse de destination", "Zogbadje, Abomey Calavi"),
            SizedBox(height: 24.h),
            AppButton(text: "Accepter", onPressed: () {
              setState(() => _status = LivraisonStatus.negociation);
            }),
          ],
        );
      
      case LivraisonStatus.negociation:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client Contact Info
             Row(
              children: [
                CircleAvatar(backgroundColor: Colors.grey[200], child: const Icon(Icons.person, color: Colors.grey)),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Client", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                    Text("+229 97 00 00 00", style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey)),
                  ],
                ),
                const Spacer(),
                IconButton(icon: const Icon(Icons.phone, color: Colors.green), onPressed: () {}),
              ],
            ),
             SizedBox(height: 20.h),
            Text("Proposer un prix", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 10.h),
            AppTextField(controller: _priceController, hintText: "Ex: 2000", keyboardType: TextInputType.number, prefixIcon: Icons.money),
            SizedBox(height: 20.h),
             AppButton(text: "Valider le prix", onPressed: () {
              // Simulate Sending to Client
               setState(() => _status = LivraisonStatus.validationClient);
               // Mock Client Acceptance after 2 seconds
               Future.delayed(const Duration(seconds: 2), () {
                 if(mounted) setState(() => _status = LivraisonStatus.versRecuperation);
               });
            }),
          ],
        );
        
      case LivraisonStatus.validationClient:
         return Center(child: Padding(
           padding: const EdgeInsets.all(20.0),
           child: Column(
             children: [
               const CircularProgressIndicator(),
               SizedBox(height: 16.h),
               Text("En attente de confirmation client...", style: GoogleFonts.poppins(fontSize: 16.sp)),
             ],
           ),
         ));

      case LivraisonStatus.versRecuperation:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text("Vers le point de récupération", style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold)),
             SizedBox(height: 20.h),
             AppButton(text: "J'ai récupéré le colis", onPressed: () {
                setState(() => _status = LivraisonStatus.versDestination);
             }),
          ],
        );

      case LivraisonStatus.versDestination:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text("Vers la destination", style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold)),
             SizedBox(height: 20.h),
             AppButton(text: "Livraison terminée", onPressed: () {
                setState(() => _status = LivraisonStatus.terminee);
             }),
          ],
        );
      
      case LivraisonStatus.terminee:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             const Icon(Icons.check_circle, color: Colors.green, size: 60),
             SizedBox(height: 10.h),
             Text("Livraison terminée avec succès !", style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold)),
             SizedBox(height: 20.h),
             AppButton(text: "Retour au tableau de bord", onPressed: () {
                Navigator.pop(context); // Back to List
             }),
          ],
        );
    }
  }

  Widget _buildLocationRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.text)),
              Text(subtitle, style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }
}
