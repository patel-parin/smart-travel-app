import 'package:flutter/material.dart';
import '../../models/travel_models.dart';

class CompareTransportScreen extends StatelessWidget {
  const CompareTransportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock data for comparison
    final List<TransportOption> options = [
      TransportOption(
        provider: 'Uber Intercity',
        eta: '10:30 AM',
        duration: '4h 20m',
        fare: '₹4,200',
        convenience: 4.5,
      ),
      TransportOption(
        provider: 'Rail + Metro',
        eta: '11:15 AM',
        duration: '5h 05m',
        fare: '₹850',
        convenience: 3.5,
        isBest: true, // Example of "Best Economical Option"
      ),
      TransportOption(
        provider: 'Ola Electric',
        eta: '10:15 AM',
        duration: '4h 05m',
        fare: '₹5,100',
        convenience: 5.0,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Options'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSuggestionBanner(theme),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                return _buildComparisonCard(theme, option);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionBanner(ThemeData theme) {
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
          const Expanded(
            child: Text(
              'Antigravity Suggests: Rail + Metro is 80% cheaper with moderate convenience.',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
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
