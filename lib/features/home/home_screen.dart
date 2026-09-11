import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/formatters.dart';
import '../maintenance/maintenance_controller.dart';
import '../maintenance/maintenance_screen.dart';
import '../map/map_screen.dart';
import '../settings/settings_screen.dart';
import '../trips/trips_controller.dart';
import '../trips/trips_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tripsCtrl = Get.find<TripsController>();
    final maintCtrl = Get.find<MaintenanceController>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Companion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Get.to(() => const SettingsScreen()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await tripsCtrl.loadTrips();
          await maintCtrl.loadItems();
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Overview',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Log trips, estimate costs, and stay on top of maintenance.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),

            Obx(() {
              final active = tripsCtrl.activeTrip.value;
              if (active == null) {
                return _StartTripCard(
                  onStartGps: () => tripsCtrl.startTrip(useGps: true),
                  onManual: () => Get.to(() => const TripsScreen()),
                );
              }
              return _ActiveTripCard(
                distanceKm: active.distanceKm,
                pointCount: active.routePoints.length,
                startTime: active.startTime,
                isTracking: tripsCtrl.isTracking.value,
                onEnd: () => _confirmEndTrip(context, tripsCtrl),
                onCancel: () => tripsCtrl.cancelTrip(),
              );
            }),

            Obx(() {
              final err = tripsCtrl.lastError.value;
              if (err == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  err,
                  style: TextStyle(color: scheme.error, fontSize: 13),
                ),
              );
            }),

            const SizedBox(height: 20),

            _NavCard(
              icon: Icons.route,
              title: 'Trips',
              subtitle: Obx(() => Text('${tripsCtrl.trips.length} recorded')),
              onTap: () => Get.to(() => const TripsScreen()),
            ),
            const SizedBox(height: 10),
            _NavCard(
              icon: Icons.build_circle_outlined,
              title: 'Maintenance',
              subtitle: Obx(
                () => Text('${maintCtrl.upcomingCount} upcoming'),
              ),
              onTap: () => Get.to(() => const MaintenanceScreen()),
            ),
            const SizedBox(height: 10),
            _NavCard(
              icon: Icons.map_outlined,
              title: 'Map',
              subtitle: const Text('View trip routes'),
              onTap: () => Get.to(() => const MapScreen()),
            ),

            const SizedBox(height: 28),
            Text(
              'Hybrid architecture',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Flutter UI + GetX · Kotlin native channels for location, '
              'Bluetooth and background work.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmEndTrip(BuildContext context, TripsController ctrl) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('End trip?', style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 8),
                Obx(() {
                  final t = ctrl.activeTrip.value;
                  if (t == null) return const SizedBox.shrink();
                  return Text(
                    '${formatKm(t.distanceKm)} · ${t.routePoints.length} GPS points\n'
                    'Cost will be estimated from Settings fuel type.',
                  );
                }),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ctrl.endTrip();
                  },
                  child: const Text('Save trip'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Keep tracking'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StartTripCard extends StatelessWidget {
  final VoidCallback onStartGps;
  final VoidCallback onManual;

  const _StartTripCard({
    required this.onStartGps,
    required this.onManual,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.primaryContainer.withValues(alpha: 0.45),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.play_circle_fill, size: 36, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Start a trip',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onStartGps,
              icon: const Icon(Icons.gps_fixed),
              label: const Text('GPS tracking'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onManual,
              icon: const Icon(Icons.edit_note),
              label: const Text('Add manual trip'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveTripCard extends StatelessWidget {
  final double distanceKm;
  final int pointCount;
  final DateTime startTime;
  final bool isTracking;
  final VoidCallback onEnd;
  final VoidCallback onCancel;

  const _ActiveTripCard({
    required this.distanceKm,
    required this.pointCount,
    required this.startTime,
    required this.isTracking,
    required this.onEnd,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.tertiaryContainer.withValues(alpha: 0.55),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isTracking ? Icons.gps_fixed : Icons.directions_car,
                  color: scheme.tertiary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Trip in progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Started ${formatTime(startTime)} · ${formatKm(distanceKm)} · $pointCount points',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: onEnd,
                    child: const Text('End trip'),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: onCancel,
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget subtitle;
  final VoidCallback onTap;

  const _NavCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
