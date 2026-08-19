import 'package:equatable/equatable.dart';
import '../../models/usage_model.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsageHistory extends HistoryEvent {
  const LoadUsageHistory();
}

class FilterHistoryByDate extends HistoryEvent {
  final DateTime? from;
  final DateTime? to;

  const FilterHistoryByDate({this.from, this.to});

  @override
  List<Object?> get props => [from, to];
}

class FilterHistoryByPatient extends HistoryEvent {
  final int? patientId;

  const FilterHistoryByPatient(this.patientId);

  @override
  List<Object?> get props => [patientId];
}

class SearchHistory extends HistoryEvent {
  final String query;

  const SearchHistory(this.query);

  @override
  List<Object?> get props => [query];
}

class RetrySyncItem extends HistoryEvent {
  final UsageModel usage;

  const RetrySyncItem(this.usage);

  @override
  List<Object?> get props => [usage];
}
