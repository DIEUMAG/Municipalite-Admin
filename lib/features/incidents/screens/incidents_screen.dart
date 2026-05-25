// lib/screens/incidents_screen.dart
import 'package:flutter/material.dart';

class IncidentsScreen extends StatelessWidget {
  const IncidentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Signalements d'Incidents"),
      ),
      body: ListView(
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.warning, color: Colors.red),
              title: Text("Incident #001"),
              subtitle: Text("Panne réseau"),
            ),
          ),
        ],
      ),
    );
  }
}