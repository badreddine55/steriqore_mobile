import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'core/di/injection.dart';
import 'core/routes/app_router.dart';
import 'core/services/sync_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/login.dart';
import 'features/auth/domain/usecases/logout.dart';
import 'features/auth/domain/usecases/register.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/history/domain/repositories/history_repository.dart';
import 'features/history/domain/usecases/get_practitioner_history.dart';
import 'features/history/presentation/bloc/history_bloc.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/home/domain/usecases/get_dashboard_stats.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/label_detail/domain/repositories/label_detail_repository.dart';
import 'features/label_detail/domain/usecases/get_cycle_attachments.dart';
import 'features/label_detail/domain/usecases/get_cycle_details.dart';
import 'features/label_detail/domain/usecases/get_cycle_items.dart';
import 'features/label_detail/presentation/bloc/label_detail_bloc.dart';
import 'features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'features/scanner/domain/repositories/scanner_repository.dart';
import 'features/scanner/domain/usecases/get_label_details.dart';
import 'features/scanner/domain/usecases/scan_label.dart';
import 'features/scanner/presentation/bloc/scanner_bloc.dart';
import 'features/usage/domain/repositories/usage_repository.dart';
import 'features/usage/domain/usecases/get_patients.dart';
import 'features/usage/domain/usecases/get_usage_history.dart';
import 'features/usage/domain/usecases/record_usage.dart';
import 'features/usage/presentation/bloc/usage_bloc.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure high-contrast clinical status bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Clean Architecture Service Locator & Hive
  await configureDependencies();

  // Start Offline Sync Observer
  sl<SyncService>().initialize();

  runApp(const SteriqoreApp());
}

class SteriqoreApp extends StatelessWidget {
  const SteriqoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Domain UseCases & Repositories
        Provider<AuthRepository>.value(value: sl<AuthRepository>()),
        Provider<LoginUseCase>.value(value: sl<LoginUseCase>()),
        Provider<RegisterUseCase>.value(value: sl<RegisterUseCase>()),
        Provider<LogoutUseCase>.value(value: sl<LogoutUseCase>()),
        Provider<GetCurrentUserUseCase>.value(value: sl<GetCurrentUserUseCase>()),

        Provider<ScannerRepository>.value(value: sl<ScannerRepository>()),
        Provider<ScanLabelUseCase>.value(value: sl<ScanLabelUseCase>()),
        Provider<GetLabelDetailsUseCase>.value(value: sl<GetLabelDetailsUseCase>()),

        Provider<LabelDetailRepository>.value(value: sl<LabelDetailRepository>()),
        Provider<GetCycleDetailsUseCase>.value(value: sl<GetCycleDetailsUseCase>()),
        Provider<GetCycleItemsUseCase>.value(value: sl<GetCycleItemsUseCase>()),
        Provider<GetCycleAttachmentsUseCase>.value(value: sl<GetCycleAttachmentsUseCase>()),

        Provider<UsageRepository>.value(value: sl<UsageRepository>()),
        Provider<GetPatientsUseCase>.value(value: sl<GetPatientsUseCase>()),
        Provider<RecordUsageUseCase>.value(value: sl<RecordUsageUseCase>()),
        Provider<GetUsageHistoryUseCase>.value(value: sl<GetUsageHistoryUseCase>()),

        Provider<HistoryRepository>.value(value: sl<HistoryRepository>()),
        Provider<GetPractitionerHistoryUseCase>.value(value: sl<GetPractitionerHistoryUseCase>()),

        Provider<HomeRepository>.value(value: sl<HomeRepository>()),
        Provider<GetDashboardStatsUseCase>.value(value: sl<GetDashboardStatsUseCase>()),

        // Feature BLoCs
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<OnboardingBloc>(
          create: (_) => sl<OnboardingBloc>(),
        ),
        BlocProvider<HomeBloc>(
          create: (_) => sl<HomeBloc>(),
        ),
        BlocProvider<ScannerBloc>(
          create: (_) => sl<ScannerBloc>(),
        ),
        BlocProvider<LabelDetailBloc>(
          create: (_) => sl<LabelDetailBloc>(),
        ),
        BlocProvider<UsageBloc>(
          create: (_) => sl<UsageBloc>(),
        ),
        BlocProvider<HistoryBloc>(
          create: (_) => sl<HistoryBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'STERIQORE — Dental Traceability',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        scrollBehavior: AppScrollBehavior(),
        routerConfig: appRouter,
      ),
    );
  }
}
