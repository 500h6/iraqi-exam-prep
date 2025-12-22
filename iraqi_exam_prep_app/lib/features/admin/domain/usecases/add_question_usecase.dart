import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/question_input.dart';
import '../repositories/admin_repository.dart';

class AddQuestionUseCase {
  final AdminRepository repository;

  AddQuestionUseCase(this.repository);

  Future<Either<Failure, void>> call(QuestionInput input) {
    return repository.addQuestion(input);
  }
}
