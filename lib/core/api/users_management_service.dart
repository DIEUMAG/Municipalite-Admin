import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class CitizenModel {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String password; // hashed as stored in DB
  final bool isActive;
  final String dateJoined;

  const CitizenModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.isActive,
    required this.dateJoined,
  });

  String get fullName {
    final n = '$firstName $lastName'.trim();
    return n.isEmpty ? username : n;
  }

  factory CitizenModel.fromJson(Map<String, dynamic> j) => CitizenModel(
        id: j['id'],
        username: j['username'] ?? '',
        firstName: j['first_name'] ?? '',
        lastName: j['last_name'] ?? '',
        email: j['email'] ?? '',
        phoneNumber: j['phone_number'] ?? '',
        password: j['password'] ?? '',
        isActive: j['is_active'] ?? true,
        dateJoined: j['date_joined'] ?? '',
      );
}

class AgentModel {
  final int? id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String agentCode;
  final String department;
  final bool isActive;
  final String dateJoined;

  const AgentModel({
    this.id,
    required this.username,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phoneNumber = '',
    this.agentCode = '',
    this.department = '',
    this.isActive = true,
    this.dateJoined = '',
  });

  String get fullName {
    final n = '$firstName $lastName'.trim();
    return n.isEmpty ? username : n;
  }

  factory AgentModel.fromJson(Map<String, dynamic> j) => AgentModel(
        id: j['id'],
        username: j['username'] ?? '',
        firstName: j['first_name'] ?? '',
        lastName: j['last_name'] ?? '',
        email: j['email'] ?? '',
        phoneNumber: j['phone_number'] ?? '',
        agentCode: j['agent_code'] ?? '',
        department: j['department'] ?? '',
        isActive: j['is_active'] ?? true,
        dateJoined: j['date_joined'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone_number': phoneNumber,
        'agent_code': agentCode,
        'department': department,
        'is_active': isActive,
      };
}

// ─── API Service ──────────────────────────────────────────────────────────────

class UserManagementService {
  final http.Client _client;

  UserManagementService({http.Client? client})
      : _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  List _parseList(dynamic body) {
    if (body is Map) return body['results'] ?? [];
    if (body is List) return body;
    return [];
  }

  // ── Citizens ──────────────────────────────────────────────────────────────

  Future<List<CitizenModel>> fetchCitizens({String search = ''}) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/citizens/${search.isNotEmpty ? '?search=$search' : ''}',
    );
    final response = await _client.get(uri, headers: _headers);
    _check(response);
    return _parseList(jsonDecode(response.body))
        .map((j) => CitizenModel.fromJson(j))
        .toList();
  }

  Future<bool> toggleCitizenActive(int id) async {
    final response = await _client.patch(
      Uri.parse('${ApiConstants.baseUrl}/citizens/$id/toggle-active/'),
      headers: _headers,
    );
    _check(response);
    return jsonDecode(response.body)['is_active'];
  }

  // ── Agents ────────────────────────────────────────────────────────────────

  Future<List<AgentModel>> fetchAgents({String search = ''}) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/agents/${search.isNotEmpty ? '?search=$search' : ''}',
    );
    final response = await _client.get(uri, headers: _headers);
    _check(response);
    return _parseList(jsonDecode(response.body))
        .map((j) => AgentModel.fromJson(j))
        .toList();
  }

  Future<AgentModel> createAgent(AgentModel agent, String password) async {
    final body = agent.toJson()..['password'] = password;
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}/agents/'),
      headers: _headers,
      body: jsonEncode(body),
    );
    _check(response);
    return AgentModel.fromJson(jsonDecode(response.body));
  }

  Future<AgentModel> updateAgent(AgentModel agent) async {
    assert(agent.id != null);
    final response = await _client.patch(
      Uri.parse('${ApiConstants.baseUrl}/agents/${agent.id}/'),
      headers: _headers,
      body: jsonEncode(agent.toJson()),
    );
    _check(response);
    return AgentModel.fromJson(jsonDecode(response.body));
  }

  Future<void> deleteAgent(int id) async {
    final response = await _client.delete(
      Uri.parse('${ApiConstants.baseUrl}/agents/$id/'),
      headers: _headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Delete failed: ${response.statusCode}');
    }
  }

  Future<bool> toggleAgentActive(int id) async {
    final response = await _client.patch(
      Uri.parse('${ApiConstants.baseUrl}/agents/$id/toggle-active/'),
      headers: _headers,
    );
    _check(response);
    return jsonDecode(response.body)['is_active'];
  }

  void _check(http.Response r) {
    if (r.statusCode >= 400) {
      throw Exception('API ${r.statusCode}: ${r.body}');
    }
  }
}