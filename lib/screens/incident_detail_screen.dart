// incident_detail_screen.dart
// Screen showing full details of a single incident.
// Enhanced: Assigned responder section, Incident ID display, better card layout.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/incident_model.dart';
import '../providers/incident_provider.dart';
import '../widgets/priority_badge.dart';

/// Displays the full information of a single incident including:
/// - Priority badge and Status chip
/// - Incident ID, Title, Description
/// - Category, Location, Time, Responder
/// - Resolve/Delete actions
class IncidentDetailScreen extends StatelessWidget {
  final String incidentId;

  const IncidentDetailScreen({super.key, required this.incidentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- Gradient App Bar ---
      appBar: AppBar(
        title: const Text(
          'Incident Details',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),

      body: Consumer<IncidentProvider>(
        builder: (context, provider, child) {
          // Find the incident from the provider's list
          final Incident incident;
          try {
            incident = provider.incidents.firstWhere((i) => i.id == incidentId);
          } catch (_) {
            return const Center(child: Text('Incident not found'));
          }

          final priorityColor = getPriorityColor(incident.priority);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ============================
                // Header Card — Priority, Status, Title, ID
                // ============================
                Card(
                  elevation: 3,
                  shadowColor: priorityColor.withAlpha(60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: priorityColor, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Priority badge + Status chip row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            PriorityBadge(priority: incident.priority, large: true),
                            StatusChip(status: incident.status, large: true),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // Title
                        Text(
                          incident.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Incident ID (monospace)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.tag, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                'Incident ID: ${incident.id}',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 13,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ============================
                // Description Section
                // ============================
                _buildSectionTitle('📝 Description'),
                const SizedBox(height: 8),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text(
                      incident.description,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ============================
                // Information Section
                // ============================
                _buildSectionTitle('ℹ️ Information'),
                const SizedBox(height: 8),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          Icons.category_rounded,
                          'Category',
                          getCategoryText(incident.category),
                          getCategoryColor(incident.category),
                        ),
                        _buildDivider(),
                        _buildInfoRow(
                          Icons.location_on_rounded,
                          'Location',
                          incident.location,
                          const Color(0xFF1565C0),
                        ),
                        _buildDivider(),
                        _buildInfoRow(
                          Icons.calendar_today_rounded,
                          'Reported',
                          DateFormat('MMM d, yyyy — HH:mm')
                              .format(incident.createdAt),
                          const Color(0xFF455A64),
                        ),
                        if (incident.resolvedAt != null) ...[
                          _buildDivider(),
                          _buildInfoRow(
                            Icons.check_circle_outline_rounded,
                            'Resolved',
                            DateFormat('MMM d, yyyy — HH:mm')
                                .format(incident.resolvedAt!),
                            const Color(0xFF388E3C),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ============================
                // Assigned Responder Section
                // ============================
                _buildSectionTitle('👤 Assigned Responder'),
                const SizedBox(height: 8),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        // Avatar circle
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              const Color(0xFF1565C0).withAlpha(25),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Color(0xFF1565C0),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                incident.assignedResponder,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                incident.assignedResponder == 'Unassigned'
                                    ? 'No responder assigned yet'
                                    : 'Emergency Responder',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Status indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                incident.assignedResponder == 'Unassigned'
                                    ? Colors.orange.withAlpha(25)
                                    : Colors.green.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            incident.assignedResponder == 'Unassigned'
                                ? 'Pending'
                                : 'Assigned',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color:
                                  incident.assignedResponder == 'Unassigned'
                                      ? Colors.orange
                                      : Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ============================
                // Action Buttons
                // ============================

                // Resolve button (only for active incidents)
                if (incident.status == IncidentStatus.active)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _showResolveDialog(context, provider, incident),
                      icon: const Icon(Icons.check_circle_rounded),
                      label: const Text('Mark as Resolved',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF388E3C),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                // Delete button
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showDeleteDialog(context, provider, incident),
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Color(0xFFD32F2F)),
                    label: const Text('Delete Incident',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFD32F2F),
                          fontWeight: FontWeight.w600,
                        )),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD32F2F)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 22, thickness: 0.5);
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Dialog Handlers ---

  void _showResolveDialog(
    BuildContext context,
    IncidentProvider provider,
    Incident incident,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF388E3C)),
            SizedBox(width: 8),
            Text('Resolve Incident'),
          ],
        ),
        content: Text(
          'Are you sure you want to mark "${incident.title}" as resolved?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.resolveIncident(incident.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Incident marked as resolved ✓'),
                    ],
                  ),
                  backgroundColor: const Color(0xFF388E3C),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF388E3C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    IncidentProvider provider,
    Incident incident,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: Color(0xFFD32F2F)),
            SizedBox(width: 8),
            Text('Delete Incident'),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete "${incident.title}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteIncident(incident.id);
              Navigator.pop(ctx);   // Close dialog
              Navigator.pop(context); // Go back to list
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.delete, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Incident deleted successfully'),
                    ],
                  ),
                  backgroundColor: const Color(0xFFD32F2F),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
