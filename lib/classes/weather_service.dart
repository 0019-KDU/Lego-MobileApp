import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:lego/classes/wether_model.dart';

class WeatherService {
  static const BASE_URL = "http://api.openweathermap.org/data/2.5/weather";
  late final String apiKey;

  WeatherService(this.apiKey);
  Future<Weather> getWeather(String cityName) async {
    print(cityName);
    try {
      final response = await http
          .get(Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=metric'));
      final url = '$BASE_URL?q=$cityName&appid=$apiKey&units=metric';
      print('API URL: $url');
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return Weather.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('City not found');
      } else {
        print('Failed to get weather. Status Code: ${response.statusCode}');
        throw Exception('Failed to get weather: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('An error occurred while getting weather data: $e');
    }
  }

  Future<String> getCurrentDistrict() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    String? district = placemarks.isNotEmpty
        ? placemarks[0]
            .subAdministrativeArea // Use subAdministrativeArea for the district name
        : null;

    return district ?? "Unknown";
  }
}
