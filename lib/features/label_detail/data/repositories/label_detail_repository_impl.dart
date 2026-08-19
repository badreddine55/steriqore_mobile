import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/cycle_item.dart';
import '../../domain/entities/sterilization_cycle.dart';
import '../../domain/repositories/label_detail_repository.dart';
import '../datasources/label_detail_remote_datasource.dart';

class LabelDetailRepositoryImpl implements LabelDetailRepository {
  final LabelDetailRemoteDataSource remoteDataSource;

  LabelDetailRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, SterilizationCycle>> getCycleDetails(String cycleId) async {
    try {
      final cycle = await remoteDataSource.getCycleDetails(cycleId);
      return Right(cycle.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CycleItem>>> getCycleItems(String cycleId) async {
    try {
      final items = await remoteDataSource.getCycleItems(cycleId);
      return Right(items.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCycleAttachments(String cycleId) async {
    try {
      final attachments = await remoteDataSource.getCycleAttachments(cycleId);
      return Right(attachments);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
