// hive_service.dart
// Handles all Hive database operations — CRUD for incidents.
// Enhanced: INC-prefix ID format, 4 specific sample incidents, clear-and-reseed support.

import 'package:hive_flutter/hive_flutter.dart';
import '../models/incident_model.dart';

/// Service class for Hive local database operations.
/// Provides offline-first data persistence for incidents.
class HiveService {
  static const String _boxName = 'incidents'; // Hive box name

  /// Initialize Hive, register all type adapters, and open the incidents box.
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters for enums and model
    Hive.registerAdapter(IncidentCategoryAdapter());
    Hive.registerAdapter(IncidentPriorityAdapter());
    Hive.registerAdapter(IncidentStatusAdapter());
    Hive.registerAdapter(IncidentAdapter());

    // Open the incidents box for offline storage
    await Hive.openBox<Incident>(_boxName);
  }

  /// Get the Hive box for incidents.
  static Box<Incident> _getBox() {
    return Hive.box<Incident>(_boxName);
  }

  /// Generate a unique incident ID with INC prefix.
  /// Format: INC + 9 timestamp-based digits (e.g., INC174652839).
  static String generateId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    // Take last 9 digits of timestamp for a clean numeric ID
    final digits = (now % 1000000000).toString().padLeft(9, '0');
    return 'INC$digits';
  }

  /// Add a new incident to the local Hive database.
  static Future<void> addIncident(Incident incident) async {
    final box = _getBox();
    await box.put(incident.id, incident);
  }

  /// Get all incidents from the local database.
  static List<Incident> getAllIncidents() {
    final box = _getBox();
    return box.values.toList();
  }

  /// Get a single incident by its ID.
  static Incident? getIncidentById(String id) {
    final box = _getBox();
    return box.get(id);
  }

  /// Update an existing incident in the database.
  static Future<void> updateIncident(Incident incident) async {
    final box = _getBox();
    await box.put(incident.id, incident);
  }

  /// Delete an incident from the database.
  static Future<void> deleteIncident(String id) async {
    final box = _getBox();
    await box.delete(id);
  }

  /// Check if the database is empty (first run).
  static bool isEmpty() {
    return _getBox().isEmpty;
  }

  /// Seed 4 sample dummy incidents for demo purposes.
  /// Called only on first run when the database is empty.
  static Future<void> seedSampleData() async {
    if (!isEmpty()) return; // Don't seed if data already exists

    final sampleIncidents = [
      // 1. Medical Emergency — Critical priority
      Incident(
        id: 'INC174650001',
        title: 'Medical Emergency - Cardiac Arrest',
        description:
            'An employee collapsed in the main cafeteria experiencing chest pain '
            'and difficulty breathing. First responders are on-site performing CPR. '
            'Emergency ambulance has been dispatched. Area has been cleared for '
            'medical team access.',
        category: IncidentCategory.medical,
        priority: IncidentPriority.critical,
        location: 'Main Cafeteria, Ground Floor, Block A',
        assignedResponder: 'Dr. Priya Sharma',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      // 2. Fire in Laboratory — High priority
      Incident(
        id: 'INC174650002',
        title: 'Fire in Chemistry Laboratory',
        description:
            'A chemical spill in the chemistry lab caused a small fire on the '
            'second workbench. The fire alarm was triggered and the building has '
            'been evacuated. Fire extinguishers have been deployed by lab staff. '
            'Fire department has been notified.',
        category: IncidentCategory.fire,
        priority: IncidentPriority.high,
        location: 'Science Building, Lab 201, 2nd Floor',
        assignedResponder: 'Fire Chief Rajesh Kumar',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      // 3. Security Threat — Medium priority
      Incident(
        id: 'INC174650003',
        title: 'Security Threat - Unauthorized Access',
        description:
            'Security cameras detected an unauthorized person attempting to enter '
            'the server room through the east wing after business hours. The '
            'individual was wearing a maintenance uniform but had no valid badge. '
            'Security team has been dispatched to investigate.',
        category: IncidentCategory.security,
        priority: IncidentPriority.medium,
        location: 'East Wing, Server Room Corridor, Floor 1',
        assignedResponder: 'Officer Amit Patel',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      // 4. Parking Accident — Low priority, already resolved
      Incident(
        id: 'INC174650004',
        title: 'Parking Lot Vehicle Accident',
        description:
            'A minor fender-bender occurred between two vehicles in the main '
            'parking lot Section C. No injuries reported. Both drivers have '
            'exchanged insurance information. Vehicles have been moved to clear '
            'the blocked parking spots.',
        category: IncidentCategory.accident,
        priority: IncidentPriority.low,
        location: 'Main Parking Lot, Section C, Spot 42',
        assignedResponder: 'Guard Suresh Yadav',
        status: IncidentStatus.resolved,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        resolvedAt: DateTime.now().subtract(const Duration(hours: 20)),
      ),
    ];

    // Add all sample incidents to the local Hive box
    for (final incident in sampleIncidents) {
      await addIncident(incident);
    }
  }
}
