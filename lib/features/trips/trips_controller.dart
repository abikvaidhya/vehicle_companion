import 'dart:async';

import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/cost_calculator.dart';
import '../../core/utils/geo.dart';
import '../../data/repositories/trip_repository.dart';
import '../../domain/models/trip.dart';
import '../../platform/location_channel.dart';

class TripsController extends GetxController {
  TripsController({
    TripRepository? repository,
    LocationChannel? locationChannel,
    CostCalculator? costCalculator,
  })  : _repo = repository ?? TripRepository(),
        _location = locationChannel ?? LocationChannel(),
        _costCalc = costCalculator ?? const CostCalculator();

  final TripRepository _repo;
  final LocationChannel _location;
  final CostCalculator _costCalc;
  final _uuid = const Uuid();

  final trips = <Trip>[].obs;
  final activeTrip = Rxn<Trip>();
  final isTracking = false.obs;
  final isLoading = false.obs;
  final lastError = RxnString();

  /// Default fuel type for cost estimates (can move to settings later).
  final fuelType = FuelType.petrol.obs;

  StreamSubscription? _locationSub;

  @override
  void onInit() {
    super.onInit();
    loadTrips();
  }

  @override
  void onClose() {
    _locationSub?.cancel();
    super.onClose();
  }

  Future<void> loadTrips() async {
    isLoading.value = true;
    try {
      final list = await _repo.getAll();
      trips.assignAll(list);
    } catch (e) {
      lastError.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _ensureLocationPermission() async {
    var status = await Permission.locationWhenInUse.status;
    if (status.isGranted) return true;
    status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  /// Start a new trip. [useGps] streams positions from native.
  Future<void> startTrip({bool useGps = true}) async {
    if (activeTrip.value != null) return;
    lastError.value = null;

    if (useGps) {
      final ok = await _ensureLocationPermission();
      if (!ok) {
        lastError.value = 'Location permission denied';
        Get.snackbar(
          'Permission needed',
          'Allow location access to track trips with GPS.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    final trip = Trip(
      id: _uuid.v4(),
      startTime: DateTime.now(),
      status: TripStatus.active,
      routePoints: const [],
    );
    activeTrip.value = trip;

    if (useGps) {
      isTracking.value = true;
      _locationSub?.cancel();
      _locationSub = _location.startTracking().listen(
        (pos) {
          final current = activeTrip.value;
          if (current == null) return;
          final point = LatLngPoint(
            (pos['latitude'] as num).toDouble(),
            (pos['longitude'] as num).toDouble(),
          );
          final points = [...current.routePoints, point];
          activeTrip.value = current.copyWith(
            routePoints: points,
            distanceKm: totalDistanceKm(points),
          );
        },
        onError: (e) {
          lastError.value = e.toString();
          isTracking.value = false;
        },
      );
    }
  }

  /// End active trip, compute distance/cost, persist.
  Future<void> endTrip({
    double? distanceKm,
    double? cost,
    String? notes,
    bool estimateCost = true,
  }) async {
    final current = activeTrip.value;
    if (current == null) return;

    await _stopTracking();

    final dist = distanceKm ?? totalDistanceKm(current.routePoints);
    final estimated = estimateCost && cost == null
        ? _costCalc.estimate(distanceKm: dist, fuelType: fuelType.value)
        : cost;

    final finished = current.copyWith(
      endTime: DateTime.now(),
      distanceKm: dist,
      cost: estimated,
      notes: notes ?? current.notes,
      status: TripStatus.completed,
    );

    try {
      await _repo.insert(finished);
      trips.insert(0, finished);
    } catch (e) {
      lastError.value = e.toString();
    }

    activeTrip.value = null;
  }

  Future<void> cancelTrip() async {
    await _stopTracking();
    activeTrip.value = null;
  }

  Future<void> _stopTracking() async {
    await _locationSub?.cancel();
    _locationSub = null;
    if (isTracking.value) {
      try {
        await _location.stopTracking();
      } catch (_) {}
      isTracking.value = false;
    }
  }

  Future<void> addManualTrip({
    required DateTime start,
    required DateTime end,
    required double distanceKm,
    double? cost,
    String? notes,
    bool estimateCost = true,
  }) async {
    final estimated = estimateCost && cost == null
        ? _costCalc.estimate(distanceKm: distanceKm, fuelType: fuelType.value)
        : cost;

    final trip = Trip(
      id: _uuid.v4(),
      startTime: start,
      endTime: end,
      distanceKm: distanceKm,
      cost: estimated,
      notes: notes,
      status: TripStatus.completed,
    );

    await _repo.insert(trip);
    trips.insert(0, trip);
  }

  Future<void> deleteTrip(String id) async {
    await _repo.delete(id);
    trips.removeWhere((t) => t.id == id);
  }

  Future<Trip?> getTrip(String id) => _repo.getById(id);
}
