class Weather {
  final String cityName;
  final double temperatuer;
  final String mainCondition;

  Weather({
    required this.cityName,
    required this.temperatuer,
    required this.mainCondition,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperatuer: json['main']['temp'].toDouble(),
      mainCondition: json['weather'][0]['main'],
    );
  }
}
