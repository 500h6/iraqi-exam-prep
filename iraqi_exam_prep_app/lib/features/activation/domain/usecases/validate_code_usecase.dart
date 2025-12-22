import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/activation_repository.dart';

class ValidateCodeUseCase {
  final ActivationRepository repository;

  ValidateCodeUseCase(this.repository);

  Future<Either<Failure, bool>> call(String code) async {
    return await repository.validateCode(code);
  }
}
