import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/cycle_item.dart';
import '../entities/sterilization_cycle.dart';

abstract class LabelDetailRepository {
  Future<Either<Failure, SterilizationCycle>> getCycleDetails(String cycleId);
  Future<Either<Failure, List<CycleItem>>> getCycleItems(String cycleId);
  Future<Either<Failure, List<String>>> getCycleAttachments(String cycleId);
}
