import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/formatters.dart';
import '../../domain/models/maintenance_item.dart';
import 'maintenance_controller.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<MaintenanceController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context, ctrl),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = ctrl.items;
        if (items.isEmpty) {
          return const Center(child: Text('No maintenance items'));
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = items[index];
            return _MaintenanceTile(
              item: item,
              onComplete: () => ctrl.markCompleted(item.id),
              onDelete: () => ctrl.deleteItem(item.id),
            );
          },
        );
      }),
    );
  }

  void _showAddSheet(BuildContext context, MaintenanceController ctrl) {
    final titleCtrl = TextEditingController();
    final intervalCtrl = TextEditingController();
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
              Text('New reminder', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title (e.g. Oil change)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: intervalCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Interval (km, optional)',
                  border: OutlineInputBorder(),
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
                  if (titleCtrl.text.trim().isEmpty) return;
                  final item = ctrl.createNew(
                    title: titleCtrl.text.trim(),
                    intervalKm: int.tryParse(intervalCtrl.text),
                    notes: notesCtrl.text.trim().isEmpty
                        ? null
                        : notesCtrl.text.trim(),
                    dueDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  ctrl.addItem(item);
                  Navigator.pop(ctx);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MaintenanceTile extends StatelessWidget {
  final MaintenanceItem item;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  const _MaintenanceTile({
    required this.item,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final overdue = item.isOverdue;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: overdue ? scheme.error : scheme.outlineVariant,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          item.isCompleted ? Icons.check_circle : Icons.build_circle_outlined,
          color: item.isCompleted
              ? scheme.primary
              : (overdue ? scheme.error : scheme.outline),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration:
                item.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          [
            if (item.dueDate != null)
              overdue
                  ? 'Overdue · ${formatDate(item.dueDate!)}'
                  : 'Due ${formatDate(item.dueDate!)}',
            if (item.intervalKm != null) 'Every ${item.intervalKm} km',
            if (item.notes != null) item.notes!,
          ].join(' · '),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'complete') onComplete();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            if (!item.isCompleted)
              const PopupMenuItem(value: 'complete', child: Text('Mark done')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}
