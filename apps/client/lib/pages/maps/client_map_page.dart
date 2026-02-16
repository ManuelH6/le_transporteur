import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_le_transporteur/components/shared_map_widget.dart';
import 'package:shared_le_transporteur/core/theme/app_theme.dart';
import 'package:shared_le_transporteur/core/widgets/app_button.dart';
import 'package:shared_le_transporteur/core/widgets/app_text_field.dart';

enum ClientMapState {
  selection,
  details,
  recherche,
  proposition,
  suivi
}

class ClientMapPage extends StatefulWidget {
  const ClientMapPage({super.key});

  @override
  State<ClientMapPage> createState() => _ClientMapPageState();
}

class _ClientMapPageState extends State<ClientMapPage> {
  ClientMapState _state = ClientMapState.selection;
  final LatLng _center = const LatLng(6.3654, 2.4183); // Cotonou
  
  // Inputs
  final TextEditingController _departController = TextEditingController();
  final TextEditingController _arriveeController = TextEditingController();
  final TextEditingController _contactDepartController = TextEditingController();
  final TextEditingController _contactArriveeController = TextEditingController();

  @override
  void dispose() {
    _departController.dispose();
    _arriveeController.dispose();
    _contactDepartController.dispose();
    _contactArriveeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Map
          Positioned.fill(
            child: SharedMapWidget(
              center: _center,
              zoom: 14.0,
              markers: _buildMarkers(),
            ),
          ),

          // Top Inputs (Only in selection)
          if (_state == ClientMapState.selection)
            Positioned(
              top: 50.h,
              left: 20.w,
              right: 20.w,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       AppTextField(controller: _departController, hintText: "Lieu de départ (Récupération)", prefixIcon: Icons.location_on_outlined),
                       SizedBox(height: 12.h),
                       AppTextField(controller: _arriveeController, hintText: "Lieu d'arrivée (Livraison)", prefixIcon: Icons.flag_outlined),
                       SizedBox(height: 16.h),
                       AppButton(
                         text: "Continuer",
                         onPressed: () {
                           setState(() => _state = ClientMapState.details);
                         },
                       )
                    ],
                  ),
                ),
              ),
            ),
            
           // Back Button (if not selection)
           if (_state != ClientMapState.selection)
           Positioned(
            top: 50.h,
            left: 20.w,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  if(_state == ClientMapState.details) setState(() => _state = ClientMapState.selection);
                  else if(_state == ClientMapState.recherche) setState(() => _state = ClientMapState.details);
                  else if(_state == ClientMapState.proposition) setState(() => _state = ClientMapState.details); // Cancel proposal
                   // ... handle back 
                },
              ),
            ),
          ),

          // Bottom Sheets
          if (_state != ClientMapState.selection)
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
                    const BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -5))
                  ],
                ),
                child: _buildBottomSheet(),
              ),
            ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers() {
    // Return markers based on state/coordinates
    return [
      Marker(point: _center, width: 40, height: 40, child: const Icon(Icons.location_on, color: AppColors.primary, size: 40)),
    ];
  }

  Widget _buildBottomSheet() {
    switch (_state) {
      case ClientMapState.details:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Détails de la course", style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.text)),
            SizedBox(height: 16.h),
            AppTextField(controller: _contactDepartController, hintText: "Contact au départ", prefixIcon: Icons.phone),
            SizedBox(height: 12.h),
            AppTextField(controller: _contactArriveeController, hintText: "Contact à l'arrivée", prefixIcon: Icons.phone),
            SizedBox(height: 20.h),
            AppButton(
              text: "Trouver un livreur",
              onPressed: () {
                 setState(() => _state = ClientMapState.recherche);
                 // Mock finding livreur
                 Future.delayed(const Duration(seconds: 3), () {
                    if(mounted) setState(() => _state = ClientMapState.proposition);
                 });
              },
            ),
          ],
        );
      
      case ClientMapState.recherche:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16.h),
            Text("Recherche d'un livreur à proximité...", style: GoogleFonts.poppins(fontSize: 16.sp, color: AppColors.text)),
          ],
        );

      case ClientMapState.proposition:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text("Livreur Trouvé !", style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.green)),
             SizedBox(height: 16.h),
             ListTile(
               leading: CircleAvatar(backgroundColor: Colors.grey[200], child: const Icon(Icons.motorcycle, color: AppColors.primary)),
               title: Text("Sam le Livreur", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.text)),
               subtitle: Text("Moto - Yamaha 100", style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey)),
               trailing: Container(
                 padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                 child: Text("4.8 ★", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primary)),
               ),
             ),
             const Divider(),
             SizedBox(height: 10.h),
             Text("Prix proposé : 2000 FCFA", style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
             SizedBox(height: 20.h),
             AppButton(
               text: "Accepter & Confirmer",
               onPressed: () {
                 setState(() => _state = ClientMapState.suivi);
               },
             ),
          ],
        );
      
      case ClientMapState.suivi:
         return Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             Text("Course en cours", style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.text)),
             SizedBox(height: 10.h),
             Text("Le livreur est en route vers le point de récupération.", textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.grey)),
             SizedBox(height: 20.h),
             LinearProgressIndicator(color: AppColors.primary, backgroundColor: AppColors.primary.withOpacity(0.1)),
           ],
         );
         
      default:
        return const SizedBox.shrink();
    }
  }
}
