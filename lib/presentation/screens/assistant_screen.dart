import 'package:flutter/material.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _sourceController = TextEditingController();
  final _destController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Rail Assistant')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Section
            Text('Plan your multimodal journey', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            TextField(
              controller: _sourceController,
              decoration: const InputDecoration(
                labelText: 'Source Location',
                prefixIcon: Icon(Icons.my_location),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _destController,
              decoration: const InputDecoration(
                labelText: 'Destination Location',
                prefixIcon: Icon(Icons.place),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/compare'),
              icon: const Icon(Icons.compare_arrows),
              label: const Text('Compare Transportation Modes'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Explore Features',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildFeatureTile(
              context, 
              Icons.train, 
              'Nearby Railway Station', 
              'Find the nearest rail hub', 
              '/nearby',
              theme.colorScheme.secondary
            ),
            _buildFeatureTile(
              context, 
              Icons.directions_bus, 
              'Local Transport Options', 
              'Metro, Ola, Uber, and more', 
              '/local',
              theme.colorScheme.tertiary
            ),
            const SizedBox(height: 32),
            Text(
              'Recent Searches',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            const Center(
              child: Column(
                children: [
                  Icon(Icons.history, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('No history available', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onTap: (index) {
          if (index == 0) Navigator.pop(context);
          if (index == 1) Navigator.pushNamed(context, '/profile');
        },
      ),
    );
  }

  Widget _buildFeatureTile(
    BuildContext context, 
    IconData icon, 
    String title, 
    String subtitle, 
    String route,
    Color color,
  ) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
