import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../data/location_service.dart';
import '../../data/taxi_estimator.dart';

class LocalTransportScreen extends StatefulWidget {
  const LocalTransportScreen({super.key});

  @override
  State<LocalTransportScreen> createState() => _LocalTransportScreenState();
}

class _LocalTransportScreenState extends State<LocalTransportScreen> {
  List<TaxiEstimate> _taxiEstimates = [];
  bool _isLoading = true;
  String? _errorMessage;
  double? _distanceKm;

  @override
  void initState() {
    super.initState();
    _fetchTransportOptions();
  }

  Future<void> _fetchTransportOptions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get user's current location
      final locationService = context.read<LocationService>();
      final position = await locationService.getCurrentPosition();

      if (position == null) {
        setState(() {
          _errorMessage = locationService.errorMessage ?? 'Unable to get location';
          _isLoading = false;
        });
        return;
      }

      // Calculate distance to nearest station
      // In production, find the actual nearest station from a database
      // For demo, we use a reasonable local distance (capped at 30km for local transport)
      const stationLat = 19.0680;
      const stationLng = 72.8347;
      final rawDistance = locationService.calculateDistance(
        locationService.currentLatLng!,
        const LatLng(stationLat, stationLng),
      );
      
      // Cap distance to reasonable local transport range
      // If user is far from Mumbai, use a demo distance
      _distanceKm = rawDistance > 50 ? 8.5 : rawDistance; // 8.5km typical city ride

      // Get taxi estimates based on distance
      final taxiEstimator = TaxiFareEstimator();
      final estimates = taxiEstimator.getEstimates(_distanceKm!);

      setState(() {
        _taxiEstimates = estimates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch transport options: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Transport'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTransportOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Distance info banner
          if (_distanceKm != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Distance to station: ${_distanceKm!.toStringAsFixed(1)} km',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

          // Main content
          Expanded(
            child: _buildContent(theme),
          ),

          // Compare button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              onPressed: _taxiEstimates.isNotEmpty
                  ? () => Navigator.pushNamed(context, '/compare')
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Text('Compare All Options'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Searching for nearby transport...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchTransportOptions,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_taxiEstimates.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No transport options available nearby',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _taxiEstimates.length,
      itemBuilder: (context, index) {
        final estimate = _taxiEstimates[index];
        return _buildTransportCard(theme, estimate, index == 0);
      },
    );
  }

  Widget _buildTransportCard(ThemeData theme, TaxiEstimate estimate, bool isCheapest) {
    IconData providerIcon;
    Color providerColor;

    switch (estimate.provider.toLowerCase()) {
      case 'ola':
        providerIcon = Icons.local_taxi;
        providerColor = Colors.green;
        break;
      case 'uber':
        providerIcon = Icons.directions_car;
        providerColor = Colors.black87;
        break;
      case 'rapido':
        providerIcon = Icons.two_wheeler;
        providerColor = Colors.amber;
        break;
      case 'auto':
        providerIcon = Icons.electric_rickshaw;
        providerColor = Colors.orange;
        break;
      default:
        providerIcon = Icons.local_taxi;
        providerColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCheapest
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: providerColor.withOpacity(0.2),
          child: Icon(providerIcon, color: providerColor),
        ),
        title: Row(
          children: [
            Text(
              estimate.provider,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
            Text(
              estimate.vehicleType,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            ),
            if (isCheapest) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'CHEAPEST',
                  style: TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text('Arrives in ${estimate.waitTime}'),
        trailing: Text(
          '₹${estimate.estimatedFare}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
