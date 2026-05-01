import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  GoogleMapController? _mapController;
  Timer? _timer;

  // Trackers for UI elements
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final List<LatLng> _pathPoints = [];

  @override
  void initState() {
    super.initState();
    // 1. Initial fetch to set the starting point
    _updateLocation();
    // 2. Real-Time Location Updates: Fetch every 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) => _updateLocation());
  }

  Future<void> _updateLocation() async {
    try {
      Position position = await _locationService.getCurrentLocation();
      LatLng newPos = LatLng(position.latitude, position.longitude);

      setState(() {
        _pathPoints.add(newPos);
        
        // Update Marker with Info Window (as per Assignment Task 4)
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId('me'),
            position: newPos,
            infoWindow: InfoWindow(
              title: 'My current location',
              snippet: '${newPos.latitude}, ${newPos.longitude}',
            ),
          ),
        );

        // Update Polyline Tracking
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('my_track'),
            points: _pathPoints,
            color: Colors.blue,
            width: 6,
          ),
        );
      });

      // Automatic Map Animation
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(newPos, 16));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Real-Time Location Tracker')),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(target: LatLng(0, 0), zoom: 2),
        onMapCreated: (controller) => _mapController = controller,
        markers: _markers,
        polylines: _polylines,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}