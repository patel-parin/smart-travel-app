class TaxiEstimate {
  final String provider;
  final int estimatedFare;
  final String waitTime;
  final String vehicleType;

  TaxiEstimate({
    required this.provider,
    required this.estimatedFare,
    required this.waitTime,
    this.vehicleType = 'Car',
  });
}

class TaxiFareEstimator {
  // Realistic 2025 Indian taxi rates
  // Base fare covers first 2km, then per-km rate applies
  
  static const double _olaBaseFare = 50.0;      // First 2km included
  static const double _olaPerKm = 9.0;          // After 2km
  
  static const double _uberBaseFare = 55.0;     // First 2km included  
  static const double _uberPerKm = 10.0;        // After 2km
  
  static const double _rapidoBaseFare = 20.0;   // Bike taxi base
  static const double _rapidoPerKm = 4.0;       // Per km for bike
  
  static const double _autoBaseFare = 30.0;     // Auto rickshaw
  static const double _autoPerKm = 6.0;

  List<TaxiEstimate> getEstimates(double distanceKm) {
    // Ensure minimum distance of 1km
    final effectiveDistance = distanceKm < 1 ? 1.0 : distanceKm;
    
    // Calculate fares (base covers first 2km)
    final extraKm = (effectiveDistance - 2.0).clamp(0, double.infinity);
    
    final olaFare = (_olaBaseFare + (extraKm * _olaPerKm)).round();
    final uberFare = (_uberBaseFare + (extraKm * _uberPerKm)).round();
    final rapidoFare = (_rapidoBaseFare + (effectiveDistance * _rapidoPerKm)).round();
    final autoFare = (_autoBaseFare + (extraKm * _autoPerKm)).round();

    return [
      TaxiEstimate(
        provider: "Rapido",
        estimatedFare: rapidoFare,
        waitTime: "2 min",
        vehicleType: "Bike",
      ),
      TaxiEstimate(
        provider: "Auto",
        estimatedFare: autoFare,
        waitTime: "4 min",
        vehicleType: "Auto",
      ),
      TaxiEstimate(
        provider: "Ola",
        estimatedFare: olaFare,
        waitTime: "5 min",
        vehicleType: "Mini",
      ),
      TaxiEstimate(
        provider: "Uber",
        estimatedFare: uberFare,
        waitTime: "3 min",
        vehicleType: "Go",
      ),
    ];
  }
}
