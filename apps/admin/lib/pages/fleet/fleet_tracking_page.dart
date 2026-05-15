// apps/admin/lib/pages/fleet/fleet_tracking_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_le_transporteur/api/v1/admin_api.dart';

class FleetTrackingPage extends StatefulWidget {
  const FleetTrackingPage({super.key});

  @override
  State<FleetTrackingPage> createState() => _FleetTrackingPageState();
}

class _FleetTrackingPageState extends State<FleetTrackingPage> {
  final _adminApi = AdminApi();
  List<Marker> _markers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPositions();
  }

  Future<void> _loadPositions() async {
    setState(() => _isLoading = true);
    try {
      final positions = await _adminApi.getFleetPositions();
      setState(() {
        _markers = positions.map((p) {
          final lat = (p['latitude'] as num).toDouble();
          final lng = (p['longitude'] as num).toDouble();
          return Marker(
            point: LatLng(lat, lng),
            width: 40,
            height: 40,
            child: const Icon(Icons.local_shipping, color: Colors.orange, size: 30),
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi de Flotte Live'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadPositions),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(14.7167, -17.4677), // Default to Dakar
                initialZoom: 12,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.le_transporteur.admin',
                ),
                MarkerLayer(markers: _markers),
              ],
            ),
    );
  }
}
