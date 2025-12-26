import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class ActivationRepository {
  Future<Either<Failure, UserEntity>> validateCode(String code);
  Future<Either<Failure, bool>> checkSubscription();
}
