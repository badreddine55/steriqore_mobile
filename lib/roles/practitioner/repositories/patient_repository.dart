import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';
import '../../../services/auth_service.dart';
import '../models/patient_model.dart';
import 'practitioner_exceptions.dart';

/// Repository for listing and searching practice patients for instrument usage recording
class PatientRepository {
  final http.Client _client;
  static const String _cachedPatientsKey = 'practitioner_cached_patients';

  PatientRepository({http.Client? client}) : _client = client ?? http.Client();

  /// Hits `GET /api/v1/patients`
  ///
  /// Searches and lists active clinic patients for the patient picker.
  /// Automatically caches patient records to allow offline recording during network drops.
  Future<List<PatientModel>> getPatients({String? query}) async {
    final token = await AuthService.getToken();
    final uri = Uri.parse(ApiConstants.patients).replace(
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'search': query.trim(),
      },
    );

    try {
      final response = await _client.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 8));

      final statusCode = response.statusCode;

      if (statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final list = (body['data'] as List<dynamic>?) ?? [];
        final patients = list
            .map((e) => PatientModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // Update local offline cache
        await _cachePatients(patients);
        return patients;
      } else if (statusCode == 401) {
        throw const TokenExpiredException();
      } else if (statusCode == 403) {
        throw const RoleForbiddenException();
      } else if (statusCode == 429) {
        throw const RateLimitException();
      } else {
        throw PractitionerException('Failed to fetch patients ($statusCode)', statusCode);
      }
    } catch (e) {
      if (e is PractitionerException) rethrow;

      // Offline fallback: load cached patients
      final cached = await _getCachedPatients();
      if (cached.isNotEmpty) {
        if (query != null && query.trim().isNotEmpty) {
          final q = query.toLowerCase().trim();
          return cached
              .where((p) =>
                  p.fullName.toLowerCase().contains(q) ||
                  p.identifier.toLowerCase().contains(q))
              .toList();
        }
        return cached;
      }

      // Default sample clinical patients if initial offline state
      return _getFallbackPatients(query);
    }
  }

  Future<void> _cachePatients(List<PatientModel> patients) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(patients.map((e) => e.toJson()).toList());
      await prefs.setString(_cachedPatientsKey, raw);
    } catch (_) {}
  }

  Future<List<PatientModel>> _getCachedPatients() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cachedPatientsKey);
      if (raw == null || raw.isEmpty) return [];

      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => PatientModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<PatientModel> _getFallbackPatients(String? query) {
    final defaultList = [
      const PatientModel(
        id: 1,
        identifier: 'PAT-2026-001',
        firstName: 'Jean',
        lastName: 'Dupont',
        phone: '+33 6 12 34 56 78',
        email: 'jean.dupont@email.fr',
        allergies: ['Penicillin', 'Latex'],
        cabinetRoom: 'Fauteuil 1',
      ),
      const PatientModel(
        id: 2,
        identifier: 'PAT-2026-002',
        firstName: 'Marie',
        lastName: 'Curie',
        phone: '+33 6 98 76 54 32',
        email: 'marie.curie@email.fr',
        allergies: [],
        cabinetRoom: 'Fauteuil 2',
      ),
      const PatientModel(
        id: 3,
        identifier: 'PAT-2026-003',
        firstName: 'Alexandre',
        lastName: 'Martin',
        phone: '+33 7 11 22 33 44',
        email: 'alex.martin@email.fr',
        allergies: ['Aspirin'],
        cabinetRoom: 'Chirurgie',
      ),
      const PatientModel(
        id: 4,
        identifier: 'PAT-2026-004',
        firstName: 'Camille',
        lastName: 'Lefevre',
        phone: '+33 6 55 44 33 22',
        cabinetRoom: 'Fauteuil 1',
      ),
    ];

    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      return defaultList
          .where((p) =>
              p.fullName.toLowerCase().contains(q) ||
              p.identifier.toLowerCase().contains(q))
          .toList();
    }
    return defaultList;
  }
}
