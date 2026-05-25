import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class ServiceModel {
  final int id;
  final String title;
  final String icon;
  final String color;
  final int entryCount;

  const ServiceModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.entryCount,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
        id: json['id'],
        title: json['title'],
        icon: json['icon'],
        color: json['color'],
        entryCount: json['entry_count'] ?? 0,
      );

  Color get flutterColor {
    switch (color) {
      case 'blue':   return Colors.blue;
      case 'red':    return Colors.red;
      case 'green':  return Colors.green;
      case 'orange': return Colors.orange;
      case 'purple': return Colors.purple;
      case 'teal':   return Colors.teal;
      default:       return Colors.grey;
    }
  }

  IconData get flutterIcon {
    switch (icon) {
      case 'local_police':    return Icons.local_police;
      case 'fire_truck':      return Icons.fire_truck;
      case 'local_hospital':  return Icons.local_hospital;
      case 'account_balance': return Icons.account_balance;
      case 'business_center': return Icons.business_center;
      case 'school':          return Icons.school;
      default:                return Icons.info;
    }
  }
}

class DirectoryEntry {
  final int? id;
  final int serviceId;
  final String serviceName;
  final String name;
  final String responsible;
  final String phone;
  final String address;
  final String email;
  final String hours;
  final String description;
  final String commissariat;
  final String zoneCovered;
  final String caserne;
  final String interventionZone;
  final String emergencyNumber;
  final String hospitalType;
  final String medicalServices;
  final String emergencyAvailable;
  final String mayorName;
  final String offeredServices;
  final String serviceType;
  final String documentsDelivered;
  final String schoolName;
  final String educationLevel;
  final String director;

  const DirectoryEntry({
    this.id,
    required this.serviceId,
    this.serviceName = '',
    this.name = '',
    this.responsible = '',
    this.phone = '',
    this.address = '',
    this.email = '',
    this.hours = '',
    this.description = '',
    this.commissariat = '',
    this.zoneCovered = '',
    this.caserne = '',
    this.interventionZone = '',
    this.emergencyNumber = '',
    this.hospitalType = '',
    this.medicalServices = '',
    this.emergencyAvailable = '',
    this.mayorName = '',
    this.offeredServices = '',
    this.serviceType = '',
    this.documentsDelivered = '',
    this.schoolName = '',
    this.educationLevel = '',
    this.director = '',
  });

  factory DirectoryEntry.fromJson(Map<String, dynamic> json) => DirectoryEntry(
        id: json['id'],
        serviceId: json['service'],
        serviceName: json['service_title'] ?? '',
        name: json['name'] ?? '',
        responsible: json['responsible'] ?? '',
        phone: json['phone'] ?? '',
        address: json['address'] ?? '',
        email: json['email'] ?? '',
        hours: json['hours'] ?? '',
        description: json['description'] ?? '',
        commissariat: json['commissariat'] ?? '',
        zoneCovered: json['zone_covered'] ?? '',
        caserne: json['caserne'] ?? '',
        interventionZone: json['intervention_zone'] ?? '',
        emergencyNumber: json['emergency_number'] ?? '',
        hospitalType: json['hospital_type'] ?? '',
        medicalServices: json['medical_services'] ?? '',
        emergencyAvailable: json['emergency_available'] ?? '',
        mayorName: json['mayor_name'] ?? '',
        offeredServices: json['offered_services'] ?? '',
        serviceType: json['service_type'] ?? '',
        documentsDelivered: json['documents_delivered'] ?? '',
        schoolName: json['school_name'] ?? '',
        educationLevel: json['education_level'] ?? '',
        director: json['director'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'service': serviceId,
        'name': name,
        'responsible': responsible,
        'phone': phone,
        'address': address,
        'email': email,
        'hours': hours,
        'description': description,
        'commissariat': commissariat,
        'zone_covered': zoneCovered,
        'caserne': caserne,
        'intervention_zone': interventionZone,
        'emergency_number': emergencyNumber,
        'hospital_type': hospitalType,
        'medical_services': medicalServices,
        'emergency_available': emergencyAvailable,
        'mayor_name': mayorName,
        'offered_services': offeredServices,
        'service_type': serviceType,
        'documents_delivered': documentsDelivered,
        'school_name': schoolName,
        'education_level': educationLevel,
        'director': director,
      };

  DirectoryEntry copyWith({
    int? id,
    int? serviceId,
    String? name,
    String? responsible,
    String? phone,
    String? address,
    String? email,
    String? hours,
    String? description,
    String? commissariat,
    String? zoneCovered,
    String? caserne,
    String? interventionZone,
    String? emergencyNumber,
    String? hospitalType,
    String? medicalServices,
    String? emergencyAvailable,
    String? mayorName,
    String? offeredServices,
    String? serviceType,
    String? documentsDelivered,
    String? schoolName,
    String? educationLevel,
    String? director,
  }) =>
      DirectoryEntry(
        id: id ?? this.id,
        serviceId: serviceId ?? this.serviceId,
        serviceName: serviceName,
        name: name ?? this.name,
        responsible: responsible ?? this.responsible,
        phone: phone ?? this.phone,
        address: address ?? this.address,
        email: email ?? this.email,
        hours: hours ?? this.hours,
        description: description ?? this.description,
        commissariat: commissariat ?? this.commissariat,
        zoneCovered: zoneCovered ?? this.zoneCovered,
        caserne: caserne ?? this.caserne,
        interventionZone: interventionZone ?? this.interventionZone,
        emergencyNumber: emergencyNumber ?? this.emergencyNumber,
        hospitalType: hospitalType ?? this.hospitalType,
        medicalServices: medicalServices ?? this.medicalServices,
        emergencyAvailable: emergencyAvailable ?? this.emergencyAvailable,
        mayorName: mayorName ?? this.mayorName,
        offeredServices: offeredServices ?? this.offeredServices,
        serviceType: serviceType ?? this.serviceType,
        documentsDelivered: documentsDelivered ?? this.documentsDelivered,
        schoolName: schoolName ?? this.schoolName,
        educationLevel: educationLevel ?? this.educationLevel,
        director: director ?? this.director,
      );
}

// ─── API Service ──────────────────────────────────────────────────────────────

class AnnuairesApiService {
  final http.Client _client;

  AnnuairesApiService({http.Client? client})
      : _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// GET /api/services/
  Future<List<ServiceModel>> fetchServices() async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}/services/'),
      headers: _headers,
    );
    _checkStatus(response);
    final body = jsonDecode(response.body);
    final List data = body is Map ? (body['results'] ?? []) : body;
    return data.map((j) => ServiceModel.fromJson(j)).toList();
  }

  /// GET /api/entries/?service=<serviceId>
  Future<List<DirectoryEntry>> fetchEntriesByService(int serviceId) async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}/entries/?service=$serviceId'),
      headers: _headers,
    );
    _checkStatus(response);
    final body = jsonDecode(response.body);
    final List data = body is Map ? (body['results'] ?? []) : body;
    return data.map((j) => DirectoryEntry.fromJson(j)).toList();
  }

  /// POST /api/entries/
  Future<DirectoryEntry> createEntry(DirectoryEntry entry) async {
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}/entries/'),
      headers: _headers,
      body: jsonEncode(entry.toJson()),
    );
    _checkStatus(response);
    return DirectoryEntry.fromJson(jsonDecode(response.body));
  }

  /// PATCH /api/entries/<id>/
  Future<DirectoryEntry> updateEntry(DirectoryEntry entry) async {
    assert(entry.id != null, 'Entry must have an id to update');
    final response = await _client.patch(
      Uri.parse('${ApiConstants.baseUrl}/entries/${entry.id}/'),
      headers: _headers,
      body: jsonEncode(entry.toJson()),
    );
    _checkStatus(response);
    return DirectoryEntry.fromJson(jsonDecode(response.body));
  }

  /// DELETE /api/entries/<id>/
  Future<void> deleteEntry(int id) async {
    final response = await _client.delete(
      Uri.parse('${ApiConstants.baseUrl}/entries/$id/'),
      headers: _headers,
    );
    if (response.statusCode != 204) {
      throw ApiException('Failed to delete entry: ${response.statusCode}');
    }
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode >= 400) {
      throw ApiException(
        'API error ${response.statusCode}: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  }
}

// ─── Exception ────────────────────────────────────────────────────────────────

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message';
}