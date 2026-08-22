import 'package:equatable/equatable.dart';
import '../../domain/entities/cabinet_settings.dart';

enum AdminSettingsStatus { initial, loading, loaded, saving, saved, error }

class AdminSettingsState extends Equatable {
  final AdminSettingsStatus status;
  final CabinetSettings? settings;
  final String? errorMessage;
  final String? successMessage;

  const AdminSettingsState({
    this.status = AdminSettingsStatus.initial,
    this.settings,
    this.errorMessage,
    this.successMessage,
  });

  AdminSettingsState copyWith({
    AdminSettingsStatus? status,
    CabinetSettings? settings,
    String? errorMessage,
    String? successMessage,
  }) {
    return AdminSettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [status, settings, errorMessage, successMessage];
}
