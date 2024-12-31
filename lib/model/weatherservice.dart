import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'Weathermodel.dart';

class WeatherService {
  static const String baseUrl = 'https://api.weatherapi.com/v1';
  final String apiKey;

  WeatherService(this.apiKey);

  // Get weather data for a specific city
  Future<Weather> getWeather(String cityName) async {
    try {
      print("CIty:- $cityName");
      final response = await http.get(
        Uri.parse('$baseUrl/current.json?key=$apiKey&q=$cityName'),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timed out');
        },
      );

      if (response.statusCode == 200) {
        return Weather.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key');
      } else if (response.statusCode == 404) {
        throw Exception('City not found');
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching weather data: $e');
    }
  }

  // Get the current city based on device location
  Future<String> getCurrentCity() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();

      // Request permission if denied
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      // Handle permanently denied permissions
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Location permissions are permanently denied. '
                'Please enable them in your phone settings.'
        );
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Convert position to address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        throw Exception('Unable to determine city name from coordinates');
      }

      // Get city name from the first placemark
      String? city = placemarks[0].locality;

      if (city == null || city.isEmpty) {
        // Fallback to subAdministrativeArea if locality is not available
        city = placemarks[0].subAdministrativeArea;
      }

      if (city == null || city.isEmpty) {
        throw Exception('Unable to determine city name');
      }

      return city;
    } catch (e) {
      throw Exception('Error getting current city: $e');
    }
  }

  // Get weather for current location
  Future<Weather> getWeatherForCurrentCity() async {
    try {
      final String city = await getCurrentCity();
      return await getWeather(city);
    } catch (e) {
      throw Exception('Failed to get weather for current location: $e');
    }
  }

  // Search for city suggestions (autocomplete)
  Future<List<String>> searchCities(String query) async {
    if (query.length < 2) return [];

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search.json?key=$apiKey&q=$query'),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Search request timed out');
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> results = jsonDecode(response.body);
        return results
            .map((result) => result['name'].toString())
            .toList();
      } else {
        throw Exception('Failed to search cities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching cities: $e');
    }
  }

  // Get forecast weather data
  Future<Weather> getForecast(String cityName, {int days = 7}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/forecast.json?key=$apiKey&q=$cityName&days=$days'),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Forecast request timed out');
        },
      );

      if (response.statusCode == 200) {
        return Weather.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load forecast data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching forecast data: $e');
    }
  }
}