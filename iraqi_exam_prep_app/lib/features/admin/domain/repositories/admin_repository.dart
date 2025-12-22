import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/question_input.dart';

abstract class AdminRepository {
  Future<Either<Failure, void>> addQuestion(QuestionInput input);
}
