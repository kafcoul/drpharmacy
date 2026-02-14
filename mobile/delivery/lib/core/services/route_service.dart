import 'package:dio/dio.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/models/route_info.dart';

class RouteService {
  final String apiKey;
  final Dio _dio = Dio();

  RouteService(this.apiKey);

  Future<RouteInfo?> getRouteInfo(LatLng origin, LatLng destination) async {
    try {
      final url = 'https://maps.googleapis.com/maps/api/directions/json';
      final response = await _dio.get(url, queryParameters: {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'mode': 'driving',
        'key': apiKey,
        'language': 'fr', // French instructions
      });

      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        final data = response.data;
        final route = data['routes'][0];
        final leg = route['legs'][0];
        
        // Decode points
        final points = PolylinePoints().decodePolyline(route['overview_polyline']['points']);
        final latLngs = points.map((p) => LatLng(p.latitude, p.longitude)).toList();

        // Steps
        final steps = (leg['steps'] as List)
            .map((s) => RouteStep.fromJson(s))
            .toList();

        return RouteInfo(
          points: latLngs,
          totalDistance: leg['distance']['text'],
          totalDuration: leg['duration']['text'],
          steps: steps,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Legacy support if needed, or deprecate
  Future<List<LatLng>> getRoute(LatLng origin, LatLng destination) async {
    final info = await getRouteInfo(origin, destination);
    return info?.points ?? [];
  }
}
