import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/civic_service.dart';
import '../models/service_report.dart';

class ServiceRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<CivicService>> getServicesByCategory(
      ServiceCategory category,
      ) async {
    final String categoryText = serviceCategoryToString(category);

    final List<dynamic> response = await _client
        .from('services')
        .select()
        .eq('category', categoryText)
        .eq('is_active', true)
        .order('name', ascending: true);

    return response
        .map(
          (item) => CivicService.fromMap(
        Map<String, dynamic>.from(item as Map),
      ),
    )
        .toList();
  }

  Future<List<CivicService>> getActiveServices() async {
    final List<dynamic> response = await _client
        .from('services')
        .select()
        .eq('is_active', true)
        .order('name', ascending: true);

    return response
        .map(
          (item) => CivicService.fromMap(
        Map<String, dynamic>.from(item as Map),
      ),
    )
        .toList();
  }

  Future<List<CivicService>> getAllServicesForAdmin() async {
    final List<dynamic> response = await _client
        .from('services')
        .select()
        .order('created_at', ascending: false);

    return response
        .map(
          (item) => CivicService.fromMap(
        Map<String, dynamic>.from(item as Map),
      ),
    )
        .toList();
  }

  Future<void> createService({
    required String name,
    required ServiceCategory category,
    required String address,
    required String area,
    required String district,
    required String? phone,
    required double latitude,
    required double longitude,
    required bool isOpen24Hours,
    required String description,
    required bool isActive,
  }) async {
    await _client.from('services').insert({
      'name': name,
      'category': serviceCategoryToString(category),
      'address': address,
      'area': area,
      'district': district,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'is_open_24_hours': isOpen24Hours,
      'description': description,
      'is_active': isActive,
    });
  }

  Future<void> updateService({
    required String serviceId,
    required String name,
    required ServiceCategory category,
    required String address,
    required String area,
    required String district,
    required String? phone,
    required double latitude,
    required double longitude,
    required bool isOpen24Hours,
    required String description,
    required bool isActive,
  }) async {
    await _client.from('services').update({
      'name': name,
      'category': serviceCategoryToString(category),
      'address': address,
      'area': area,
      'district': district,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'is_open_24_hours': isOpen24Hours,
      'description': description,
      'is_active': isActive,
    }).eq('id', serviceId);
  }

  Future<void> toggleServiceActive({
    required String serviceId,
    required bool isActive,
  }) async {
    await _client.from('services').update({
      'is_active': isActive,
    }).eq('id', serviceId);
  }

  Future<void> submitServiceReport({
    required CivicService service,
    required String issueType,
    required String issueDescription,
    String? reporterName,
    String? reporterPhone,
  }) async {
    final Map<String, dynamic> reportData = {
      'service_id': service.id,
      'service_name': service.name,
      'issue_type': issueType,
      'issue_description': issueDescription,
      'reporter_name': reporterName,
      'reporter_phone': reporterPhone,
    };

    debugPrint('Submitting report to Supabase: $reportData');

    await _client.from('service_reports').insert(reportData);

    debugPrint('Report submitted to Supabase successfully.');
  }

  Future<void> signInAdmin({
    required String email,
    required String password,
  }) async {
    final AuthResponse response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final User? user = response.user;

    if (user == null) {
      throw Exception('Login failed.');
    }

    final List<dynamic> adminResponse = await _client
        .from('admin_users')
        .select()
        .eq('user_id', user.id)
        .limit(1);

    if (adminResponse.isEmpty) {
      await _client.auth.signOut();
      throw Exception('This account is not an admin.');
    }
  }

  Future<void> signOutAdmin() async {
    await _client.auth.signOut();
  }

  Future<bool> isAdminLoggedIn() async {
    final User? user = _client.auth.currentUser;

    if (user == null) {
      return false;
    }

    final List<dynamic> adminResponse = await _client
        .from('admin_users')
        .select()
        .eq('user_id', user.id)
        .limit(1);

    return adminResponse.isNotEmpty;
  }

  Future<List<ServiceReport>> getServiceReports() async {
    final List<dynamic> response = await _client
        .from('service_reports')
        .select()
        .order('created_at', ascending: false);

    return response
        .map(
          (item) => ServiceReport.fromMap(
        Map<String, dynamic>.from(item as Map),
      ),
    )
        .toList();
  }

  Future<void> updateReportStatus({
    required String reportId,
    required String status,
  }) async {
    await _client.from('service_reports').update({
      'status': status,
    }).eq('id', reportId);
  }
}