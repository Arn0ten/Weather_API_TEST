import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:weather_app/API/const.dart';
import 'package:weather_app/Alert/weather_alert_messages.dart';

class Event {
  final String name;
  final DateTime dateTime;

  Event({required this.name, required this.dateTime});
}

class WeatherService {
  final WeatherFactory _weatherFactory;

  WeatherService(this._weatherFactory);

  Future<String> getWeatherType(String cityName) async {
    Weather? weather = await _weatherFactory.currentWeatherByCityName(cityName);
    return weather?.weatherDescription ?? "Clear";
  }
}

class EventAlertManager {
  final WeatherService _weatherService;

  EventAlertManager(this._weatherService);

  Future<String> generateAlertMessage(Event event, String cityName) async {
    String weatherType = await _weatherService.getWeatherType(cityName);
    return weatherAlertMessages[weatherType] ?? "Weather conditions are favorable. Enjoy your event!";
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final WeatherService _weatherService;
  late final EventAlertManager _alertManager;
  final List<Event> events = [
    Event(name: "Community Picnic", dateTime: DateTime.now().add(Duration(days: 3))),
    Event(name: "Outdoor Concert", dateTime: DateTime.now().add(Duration(days: 5))),
    Event(name: "Mukbang kalawat with father", dateTime: DateTime.now().add(Duration(days: 1))),
  ];

  @override
  void initState() {
    super.initState();

    _weatherService = WeatherService(WeatherFactory(OPENWEATHER_API_KEY));
    _alertManager = EventAlertManager(_weatherService);

    for (Event event in events) {
      _showWeatherAlert(event);
    }
  }

  void _showWeatherAlert(Event event) async {
    String alertMessage = await _alertManager.generateAlertMessage(event, "Manila");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.blue[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 30),
              SizedBox(width: 10),
              Text('Weather Alert for ${event.name}'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Forecast for ${DateFormat("MMMM d, yyyy").format(event.dateTime)}:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(alertMessage, textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Dismiss', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        title: Text("Weather Alert App"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Upcoming Events",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  Event event = events[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    color: Colors.white,
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(
                        Icons.event,
                        color: Colors.blueAccent,
                        size: 40,
                      ),
                      title: Text(
                        event.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        DateFormat("MMMM d, yyyy - hh:mm a").format(event.dateTime),
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.info_outline, color: Colors.blueAccent),
                        onPressed: () => _showWeatherAlert(event),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
