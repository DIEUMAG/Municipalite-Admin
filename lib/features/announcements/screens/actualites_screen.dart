// lib/screens/actualites_screen.dart

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '/core/api/actualite_service.dart';
import '/models/actualite_model.dart';

class ActualitesScreen extends StatefulWidget {
  const ActualitesScreen({super.key});

  @override
  State<ActualitesScreen> createState() => _ActualitesScreenState();
}

class _ActualitesScreenState extends State<ActualitesScreen> {

  final TextEditingController titreController = TextEditingController();
  final TextEditingController corpsController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker picker = ImagePicker();

  late Future<List<ActualiteModel>> actualitesFuture;

  // ✅ MediaUpload au lieu de LocalMediaModel → compatible Web + Mobile
  final List<MediaUpload> selectedMedias = [];

  ActualiteModel? _editingActualite;

  @override
  void initState() {
    super.initState();
    _loadActualites();
  }

  @override
  void dispose() {
    titreController.dispose();
    corpsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadActualites() {
    setState(() {
      actualitesFuture = ActualiteService().getActualites();
    });
  }

  // ── Médias ─────────────────────────────────────────────────────────────────
  Future<void> choisirMedia() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Ajouter des photos"),
              onTap: () async {
                Navigator.pop(context);
                final images = await picker.pickMultiImage();
                if (images.isNotEmpty) {
                  // ✅ readAsBytes() → compatible Web + Mobile
                  final uploads = await Future.wait(
                    images.map(
                      (e) => MediaUpload.fromXFile(e, isVideo: false),
                    ),
                  );
                  setState(() => selectedMedias.addAll(uploads));
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
                  final upload = await MediaUpload.fromXFile(
                    video,
                    isVideo: true,
                  );
                  setState(() => selectedMedias.add(upload));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Reset formulaire ───────────────────────────────────────────────────────
  void _resetForm() {
    setState(() {
      titreController.clear();
      corpsController.clear();
      selectedMedias.clear();
      _editingActualite = null;
    });
  }

  // ── Pré-remplir pour édition ───────────────────────────────────────────────
  void _startEditing(ActualiteModel actualite) {
    setState(() {
      _editingActualite = actualite;
      titreController.text = actualite.titre;
      corpsController.text = actualite.corps;
      selectedMedias.clear();
    });
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  // ── Soumettre (création ou modification) ───────────────────────────────────
  Future<void> _soumettre() async {
    if (titreController.text.trim().isEmpty ||
        corpsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    bool success;

    if (_editingActualite != null) {
      success = await ActualiteService().modifierActualite(
        id: _editingActualite!.id,
        titre: titreController.text.trim(),
        corps: corpsController.text.trim(),
        fichiers: selectedMedias,
      );
    } else {
      success = await ActualiteService().publierActualite(
        titre: titreController.text.trim(),
        corps: corpsController.text.trim(),
        fichiers: selectedMedias,
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? _editingActualite != null
                  ? "Actualité modifiée avec succès"
                  : "Actualité publiée avec succès"
              : "Erreur lors de l'opération",
        ),
      ),
    );

    if (success) {
      _resetForm();
      _loadActualites();
    }
  }

  // ── Suppression ────────────────────────────────────────────────────────────
  Future<void> _supprimerActualite(ActualiteModel actualite) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Supprimer l'actualité"),
        content: Text(
          'Voulez-vous vraiment supprimer "${actualite.titre}" ?\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirme != true) return;

    final success = await ActualiteService().supprimerActualite(
      id: actualite.id,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? "Actualité supprimée avec succès"
              : "Erreur lors de la suppression",
        ),
      ),
    );

    if (success) {
      if (_editingActualite?.id == actualite.id) _resetForm();
      _loadActualites();
    }
  }

  // ── UI ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bool isEditing = _editingActualite != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des Actualités"),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── FORMULAIRE ──────────────────────────────────────────────────
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: [
                        Icon(
                          isEditing
                              ? Icons.edit_note
                              : Icons.add_box_outlined,
                          color: isEditing
                              ? Colors.orange
                              : Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isEditing
                              ? "Modifier l'actualité"
                              : "Nouvelle actualité",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (isEditing)
                          TextButton.icon(
                            onPressed: _resetForm,
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text("Annuler"),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

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

                    // ✅ Aperçu via Image.memory (bytes) → compatible Web
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
                                      ? const Icon(
                                          Icons.videocam,
                                          size: 50,
                                        )
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.memory(
                                            Uint8List.fromList(media.bytes),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => setState(
                                      () => selectedMedias.removeAt(index),
                                    ),
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
                        onPressed: _soumettre,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isEditing ? Colors.orange : null,
                        ),
                        icon: Icon(isEditing ? Icons.save : Icons.publish),
                        label: Text(
                          isEditing
                              ? "Enregistrer les modifications"
                              : "Publier l'actualité",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Center(
              child: Text(
                "Anciennes actualités",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ── LISTE ───────────────────────────────────────────────────────
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
                  children: actualites.map((actualite) {
                    final isCurrentlyEditing =
                        _editingActualite?.id == actualite.id;

                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: isCurrentlyEditing
                                ? const BorderSide(
                                    color: Colors.orange,
                                    width: 2,
                                  )
                                : BorderSide.none,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        actualite.titre,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: "Modifier",
                                      icon: Icon(
                                        Icons.edit,
                                        color: isCurrentlyEditing
                                            ? Colors.orange
                                            : Colors.blueGrey,
                                      ),
                                      onPressed: () =>
                                          _startEditing(actualite),
                                    ),
                                    IconButton(
                                      tooltip: "Supprimer",
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          _supprimerActualite(actualite),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 6),

                                Text(actualite.corps),

                                const SizedBox(height: 12),

                                if (actualite.medias.isNotEmpty)
                                  SizedBox(
                                    height: 120,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: actualite.medias.length,
                                      itemBuilder: (context, index) {
                                        final media =
                                            actualite.medias[index];
                                        return Container(
                                          width: 120,
                                          margin: const EdgeInsets.only(
                                            right: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: Colors.grey.shade200,
                                          ),
                                          child: media.isVideo
                                              ? const Icon(
                                                  Icons.videocam,
                                                  size: 50,
                                                )
                                              : ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    12,
                                                  ),
                                                  child: Image.network(
                                                    media.fichier,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                        );
                                      },
                                    ),
                                  ),

                                const SizedBox(height: 10),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      size: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat("dd/MM/yyyy à HH:mm")
                                          .format(
                                        DateTime.parse(actualite.createdAt),
                                      ),
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}