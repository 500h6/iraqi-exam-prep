import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class IdentifyUseCase {
  final AuthRepository repository;

  IdentifyUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String name,
    required String phone,
    String? branch,
    String? city,
  }) {
    return repository.identify(
      name: name,
      phone: phone,
      branch: branch,
      city: city,
    );
  }
}
