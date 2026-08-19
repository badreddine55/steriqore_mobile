import 'dart:async';
import '../../features/scanner/data/datasources/scanner_remote_datasource.dart';
import '../../features/usage/data/datasources/usage_local_datasource.dart';
import '../../features/usage/data/datasources/usage_remote_datasource.dart';
import '../../features/usage/data/models/usage_request_model.dart';
import '../../features/usage/data/models/usage_response_model.dart';
import '../../features/usage/domain/entities/instrument_usage.dart';
import '../network/network_info.dart';
import '../utils/date_formatter.dart';

class SyncService {
  final NetworkInfo networkInfo;
  final UsageLocalDataSource usageLocalDataSource;
  final UsageRemoteDataSource usageRemoteDataSource;
  final ScannerRemoteDataSource scannerRemoteDataSource;

  StreamSubscription<bool>? _connectivitySubscription;
  bool _isSyncing = false;

  SyncService({
    required this.networkInfo,
    required this.usageLocalDataSource,
    required this.usageRemoteDataSource,
    required this.scannerRemoteDataSource,
  });

  void initialize() {
    _connectivitySubscription = networkInfo.onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        syncPendingUsages();
      }
    });
  }

  Future<void> syncPendingUsages() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        _isSyncing = false;
        return;
      }

      final pendingQueue = await usageLocalDataSource.getPendingQueue();
      if (pendingQueue.isEmpty) {
        _isSyncing = false;
        return;
      }

      for (final usage in pendingQueue) {
        await _processUsageSync(usage);
      }
    } catch (_) {
      // Catch all to protect background service
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _processUsageSync(UsageResponseModel usage) async {
    try {
      // 1. Mark as syncing
      final inProgress = UsageResponseModel(
        id: usage.id,
        idempotencyKey: usage.idempotencyKey,
        labelId: usage.labelId,
        labelCode: usage.labelCode,
        productName: usage.productName,
        lotNumber: usage.lotNumber,
        patientId: usage.patientId,
        patientName: usage.patientName,
        dossierId: usage.dossierId,
        patientAllergies: usage.patientAllergies,
        practitionerId: usage.practitionerId,
        practitionerName: usage.practitionerName,
        usedAt: usage.usedAt,
        syncStatus: UsageSyncStatus.syncing,
        procedureType: usage.procedureType,
        notes: usage.notes,
      );
      await usageLocalDataSource.updateUsage(inProgress);

      // 2. Re-verify label online before sync to prevent recording recalled instrument
      try {
        final label = await scannerRemoteDataSource.getLabelByCode(usage.labelCode);
        if (label.isBlocked) {
          final failed = UsageResponseModel(
            id: usage.id,
            idempotencyKey: usage.idempotencyKey,
            labelId: usage.labelId,
            labelCode: usage.labelCode,
            productName: usage.productName,
            lotNumber: usage.lotNumber,
            patientId: usage.patientId,
            patientName: usage.patientName,
            dossierId: usage.dossierId,
            patientAllergies: usage.patientAllergies,
            practitionerId: usage.practitionerId,
            practitionerName: usage.practitionerName,
            usedAt: usage.usedAt,
            syncStatus: UsageSyncStatus.failed,
            errorMessage: 'Safety Gate: Instrument was recalled before sync.',
            procedureType: usage.procedureType,
            notes: usage.notes,
          );
          await usageLocalDataSource.updateUsage(failed);
          return;
        }
      } catch (_) {
        // If label check fails but network available, proceed with usage submission
      }

      // 3. Post usage with preserved client-side idempotency key
      final request = UsageRequestModel(
        patientId: usage.patientId,
        practitionerId: usage.practitionerId,
        usedAt: DateFormatter.formatIso(usage.usedAt),
        idempotencyKey: usage.idempotencyKey,
        procedureType: usage.procedureType,
        notes: usage.notes,
      );

      final response = await usageRemoteDataSource.recordUsage(
        labelId: usage.labelId,
        request: request,
      );

      // 4. Mark as synced
      final synced = UsageResponseModel(
        id: response.id,
        idempotencyKey: usage.idempotencyKey,
        labelId: usage.labelId,
        labelCode: usage.labelCode,
        productName: usage.productName,
        lotNumber: usage.lotNumber,
        patientId: usage.patientId,
        patientName: usage.patientName,
        dossierId: usage.dossierId,
        patientAllergies: usage.patientAllergies,
        practitionerId: usage.practitionerId,
        practitionerName: usage.practitionerName,
        usedAt: usage.usedAt,
        syncStatus: UsageSyncStatus.synced,
        procedureType: usage.procedureType,
        notes: usage.notes,
      );

      await usageLocalDataSource.updateUsage(synced);
    } catch (e) {
      // Revert to pending or failed
      final failed = UsageResponseModel(
        id: usage.id,
        idempotencyKey: usage.idempotencyKey,
        labelId: usage.labelId,
        labelCode: usage.labelCode,
        productName: usage.productName,
        lotNumber: usage.lotNumber,
        patientId: usage.patientId,
        patientName: usage.patientName,
        dossierId: usage.dossierId,
        patientAllergies: usage.patientAllergies,
        practitionerId: usage.practitionerId,
        practitionerName: usage.practitionerName,
        usedAt: usage.usedAt,
        syncStatus: UsageSyncStatus.pending,
        errorMessage: e.toString(),
        procedureType: usage.procedureType,
        notes: usage.notes,
      );
      await usageLocalDataSource.updateUsage(failed);
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
