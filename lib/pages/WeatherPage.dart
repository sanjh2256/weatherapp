import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../model/Weathermodel.dart';
import '../model/weatherservice.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {

  //api key
  final _weatherService = Weatherservice('56f1b0f02d4625840d80adce1dc3eab8');
  Weather? _weather;


  // fetch weather
  _fetchWeather() async {
    // get the current city
    String cityname = await _weatherService.getCurrentCity();

    // get weather for city
    try{
      final weather = await _weatherService.getWeather(cityname);
      setState(() {
        _weather = weather ;
      });
    }

    // any error
    catch (e){
      print(e);
    }
  }


  // weather animations
  String getWeaatherAnimation(String? maincondition){
    if (maincondition == null) return 'weatherassets/sunny.json';

    switch(maincondition.toLowerCase()){
      case 'clouds':
        return 'weatherassets/clouds.json';
      case 'sunny':
        return 'weatherassets/sunny.json';
      case 'snow':
        return 'weatherassets/snow.json';
      case 'thunderstrom':
        return 'weatherassets/thunder.json';
      case 'windy':
        return 'weatherassets/windy.json';
      default:
        return 'weatherassets/sunny.json';

    }
  }


  //init state
  @override
  void initState() {
    super.initState();

    //fetch weather on startup
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //city name
            Text(_weather?.cityname ?? "loading city.."),

            //animations
          Lottie.asset(getWeaatherAnimation(_weather?.maincondition)),

            //temperature
            Text('${_weather?.temperature.round()}°C'),

            //condition
            Text(_weather?.maincondition?? "")
          ],),
      ),
    );
  }
}

