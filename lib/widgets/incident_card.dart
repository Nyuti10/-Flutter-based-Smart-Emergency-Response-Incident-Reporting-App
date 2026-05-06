// incident_card.dart
// Reusable card widget for displaying incident summaries in lists.
// Enhanced: Better spacing, Incident ID display, colored borders for critical.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/incident_model.dart';
import 'priority_badge.dart';

/// A Material Design card that shows a summary of an incident.
/// Displays: Title, Incident ID, Priority badge, Status, Time, Location.
/// Critical incidents get a red border highlight.
class IncidentCard extends StatelessWidget {
  final Incident incident;
  final VoidCallback onTap;

  const IncidentCard({
    super.key,
    required this.incident,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCritical = incident.priority == IncidentPriority.critical;
    final bool isHigh = incident.priority == IncidentPriority.high;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: isCritical ? 4 : 2,
      shadowColor: isCritical ? Colors.red.withAlpha(80) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isCritical
            ? const BorderSide(color: Color(0xFFD32F2F), width: 2)
            : isHigh
                ? BorderSide(color: Colors.orange.shade300, width: 1.5)
                : BorderSide(color: Colors.grey.shade200, width: 0.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Top Row: Category icon + Title + Priority badge ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category icon with colored background
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: getCategoryColor(incident.category).withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      getCategoryIcon(incident.category),
                      color: getCategoryColor(incident.category),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title and Incident ID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          incident.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Incident ID in monospace
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            incident.id,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 11,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  PriorityBadge(priority: incident.priority),
                ],
              ),
              const SizedBox(height: 12),

              // --- Description preview ---
              Text(
                incident.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),

              // --- Divider ---
              Divider(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 10),

              // --- Bottom Row: Location, Status, Date ---
              Row(
                children: [
                  // Location
                  Icon(Icons.location_on_outlined,
                      size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      incident.location,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status chip
                  StatusChip(status: incident.status),
                  const SizedBox(width: 8),
                  // Date/time
                  Icon(Icons.access_time, size: 12, color: Colors.grey[400]),
                  const SizedBox(width: 3),
                  Text(
                    DateFormat('MMM d, HH:mm').format(incident.createdAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
