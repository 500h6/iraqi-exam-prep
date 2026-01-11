import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/admin_repository.dart';

class DeleteQuestionUseCase {
  final AdminRepository repository;

  DeleteQuestionUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteQuestion(id);
  }
}
