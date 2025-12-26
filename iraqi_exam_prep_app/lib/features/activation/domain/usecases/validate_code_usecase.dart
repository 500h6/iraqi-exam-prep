import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/activation_repository.dart';
import '../../../auth/domain/entities/user_entity.dart';

class ValidateCodeUseCase {
  final ActivationRepository repository;

  ValidateCodeUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String code) async {
    return await repository.validateCode(code);
  }
}
