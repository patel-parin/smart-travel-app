import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/location_service.dart';
import '../../data/railway_service.dart';
import '../../data/taxi_estimator.dart';
import '../../models/travel_models.dart';

class CompareTransportScreen extends StatefulWidget {
  const CompareTransportScreen({super.key});

  @override
  State<CompareTransportScreen> createState() => _CompareTransportScreenState();
}

class _CompareTransportScreenState extends State<CompareTransportScreen> {
  List<TransportOption> _options = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _bestSuggestion = '';

  @override
  void initState() {
    super.initState();
    _fetchAllOptions();
  }

  bool _hasTrains = false;

  Future<void> _fetchAllOptions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final locationService = context.read<LocationService>();
      await locationService.getCurrentPosition();

      // Try to fetch train options
      final railService = MockRailwayService();
      List<Train> trains = [];
      try {
        trains = await railService.getTrainsBetweenStations('Mumbai', 'Delhi');
      } catch (_) {
        // No trains available - continue with local transport only
        trains = [];
      }

      _hasTrains = trains.isNotEmpty;

      // Calculate taxi estimates for local transport
      final taxiEstimator = TaxiFareEstimator();
      final taxiEstimates = taxiEstimator.getEstimates(8.5); // Local distance ~8.5km

      // Build transport options
      final List<TransportOption> options = [];

      // Add train options only if available
      if (_hasTrains) {
        for (final train in trains) {
          options.add(TransportOption(
            provider: '🚆 ${train.name}',
            eta: train.arrival,
            duration: train.duration,
            fare: '₹450 - ₹1,200',
            convenience: 3.5,
          ));
        }
      }

      // Always add local transport options
      for (final taxi in taxiEstimates) {
        String icon = '';
        double convenience = 4.0;
        String duration = '25 min';
        
        switch (taxi.provider.toLowerCase()) {
          case 'rapido':
            icon = '🏍️';
            convenience = 3.5;
            duration = '20 min';
            break;
          case 'auto':
            icon = '🛺';
            convenience = 3.8;
            duration = '25 min';
            break;
          case 'ola':
            icon = '🚕';
            convenience = 4.2;
            duration = '22 min';
            break;
          case 'uber':
            icon = '🚗';
            convenience = 4.5;
            duration = '22 min';
            break;
        }
        
        options.add(TransportOption(
          provider: '$icon ${taxi.provider} ${taxi.vehicleType}',
          eta: taxi.waitTime,
          duration: duration,
          fare: '₹${taxi.estimatedFare}',
          convenience: convenience,
        ));
      }

      // Mark best option
      if (options.isNotEmpty) {
        int bestIndex = 0;
        
        if (_hasTrains) {
          // If trains available, mark train as best (cheapest for long distance)
          bestIndex = 0;
          _bestSuggestion = 'Train is up to 70% cheaper than cab for intercity travel.';
        } else {
          // No trains - find cheapest local transport
          bestIndex = options.indexWhere((o) => o.provider.contains('Rapido'));
          if (bestIndex == -1) bestIndex = 0;
          _bestSuggestion = 'Rapido Bike is the fastest and most affordable for short distances.';
        }
        
        final best = options[bestIndex];
        options[bestIndex] = TransportOption(
          provider: best.provider,
          eta: best.eta,
          duration: best.duration,
          fare: best.fare,
          convenience: best.convenience,
          isBest: true,
        );
      }

      setState(() {
        _options = options;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load options: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Options'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAllOptions,
          ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Comparing all transport options...',
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
                onPressed: _fetchAllOptions,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_options.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No transport options found',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildSuggestionBanner(theme),
        if (!_hasTrains)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No trains available for this route. Showing local transport options.',
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _options.length,
            itemBuilder: (context, index) {
              final option = _options[index];
              return _buildComparisonCard(theme, option);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionBanner(ThemeData theme) {
    if (_bestSuggestion.isEmpty) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Smart Suggestion: $_bestSuggestion',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(ThemeData theme, TransportOption option) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: option.isBest 
          ? Border.all(color: theme.colorScheme.primary, width: 2)
          : null,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      option.provider,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      option.fare,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildIconLabel(Icons.access_time, option.duration),
                    const SizedBox(width: 16),
                    _buildIconLabel(Icons.schedule, 'ETA: ${option.eta}'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Convenience: ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ...List.generate(5, (index) {
                      return Icon(
                        index < option.convenience.floor() 
                          ? Icons.star 
                          : (index < option.convenience ? Icons.star_half : Icons.star_border),
                        size: 16,
                        color: Colors.amber,
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          if (option.isBest)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: const Text(
                  'BEST CHOICE',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          // Navigate button
          Positioned(
            bottom: 12,
            right: 12,
            child: TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/guide'),
              icon: const Icon(Icons.directions, size: 18),
              label: const Text('Guide'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }
}
