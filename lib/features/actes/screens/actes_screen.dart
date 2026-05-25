import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '/core/api/actes_service.dart';

class ArchiveActesPage extends StatefulWidget {
  const ArchiveActesPage({super.key});

  @override
  State<ArchiveActesPage> createState() => _ArchiveActesPageState();
}

class _ArchiveActesPageState extends State<ArchiveActesPage>
    with SingleTickerProviderStateMixin {
  final _svc = ActesService();
  late TabController _tabs;

  // ── Upload state ────────────────────────────────────────────────────────────
  String? _selectedType;
  File? _selectedFile;
  String? _selectedFileName;
  final _nomController = TextEditingController();
  final _descController = TextEditingController();
  bool _uploading = false;

  // ── List state ──────────────────────────────────────────────────────────────
  List<ActeModel> _actes = [];
  bool _loadingList = true;
  String? _listError;
  String? _filterType;

  final List<Map<String, String>> _types = [
    {'value': 'naissance', 'label': 'Acte de naissance'},
    {'value': 'mariage',   'label': 'Acte de mariage'},
    {'value': 'deces',     'label': 'Acte de décès'},
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadActes();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _nomController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // ── Load list ───────────────────────────────────────────────────────────────

  Future<void> _loadActes({String? type}) async {
    setState(() {
      _loadingList = true;
      _listError = null;
    });
    try {
      final data = await _svc.fetchActes(typeActe: type);
      setState(() {
        _actes = data;
        _loadingList = false;
      });
    } catch (e) {
      setState(() {
        _listError = e.toString();
        _loadingList = false;
      });
    }
  }

  // ── Pick PDF ─────────────────────────────────────────────────────────────────

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _selectedFileName = result.files.single.name;
      });
    }
  }

  // ── Upload ───────────────────────────────────────────────────────────────────

  Future<void> _upload() async {
    if (_selectedType == null) {
      _snack("Veuillez sélectionner un type d'acte.");
      return;
    }
    if (_selectedFile == null) {
      _snack("Veuillez choisir un fichier PDF.");
      return;
    }
    setState(() => _uploading = true);
    try {
      await _svc.uploadActe(
        typeActe: _selectedType!,
        pdfFile: _selectedFile!,
        nomComplet: _nomController.text.trim(),
        description: _descController.text.trim(),
      );
      _snack("Acte enregistré avec succès ✓");
      setState(() {
        _selectedType = null;
        _selectedFile = null;
        _selectedFileName = null;
        _nomController.clear();
        _descController.clear();
      });
      _loadActes(type: _filterType); // refresh list
      _tabs.animateTo(1);            // switch to list tab
    } catch (e) {
      _snack("Erreur: $e");
    } finally {
      setState(() => _uploading = false);
    }
  }

  // ── Delete ───────────────────────────────────────────────────────────────────

  Future<void> _delete(ActeModel acte) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer l\'acte'),
        content: Text(
            'Supprimer "${acte.typeActeDisplay}" de ${acte.nomComplet.isEmpty ? "cet enregistrement" : acte.nomComplet} ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Supprimer',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _svc.deleteActe(acte.id!);
      setState(() => _actes.removeWhere((a) => a.id == acte.id));
      _snack('Acte supprimé');
    } catch (e) {
      _snack('Erreur: $e');
    }
  }

  void _snack(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Archives des actes"),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(icon: Icon(Icons.upload_file), text: 'Ajouter'),
            Tab(icon: Icon(Icons.list_alt), text: 'Consulter'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _uploadTab(),
          _listTab(),
        ],
      ),
    );
  }

  // ── Upload tab ────────────────────────────────────────────────────────────────

  Widget _uploadTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type selector
          const Text("Type d'acte *",
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.description),
              filled: true,
              fillColor: Colors.white,
            ),
            hint: const Text("Choisir un type d'acte"),
            items: _types.map((t) {
              return DropdownMenuItem(
                  value: t['value'], child: Text(t['label']!));
            }).toList(),
            onChanged: (v) => setState(() => _selectedType = v),
          ),

          const SizedBox(height: 20),

          // Nom complet
          const Text("Nom complet concerné",
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            controller: _nomController,
            decoration: InputDecoration(
              hintText: "Ex: Jean Dupont",
              prefixIcon: const Icon(Icons.person),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Description
          const Text("Description",
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            controller: _descController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Notes optionnelles...",
              prefixIcon: const Icon(Icons.notes),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // PDF picker
          const Text("Fichier PDF *",
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _pickPdf,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: _selectedFile != null
                      ? Colors.green
                      : Colors.grey.shade400,
                  width: _selectedFile != null ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    _selectedFile != null
                        ? Icons.picture_as_pdf
                        : Icons.cloud_upload,
                    size: 60,
                    color: _selectedFile != null
                        ? Colors.green
                        : Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _selectedFileName ?? "Appuyer pour choisir un PDF",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _selectedFile != null
                          ? Colors.green.shade700
                          : Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_selectedFile == null) ...[
                    const SizedBox(height: 8),
                    Text("Fichiers .pdf uniquement",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500)),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _uploading ? null : _upload,
              icon: _uploading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save),
              label: Text(
                  _uploading ? "Enregistrement..." : "Enregistrer"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ── List tab ──────────────────────────────────────────────────────────────────

  Widget _listTab() {
    return Column(
      children: [
        // Filter chips
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('Tous', null),
                const SizedBox(width: 8),
                ..._types.map((t) =>
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _filterChip(t['label']!, t['value']),
                    )),
              ],
            ),
          ),
        ),
        Expanded(
          child: _loadingList
              ? const Center(child: CircularProgressIndicator())
              : _listError != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wifi_off,
                              size: 48, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text(_listError!,
                              style:
                                  const TextStyle(color: Colors.red)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                              onPressed: () =>
                                  _loadActes(type: _filterType),
                              child: const Text('Réessayer')),
                        ],
                      ),
                    )
                  : _actes.isEmpty
                      ? const Center(
                          child: Text("Aucun acte enregistré"))
                      : RefreshIndicator(
                          onRefresh: () =>
                              _loadActes(type: _filterType),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _actes.length,
                            itemBuilder: (_, i) =>
                                _acteCard(_actes[i]),
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, String? value) {
    final selected = _filterType == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() => _filterType = value);
        _loadActes(type: value);
      },
    );
  }

  Widget _acteCard(ActeModel acte) {
    final color = acte.typeActe == 'naissance'
        ? Colors.blue
        : acte.typeActe == 'mariage'
            ? Colors.pink
            : Colors.grey.shade700;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.picture_as_pdf, color: color, size: 28),
          ),
          title: Text(
            acte.typeActeDisplay,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (acte.nomComplet.isNotEmpty)
                Text(acte.nomComplet,
                    style: const TextStyle(fontSize: 13)),
              Text(
                acte.formattedDate,
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _delete(acte),
          ),
        ),
      ),
    );
  }
}