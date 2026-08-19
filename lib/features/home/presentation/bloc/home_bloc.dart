import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_dashboard_stats.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetDashboardStatsUseCase getDashboardStatsUseCase;

  HomeBloc({
    required this.getDashboardStatsUseCase,
  }) : super(const HomeInitial()) {
    on<HomeLoadRequested>(_onHomeLoadRequested);
    on<HomeRefreshRequested>(_onHomeRefreshRequested);
  }

  Future<void> _onHomeLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    final result = await getDashboardStatsUseCase(const NoParams());
    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (stats) => emit(HomeLoaded(stats)),
    );
  }

  Future<void> _onHomeRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    final result = await getDashboardStatsUseCase(const NoParams());
    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (stats) => emit(HomeLoaded(stats)),
    );
  }
}
