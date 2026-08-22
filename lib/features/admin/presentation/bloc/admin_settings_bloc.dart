import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_cabinet_settings.dart';
import '../../domain/usecases/update_cabinet_settings.dart';
import 'admin_settings_event.dart';
import 'admin_settings_state.dart';

class AdminSettingsBloc extends Bloc<AdminSettingsEvent, AdminSettingsState> {
  final GetCabinetSettingsUseCase getCabinetSettingsUseCase;
  final UpdateCabinetSettingsUseCase updateCabinetSettingsUseCase;

  AdminSettingsBloc({
    required this.getCabinetSettingsUseCase,
    required this.updateCabinetSettingsUseCase,
  }) : super(const AdminSettingsState()) {
    on<AdminLoadSettingsRequested>(_onLoadSettings);
    on<AdminUpdateSettingsSubmitted>(_onUpdateSettings);
  }

  Future<void> _onLoadSettings(
    AdminLoadSettingsRequested event,
    Emitter<AdminSettingsState> emit,
  ) async {
    emit(state.copyWith(status: AdminSettingsStatus.loading));

    final result = await getCabinetSettingsUseCase(const NoParams());

    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminSettingsStatus.error,
        errorMessage: failure.message,
      )),
      (settings) => emit(state.copyWith(
        status: AdminSettingsStatus.loaded,
        settings: settings,
      )),
    );
  }

  Future<void> _onUpdateSettings(
    AdminUpdateSettingsSubmitted event,
    Emitter<AdminSettingsState> emit,
  ) async {
    emit(state.copyWith(status: AdminSettingsStatus.saving));

    final result = await updateCabinetSettingsUseCase(UpdateCabinetSettingsParams(event.settings));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminSettingsStatus.error,
        errorMessage: failure.message,
      )),
      (settings) => emit(state.copyWith(
        status: AdminSettingsStatus.saved,
        settings: settings,
        successMessage: 'Cabinet settings successfully updated.',
      )),
    );
  }
}
