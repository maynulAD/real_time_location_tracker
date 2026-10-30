import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LocationTrackerApp());
}

class LocationTrackerApp extends StatelessWidget {
  const LocationTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real-Time Location Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2196F3)),
      ),
      home: const LocationTrackerScreen(),
    );
  }
}

class LocationTrackerScreen extends StatefulWidget {
  const LocationTrackerScreen({super.key});

  @override
  State<LocationTrackerScreen> createState() => _LocationTrackerScreenState();
}

class _LocationTrackerScreenState extends State<LocationTrackerScreen> {
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionSubscription;
  Position? _currentPosition;
  final List<LatLng> _trackPoints = [];
  bool _loading = true;
  String? _error;

  static const CameraPosition _fallbackCamera = CameraPosition(
    target: LatLng(23.7216771, 90.4165835),
    zoom: 15,
  );

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  Future<void> _startLocationTracking() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are turned off. Please enable GPS.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission was denied.');
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permission is permanently denied. Enable it from app settings.',
        );
      }

      final firstPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _updatePosition(firstPosition, animate: false);

      // Poll the device location every 10 seconds as requested.
      _positionSubscription?.cancel();
      _positionSubscription = Stream.periodic(
        const Duration(seconds: 10),
      ).asyncMap((_) => Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
            ),
          )).listen((position) => _updatePosition(position));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _updatePosition(Position position, {bool animate = true}) {
    final point = LatLng(position.latitude, position.longitude);
    if (!mounted) return;

    setState(() {
      _currentPosition = position;
      if (_trackPoints.isEmpty ||
          _trackPoints.last.latitude != point.latitude ||
          _trackPoints.last.longitude != point.longitude) {
        _trackPoints.add(point);
      }
      _loading = false;
      _error = null;
    });

    if (animate) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: point, zoom: 17),
        ),
      );
    } else {
      _mapController?.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: point, zoom: 16),
        ),
      );
    }
  }

  Set<Marker> get _markers {
    final position = _currentPosition;
    if (position == null) return {};
    final point = LatLng(position.latitude, position.longitude);
    return {
      Marker(
        markerId: const MarkerId('current_location'),
        position: point,
        infoWindow: InfoWindow(
          title: 'My current location',
          snippet:
              'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}',
        ),
      ),
    };
  }

  Set<Polyline> get _polylines {
    if (_trackPoints.length < 2) return {};
    return {
      Polyline(
        polylineId: const PolylineId('location_track'),
        points: List<LatLng>.unmodifiable(_trackPoints),
        color: const Color(0xFF1976D2),
        width: 6,
        geodesic: true,
      ),
    };
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final position = _currentPosition;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Real-Time Location Tracker',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _fallbackCamera,
            onMapCreated: (controller) {
              _mapController = controller;
              if (position != null) {
                controller.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(position.latitude, position.longitude),
                    16,
                  ),
                );
              }
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
            markers: _markers,
            polylines: _polylines,
          ),
          if (_loading)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                      SizedBox(width: 12),
                      Text('Getting your current location...'),
                    ],
                  ),
                ),
              ),
            ),
          if (_error != null)
            Positioned(
              left: 16,
              right: 16,
              top: 16,
              child: Material(
                color: Colors.white,
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Location unavailable',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(_error!),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _startLocationTracking,
                          child: const Text('Try again'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (position != null)
            Positioned(
              left: 16,
              top: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 5)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('My Current Location',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    Text(
                      '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: position == null
          ? null
          : FloatingActionButton(
              tooltip: 'Go to my location',
              onPressed: () => _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(
                  LatLng(position.latitude, position.longitude),
                  17,
                ),
              ),
              child: const Icon(Icons.my_location),
            ),
    );
  }
}
