import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../services/auth_service.dart';
import '../models/label_model.dart';
import '../offline/scan_outbox.dart';
import 'practitioner_exceptions.dart';

/// Repository for scanning, looking up and validating sterilization package labels
class LabelRepository {
  final http.Client _client;

  LabelRepository({http.Client? client}) : _client = client ?? http.Client();

  /// Hits `GET /api/v1/labels/{code}`
  ///
  /// Decodes and validates package labels (DataMatrix or QR).
  ///
  /// - Throws [TokenExpiredException] on 401
  /// - Throws [RoleForbiddenException] on 403
  /// - Throws [LabelNotFoundException] on 404
  /// - Throws [UsageAlreadyRecordedException] on 409
  /// - Throws [LabelBlockedException] on 410 (Expired DLC or Recalled Lot)
  /// - Throws [RateLimitException] on 429
  /// - Falls back to [ScanOutbox.getCachedLabel] when offline and strictly enforces local recall/DLC blocks
  Future<LabelModel> getLabelByCode(String code) async {
    final cleanCode = code.trim();
    if (cleanCode.isEmpty) {
      throw const LabelNotFoundException('', 'Scanned code is empty');
    }

    final token = await AuthService.getToken();
    final url = Uri.parse(ApiConstants.labelByCode(cleanCode));

    try {
      final response = await _client.get(
        url,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 8));

      final statusCode = response.statusCode;

      if (statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = (body['data'] is Map<String, dynamic>)
            ? body['data'] as Map<String, dynamic>
            : body;
        final label = LabelModel.fromJson(data);

        // Cache for future offline safety checks
        await ScanOutbox.cacheLabel(label);

        // Check if server marked it as blocked/expired
        if (label.isBlocked) {
          throw LabelBlockedException(
            label,
            label.recallReason ??
                (label.isExpiredByDate
                    ? 'DLC Expired (${label.expirationDate.toString().split(' ')[0]})'
                    : 'Safety block'),
          );
        }

        return label;
      } else if (statusCode == 401) {
        throw const TokenExpiredException();
      } else if (statusCode == 403) {
        throw const RoleForbiddenException();
      } else if (statusCode == 404) {
        throw LabelNotFoundException(cleanCode);
      } else if (statusCode == 409) {
        try {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          final data = body['data'] as Map<String, dynamic>?;
          final label = data != null ? LabelModel.fromJson(data) : null;
          throw UsageAlreadyRecordedException(label, body['message'] as String?);
        } catch (e) {
          if (e is UsageAlreadyRecordedException) rethrow;
          throw const UsageAlreadyRecordedException();
        }
      } else if (statusCode == 410) {
        try {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          final data = (body['data'] is Map<String, dynamic>)
              ? body['data'] as Map<String, dynamic>
              : body;
          final label = LabelModel.fromJson(data);
          final reason = body['message'] as String? ?? label.recallReason ?? 'Expired or recalled';
          throw LabelBlockedException(label, reason);
        } catch (e) {
          if (e is LabelBlockedException) rethrow;
          throw LabelBlockedException(
            LabelModel(
              id: 0,
              code: cleanCode,
              productName: 'Blocked Device',
              reference: 'BLOCKED',
              lotNumber: 'RECALLED',
              expirationDate: DateTime.now().subtract(const Duration(days: 1)),
              status: LabelStatus.recalled,
              recallReason: 'Recalled by manufacturer or practice authority',
            ),
            'Recalled or expired instrument',
          );
        }
      } else if (statusCode == 429) {
        final retryHeader = response.headers['retry-after'];
        final seconds = int.tryParse(retryHeader ?? '5') ?? 5;
        throw RateLimitException(seconds);
      } else {
        throw PractitionerException('Failed to fetch label ($statusCode)', statusCode);
      }
    } catch (e) {
      if (e is PractitionerException) rethrow;

      // Offline / Network unreachable fallback
      final cached = await ScanOutbox.getCachedLabel(cleanCode);
      if (cached != null) {
        // Enforce offline patient safety: never allow an expired/recalled instrument
        if (cached.isBlocked) {
          throw LabelBlockedException(
            cached,
            cached.recallReason ?? 'Expired DLC (Local cache verification)',
          );
        }
        return cached;
      }

      // If no local cache exists, construct an optimistic offline placeholder or throw offline error
      throw const NetworkOfflineException('Unable to reach server to verify label.');
    }
  }
}
