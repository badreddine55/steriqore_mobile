import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/label.dart';

abstract class ScannerRepository {
  Future<Either<Failure, Label>> scanLabel(String rawCode);
  Future<Either<Failure, Label>> getLabelDetails(String code);
  Future<List<String>> getRecentScannedCodes();
  Future<void> saveRecentCode(String code);
}
