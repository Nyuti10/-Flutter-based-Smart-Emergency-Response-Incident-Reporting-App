// search_filter_screen.dart
// Search by title/ID and filter by priority/status/category.
// Enhanced: Clear filter button, result count, better filter chips.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/incident_model.dart';
import '../providers/incident_provider.dart';
import '../widgets/incident_card.dart';
import '../widgets/priority_badge.dart';
import 'incident_detail_screen.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncidentProvider>().clearFilters();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search & Filter', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1565C0)]),
          ),
        ),
        foregroundColor: Colors.white,
        actions: [
          Consumer<IncidentProvider>(
            builder: (context, provider, _) {
              if (!provider.hasActiveFilters) return const SizedBox.shrink();
              return TextButton.icon(
                onPressed: () {
                  _searchCtrl.clear();
                  provider.clearFilters();
                },
                icon: const Icon(Icons.clear_all_rounded, color: Colors.white),
                label: const Text('Clear', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Search & Filter Panel ---
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.withAlpha(30), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search by Incident ID or Title...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF1565C0)),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchCtrl.clear();
                              context.read<IncidentProvider>().setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2)),
                  ),
                  onChanged: (v) {
                    context.read<IncidentProvider>().setSearchQuery(v);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 14),
                const Text('Filters', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 8),
                // Filter dropdowns
                Consumer<IncidentProvider>(
                  builder: (context, provider, _) {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _filterDropdown<IncidentPriority>(
                          label: 'Priority', value: provider.filterPriority,
                          items: IncidentPriority.values.reversed.toList(),
                          itemLabel: (p) => getPriorityText(p),
                          onChanged: (v) => provider.setFilterPriority(v),
                          itemColor: (p) => getPriorityColor(p),
                        ),
                        _filterDropdown<IncidentStatus>(
                          label: 'Status', value: provider.filterStatus,
                          items: IncidentStatus.values,
                          itemLabel: (s) => getStatusText(s),
                          onChanged: (v) => provider.setFilterStatus(v),
                        ),
                        _filterDropdown<IncidentCategory>(
                          label: 'Category', value: provider.filterCategory,
                          items: IncidentCategory.values,
                          itemLabel: (c) => getCategoryText(c),
                          onChanged: (v) => provider.setFilterCategory(v),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          // --- Results ---
          Expanded(
            child: Consumer<IncidentProvider>(
              builder: (context, provider, _) {
                final results = provider.filteredIncidents;
                if (results.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('No incidents found', style: TextStyle(fontSize: 18, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text('Try adjusting your search or filters', style: TextStyle(color: Colors.grey[400])),
                      ],
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                      child: Text('${results.length} result(s) found',
                          style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500, fontSize: 13)),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 4, bottom: 16),
                        itemCount: results.length,
                        itemBuilder: (context, i) {
                          final inc = results[i];
                          return IncidentCard(
                            incident: inc,
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => IncidentDetailScreen(incidentId: inc.id))),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterDropdown<T>({
    required String label, required T? value, required List<T> items,
    required String Function(T) itemLabel, required ValueChanged<T?> onChanged,
    Color Function(T)? itemColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: value != null ? const Color(0xFF1565C0) : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        color: value != null ? const Color(0xFF1565C0).withAlpha(15) : null,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(label, style: const TextStyle(fontSize: 13)),
          isDense: true,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          items: [
            DropdownMenuItem<T>(value: null, child: Text('All $label', style: const TextStyle(fontSize: 13))),
            ...items.map((item) => DropdownMenuItem<T>(
              value: item,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (itemColor != null)
                  Container(width: 10, height: 10, margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(color: itemColor(item), shape: BoxShape.circle)),
                Text(itemLabel(item), style: const TextStyle(fontSize: 13)),
              ]),
            )),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
