import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/formatters.dart';
import '../../domain/models/trip.dart';
import 'trips_controller.dart';

class TripDetailScreen extends StatelessWidget {
  final String tripId;

  const TripDetailScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TripsController>();

    return FutureBuilder<Trip?>(
      future: ctrl.getTrip(tripId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Trip')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final trip = snapshot.data ??
            ctrl.trips.firstWhereOrNull((t) => t.id == tripId);

        if (trip == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Trip')),
            body: const Center(child: Text('Trip not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Trip details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final ok = await Get.dialog<bool>(
                    AlertDialog(
                      title: const Text('Delete trip?'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(result: false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Get.back(result: true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await ctrl.deleteTrip(trip.id);
                    Get.back();
                  }
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _InfoRow(label: 'Started', value: formatDateTime(trip.startTime)),
              if (trip.endTime != null)
                _InfoRow(label: 'Ended', value: formatDateTime(trip.endTime!)),
              _InfoRow(label: 'Duration', value: formatDuration(trip.duration)),
              _InfoRow(label: 'Distance', value: formatKm(trip.distanceKm)),
              _InfoRow(label: 'Cost', value: formatCost(trip.cost)),
              _InfoRow(
                label: 'GPS points',
                value: '${trip.routePoints.length}',
              ),
              if (trip.notes != null && trip.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Notes', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(trip.notes!),
              ],
              const SizedBox(height: 24),
              Text(
                'Route preview',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              if (trip.routePoints.isEmpty)
                Text(
                  'No GPS points (manual trip or tracking not connected yet).',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'First: ${trip.routePoints.first}',
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Last:  ${trip.routePoints.last}',
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Map polyline will use these points once google_maps_flutter is added.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
