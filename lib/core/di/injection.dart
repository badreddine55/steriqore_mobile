import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/network_info.dart';
import '../../core/services/sync_service.dart';
import '../../core/utils/first_launch_checker.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/domain/usecases/register.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/onboarding/data/datasources/onboarding_local_datasource.dart';
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart';

import '../../features/home/data/datasources/home_remote_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_dashboard_stats.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';

import '../../features/scanner/data/datasources/scanner_local_datasource.dart';
import '../../features/scanner/data/datasources/scanner_remote_datasource.dart';
import '../../features/scanner/data/repositories/scanner_repository_impl.dart';
import '../../features/scanner/domain/repositories/scanner_repository.dart';
import '../../features/scanner/domain/usecases/get_label_details.dart';
import '../../features/scanner/domain/usecases/scan_label.dart';
import '../../features/scanner/presentation/bloc/scanner_bloc.dart';

import '../../features/label_detail/data/datasources/label_detail_remote_datasource.dart';
import '../../features/label_detail/data/repositories/label_detail_repository_impl.dart';
import '../../features/label_detail/domain/repositories/label_detail_repository.dart';
import '../../features/label_detail/domain/usecases/get_cycle_attachments.dart';
import '../../features/label_detail/domain/usecases/get_cycle_details.dart';
import '../../features/label_detail/domain/usecases/get_cycle_items.dart';
import '../../features/label_detail/presentation/bloc/label_detail_bloc.dart';

import '../../features/usage/data/datasources/usage_local_datasource.dart';
import '../../features/usage/data/datasources/usage_remote_datasource.dart';
import '../../features/usage/data/repositories/usage_repository_impl.dart';
import '../../features/usage/domain/repositories/usage_repository.dart';
import '../../features/usage/domain/usecases/get_patients.dart';
import '../../features/usage/domain/usecases/get_usage_history.dart';
import '../../features/usage/domain/usecases/record_usage.dart';
import '../../features/usage/presentation/bloc/usage_bloc.dart';

import '../../features/history/data/datasources/history_remote_datasource.dart';
import '../../features/history/data/repositories/history_repository_impl.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/history/domain/usecases/get_practitioner_history.dart';
import '../../features/history/presentation/bloc/history_bloc.dart';

import '../../features/admin/data/datasources/admin_remote_datasource.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/domain/usecases/create_cabinet_user.dart';
import '../../features/admin/domain/usecases/get_audit_trail.dart';
import '../../features/admin/domain/usecases/get_cabinet_settings.dart';
import '../../features/admin/domain/usecases/get_cabinet_users.dart';
import '../../features/admin/domain/usecases/toggle_user_status.dart';
import '../../features/admin/domain/usecases/update_cabinet_settings.dart';
import '../../features/admin/domain/usecases/update_cabinet_user.dart';
import '../../features/admin/presentation/bloc/admin_audit_bloc.dart';
import '../../features/admin/presentation/bloc/admin_settings_bloc.dart';
import '../../features/admin/presentation/bloc/admin_users_bloc.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // Initialize Hive
  try {
    await Hive.initFlutter();
    await Hive.openBox(StorageKeys.appSettingsBox);
    await Hive.openBox(StorageKeys.authBox);
  } catch (_) {}

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // Core Utils
  sl.registerLazySingleton<FirstLaunchChecker>(() => FirstLaunchChecker(prefs: sl()));
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<DioClient>(() => DioClient(secureStorage: sl()));

  // Onboarding Feature
  sl.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(firstLaunchChecker: sl()),
  );
  sl.registerFactory(() => OnboardingBloc(localDataSource: sl()));

  // Auth Feature
  final authLocalDataSource = AuthLocalDataSourceImpl(secureStorage: sl(), prefs: sl());
  await authLocalDataSource.getToken();
  await authLocalDataSource.getUser();
  sl.registerLazySingleton<AuthLocalDataSource>(() => authLocalDataSource);
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerFactory(() => AuthBloc(
        loginUseCase: sl(),
        logoutUseCase: sl(),
        getCurrentUserUseCase: sl(),
        registerUseCase: sl(),
        authRepository: sl(),
      ));

  // Scanner Feature
  sl.registerLazySingleton<ScannerRemoteDataSource>(() => ScannerRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<ScannerLocalDataSource>(() => ScannerLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<ScannerRepository>(() => ScannerRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()));
  sl.registerLazySingleton(() => ScanLabelUseCase(sl()));
  sl.registerLazySingleton(() => GetLabelDetailsUseCase(sl()));
  sl.registerFactory(() => ScannerBloc(scanLabelUseCase: sl()));

  // Label Detail Feature
  sl.registerLazySingleton<LabelDetailRemoteDataSource>(() => LabelDetailRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<LabelDetailRepository>(() => LabelDetailRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton(() => GetCycleDetailsUseCase(sl()));
  sl.registerLazySingleton(() => GetCycleItemsUseCase(sl()));
  sl.registerLazySingleton(() => GetCycleAttachmentsUseCase(sl()));
  sl.registerFactory(() => LabelDetailBloc(
        getLabelDetailsUseCase: sl(),
        getCycleDetailsUseCase: sl(),
      ));

  // Usage Feature
  sl.registerLazySingleton<UsageRemoteDataSource>(() => UsageRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<UsageLocalDataSource>(() => UsageLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<UsageRepository>(() => UsageRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()));
  sl.registerLazySingleton(() => GetPatientsUseCase(sl()));
  sl.registerLazySingleton(() => RecordUsageUseCase(sl()));
  sl.registerLazySingleton(() => GetUsageHistoryUseCase(sl()));
  sl.registerFactory(() => UsageBloc(
        getPatientsUseCase: sl(),
        recordUsageUseCase: sl(),
      ));

  // History Feature
  sl.registerLazySingleton<HistoryRemoteDataSource>(() => HistoryRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<HistoryRepository>(() => HistoryRepositoryImpl(remoteDataSource: sl(), usageLocalDataSource: sl()));
  sl.registerLazySingleton(() => GetPractitionerHistoryUseCase(sl()));
  sl.registerFactory(() => HistoryBloc(getPractitionerHistoryUseCase: sl()));

  // Home Feature
  sl.registerLazySingleton<HomeRemoteDataSource>(() => HomeRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(remoteDataSource: sl(), usageLocalDataSource: sl()));
  sl.registerLazySingleton(() => GetDashboardStatsUseCase(sl()));
  sl.registerFactory(() => HomeBloc(getDashboardStatsUseCase: sl()));

  // Admin Feature
  sl.registerLazySingleton<AdminRemoteDataSource>(() => AdminRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<AdminRepository>(() => AdminRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton(() => GetCabinetUsersUseCase(sl()));
  sl.registerLazySingleton(() => CreateCabinetUserUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCabinetUserUseCase(sl()));
  sl.registerLazySingleton(() => ToggleUserStatusUseCase(sl()));
  sl.registerLazySingleton(() => GetAuditTrailUseCase(sl()));
  sl.registerLazySingleton(() => GetCabinetSettingsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCabinetSettingsUseCase(sl()));
  sl.registerFactory(() => AdminUsersBloc(
        getCabinetUsersUseCase: sl(),
        createCabinetUserUseCase: sl(),
        updateCabinetUserUseCase: sl(),
        toggleUserStatusUseCase: sl(),
      ));
  sl.registerFactory(() => AdminAuditBloc(getAuditTrailUseCase: sl()));
  sl.registerFactory(() => AdminSettingsBloc(
        getCabinetSettingsUseCase: sl(),
        updateCabinetSettingsUseCase: sl(),
      ));

  // Sync Service
  sl.registerLazySingleton<SyncService>(() => SyncService(
        networkInfo: sl(),
        usageLocalDataSource: sl(),
        usageRemoteDataSource: sl(),
        scannerRemoteDataSource: sl(),
      ));
}
