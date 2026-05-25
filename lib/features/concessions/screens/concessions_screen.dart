// lib/screens/concessions_screen.dart
import 'package:flutter/material.dart';

class ConcessionsScreen extends StatelessWidget {
  const ConcessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Concessions Funéraires"),
      ),
      body: ListView(
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.account_balance),
              title: Text("Concession #101"),
              subtitle: Text("Disponible"),
            ),
          ),
        ],
      ),
    );
  }
}