import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_stats.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final DashboardStats stats;

  const HomeLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
