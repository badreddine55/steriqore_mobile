import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../models/label_model.dart';
import '../models/patient_model.dart';
import '../models/usage_model.dart';
import '../repositories/label_repository.dart';
import '../repositories/usage_repository.dart';
import 'scan_outbox.dart';

/// Sync service that listens to network connectivity streams and syncs queued usage records
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final UsageRepository _usageRepo = UsageRepository();
  final LabelRepository _labelRepo = LabelRepository();
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  final ValueNotifier<int> pendingCount = ValueNotifier<int>(0);
  final ValueNotifier<bool> isSyncing = ValueNotifier<bool>(false);
  final ValueNotifier<String?> lastSyncMessage = ValueNotifier<String?>(null);

  /// Initialize connectivity stream listener
  void initialize() {
    refreshPendingCount();
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection) {
        syncNow();
      }
    });
  }

  /// Update pending count for badges
  Future<void> refreshPendingCount() async {
    final pending = await ScanOutbox.getPendingQueue();
    pendingCount.value = pending.length;
  }

  /// Manually or automatically trigger background sync
  Future<int> syncNow() async {
    if (_isSyncing) return 0;
    _isSyncing = true;
    isSyncing.value = true;

    int syncedCount = 0;

    try {
      final pendingList = await ScanOutbox.getPendingQueue();
      if (pendingList.isEmpty) {
        lastSyncMessage.value = 'All records up to date';
        return 0;
      }

      for (final item in pendingList) {
        // Mark as syncing in outbox
        await ScanOutbox.updateItem(item.copyWith(syncStatus: SyncStatus.syncing));

        try {
          // Re-validate label status online before pushing to prevent synced recalls
          LabelModel? verifiedLabel;
          try {
            verifiedLabel = await _labelRepo.getLabelByCode(item.labelCode);
          } catch (_) {
            // If offline re-check fails, use recorded item details
          }

          if (verifiedLabel != null && verifiedLabel.isBlocked) {
            // Item was recalled or expired while offline: mark as failed with compliance reason
            await ScanOutbox.updateItem(item.copyWith(
              syncStatus: SyncStatus.failed,
              errorMessage: 'SAFETY BLOCK: Label is ${verifiedLabel.status.toDisplayString()}',
            ));
            continue;
          }

          final label = verifiedLabel ??
              LabelModel(
                id: item.labelId,
                code: item.labelCode,
                productName: item.productName,
                reference: item.reference,
                lotNumber: item.lotNumber,
                expirationDate: DateTime.now().add(const Duration(days: 90)),
                status: LabelStatus.valid,
              );

          final patient = PatientModel(
            id: item.patientId,
            identifier: item.patientIdentifier ?? 'PAT-${item.patientId}',
            firstName: item.patientName.split(' ').first,
            lastName: item.patientName.split(' ').skip(1).join(' '),
          );

          final result = await _usageRepo.recordUsage(
            label: label,
            patient: patient,
            notes: item.notes,
            procedureType: item.procedureType,
            existingIdempotencyKey: item.idempotencyKey,
          );

          if (result.syncStatus == SyncStatus.synced) {
            syncedCount++;
          }
        } catch (e) {
          await ScanOutbox.updateItem(item.copyWith(
            syncStatus: SyncStatus.failed,
            errorMessage: e.toString(),
            retryCount: item.retryCount + 1,
          ));
        }
      }

      lastSyncMessage.value = syncedCount > 0
          ? 'Successfully synchronized $syncedCount usage records'
          : null;
    } finally {
      _isSyncing = false;
      isSyncing.value = false;
      await refreshPendingCount();
    }

    return syncedCount;
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    pendingCount.dispose();
    isSyncing.dispose();
    lastSyncMessage.dispose();
  }
}
