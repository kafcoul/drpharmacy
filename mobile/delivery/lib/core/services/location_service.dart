import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/repositories/delivery_repository.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService(ref.read(deliveryRepositoryProvider));
});

class LocationService {
  final DeliveryRepository _repository;
  StreamSubscription<Position>? _positionStreamSubscription;
  final StreamController<Position> _locationController =
      StreamController<Position>.broadcast();
  bool _isTracking = false;

  LocationService(this._repository);

  Stream<Position> get locationStream => _locationController.stream;

  Future<void> requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }
  }

  void startTracking() async {
    if (_isTracking) return;

    try {
      await requestPermission();

      _isTracking = true;
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters for better real-time tracking
      );

      _positionStreamSubscription =
          Geolocator.getPositionStream(
            locationSettings: locationSettings,
          ).listen((Position position) {
            _repository.updateLocation(position.latitude, position.longitude);
            _locationController.add(position);
            debugPrint(
              'Location updated: ${position.latitude}, ${position.longitude}',
            );
          });
    } catch (e) {
      debugPrint('Error starting location tracking: $e');
      _isTracking = false;
    }
  }

  void stopTracking() {
    _positionStreamSubscription?.cancel();
    _isTracking = false;
  }

  void dispose() {
    _locationController.close();
  }
}
