class RouteStep {
  final String instruction;
  final String distance;
  final String duration;

  RouteStep({
    required this.instruction,
    required this.distance,
    required this.duration,
  });

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    return RouteStep(
      instruction: json['html_instructions'] ?? '',
      distance: json['distance']['text'] ?? '',
      duration: json['duration']['text'] ?? '',
    );
  }
}

class RouteInfo {
  final List<dynamic> points; // LatLng is from google_maps_flutter
  final String totalDistance;
  final String totalDuration;
  final List<RouteStep> steps;

  RouteInfo({
    required this.points,
    required this.totalDistance,
    required this.totalDuration,
    required this.steps,
  });
}
