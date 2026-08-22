import 'package:equatable/equatable.dart';
import '../../domain/entities/cabinet_settings.dart';

abstract class AdminSettingsEvent extends Equatable {
  const AdminSettingsEvent();

  @override
  List<Object?> get props => [];
}

class AdminLoadSettingsRequested extends AdminSettingsEvent {
  const AdminLoadSettingsRequested();
}

class AdminUpdateSettingsSubmitted extends AdminSettingsEvent {
  final CabinetSettings settings;
  const AdminUpdateSettingsSubmitted(this.settings);

  @override
  List<Object?> get props => [settings];
}
