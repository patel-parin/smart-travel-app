import 'rail_service.dart';
import 'uber_service.dart';

/// Combined travel plan with train and cab details
class CombinedTravelPlan {
  final RailTrain train;
  final List<UberPriceEstimate> cabOptions;
  final double stationLat;
  final double stationLng;
  final double homeLat;
  final double homeLng;
  final String? errorMessage;

  CombinedTravelPlan({
    required this.train,
    required this.cabOptions,
    required this.stationLat,
    required this.stationLng,
    required this.homeLat,
    required this.homeLng,
    this.errorMessage,
  });

  /// Returns the cheapest cab option
  UberPriceEstimate? get cheapestCab {
    if (cabOptions.isEmpty) return null;
    return cabOptions.reduce((a, b) => 
      a.lowEstimate < b.lowEstimate ? a : b);
  }

  /// Returns total estimated cost (train fare not included - API dependent)
  String get estimatedCabCost {
    final cab = cheapestCab;
    if (cab == null) return 'N/A';
    return cab.priceRange;
  }

  /// Checks if the plan has cab options available
  bool get hasCabOptions => cabOptions.isNotEmpty;
}

/// Smart planner that combines train and cab bookings
class SmartPlanner {
  final RailService _railService;
  final UberService _uberService;

  // Station coordinates lookup (common Indian railway stations)
  // In production, this would come from an API or database
  static final Map<String, Map<String, double>> _stationCoordinates = {
    'NDLS': {'lat': 28.6428, 'lng': 77.2195},   // New Delhi
    'BCT': {'lat': 19.0680, 'lng': 72.8347},    // Mumbai Central
    'CSTM': {'lat': 18.9398, 'lng': 72.8354},   // Mumbai CST
    'HWH': {'lat': 22.5839, 'lng': 88.3428},    // Howrah
    'MAS': {'lat': 13.0827, 'lng': 80.2707},    // Chennai Central
    'SBC': {'lat': 12.9784, 'lng': 77.5717},    // Bangalore
    'ADI': {'lat': 23.0225, 'lng': 72.5714},    // Ahmedabad
    'JP': {'lat': 26.9204, 'lng': 75.7855},     // Jaipur
    'LKO': {'lat': 26.8302, 'lng': 80.9207},    // Lucknow
    'PUNE': {'lat': 18.5285, 'lng': 73.8743},   // Pune
    'ST': {'lat': 21.2060, 'lng': 72.8411},     // Surat
    'BRC': {'lat': 22.3101, 'lng': 73.1812},    // Vadodara
    'GWL': {'lat': 26.2183, 'lng': 78.1828},    // Gwalior
    'AGC': {'lat': 27.1591, 'lng': 78.0081},    // Agra Cantt
  };

  SmartPlanner({
    RailService? railService,
    UberService? uberService,
  })  : _railService = railService ?? RailService(),
        _uberService = uberService ?? UberService();

  /// Gets station coordinates from code
  /// Returns null if station not found
  Map<String, double>? getStationCoordinates(String stationCode) {
    return _stationCoordinates[stationCode.toUpperCase()];
  }

  /// Plans a complete journey from source station to home
  /// 
  /// [sourceStation] - Source station code (e.g., "NDLS")
  /// [destinationStation] - Destination station code (e.g., "BCT")
  /// [homeLat], [homeLng] - User's home/final destination coordinates
  Future<List<CombinedTravelPlan>> planJourney({
    required String sourceStation,
    required String destinationStation,
    required double homeLat,
    required double homeLng,
  }) async {
    // Step 1: Fetch available trains
    final trains = await _railService.fetchTrains(sourceStation, destinationStation);
    
    if (trains.isEmpty) {
      throw SmartPlannerException('No trains found between $sourceStation and $destinationStation');
    }

    // Step 2: Get destination station coordinates
    final stationCoords = getStationCoordinates(destinationStation);
    
    double stationLat;
    double stationLng;
    
    if (stationCoords != null) {
      stationLat = stationCoords['lat']!;
      stationLng = stationCoords['lng']!;
    } else if (trains.first.destinationLat != null && trains.first.destinationLng != null) {
      // Use coordinates from API response if available
      stationLat = trains.first.destinationLat!;
      stationLng = trains.first.destinationLng!;
    } else {
      throw SmartPlannerException('Unable to find coordinates for station: $destinationStation');
    }

    // Step 3: Fetch cab prices from station to home
    List<UberPriceEstimate> cabPrices = [];
    String? cabError;
    
    try {
      cabPrices = await _uberService.getUberPrice(
        stationLat,
        stationLng,
        homeLat,
        homeLng,
      );
    } on UberServiceException catch (e) {
      cabError = e.message;
    }

    // Step 4: Create combined plans for each train
    return trains.map((train) => CombinedTravelPlan(
      train: train,
      cabOptions: cabPrices,
      stationLat: stationLat,
      stationLng: stationLng,
      homeLat: homeLat,
      homeLng: homeLng,
      errorMessage: cabError,
    )).toList();
  }

  /// Quick estimate for a single train with cab
  Future<CombinedTravelPlan?> getQuickPlan({
    required RailTrain train,
    required String destinationStationCode,
    required double homeLat,
    required double homeLng,
  }) async {
    final stationCoords = getStationCoordinates(destinationStationCode);
    
    if (stationCoords == null) {
      return null;
    }

    final stationLat = stationCoords['lat']!;
    final stationLng = stationCoords['lng']!;

    try {
      final cabPrices = await _uberService.getUberPrice(
        stationLat,
        stationLng,
        homeLat,
        homeLng,
      );

      return CombinedTravelPlan(
        train: train,
        cabOptions: cabPrices,
        stationLat: stationLat,
        stationLng: stationLng,
        homeLat: homeLat,
        homeLng: homeLng,
      );
    } on UberServiceException catch (e) {
      return CombinedTravelPlan(
        train: train,
        cabOptions: [],
        stationLat: stationLat,
        stationLng: stationLng,
        homeLat: homeLat,
        homeLng: homeLng,
        errorMessage: e.message,
      );
    }
  }

  void dispose() {
    _railService.dispose();
    _uberService.dispose();
  }
}

/// Custom exception for Smart Planner errors
class SmartPlannerException implements Exception {
  final String message;
  SmartPlannerException(this.message);

  @override
  String toString() => 'SmartPlannerException: $message';
}
