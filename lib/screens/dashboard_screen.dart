// dashboard_screen.dart
// Admin Dashboard screen showing incident statistics and navigation.
// Enhanced: Professional card design, Incident IDs, category breakdown, quick actions.
// Added: Proper filtering logic passed to IncidentListScreen.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/incident_model.dart';
import '../providers/incident_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/priority_badge.dart';
import '../widgets/incident_card.dart';
import 'incident_list_screen.dart';
import 'report_screen.dart';
import 'search_filter_screen.dart';
import 'incident_detail_screen.dart';

/// Admin Dashboard screen that shows:
/// - Total, Active, Resolved, Critical incident counts
/// - Priority distribution with progress bars
/// - Category breakdown with icons
/// - Recent urgent incidents with Incident IDs
/// - Quick action buttons
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- Professional App Bar ---
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield, size: 24),
            SizedBox(width: 8),
            Text(
              'Emergency Dashboard',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
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
          // Search button
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search & Filter',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchFilterScreen()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),

      // --- FAB to report new incident ---
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'dashboard_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReportScreen()),
          );
        },
        icon: const Icon(Icons.add_alert_rounded),
        label: const Text('Report', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // --- Body ---
      body: Consumer<IncidentProvider>(
        builder: (context, provider, child) {
          final priorityDist = provider.priorityDistribution;
          final categoryDist = provider.categoryDistribution;

          // Get urgent incidents (Critical or High, still active)
          final urgentIncidents = provider.incidents
              .where((i) =>
                  i.status == IncidentStatus.active &&
                  (i.priority == IncidentPriority.critical ||
                      i.priority == IncidentPriority.high))
              .toList();

          return RefreshIndicator(
            onRefresh: () async {
              provider.loadIncidents();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Overview Stats Grid (2x2) ---
                  _buildSectionHeader(context, 'Overview'),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.25,
                    children: [
                      StatCard(
                        title: 'Total Incidents',
                        count: provider.totalIncidents,
                        icon: Icons.assignment_rounded,
                        color: const Color(0xFF1565C0),
                        onTap: () => _navigateToList(context, filter: 'all'),
                      ),
                      StatCard(
                        title: 'Active',
                        count: provider.activeIncidents,
                        icon: Icons.warning_amber_rounded,
                        color: const Color(0xFFF57C00),
                        onTap: () => _navigateToList(context, filter: 'active'),
                      ),
                      StatCard(
                        title: 'Resolved',
                        count: provider.resolvedIncidents,
                        icon: Icons.check_circle_outline_rounded,
                        color: const Color(0xFF388E3C),
                        onTap: () => _navigateToList(context, filter: 'resolved'),
                      ),
                      StatCard(
                        title: 'Critical',
                        count: provider.criticalIncidents,
                        icon: Icons.error_outline_rounded,
                        color: const Color(0xFFD32F2F),
                        onTap: () => _navigateToList(context, filter: 'critical'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // --- Priority Distribution ---
                  _buildSectionHeader(context, 'Priority Distribution'),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: IncidentPriority.values.reversed.map((priority) {
                          final count = priorityDist[priority] ?? 0;
                          final total = provider.totalIncidents;
                          final fraction = total > 0 ? count / total : 0.0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 70,
                                  child: Text(
                                    getPriorityText(priority),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: getPriorityColor(priority),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: fraction,
                                      minHeight: 16,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation(
                                        getPriorityColor(priority),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 24,
                                  child: Text(
                                    '$count',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // --- Category Breakdown ---
                  _buildSectionHeader(context, 'Category Breakdown'),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: IncidentCategory.values.map((cat) {
                          final count = categoryDist[cat] ?? 0;
                          final catColor = getCategoryColor(cat);
                          return Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: catColor.withAlpha(25),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: catColor.withAlpha(60),
                                    width: 1,
                                  ),
                                ),
                                child:
                                    Icon(getCategoryIcon(cat), size: 28, color: catColor),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                count.toString(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: catColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                getCategoryText(cat),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // --- Urgent Incidents (if any) ---
                  if (urgentIncidents.isNotEmpty) ...[
                    _buildSectionHeader(
                      context,
                      '⚠ Urgent Incidents (${urgentIncidents.length})',
                    ),
                    const SizedBox(height: 10),
                    ...urgentIncidents.take(5).map((incident) {
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
                    }),
                    const SizedBox(height: 16),
                  ],

                  // --- Quick Actions Bar ---
                  _buildSectionHeader(context, 'Quick Actions'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.list_alt_rounded,
                          label: 'View All',
                          color: const Color(0xFF1565C0),
                          onTap: () => _navigateToList(context, filter: 'all'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.search_rounded,
                          label: 'Search',
                          color: const Color(0xFF7B1FA2),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SearchFilterScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.add_circle_outline_rounded,
                          label: 'Report',
                          color: const Color(0xFF388E3C),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ReportScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Navigate to the Incident List screen with a filter.
  void _navigateToList(BuildContext context, {String filter = 'all'}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => IncidentListScreen(filter: filter)),
    );
  }

  /// Builds a section header with bold title text.
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
      ),
    );
  }
}

/// Reusable quick action button card for the dashboard.
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
