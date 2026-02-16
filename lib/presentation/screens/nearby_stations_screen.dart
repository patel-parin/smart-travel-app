import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../data/location_service.dart';

class NearbyStationsScreen extends StatefulWidget {
  const NearbyStationsScreen({super.key});

  @override
  State<NearbyStationsScreen> createState() => _NearbyStationsScreenState();
}

class _NearbyStationsScreenState extends State<NearbyStationsScreen> {
  final MapController _mapController = MapController();
  LatLng? _userLocation;
  bool _isLoading = true;
  String? _error;
  bool _mapReady = false;

  // Sample nearby stations (will calculate real distances)
  final List<Map<String, dynamic>> _stationData = [
    {'name': 'Nadiad Junction', 'lat': 22.6950, 'lng': 72.8680},
    {'name': 'Anand Junction', 'lat': 22.5645, 'lng': 72.9289},
    {'name': 'Ahmedabad Junction', 'lat': 23.0225, 'lng': 72.5714},
    {'name': 'Vadodara Junction', 'lat': 22.3106, 'lng': 73.1812},
  ];
  
  List<Map<String, dynamic>> _nearbyStations = [];

  @override
  void initState() {
    super.initState();
    // Delay location fetch to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    
    final locationService = context.read<LocationService>();
    
    try {
      final position = await locationService.getCurrentPosition();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = null;
          if (position != null) {
            _userLocation = LatLng(position.latitude, position.longitude);
          } else {
            _error = locationService.errorMessage ?? 'Could not get location';
            _userLocation = LatLng(22.6916, 72.8634);
          }
          // Calculate distances to stations
          _updateStationDistances();
        });
        
        // Auto-center map on user location
        _centerOnUser();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Location error: $e';
          _userLocation = LatLng(22.6916, 72.8634);
          _updateStationDistances();
        });
      }
    }
  }
  
  void _updateStationDistances() {
    if (_userLocation == null) return;
    
    final locationService = context.read<LocationService>();
    
    _nearbyStations = _stationData.map((station) {
      final stationLatLng = LatLng(station['lat'], station['lng']);
      final distance = locationService.calculateDistance(_userLocation!, stationLatLng);
      return {
        ...station,
        'distance': distance,
        'distanceText': distance < 1 
            ? '${(distance * 1000).toStringAsFixed(0)} m' 
            : '${distance.toStringAsFixed(1)} km',
      };
    }).toList();
    
    // Sort by distance
    _nearbyStations.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
  }

  void _centerOnUser() {
    if (_userLocation != null && _mapReady) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _mapController.move(_userLocation!, 14.0);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultLocation = LatLng(22.6916, 72.8634);
    final mapCenter = _userLocation ?? defaultLocation;

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Stations')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: mapCenter,
                    initialZoom: 14.0,
                    onMapReady: () {
                      _mapReady = true;
                      // Center on user once map is ready
                      if (_userLocation != null) {
                        _centerOnUser();
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.travel_guide_app',
                    ),
                    MarkerLayer(
                      markers: [
                        // User location marker
                        if (_userLocation != null)
                          Marker(
                            point: _userLocation!,
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(6),
                                child: Icon(Icons.person, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        // Station markers
                        ..._nearbyStations.map((station) => Marker(
                          point: LatLng(station['lat'], station['lng']),
                          child: Icon(Icons.train_rounded, color: theme.colorScheme.primary, size: 32),
                        )),
                      ],
                    ),
                  ],
                ),
                // Loading indicator
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
                // Center on user button
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: _isLoading ? null : _centerOnUser,
                    backgroundColor: theme.colorScheme.surface,
                    child: Icon(Icons.my_location, color: theme.colorScheme.secondary),
                  ),
                ),
              ],
            ),
          ),
          // Station list
          Expanded(
            flex: 1,
            child: _error != null
                ? _buildErrorWidget(theme)
                : _buildStationList(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off_rounded, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text(_error ?? 'Location unavailable', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              setState(() => _isLoading = true);
              await _getCurrentLocation();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildStationList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _nearbyStations.length,
      itemBuilder: (context, index) {
        final station = _nearbyStations[index];
        return Card(
          color: theme.colorScheme.surface,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              child: Icon(Icons.train, color: theme.colorScheme.primary),
            ),
            title: Text(station['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(station['distanceText'] ?? 'Calculating...'),
            trailing: IconButton(
              icon: Icon(Icons.directions, color: theme.colorScheme.secondary),
              onPressed: () {
                _mapController.move(LatLng(station['lat'], station['lng']), 15.0);
              },
            ),
          ),
        );
      },
    );
  }
}
