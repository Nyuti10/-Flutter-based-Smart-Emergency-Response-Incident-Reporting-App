// incident_provider.dart
// State management using Provider pattern for incident data.
// Enhanced: Sorting order (Critical first, then by date), improved stats.

import 'package:flutter/foundation.dart';
import '../models/incident_model.dart';
import '../services/hive_service.dart';

/// IncidentProvider manages the state of all incidents in the app.
/// Uses ChangeNotifier to notify widgets when data changes.
class IncidentProvider extends ChangeNotifier {
  // --- Private State ---
  List<Incident> _incidents = [];       // All incidents list
  String _searchQuery = '';             // Current search query
  IncidentPriority? _filterPriority;    // Priority filter (null = no filter)
  IncidentStatus? _filterStatus;        // Status filter (null = no filter)
  IncidentCategory? _filterCategory;    // Category filter (null = no filter)

  // --- Getters ---

  /// All incidents sorted by priority (Critical first) then by date (newest first).
  List<Incident> get incidents => _incidents;

  /// Current search query text.
  String get searchQuery => _searchQuery;

  /// Current filter values.
  IncidentPriority? get filterPriority => _filterPriority;
  IncidentStatus? get filterStatus => _filterStatus;
  IncidentCategory? get filterCategory => _filterCategory;

  /// Filtered and searched incidents based on current query/filters.
  /// Maintains the priority-first sorting order.
  List<Incident> get filteredIncidents {
    List<Incident> result = List.from(_incidents);

    // Apply search filter (by title or Incident ID)
    if (_searchQuery.isNotEmpty) {
      result = result.where((incident) {
        final query = _searchQuery.toLowerCase();
        return incident.title.toLowerCase().contains(query) ||
            incident.id.toLowerCase().contains(query);
      }).toList();
    }

    // Apply priority filter
    if (_filterPriority != null) {
      result = result.where((i) => i.priority == _filterPriority).toList();
    }

    // Apply status filter
    if (_filterStatus != null) {
      result = result.where((i) => i.status == _filterStatus).toList();
    }

    // Apply category filter
    if (_filterCategory != null) {
      result = result.where((i) => i.category == _filterCategory).toList();
    }

    return result;
  }

  /// Whether any filter or search is currently active.
  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _filterPriority != null ||
      _filterStatus != null ||
      _filterCategory != null;

  // --- Dashboard Statistics ---

  /// Total number of incidents.
  int get totalIncidents => _incidents.length;

  /// Number of active (unresolved) incidents.
  int get activeIncidents =>
      _incidents.where((i) => i.status == IncidentStatus.active).length;

  /// Number of resolved incidents.
  int get resolvedIncidents =>
      _incidents.where((i) => i.status == IncidentStatus.resolved).length;

  /// Number of critical-priority incidents.
  int get criticalIncidents =>
      _incidents.where((i) => i.priority == IncidentPriority.critical).length;

  /// Count of incidents for each priority level.
  Map<IncidentPriority, int> get priorityDistribution {
    final map = <IncidentPriority, int>{};
    for (var priority in IncidentPriority.values) {
      map[priority] = _incidents.where((i) => i.priority == priority).length;
    }
    return map;
  }

  /// Count of incidents for each category.
  Map<IncidentCategory, int> get categoryDistribution {
    final map = <IncidentCategory, int>{};
    for (var category in IncidentCategory.values) {
      map[category] = _incidents.where((i) => i.category == category).length;
    }
    return map;
  }

  // --- Data Operations ---

  /// Load all incidents from Hive and sort them:
  /// 1. Priority order: Critical → High → Medium → Low
  /// 2. Within same priority: newest first (by createdAt)
  void loadIncidents() {
    _incidents = HiveService.getAllIncidents();
    _sortIncidents();
    notifyListeners();
  }

  /// Sort incidents by priority (Critical first) then by date (newest first).
  void _sortIncidents() {
    _incidents.sort((a, b) {
      // Priority order: Critical(3) > High(2) > Medium(1) > Low(0)
      final priorityCompare = b.priority.index.compareTo(a.priority.index);
      if (priorityCompare != 0) return priorityCompare;
      // Within same priority, newest first
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  /// Add a new incident and refresh the list.
  Future<void> addIncident(Incident incident) async {
    await HiveService.addIncident(incident);
    loadIncidents(); // Reload from Hive and notify listeners
  }

  /// Update an existing incident and refresh the list.
  Future<void> updateIncident(Incident incident) async {
    await HiveService.updateIncident(incident);
    loadIncidents();
  }

  /// Delete an incident by ID and refresh the list.
  Future<void> deleteIncident(String id) async {
    await HiveService.deleteIncident(id);
    loadIncidents();
  }

  /// Mark an incident as resolved and refresh the list.
  Future<void> resolveIncident(String id) async {
    final incident = HiveService.getIncidentById(id);
    if (incident != null) {
      incident.markResolved();
      await HiveService.updateIncident(incident);
      loadIncidents();
    }
  }

  // --- Search & Filter Operations ---

  /// Set the search query and notify listeners.
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Set the priority filter and notify listeners.
  void setFilterPriority(IncidentPriority? priority) {
    _filterPriority = priority;
    notifyListeners();
  }

  /// Set the status filter and notify listeners.
  void setFilterStatus(IncidentStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  /// Set the category filter and notify listeners.
  void setFilterCategory(IncidentCategory? category) {
    _filterCategory = category;
    notifyListeners();
  }

  /// Clear all filters and search query.
  void clearFilters() {
    _searchQuery = '';
    _filterPriority = null;
    _filterStatus = null;
    _filterCategory = null;
    notifyListeners();
  }
}
