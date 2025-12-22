import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/activation_repository.dart';

class CheckSubscriptionUseCase {
  final ActivationRepository repository;

  CheckSubscriptionUseCase(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.checkSubscription();
  }
}
