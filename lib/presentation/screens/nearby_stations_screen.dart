import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class NearbyStationsScreen extends StatelessWidget {
  const NearbyStationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Stations')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(22.6916, 72.8634),
                initialZoom: 14.0,
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
                      child: Icon(Icons.my_location, color: theme.colorScheme.secondary),
                    ),
                    Marker(
                      point: LatLng(22.6950, 72.8680),
                      child: Icon(Icons.train_rounded, color: theme.colorScheme.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Expanded(
            flex: 1,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off_rounded, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Showing markers for demonstration', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
