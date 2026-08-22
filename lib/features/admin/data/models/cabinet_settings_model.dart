import '../../domain/entities/cabinet_settings.dart';

class CabinetSettingsModel extends CabinetSettings {
  const CabinetSettingsModel({
    required super.id,
    required super.cabinetName,
    required super.cabinetCode,
    super.address,
    super.phone,
    super.email,
    super.dlcThresholdDays = 30,
    super.lowStockThreshold = 5,
    super.enableBiometrics = true,
    super.autoSyncEnabled = true,
    super.primaryAutoclaveId,
  });

  factory CabinetSettingsModel.fromJson(Map<String, dynamic> json) {
    return CabinetSettingsModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '1') ?? 1,
      cabinetName: json['cabinet_name'] as String? ?? json['name'] as String? ?? 'Cabinet Dentaire',
      cabinetCode: json['cabinet_code'] as String? ?? json['code'] as String? ?? 'CAB-001',
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      dlcThresholdDays: json['dlc_threshold_days'] is int
          ? json['dlc_threshold_days'] as int
          : int.tryParse(json['dlc_threshold_days']?.toString() ?? '30') ?? 30,
      lowStockThreshold: json['low_stock_threshold'] is int
          ? json['low_stock_threshold'] as int
          : int.tryParse(json['low_stock_threshold']?.toString() ?? '5') ?? 5,
      enableBiometrics: json['enable_biometrics'] is bool ? json['enable_biometrics'] as bool : true,
      autoSyncEnabled: json['auto_sync_enabled'] is bool ? json['auto_sync_enabled'] as bool : true,
      primaryAutoclaveId: json['primary_autoclave_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cabinet_name': cabinetName,
      'cabinet_code': cabinetCode,
      'address': address,
      'phone': phone,
      'email': email,
      'dlc_threshold_days': dlcThresholdDays,
      'low_stock_threshold': lowStockThreshold,
      'enable_biometrics': enableBiometrics,
      'auto_sync_enabled': autoSyncEnabled,
      'primary_autoclave_id': primaryAutoclaveId,
    };
  }

  CabinetSettings toEntity() {
    return CabinetSettings(
      id: id,
      cabinetName: cabinetName,
      cabinetCode: cabinetCode,
      address: address,
      phone: phone,
      email: email,
      dlcThresholdDays: dlcThresholdDays,
      lowStockThreshold: lowStockThreshold,
      enableBiometrics: enableBiometrics,
      autoSyncEnabled: autoSyncEnabled,
      primaryAutoclaveId: primaryAutoclaveId,
    );
  }
}
