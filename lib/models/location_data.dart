import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyLocation {
  final double lat;
  final double lng;

  MyLocation(this.lat, this.lng);

  LatLng toLatLng() => LatLng(lat, lng);
}