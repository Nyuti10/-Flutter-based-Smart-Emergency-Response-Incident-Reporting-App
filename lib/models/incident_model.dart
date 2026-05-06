// incident_model.dart
// Defines the Incident data model, enums, and Hive type adapters.
// Enhanced: Added assignedResponder field and improved documentation.

import 'package:hive/hive.dart';

// ============================================================
// Enums for Category, Priority, and Status
// ============================================================

/// Categories of incidents that can be reported.
enum IncidentCategory {
  medical,
  fire,
  security,
  accident,
}

/// Priority levels for incidents — used for color coding throughout the app.
/// Critical → Red | High → Orange | Medium → Yellow/Amber | Low → Green
enum IncidentPriority {
  low,      // Green
  medium,   // Yellow
  high,     // Orange
  critical, // Red
}

/// Status of an incident.
enum IncidentStatus {
  active,
  resolved,
}

// ============================================================
// Hive Type Adapters for Enums
// ============================================================

/// Hive adapter for [IncidentCategory] enum.
class IncidentCategoryAdapter extends TypeAdapter<IncidentCategory> {
  @override
  final int typeId = 1;

  @override
  IncidentCategory read(BinaryReader reader) {
    return IncidentCategory.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, IncidentCategory obj) {
    writer.writeInt(obj.index);
  }
}

/// Hive adapter for [IncidentPriority] enum.
class IncidentPriorityAdapter extends TypeAdapter<IncidentPriority> {
  @override
  final int typeId = 2;

  @override
  IncidentPriority read(BinaryReader reader) {
    return IncidentPriority.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, IncidentPriority obj) {
    writer.writeInt(obj.index);
  }
}

/// Hive adapter for [IncidentStatus] enum.
class IncidentStatusAdapter extends TypeAdapter<IncidentStatus> {
  @override
  final int typeId = 3;

  @override
  IncidentStatus read(BinaryReader reader) {
    return IncidentStatus.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, IncidentStatus obj) {
    writer.writeInt(obj.index);
  }
}

// ============================================================
// Incident Model
// ============================================================

/// The main Incident data model stored locally in Hive.
/// Each incident has an auto-generated ID (format: INC + timestamp digits).
class Incident {
  final String id;                    // Auto-generated unique ID (e.g., INC174652839)
  final String title;                 // Short title of the incident
  final String description;           // Detailed description
  final IncidentCategory category;    // Medical, Fire, Security, Accident
  final IncidentPriority priority;    // Low, Medium, High, Critical
  final String location;              // Location of the incident
  IncidentStatus status;              // Active or Resolved
  final DateTime createdAt;           // When the incident was reported
  DateTime? resolvedAt;               // When the incident was resolved (nullable)
  final String assignedResponder;     // Name of the assigned responder

  Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.location,
    this.status = IncidentStatus.active,
    required this.createdAt,
    this.resolvedAt,
    this.assignedResponder = 'Unassigned',
  });

  /// Marks this incident as resolved with the current timestamp.
  void markResolved() {
    status = IncidentStatus.resolved;
    resolvedAt = DateTime.now();
  }
}

// ============================================================
// Hive Adapter for Incident Model
// ============================================================

/// Hive adapter for the [Incident] model — handles serialization/deserialization.
class IncidentAdapter extends TypeAdapter<Incident> {
  @override
  final int typeId = 0;

  @override
  Incident read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return Incident(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as IncidentCategory,
      priority: fields[4] as IncidentPriority,
      location: fields[5] as String,
      status: fields[6] as IncidentStatus,
      createdAt: DateTime.parse(fields[7] as String),
      resolvedAt: fields[8] != null ? DateTime.parse(fields[8] as String) : null,
      assignedResponder: (fields[9] as String?) ?? 'Unassigned',
    );
  }

  @override
  void write(BinaryWriter writer, Incident obj) {
    writer.writeByte(10); // total number of fields
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.title);
    writer.writeByte(2);
    writer.write(obj.description);
    writer.writeByte(3);
    writer.write(obj.category);
    writer.writeByte(4);
    writer.write(obj.priority);
    writer.writeByte(5);
    writer.write(obj.location);
    writer.writeByte(6);
    writer.write(obj.status);
    writer.writeByte(7);
    writer.write(obj.createdAt.toIso8601String());
    writer.writeByte(8);
    writer.write(obj.resolvedAt?.toIso8601String());
    writer.writeByte(9);
    writer.write(obj.assignedResponder);
  }
}
