// lib/main.dart
import 'package:flutter/material.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/annuaires/screens/annuaires_screen.dart';
import 'features/announcements/screens/actualites_screen.dart';
import 'features/incidents/screens/incidents_screen.dart';
import 'features/notifications/screens/notifications_screen.dart';
import 'features/actes/screens/actes_screen.dart';
import 'features/elections/screens/elections_screen.dart';
import 'features/concessions/screens/concessions_screen.dart';
import 'features/etat_civil/screens/etat_civil_screen.dart';
import 'features/archivage/screens/archivage_screen.dart';

void main() {
  runApp(const AdminDashboardApp());
}

class AdminDashboardApp extends StatelessWidget {
  const AdminDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dashboard Administration',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/annuaires': (context) => const AnnuairesScreen(),
        '/actualites': (context) => const ActualitesScreen(),
        '/incidents': (context) => const IncidentsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/actes': (context) => const ArchiveActesPage(),
        '/elections': (context) => const ElectionsScreen(),
        '/concessions': (context) => const ConcessionsScreen(),
        '/etat-civil': (context) =>const EtatCivilScreen(),
        '/archivage': (context) =>const ArchivageScreen(),
      },
    );
  }
}