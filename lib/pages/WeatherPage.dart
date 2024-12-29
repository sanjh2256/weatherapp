import 'package:flutter/material.dart';
import 'package:weatherapp/model/weatherservice.dart';
import '../model/Weathermodel.dart';

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final Weatherservice weatherService = Weatherservice('fd6160f8683a473698692016242912');
  Weather? weather;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      String city = await weatherService.getCurrentCity();
      Weather fetchedWeather = await weatherService.getWeather(city);
      setState(() {
        weather = fetchedWeather;
      });
    } catch (e) {
      print('Error fetching weather: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: weather == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'City: ${weather!.cityName}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Temperature: ${weather!.temperature} °C',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Condition: ${weather!.condition}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
