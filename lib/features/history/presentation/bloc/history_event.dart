import 'package:equatable/equatable.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class HistoryLoadRequested extends HistoryEvent {
  final String? query;
  final String? filter;

  const HistoryLoadRequested({this.query, this.filter});

  @override
  List<Object?> get props => [query, filter];
}

class HistoryRefreshRequested extends HistoryEvent {
  const HistoryRefreshRequested();
}

class HistoryFilterChangedEvent extends HistoryEvent {
  final String filter;

  const HistoryFilterChangedEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}
