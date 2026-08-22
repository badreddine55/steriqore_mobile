import 'package:equatable/equatable.dart';

class CabinetSettings extends Equatable {
  final int id;
  final String cabinetName;
  final String cabinetCode;
  final String? address;
  final String? phone;
  final String? email;
  final int dlcThresholdDays;
  final int lowStockThreshold;
  final bool enableBiometrics;
  final bool autoSyncEnabled;
  final String? primaryAutoclaveId;

  const CabinetSettings({
    required this.id,
    required this.cabinetName,
    required this.cabinetCode,
    this.address,
    this.phone,
    this.email,
    this.dlcThresholdDays = 30,
    this.lowStockThreshold = 5,
    this.enableBiometrics = true,
    this.autoSyncEnabled = true,
    this.primaryAutoclaveId,
  });

  CabinetSettings copyWith({
    int? id,
    String? cabinetName,
    String? cabinetCode,
    String? address,
    String? phone,
    String? email,
    int? dlcThresholdDays,
    int? lowStockThreshold,
    bool? enableBiometrics,
    bool? autoSyncEnabled,
    String? primaryAutoclaveId,
  }) {
    return CabinetSettings(
      id: id ?? this.id,
      cabinetName: cabinetName ?? this.cabinetName,
      cabinetCode: cabinetCode ?? this.cabinetCode,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      dlcThresholdDays: dlcThresholdDays ?? this.dlcThresholdDays,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      enableBiometrics: enableBiometrics ?? this.enableBiometrics,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      primaryAutoclaveId: primaryAutoclaveId ?? this.primaryAutoclaveId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        cabinetName,
        cabinetCode,
        address,
        phone,
        email,
        dlcThresholdDays,
        lowStockThreshold,
        enableBiometrics,
        autoSyncEnabled,
        primaryAutoclaveId,
      ];
}
