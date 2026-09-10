import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../data/repositories/maintenance_repository.dart';
import '../../domain/models/maintenance_item.dart';

class MaintenanceController extends GetxController {
  MaintenanceController({MaintenanceRepository? repository})
      : _repo = repository ?? MaintenanceRepository();

  final MaintenanceRepository _repo;
  final _uuid = const Uuid();

  final items = <MaintenanceItem>[].obs;
  final isLoading = false.obs;
  final lastError = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadItems();
  }

  Future<void> loadItems() async {
    isLoading.value = true;
    try {
      final list = await _repo.getAll();
      items.assignAll(list);
    } catch (e) {
      lastError.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addItem(MaintenanceItem item) async {
    await _repo.insert(item);
    await loadItems();
  }

  Future<void> updateItem(MaintenanceItem item) async {
    await _repo.update(item);
    await loadItems();
  }

  Future<void> markCompleted(String id) async {
    final item = items.firstWhereOrNull((e) => e.id == id);
    if (item == null) return;
    final updated = item.copyWith(
      isCompleted: true,
      lastDone: DateTime.now(),
    );
    await _repo.update(updated);
    await loadItems();
  }

  Future<void> deleteItem(String id) async {
    await _repo.delete(id);
    items.removeWhere((e) => e.id == id);
  }

  MaintenanceItem createNew({
    required String title,
    DateTime? dueDate,
    int? intervalKm,
    String? notes,
  }) {
    return MaintenanceItem(
      id: _uuid.v4(),
      title: title,
      dueDate: dueDate,
      intervalKm: intervalKm,
      notes: notes,
    );
  }

  int get upcomingCount =>
      items.where((e) => !e.isCompleted).length;
}
