import 'package:flutter/material.dart';
import '../Actes/archive_acte.dart';

class ArchivageScreen extends StatelessWidget {
  const ArchivageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> archives = [
      {
        "title": "Archives des actes",
        "icon": Icons.folder_copy,
        "color": Colors.blue,
      },
      {
        "title": "Archives électorales",
        "icon": Icons.how_to_vote,
        "color": Colors.green,
      },
      {
        "title": "Archives administratives",
        "icon": Icons.apartment,
        "color": Colors.orange,
      },
      {
        "title": "Documents PDF",
        "icon": Icons.picture_as_pdf,
        "color": Colors.red,
      },
      {
        "title": "Signatures électroniques",
        "icon": Icons.draw,
        "color": Colors.purple,
      },
      {
        "title": "Sauvegardes",
        "icon": Icons.backup,
        "color": Colors.teal,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Archivage"),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: archives.length,
        itemBuilder: (context, index) {
          final archive = archives[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: archive["color"].withOpacity(0.15),
                  child: Icon(
                    archive["icon"],
                    color: archive["color"],
                  ),
                ),
                title: Text(
                  archive["title"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                subtitle: const Text(
                  "Consulter et gérer les archives",
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                ),

                // NAVIGATION
                onTap: () {
                  if (archive["title"] == "Archives des actes") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ArchiveActesPage(),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}


// PAGE ARCHIVES DES ACTES


