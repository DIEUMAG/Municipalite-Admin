import 'package:flutter/material.dart';
import '/core/api/users_management_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _svc = UserManagementService();

  // Citizens state
  List<CitizenModel> _citizens = [];
  bool _loadingCitizens = true;
  String? _citizenError;
  final _citizenSearch = TextEditingController();

  // Agents state
  List<AgentModel> _agents = [];
  bool _loadingAgents = true;
  String? _agentError;
  final _agentSearch = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadCitizens();
    _loadAgents();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _citizenSearch.dispose();
    _agentSearch.dispose();
    super.dispose();
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> _loadCitizens({String search = ''}) async {
    setState(() {
      _loadingCitizens = true;
      _citizenError = null;
    });
    try {
      final data = await _svc.fetchCitizens(search: search);
      setState(() {
        _citizens = data;
        _loadingCitizens = false;
      });
    } catch (e) {
      setState(() {
        _citizenError = e.toString();
        _loadingCitizens = false;
      });
    }
  }

  Future<void> _loadAgents({String search = ''}) async {
    setState(() {
      _loadingAgents = true;
      _agentError = null;
    });
    try {
      final data = await _svc.fetchAgents(search: search);
      setState(() {
        _agents = data;
        _loadingAgents = false;
      });
    } catch (e) {
      setState(() {
        _agentError = e.toString();
        _loadingAgents = false;
      });
    }
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _toggleCitizen(CitizenModel c) async {
    try {
      final active = await _svc.toggleCitizenActive(c.id);
      setState(() {
        final i = _citizens.indexWhere((x) => x.id == c.id);
        if (i != -1) {
          _citizens[i] = CitizenModel(
            id: c.id,
            username: c.username,
            firstName: c.firstName,
            lastName: c.lastName,
            email: c.email,
            phoneNumber: c.phoneNumber,
            password: c.password,
            isActive: active,
            dateJoined: c.dateJoined,
          );
        }
      });
    } catch (e) {
      _snack('Erreur: $e');
    }
  }

  Future<void> _toggleAgent(AgentModel a) async {
    try {
      final active = await _svc.toggleAgentActive(a.id!);
      setState(() {
        final i = _agents.indexWhere((x) => x.id == a.id);
        if (i != -1) {
          _agents[i] = AgentModel(
            id: a.id,
            username: a.username,
            firstName: a.firstName,
            lastName: a.lastName,
            email: a.email,
            phoneNumber: a.phoneNumber,
            agentCode: a.agentCode,
            department: a.department,
            isActive: active,
            dateJoined: a.dateJoined,
          );
        }
      });
    } catch (e) {
      _snack('Erreur: $e');
    }
  }

  Future<void> _deleteAgent(AgentModel a) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer l\'agent'),
        content: Text('Supprimer ${a.fullName} ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _svc.deleteAgent(a.id!);
      setState(() => _agents.removeWhere((x) => x.id == a.id));
      _snack('Agent supprimé');
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

  // ── Open citizen detail ───────────────────────────────────────────────────

  void _showCitizenDetail(CitizenModel c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  c.fullName.isNotEmpty ? c.fullName[0].toUpperCase() : '?',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.fullName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('@${c.username}',
                        style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
              _statusBadge(c.isActive),
            ]),
            const SizedBox(height: 20),
            _detailRow(Icons.email, 'Email', c.email),
            _detailRow(Icons.phone, 'Téléphone', c.phoneNumber),
            _detailRow(Icons.lock, 'Mot de passe (hashé)', c.password,
                mono: true),
            _detailRow(Icons.calendar_today, 'Inscrit le',
                c.dateJoined.isNotEmpty
                    ? c.dateJoined.substring(0, 10)
                    : '—'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _toggleCitizen(c);
                },
                icon: Icon(
                    c.isActive ? Icons.block : Icons.check_circle_outline),
                label: Text(c.isActive ? 'Désactiver' : 'Activer'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: c.isActive ? Colors.red : Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Open agent form ───────────────────────────────────────────────────────

  void _openAgentForm({AgentModel? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AgentForm(
        existing: existing,
        onSave: (agent, password) async {
          try {
            if (existing == null) {
              final created = await _svc.createAgent(agent, password);
              setState(() => _agents.insert(0, created));
              _snack('Agent créé ✓');
            } else {
              final updated = await _svc.updateAgent(agent);
              setState(() {
                final i = _agents.indexWhere((x) => x.id == updated.id);
                if (i != -1) _agents[i] = updated;
              });
              _snack('Agent mis à jour ✓');
            }
          } catch (e) {
            _snack('Erreur: $e');
          }
        },
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('Gestion des Utilisateurs'),
        bottom: TabBar(
          controller: _tabs,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: [
            Tab(
              icon: const Icon(Icons.people),
              text: 'Citoyens (${_citizens.length})',
            ),
            Tab(
              icon: const Icon(Icons.badge),
              text: 'Agents (${_agents.length})',
            ),
          ],
        ),
      ),
      floatingActionButton: ListenableBuilder(
        listenable: _tabs,
        builder: (_, __) => _tabs.index == 1
            ? FloatingActionButton.extended(
                onPressed: () => _openAgentForm(),
                icon: const Icon(Icons.person_add),
                label: const Text('Nouvel agent'),
              )
            : const SizedBox.shrink(),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _citizensTab(),
          _agentsTab(),
        ],
      ),
    );
  }

  // ── Citizens tab ──────────────────────────────────────────────────────────

  Widget _citizensTab() {
    return Column(
      children: [
        _searchBar(_citizenSearch, 'Rechercher un citoyen...', (v) {
          if (v.isEmpty || v.length >= 2) _loadCitizens(search: v);
        }),
        Expanded(
          child: _loadingCitizens
              ? const Center(child: CircularProgressIndicator())
              : _citizenError != null
                  ? _errorWidget(_citizenError!, () => _loadCitizens())
                  : _citizens.isEmpty
                      ? const Center(child: Text('Aucun citoyen trouvé'))
                      : RefreshIndicator(
                          onRefresh: () => _loadCitizens(),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _citizens.length,
                            itemBuilder: (_, i) =>
                                _citizenCard(_citizens[i]),
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _citizenCard(CitizenModel c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 3,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Text(
              c.fullName.isNotEmpty ? c.fullName[0].toUpperCase() : '?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(c.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (c.email.isNotEmpty)
                Text(c.email,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
              if (c.phoneNumber.isNotEmpty)
                Text(c.phoneNumber,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
          trailing: _statusBadge(c.isActive),
          onTap: () => _showCitizenDetail(c),
        ),
      ),
    );
  }

  // ── Agents tab ────────────────────────────────────────────────────────────

  Widget _agentsTab() {
    return Column(
      children: [
        _searchBar(_agentSearch, 'Rechercher un agent...', (v) {
          if (v.isEmpty || v.length >= 2) _loadAgents(search: v);
        }),
        Expanded(
          child: _loadingAgents
              ? const Center(child: CircularProgressIndicator())
              : _agentError != null
                  ? _errorWidget(_agentError!, () => _loadAgents())
                  : _agents.isEmpty
                      ? const Center(child: Text('Aucun agent trouvé'))
                      : RefreshIndicator(
                          onRefresh: () => _loadAgents(),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _agents.length,
                            itemBuilder: (_, i) => _agentCard(_agents[i]),
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _agentCard(AgentModel a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 3,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: Colors.purple.shade100,
            child: Text(
              a.fullName.isNotEmpty ? a.fullName[0].toUpperCase() : '?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(a.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (a.department.isNotEmpty)
                Text(a.department,
                    style: const TextStyle(fontSize: 12)),
              if (a.agentCode.isNotEmpty)
                Text('Code: ${a.agentCode}',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _statusBadge(a.isActive),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') _openAgentForm(existing: a);
                  if (v == 'toggle') _toggleAgent(a);
                  if (v == 'delete') _deleteAgent(a);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Modifier')
                      ])),
                  PopupMenuItem(
                      value: 'toggle',
                      child: Row(children: [
                        Icon(
                            a.isActive
                                ? Icons.block
                                : Icons.check_circle_outline,
                            size: 18),
                        const SizedBox(width: 8),
                        Text(a.isActive ? 'Désactiver' : 'Activer')
                      ])),
                  const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Supprimer',
                            style: TextStyle(color: Colors.red))
                      ])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────

  Widget _searchBar(TextEditingController ctrl, String hint,
      ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: ctrl,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        active ? 'Actif' : 'Inactif',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: active ? Colors.green.shade700 : Colors.red.shade700,
        ),
      ),
    );
  }

  Widget _errorWidget(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(error,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Réessayer')),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value,
      {bool mono = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500)),
                Text(
                  value.isEmpty ? '—' : value,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: mono ? 'monospace' : null,
                  ),
                  maxLines: mono ? 2 : null,
                  overflow: mono ? TextOverflow.ellipsis : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Agent create/edit form ───────────────────────────────────────────────────

class _AgentForm extends StatefulWidget {
  final AgentModel? existing;
  final Future<void> Function(AgentModel agent, String password) onSave;

  const _AgentForm({required this.onSave, this.existing});

  @override
  State<_AgentForm> createState() => _AgentFormState();
}

class _AgentFormState extends State<_AgentForm> {
  final _username    = TextEditingController();
  final _firstName   = TextEditingController();
  final _lastName    = TextEditingController();
  final _email       = TextEditingController();
  final _phone       = TextEditingController();
  final _agentCode   = TextEditingController();
  final _department  = TextEditingController();
  final _password    = TextEditingController();
  bool _saving = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _username.text   = e.username;
      _firstName.text  = e.firstName;
      _lastName.text   = e.lastName;
      _email.text      = e.email;
      _phone.text      = e.phoneNumber;
      _agentCode.text  = e.agentCode;
      _department.text = e.department;
    }
  }

  @override
  void dispose() {
    for (final c in [_username, _firstName, _lastName, _email,
        _phone, _agentCode, _department, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_username.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Le nom d'utilisateur est requis.")));
      return;
    }
    setState(() => _saving = true);
    final agent = AgentModel(
      id: widget.existing?.id,
      username: _username.text.trim(),
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      email: _email.text.trim(),
      phoneNumber: _phone.text.trim(),
      agentCode: _agentCode.text.trim(),
      department: _department.text.trim(),
    );
    await widget.onSave(agent, _password.text);
    if (mounted) Navigator.pop(context);
    setState(() => _saving = false);
  }

  Widget _field(String label, IconData icon, TextEditingController ctrl,
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        obscureText: obscure ? _obscure : false,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: obscure
              ? IconButton(
                  icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscure = !_obscure),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(
              isEdit ? 'Modifier l\'agent' : 'Nouvel agent',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _field("Nom d'utilisateur *", Icons.person, _username),
            _field("Prénom", Icons.person_outline, _firstName),
            _field("Nom", Icons.person_outline, _lastName),
            _field("Email", Icons.email, _email),
            _field("Téléphone", Icons.phone, _phone),
            _field("Code agent", Icons.badge, _agentCode),
            _field("Département / Service", Icons.apartment, _department),
            if (!isEdit)
              _field("Mot de passe", Icons.lock, _password, obscure: true),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save),
                label: Text(_saving
                    ? 'Enregistrement...'
                    : isEdit ? 'Mettre à jour' : 'Créer l\'agent'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}