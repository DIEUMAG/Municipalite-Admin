// lib/screens/elections_screen.dart
import 'package:flutter/material.dart';

class ElectionsScreen extends StatelessWidget {
  const ElectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Listes Électorales"),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.how_to_vote),
            title: Text("Électeur #001"),
            subtitle: Text("Centre A"),
          ),
        ],
      ),
    );
  }
}