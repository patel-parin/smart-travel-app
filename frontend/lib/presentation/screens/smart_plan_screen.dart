import 'package:flutter/material.dart';
import '../../services/smart_planner.dart';
import '../../services/uber_service.dart';

class SmartPlanScreen extends StatefulWidget {
  const SmartPlanScreen({super.key});

  @override
  State<SmartPlanScreen> createState() => _SmartPlanScreenState();
}

class _SmartPlanScreenState extends State<SmartPlanScreen> {
  final _sourceController = TextEditingController(text: 'NDLS');
  final _destController = TextEditingController(text: 'BCT');
  final _homeLatController = TextEditingController(text: '19.0760');
  final _homeLngController = TextEditingController(text: '72.8777');

  Future<List<CombinedTravelPlan>>? _planFuture;
  final SmartPlanner _planner = SmartPlanner();

  void _searchPlans() {
    final homeLat = double.tryParse(_homeLatController.text);
    final homeLng = double.tryParse(_homeLngController.text);

    if (homeLat == null || homeLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid home coordinates')),
      );
      return;
    }

    setState(() {
      _planFuture = _planner.planJourney(
        sourceStation: _sourceController.text.trim(),
        destinationStation: _destController.text.trim(),
        homeLat: homeLat,
        homeLng: homeLng,
      );
    });
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _destController.dispose();
    _homeLatController.dispose();
    _homeLngController.dispose();
    _planner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Travel Planner'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSearchCard(),
            const SizedBox(height: 16),
            if (_planFuture != null) _buildResultsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Plan Your Journey',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _sourceController,
                    decoration: const InputDecoration(
                      labelText: 'From Station',
                      hintText: 'e.g., NDLS',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.train),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _destController,
                    decoration: const InputDecoration(
                      labelText: 'To Station',
                      hintText: 'e.g., BCT',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Home Address Coordinates',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _homeLatController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.my_location),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _homeLngController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.my_location),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _searchPlans,
                icon: const Icon(Icons.search),
                label: const Text('Find Smart Plans'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    return FutureBuilder<List<CombinedTravelPlan>>(
      future: _planFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  CircularProgressIndicator(color: Colors.teal),
                  SizedBox(height: 16),
                  Text('Finding best travel options...'),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      snapshot.error.toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final plans = snapshot.data ?? [];
        if (plans.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No travel plans found'),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${plans.length} Travel Plan(s) Found',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...plans.map((plan) => _buildPlanCard(plan)),
          ],
        );
      },
    );
  }

  Widget _buildPlanCard(CombinedTravelPlan plan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: Column(
        children: [
          // Train Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.train, color: Colors.teal),
                    const SizedBox(width: 8),
                    Text(
                      plan.train.trainName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '#${plan.train.trainNumber}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTimeColumn('Departure', plan.train.departureTime),
                    const Icon(Icons.arrow_forward, color: Colors.grey),
                    _buildTimeColumn('Arrival', plan.train.arrivalTime),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        plan.train.duration,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Cab Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_taxi, color: Colors.amber),
                    const SizedBox(width: 8),
                    const Text(
                      'Cab to Home',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (plan.errorMessage != null)
                      const Chip(
                        label: Text('Estimate Only'),
                        backgroundColor: Colors.orange,
                        labelStyle: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (plan.hasCabOptions) ...[
                  ...plan.cabOptions.take(3).map((cab) => _buildCabOption(cab)),
                ] else ...[
                  Text(
                    plan.errorMessage ?? 'Cab prices unavailable',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
          // Total Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Estimated Cab Cost:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  plan.estimatedCabCost,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeColumn(String label, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          time,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCabOption(UberPriceEstimate cab) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(cab.displayName),
          Text(
            cab.priceRange,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            cab.durationFormatted,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
