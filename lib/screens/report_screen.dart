// report_screen.dart
// Screen for reporting a new incident with form validation.
// Enhanced: Offline save snackbar, better validation, professional design.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/incident_model.dart';
import '../providers/incident_provider.dart';
import '../services/hive_service.dart';
import '../widgets/priority_badge.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  IncidentCategory _category = IncidentCategory.medical;
  IncidentPriority _priority = IncidentPriority.medium;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.error_outline, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Please fill in all required fields'),
          ]),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    final incidentId = HiveService.generateId();
    final incident = Incident(
      id: incidentId,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _category,
      priority: _priority,
      location: _locCtrl.text.trim(),
      createdAt: DateTime.now(),
    );
    await context.read<IncidentProvider>().addIncident(incident);
    setState(() => _isSubmitting = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.cloud_done_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Incident saved offline successfully',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text('ID: $incidentId', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ]),
          backgroundColor: const Color(0xFF388E3C),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    }
  }

  InputDecoration _inputDeco({String? hint, required IconData icon, bool alignTop = false}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      prefixIcon: alignTop
          ? Padding(padding: const EdgeInsets.only(bottom: 60), child: Icon(icon, color: const Color(0xFF1565C0)))
          : Icon(icon, color: const Color(0xFF1565C0)),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD32F2F))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _label(String text) => Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Incident', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1565C0)]),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.add_alert_rounded, size: 56, color: Color(0xFFD32F2F)),
              const SizedBox(height: 10),
              const Text('Report an Emergency', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('Fill in all details below. A unique Incident ID will be generated automatically.',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              const SizedBox(height: 28),
              // Title
              _label('Incident Title'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleCtrl,
                textInputAction: TextInputAction.next,
                decoration: _inputDeco(hint: 'e.g., Fire in Building A', icon: Icons.title_rounded),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please enter an incident title';
                  if (v.trim().length < 3) return 'Title must be at least 3 characters';
                  return null;
                },
              ),
              const SizedBox(height: 18),
              // Description
              _label('Description'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descCtrl, maxLines: 4, textInputAction: TextInputAction.next,
                decoration: _inputDeco(hint: 'Provide detailed information...', icon: Icons.description_rounded, alignTop: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please provide a description';
                  if (v.trim().length < 10) return 'Description must be at least 10 characters';
                  return null;
                },
              ),
              const SizedBox(height: 18),
              // Category
              _label('Category'),
              const SizedBox(height: 6),
              DropdownButtonFormField<IncidentCategory>(
                value: _category,
                decoration: _inputDeco(icon: Icons.category_rounded),
                items: IncidentCategory.values.map((c) => DropdownMenuItem(
                  value: c,
                  child: Row(children: [
                    Icon(getCategoryIcon(c), size: 20, color: getCategoryColor(c)),
                    const SizedBox(width: 10),
                    Text(getCategoryText(c)),
                  ]),
                )).toList(),
                onChanged: (v) { if (v != null) setState(() => _category = v); },
              ),
              const SizedBox(height: 18),
              // Priority
              _label('Priority Level'),
              const SizedBox(height: 6),
              DropdownButtonFormField<IncidentPriority>(
                value: _priority,
                decoration: _inputDeco(icon: Icons.priority_high_rounded),
                items: IncidentPriority.values.reversed.map((p) => DropdownMenuItem(
                  value: p,
                  child: Row(children: [
                    Container(width: 14, height: 14, decoration: BoxDecoration(color: getPriorityColor(p), shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Text(getPriorityText(p)),
                  ]),
                )).toList(),
                onChanged: (v) { if (v != null) setState(() => _priority = v); },
              ),
              const SizedBox(height: 18),
              // Location
              _label('Location'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _locCtrl,
                textInputAction: TextInputAction.done,
                decoration: _inputDeco(hint: 'e.g., Building A, Floor 3, Room 302', icon: Icons.location_on_rounded),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please enter the incident location';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              // Submit
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitForm,
                  icon: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded),
                  label: Text(_isSubmitting ? 'Submitting...' : 'Submit Report',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
