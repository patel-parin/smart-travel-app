import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          // Map Banner Placeholder
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.1),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_rounded, size: 64, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Map Placeholder', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildHomeButton(
                  context,
                  'Smart Rail\nAssistant',
                  Icons.smart_toy_rounded,
                  '/assistant',
                  theme.colorScheme.primary,
                ),
                _buildHomeButton(
                  context,
                  'Nearby\nStations',
                  Icons.location_on_rounded,
                  '/nearby',
                  theme.colorScheme.secondary,
                ),
                _buildHomeButton(
                  context,
                  'Local\nTransport',
                  Icons.directions_bus_rounded,
                  '/local',
                  theme.colorScheme.tertiary,
                ),
                _buildHomeButton(
                  context,
                  'Profile\nSettings',
                  Icons.person_rounded,
                  '/profile',
                  Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeButton(
    BuildContext context,
    String label,
    IconData icon,
    String route,
    Color color,
  ) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
