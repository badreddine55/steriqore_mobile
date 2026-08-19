import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/usage_history_entry.dart';
import '../repositories/history_repository.dart';

class GetPractitionerHistoryParams extends Equatable {
  final int page;
  final String? search;
  final String? filterDate;

  const GetPractitionerHistoryParams({
    this.page = 1,
    this.search,
    this.filterDate,
  });

  @override
  List<Object?> get props => [page, search, filterDate];
}

class GetPractitionerHistoryUseCase
    implements UseCase<List<UsageHistoryEntry>, GetPractitionerHistoryParams> {
  final HistoryRepository repository;

  GetPractitionerHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<UsageHistoryEntry>>> call(
      GetPractitionerHistoryParams params) {
    return repository.getPractitionerHistory(
      page: params.page,
      search: params.search,
      filterDate: params.filterDate,
    );
  }
}
