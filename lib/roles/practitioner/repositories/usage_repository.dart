import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../../core/constants/api_constants.dart';
import '../../../services/auth_service.dart';
import '../models/label_model.dart';
import '../models/patient_model.dart';
import '../models/usage_model.dart';
import '../offline/scan_outbox.dart';
import 'practitioner_exceptions.dart';

/// Repository for recording clinical usage of sterilized instruments on patients with idempotency
class UsageRepository {
  final http.Client _client;
  static const _uuid = Uuid();

  UsageRepository({http.Client? client}) : _client = client ?? http.Client();

  /// Hits `POST /api/v1/labels/{label}/usage`
  ///
  /// Records instrument package usage against a specific patient.
  /// Mandates an [idempotencyKey] (reused on retry) to guarantee compliance and prevent duplicate usage logs.
  ///
  /// If offline, queues the record in [ScanOutbox] with `pending` status and optimistic UI response.
  Future<UsageModel> recordUsage({
    required LabelModel label,
    required PatientModel patient,
    String? notes,
    String? procedureType,
    String? existingIdempotencyKey,
  }) async {
    // Generate or reuse client-side UUID idempotency key
    final idempotencyKey = existingIdempotencyKey ?? _uuid.v4();
    final user = await AuthService.getUser();
    final token = await AuthService.getToken();

    final usageDraft = UsageModel(
      idempotencyKey: idempotencyKey,
      labelId: label.id,
      labelCode: label.code,
      productName: label.productName,
      lotNumber: label.lotNumber,
      reference: label.reference,
      patientId: patient.id,
      patientName: patient.fullName,
      patientIdentifier: patient.identifier,
      practitionerId: user?.id ?? 0,
      practitionerName: user?.name ?? 'Practitioner',
      usedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
      notes: notes,
      procedureType: procedureType,
    );

    final url = Uri.parse(ApiConstants.labelUsage(label.id > 0 ? label.id : label.code));

    try {
      final response = await _client.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Idempotency-Key': idempotencyKey,
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'patient_id': patient.id,
          'notes': notes,
          'procedure_type': procedureType,
          'used_at': usageDraft.usedAt.toIso8601String(),
          'idempotency_key': idempotencyKey,
        }),
      ).timeout(const Duration(seconds: 10));

      final statusCode = response.statusCode;

      if (statusCode == 200 || statusCode == 201) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = (body['data'] is Map<String, dynamic>)
            ? body['data'] as Map<String, dynamic>
            : body;

        final saved = UsageModel.fromJson(data).copyWith(
          idempotencyKey: idempotencyKey,
          syncStatus: SyncStatus.synced,
        );

        // Update outbox with synced state
        await ScanOutbox.updateItem(saved);
        return saved;
      } else if (statusCode == 401) {
        throw const TokenExpiredException();
      } else if (statusCode == 403) {
        throw const RoleForbiddenException();
      } else if (statusCode == 404) {
        throw LabelNotFoundException(label.code);
      } else if (statusCode == 409) {
        throw UsageAlreadyRecordedException(label, 'Instrument usage was already recorded.');
      } else if (statusCode == 410) {
        throw LabelBlockedException(label, 'Safety Block: Instrument expired or recalled.');
      } else if (statusCode == 422) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final rawErrors = body['errors'] as Map<String, dynamic>? ?? {};
        final parsedErrors = rawErrors.map((k, v) => MapEntry(
            k, (v is List) ? v.map((e) => e.toString()).toList() : [v.toString()]));
        throw PractitionerValidationException(parsedErrors, body['message'] as String? ?? 'Validation error');
      } else if (statusCode == 429) {
        throw const RateLimitException();
      } else {
        throw PractitionerException('Server returned code $statusCode', statusCode);
      }
    } catch (e) {
      if (e is PractitionerException && e is! NetworkOfflineException) {
        // Known business compliance failure (e.g. 409, 410, 422)
        if (e is LabelBlockedException || e is UsageAlreadyRecordedException) {
          rethrow;
        }
      }

      // Network error / Shaky Wi-Fi: Queue in local outbox
      final offlineItem = usageDraft.copyWith(
        syncStatus: SyncStatus.pending,
        errorMessage: e.toString(),
      );
      await ScanOutbox.addToQueue(offlineItem);
      return offlineItem;
    }
  }

  /// Hits `GET /api/v1/usages`
  ///
  /// Lists historical usage entries for the current practitioner, merged with any pending offline items.
  Future<List<UsageModel>> getUsageHistory({
    int? patientId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final token = await AuthService.getToken();
    final url = Uri.parse(ApiConstants.usages).replace(
      queryParameters: {
        if (patientId != null) 'patient_id': patientId.toString(),
        if (fromDate != null) 'from': fromDate.toIso8601String(),
        if (toDate != null) 'to': toDate.toIso8601String(),
      },
    );

    List<UsageModel> serverList = [];

    try {
      final response = await _client.get(
        url,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final list = (body['data'] as List<dynamic>?) ?? [];
        serverList = list.map((e) => UsageModel.fromJson(e as Map<String, dynamic>)).toList();
      } else if (response.statusCode == 401) {
        throw const TokenExpiredException();
      }
    } catch (_) {
      // Network failure: fall back to local outbox
    }

    // Merge with local pending outbox items (avoiding duplicates)
    final localQueue = await ScanOutbox.getAllQueue();
    final combinedMap = <String, UsageModel>{};

    for (final s in serverList) {
      combinedMap[s.idempotencyKey] = s;
    }
    for (final l in localQueue) {
      // Local pending/failed items take precedence over missing server state
      if (!combinedMap.containsKey(l.idempotencyKey) || l.syncStatus != SyncStatus.synced) {
        combinedMap[l.idempotencyKey] = l;
      }
    }

    final result = combinedMap.values.toList();
    result.sort((a, b) => b.usedAt.compareTo(a.usedAt));
    return result;
  }
}
