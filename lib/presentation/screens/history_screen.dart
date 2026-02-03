import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock history data
    final history = [
      {'route': 'Mumbai to Pune', 'date': '24 Jan 2026', 'mode': 'Rail + Metro'},
      {'route': 'Delhi to Agra', 'date': '15 Jan 2026', 'mode': 'Uber Intercity'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Travel History')),
      body: history.isEmpty
          ? const Center(
              child: Text('No history available', style: TextStyle(color: Colors.grey)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return Card(
                  color: theme.colorScheme.surface,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
                      child: Icon(Icons.history, color: theme.colorScheme.secondary),
                    ),
                    title: Text(item['route']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${item['date']} • ${item['mode']}'),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {},
                  ),
                );
              },
            ),
    );
  }
}
