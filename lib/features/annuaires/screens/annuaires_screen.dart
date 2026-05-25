import 'package:flutter/material.dart';
import '/core/api/annuaires_service.dart';

// ─── AnnuairesScreen (unchanged layout, loads from API) ──────────────────────

class AnnuairesScreen extends StatefulWidget {
  const AnnuairesScreen({super.key});

  @override
  State<AnnuairesScreen> createState() => _AnnuairesScreenState();
}

class _AnnuairesScreenState extends State<AnnuairesScreen> {
  final _api = AnnuairesApiService();
  List<ServiceModel> _services = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final services = await _api.fetchServices();
      setState(() {
        _services = services;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("Gestion des Annuaires"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: TextStyle(color: Colors.red)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _services.length,
                  itemBuilder: (context, index) {
                    final service = _services[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: service.flutterColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              service.flutterIcon,
                              color: service.flutterColor,
                              size: 30,
                            ),
                          ),
                          title: Text(
                            service.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              "${service.entryCount} entrée(s) enregistrée(s)",
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ),
                          trailing: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.edit),
                              color: Colors.blue,
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DirectoryFormScreen(
                                      service: service,
                                    ),
                                  ),
                                );
                                _load(); // refresh count after save
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// ─── DirectoryFormScreen (wired to API) ──────────────────────────────────────

class DirectoryFormScreen extends StatefulWidget {
  final ServiceModel service;
  final DirectoryEntry? existingEntry; // pass to edit, null to create

  const DirectoryFormScreen({
    super.key,
    required this.service,
    this.existingEntry,
  });

  @override
  State<DirectoryFormScreen> createState() => _DirectoryFormScreenState();
}

class _DirectoryFormScreenState extends State<DirectoryFormScreen> {
  final _api = AnnuairesApiService();
  bool _saving = false;

  // General controllers
  late final TextEditingController _name;
  late final TextEditingController _responsible;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  late final TextEditingController _email;
  late final TextEditingController _hours;
  late final TextEditingController _description;

  // Service-specific controllers
  late final TextEditingController _commissariat;
  late final TextEditingController _zoneCovered;
  late final TextEditingController _caserne;
  late final TextEditingController _interventionZone;
  late final TextEditingController _emergencyNumber;
  late final TextEditingController _hospitalType;
  late final TextEditingController _medicalServices;
  late final TextEditingController _emergencyAvailable;
  late final TextEditingController _mayorName;
  late final TextEditingController _offeredServices;
  late final TextEditingController _serviceType;
  late final TextEditingController _documentsDelivered;
  late final TextEditingController _schoolName;
  late final TextEditingController _educationLevel;
  late final TextEditingController _director;

  @override
  void initState() {
    super.initState();
    final e = widget.existingEntry;
    _name               = TextEditingController(text: e?.name ?? '');
    _responsible        = TextEditingController(text: e?.responsible ?? '');
    _phone              = TextEditingController(text: e?.phone ?? '');
    _address            = TextEditingController(text: e?.address ?? '');
    _email              = TextEditingController(text: e?.email ?? '');
    _hours              = TextEditingController(text: e?.hours ?? '');
    _description        = TextEditingController(text: e?.description ?? '');
    _commissariat       = TextEditingController(text: e?.commissariat ?? '');
    _zoneCovered        = TextEditingController(text: e?.zoneCovered ?? '');
    _caserne            = TextEditingController(text: e?.caserne ?? '');
    _interventionZone   = TextEditingController(text: e?.interventionZone ?? '');
    _emergencyNumber    = TextEditingController(text: e?.emergencyNumber ?? '');
    _hospitalType       = TextEditingController(text: e?.hospitalType ?? '');
    _medicalServices    = TextEditingController(text: e?.medicalServices ?? '');
    _emergencyAvailable = TextEditingController(text: e?.emergencyAvailable ?? '');
    _mayorName          = TextEditingController(text: e?.mayorName ?? '');
    _offeredServices    = TextEditingController(text: e?.offeredServices ?? '');
    _serviceType        = TextEditingController(text: e?.serviceType ?? '');
    _documentsDelivered = TextEditingController(text: e?.documentsDelivered ?? '');
    _schoolName         = TextEditingController(text: e?.schoolName ?? '');
    _educationLevel     = TextEditingController(text: e?.educationLevel ?? '');
    _director           = TextEditingController(text: e?.director ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _name, _responsible, _phone, _address, _email, _hours, _description,
      _commissariat, _zoneCovered, _caserne, _interventionZone, _emergencyNumber,
      _hospitalType, _medicalServices, _emergencyAvailable, _mayorName,
      _offeredServices, _serviceType, _documentsDelivered, _schoolName,
      _educationLevel, _director,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le nom de l'établissement est requis.")),
      );
      return;
    }

    setState(() => _saving = true);

    final entry = DirectoryEntry(
      id: widget.existingEntry?.id,
      serviceId: widget.service.id,
      name: _name.text.trim(),
      responsible: _responsible.text.trim(),
      phone: _phone.text.trim(),
      address: _address.text.trim(),
      email: _email.text.trim(),
      hours: _hours.text.trim(),
      description: _description.text.trim(),
      commissariat: _commissariat.text.trim(),
      zoneCovered: _zoneCovered.text.trim(),
      caserne: _caserne.text.trim(),
      interventionZone: _interventionZone.text.trim(),
      emergencyNumber: _emergencyNumber.text.trim(),
      hospitalType: _hospitalType.text.trim(),
      medicalServices: _medicalServices.text.trim(),
      emergencyAvailable: _emergencyAvailable.text.trim(),
      mayorName: _mayorName.text.trim(),
      offeredServices: _offeredServices.text.trim(),
      serviceType: _serviceType.text.trim(),
      documentsDelivered: _documentsDelivered.text.trim(),
      schoolName: _schoolName.text.trim(),
      educationLevel: _educationLevel.text.trim(),
      director: _director.text.trim(),
    );

    try {
      if (entry.id == null) {
        await _api.createEntry(entry);
      } else {
        await _api.updateEntry(entry);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enregistré avec succès ✓")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final svcTitle = widget.service.title;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: Text(svcTitle)),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save),
              label: Text(_saving ? "Enregistrement..." : "Enregistrer"),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  CircleAvatar(
                    radius: 28,
                    child: Icon(widget.service.flutterIcon, size: 30),
                  ),
                  const SizedBox(width: 15),
                  Expanded(child: Text(svcTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                ]),
                const SizedBox(height: 30),
                const Text("Informations générales", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                const SizedBox(height: 18),
                _field("Nom de l'établissement", Icons.business, _name),
                const SizedBox(height: 15),
                _field("Responsable", Icons.person, _responsible),
                const SizedBox(height: 15),
                _field("Téléphone", Icons.phone, _phone),
                const SizedBox(height: 15),
                _field("Adresse", Icons.location_on, _address),
                const SizedBox(height: 15),
                _field("Email", Icons.email, _email),
                const SizedBox(height: 15),
                _field("Horaires", Icons.access_time, _hours),
                const SizedBox(height: 15),
                _field("Description", Icons.description, _description, maxLines: 4),
                const SizedBox(height: 25),

                // ── Police ──────────────────────────────────────────────────
                if (svcTitle == "Police") ...[
                  _field("Commissariat", Icons.local_police, _commissariat),
                  const SizedBox(height: 15),
                  _field("Zone couverte", Icons.map, _zoneCovered),
                  const SizedBox(height: 15),
                  _field("Numéro d'urgence", Icons.emergency, _emergencyNumber),
                ],

                // ── Pompiers ─────────────────────────────────────────────────
                if (svcTitle == "Pompiers") ...[
                  _field("Caserne", Icons.fire_truck, _caserne),
                  const SizedBox(height: 15),
                  _field("Zone d'intervention", Icons.location_city, _interventionZone),
                  const SizedBox(height: 15),
                  _field("Numéro d'urgence", Icons.call, _emergencyNumber),
                ],

                // ── Hôpitaux ─────────────────────────────────────────────────
                if (svcTitle == "Hôpitaux") ...[
                  _field("Type d'hôpital", Icons.local_hospital, _hospitalType),
                  const SizedBox(height: 15),
                  _field("Services médicaux", Icons.medical_services, _medicalServices),
                  const SizedBox(height: 15),
                  _field("Urgences disponibles", Icons.emergency, _emergencyAvailable),
                ],

                // ── Mairie ───────────────────────────────────────────────────
                if (svcTitle == "Mairie") ...[
                  _field("Nom du maire", Icons.account_balance, _mayorName),
                  const SizedBox(height: 15),
                  _field("Services proposés", Icons.miscellaneous_services, _offeredServices),
                ],

                // ── Services administratifs ───────────────────────────────────
                if (svcTitle == "Services administratifs") ...[
                  _field("Type de service", Icons.badge, _serviceType),
                  const SizedBox(height: 15),
                  _field("Documents délivrés", Icons.folder, _documentsDelivered),
                ],

                // ── Éducation ─────────────────────────────────────────────────
                if (svcTitle == "Éducation") ...[
                  _field("Nom de l'école", Icons.school, _schoolName),
                  const SizedBox(height: 15),
                  _field("Niveau d'enseignement", Icons.menu_book, _educationLevel),
                  const SizedBox(height: 15),
                  _field("Directeur", Icons.person_3, _director),
                ],

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _field(String label, IconData icon, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
