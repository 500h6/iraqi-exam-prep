import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class ActivationRepository {
  Future<Either<Failure, bool>> validateCode(String code);
  Future<Either<Failure, bool>> checkSubscription();
}
