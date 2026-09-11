import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/utils/formatters.dart';
import '../../domain/models/trip.dart';
import '../trips/trips_controller.dart';

class MapScreen extends StatefulWidget {
  /// If set, only this trip is drawn. Otherwise all trips with points.
  final String? tripId;

  const MapScreen({super.key, this.tripId});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  String? _selectedTripId;

  @override
  void initState() {
    super.initState();
    _selectedTripId = widget.tripId;
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripsCtrl = Get.find<TripsController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tripId != null ? 'Trip route' : 'Trip map'),
      ),
      body: Obx(() {
        final all = tripsCtrl.trips;
        final tripsWithPoints = all
            .where((t) => t.routePoints.length >= 2)
            .toList();

        final focus = _selectedTripId != null
            ? tripsWithPoints.where((t) => t.id == _selectedTripId).toList()
            : tripsWithPoints;

        if (tripsWithPoints.isEmpty) {
          return _EmptyMapState(
            hasTrips: all.isNotEmpty,
          );
        }

        final polylines = <Polyline>{};
        final markers = <Marker>{};

        for (var i = 0; i < focus.length; i++) {
          final trip = focus[i];
          final points = trip.routePoints
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList();
          if (points.length < 2) continue;

          final color = _colorForIndex(i, Theme.of(context).colorScheme);
          polylines.add(
            Polyline(
              polylineId: PolylineId(trip.id),
              points: points,
              color: color,
              width: 5,
            ),
          );
          markers.add(
            Marker(
              markerId: MarkerId('${trip.id}_start'),
              position: points.first,
              infoWindow: InfoWindow(
                title: 'Start',
                snippet: formatDateTime(trip.startTime),
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen,
              ),
            ),
          );
          markers.add(
            Marker(
              markerId: MarkerId('${trip.id}_end'),
              position: points.last,
              infoWindow: InfoWindow(
                title: 'End · ${formatKm(trip.distanceKm)}',
                snippet: formatCost(trip.cost),
              ),
            ),
          );
        }

        final initial = _initialCamera(focus);

        return Column(
          children: [
            Expanded(
              child: GoogleMap(
                initialCameraPosition: initial,
                polylines: polylines,
                markers: markers,
                myLocationButtonEnabled: true,
                myLocationEnabled: false,
                zoomControlsEnabled: true,
                onMapCreated: (c) {
                  _mapController = c;
                  _fitBounds(focus);
                },
              ),
            ),
            if (widget.tripId == null && tripsWithPoints.isNotEmpty)
              SizedBox(
                height: 88,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  itemCount: tripsWithPoints.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final selected = _selectedTripId == null;
                      return FilterChip(
                        label: const Text('All'),
                        selected: selected,
                        onSelected: (_) {
                          setState(() => _selectedTripId = null);
                          _fitBounds(tripsWithPoints);
                        },
                      );
                    }
                    final trip = tripsWithPoints[index - 1];
                    final selected = _selectedTripId == trip.id;
                    return FilterChip(
                      label: Text(
                        '${formatDate(trip.startTime)} · ${formatKm(trip.distanceKm)}',
                      ),
                      selected: selected,
                      onSelected: (_) {
                        setState(() => _selectedTripId = trip.id);
                        _fitBounds([trip]);
                      },
                    );
                  },
                ),
              ),
          ],
        );
      }),
    );
  }

  CameraPosition _initialCamera(List<Trip> trips) {
    // Default: Göteborg area if somehow empty
    const fallback = CameraPosition(
      target: LatLng(57.7089, 11.9746),
      zoom: 11,
    );
    if (trips.isEmpty) return fallback;
    final first = trips.first.routePoints.first;
    return CameraPosition(
      target: LatLng(first.latitude, first.longitude),
      zoom: 13,
    );
  }

  Future<void> _fitBounds(List<Trip> trips) async {
    final controller = _mapController;
    if (controller == null) return;

    final points = <LatLng>[];
    for (final t in trips) {
      for (final p in t.routePoints) {
        points.add(LatLng(p.latitude, p.longitude));
      }
    }
    if (points.isEmpty) return;

    if (points.length == 1) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 15),
      );
      return;
    }

    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;
    for (final p in points) {
      minLat = minLat < p.latitude ? minLat : p.latitude;
      maxLat = maxLat > p.latitude ? maxLat : p.latitude;
      minLng = minLng < p.longitude ? minLng : p.longitude;
      maxLng = maxLng > p.longitude ? maxLng : p.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 64));
  }

  Color _colorForIndex(int index, ColorScheme scheme) {
    const hues = [
      Color(0xFF1565C0),
      Color(0xFF2E7D32),
      Color(0xFF6A1B9A),
      Color(0xFFC62828),
      Color(0xFF00838F),
      Color(0xFFEF6C00),
    ];
    return hues[index % hues.length];
  }
}

class _EmptyMapState extends StatelessWidget {
  final bool hasTrips;

  const _EmptyMapState({required this.hasTrips});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              hasTrips ? 'No GPS routes yet' : 'No trips to show',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              hasTrips
                  ? 'Start a trip with GPS tracking so route points are recorded.'
                  : 'Record a trip from Home, then open the map again.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
