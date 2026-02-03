import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(22.6916, 72.8634), // Nadiad coordinates
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.travel_guide_app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(22.6916, 72.8634),
                    width: 80,
                    height: 80,
                    child: Icon(
                      Icons.location_on,
                      color: theme.colorScheme.primary,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 48,
            left: 16,
            child: FloatingActionButton(
              onPressed: () => Navigator.pop(context),
              mini: true,
              backgroundColor: theme.colorScheme.surface,
              child: const Icon(Icons.arrow_back),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/compare'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: theme.colorScheme.primary,
              ),
              child: const Text('Compare All Transport Options'),
            ),
          ),
        ],
      ),
    );
  }
}
