// main.dart
// Entry point for the Smart Emergency Response App.
// Initializes Hive, seeds sample data, sets up Provider, and launches the app.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/hive_service.dart';
import 'providers/incident_provider.dart';
import 'screens/dashboard_screen.dart';
import 'models/incident_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for offline storage
  await Hive.initFlutter();

  // Register type adapters
  Hive.registerAdapter(IncidentCategoryAdapter());
  Hive.registerAdapter(IncidentPriorityAdapter());
  Hive.registerAdapter(IncidentStatusAdapter());
  Hive.registerAdapter(IncidentAdapter());

  // Clear old data so new sample format (INC prefix, responder) takes effect
  final box = await Hive.openBox<Incident>('incidents');
  if (box.isNotEmpty) {
    final firstId = box.values.first.id;
    // If data was seeded with old format (no INC prefix), clear and reseed
    if (!firstId.startsWith('INC')) {
      await box.clear();
    }
  }

  // Seed 4 sample incidents on first run
  await HiveService.seedSampleData();

  runApp(const SmartEmergencyApp());
}

/// Root widget of the Smart Emergency Response App.
class SmartEmergencyApp extends StatelessWidget {
  const SmartEmergencyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = IncidentProvider();
            provider.loadIncidents();
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Smart Emergency Response',
        debugShowCheckedModeBanner: false,

        // Professional Material 3 theme
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF0D47A1),
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFF5F7FA),
          appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            surfaceTintColor: Colors.transparent,
            color: Colors.white,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(elevation: 4),
          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}
