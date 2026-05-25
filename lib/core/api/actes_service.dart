import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../constants/api_constants.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class ActeModel {
  final int? id;
  final String typeActe;
  final String typeActeDisplay;
  final String fichierUrl;
  final String nomComplet;
  final String description;
  final String dateUpload;

  const ActeModel({
    this.id,
    required this.typeActe,
    this.typeActeDisplay = '',
    this.fichierUrl = '',
    this.nomComplet = '',
    this.description = '',
    this.dateUpload = '',
  });

  factory ActeModel.fromJson(Map<String, dynamic> j) => ActeModel(
        id: j['id'],
        typeActe: j['type_acte'] ?? '',
        typeActeDisplay: j['type_acte_display'] ?? '',
        fichierUrl: j['fichier_url'] ?? '',
        nomComplet: j['nom_complet'] ?? '',
        description: j['description'] ?? '',
        dateUpload: j['date_upload'] ?? '',
      );

  String get formattedDate {
    if (dateUpload.isEmpty) return '';
    return dateUpload.substring(0, 10);
  }
}

// ─── Service ──────────────────────────────────────────────────────────────────

class ActesService {
  final http.Client _client;

  ActesService({http.Client? client}) : _client = client ?? http.Client();

  List _parseList(dynamic body) {
    if (body is Map) return body['results'] ?? [];
    if (body is List) return body;
    return [];
  }

  /// GET /api/actes/?type_acte=<type>
  Future<List<ActeModel>> fetchActes({String? typeActe}) async {
    final query = typeActe != null ? '?type_acte=$typeActe' : '';
    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}/actes/$query'),
      headers: {'Accept': 'application/json'},
    );
    _check(response);
    return _parseList(jsonDecode(response.body))
        .map((j) => ActeModel.fromJson(j))
        .toList();
  }

  /// POST /api/actes/ — upload PDF with metadata
  Future<ActeModel> uploadActe({
    required String typeActe,
    required File pdfFile,
    String nomComplet = '',
    String description = '',
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/actes/');
    final request = http.MultipartRequest('POST', uri)
      ..fields['type_acte'] = typeActe
      ..fields['nom_complet'] = nomComplet
      ..fields['description'] = description
      ..files.add(await http.MultipartFile.fromPath(
        'fichier',
        pdfFile.path,
        contentType: MediaType('application', 'pdf'),
      ));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    _check(response);
    return ActeModel.fromJson(jsonDecode(response.body));
  }

  /// DELETE /api/actes/<id>/
  Future<void> deleteActe(int id) async {
    final response = await _client.delete(
      Uri.parse('${ApiConstants.baseUrl}/actes/$id/'),
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode != 204) {
      throw Exception('Delete failed: ${response.statusCode}');
    }
  }

  void _check(http.Response r) {
    if (r.statusCode >= 400) {
      throw Exception('API ${r.statusCode}: ${r.body}');
    }
  }
}