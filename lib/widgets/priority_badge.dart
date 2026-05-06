// priority_badge.dart
// Reusable widget that displays a color-coded priority badge.
// Also contains helper functions for enums used across the app.

import 'package:flutter/material.dart';
import '../models/incident_model.dart';

// ============================================================
// Color and Text Helpers for Enums
// ============================================================

/// Returns the color for each priority level.
/// Critical → Red | High → Orange | Medium → Amber | Low → Green
Color getPriorityColor(IncidentPriority priority) {
  switch (priority) {
    case IncidentPriority.critical:
      return const Color(0xFFD32F2F); // Deep Red
    case IncidentPriority.high:
      return const Color(0xFFF57C00); // Deep Orange
    case IncidentPriority.medium:
      return const Color(0xFFFFA000); // Amber
    case IncidentPriority.low:
      return const Color(0xFF388E3C); // Green
  }
}

/// Returns a human-readable string for the priority.
String getPriorityText(IncidentPriority priority) {
  switch (priority) {
    case IncidentPriority.critical:
      return 'Critical';
    case IncidentPriority.high:
      return 'High';
    case IncidentPriority.medium:
      return 'Medium';
    case IncidentPriority.low:
      return 'Low';
  }
}

/// Returns a human-readable string for the category.
String getCategoryText(IncidentCategory category) {
  switch (category) {
    case IncidentCategory.medical:
      return 'Medical';
    case IncidentCategory.fire:
      return 'Fire';
    case IncidentCategory.security:
      return 'Security';
    case IncidentCategory.accident:
      return 'Accident';
  }
}

/// Returns a human-readable string for the status.
String getStatusText(IncidentStatus status) {
  switch (status) {
    case IncidentStatus.active:
      return 'Active';
    case IncidentStatus.resolved:
      return 'Resolved';
  }
}

/// Returns the Material icon for each category.
IconData getCategoryIcon(IncidentCategory category) {
  switch (category) {
    case IncidentCategory.medical:
      return Icons.local_hospital;
    case IncidentCategory.fire:
      return Icons.local_fire_department;
    case IncidentCategory.security:
      return Icons.security;
    case IncidentCategory.accident:
      return Icons.car_crash;
  }
}

/// Returns a color for each category.
Color getCategoryColor(IncidentCategory category) {
  switch (category) {
    case IncidentCategory.medical:
      return const Color(0xFF1565C0); // Blue
    case IncidentCategory.fire:
      return const Color(0xFFD32F2F); // Red
    case IncidentCategory.security:
      return const Color(0xFF7B1FA2); // Purple
    case IncidentCategory.accident:
      return const Color(0xFFE65100); // Deep Orange
  }
}

// ============================================================
// Priority Badge Widget
// ============================================================

/// A color-coded badge widget showing the priority level.
/// Used in incident cards, list items, and detail screens.
class PriorityBadge extends StatelessWidget {
  final IncidentPriority priority;
  final bool large; // Use larger size for detail screens

  const PriorityBadge({
    super.key,
    required this.priority,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = getPriorityColor(priority);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 14 : 10,
        vertical: large ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Small colored dot indicator
          Container(
            width: large ? 8 : 6,
            height: large ? 8 : 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: large ? 6 : 4),
          Text(
            getPriorityText(priority),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: large ? 14 : 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Status Chip Widget
// ============================================================

/// A chip widget showing the incident status (Active / Resolved).
class StatusChip extends StatelessWidget {
  final IncidentStatus status;
  final bool large;

  const StatusChip({
    super.key,
    required this.status,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = status == IncidentStatus.active;
    final color = isActive ? const Color(0xFF1565C0) : const Color(0xFF388E3C);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 14 : 10,
        vertical: large ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(100), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.warning_amber_rounded : Icons.check_circle,
            size: large ? 16 : 14,
            color: color,
          ),
          SizedBox(width: large ? 6 : 4),
          Text(
            getStatusText(status),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: large ? 13 : 11,
            ),
          ),
        ],
      ),
    );
  }
}
