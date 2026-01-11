import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/question_input.dart';
import '../repositories/admin_repository.dart';

class UpdateQuestionUseCase {
  final AdminRepository repository;

  UpdateQuestionUseCase(this.repository);

  Future<Either<Failure, void>> call(String id, QuestionInput input) {
    return repository.updateQuestion(id, input);
  }
}
