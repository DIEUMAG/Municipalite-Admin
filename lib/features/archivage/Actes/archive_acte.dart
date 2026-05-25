import 'package:flutter/material.dart';

class ArchiveActesPage extends StatefulWidget {
  const ArchiveActesPage({super.key});

  @override
  State<ArchiveActesPage> createState() =>
      _ArchiveActesPageState();
}

class _ArchiveActesPageState
    extends State<ArchiveActesPage> {
  String? selectedActe;

  final List<String> actes = [
    "Acte de naissance",
    "Acte de mariage",
    "Acte de décès",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Archives des actes",
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const Text(
              "Sélectionner le type d'acte",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: selectedActe,

              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                prefixIcon:
                    const Icon(Icons.description),
              ),

              hint: const Text(
                "Choisir un acte",
              ),

              items: actes.map((acte) {
                return DropdownMenuItem(
                  value: acte,
                  child: Text(acte),
                );
              }).toList(),

              onChanged: (value) {
                setState(() {
                  selectedActe = value;
                });
              },
            ),

            const SizedBox(height: 30),

            const Text(
              "Télécharger une image",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),

              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade400,
                ),
                borderRadius:
                    BorderRadius.circular(16),
              ),

              child: Column(
                children: [
                  const Icon(
                    Icons.cloud_upload,
                    size: 70,
                    color: Colors.blue,
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Importer une image",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: () {
                      // Ajouter ici ImagePicker
                    },

                    icon: const Icon(
                      Icons.upload,
                    ),

                    label: const Text(
                      "Choisir une image",
                    ),

                    style: ElevatedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {},

                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),

                child: const Text(
                  "Enregistrer",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}