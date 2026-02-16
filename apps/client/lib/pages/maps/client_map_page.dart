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
  
  // Coordinates (Mock)
  final LatLng _pickupCoord = const LatLng(6.3654, 2.4183);
  final LatLng _dropoffCoord = const LatLng(6.3800, 2.4400);

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
              polylines: _buildPolylines(),
            ),
          ),

          // Top Inputs (Selection state)
          if (_state == ClientMapState.selection)
            Positioned(
              top: 50.h,
              left: 20.w,
              right: 20.w,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Où allez-vous ?", style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.text)),
                    SizedBox(height: 16.h),
                    AppTextField(controller: _departController, hintText: "Lieu de départ", prefixIcon: Icons.my_location, prefixIconColor: AppColors.primary),
                    SizedBox(height: 12.h),
                    AppTextField(controller: _arriveeController, hintText: "Destination", prefixIcon: Icons.location_on, prefixIconColor: Colors.red),
                    SizedBox(height: 16.h),
                    AppButton(
                      text: "Confirmer les lieux",
                      onPressed: () {
                        setState(() => _state = ClientMapState.details);
                      },
                    )
                  ],
                ),
              ),
            ),
            
           // Floating Back Button
           if (_state != ClientMapState.selection)
           Positioned(
            top: 50.h,
            left: 20.w,
            child: Material(
              elevation: 4,
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  setState(() {
                    if(_state == ClientMapState.details) _state = ClientMapState.selection;
                    else if(_state == ClientMapState.recherche) _state = ClientMapState.details;
                    else if(_state == ClientMapState.proposition) _state = ClientMapState.details;
                    else if(_state == ClientMapState.suivi) _state = ClientMapState.selection;
                  });
                },
              ),
            ),
          ),

          // Multi-step Bottom Interaction Panel
          if (_state != ClientMapState.selection)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 40.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, -5))
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
    if (_state == ClientMapState.selection) {
      return [
        Marker(point: _pickupCoord, width: 40, height: 40, child: const Icon(Icons.my_location, color: AppColors.primary, size: 30)),
      ];
    }
    return [
      Marker(point: _pickupCoord, width: 50, height: 50, child: const Icon(Icons.location_on, color: AppColors.primary, size: 40)),
      Marker(point: _dropoffCoord, width: 50, height: 50, child: const Icon(Icons.flag, color: Colors.red, size: 40)),
    ];
  }

  List<Polyline> _buildPolylines() {
    if (_state == ClientMapState.selection) return [];
    return [
      Polyline(
        points: [_pickupCoord, _dropoffCoord],
        color: AppColors.primary,
        strokeWidth: 4.0,
      ),
    ];
  }

  Widget _buildBottomSheetContent() {
    switch (_state) {
      case ClientMapState.details:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary),
                SizedBox(width: 10.w),
                Text("Détails de l'envoi", style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.text)),
              ],
            ),
            SizedBox(height: 16.h),
            AppTextField(controller: _contactDepartController, hintText: "Contact Pickup (Nom/Tél)", prefixIcon: Icons.person_outline),
            SizedBox(height: 12.h),
            AppTextField(controller: _contactArriveeController, hintText: "Contact Destinataire (Nom/Tél)", prefixIcon: Icons.phone_outlined),
            SizedBox(height: 20.h),
            AppButton(
              text: "Chercher un livreur",
              onPressed: () {
                 setState(() => _state = ClientMapState.recherche);
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
            SizedBox(height: 20.h),
            const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary), strokeWidth: 5),
            SizedBox(height: 24.h),
            Text("Recherche en cours...", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            Text("Nous contactons les livreurs à proximité", style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey)),
            SizedBox(height: 20.h),
          ],
        );

      case ClientMapState.proposition:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text("Livreur disponible !", style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.green[700])),
             SizedBox(height: 16.h),
             Container(
               padding: EdgeInsets.all(12.w),
               decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.grey[200]!)),
               child: Row(
                 children: [
                   CircleAvatar(radius: 25.r, backgroundColor: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.person, color: AppColors.primary, size: 30)),
                   SizedBox(width: 12.w),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text("Sam Le Rapide", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                         Text("Yamaha Crypton • ABC-1234", style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey[600])),
                       ],
                     ),
                   ),
                   Column(
                     children: [
                       const Icon(Icons.star, color: Colors.amber, size: 20),
                       Text("4.9", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                     ],
                   ),
                 ],
               ),
             ),
             SizedBox(height: 16.h),
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text("Prix total :", style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.grey[600])),
                 Text("1500 FCFA", style: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
               ],
             ),
             SizedBox(height: 20.h),
             AppButton(
               text: "Confirmer la commande",
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
             Row(
               children: [
                 const Icon(Icons.local_shipping, color: AppColors.primary),
                 SizedBox(width: 10.w),
                 Text("Suivi de votre colis", style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold)),
               ],
             ),
             SizedBox(height: 16.h),
             const LinearProgressIndicator(color: AppColors.primary, minHeight: 6),
             SizedBox(height: 16.h),
             Text("Sam est en route !", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16.sp)),
             Text("Arrivée prévue dans 5 min", style: GoogleFonts.poppins(color: Colors.grey[600])),
             SizedBox(height: 20.h),
             Row(
               children: [
                 Expanded(
                   child: OutlinedButton.icon(
                     onPressed: () {}, 
                     icon: const Icon(Icons.call, size: 18), 
                     label: const Text("Appeler"),
                     style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12.h)),
                   ),
                 ),
                 SizedBox(width: 12.w),
                 Expanded(
                   child: OutlinedButton.icon(
                     onPressed: () {}, 
                     icon: const Icon(Icons.message, size: 18), 
                     label: const Text("Message"),
                     style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12.h)),
                   ),
                 ),
               ],
             ),
           ],
         );
          
      default:
        return const SizedBox.shrink();
    }
  }
}

