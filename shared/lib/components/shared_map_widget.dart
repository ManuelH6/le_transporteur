import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_le_transporteur/core/utils/permission_helper.dart';

class SharedMapWidget extends StatelessWidget {
  final LatLng center;
  final List<Marker> markers;
  final List<Polyline> polylines;
  final double zoom;

  const SharedMapWidget({
    super.key,
    required this.center,
    this.markers = const [],
    this.polylines = const [],
    this.zoom = 13.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: zoom,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.transporteur.shared',
            ),
            PolylineLayer(
              polylines: polylines,
            ),
            MarkerLayer(
              markers: markers,
            ),
          ],
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            heroTag: "location_btn_${center.latitude}", // Unique tag
            backgroundColor: Colors.white,
            mini: true,
            child: const Icon(Icons.my_location, color: Colors.blue),
            onPressed: () async {
               await _handleLocationPermission(context);
            },
          ),
        ),
      ],
    );
  }

  Future<void> _handleLocationPermission(BuildContext context) async {
    final hasPermission = await PermissionHelper.requestPermission(
      context,
      permission: Permission.location,
      title: "Autorisation Localisation",
      description: "Le Transporteur a besoin de votre localisation pour afficher votre position sur la carte et suivre votre trajet.",
      iconPath: "", 
    );

    if (hasPermission && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Localisation activée (Simulation)")),
      );
      // Here you would typically trigger a callback or use a ValueNotifier to update the map center
      // For now, we just confirm permission is granted compliant with user request.
    }
  }
}
