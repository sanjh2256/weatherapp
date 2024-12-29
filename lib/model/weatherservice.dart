import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../model/Weathermodel.dart';
import 'package:http/http.dart' as http;
class Weatherservice{

  static const BASE_URL='http://api.openweathermap.org/data/3.0/weather';
  final String apiKey;

  Weatherservice(this.apiKey);

  Future<Weather> getWeather(String cityname) async {
    print("City:- $cityname");
    final response = await http.get(Uri.parse('https://api.weatherapi.com/v1/current.json?key=fd6160f8683a473698692016242912&q=$cityname'));
    print("----------------");
    print(response);
  if (response.statusCode == 200) {
    return Weather.fromJson(jsonDecode(response.body));

  }else{
    throw Exception('Failed to load weather data');
  }
  }
  Future<String> getCurrentCity() async {

    // get permission from user
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
    }
    // fetch current loc
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );
    //convert the loc into a list of placemark obj
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

    //extract city name from the first placemark
    String? city = placemarks[0].locality;

    return city ?? "";
  }
}