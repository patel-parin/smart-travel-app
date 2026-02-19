import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Model for train data from the Railway API
class RailTrain {
  final String trainNumber;
  final String trainName;
  final String sourceStation;
  final String destinationStation;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final double? destinationLat;
  final double? destinationLng;

  RailTrain({
    required this.trainNumber,
    required this.trainName,
    required this.sourceStation,
    required this.destinationStation,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    this.destinationLat,
    this.destinationLng,
  });

  factory RailTrain.fromJson(Map<String, dynamic> json) {
    return RailTrain(
      trainNumber: json['train_number']?.toString() ?? '',
      trainName: json['train_name']?.toString() ?? 'Unknown',
      sourceStation: json['source_station']?.toString() ?? '',
      destinationStation: json['destination_station']?.toString() ?? '',
      departureTime: json['departure_time']?.toString() ?? '--:--',
      arrivalTime: json['arrival_time']?.toString() ?? '--:--',
      duration: json['travel_duration']?.toString() ?? 'N/A',
      destinationLat: _parseDouble(json['destination_lat']),
      destinationLng: _parseDouble(json['destination_lng']),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

/// Service to fetch train data from RapidAPI Indian Railways
class RailService {
  static String get _apiKey => dotenv.env['RAPIDAPI_KEY'] ?? '';
  static const String _apiHost = 'indian-railway-irctc.p.rapidapi.com';
  static const String _baseUrl = 'https://indian-railway-irctc.p.rapidapi.com';

  final http.Client _client;

  RailService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches trains between source and destination stations
  /// [source] - Source station code (e.g., "NDLS" for New Delhi)
  /// [destination] - Destination station code (e.g., "BCT" for Mumbai Central)
  Future<List<RailTrain>> fetchTrains(String source, String destination) async {
    final uri = Uri.parse('$_baseUrl/getTrainsBetweenStations').replace(
      queryParameters: {
        'fromStationCode': source.toUpperCase(),
        'toStationCode': destination.toUpperCase(),
      },
    );

    try {
      final response = await _client.get(
        uri,
        headers: {
          'x-rapidapi-key': _apiKey,
          'x-rapidapi-host': _apiHost,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Handle different response structures
        List<dynamic> trainsList;
        if (data is List) {
          trainsList = data;
        } else if (data is Map && data['data'] != null) {
          trainsList = data['data'] as List<dynamic>;
        } else if (data is Map && data['trains'] != null) {
          trainsList = data['trains'] as List<dynamic>;
        } else {
          return [];
        }

        return trainsList
            .map((json) => RailTrain.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        throw RailServiceException('Invalid API key. Please check your RapidAPI key.');
      } else if (response.statusCode == 429) {
        throw RailServiceException('API rate limit exceeded. Please try again later.');
      } else {
        throw RailServiceException('Failed to fetch trains: ${response.statusCode}');
      }
    } on FormatException {
      throw RailServiceException('Invalid response format from API');
    } catch (e) {
      if (e is RailServiceException) rethrow;
      throw RailServiceException('Network error: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}

/// Custom exception for Rail Service errors
class RailServiceException implements Exception {
  final String message;
  RailServiceException(this.message);

  @override
  String toString() => 'RailServiceException: $message';
}
