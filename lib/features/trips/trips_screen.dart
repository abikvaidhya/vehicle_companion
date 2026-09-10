import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/formatters.dart';
import '../../domain/models/trip.dart';
import 'trip_detail_screen.dart';
import 'trips_controller.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TripsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Trips')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddManualTrip(context, ctrl),
        icon: const Icon(Icons.add),
        label: const Text('Manual trip'),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.trips.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ctrl.trips.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.route,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No trips yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a GPS trip from Home or add one manually.',
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

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
          itemCount: ctrl.trips.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final trip = ctrl.trips[index];
            return _TripTile(
              trip: trip,
              onTap: () => Get.to(() => TripDetailScreen(tripId: trip.id)),
              onDelete: () async {
                final ok = await Get.dialog<bool>(
                  AlertDialog(
                    title: const Text('Delete trip?'),
                    content: const Text('This cannot be undone.'),
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
                if (ok == true) await ctrl.deleteTrip(trip.id);
              },
            );
          },
        );
      }),
    );
  }

  void _showAddManualTrip(BuildContext context, TripsController ctrl) {
    final distanceCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add manual trip', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: distanceCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Distance (km)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: costCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Cost (optional, kr)',
                  border: OutlineInputBorder(),
                  helperText: 'Leave empty to estimate from fuel type',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  final distance = double.tryParse(
                        distanceCtrl.text.replaceAll(',', '.'),
                      ) ??
                      0;
                  if (distance <= 0) {
                    Get.snackbar('Invalid', 'Enter a distance greater than 0');
                    return;
                  }
                  final cost = double.tryParse(
                    costCtrl.text.replaceAll(',', '.'),
                  );
                  final now = DateTime.now();
                  ctrl.addManualTrip(
                    start: now.subtract(const Duration(hours: 1)),
                    end: now,
                    distanceKm: distance,
                    cost: cost,
                    notes: notesCtrl.text.trim().isEmpty
                        ? null
                        : notesCtrl.text.trim(),
                    estimateCost: cost == null,
                  );
                  Navigator.pop(ctx);
                },
                child: const Text('Save trip'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TripTile extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TripTile({
    required this.trip,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          formatDateTime(trip.startTime),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          [
            formatKm(trip.distanceKm),
            formatDuration(trip.duration),
            formatCost(trip.cost),
            if (trip.notes != null && trip.notes!.isNotEmpty) trip.notes!,
          ].join(' · '),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'open') onTap();
            if (v == 'delete') onDelete();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'open', child: Text('Open')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
