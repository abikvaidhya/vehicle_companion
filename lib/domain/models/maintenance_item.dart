class MaintenanceItem {
  final String id;
  final String title;
  final DateTime? dueDate;
  final int? intervalKm;
  final DateTime? lastDone;
  final String? notes;
  final bool isCompleted;

  const MaintenanceItem({
    required this.id,
    required this.title,
    this.dueDate,
    this.intervalKm,
    this.lastDone,
    this.notes,
    this.isCompleted = false,
  });

  bool get isOverdue {
    if (isCompleted || dueDate == null) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  MaintenanceItem copyWith({
    String? id,
    String? title,
    DateTime? dueDate,
    int? intervalKm,
    DateTime? lastDone,
    String? notes,
    bool? isCompleted,
  }) {
    return MaintenanceItem(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      intervalKm: intervalKm ?? this.intervalKm,
      lastDone: lastDone ?? this.lastDone,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'dueDate': dueDate?.toIso8601String(),
      'intervalKm': intervalKm,
      'lastDone': lastDone?.toIso8601String(),
      'notes': notes,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory MaintenanceItem.fromMap(Map<String, dynamic> map) {
    return MaintenanceItem(
      id: map['id'] as String,
      title: map['title'] as String,
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'] as String)
          : null,
      intervalKm: map['intervalKm'] as int?,
      lastDone: map['lastDone'] != null
          ? DateTime.parse(map['lastDone'] as String)
          : null,
      notes: map['notes'] as String?,
      isCompleted: (map['isCompleted'] as int? ?? 0) == 1,
    );
  }
}
