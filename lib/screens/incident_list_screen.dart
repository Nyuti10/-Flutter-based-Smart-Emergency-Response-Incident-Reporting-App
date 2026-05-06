// incident_list_screen.dart
// Screen that displays all incidents in a scrollable list.
// Enhanced: Sorted Critical-first, incident count header, better empty state.
// Added: Dynamic filtering based on 'active', 'resolved', 'critical' parameters.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/incident_provider.dart';
import '../models/incident_model.dart';
import '../widgets/incident_card.dart';
import 'report_screen.dart';
import 'incident_detail_screen.dart';

/// Displays a sorted and filtered list of incidents.
/// Sorting: Critical → High → Medium → Low, then newest first.
/// Includes a FAB to add new incidents and a refresh button.
class IncidentListScreen extends StatelessWidget {
  /// Parameter to specify what category of incidents to show.
  /// Valid values: 'all', 'active', 'resolved', 'critical'.
  final String filter;

  const IncidentListScreen({super.key, this.filter = 'all'});

  /// Determines the dynamic AppBar title based on the filter.
  String get _appBarTitle {
    switch (filter) {
      case 'active':
        return 'Active Incidents';
      case 'resolved':
        return 'Resolved Incidents';
      case 'critical':
        return 'Critical Incidents';
      case 'all':
      default:
        return 'All Incidents';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- App Bar with gradient ---
      appBar: AppBar(
        title: Text(
          _appBarTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
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
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () {
              context.read<IncidentProvider>().loadIncidents();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.sync, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Incidents refreshed'),
                    ],
                  ),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          ),
        ],
      ),

      // --- FAB to add a new incident ---
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'list_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReportScreen()),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Report Incident',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // --- Body ---
      body: Consumer<IncidentProvider>(
        builder: (context, provider, child) {
          final allIncidents = provider.incidents;

          // Apply current filter logic
          List<Incident> displayedIncidents = allIncidents;
          if (filter == 'active') {
            displayedIncidents = allIncidents
                .where((i) => i.status == IncidentStatus.active)
                .toList();
          } else if (filter == 'resolved') {
            displayedIncidents = allIncidents
                .where((i) => i.status == IncidentStatus.resolved)
                .toList();
          } else if (filter == 'critical') {
            displayedIncidents = allIncidents
                .where((i) => i.priority == IncidentPriority.critical)
                .toList();
          }

          // Empty state
          if (displayedIncidents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_rounded, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No incidents found',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the button below to report one',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Incident count header
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: Colors.grey.shade50,
                child: Text(
                  '${displayedIncidents.length} incident(s) — sorted by priority',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
              // List of incident cards
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 6, bottom: 90),
                  itemCount: displayedIncidents.length,
                  itemBuilder: (context, index) {
                    final incident = displayedIncidents[index];
                    return IncidentCard(
                      incident: incident,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                IncidentDetailScreen(incidentId: incident.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
