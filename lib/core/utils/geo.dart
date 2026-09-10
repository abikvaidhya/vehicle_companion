import 'dart:math' as math;

import '../../domain/models/trip.dart';

/// Haversine distance in kilometres between two points.
double haversineKm(LatLngPoint a, LatLngPoint b) {
  const earthRadiusKm = 6371.0;
  final dLat = _toRad(b.latitude - a.latitude);
  final dLon = _toRad(b.longitude - a.longitude);
  final lat1 = _toRad(a.latitude);
  final lat2 = _toRad(b.latitude);

  final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
  return earthRadiusKm * c;
}

/// Total distance along a polyline of points.
double totalDistanceKm(List<LatLngPoint> points) {
  if (points.length < 2) return 0;
  var sum = 0.0;
  for (var i = 1; i < points.length; i++) {
    sum += haversineKm(points[i - 1], points[i]);
  }
  return sum;
}

double _toRad(double deg) => deg * math.pi / 180.0;
