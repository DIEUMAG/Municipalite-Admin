// lib/screens/actualites_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

import '/core/api/actualite_service.dart';
import '/models/actualite_model.dart'; // ✅ AJOUT : import du vrai modèle DB

class ActualitesScreen extends StatefulWidget {
  const ActualitesScreen({super.key});

  @override
  State<ActualitesScreen> createState() => _ActualitesScreenState();
}

class _ActualitesScreenState extends State<ActualitesScreen> {
  final TextEditingController titreController = TextEditingController();
  final TextEditingController corpsController = TextEditingController();

  // ✅ MODIFIÉ : plus de liste locale, on fetch depuis la DB
  late Future<List<ActualiteModel>> actualitesFuture;

  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadActualites(); // ✅ AJOUT
  }

  // ✅ AJOUT
  void _loadActualites() {
    setState(() {
      actualitesFuture = ActualiteService().getActualites();
    });
  }

  Future<void> choisirMedia() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Ajouter des photos"),
                onTap: () async {
                  Navigator.pop(context);

                  final images = await picker.pickMultiImage();

                  if (images.isNotEmpty) {
                    setState(() {
                      selectedMedias.addAll(
                        images.map(
                          (e) => LocalMediaModel(
                            path: e.path,
                            isVideo: false,
                          ),
                        ),
                      );
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text("Ajouter une vidéo"),
                onTap: () async {
                  Navigator.pop(context);

                  final video = await picker.pickVideo(
                    source: ImageSource.gallery,
                  );

                  if (video != null) {
                    setState(() {
                      selectedMedias.add(
                        LocalMediaModel(
                          path: video.path,
                          isVideo: true,
                        ),
                      );
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  final List<LocalMediaModel> selectedMedias = []; // ✅ MODIFIÉ

  Future<void> publierActualite() async {
    if (titreController.text.trim().isEmpty ||
        corpsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez remplir tous les champs"),
        ),
      );
      return;
    }

    final fichiers = selectedMedias.map((m) => m.path).toList();

    final success = await ActualiteService().publierActualite(
      titre: titreController.text.trim(),
      corps: corpsController.text.trim(),
      fichiers: fichiers,
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur lors de la publication"),
        ),
      );
      return;
    }

    // ✅ MODIFIÉ : plus d'insertion locale, on recharge depuis la DB
    setState(() {
      titreController.clear();
      corpsController.clear();
      selectedMedias.clear();
    });

    _loadActualites(); // ✅ AJOUT

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Actualité publiée avec succès"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des Actualités"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FORMULAIRE — inchangé
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: titreController,
                      decoration: const InputDecoration(
                        labelText: "Titre",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: corpsController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: "Corps de l'actualité",
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: choisirMedia,
                        icon: const Icon(Icons.attach_file),
                        label: const Text("Ajouter des médias"),
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (selectedMedias.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: selectedMedias.length,
                          itemBuilder: (context, index) {
                            final media = selectedMedias[index];

                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey.shade200,
                                  ),
                                  child: media.isVideo
                                      ? const Icon(Icons.videocam, size: 50)
                                      : ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.file(
                                            File(media.path),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                ),

                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedMedias.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: publierActualite,
                        icon: const Icon(Icons.publish),
                        label: const Text("Publier l'actualité"),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Anciennes actualités",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            // ✅ MODIFIÉ : FutureBuilder au lieu de la liste locale
            FutureBuilder<List<ActualiteModel>>(
              future: actualitesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text("Erreur de chargement"));
                }

                final actualites = snapshot.data ?? [];

                if (actualites.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("Aucune actualité publiée"),
                    ),
                  );
                }

                return Column(
                  children: actualites.map((actualite) => Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            actualite.titre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(actualite.corps),

                          const SizedBox(height: 12),

                          if (actualite.medias.isNotEmpty)
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: actualite.medias.length,
                                itemBuilder: (context, index) {
                                  final media = actualite.medias[index];

                                  return Container(
                                    width: 120,
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.grey.shade200,
                                    ),
                                    child: media.isVideo
                                        ? const Icon(Icons.videocam, size: 50)
                                        : ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.network(
                                              media.fichier, // champ DB
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                  );
                                },
                              ),
                            ),

                          const SizedBox(height: 12),

                          // ✅ MODIFIÉ : utilise createdAt depuis la DB
                          Text(
                            DateFormat("dd/MM/yyyy à HH:mm").format(
                              DateTime.parse(actualite.createdAt),
                            ),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Modèle local uniquement pour la sélection avant upload
class LocalMediaModel {
  final String path;
  final bool isVideo;

  LocalMediaModel({required this.path, required this.isVideo});
}

// ✅ SUPPRIMÉ : ActualiteModel et MediaModel locaux
// → ils viennent maintenant de /models/actualite_model.dart