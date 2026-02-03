class TaxiEstimate {
  final String provider;
  final int estimatedFare;
  final String waitTime;

  TaxiEstimate({
    required this.provider,
    required this.estimatedFare,
    required this.waitTime,
  });
}

class TaxiFareEstimator {
  List<TaxiEstimate> getEstimates(double distanceKm) {
    const baseRateOla = 12.0;
    const baseRateUber = 14.0;
    const baseRateRapido = 8.0;

    return [
      TaxiEstimate(
        provider: "Ola",
        estimatedFare: (distanceKm * baseRateOla).round() + 30,
        waitTime: "5 min",
      ),
      TaxiEstimate(
        provider: "Uber",
        estimatedFare: (distanceKm * baseRateUber).round() + 40,
        waitTime: "3 min",
      ),
      TaxiEstimate(
        provider: "Rapido",
        estimatedFare: (distanceKm * baseRateRapido).round() + 20,
        waitTime: "2 min",
      ),
    ];
  }
}
